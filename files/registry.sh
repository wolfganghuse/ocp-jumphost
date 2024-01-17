mkdir certs
cp cert.* certs
mkdir docker_reg_auth
podman login
podman run -it --entrypoint htpasswd -v $PWD/docker_reg_auth:/auth -w /auth registry:2 -Bbc /auth/htpasswd admin password