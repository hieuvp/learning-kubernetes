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

User management must be configured by the cluster administrator. Examples:
- Certificate-based authentication
- Token-based authentication
- Basic authentication
- OAuth2

```
$ docker exec -it --user=root rbac-authorization bash

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
# CN (Common Name): will be used to identify the User against the API Server
# O (Organization): will be used to identify the Group against the API Server

# Read your Certificate Signing Request
openssl req -text -noout -verify -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr

# Certificate Authority (CA)
# ca.crt: public certificate
cp ~/.minikube/ca.crt ${CERTIFICATE_DIR}/
# ca.key: private key
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

```
bash-5.0# labs/01-creating-users/test.sh
+ cat .kube/config
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
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMwakNDQWJvQ0ZFa3JOSTc5M0UxUklPdnFNUDJsV3Zsb2YvdkJNQTBHQ1NxR1NJYjNEUUVCQ3dVQU1CVXgKRXpBUkJnTlZCQU1UQ20xcGJtbHJkV0psUTBFd0hoY05NVGt4TVRJeU1EUXdNREF5V2hjTk1qRXdOREExTURRdwpNREF5V2pBMk1SRXdEd1lEVlFRRERBaG9ZWEp5YVhOdmJqRU5NQXNHQTFVRUNnd0VaR1YyY3pFU01CQUdBMVVFCkNnd0pkR1ZqYUMxc1pXRmtNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTRNLzQKSm5CcTdzNmFUdGx6Yk5CbDR5eDRDTVpoeFpzL05VakFWZjdCdnE5YVFCR0k3NytKWEs0YkFHU1I4aEdVWEY2eQpnV2tSU2t5ak5QRi84Y1JmM3d3ejluMXoyR0FFQkJkdWhUUjI3bGg4Q01veFQ3MExqQURVV2tZUHdnWjQ4ZldvCmU1czdla1hpQmd6SGpYbThmRENVcEhsc3NjTllvaTFOTGdBTno1alJRTTBJcE81SDBkUnc0YUJrMDAyTkxuMGQKdG1TRGFiZVRnckw5MU9wVUNqak1iTXp3aFNUQlpuQzZha2JaZ1NQS3FicGdtcUxNclRQb1FRbU95YUJpOS9zdApYODhYZ0toamQxOTNMa2VSbVRjaVlUKzVucStTRFRmQ3Z5MnNBM04xaDJXNnVZbjNqM1hXcEdoRzRYcUIrVFZ3Cjg0QThTTTduZkJPRVhCUUJ4d0lEQVFBQk1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQWI1UzJscFd4a29PZ2oKKzNCS2VyaEFCcnpLdWUwTTd2N2hWdmhNVGkwWUZnbGZ3UWpEMWtDQjdOUUF2TTZ3YXhmZVNwM0NjRmpscEhpcwp3M21wS3JpRHJPZk43bTA3MEJ6MDJwWE43ZDZRU29NVE1IdkN4THZTSXYxY2ZmVmNBanRUMjU3K2VnQzR0ano0ClJGUzhUYW9ia1BndWk4Q2toZzRVOSt0WmwzZGJrYS9RRDRVS2l2cDk5RFpPRUt0TnQ5ZFB2NDhRcHMzVHp3QVoKUW5iOHNpNys1Q3JZeHhaQnFjNEtPNlppMVJnd1FxbW1QZGRSaWQvaVlQdkpRbkdaNWhPc1o3bzAxNVJ4L285aApJdHRsY1ZQRDc2SXFMbTJmZlNCQXZSeHJ5Zk91MG5LZktDZ1J3TTJZRUhwd0NPQ3lNYUhwalNZdmdqcDVmTjRiCnFaeGgyOGFnCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBNE0vNEpuQnE3czZhVHRsemJOQmw0eXg0Q01aaHhacy9OVWpBVmY3QnZxOWFRQkdJCjc3K0pYSzRiQUdTUjhoR1VYRjZ5Z1drUlNreWpOUEYvOGNSZjN3d3o5bjF6MkdBRUJCZHVoVFIyN2xoOENNb3gKVDcwTGpBRFVXa1lQd2daNDhmV29lNXM3ZWtYaUJnekhqWG04ZkRDVXBIbHNzY05Zb2kxTkxnQU56NWpSUU0wSQpwTzVIMGRSdzRhQmswMDJOTG4wZHRtU0RhYmVUZ3JMOTFPcFVDampNYk16d2hTVEJabkM2YWtiWmdTUEtxYnBnCm1xTE1yVFBvUVFtT3lhQmk5L3N0WDg4WGdLaGpkMTkzTGtlUm1UY2lZVCs1bnErU0RUZkN2eTJzQTNOMWgyVzYKdVluM2ozWFdwR2hHNFhxQitUVnc4NEE4U003bmZCT0VYQlFCeHdJREFRQUJBb0lCQUdCNVh1Zy8vZU9WVGFyZwpyaVBZR3FFdWlDUmIzY0ZMS2dqWHU1SXJ6VURqUnp1UFN0QjN4WjY4S0dJMnhscTNLSStySTdkZE8wcERNUmFiClBHaW4rT3hpOURtbkJIdXFXSTdZNzFqQ2R2YzVpYURNQS9WUUR4QjVtcWRTd1pobDVxa08zc3FNaHkybHA2VW8KL3NtN29DTTdSYzUvUFNIYnpzRnA1MkVDTE9zVXZ6Y0hUbVBuZklYd0JWVnVDQzIxb3p4OXFxK2dTajZqb3d1RAo5MmljbktUK09vZWJKdys4dGk4UDZuTzZEVkVJUGJnNXhFRWFlTFZCNjZ3T0R4R2ZZMzljWEQ3OFk0VzB4SjlLCk1jdWFHTFZSUFo4TnlDMmdjTWxDeHBzQ282cHBzbXhCMmZvVjJYR3Zxd3VyQmFFUzR0QituVjM2YW53c0tZQ0cKOEtJSUJpRUNnWUVBKzI5QTJ5UkorM0hsN0s4N2hYREc0ODJXcjRCYW8rNllwQ2ZlL3NWejBnZENLbVN5SmdMYgp6R0JRSnd1M3F5YmRLV3c5aGhhcEZ6ZUJpdmg3K3dSU0k5cmlvMDJZMXRpSjRoL1Z6TXNFeGtlVS9NT3FDb3l1CkN4K0RiT1Z2OFdFQi9NSXBkQ1ZKVVhkQ2Z0UlJsTGN6Vm9ZaXN1MDlVUXU1MFVyOHFoKzZLNU1DZ1lFQTVPVDMKdUhOeHVJQUJEa21YMVF2MlpWaE1rWTI1UG1sN0x0eWpzSmRZZFVEZStIMDRqT0JvU2U4K0Z5MXY5OUdLbm5nQQo2TEI2OHRBNWxWWk00bUlhR05KUGhiVTI2K2xCSERHbFFTNnZneDl4UWZuMmVCaXAxRkl6VmRXVU84V2FZNkovClpVOVVZeTFGblVETHR6QmFrODZGeUJGNlMya21xRllCVXRGRE9YMENnWUI4NXV0azhVWC9McmwxTmlkdlJuTEcKdjE1WG1IOXVhQnhUajZyckROTllSbHJNREhHakNGQi8ybWgydlE5a2FrMzdRZFhlUW11RktRR2xNNE1EVTBZcQpvWlZzWWlQR3RwTG9UY0E3bDY2cmdPdTJGTXpucUxMY3U2N2g3YWdLVkpKVUtXL0dUcTk1VkxFbnAvbE8weU1oCm5FaW9jY20vOVA4OXhPNTI1SVByR1FLQmdEUXFXcXFXNU52L2tENEpWNmtlU05GZ0JsTkYwV24vOENzRjdlaFoKRmJmalNPMm8zREovRWtXSFdNYy9lNzBtN0VpaFlOT25KTjRoeG4zYVpUdFMwRS9IM29mQ2ZQblc5eGZOMkxPNgpTQlhDSExYRW1mOVUzNStiL0VjYm5lVGhiQVk1Q24rMFRLOHRxaWZrbElqelpERTdhQkhvcWM1MThIRjg2R0JQCmdOcWhBb0dBTjF0bmY0ay9vUUx6Q0JyV0RxeDhJcWdmWFdjRmZqcXBDT0h3Zk9jTWxnaUc3aGxacElWTjZ3Nm0KNEJNRm9Nb0VEOGtTN0JQMmp4MkJPTytoSFhhY0pRbVVTeUF2c1NsZEhUdVdaZUdqMFA3TU9vcnZSZC84dnVMSgozU2I5eU1kVVA1VlBReEZ5dlYxMWw2YWtKMWJLT0U4VkFZdCtYYmtJVTZZWkdTczFGZkk9Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
+ kubectl version --short
Client Version: v1.16.2
Server Version: v1.16.2
+ helm version --client --short
Client: v2.16.1+gbbdfe5e
+ kubectl config get-clusters
NAME
minikube
+ kubectl config get-contexts
CURRENT   NAME                CLUSTER    AUTHINFO            NAMESPACE
*         harrison@minikube   minikube   harrison@minikube
+ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "default"
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
bash-5.0# labs/02-setting-rbac-rules/test.sh
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

```bash
# Give the user privileges to see pods in the "test" namespace
$ kubectl apply --filename labs/02-setting-rbac-rules/03-devs-read-pods.yaml
rolebinding.rbac.authorization.k8s.io/devs-read-pods created
```

```bash
bash-5.0# labs/02-setting-rbac-rules/test.sh
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
# apiVersion: rbac.authorization.k8s.io/v1
# kind: Role
#
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
  # or remove apiGroup?
  # can achieve the same result?
  - apiGroup: ""
    kind: ServiceAccount
    name: tiller-sa
    namespace: kube-system

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  # The cluster-admin ClusterRole exists by default in your Kubernetes cluster,
  # and allows super-user operations in all of the cluster resources
  name: cluster-admin
# apiVersion: rbac.authorization.k8s.io/v1
# kind: RoleBinding
#
# metadata:
#   name: tiller-role-binding
#   namespace: lab
#
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
