make prepare_infra
cd infra_prepare
./ssl.sh
cd ..
make vm
make ocp