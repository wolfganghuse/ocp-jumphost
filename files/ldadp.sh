oc --kubeconfig=auth/kubeconfig create secret generic ldap-secret --from-literal=bindPassword='nutanix/4u' -n openshift-config
cat <<EOF | oc --kubeconfig=auth/kubeconfig apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: nvd.lab 
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
      bindDN: administrator@nvd.lab 
      bindPassword: 
        name: ldap-secret
      insecure: true
      url: "ldap://dc.nvd.lab/CN=Users,DC=nvd,DC=lab?sAMAccountName"
EOF
echo """kind: LDAPSyncConfig
apiVersion: v1
url: ldap://dc.nvd.lab:389
bindDN: administrator@nvd.lab 
bindPassword: "nutanix/4u"
insecure: true
groupUIDNameMapping:
  CN=Domain Admins,CN=Users,DC=nvd,DC=lab: OCP_Cluster_Admins
augmentedActiveDirectory:
  groupsQuery:
    baseDN: CN=users,DC=nvd,DC=lab
    scope: sub
    derefAliases: never
    pageSize: 0
  groupUIDAttribute: dn
  groupNameAttributes: [ cn ]
  usersQuery:
    baseDN: cn=users,dc=nvd,dc=lab
    scope: sub
    derefAliases: never
    filter: (objectclass=person)
    pageSize: 0
  userNameAttributes: [ sAMAccountName ] 
  groupMembershipAttributes: [ memberOf ]""" > ldapsync.yaml

oc --kubeconfig=auth/kubeconfig adm groups sync --sync-config=ldapsync.yaml --confirm
oc --kubeconfig=auth/kubeconfig adm policy add-cluster-role-to-group cluster-admin OCP_Cluster_Admins