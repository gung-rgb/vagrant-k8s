#!/usr/bin/env bash
set -e

OUTPUT_FILE=/vagrant/join.sh
MASTER_IP='172.16.50.10'
rm -rf $OUTPUT_FILE

# Start cluster
#sudo kubeadm init --control-plane-endpoint $MASTER_IP --apiserver-advertise-address=0.0.0.0 --pod-network-cidr=10.244.0.0/16 | grep "kubeadm join" > ${OUTPUT_FILE}
sudo kubeadm init  --control-plane-endpoint $MASTER_IP --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=10.244.0.0/16  > /vagrant/init_out_put_file.txt
# debug
sudo cat /vagrant/init_out_put_file.txt

sudo cat /vagrant/init_out_put_file.txt |  grep 'you can join any number of worker' -A 5 | grep -v 'you can join any number of worker' > ${OUTPUT_FILE}
sudo rm -rf  /vagrant/init_out_put_file.txt
chmod +x $OUTPUT_FILE

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp  /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Fix kubelet IP
echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$MASTER_IP\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Configure cilium
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --namespace=kube-system --set ipam.operator.clusterPoolIPv4PodCIDR=10.10.0.0/16

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
kubectl taint nodes --all node-role.kubernetes.io/master-


sudo systemctl daemon-reload
sudo systemctl restart kubelet
