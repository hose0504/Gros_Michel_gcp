#!/bin/bash

# -----------------------
# 시스템 업데이트
# -----------------------
apt update -y && apt upgrade -y

# -----------------------
# OpenJDK 17 설치
# -----------------------
apt install -y openjdk-17-jdk

# -----------------------
# AWS CLI 설치
# -----------------------
apt install -y awscli

# -----------------------
# kubectl 설치 (v1.29.2 기준)
# -----------------------
curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# -----------------------
# tomcat 사용자 및 그룹 생성
# -----------------------
useradd -r -m -U -d /opt/tomcat -s /usr/sbin/nologin tomcat

# -----------------------
# Apache Tomcat 11 설치
# -----------------------
TOM_VER="11.0.8"
wget -O /tmp/tomcat.tar.gz \
  https://dlcdn.apache.org/tomcat/tomcat-11/v$TOM_VER/bin/apache-tomcat-$TOM_VER.tar.gz

mkdir -p /opt/tomcat
tar -xf /tmp/tomcat.tar.gz -C /opt/tomcat/
mv /opt/tomcat/apache-tomcat-$TOM_VER /opt/tomcat/tomcat-11

chown -RH tomcat:tomcat /opt/tomcat/tomcat-11

# -----------------------
# systemd 서비스 등록
# -----------------------
cat <<EOF > /etc/systemd/system/tomcat.service
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

# -----------------------
# Tomcat 실행 및 부팅 시 자동 실행 등록
# -----------------------
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# -----------------------
# 상태 확인
# -----------------------
systemctl status tomcat
kubectl version --client
