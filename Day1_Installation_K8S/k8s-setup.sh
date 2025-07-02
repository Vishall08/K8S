#!/bin/bash

set -e

echo "[STEP 1] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "[STEP 2] Loading kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "[STEP 3] Applying sysctl params for Kubernetes networking..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo "[CHECK] Kernel modules:"
lsmod | grep br_netfilter || echo "br_netfilter not loaded"
lsmod | grep overlay || echo "overlay not loaded"

echo "[STEP 4] Installing containerd runtime..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io

echo "[STEP 5] Configuring containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sed -e 's/SystemdCgroup = false/SystemdCgroup = true/' \
-e 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' \
| sudo tee /etc/containerd/config.toml > /dev/null

sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd --no-pager

echo "[STEP 6] Installing Kubernetes components (kubelet, kubeadm, kubectl)..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "[✅ DONE] Kubernetes components installed. Reboot is recommended before initializing the cluster."

# --------------------------------------
# Execute these steps ONLY on the Master node
# --------------------------------------

echo "[🚀 Initializing Kubernetes cluster with kubeadm...]"
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

echo "[⚙️ Setting up kubeconfig for current user...]"
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

echo "[🌐 Installing Calico network plugin...]"
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml

echo "[🔑 Your worker join command is below:]"
kubeadm token create --print-join-command

echo "[✅ Cluster is ready! Run the above join command on each worker node.]"
