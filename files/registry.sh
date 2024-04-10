mkdir certs
mkdir docker_reg_auth
mkdir registry
htpasswd -bnB nutanix nutanix.1 > docker_reg_auth/htpasswd
cat cert.crt ca.crt > certs/fullchain.crt
cp cert.key certs

#$CONTAINER_ENGINE login
$CONTAINER_ENGINE container run -d -p 443:5000 --name registry -v "$(pwd)"/docker_reg_auth:/auth -v "$(pwd)"/certs:/certs -v "$(pwd)"/registry:/var/lib/registry -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/cert.key registry:2