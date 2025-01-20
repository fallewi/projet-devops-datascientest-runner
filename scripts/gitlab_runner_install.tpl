#!/bin/bash

# Maintainer: Fall Lewis YOMBA 
# Email: Fall-lewis.y@datascientest.com

# Install necessary dependencies
# set -x enables a mode of the shell where all executed commands are printed to the terminal
set -x
echo "Hello from EC2 user data script"

yum update -y
yum install -y curl git
sudo yum install -y docker
sudo systemctl enable --now docker
# Install GitLab Runner
curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
chmod +x /usr/local/bin/gitlab-runner

useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Start the GitLab Runner service
/usr/local/bin/gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
/usr/local/bin/gitlab-runner start


sudo usermod -aG docker  gitlab-runner

# Register the GitLab Runner
/usr/local/bin/gitlab-runner register --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token "${gitlab_runner_registration_token}" \
  --executor "shell" \
  --description "AWS GitLab Runner" \
  --tag-list "aws,linux" \
  --run-untagged="true" \
  --locked="false"

systemctl status -l gitlab-runner.service

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
./get_helm.sh

# Install terraform
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Install Kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.3/2024-12-12/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.3/2024-12-12/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

