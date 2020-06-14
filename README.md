# KOPS Config generator

Kubernetes supports couple of option to authenticate the users, in kops you are start with credenetials of admin.

You can generate user certificated by cluster PKI files that shown as below.

```sh

$ aws s3 cp s3://$KOPS_STATE_STORE/$CLUSTERNAME/pki/private/ca/$KEY ca.key

$ aws s3 cp s3://$KOPS_STATE_STORE/$CLUSTERNAME/pki/issued/ca/$CERT ca.crt

```

If you want to create user certificates you can run this script to do that.

`./main.sh <CLUSTER_NAME> <CA_CRT_PATH> <CA_KEY_PATH> <USER_NAME> `

## Rbac
You can specify user capabilities via RBAC objects shown as below:


```yaml
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  namespace: jenkins
  name: pod-list
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get","list"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: role-binding
subjects:
  - kind: User
    name: ### Common Name in certificate
roleRef:
  kind: Role
  name: role-pod-list
  apiGroup: rbac.authorization.k8s.io
```