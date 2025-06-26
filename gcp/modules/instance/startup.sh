#!/bin/bash
###############################################################################
# Gros-Michel bastion – startup script (user-data)
###############################################################################
set -euo pipefail            # ⇦ 스크립트 어느 부분이든 오류 나면 즉시 종료

#######################################
# 0) 공통 변수
#######################################
PROJECT="skillful-cortex-463200-a7"
CLUSTER_NAME="gros-michel-gke-cluster"
REGION="us-central1"
SA_JSON_B64_URL="https://storage.googleapis.com/grosmichel-tfstate-202506180252/terraform/state/terraform-sa.json.b64"
APP_HELM_URL="https://raw.githubusercontent.com/hose0504/Gros_Michel_gcp/main/gcp/helm/static-site/templates/app-helm.yaml"

#######################################
# 1) 시스템 업데이트 & 기본 툴
#######################################
apt update -y && apt upgrade -y
apt install -y openjdk-17-jdk awscli \
               apt-transport-https ca-certificates gnupg curl sudo wget \
               lsb-release

#######################################
# 2) kubectl 1.29.2
#######################################
curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl"
install -m 0755 kubectl /usr/local/bin/kubectl

#######################################
# 3) gcloud & GKE 플러그인
#######################################
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
      https://packages.cloud.google.com/apt cloud-sdk main" \
  | tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | tee /usr/share/keyrings/cloud.google.gpg >/dev/null
apt update -y
apt install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >/etc/profile.d/gcloud-auth.sh
export USE_GKE_GCLOUD_AUTH_PLUGIN=True   # 현재 셸에도 즉시 적용

#######################################
# 4) wish 계정 & 서비스 계정 키
#######################################
id wish &>/dev/null || useradd -m -s /bin/bash wish
wget -qO - "${SA_JSON_B64_URL}" | base64 -d >/home/wish/terraform-sa.json
chown wish:wish /home/wish/terraform-sa.json
echo "[DEBUG] SA_KEY_JSON prefix: $(head -c 50 /home/wish/terraform-sa.json)" \
  | tee -a /var/log/startup.log

#######################################
# 5) gcloud 인증 (재시도 5회)
#######################################
for i in {1..5}; do
  if gcloud auth activate-service-account \
        --key-file=/home/wish/terraform-sa.json &>/dev/null; then
    break
  fi
  echo "[WARN] gcloud auth failed. retry ${i}/5…" | tee -a /var/log/startup.log
  sleep 5
  [[ $i -eq 5 ]] && { echo "[ERROR] auth failed"; exit 1; }
done
gcloud config set project "$PROJECT"

#######################################
# 6) 클러스터 RUNNING 대기 → kubeconfig 설정
#######################################
until [[ "$(gcloud container clusters describe "$CLUSTER_NAME" \
            --region "$REGION" --format='value(status)' 2>/dev/null)" == "RUNNING" ]]; do
  echo "[INFO] cluster not ready; sleep 30s" | tee -a /var/log/startup.log
  sleep 30
done
gcloud container clusters get-credentials "$CLUSTER_NAME" \
       --region "$REGION" --project "$PROJECT"

#######################################
# 7) wish 계정으로 kubeconfig·gcloud creds 복사
#######################################
install -d -o wish -g wish /home/wish/.kube /home/wish/.config
cp /root/.kube/config /home/wish/.kube/
cp -r /root/.config/gcloud /home/wish/.config/
chown -R wish:wish /home/wish/.kube /home/wish/.config/gcloud

#######################################
# 8) Helm & Argo CD
#######################################
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace

#######################################
# 9) Tomcat 11
#######################################
useradd -r -m -U -d /opt/tomcat -s /usr/sbin/nologin tomcat
TOM_VER="11.0.8"
wget -qO /tmp/tomcat.tar.gz \
     "https://dlcdn.apache.org/tomcat/tomcat-11/v${TOM_VER}/bin/apache-tomcat-${TOM_VER}.tar.gz"
mkdir -p /opt/tomcat && tar -xf /tmp/tomcat.tar.gz -C /opt/tomcat
mv /opt/tomcat/apache-tomcat-${TOM_VER} /opt/tomcat/tomcat-11
chown -RH tomcat:tomcat /opt/tomcat/tomcat-11
cat >/etc/systemd/system/tomcat.service <<'EOF'
[Unit]
Description=Apache Tomcat 11
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat/tomcat-11"
Environment="CATALINA_BASE=/opt/tomcat/tomcat-11"
Environment="CATALINA_PID=/opt/tomcat/tomcat-11/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/tomcat-11/bin/startup.sh
ExecStop=/opt/tomcat/tomcat-11/bin/shutdown.sh
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now tomcat

#######################################
# 10) 데모 Helm 차트 적용
#######################################
sudo -u wish -E bash <<'EOSU'
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  kubectl apply -f '"${APP_HELM_URL}"' --validate=false || true
EOSU

echo "🎉  Bastion startup script completed."
