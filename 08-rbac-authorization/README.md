# RBAC Authorization

> **Role-Based Access Control** (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Creating Users](#creating-users)
- [Key Concepts](#key-concepts)
- [Roles](#roles)
- [RoleBindings](#rolebindings)
- [ClusterRoles](#clusterroles)
- [ClusterRoleBindings](#clusterrolebindings)
- [ServiceAccounts](#serviceaccounts)
- [Understanding RBAC API Objects](#understanding-rbac-api-objects)
- [Subjects: Users and Service Accounts](#subjects-users-and-service-accounts)
- [RBAC in Deployments: A use case](#rbac-in-deployments-a-use-case)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Creating Users

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-creating-users/create-certificates.sh) -->
<!-- The below code snippet is automatically added from labs/01-creating-users/create-certificates.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r CERT_DIR=".certificates"

# Create cert dirs
rm -rf ${CERT_DIR}
mkdir ${CERT_DIR}
cp ~/.minikube/ca.crt ${CERT_DIR}

# Private Key
openssl genrsa -out ${CERT_DIR}/harrison.key 2048
cat ${CERT_DIR}/harrison.key

# Certificate Sign Request
openssl req -new -key ${CERT_DIR}/harrison.key -out ${CERT_DIR}/harrison.csr -subj "/CN=harrison/O=devs/O=tech-lead"
cat ${CERT_DIR}/harrison.csr

# Certificate
openssl x509 -req -in ${CERT_DIR}/harrison.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${CERT_DIR}/harrison.crt -days 500
cat ${CERT_DIR}/harrison.crt

# Check the content of the certificate
openssl x509 -in ${CERT_DIR}/harrison.crt -text -noout
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-creating-users/configure-kubectl.sh) -->
<!-- The below code snippet is automatically added from labs/01-creating-users/configure-kubectl.sh -->
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


## Key Concepts

- **Subjects**: the objects (Users, Groups, Processes) allowed access to the Kubernetes API,
based on **API Resources** and **Verbs**.

- **API Resources**: the Kubernetes API Objects available on the clusters.
They are the Pods, Deployments, Services, Nodes, PersistentVolumes and other things that make up Kubernetes.

- **Verbs**: the set of operations that can be executed to the **Resources** above.
There are many **Verbs** (e.g. get, watch, create, delete,...),
but ultimately all of them are Create, Read, Update or Delete (CRUD) operations.

<div align="center">
  <img src="assets/types-of-rbac.png" width="900">
  <br />
  <em>Types of Role-Based Access Control</em>
  <br />
</div>
<br />


## Roles

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/01-pod-access-role.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/01-pod-access-role.yaml -->
```yaml
# Establish a set of allowed operations (rules)
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
```

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

```bash
$ kubectl apply --filename labs/02-setting-rbac-rules/01-pod-access-role.yaml
role.rbac.authorization.k8s.io/pod-access created
```

```bash
$ kubectl apply --filename labs/02-setting-rbac-rules/02-ns-admin-role.yaml                                         127 ↵
role.rbac.authorization.k8s.io/ns-admin created
```

```
$ kubectl get roles --namespace=test
NAME         AGE
ns-admin     21s
pod-access   83s
```


```bash
# At the end of this script, you will create some access rules for your newly created user

## Switch to the new user and try executing these commands now
kubectl config use-context harrison@minikube
kubectl get pods
kubectl get pods --namespace=test
kubectl run -n test nginx --image=nginx --replicas=2


## Switch to the user and let's try deploying

kubectl config use-context harrison@minikube
kubectl run -n test nginx --image=nginx --replicas=2
kubectl get pods -n test -w
kubectl expose deployment nginx -n test --type=NodePort --port=80
kubectl get svc -n test

kubectl run nginx --image=nginx --replicas=2

## Finally, we will grant the user full pod read access
kubectl config use-context minikube
kubectl apply --filename labs/02-setting-rbac-rules/05-all-pods-access.yaml
kubectl apply --filename labs/02-setting-rbac-rules/06-harrison-reads-all-pods.yaml

## Test now

kubectl config use-context harrison@minikube
kubectl get pods -n test
kubectl get pods
kubectl get pods -n kube-system

kubectl get svc
kubectl run nginx --image=nginx --replicas=2
```


## RoleBindings

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/03-devs-read-pods.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/03-devs-read-pods.yaml -->
```yaml
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

roleRef:
  name: pod-access
  kind: Role

  apiGroup: rbac.authorization.k8s.io
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
bash-5.0# kubectl get pods
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "default"
```

```bash
bash-5.0# kubectl get pods --namespace=test
Error from server (Forbidden): pods is forbidden: User "harrison" cannot list resource "pods" in API group "" in the namespace "test"
```

```bash
# Give the user privileges to see pods in the "test" namespace
$ kubectl apply --filename labs/02-setting-rbac-rules/03-devs-read-pods.yaml
rolebinding.rbac.authorization.k8s.io/devs-read-pods created
```

```bash
bash-5.0# kubectl get pods --namespace=test
No resources found in test namespace.
```

```bash
kubectl run --generator=run-pod/v1 --namespace=test test nginx --image=nginx --replicas=2
```

```bash
# Now we will grant administrator access in the namespace
$ kubectl apply --filename labs/02-setting-rbac-rules/04-harrison-ns-admin.yaml
```


## ClusterRoles

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/05-all-pods-access.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/05-all-pods-access.yaml -->
```yaml
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


## ClusterRoleBindings

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/02-setting-rbac-rules/06-harrison-reads-all-pods.yaml) -->
<!-- The below code snippet is automatically added from labs/02-setting-rbac-rules/06-harrison-reads-all-pods.yaml -->
```yaml
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


## ServiceAccounts

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

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/03-playing-with-helm/03-tiller-clusterrolebinding.yaml) -->
<!-- The below code snippet is automatically added from labs/03-playing-with-helm/03-tiller-clusterrolebinding.yaml -->
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
# At the end of this script, you will experience some issues with Helm and then have it configured for your minikube cluster

## NOTE: if you want to reproduce the same environment, execute these previous commands
# kubectl config use-context minikube
# kubectl delete clusterrolebinding minikube-rbac
# Set up helm using the last set of commands

## Try deploying a dokuwiki chart
kubectl config use-context harrison@minikube
helm install stable/dokuwiki --namespace=test

## We need to grant some extra permissions for harrison to access tiller
kubectl config use-context minikube
kubectl apply --filename labs/03-playing-with-helm/01-helm-tiller-access.yaml
kubectl apply --filename labs/03-playing-with-helm/02-harrison-use-tiller.yaml

## Try now
kubectl config use-context harrison@minikube
helm ls
helm install stable/dokuwiki --namespace=test
kubectl get pods -n test -w

helm install stable/dokuwiki
kubectl run --image=bitnami/dokuwiki dokuwiki
kubectl get pods
helm install stable/dokuwiki --namespace=kube-system

## Let's delete tiller
kubectl config use-context minikube
helm reset --force
helm init

## Let's try now
helm ls
kubectl config use-context harrison@minikube
helm install stable/dokuwiki

## Let's fix this
kubectl config use-context minikube
kubectl create serviceaccount tiller-sa -n kube-system
kubectl apply -f yaml/03-tiller-clusterrolebinding.yaml

## Redeploy helm
helm init --upgrade --service-account tiller-sa
```

- These three elements combine into giving a user permission
to execute certain operations on a set of resources
by using Roles and RoleBindings (connecting Subjects like Users, Groups and Service Accounts to Roles).

Users are authenticated using one or more authentication modes. These include client certificates, passwords, and various tokens.
After this, each user action or request on the cluster is authorized against the rules assigned to a user through roles.

There are two kinds of users: Service Accounts managed by Kubernetes, and normal users.
These normal users come from an identity store outside Kubernetes.
This means that accessing Kubernetes with multiple users, or even multiple roles, is something that needs to be carefully thought out.
Which identity source will you use? Which access control mode most suits you?
Which attributes or roles should you define? For larger deployments,
it's become standard to give each app a dedicated Service Account and launch the app with it.
Ideally, each app would run in a dedicated namespace, as it's fairly easy to assign roles to namespaces.

Kubernetes does lend itself to securing namespaces,
granting only permissions where needed so users don't see resources in their authorized namespace for isolation.
It also limits resource creation to specific namespaces, and applies quotas.

Many organizations take this one step further and lock down access even more,
so only tooling in their CI/CD pipeline can access Kubernetes, via Service Accounts.
This locks out real, actual humans, as they are expected to interact with Kubernetes clusters only indirectly.


## Understanding RBAC API Objects

- **Roles**: will connect API Resources and Verbs.
These can be reused for different Subjects.
These are bound to one namespace (we cannot use wildcards to represent more than one, but we can deploy the same role object in different namespaces).
If we want the role to be applied cluster-wide, the equivalent object is called ClusterRoles.

- **RoleBinding**: will connect the remaining entity-subjects.
Given a Role, which already binds API Objects and Verbs,
we will establish which subjects can use it.
For the cluster-level, non-namespaced equivalent, there are ClusterRoleBindings.


## Subjects: Users and Service Accounts

- **Users**: these are global, and meant for humans or processes living outside the cluster.
- **Service Accounts**: these are namespaced and meant for intra-cluster processes running inside Pods.


## RBAC in Deployments: A use case


## References

- [RBAC Online Talk - YouTube](https://www.youtube.com/watch?v=CnHTCTP8d48)
- [RBAC Online Talk - Slides](https://www.cncf.io/wp-content/uploads/2018/07/RBAC-Online-Talk.pdf)
- [RBAC Online Talk - Materials](https://github.com/javsalgar/rbac-online-talk)
- [Configure RBAC in your Kubernetes Cluster](https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/)
- [Demystifying RBAC in Kubernetes](https://www.cncf.io/blog/2018/08/01/demystifying-rbac-in-kubernetes/)
- [Kubernetes RBAC: Giving Users Access](https://platform9.com/blog/the-gorilla-guide-to-kubernetes-in-the-enterprise-chapter-4-putting-kubernetes-to-work/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
