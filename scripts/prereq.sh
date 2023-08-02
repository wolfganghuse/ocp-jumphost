sudo cp ~/ipi/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

sudo apt-get update
sudo apt-get install helm --yes
sudo apt-get install python3.8-venv gcc make jq apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

sudo apt install mkisofs
sudo apt install unzip
export PACKER_RELEASE="1.8.3"

wget https://releases.hashicorp.com/packer/${PACKER_RELEASE}/packer_${PACKER_RELEASE}_linux_amd64.zip
unzip packer_${PACKER_RELEASE}_linux_amd64.zip
sudo mv packer /usr/local/bin

#curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

wget https://github.com/derailed/k9s/releases/download/v0.26.0/k9s_Linux_x86_64.tar.gz
tar xvzf k9s_Linux_x86_64.tar.gz
sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s

curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.2.1/clusterctl-linux-amd64 -o clusterctl
sudo install -o root -g root -m 0755 clusterctl /usr/local/bin/clusterctl

#curl -O http://10.42.194.11/Users/Huse/openshift-tests

curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.12/openshift-client-linux.tar.gz
curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.12/openshift-install-linux.tar.gz
curl -O https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable-4.12/oc-mirror.tar.gz

tar xvzf openshift-client-linux.tar.gz
tar xvzf openshift-install-linux.tar.gz
tar xvzf oc-mirror.tar.gz
chmod +x oc-mirror

wget -O https://github.com/nutanix/kubectl-karbon/releases/download/v0.9.2/kubectl-karbon_v0.9.2_linux_amd64.tar.gz
tar xvzf kubectl-karbon_v0.9.2_linux_amd64.tar.gz
sudo install -o root -g root -m 0755 kubectl-karbon /usr/local/bin/


sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
mkdir ~/.kube

sudo install oc /usr/local/bin
sudo install oc-mirror /usr/local/bin
sudo install openshift-install /usr/local/bin
sudo install openshift-tests /usr/local/bin

git clone https://github.com/wolfganghuse/ocp-stress
./ocp-stress/install.sh

#git clone https://github.com/cloud-bulldozer/e2e-benchmarking

#git clone https://github.com/wolfganghuse/containerdays-demo
