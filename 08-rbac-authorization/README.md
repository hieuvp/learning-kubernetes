# RBAC Authorization

> **Role-Based Access Control** (RBAC) is a method of regulating access
> to computer or network resources based on the roles of individual users within an enterprise.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Key Concepts](#key-concepts)
- [Creating Users](#creating-users)
- [Roles](#roles)
- [RoleBindings](#rolebindings)
- [ClusterRoles](#clusterroles)
- [ClusterRoleBindings](#clusterrolebindings)
- [ServiceAccounts](#serviceaccounts)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Key Concepts

- **Subjects**: the objects (Users, Groups, Processes) allowed access to the Kubernetes API,
based on **API Resources** and **Verbs**.

- **API Resources**: the Kubernetes API Objects available on the clusters.
They are the Pods, Deployments, Services, Nodes, PersistentVolumes and other things that make up Kubernetes.

- **Verbs**: the set of operations that can be executed to the **Resources** above.
There are many **Verbs** (e.g. get, watch, create, delete,...),
but ultimately all of them are Create, Read, Update or Delete (CRUD) operations.

<div align="center"><img src="assets/types-of-rbac.png" width="900"></div>


## Creating Users

Users are authenticated using one or more authentication modes.
These include client certificates, passwords, and various tokens.
After this, each user action or request on the cluster is authorized against the rules assigned to a user through roles.

```bash
$ docker exec -it --user=root rbac-authorization /bin/bash
bash-5.0# labs/01-creating-users/test.sh
+ cat .kube/config
cat: can't open '.kube/config': No such file or directory
+ kubectl version --short
Client Version: v1.16.2
The connection to the server localhost:8080 was refused - did you specify the right host or port?
+ helm version --client --short
Client: v2.16.1+gbbdfe5e
+ kubectl config get-clusters
NAME
+ kubectl config get-contexts
CURRENT   NAME   CLUSTER   AUTHINFO   NAMESPACE
+ kubectl get pods
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-creating-users/01-create-certificate.sh) -->
<!-- The below code snippet is automatically added from labs/01-creating-users/01-create-certificate.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

# declare: is a built-in command of the Bash shell
# It declares shell variables and functions, sets their attributes, and displays their values
# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"

# Create a clean directory to store certificates
rm -rf ${CERTIFICATE_DIR}
mkdir ${CERTIFICATE_DIR}

# RSA is popular format use to create asymmetric key pairs those named public and private key
# 1. Generate an RSA private key
openssl genrsa -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key 2048

# Read your RSA private key
openssl rsa -in .certificates/${CERTIFICATE_USER}.key -check

# The CSR (or Certificate Signing Request) is created using the PEM format
# and contains the public key portion of the private key
# as well as information about you (or your company)
# 2. Generate a CSR from the private key
openssl req -new \
  -key ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -subj "/CN=${CERTIFICATE_USER}/O=devs/O=tech-lead"
# CN : Common Name
# O  : Organization

# Read your Certificate Signing Request
openssl req -text -noout -verify -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr

# Certificate Authority (CA)
# ca.crt: the certificate file
# ca.key: the RSA private key
cp ~/.minikube/ca.crt ${CERTIFICATE_DIR}/
cp ~/.minikube/ca.key ${CERTIFICATE_DIR}/

# An X.509 certificate is a digital certificate
# that uses the widely accepted international X.509 public key infrastructure (PKI) standard
# to verify that a public key belongs to
# the user, computer or service identity contained within the certificate
# 3. Sign your CSR with minikube CA
openssl x509 -req \
  -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt \
  -CA ${CERTIFICATE_DIR}/ca.crt \
  -CAkey ${CERTIFICATE_DIR}/ca.key \
  -CAcreateserial \
  -days 500
# CAcreateserial: this option will create a file (ca.srl) containing a serial number

# Read X509 Certificate
# Print Certificate Purpose
openssl x509 -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt -text -noout -purpose

tree ${CERTIFICATE_DIR}

declare -r CONTAINER_NAME="rbac-authorization"
declare -r CONTAINER_USER="root"

docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} rm -rf /${CONTAINER_USER}/${CERTIFICATE_DIR}
docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} mkdir /${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp .certificates/harrison.key ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp .certificates/harrison.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp .certificates/ca.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/01-creating-users/01-create-certificate.sh
+ declare -r CERTIFICATE_DIR=.certificates
+ declare -r CERTIFICATE_USER=harrison
+ rm -rf .certificates
+ mkdir .certificates
+ openssl genrsa -out .certificates/harrison.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
........................................................................................................................+++++
...........................+++++
e is 65537 (0x010001)
+ openssl rsa -in .certificates/harrison.key -check
RSA key ok
writing RSA key
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA8spTDzWAzfXXBJ9SflMAWlimWPHcXFogFJDzkLKNuiPvxtA5
C5CNjiBbjmCtGEFHfK8NKfx6hH+kh1JsbNkByOMbw/boQlLfojcgEOZ5dx9tOJRA
/6A5F/g+LoxMyJNsdNfll7kqojcHoJ7JxGMDU9AeAjx5pbe1zlPINrQku9q60CBZ
owdJhW8NOHBL6FIMm/DsvzH7JwzjSpJ3D8b1j6tlx5THNUHs1J125oW6oLeqwug3
WEy09llnFBYAY9azuFWOWRpl4jYiQFFr9rLprZJJHcyCskf37jGgA10/Kv5S7Xek
H27h/SMtphQrvCofxIvMUyFr1oQGyd/CgmKzkwIDAQABAoIBAQDgShanIzcljamg
RIrR1l2qGOE7o9t9mWivdyT7FGgngFFe6jb4vwZ2OOA7zIW7tXqT7acMlYidZMma
lYNCnsquSVf6FduEgcjEs4Y09qVZbbfZn+PYAq0bvqG7ILNCTCbSXixkmJORHaM3
N9mPSiTlxYojaLi8ZdVXkUCRgKO6wU5YD2r5VDRR0AGAfolW13igyvfEfo9v3Z6m
9v6Psuss0i4DD4/t8zFJ62VabEoajnZFZjp0+p3Gz5W0qeqZ3KtuW8hfGx7vpYsh
iU1PpcM6Nvx41qp5cHRnSioeMSuXTD5q3k9uahnmEZFHKV5kdCsRWyk8NrLzheGq
GFZGT1WhAoGBAPoYf8+RZWRBjY2MSEK2zvPfCy1L5nktuPvXIQiR4ebwbiQXY1TC
rlx/4Bi9ojg4qlL+H0cMhHJtYgUSGELg6ALVSi2Gg+TnMlFio4bmfGvC5KyXEygI
pLXNpE6fWAaK6+NX+oqHJwH4mjM5mLE2TnABgvHq6XUDEZksm0/MHY0xAoGBAPiF
rH4s6uIqaW2BUpHxRmmyq7CGwcN+05hpRnkbOiziwtdFZwmv0e6CespelRqr+YiU
+Of+qytnZC1o37wD+k8ys84Sfm1ZW1/Rv8b+0jYvrSF2sqRxjF3NmMzwVZqe5bAb
3Tf8SvgMB7GE0o9mNMoYF5QC2ORijbwBNbb8N8wDAoGAMvLgvsFo/WaZVre4VNb3
DBlpJn4q4o7c+3kVArDta2WZmoKlOrQ6Xx+x4HhpXri0ghnA93FmXgVIja3lAWLe
AQ3AgcvAfNZYmtnUZHv55t4aRcq1HVe9bkgJa/bsMNEGQxc+NBBacv1ZNIxMPfXJ
Puof6faoPq00XZcHwNbdQlECgYAlnw7CtwgDnsoA8r/OKgkvvQVynqO8dXmQq/co
JDAFVXqLXg1AESalhYkTE4hc1kXbIDoh3JKK6obmvOaJrsx4qsM/YdtTsGA9vCHc
/PxTiZoa474dWLcYCCSmeYdr9bvtkfpGHGI49JFBlUrOvHknUshW9qtgv26XVFOO
VNYZgwKBgQDQxWRQ+qySuO1mpXCoR2+0/rakgzNZcTCzsz3+lv3bdadvnBM87BME
owqAnJIZDsVRMUupxWpT7ULpf8dg7DDJWT3BeJy91ww/J4cRoProEC3pQdRCsqoA
rq89AOn2Vxm1Vyv53iNB2cAboTZqo113CtXTByg8dfzWNbVbbxiETg==
-----END RSA PRIVATE KEY-----
+ openssl req -new -key .certificates/harrison.key -out .certificates/harrison.csr -subj /CN=harrison/O=devs/O=tech-lead
+ openssl req -text -noout -verify -in .certificates/harrison.csr
verify OK
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: CN = harrison, O = devs, O = tech-lead
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:f2:ca:53:0f:35:80:cd:f5:d7:04:9f:52:7e:53:
                    00:5a:58:a6:58:f1:dc:5c:5a:20:14:90:f3:90:b2:
                    8d:ba:23:ef:c6:d0:39:0b:90:8d:8e:20:5b:8e:60:
                    ad:18:41:47:7c:af:0d:29:fc:7a:84:7f:a4:87:52:
                    6c:6c:d9:01:c8:e3:1b:c3:f6:e8:42:52:df:a2:37:
                    20:10:e6:79:77:1f:6d:38:94:40:ff:a0:39:17:f8:
                    3e:2e:8c:4c:c8:93:6c:74:d7:e5:97:b9:2a:a2:37:
                    07:a0:9e:c9:c4:63:03:53:d0:1e:02:3c:79:a5:b7:
                    b5:ce:53:c8:36:b4:24:bb:da:ba:d0:20:59:a3:07:
                    49:85:6f:0d:38:70:4b:e8:52:0c:9b:f0:ec:bf:31:
                    fb:27:0c:e3:4a:92:77:0f:c6:f5:8f:ab:65:c7:94:
                    c7:35:41:ec:d4:9d:76:e6:85:ba:a0:b7:aa:c2:e8:
                    37:58:4c:b4:f6:59:67:14:16:00:63:d6:b3:b8:55:
                    8e:59:1a:65:e2:36:22:40:51:6b:f6:b2:e9:ad:92:
                    49:1d:cc:82:b2:47:f7:ee:31:a0:03:5d:3f:2a:fe:
                    52:ed:77:a4:1f:6e:e1:fd:23:2d:a6:14:2b:bc:2a:
                    1f:c4:8b:cc:53:21:6b:d6:84:06:c9:df:c2:82:62:
                    b3:93
                Exponent: 65537 (0x10001)
        Attributes:
            a0:00
    Signature Algorithm: sha256WithRSAEncryption
         19:15:9a:20:78:50:ba:df:4e:f9:87:c6:c0:a4:b6:a0:36:96:
         dc:e0:7b:69:a2:81:04:55:f3:2e:97:67:e6:7f:72:ef:1c:b4:
         c0:c3:8c:21:5c:2f:02:7a:1a:df:cc:db:a4:98:eb:8a:d5:41:
         9a:42:ba:bf:e9:95:8d:a8:63:b1:09:46:41:3e:c4:53:c4:20:
         0c:03:f3:b7:12:af:f5:26:29:9e:67:60:dd:86:e9:ae:62:76:
         d6:e6:97:33:de:fc:3d:f3:60:ce:9a:19:32:92:83:6d:b9:6a:
         7c:fd:66:37:44:08:59:9a:14:04:9a:b3:d7:b1:4e:6a:43:1b:
         ae:93:c5:02:b4:0f:0a:f6:de:f2:83:b7:a9:4b:e8:98:90:21:
         4d:f6:99:ff:66:7b:76:28:0e:7e:dd:33:2f:26:5e:b1:07:a7:
         61:e2:2f:46:35:10:6f:56:c6:02:77:30:c1:4e:50:77:a9:12:
         4d:8e:77:59:d8:1b:03:78:3b:db:5e:ba:9d:c0:a7:fd:32:29:
         5b:76:ee:09:bf:33:0d:68:be:e0:76:24:1a:e0:4f:dc:48:e9:
         e2:6d:d0:d6:5c:cc:01:c9:b2:0c:9c:ed:cd:06:cf:00:52:8b:
         79:6f:df:27:1f:bf:3a:9c:87:51:4c:8e:73:0b:0e:e2:45:10:
         25:a2:30:5e
+ cp /Users/hieu.van/.minikube/ca.crt .certificates/
+ cp /Users/hieu.van/.minikube/ca.key .certificates/
+ openssl x509 -req -in .certificates/harrison.csr -out .certificates/harrison.crt -CA .certificates/ca.crt -CAkey .certificates/ca.key -CAcreateserial -days 500
Signature ok
subject=CN = harrison, O = devs, O = tech-lead
Getting CA Private Key
+ openssl x509 -in .certificates/harrison.crt -text -noout -purpose
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number:
            23:b4:3d:f1:a4:90:75:3e:c4:02:61:01:2e:ec:4d:08:46:9b:2e:16
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = minikubeCA
        Validity
            Not Before: Nov 22 03:51:02 2019 GMT
            Not After : Apr  5 03:51:02 2021 GMT
        Subject: CN = harrison, O = devs, O = tech-lead
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:f2:ca:53:0f:35:80:cd:f5:d7:04:9f:52:7e:53:
                    00:5a:58:a6:58:f1:dc:5c:5a:20:14:90:f3:90:b2:
                    8d:ba:23:ef:c6:d0:39:0b:90:8d:8e:20:5b:8e:60:
                    ad:18:41:47:7c:af:0d:29:fc:7a:84:7f:a4:87:52:
                    6c:6c:d9:01:c8:e3:1b:c3:f6:e8:42:52:df:a2:37:
                    20:10:e6:79:77:1f:6d:38:94:40:ff:a0:39:17:f8:
                    3e:2e:8c:4c:c8:93:6c:74:d7:e5:97:b9:2a:a2:37:
                    07:a0:9e:c9:c4:63:03:53:d0:1e:02:3c:79:a5:b7:
                    b5:ce:53:c8:36:b4:24:bb:da:ba:d0:20:59:a3:07:
                    49:85:6f:0d:38:70:4b:e8:52:0c:9b:f0:ec:bf:31:
                    fb:27:0c:e3:4a:92:77:0f:c6:f5:8f:ab:65:c7:94:
                    c7:35:41:ec:d4:9d:76:e6:85:ba:a0:b7:aa:c2:e8:
                    37:58:4c:b4:f6:59:67:14:16:00:63:d6:b3:b8:55:
                    8e:59:1a:65:e2:36:22:40:51:6b:f6:b2:e9:ad:92:
                    49:1d:cc:82:b2:47:f7:ee:31:a0:03:5d:3f:2a:fe:
                    52:ed:77:a4:1f:6e:e1:fd:23:2d:a6:14:2b:bc:2a:
                    1f:c4:8b:cc:53:21:6b:d6:84:06:c9:df:c2:82:62:
                    b3:93
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         8c:2e:33:43:cb:97:90:d1:6e:53:cb:1e:f5:c4:d0:4e:e0:9c:
         dc:80:12:00:04:87:25:98:ee:87:a0:e2:5a:be:a0:02:0c:ce:
         93:fb:aa:e5:86:61:4b:a3:13:8d:1c:d0:8f:89:2b:0e:6c:25:
         d5:54:52:8e:d6:a9:fd:15:90:42:bb:73:d4:83:01:fa:f4:d1:
         bc:41:60:ca:6d:89:94:28:3f:ad:87:74:ff:41:9e:a7:ea:ec:
         5a:a1:9b:b1:bf:40:07:bd:1b:8d:83:c5:3e:51:24:94:8e:d2:
         ed:7d:3a:58:a0:34:41:c0:04:5e:a9:47:a9:7f:7f:66:8c:81:
         69:18:12:e0:15:98:3c:58:e7:21:b8:69:07:7a:52:d8:37:62:
         a1:8e:ea:fa:ba:be:92:81:44:3e:54:50:1b:fc:d3:f2:41:d1:
         33:39:61:86:6c:87:8f:7f:9c:ff:c8:91:96:2a:20:8a:7c:fa:
         c5:bd:e0:5a:d7:c7:f2:1c:fd:bb:73:7e:5c:61:a0:a3:e0:38:
         68:11:75:07:54:69:05:ae:30:16:46:ea:76:64:f3:0d:11:af:
         5a:91:e1:6e:c3:ce:30:40:09:b1:b0:eb:f2:60:81:09:0d:3d:
         a6:8f:cc:bc:79:4e:f2:ae:72:1a:ff:ba:3d:5c:24:a1:79:b4:
         34:ad:88:86
Certificate purposes:
SSL client : Yes
SSL client CA : No
SSL server : Yes
SSL server CA : No
Netscape SSL server : Yes
Netscape SSL server CA : No
S/MIME signing : Yes
S/MIME signing CA : No
S/MIME encryption : Yes
S/MIME encryption CA : No
CRL signing : Yes
CRL signing CA : No
Any Purpose : Yes
Any Purpose CA : Yes
OCSP helper : Yes
OCSP helper CA : No
Time Stamp signing : No
Time Stamp signing CA : No
+ tree .certificates
.certificates
├── ca.crt
├── ca.key
├── ca.srl
├── harrison.crt
├── harrison.csr
└── harrison.key

0 directories, 6 files
+ declare -r CONTAINER_NAME=rbac-authorization
+ declare -r CONTAINER_USER=root
+ docker exec -it --user=root rbac-authorization rm -rf /root/.certificates
+ docker exec -it --user=root rbac-authorization mkdir /root/.certificates
+ docker cp .certificates/harrison.key rbac-authorization:/root/.certificates
+ docker cp .certificates/harrison.crt rbac-authorization:/root/.certificates
+ docker cp .certificates/ca.crt rbac-authorization:/root/.certificates
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-creating-users/02-config-kubectl.sh) -->
<!-- The below code snippet is automatically added from labs/01-creating-users/02-config-kubectl.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

declare -r MINIKUBE_IP=192.168.99.100

# Add new kubectl context
kubectl config set-cluster minikube \
  --certificate-authority=.certificates/ca.crt \
  --embed-certs=true \
  --server=https://${MINIKUBE_IP}:8443

kubectl config set-credentials harrison@minikube \
  --client-certificate=.certificates/harrison.crt \
  --client-key=.certificates/harrison.key \
  --embed-certs=true

kubectl config set-context harrison@minikube \
  --cluster=minikube \
  --user=harrison@minikube

# Set new context
kubectl config use-context harrison@minikube
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/01-creating-users/02-config-kubectl.sh
```

```bash
$ labs/01-creating-users/test.sh
```


## Roles

> Roles connect **API Resources** and **Verbs**, these can be reused for different **Subjects**.

These are bound to one namespace (we cannot use wildcards to represent more than one, but we can deploy the same role object in different namespaces).
If we want the role to be applied cluster-wide, the equivalent object is called [ClusterRoles](#clusterroles).

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/01-pod-access-role.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/01-pod-access-role.yaml -->
```yaml
# Establish a set of allowed operations
# over a set of resources in a namespace
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role

metadata:
  name: pod-access
  namespace: test

rules:
  # The name of the "apiGroups" that contain the resources
  # When it is "core", we use an empty string
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/02-ns-admin-role.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/02-ns-admin-role.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role

metadata:
  name: ns-admin
  namespace: test

rules:
  # Wildcards are allowed
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
```
<!-- AUTO-GENERATED-CONTENT:END -->


```bash
$ kubectl get namespaces
NAME                   STATUS   AGE
default                Active   8h
kube-node-lease        Active   8h
kube-public            Active   8h
kube-system            Active   8h
kubernetes-dashboard   Active   8h
test                   Active   15m
```

```
$ kubectl get roles --namespace=test
NAME         AGE
ns-admin     21s
pod-access   83s
```

```
# Create a namespace for the new user
kubectl create namespace test

kubectl apply --filename labs/02-setting-rbac-rules/01-pod-access-role.yaml
kubectl apply --filename labs/02-setting-rbac-rules/02-ns-admin-role.yaml
```


## RoleBindings

> **RoleBindings** connect the remaining entity-subjects.
> Given a **Role**, which already binds **API Objects** and **Verbs**,
> we will establish which **Subjects** can use it.

For the cluster-level, non-namespaced equivalent, there are [ClusterRoleBindings](#clusterrolebindings).

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/03-devs-read-pods.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/03-devs-read-pods.yaml -->
```yaml
# Connect a "Role" to a Subject or set of Subjects
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: devs-read-pods
  namespace: test

subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: devs

# Only one Role per Binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-access
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/04-harrison-ns-admin.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/04-harrison-ns-admin.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: harrison-ns-admin
  namespace: test

subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: harrison

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ns-admin
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
# Give the user privileges to see pods in the "test" namespace
$ kubectl apply --filename labs/02-setting-rbac-rules/03-devs-read-pods.yaml
```

```bash
# Now we will grant administrator access in the namespace
kubectl apply --filename labs/02-setting-rbac-rules/04-harrison-ns-admin.yaml
```


## ClusterRoles

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/05-all-pods-access.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/05-all-pods-access.yaml -->
```yaml
# Establish a set of allowed operations
# over a set of resources in the whole cluster
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole

metadata:
  name: all-pod-access

rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
kubectl apply --filename labs/02-setting-rbac-rules/05-all-pods-access.yaml
```


## ClusterRoleBindings

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/06-harrison-reads-all-pods.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/06-harrison-reads-all-pods.yaml -->
```yaml
# Connect a "ClusterRole" to a Subject or set of Subjects
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding

metadata:
  name: harrison-reads-all-pods

subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: harrison

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: all-pod-access
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
# Finally, we will grant the user full pod read access
kubectl apply --filename labs/02-setting-rbac-rules/06-harrison-reads-all-pods.yaml
```


## ServiceAccounts

- **Users**: these are global, and meant for humans or processes living outside the cluster.
- **Service Accounts**: these are namespaced and meant for intra-cluster processes running inside Pods.

Both have in common that they want to authenticate against the API in order to perform a set of operations over a set of resources,
and their domains seem to be clearly defined.
They can also belong to what is known as Groups,
so a RoleBinding can bind more than one subject (but ServiceAccounts can only belong to the `system:serviceaccounts` group).

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/03-playing-with-helm/01-helm-tiller-access.yaml) -->
<!-- The below code snippet is automatically added from labs/03-playing-with-helm/01-helm-tiller-access.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole

metadata:
  name: helm-tiller-access

rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]

  - apiGroups: [""]
    resources: ["pods/portforward"]
    verbs: ["create"]

  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "create", "update"]

  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "create"]
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/03-playing-with-helm/02-harrison-use-tiller.yaml) -->
<!-- The below code snippet is automatically added from labs/03-playing-with-helm/02-harrison-use-tiller.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding

metadata:
  name: harrison-use-tiller

subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: harrison

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: helm-tiller-access
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/03-playing-with-helm/03-tiller-serviceaccount.yaml) -->
<!-- The below code snippet is automatically added from labs/03-playing-with-helm/03-tiller-serviceaccount.yaml -->
```yaml
# ServiceAccounts are used in Pod/RS/Deployment declarations
---
apiVersion: v1
kind: ServiceAccount

metadata:
  name: tiller-sa
  namespace: kube-system
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/03-playing-with-helm/04-tiller-clusterrolebinding.yaml) -->
<!-- The below code snippet is automatically added from labs/03-playing-with-helm/04-tiller-clusterrolebinding.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding

metadata:
  name: tiller

subjects:
  - apiGroup: ""
    kind: ServiceAccount
    name: tiller-sa
    namespace: kube-system

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
kubectl apply --filename labs/03-playing-with-helm/01-helm-tiller-access.yaml
kubectl apply --filename labs/03-playing-with-helm/02-harrison-use-tiller.yaml
```

```bash
kubectl apply --filename labs/03-playing-with-helm/03-tiller-serviceaccount.yaml
kubectl apply --filename labs/03-playing-with-helm/04-tiller-clusterrolebinding.yaml
```


## References

- [RBAC Online Talk - YouTube](https://www.youtube.com/watch?v=CnHTCTP8d48)
- [RBAC Online Talk - Slides](https://www.cncf.io/wp-content/uploads/2018/07/RBAC-Online-Talk.pdf)
- [RBAC Online Talk - Materials](https://github.com/javsalgar/rbac-online-talk)
- [Demystifying RBAC in Kubernetes](https://www.cncf.io/blog/2018/08/01/demystifying-rbac-in-kubernetes/)
- [Kubernetes RBAC: Giving Users Access](https://platform9.com/blog/the-gorilla-guide-to-kubernetes-in-the-enterprise-chapter-4-putting-kubernetes-to-work/)
