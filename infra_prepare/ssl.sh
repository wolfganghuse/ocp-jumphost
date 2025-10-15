#./acme2pc.sh -u $TF_VAR_PC_USER -p $TF_VAR_PC_PASS -h $TF_VAR_PC_ENDPOINT
#ansible-playbook cloudnativerole.yml
./nxcert pc update-from-file \
  --cert certs/$TF_VAR_ZONE.crt \
  --key certs/$TF_VAR_ZONE.key \
  --chain /certs/$TF_VAR_ZONE-ca.crt \
  --endpoint $TF_VAR_PC_ENDPOINT \
  --username $TF_VAR_PC_USER \
  --password :$TF_VAR_PC_PASS