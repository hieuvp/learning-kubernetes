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

- **Subjects**:
the objects (Users, Groups, Processes) allowed access to the Kubernetes API,
based on **API Resources** and **Verbs**.

- **API Resources**:
the Kubernetes API Objects available on the clusters.
They are the Pods, Deployments, Services, Nodes, PersistentVolumes
and other things that make up Kubernetes.

- **Verbs**:
the set of operations that can be executed to the **Resources** above.
There are many **Verbs** (e.g. get, watch, create, delete,...),
but ultimately all of them are Create, Read, Update or Delete (CRUD) operations.

<br />
<div align="center">
  <img src="assets/types-of-rbac.png" width="780">
  <br />
  <em>RBAC connects the three of them</em>
  <br />
</div>


## Creating Users

Users are authenticated using one or more authentication modes.
These include client certificates, passwords, and various tokens.
After this, each user action or request on the cluster is authorized against the rules assigned to a user through roles.

User management must be configured by the cluster administrator. Examples:
- Certificate-based authentication
- Token-based authentication
- Basic authentication
- OAuth2

```bash
$ docker exec -it --user=root rbac-authorization labs/01-creating-users-test.sh
+ kubectl version --short
Client Version: v1.16.2
The connection to the server localhost:8080 was refused - did you specify the right host or port?
+ helm version --short
Client: v2.16.1+gbbdfe5e
Error: Get http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=app%3Dhelm%2Cname%3Dtiller: dial tcp 127.0.0.1:8080: connect: connection refused
+ cat /root/.kube/config
cat: can't open '/root/.kube/config': No such file or directory
+ kubectl config get-clusters
NAME
+ kubectl config get-contexts
CURRENT   NAME   CLUSTER   AUTHINFO   NAMESPACE
+ kubectl config current-context
error: current-context is not set
+ kubectl get pods
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-creating-users/01-create-certificate.sh) -->
<!-- The below code snippet is automatically added from labs/01-creating-users/01-create-certificate.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

# "declare" is a built-in command of the Bash shell
# It declares shell variables and functions,
# sets their attributes, and displays their values
# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"
# -r: make the named items read-only,
# they cannot subsequently be reassigned values or unset

# Create a clean directory to store certificates
rm -rf ${CERTIFICATE_DIR}
mkdir ${CERTIFICATE_DIR}

########################################################################
# DEVELOPER
# 1. Create an RSA Private Key if it does not exist
# 2. Create a CSR (Certificate Signing Request) from the Private Key
# 3. Send the newly created CSR to Administrator
########################################################################

# RSA is a popular format use to create asymmetric key pairs
# those named Public Key and Private Key
openssl genrsa -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key 2048

# Read your RSA Private Key
openssl rsa -check -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key
# -check: verify key consistency

# The CSR (Certificate Signing Request) is created using the PEM format
# and contains the Public Key portion of the Private Key
# as well as information about you (or your company)
openssl req -new \
  -key ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -subj "/CN=${CERTIFICATE_USER}/O=devs/O=tech-lead"
# -subj: set or modify request subject
# /CN (Common Name): K8S will interpret this value as a "User"  (e.g. harrison)
# /O (Organization): K8S will interpret this value as a "Group" (e.g. devs, tech-lead)

# Read your CSR
openssl req -verify -text -noout -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr
# -verify: verify signature on REQ
# -text: text form of REQ
# -noout: do not output REQ

########################################################################
# ADMINISTRATOR
# 1. Sign the Developer's CSR with your CA (Certificate Authority)
########################################################################

# Minikube CA (Certificate Authority)
# CA Public Certificate
cp ~/.minikube/ca.crt ${CERTIFICATE_DIR}/
# CA Private Key
cp ~/.minikube/ca.key ${CERTIFICATE_DIR}/

# An X.509 Certificate is a Digital Certificate that uses
# the widely accepted international X.509 Public Key Infrastructure (PKI) standard
# to verify that a Public Key belongs to
# the user, computer or service identity contained within the Certificate
openssl x509 -req \
  -CA ${CERTIFICATE_DIR}/ca.crt \
  -CAkey ${CERTIFICATE_DIR}/ca.key \
  -CAcreateserial \
  -days 500 \
  -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt
# -days: how long till expiry of a signed certificate (default: 30 days)

# Serial
# - The first time using a CA to sign a Certificate we can use "-CAcreateserial"
#   This option will create a file (ca.srl) containing a Serial Number
# - We are probably going to create more Certificate,
#   and the next time we will have to do that use "-CAserial" (no more "-CAcreateserial")
#   followed with the name of the file containing the Serial Number
# - This file (ca.srl) will be increased each time we sign a new Certificate
#   This Serial Number will be readable using a browser,
#   once the Certificate is imported to a pkcs12 format
#   And we can have an idea of the number of Certificate created by our CA

# Read Developer's X.509 Certificate
openssl x509 -text -noout -purpose -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt
# -text: print the certificate in text form
# -noout: no output, just status
# -purpose: print out certificate purposes

########################################################################
# DEVELOPER
# 4. Download the CA Public Certificate and your X.509 Certificate
# ├── ca.crt
# ├── harrison.crt
# └── harrison.key
########################################################################

tree ${CERTIFICATE_DIR}

declare -r CONTAINER_NAME="rbac-authorization"
declare -r CONTAINER_USER="root"
declare -r CONTAINER_CERTIFICATE_DIR="/${CONTAINER_USER}/${CERTIFICATE_DIR}"

docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} rm -rf ${CONTAINER_CERTIFICATE_DIR}
docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} mkdir ${CONTAINER_CERTIFICATE_DIR}

docker cp ${CERTIFICATE_DIR}/ca.crt ${CONTAINER_NAME}:${CONTAINER_CERTIFICATE_DIR}
docker cp ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt ${CONTAINER_NAME}:${CONTAINER_CERTIFICATE_DIR}
docker cp ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key ${CONTAINER_NAME}:${CONTAINER_CERTIFICATE_DIR}

docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} ls -lia ${CONTAINER_CERTIFICATE_DIR}
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
.........................................+++++
......................+++++
e is 65537 (0x010001)
+ openssl rsa -in .certificates/harrison.key -check
RSA key ok
writing RSA key
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA4M/4JnBq7s6aTtlzbNBl4yx4CMZhxZs/NUjAVf7Bvq9aQBGI
77+JXK4bAGSR8hGUXF6ygWkRSkyjNPF/8cRf3wwz9n1z2GAEBBduhTR27lh8CMox
T70LjADUWkYPwgZ48fWoe5s7ekXiBgzHjXm8fDCUpHlsscNYoi1NLgANz5jRQM0I
pO5H0dRw4aBk002NLn0dtmSDabeTgrL91OpUCjjMbMzwhSTBZnC6akbZgSPKqbpg
mqLMrTPoQQmOyaBi9/stX88XgKhjd193LkeRmTciYT+5nq+SDTfCvy2sA3N1h2W6
uYn3j3XWpGhG4XqB+TVw84A8SM7nfBOEXBQBxwIDAQABAoIBAGB5Xug//eOVTarg
riPYGqEuiCRb3cFLKgjXu5IrzUDjRzuPStB3xZ68KGI2xlq3KI+rI7ddO0pDMRab
PGin+Oxi9DmnBHuqWI7Y71jCdvc5iaDMA/VQDxB5mqdSwZhl5qkO3sqMhy2lp6Uo
/sm7oCM7Rc5/PSHbzsFp52ECLOsUvzcHTmPnfIXwBVVuCC21ozx9qq+gSj6jowuD
92icnKT+OoebJw+8ti8P6nO6DVEIPbg5xEEaeLVB66wODxGfY39cXD78Y4W0xJ9K
McuaGLVRPZ8NyC2gcMlCxpsCo6ppsmxB2foV2XGvqwurBaES4tB+nV36anwsKYCG
8KIIBiECgYEA+29A2yRJ+3Hl7K87hXDG482Wr4Bao+6YpCfe/sVz0gdCKmSyJgLb
zGBQJwu3qybdKWw9hhapFzeBivh7+wRSI9rio02Y1tiJ4h/VzMsExkeU/MOqCoyu
Cx+DbOVv8WEB/MIpdCVJUXdCftRRlLczVoYisu09UQu50Ur8qh+6K5MCgYEA5OT3
uHNxuIABDkmX1Qv2ZVhMkY25Pml7LtyjsJdYdUDe+H04jOBoSe8+Fy1v99GKnngA
6LB68tA5lVZM4mIaGNJPhbU26+lBHDGlQS6vgx9xQfn2eBip1FIzVdWUO8WaY6J/
ZU9UYy1FnUDLtzBak86FyBF6S2kmqFYBUtFDOX0CgYB85utk8UX/Lrl1NidvRnLG
v15XmH9uaBxTj6rrDNNYRlrMDHGjCFB/2mh2vQ9kak37QdXeQmuFKQGlM4MDU0Yq
oZVsYiPGtpLoTcA7l66rgOu2FMznqLLcu67h7agKVJJUKW/GTq95VLEnp/lO0yMh
nEioccm/9P89xO525IPrGQKBgDQqWqqW5Nv/kD4JV6keSNFgBlNF0Wn/8CsF7ehZ
FbfjSO2o3DJ/EkWHWMc/e70m7EihYNOnJN4hxn3aZTtS0E/H3ofCfPnW9xfN2LO6
SBXCHLXEmf9U35+b/EcbneThbAY5Cn+0TK8tqifklIjzZDE7aBHoqc518HF86GBP
gNqhAoGAN1tnf4k/oQLzCBrWDqx8IqgfXWcFfjqpCOHwfOcMlgiG7hlZpIVN6w6m
4BMFoMoED8kS7BP2jx2BOO+hHXacJQmUSyAvsSldHTuWZeGj0P7MOorvRd/8vuLJ
3Sb9yMdUP5VPQxFyvV11l6akJ1bKOE8VAYt+XbkIU6YZGSs1FfI=
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
                    00:e0:cf:f8:26:70:6a:ee:ce:9a:4e:d9:73:6c:d0:
                    65:e3:2c:78:08:c6:61:c5:9b:3f:35:48:c0:55:fe:
                    c1:be:af:5a:40:11:88:ef:bf:89:5c:ae:1b:00:64:
                    91:f2:11:94:5c:5e:b2:81:69:11:4a:4c:a3:34:f1:
                    7f:f1:c4:5f:df:0c:33:f6:7d:73:d8:60:04:04:17:
                    6e:85:34:76:ee:58:7c:08:ca:31:4f:bd:0b:8c:00:
                    d4:5a:46:0f:c2:06:78:f1:f5:a8:7b:9b:3b:7a:45:
                    e2:06:0c:c7:8d:79:bc:7c:30:94:a4:79:6c:b1:c3:
                    58:a2:2d:4d:2e:00:0d:cf:98:d1:40:cd:08:a4:ee:
                    47:d1:d4:70:e1:a0:64:d3:4d:8d:2e:7d:1d:b6:64:
                    83:69:b7:93:82:b2:fd:d4:ea:54:0a:38:cc:6c:cc:
                    f0:85:24:c1:66:70:ba:6a:46:d9:81:23:ca:a9:ba:
                    60:9a:a2:cc:ad:33:e8:41:09:8e:c9:a0:62:f7:fb:
                    2d:5f:cf:17:80:a8:63:77:5f:77:2e:47:91:99:37:
                    22:61:3f:b9:9e:af:92:0d:37:c2:bf:2d:ac:03:73:
                    75:87:65:ba:b9:89:f7:8f:75:d6:a4:68:46:e1:7a:
                    81:f9:35:70:f3:80:3c:48:ce:e7:7c:13:84:5c:14:
                    01:c7
                Exponent: 65537 (0x10001)
        Attributes:
            a0:00
    Signature Algorithm: sha256WithRSAEncryption
         91:94:5b:84:df:03:55:c2:ce:0f:e7:34:de:40:bd:b7:03:93:
         ee:5f:75:9d:ae:fc:a8:e6:93:60:70:d0:04:ed:75:5d:aa:97:
         dc:93:10:4a:f9:b1:88:34:6f:04:f5:3f:08:21:3f:4a:19:62:
         d0:49:54:68:b6:5a:d8:d6:65:56:36:51:1b:62:1e:6a:e5:00:
         28:37:57:e6:8a:cd:49:84:77:72:8d:3f:24:9e:b0:21:5a:fa:
         34:3f:72:ce:48:76:35:ea:b4:3b:e4:ee:42:23:97:5d:77:d6:
         e8:bb:d2:bc:93:5a:cd:30:3b:8a:87:ce:11:d8:f8:04:aa:54:
         e6:18:74:72:29:cd:0f:cc:83:c0:33:09:90:84:bc:6a:59:1e:
         2f:0d:cf:18:73:bb:c7:34:e6:43:03:8e:3e:86:f0:14:47:90:
         d4:81:43:ee:3f:33:3c:b0:ce:92:78:ef:59:db:9a:b8:17:2b:
         be:04:09:9a:e6:59:fe:08:98:95:db:f6:bb:83:10:50:01:77:
         f5:b1:72:be:a8:bc:4a:7b:db:f3:58:82:22:a1:b0:3c:d6:d2:
         07:f5:03:90:4b:85:c5:37:05:83:b0:a6:4c:7b:c9:a2:4b:a3:
         51:d8:d4:ff:ce:cd:b2:fc:6f:43:5d:af:c9:c7:e8:50:b3:88:
         78:16:72:56
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
            49:2b:34:8e:fd:dc:4d:51:20:eb:ea:30:fd:a5:5a:f9:68:7f:fb:c1
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = minikubeCA
        Validity
            Not Before: Nov 22 04:00:02 2019 GMT
            Not After : Apr  5 04:00:02 2021 GMT
        Subject: CN = harrison, O = devs, O = tech-lead
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:e0:cf:f8:26:70:6a:ee:ce:9a:4e:d9:73:6c:d0:
                    65:e3:2c:78:08:c6:61:c5:9b:3f:35:48:c0:55:fe:
                    c1:be:af:5a:40:11:88:ef:bf:89:5c:ae:1b:00:64:
                    91:f2:11:94:5c:5e:b2:81:69:11:4a:4c:a3:34:f1:
                    7f:f1:c4:5f:df:0c:33:f6:7d:73:d8:60:04:04:17:
                    6e:85:34:76:ee:58:7c:08:ca:31:4f:bd:0b:8c:00:
                    d4:5a:46:0f:c2:06:78:f1:f5:a8:7b:9b:3b:7a:45:
                    e2:06:0c:c7:8d:79:bc:7c:30:94:a4:79:6c:b1:c3:
                    58:a2:2d:4d:2e:00:0d:cf:98:d1:40:cd:08:a4:ee:
                    47:d1:d4:70:e1:a0:64:d3:4d:8d:2e:7d:1d:b6:64:
                    83:69:b7:93:82:b2:fd:d4:ea:54:0a:38:cc:6c:cc:
                    f0:85:24:c1:66:70:ba:6a:46:d9:81:23:ca:a9:ba:
                    60:9a:a2:cc:ad:33:e8:41:09:8e:c9:a0:62:f7:fb:
                    2d:5f:cf:17:80:a8:63:77:5f:77:2e:47:91:99:37:
                    22:61:3f:b9:9e:af:92:0d:37:c2:bf:2d:ac:03:73:
                    75:87:65:ba:b9:89:f7:8f:75:d6:a4:68:46:e1:7a:
                    81:f9:35:70:f3:80:3c:48:ce:e7:7c:13:84:5c:14:
                    01:c7
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         1b:e5:2d:a5:a5:6c:64:a0:e8:23:fb:70:4a:7a:b8:40:06:bc:
         ca:b9:ed:0c:ee:fe:e1:56:f8:4c:4e:2d:18:16:09:5f:c1:08:
         c3:d6:40:81:ec:d4:00:bc:ce:b0:6b:17:de:4a:9d:c2:70:58:
         e5:a4:78:ac:c3:79:a9:2a:b8:83:ac:e7:cd:ee:6d:3b:d0:1c:
         f4:da:95:cd:ed:de:90:4a:83:13:30:7b:c2:c4:bb:d2:22:fd:
         5c:7d:f5:5c:02:3b:53:db:9e:fe:7a:00:b8:b6:3c:f8:44:54:
         bc:4d:aa:1b:90:f8:2e:8b:c0:a4:86:0e:14:f7:eb:59:97:77:
         5b:91:af:d0:0f:85:0a:8a:fa:7d:f4:36:4e:10:ab:4d:b7:d7:
         4f:bf:8f:10:a6:cd:d3:cf:00:19:42:76:fc:b2:2e:fe:e4:2a:
         d8:c7:16:41:a9:ce:0a:3b:a6:62:d5:18:30:42:a9:a6:3d:d7:
         51:89:df:e2:60:fb:c9:42:71:99:e6:13:ac:67:ba:34:d7:94:
         71:fe:8f:61:22:db:65:71:53:c3:ef:a2:2a:2e:6d:9f:7d:20:
         40:bd:1c:6b:c9:f3:ae:d2:72:9f:28:28:11:c0:cd:98:10:7a:
         70:08:e0:b2:31:a1:e9:8d:26:2f:82:3a:79:7c:de:1b:a9:9c:
         61:db:c6:a0
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

declare -r CLUSTER_NAME="minikube"
declare -r CLUSTER_IP="192.168.99.100"
declare -r CLUSTER_PORT="8443"

declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"

#####################################################
# Add into your local machine the new configuration #
#####################################################

# --embed-certs=true
# The certificates are embedded as base64-encoded string
# in the kubeconfig file (~/.kube/config)

# Add a new cluster to kubectl
# It will set a "cluster" entry in kubeconfig
kubectl config set-cluster ${CLUSTER_NAME} \
  --server=https://${CLUSTER_IP}:${CLUSTER_PORT} \
  --certificate-authority=${CERTIFICATE_DIR}/ca.crt \
  --embed-certs=true
# embed-certs to "certificate-authority-data" field

# Add a new credentials to kubectl
# It will set a "user" entry in kubeconfig
kubectl config set-credentials ${CERTIFICATE_USER}@${CLUSTER_NAME} \
  --client-certificate=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt \
  --client-key=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  --embed-certs=true
# embed-certs to "client-certificate-data" and "client-key-data" fields

# Add a new context to kubectl
# It will set a "context" entry in kubeconfig
kubectl config set-context ${CERTIFICATE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${CERTIFICATE_USER}@${CLUSTER_NAME}

# Change to the newly created context
# It will set the "current-context" in kubeconfig
kubectl config use-context ${CERTIFICATE_USER}@${CLUSTER_NAME}
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
bash-5.0# labs/01-creating-users/02-config-kubectl.sh
+ declare -r MINIKUBE_IP=192.168.99.100
+ kubectl config set-cluster minikube --certificate-authority=.certificates/ca.crt --embed-certs=true --server=https://192.168.99.100:8443
Cluster "minikube" set.
+ kubectl config set-credentials harrison@minikube --client-certificate=.certificates/harrison.crt --client-key=.certificates/harrison.key --embed-certs=true
User "harrison@minikube" set.
+ kubectl config set-context harrison@minikube --cluster=minikube --user=harrison@minikube
Context "harrison@minikube" created.
+ kubectl config use-context harrison@minikube
Switched to context "harrison@minikube".
```

```bash
$ docker exec -it --user=root rbac-authorization labs/01-creating-users-test.sh                                                                                             1 ↵
+ kubectl version --short
Client Version: v1.16.2
Server Version: v1.16.2
+ helm version --short
Client: v2.16.1+gbbdfe5e
Error: pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "kube-system"
+ cat /root/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRFNE1EZ3dNekEyTkRVd09Gb1hEVEk0TURnd01UQTJORFV3T0Zvd0ZURVRNQkVHQTFVRQpBeE1LYldsdWFXdDFZbVZEUVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT2NFCnhTRXQ5OTV0UVdqemJHZVlsb2ZidGRiSSthWno0RkRoQmlCUkVSU3pYQ1pEQVd4aWlQdzNkYWIyV0NmRkFHMmwKaWx4UnlBandFZSs0ZXkzdDBGbXBQUDhPRzJNdVdqUk1zMmJHREdhNVUvUFdEcTFHRk1lMDY3emZYTXRzUVh3QQpTMlI1YVlyWFZlb0loU29wdWZ4d1RiNXF1VkdicnUzOG9XNnBOVmsybHk4MVljQkJQaENRby9ua3MzaExhRXh6Ck93T3BwdlFZZzAxdy90RkZ2VnRoRHRxY2RzNWV0bXN3SzlXOWFNMUQvc3YvRDFMVnc5dXdwNGdOVWlYS2VTQ1oKTS9rUWowTWREQTZCWUNRRWN6STFCZEpYQjdTSklQSm16T3U2QTEramdMc3BWWExjc0UvbXRQcHkwMmozRW5udwpvS1VkZjljNU0vQTlNb0cyL0UwQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFCQjgydC9rMjVrMlR5M0RiT2VhdUtsQ2hFNng2dWFwQ0NKUkZMR0ViQmVpRVo3YkRFVgpxL29ZbEJsS2FtSmdVaXRnNkVOMUhqUllTNEZvWnpjN3hEU2hSMG1wQWpHU0U3eTZkTS95RzlCMmFzMWZYeFlWCi9PUllZNFczQlZUdFBZelBUSUlOTTVrV0s1aDJzV0lEQVVySFJucVpUOUxtaXRXUXNscys0dzBYTFp6bGhKNjEKUHhhM0U0ajM1cEZzc2wxdlZsb0VwWW1NckNnU1ZXL1BWaGJsYUpMYkYyY3JVUThlMGZOV1ZVYmdGNWMrNzNzMwpiUFVGOWYxM3VLS0x3UVpncVFRQURwbHArejR0YU92S3BYUzNaVm8yMGhGTzRmVVkvSGtldGQ3OSttcUs2NldRCjREZ3pENktmSXR1dG1KNWJIRE1SREplNXNYQmUvcmF2WVYzTQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: harrison@minikube
  name: harrison@minikube
current-context: harrison@minikube
kind: Config
preferences: {}
users:
- name: harrison@minikube
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMwakNDQWJvQ0ZGUWwvNFo3N3p2V2w1WlNhU0VicVRncUlvR1RNQTBHQ1NxR1NJYjNEUUVCQ3dVQU1CVXgKRXpBUkJnTlZCQU1UQ20xcGJtbHJkV0psUTBFd0hoY05NVGt4TWpBeE1URTBPREF6V2hjTk1qRXdOREUwTVRFMApPREF6V2pBMk1SRXdEd1lEVlFRRERBaG9ZWEp5YVhOdmJqRU5NQXNHQTFVRUNnd0VaR1YyY3pFU01CQUdBMVVFCkNnd0pkR1ZqYUMxc1pXRmtNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTdQNTgKMFFWVkkzZ3lmQ0oreUNPVll6cDJnQzhBeGhxWjhuYXJvSVBjRUNJUkZGVVJhU0JLMUJwTnRCNUdmeWg1OGt4agp4TnpLbTR2K1RKNEwxQlBDNDlnNXo2cVlrcFFxdlV0bnFBT2tVbnlOSkM0bld2M0o5bUdWYWEwdW9qKytrK091ClhPZzVrQStYYVE4UmhyUVI2OEE5VzVvaGhwMjJyRlBnRGNzTlRYbXpES1pFNlpXSGFOREFJQStpQUVsTG16Z0kKYUpscFJzTDJKVnp3bWVnNE1GdHIydmdPOHg2LzFFQ2FGL2RCRUtWRDB5UVh2dkU3WUZkcXNoWU1rVnI4SUlzdgpGME5pUlhQd3Y0Y3RsOTBoVHhOc3lxZDE0VEJQMFNRYUl0enB0QkVjZ1Y2NVdla2c3Tm5KZnNBc1hvWVlqMEk0CmtnVzlnQXlQOC9DbG5JLzJRUUlEQVFBQk1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmNjK0FUMEtjcjVVTWIKcG4wNjRjaXloWk1jS0FVWXRYV0h1Q0NhL2plWStuYVRYRTBuVGl2QUZDM0hLRk5aamtyY045N3BxUS9hSnNUbwpBUFZjSXhxcnFSSUJOTk40Y0dML2U4SC9GR3Z6OFpNY0dJZVp1WDAvZi9lLzBJNFhXNUM2TlI4ZkxJUlNyaDdECkNyWnV1by9JQUwzL1NveFRMWnJZR2pCamtROURENk5mVTF6V2o2SEVReUVjT2k1YXdVVHR3YUpQVWI0cWRBeG8KQTRPbVE0ckJZZitsc25xVjIzbWpjOGt2WDdzZ1hHd09YeXdmL25SVjdtWklhM1Azd2hRdzN2MDc2N0l5WVgrWApZM2VWc3lER1BDWmdXS2dkMWw0YXhBTHd1dzk2OW14TVRjZzdPaG41TVh0aDBCeFA5Ni9ndjJ6MlpCd1lFbWplCnRVUmd1K3ZWCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBN1A1ODBRVlZJM2d5ZkNKK3lDT1ZZenAyZ0M4QXhocVo4bmFyb0lQY0VDSVJGRlVSCmFTQksxQnBOdEI1R2Z5aDU4a3hqeE56S200ditUSjRMMUJQQzQ5ZzV6NnFZa3BRcXZVdG5xQU9rVW55TkpDNG4KV3YzSjltR1ZhYTB1b2orK2srT3VYT2c1a0ErWGFROFJoclFSNjhBOVc1b2hocDIyckZQZ0Rjc05UWG16REtaRQo2WldIYU5EQUlBK2lBRWxMbXpnSWFKbHBSc0wySlZ6d21lZzRNRnRyMnZnTzh4Ni8xRUNhRi9kQkVLVkQweVFYCnZ2RTdZRmRxc2hZTWtWcjhJSXN2RjBOaVJYUHd2NGN0bDkwaFR4TnN5cWQxNFRCUDBTUWFJdHpwdEJFY2dWNjUKV2VrZzdObkpmc0FzWG9ZWWowSTRrZ1c5Z0F5UDgvQ2xuSS8yUVFJREFRQUJBb0lCQUhKaklydUFaMmVIVEZhKwpENU5xR1dDYmh6YTNlUmdsSHNqNG5qNExadHdpbFR2TEUydzZPZVBHRGxzeGdiVStSQjIrNFNqVHFMY0xDdUxRCkpjVm5CRm9VczFLWWRLdksrQllGbnpKcEQ1Y0FwdDhmcDc4elg1ZWI0aEh2bE9LYkFkRS93NWowUFZSYk1pbHoKTEhKbjEzNkNleHNMZWNNUHZHdlEwQVBZVGNObVhEVmIxVC81eTRsbzFpRXkwb1BNcmVhSExFR0dTcUpqU09VUwpSNW8wS0NKMGE3bi81b3NzcnQrbWo2R1JMcHcwUWtwaHZNL2xpRTZhWEVqaDBONTBmYVNZZFFwWVdqQ01wMHN3CkpjV3FzSUd4V0x1bTZpRFdLa1R2cHlTM2k5NWxmRkQzTTg1MHJPTEd0eDM5WDRqeDN4WUVwdTU3ZUtSdk5rQ1MKdTI1QVFBRUNnWUVBL1paTTNOZGhaZXNENFk4Vi95c0haaytCRWFzOU03ZWFRaDl4MWtFdEZKV0lncW9VbUxFTwpsc1oxVGFRMWVtUnQ1RExRY000cHpOY0llY2ZLUkEvdFBhL1UzNis4ZUFoRWo2ZlhNYjBBT3lpdXQyZE5MTEhiCnZTa1N3QUszbDhZWmFVVk5ZaFA4azZWSXRCdXZJMjJjRTZuczlDSVNRT1ExOGtvR0NodTBiZUVDZ1lFQTd6L0UKN1JjaHg1bWE0K3h6bGJOM25ySy9Pb1dIbm9FdzVqS0Fia2kxYkRIV0NJcEZleGJKb3cvemsxaXY1N2F1aEFZUwpseUV3WVkzUm94RG1MMUZZUjhFMGUrME5LSlNxRWt5M3Z0R0pNdmRmdEI0VUwzdTZBS0hteUNmcy9NNmV5SzE0Cnc1d1lXMTJ1STNhVlEydEZIVTR3WXpyNGVxckxwdjBhOEhDMDFHRUNnWUFhTENVS3RnQUxjTkladVpiZm15Vk0KWGZCSVRwQW1nbENkZW5sWlQ2akRjeHQvd09ZWFRFN2hLT0o2ZlBRNENaMTk2L0N2YzlmRW1IejdkSzlmanZWQgpaS0JuNWM5aDVCaVBheGMrdnU4RExCTzhRaUVvOThKaUo1Y1QwalA0cWkxOU8vWGNwWXR3QWFNYlU3QWp5L0JMCjUwSFpnSnE1cjlRUmlhcE42TVlhZ1FLQmdFdytJUzZCSWFXdklMb2p2dzNrM0dqNWc1Rk52bE5YemxKOW80b0IKcDdjc0JvNUFLalk0bzlkUUhRcEd4Ly9xcXFDdUlyeUF1aDlNaDVNVXJwWkRzUU5rNGFuZ2VFSUhaazlnbldtMAo4cWtJUmpwckgzbW1UemNtWVJwR0J2TGxrWnBZRmRVWWFIYXRXdkk0TndiK0owOVlmSGtTOE41K2tWbk03UW5VCmtQdmhBb0dBQmR6TS9CN1lBT01SRXcvWjVDaUo5Ny9CYzh3SVF1Y051U0dteStiTElydlBNL0VTNXlTSWhrZTUKRUVFWDlwUWt4SzVXTk90eDZkOUpRaXV6NmI0WGhFMXhwbEt6aDdSN1VzNXNnSkt5RjdNdlVGazNCRFVwWmxLLwp6aWZ4L01Zb1FJbE1jbDdHY2Q1dmhMYnprNnhiT09VTTNhNVZ0Zm5KVHd0UitidnF3Wm89Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
+ kubectl config get-clusters
NAME
minikube
+ kubectl config get-contexts
CURRENT   NAME                CLUSTER    AUTHINFO            NAMESPACE
*         harrison@minikube   minikube   harrison@minikube
+ kubectl config current-context
harrison@minikube
+ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "default"
```

```
# Create a user and configure Kubernetes access
config:
	labs/01-creating-users/01-create-certificate.sh
	docker exec -it --user=root rbac-authorization ./config-kubectl.sh
```


## Roles

> Roles connect **API Resources** and **Verbs**, these can be reused for different **Subjects**.

These are bound to one namespace (we cannot use wildcards to represent more than one, but we can deploy the same role object in different namespaces).
If we want the role to be applied cluster-wide, the equivalent object is called [ClusterRoles](#clusterroles).

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/01-pod-access-role.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/01-pod-access-role.yaml -->
```yaml
# Establish
# a set of allowed operations over a set of resources
# in a namespace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role

metadata:
  name: pod-access
  namespace: test

rules:
  # The name of the "apiGroups" that contain the "resources"
  # When it is "core", we can use an empty string
  - apiGroups: [""]
    resources: ["pods"]

    verbs: ["get", "list"]
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/03-namespace-admin-role.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/03-namespace-admin-role.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role

metadata:
  name: namespace-admin
  namespace: test

rules:
  # Wildcards are allowed
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
# Create a namespace for the new user
$ kubectl create namespace test
namespace/test created

$ kubectl get namespaces
NAME                   STATUS   AGE
default                Active   79m
kube-node-lease        Active   79m
kube-public            Active   79m
kube-system            Active   79m
kubernetes-dashboard   Active   79m
test                   Active   10s
```

```bash
$ kubectl apply --filename labs/02-setting-rbac-rules/01-pod-access-role.yaml
role.rbac.authorization.k8s.io/pod-access created

$ kubectl apply --filename labs/02-setting-rbac-rules/02-ns-admin-role.yaml
role.rbac.authorization.k8s.io/ns-admin created

$ kubectl get roles --namespace=test
NAME         AGE
ns-admin     33s
pod-access   40s
```


## RoleBindings

> **RoleBindings** connect the remaining entity-subjects.
> Given a **Role**, which already binds **API Objects** and **Verbs**,
> we will establish which **Subjects** can use it.

For the cluster-level, non-namespaced equivalent, there are [ClusterRoleBindings](#clusterrolebindings).

```bash
bash-5.0# labs/02-setting-rbac-rules-test.sh
+ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "default"
+ kubectl get pods --namespace=test
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "test"
+ kubectl get pods --namespace=test --watch
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "test"
+ kubectl get pods --namespace=kube-system
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "kube-system"
+ kubectl run nginx --image=nginx --replicas=2
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
Error from server (Forbidden): deployments.apps is forbidden: User "harrison" cannot create resource "deployments" in API group "apps" in the namespace "default"
+ kubectl run nginx --namespace=test --image=nginx --replicas=2
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
Error from server (Forbidden): deployments.apps is forbidden: User "harrison" cannot create resource "deployments" in API group "apps" in the namespace "test"
+ kubectl expose deployment nginx --namespace=test --type=NodePort --port=80
Error from server (Forbidden): deployments.apps "nginx" is forbidden: User "harrison" cannot get resource "deployments" in API group "apps" in the namespace "test"
+ kubectl get services
Error from server (Forbidden): services is forbidden: User "harrison" cannot list resource "services" in API group "" in the namespace "default"
+ kubectl get services --namespace=test
Error from server (Forbidden): services is forbidden: User "harrison" cannot list resource "services" in API group "" in the namespace "test"
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/02-devs-read-pods.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/02-devs-read-pods.yaml -->
```yaml
# Connect a "Role" to a Subject or set of Subjects
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: devs-read-pods
  namespace: test

# User or Group
subjects:
  # Used to specify which "apiGroup" the "kind" belongs to
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

```bash
# Give the user privileges to see pods in the "test" namespace
$ kubectl apply --filename labs/02-setting-rbac-rules/03-devs-read-pods.yaml
rolebinding.rbac.authorization.k8s.io/devs-read-pods created
```

```bash
bash-5.0# labs/02-setting-rbac-rules-test.sh
+ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "default"
+ kubectl get pods --namespace=test
No resources found in test namespace.
+ kubectl get pods --namespace=test --watch
Error from server (Forbidden): unknown (get pods)
+ kubectl get pods --namespace=kube-system
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "kube-system"
+ kubectl run nginx --image=nginx --replicas=2
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
Error from server (Forbidden): deployments.apps is forbidden: User "harrison" cannot create resource "deployments" in API group "apps" in the namespace "default"
+ kubectl run nginx --namespace=test --image=nginx --replicas=2
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
Error from server (Forbidden): deployments.apps is forbidden: User "harrison" cannot create resource "deployments" in API group "apps" in the namespace "test"
+ kubectl expose deployment nginx --namespace=test --type=NodePort --port=80
Error from server (Forbidden): deployments.apps "nginx" is forbidden: User "harrison" cannot get resource "deployments" in API group "apps" in the namespace "test"
+ kubectl get services
Error from server (Forbidden): services is forbidden: User "harrison" cannot list resource "services" in API group "" in the namespace "default"
+ kubectl get services --namespace=test
Error from server (Forbidden): services is forbidden: User "harrison" cannot list resource "services" in API group "" in the namespace "test"
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/04-harrison-namespace-admin.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/04-harrison-namespace-admin.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: harrison-namespace-admin
  namespace: test

subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: harrison

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: namespace-admin
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
# Now we will grant administrator access in the namespace
$ kubectl apply --filename labs/02-setting-rbac-rules/04-harrison-ns-admin.yaml
rolebinding.rbac.authorization.k8s.io/harrison-ns-admin created
```

```bash
bash-5.0# labs/02-setting-rbac-rules/test.sh
+ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "default"
+ kubectl get pods --namespace=test
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6db489d4b7-kkfdz   1/1     Running   0          27m
nginx-6db489d4b7-nbc4g   1/1     Running   0          27m
+ timeout 3s kubectl get pods --namespace=test --watch
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6db489d4b7-kkfdz   1/1     Running   0          27m
nginx-6db489d4b7-nbc4g   1/1     Running   0          27m
+ kubectl get pods --namespace=kube-system
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "kube-system"
+ kubectl run nginx --image=nginx --replicas=2
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
Error from server (Forbidden): deployments.apps is forbidden: User "harrison" cannot create resource "deployments" in API group "apps" in the namespace "default"
+ kubectl run nginx --namespace=test --image=nginx --replicas=2
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
Error from server (AlreadyExists): deployments.apps "nginx" already exists
+ kubectl expose deployment nginx --namespace=test --type=NodePort --port=80
Error from server (AlreadyExists): services "nginx" already exists
+ kubectl get services
Error from server (Forbidden): services is forbidden: User "harrison" cannot list resource "services" in API group "" in the namespace "default"
+ kubectl get services --namespace=test
NAME    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.102.228.57   <none>        80:30839/TCP   28m
```

```bash
$ kubectl get rolebindings --namespace=test
NAME                AGE
devs-read-pods      4m31s
harrison-ns-admin   116s
```


## ClusterRoles

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/05-all-pods-access.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/05-all-pods-access.yaml -->
```yaml
# Establish
# a set of allowed operations over a set of resources
# in the whole cluster
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole

metadata:
  name: all-pods-access

rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
kubectl apply --filename labs/02-setting-rbac-rules/05-all-pods-access.yaml
```

```bash
$ kubectl get clusterroles
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

```bash
$ kubectl get clusterrolebindings
```

Default ClusterRoleBindings
Kubernetes includes some ClusterRoleBindings. For example: 
- system:basic-user: For unauthenticated users (group system:unauthenticated). No operations are allowed.
- cluster-admin: For members of the system:masters group. Can do any operation on the cluster (using cluster-admin ClusterRole).

Admin accounts can be created belonging to this group
-subj "/CN=dbarranco/O=system:masters"

- ClusterRoleBindings for the different components of the cluster (kube-controller-manager, kube-scheduler, kube-proxy ...)

More about the possible actions (verbs)

```bash
kubectl run --image=bitnami/mongodb my-mongodb
```
deployments: create


```bash
kubectl get deployments -w
```
deployments: get, list, watch


```bash
kubectl delete deployment my-mongodb
```
deployments: get, delete


```bash
kubectl edit deployment my-mongodb mypod
```
deployments: get, patch


```bash
kubectl expose deployment my-mongodb --port=27017 --type=NodePort
```
deployments: get
services: create


```bash
kubectl exec -ti mypod bash
```
pods: get
pods/exec: create


## ServiceAccounts

- **Users**: these are global, and meant for humans or processes living outside the cluster.
- **Service Accounts**: these are namespaced and meant for intra-cluster processes running inside Pods.

Both have in common that they want to authenticate against the API in order to perform a set of operations over a set of resources,
and their domains seem to be clearly defined.
They can also belong to what is known as Groups,
so a RoleBinding can bind more than one subject (but ServiceAccounts can only belong to the `system:serviceaccounts` group).


A server called tiller is in charge of rendering and deploying charts
Process in Pod

Necessary for pods that need to contact Kubernetes API
Also used for other operations like storing image pull secrets

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/03-playing-with-helm/01-helm-tiller-access.yaml) -->
<!-- The below code snippet is automatically added from labs/03-playing-with-helm/01-helm-tiller-access.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole

metadata:
  name: helm-tiller-access

rules:
  - apiGroups: ["", "apps"]
    resources: ["pods", "deployments", "services"]
    verbs: ["get", "list", "create", "update"]

  - apiGroups: [""]
    resources: ["pods/portforward"]
    verbs: ["create"]
# metadata:
#   name: tiller-role
#   namespace: lab
#
# rules:
#   - apiGroups: ["", "extensions", "apps"]
#     resources: ["*"]
#     verbs: ["*"]
#   - apiGroups: ["batch"]
#     resources:
#       - jobs
#       - cronjobs
#     verbs: ["*"]
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
# An API token will be automatically created and stored in the cluster
# Can be used in RoleBinding and ClusterRoleBinding as subjects
# ServiceAccounts are used in Pod/RS/Deployment declarations
---
apiVersion: v1
kind: ServiceAccount

metadata:
  name: tiller-sa
  namespace: kube-system
# Pod Object
# spec -> serviceAccountName: my-service-account
# - If not specified it will use the "default" ServiceAccount
# - The API token will be mounted inside the containers
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/03-playing-with-helm/04-tiller-clusterrolebinding.yaml) -->
<!-- The below code snippet is automatically added from labs/03-playing-with-helm/04-tiller-clusterrolebinding.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding

metadata:
  name: tiller-rolebinding

subjects:
  # or remove apiGroup?
  # can achieve the same result?
  - apiGroup: rbac.authorization.k8s.io
    kind: ServiceAccount
    name: tiller-sa
    namespace: kube-system

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  # The cluster-admin ClusterRole exists by default in your Kubernetes cluster,
  # and allows super-user operations in all of the cluster resources
  name: cluster-admin
# subjects:
#   - kind: ServiceAccount
#     name: tiller
#     namespace: lab
# roleRef:
#   kind: Role
#   name: tiller-role
#   apiGroup: rbac.authorization.k8s.io
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
labs/03-playing-with-helm-test.sh
```

<br />

```bash
# We need to grant some extra permissions for harrison to access tiller
kubectl apply --filename labs/03-playing-with-helm/01-helm-tiller-access.yaml
kubectl apply --filename labs/03-playing-with-helm/02-harrison-use-tiller.yaml
```

```bash
labs/03-playing-with-helm-test.sh
```

<br />

```bash
# Let's delete tiller
$ docker exec -it --user=root rbac-authorization helm reset --force
$ docker exec -it --user=root rbac-authorization helm init
```

```bash
labs/03-playing-with-helm-test.sh
```

<br />

```bash
# Let's fix this
kubectl apply --filename labs/03-playing-with-helm/03-tiller-serviceaccount.yaml
kubectl apply --filename labs/03-playing-with-helm/04-tiller-clusterrolebinding.yaml
```

```bash
$ kubectl get serviceaccounts --namespace=kube-system
```

```bash
# Redeploy helm
# Update the tiller pod
$ docker exec -it --user=root rbac-authorization helm init --upgrade --service-account tiller-sa
```

```bash
labs/03-playing-with-helm-test.sh
```


## References

- [RBAC Online Talk - YouTube](https://www.youtube.com/watch?v=CnHTCTP8d48)
- [RBAC Online Talk - Slides](https://www.cncf.io/wp-content/uploads/2018/07/RBAC-Online-Talk.pdf)
- [RBAC Online Talk - Materials](https://github.com/javsalgar/rbac-online-talk)
- [Demystifying RBAC in Kubernetes](https://www.cncf.io/blog/2018/08/01/demystifying-rbac-in-kubernetes/)
- [Kubernetes RBAC: Giving Users Access](https://platform9.com/blog/the-gorilla-guide-to-kubernetes-in-the-enterprise-chapter-4-putting-kubernetes-to-work/)
