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

# 4) 서비스 계정 키 다운로드 & 디코딩
id wish &>/dev/null || useradd -m -s /bin/bash wish
wget -qO - "https://storage.googleapis.com/grosmichel-tfstate-202506180252/terraform/state/terraform-sa.json.b64" \
  | base64 -d > /home/wish/terraform-sa.json
chown wish:wish /home/wish/terraform-sa.json

# DEBUG 로그
echo "[DEBUG] SA_KEY_JSON via wget decoded prefix: $(head -c 50 /home/wish/terraform-sa.json)" \
  | tee -a /var/log/startup.log

# 5) GKE 준비 대기
CLUSTER_NAME="gros-michel-gke-cluster"
REGION="us-central1"
PROJECT="skillful-cortex-463200-a7"

echo "📡  Waiting for GKE cluster to be RUNNING…"
until [ "$(gcloud container clusters describe "$CLUSTER_NAME" \
          --region "$REGION" --project "$PROJECT" --format='value(status)')" = "RUNNING" ]; do
  echo "⏳  Cluster not ready yet – retry in 10 s"; sleep 10
done
echo "✅  GKE cluster ready!"

# 6) gcloud 인증 & 컨텍스트 설정
gcloud auth activate-service-account --key-file=/home/wish/terraform-sa.json
gcloud config set project "$PROJECT"
gcloud container clusters get-credentials "$CLUSTER_NAME" \
       --region "$REGION" --project "$PROJECT"

# 7) Helm & Argo CD 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace

# 8) Tomcat 11 설치
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

# 9) 데모 Helm 차트 적용
curl -sLo /home/wish/app-helm.yaml \
  https://raw.githubusercontent.com/wish4o/grosmichel/main/gcp/helm/static-site/templates/app-helm.yaml
kubectl apply -f /home/wish/app-helm.yaml || true

echo "🎉  Bastion startup script completed."
