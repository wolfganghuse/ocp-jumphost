oc --kubeconfig=auth/kubeconfig create secret generic ldap-secret --from-literal=bindPassword='Nutanix.1' -n openshift-config
cat <<EOF | oc --kubeconfig=auth/kubeconfig apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: blaze.dachlab.net
    mappingMethod: claim
    type: LDAP
    ldap:
      attributes:
        id:
        - sAMAccountName
        email: []
        name:
        - displayName
        preferredUsername:
        - sAMAccountName
      bindDN: administrator@blaze.dachlab.net
      bindPassword:
        name: ldap-secret
      insecure: true
      url: "ldap://dc.blaze.dachlab.net/CN=Users,DC=blaze,DC=dachlab,DC=net?sAMAccountName"
EOF
echo """kind: LDAPSyncConfig
apiVersion: v1
url: ldap://dc.blaze.dachlab.net:389
bindDN: administrator@blaze.dachlab.net
bindPassword: "Nutanix.1"
insecure: true
groupUIDNameMapping:
  CN=labadmin,CN=Users,DC=blaze,DC=dachlab,DC=net: OCP_Cluster_Admins
augmentedActiveDirectory:
  groupsQuery:
    baseDN: CN=users,DC=blaze,DC=dachlab,DC=net
    scope: sub
    derefAliases: never
    pageSize: 0
  groupUIDAttribute: dn
  groupNameAttributes: [ cn ]
  usersQuery:
    baseDN: cn=users,dc=blaze,dc=dachlab,dc=net
    scope: sub
    derefAliases: never
    filter: (objectclass=person)
    pageSize: 0
  userNameAttributes: [ sAMAccountName ]
  groupMembershipAttributes: [ memberOf ]""" > ldapsync.yaml

oc --kubeconfig=auth/kubeconfig adm groups sync --sync-config=ldapsync.yaml --confirm
oc --kubeconfig=auth/kubeconfig adm policy add-cluster-role-to-group cluster-admin OCP_Cluster_Admins