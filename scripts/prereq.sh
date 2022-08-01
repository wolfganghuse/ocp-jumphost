sudo cp ~/ipi/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

sudo apt-get update
sudo apt-get install helm --yes
sudo apt-get install python3.8-venv gcc make jq apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

wget https://github.com/derailed/k9s/releases/download/v0.26.0/k9s_Linux_x86_64.tar.gz
tar xvzf k9s_Linux_x86_64.tar.gz
sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s

curl -O http://10.42.194.11/Users/Huse/openshift-tests

curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast-4.11/openshift-client-linux.tar.gz
curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast-4.11/openshift-install-linux.tar.gz

tar xvzf openshift-client-linux.tar.gz
tar xvzf openshift-install-linux.tar.gz

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
mkdir ~/.kube

sudo install oc /usr/local/bin
sudo install openshift-install /usr/local/bin
sudo install openshift-tests /usr/local/bin

git clone https://github.com/wolfganghuse/ocp-stress
./ocp-stress/install.sh

git clone https://github.com/cloud-bulldozer/e2e-benchmarking