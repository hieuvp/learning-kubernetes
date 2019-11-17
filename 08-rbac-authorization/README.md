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

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-creating-users/create-user.sh) -->
<!-- The below code snippet is automatically added from labs/01-creating-users/create-user.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

## Create cert dirs
mkdir -p ~/.certs/kubernetes/minikube/

## Private key
openssl genrsa -out ~/.certs/kubernetes/minikube/harrison.key 2048

## Certificate sign request
openssl req -new -key ~/.certs/kubernetes/minikube/harrison.key -out /tmp/harrison.csr -subj "/CN=harrison/O=devs/O=tech-lead"

## Certificate
openssl x509 -req -in /tmp/harrison.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ~/.certs/kubernetes/minikube/harrison.crt -days 500

# Check the content of the certificate
openssl x509 -in "$HOME/.certs/kubernetes/minikube/harrison.crt" -text -noout

# Add new kubectl context

# This one is not necessary
# MINIKUBE_IP=$(minikube ip)
# kubectl config set-cluster minikube --certificate-authority=$HOME/.certs/kubernetes/minikube/ca.crt --embed-certs=true --server=https://${MINIKUBE_IP}:6443

kubectl config set-credentials harrison@minikube --client-certificate="$HOME/.certs/kubernetes/minikube/harrison.crt" --client-key="$HOME/.certs/kubernetes/minikube/harrison.key" --embed-certs=true

kubectl config set-context harrison@minikube --cluster=minikube --user=harrison@minikube

# Set new context
kubectl config use-context harrison@minikube

# Try
kubectl get pods
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


## RoleBindings


## ClusterRoles


## ClusterRoleBindings


## ServiceAccounts


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

```bash
$ docker build --tag kubectl labs/
$ docker run --detach --name kubectl kubectl
$ docker exec -it --user root kubectl /bin/bash
```

```bash
$ docker stop kubectl
$ docker rm kubectl
$ docker rmi kubectl
```


## References

- [RBAC Online Talk - YouTube](https://www.youtube.com/watch?v=CnHTCTP8d48)
- [RBAC Online Talk - Slides](https://www.cncf.io/wp-content/uploads/2018/07/RBAC-Online-Talk.pdf)
- [RBAC Online Talk - Materials](https://github.com/javsalgar/rbac-online-talk)
- [Configure RBAC in your Kubernetes Cluster](https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/)
- [Demystifying RBAC in Kubernetes](https://www.cncf.io/blog/2018/08/01/demystifying-rbac-in-kubernetes/)
- [Kubernetes RBAC: Giving Users Access](https://platform9.com/blog/the-gorilla-guide-to-kubernetes-in-the-enterprise-chapter-4-putting-kubernetes-to-work/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
