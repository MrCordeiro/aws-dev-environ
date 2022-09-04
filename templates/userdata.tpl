#!/bin/bash
{* Update apt *}
sudo apt-get update -y &&
{* Install depedencies *}
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
{* Install GPG key *}
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
{* Install Docker *}
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo apt-get install -y docker-ce docker-ce-cli containerd.io &&
{* Add ubuntu user to the docker group, allowing you to run docker commands as the ubuntu user *}
sudo usermod -aG docker ubuntu
