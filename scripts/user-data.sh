#!/bin/bash
apt update -y
apt install openjdk-11-jdk -y

# Jenkins installation for Ubuntu
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]  https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt update
apt install jenkins -y
systemctl enable jenkins
systemctl start jenkins

# Maven installation
apt update
apt install -y wget ca-certificates curl gnupg lsb-release
wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xvf apache-maven-3.6.3-bin.tar.gz -C /opt
mv /opt/apache-maven-3.6.3 /opt/maven

bash -c 'cat <<EOF >/etc/profile.d/maven.sh
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=\$PATH:\$M2_HOME/bin
EOF'


# Docker installation
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
usermod -aG docker $USER
usermod -aG docker jenkins
newgrp docker

# Cleanup
rm apache-maven-3.6.3-bin.tar.gz

# setup aws cli and eksctl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt-get install -y unzip curl
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip
rm -rf aws/
echo "export PATH=/usr/local/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
ln -s /usr/local/aws-cli/v2/current/bin/aws /usr/local/bin/aws

# Determine the architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="amd64";;
    aarch64) ARCH="arm64";;
    armv6*) ARCH="armv6";;
    armv7*) ARCH="armv7";;
    *) echo "Unsupported architecture"; exit 1;;
esac

PLATFORM=$(uname -s)_$ARCH

# Download eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp
rm eksctl_$PLATFORM.tar.gz
mv /tmp/eksctl /usr/local/bin

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
systemctl restart jenkins
