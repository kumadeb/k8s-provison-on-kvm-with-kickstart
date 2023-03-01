#!/bin/bash

# Install KVM
echo "Installing KVM"
sudo apt-get -qq -y install \
bridge-utils \
qemu-kvm \
qemu \
virt-manager \
net-tools \
openssh-server \
mlocate \
libvirt-clients \
libvirt-daemon \
libvirt-daemon-driver-storage-zfs \
python3-libvirt \
virt-manager \
virtinst
# Create ssh key pair
echo "Creating ssh key pair"
ssh-keygen -f id_rsa -t rsa -N "ssh-keygen -t rsa -C ansible@host -f id_rsa"

# Create an encrypted password for the user ansible
echo "Creating an encrypted password for the user ansible"
py_ver=`python --version|cut -d. -f1|cut -d' ' -f2`
python v${py_ver}_encrypt-pw.py |tee enc_pass.txt

# Create a kickstart file
echo "Creating a kickstart file"
ID_RSA_PUBLIC_KEY=`cat id_rsa.pub`
ENCRYPTED_PASSWORD=`cat enc_pass.txt`

cat template_ubuntu.ks \
| sed -e "s|ID_RSA_PUBLIC_KEY|${ID_RSA_PUBLIC_KEY}|" \
| sed -e "s|ENCRYPTED_PASSWORD|${ENCRYPTED_PASSWORD}|" \
> ubuntu.ks

rm -f enc_pass.txt