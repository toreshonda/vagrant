#!/bin/bash
# install other soft for kubernetes
    echo -e "1q2wroot3e4r\n1q2wroot3e4r\n" | passwd root
    yum update -y
    yum -y install mc nano git docker wget
    yum -y install epel-release
    yum -y install net-tools 
#    yum -y groupinstall "Development Tools"
#    yum -y install gcc-c++
#    yum -y install kernel-devel
#firewall-cmd --permanent --add-port=6443/tcp
#firewall-cmd --permanent --add-port=2379-2380/tcp
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10251/tcp
#firewall-cmd --permanent --add-port=10252/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --reload
#echo 'hello i'm prepare the minion'
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
#disable SELINUX
     setenforce 0
 sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernete
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
         https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl
systemctl restart docker && systemctl enable docker
systemctl  restart kubelet && systemctl enable kubelet
#Disable SWAP
    sed -i 's/\(.*swap.*\)/#\1/g' /etc/fstab
    swapoff -a
                     	
#Join into cluster
sudo su
mkdir -p $HOME/.kube
cp /vagrant/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
# kubeadm token create --print-join-command >> join.file
bash /vagrant/join.file
echo "THE END!!!"

