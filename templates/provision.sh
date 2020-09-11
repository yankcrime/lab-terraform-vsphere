#!/usr/bin/env bash

set -eo

export DEBIAN_FRONTEND="noninteractive"

echo "Resizing root filesystem"
growpart /dev/sda 1
resize2fs /dev/sda1

echo "Installing Docker"
apt-get install -qq \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -qq docker-ce docker-ce-cli containerd.io

usermod -a -G docker packerbuilt

echo '{ "registry-mirrors": ["http://syn:55000"] }' >> /etc/docker/daemon.json

systemctl restart docker

echo "Updating SSH keys"
mkdir /home/packerbuilt/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxUkizE2ZSyjc21DMB27+zeH+eSiLp/8Nso+ITAAwlG3oE732PootURCtiS96CnVwjoBUHV85XsEWq0yWnD5RSGzJ/tlGpgUIedMP9RCUQ5Vlkj3LMrY5wF4hup5+UC87dnpQ0BLxqY+79/VNYrsQEtS1NmcSTwfV8mNHH+q0oEjemU4R4t14gP3elN2AvDSLRjvxN9rkgjEW504lMtUyvfudV6qx3loS1sh/96xTHN7XIKWyjsWkA2j4VIMJ6ytBvFuhIClHFu8mVVs5fufRmEDm3HPWqrMzyuXRh0sIzVvZswHm5MtRz2op4oK5eSFb0EmD9xGey+ZORczL9WrQww== nick@deadair.local' >> /home/packerbuilt/.ssh/authorized_keys
