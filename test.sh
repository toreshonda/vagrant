#!/bin/bash
echo $1

cat <<EOF > kubeadm1.yaml
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

exit;
