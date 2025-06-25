#!/bin/bash

# 시스템 업데이트
apt update -y && apt upgrade -y

# 필수 패키지 설치
apt install -y openjdk-17-jdk awscli apt-transport-https ca-certificates gnupg curl sudo lsb-release wget

# kubectl 설치 (v1.29.2 기준)
curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# gcloud CLI 설치
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt update -y && apt install -y google-cloud-sdk

# 서비스 계정 키 삽입
cat <<EOF > /home/wish/terraform-sa.json
${SA_KEY_JSON}
EOF

# GKE 클러스터 준비 대기
CLUSTER_NAME="gros-michel-gke-cluster"
REGION="us-central1"
PROJECT="skillful-cortex-463200-a7"

echo "GKE 클러스터가 준비될 때까지 대기 중..."
until [ "$(gcloud container clusters describe $CLUSTER_NAME --region $REGION --project $PROJECT --format='value(status)')" = "RUNNING" ]; do
  echo "아직 준비되지 않음. 10초 후 재시도..."
  sleep 10
done
echo "GKE 클러스터 준비 완료!"

# gcloud 인증 및 연결
gcloud auth activate-service-account --key-file=/home/wish/terraform-sa.json
gcloud config set project $PROJECT
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT

# Helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Argo CD 설치
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace

# tomcat 사용자 생성
useradd -r -m -U -d /opt/tomcat -s /usr/sbin/nologin tomcat

# Apache Tomcat 11 설치
TOM_VER="11.0.8"
wget -O /tmp/tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-11/v$TOM_VER/bin/apache-tomcat-$TOM_VER.tar.gz
mkdir -p /opt/tomcat
tar -xf /tmp/tomcat.tar.gz -C /opt/tomcat/
mv /opt/tomcat/apache-tomcat-$TOM_VER /opt/tomcat/tomcat-11
chown -RH tomcat:tomcat /opt/tomcat/tomcat-11

# systemd 등록
cat <<EOT > /etc/systemd/system/tomcat.service
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

# Tomcat 실행
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# app-helm.yaml 적용
curl -o /home/wish/app-helm.yaml https://raw.githubusercontent.com/wish4o/grosmichel/main/gcp/helm/static-site/templates/app-helm.yaml
kubectl apply -f /home/wish/app-helm.yaml || true
