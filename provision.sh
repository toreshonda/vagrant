#!/bin/bash
# install other soft for kubernetes
    echo -e "1q2wroot3e4r\n1q2wroot3e4r\n" | passwd root
	sudo su
    yum update -y
    yum -y install mc nano git docker wget net-tools
    # yum -y install epel-release
    # yum -y install dkms net-tools
    # yum -y install kernel-devel
#firewall-cmd --permanent --add-port=6443/tcp
#firewall-cmd --permanent --add-port=2379-2380/tcp
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10251/tcp
#firewall-cmd --permanent --add-port=10252/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

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

echo "create kubeadm.yaml file"

cat <<EOF > kubeadm.yaml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
etcd:
   extraArgs:
       'listen-peer-urls': 'http://127.0.0.1:2380'
api:
  advertiseAddress: $1
networkin:
  podSubnet: 10.244.0.0/16
EOF

yum install kubeadm -y
systemctl restart docker && systemctl enable docker
systemctl  restart kubelet && systemctl enable kubelet

#Disable SWAP
    sed -i 's/\(.*swap.*\)/#\1/g' /etc/fstab
    swapoff -a
#kubernetes cluster init
    kubeadm reset
    kubeadm init --config=kubeadm.yaml
	mkdir -p $HOME/.kube
    cp /etc/kubernetes/admin.conf $HOME/.kube/config
	cp /etc/kubernetes/admin.conf /vagrant/admin.conf
    chown $(id -u):$(id -g) $HOME/.kube	
    export KUBECONFIG=$HOME/.kube/config
	kubect token create --print-join-command >> /vagrant/join.file
    kubectl apply -n kube-system -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
    
    git clone https://github.com/kubernetes/heapster.git
    cd heapster/
    kubectl create -f deploy/kube-config/influxdb/
    kubectl apply -f https://github.com/kubernetes/heapster/raw/master/deploy/kube-config/rbac/heapster-rbac.yaml
    kubectl apply -f https://github.com/kubernetes/heapster/raw/master/deploy/kube-config/influxdb/heapster.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
     
