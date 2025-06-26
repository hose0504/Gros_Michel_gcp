#!/bin/bash
###############################################################################
# Gros-Michel bastion – startup script (user-data)
###############################################################################

# 1) 시스템 업데이트 & 기본 툴 설치 … (생략)

# 4) 서비스 계정 키 다운로드 & 디코딩
id wish &>/dev/null || useradd -m -s /bin/bash wish
wget -qO - "https://storage.googleapis.com/grosmichel-tfstate-202506180252/terraform/state/terraform-sa.json.b64" \
  | base64 -d > /home/wish/terraform-sa.json
chown wish:wish /home/wish/terraform-sa.json
echo "[DEBUG] key decoded prefix: $(head -c 50 /home/wish/terraform-sa.json)" | tee -a /var/log/startup.log

# 5) gcloud 인증 & 기본 프로젝트 설정  ←★ 먼저 인증!
PROJECT="skillful-cortex-463200-a7"
gcloud auth activate-service-account --key-file=/home/wish/terraform-sa.json
gcloud config set project "$PROJECT"

# 6) GKE 클러스터 준비 대기
CLUSTER_NAME="gros-michel-gke-cluster"
REGION="us-central1"

echo "📡  Waiting for GKE cluster to be RUNNING…"
until [ "$(gcloud container clusters describe "$CLUSTER_NAME" \
          --region "$REGION" --format='value(status)')" = "RUNNING" ]; do
  echo "⏳  Cluster not ready yet – retry in 10 s"; sleep 10
done
echo "✅  GKE cluster ready!"

# 7) 클러스터 credentials 가져오기
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$REGION"

# 8) Helm & Argo CD 설치 … (생략)
# 9) Tomcat 설치 … (생략)
# 10) 데모 Helm 차트 적용 … (생략)

echo "🎉  Bastion startup script completed."
