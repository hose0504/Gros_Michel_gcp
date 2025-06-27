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

# 4) GKE 인증 플러그인 설치 및 전역 환경 변수 등록
apt install -y google-cloud-sdk-gke-gcloud-auth-plugin
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' > /etc/profile.d/gcloud-auth.sh
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# 5) 서비스 계정 키 다운로드 & 디코딩
id wish &>/dev/null || useradd -m -s /bin/bash wish
wget -qO - "https://storage.googleapis.com/grosmichel-tfstate-202506180252/terraform/state/terraform-sa.json.b64" \
  | base64 -d > /home/wish/terraform-sa.json
chown wish:wish /home/wish/terraform-sa.json

# DEBUG
echo "[DEBUG] SA_KEY_JSON prefix: $(head -c 50 /home/wish/terraform-sa.json)" | tee -a /var/log/startup.log

# 6) gcloud 인증 재시도 (최대 5회)
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

# 7) GKE 클러스터가 RUNNING 될 때까지 대기 후 credentials 획득
CLUSTER_NAME="gros-michel-gke-cluster"
REGION="us-central1"

echo "📡  Waiting for GKE cluster to be RUNNING…"
while true; do
  STATUS=$(gcloud container clusters describe "$CLUSTER_NAME" \
            --region "$REGION" --format='value(status)' 2>/dev/null)
  if [[ "$STATUS" == "RUNNING" ]]; then
    echo "[INFO] GKE cluster status = RUNNING ✅"; break
  fi
  echo "[INFO] Current status: ${STATUS:-NOT_FOUND}. Re-check in 30 s..."; sleep 30
done

gcloud container clusters get-credentials "$CLUSTER_NAME" \
       --region "$REGION" --project "$PROJECT"

# ✅ wish 계정으로 config 생성
sudo -u wish bash -c '
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  mkdir -p /home/wish/.kube
  gcloud container clusters get-credentials gros-michel-gke-cluster \
    --region us-central1 --project skillful-cortex-463200-a7
'

# 8) wish 유저에게 kubeconfig & gcloud creds 복사 + 환경 변수도 설정
mkdir -p /home/wish/.kube /home/wish/.config
grep -q "account:" /root/.kube/config && cp -r /root/.kube/* /home/wish/.kube/
cp -r /root/.config/gcloud /home/wish/.config/ 2>/dev/null || true
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/wish/.bashrc
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/wish/.profile
chown -R wish:wish /home/wish/.kube /home/wish/.config/gcloud /home/wish/.bashrc /home/wish/.profile

# 9) Helm 차트만 적용 (wish 계정으로)
sudo -u wish bash -c '
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  wget -qO /home/wish/app-helm.yaml https://raw.githubusercontent.com/hose0504/Gros_Michel_gcp/main/gcp/helm/static-site/templates/app-helm.yaml
  kubectl apply -f /home/wish/app-helm.yaml --validate=false || true
'

echo "🎉  Bastion startup script completed."
