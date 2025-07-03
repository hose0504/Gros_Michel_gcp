#!/bin/bash
###############################################################################
# Gros-Michel bastion – startup script (user-data)
###############################################################################

# 1) 시스템 업데이트 & 기본 툴 설치
apt update -y && apt upgrade -y
apt install -y openjdk-17-jdk awscli \
               apt-transport-https ca-certificates gnupg curl \
               sudo lsb-release wget

# 2) kubectl 설치 (v1.29.2)
curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/

# 3) gcloud CLI 설치
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
      http://packages.cloud.google.com/apt cloud-sdk main" \
  | tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt update -y && apt install -y google-cloud-sdk

# 4) GKE 인증 플랫에인 설치 및 전역 환경 변수 등록
apt install -y google-cloud-sdk-gke-gcloud-auth-plugin
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' > /etc/profile.d/gcloud-auth.sh
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# 5) wish 계정 생성 & 서비스 계정 키 다운로드
id wish &>/dev/null || useradd -m -s /bin/bash wish
wget -qO - "https://storage.googleapis.com/grosmichel-tfstate-202506180252/terraform/state/terraform-sa.json.b64" \
  | base64 -d > /home/wish/terraform-sa.json
chown wish:wish /home/wish/terraform-sa.json

# 6) gcloud 인증 (root에서)
PROJECT="skillful-cortex-463200-a7"
retry=0
until gcloud auth activate-service-account --key-file=/home/wish/terraform-sa.json; do
  retry=$((retry+1))
  if [ $retry -ge 5 ]; then
    echo "[ERROR] gcloud auth failed after $retry attempts" | tee -a /var/log/startup.log
    exit 1
  fi
  echo "[WARN] gcloud auth failed. Retrying ($retry/5)..." | tee -a /var/log/startup.log
  sleep 5
done
gcloud config set project "$PROJECT"

# 7) GKE 클라스터가 RUNNING 될 때까지 기다린다
CLUSTER_NAME="gros-michel-gke-cluster"
REGION="us-central1"
echo "📱  Waiting for GKE cluster to be RUNNING…"
while true; do
  STATUS=$(gcloud container clusters describe "$CLUSTER_NAME" \
            --region "$REGION" --format='value(status)' 2>/dev/null)
  if [[ "$STATUS" == "RUNNING" ]]; then
    echo "[INFO] GKE cluster status = RUNNING ✅"; break
  fi
  echo "[INFO] Current status: ${STATUS:-NOT_FOUND}. Re-check in 30 s..."; sleep 30
done

# 8) wish 계정에 kubectl 인증 설정 복사
mkdir -p /home/wish/.kube /home/wish/.config
cp -r /root/.kube/* /home/wish/.kube/ 2>/dev/null || true
cp -r /root/.config/gcloud /home/wish/.config/ 2>/dev/null || true
chown -R wish:wish /home/wish/.kube /home/wish/.config
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/wish/.bashrc
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/wish/.profile

# 9) wish 계정으로 get-credentials 재시도
for i in {1..5}; do
  sudo -u wish bash -c "
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True
    mkdir -p /home/wish/.kube
    gcloud container clusters get-credentials $CLUSTER_NAME \
      --region $REGION --project $PROJECT
  " && break || sleep 30
done

# 확장: kube-apiserver 응답 기다린다
echo "⏳ Waiting for kube-apiserver to respond after credentials..."
for i in {1..10}; do
  if sudo -u wish kubectl cluster-info &>/dev/null; then
    echo "✅ kube-apiserver is responding"
    break
  fi
  echo "⏳ kube-apiserver not ready yet. Waiting ($i/10)..."
  sleep 5
done

# 10) kubectl 연결 확인
for i in {1..10}; do
  if sudo -u wish kubectl get nodes &>/dev/null; then
    echo "✅ kubectl connected to cluster"
    break
  fi
  echo "⏳ Waiting for kubectl to connect to cluster... ($i/10)"
  sleep 5
done

# 11) Helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 12) NGINX Ingress Controller 설치
sudo -u wish bash -c "
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.publishService.enabled=true
"

# ✅ NGINX Ingress Controller가 준비될 때까지 기다림
kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx --timeout=300s

# 13) Argo CD 설치
sudo -u wish bash -c "
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  echo '📁 Creating ArgoCD namespace...'
  kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

  echo '🚀 Installing ArgoCD...'
  for i in {1..5}; do
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml && break
    echo '[WARN] ArgoCD install attempt ($i/5) failed. Retrying in 10 sec...'
    sleep 10
  done

  echo '⏳ Waiting for ArgoCD CRD to be ready...'
  for i in {1..10}; do
    kubectl get crd applications.argoproj.io &>/dev/null && echo '✅ ArgoCD CRD ready' && break
    echo '[WAIT] Still waiting for CRD... ($i/10)'
    sleep 5
  done

  kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=60s || true
"

# 14) Helm 차트 적용
sudo -u wish bash -c "
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  wget -qO /home/wish/app-helm.yaml https://raw.githubusercontent.com/hose0504/Gros_Michel_gcp/main/gcp/helm/static-site/templates/app-helm.yaml
  kubectl apply -f /home/wish/app-helm.yaml || true
"

echo "🎉  Bastion startup script completed."
