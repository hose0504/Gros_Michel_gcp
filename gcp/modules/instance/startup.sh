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
#   – 모든 셸에서 플러그인을 쓰도록 profile 에 기록
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

# 8) wish 유저에게 kubeconfig & gcloud creds 복사 + 환경 변수도 설정
mkdir -p /home/wish/.kube /home/wish/.config
grep -q "account:" /root/.kube/config && cp -r /root/.kube/* /home/wish/.kube/
cp -r /root/.config/gcloud /home/wish/.config/ 2>/dev/null || true
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/wish/.bashrc
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> /home/wish/.profile
chown -R wish:wish /home/wish/.kube /home/wish/.config/gcloud /home/wish/.bashrc /home/wish/.profile

# 9) Helm & Argo CD 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace

# 10) Tomcat 11 설치
useradd -r -m -U -d /opt/tomcat -s /usr/sbin/nologin tomcat
TOM_VER="11.0.8"
wget -qO /tmp/tomcat.tar.gz \
     "https://dlcdn.apache.org/tomcat/tomcat-11/v${TOM_VER}/bin/apache-tomcat-${TOM_VER}.tar.gz"
mkdir -p /opt/tomcat && tar -xf /tmp/tomcat.tar.gz -C /opt/tomcat/
mv /opt/tomcat/apache-tomcat-${TOM_VER} /opt/tomcat/tomcat-11
chown -RH tomcat:tomcat /opt/tomcat/tomcat-11

cat >/etc/systemd/system/tomcat.service <<'EOT'
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
EOT

systemctl daemon-reload
systemctl enable --now tomcat

# 11) 데모 Helm 차트 적용 (wish 계정, 검증 off)
sleep 30  # API server stabilise
sudo -u wish USE_GKE_GCLOUD_AUTH_PLUGIN=True \
  kubectl apply -f https://raw.githubusercontent.com/hose0504/Gros_Michel_gcp/main/gcp/helm/static-site/templates/app-helm.yaml --validate=false || true

echo "🎉  Bastion startup script completed."
