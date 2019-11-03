# Kubernetes Secrets and ConfigMaps

> Kubernetes has two types of objects that can inject configuration data into a container when it starts up: Secrets and ConfigMaps.
> Secrets and ConfigMaps behave similarly in Kubernetes,
> both in how they are created and because they can be exposed inside a container as mounted files or volumes or environment variables.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Secrets](#secrets)
  - [Create a `Secret` using `YAML` file](#create-a-secret-using-yaml-file)
  - [Create a `Secret` using `kubectl` command](#create-a-secret-using-kubectl-command)
- [ConfigMaps](#configmaps)
  - [Create a ConfigMap from an existing file](#create-a-configmap-from-an-existing-file)
- [Using Secrets and ConfigMaps](#using-secrets-and-configmaps)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

scenario:

You're running the official MariaDB container image in Kubernetes and must do some configuration to get the container to run.
The image requires an environment variable to be set for MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD, or MYSQL_RANDOM_ROOT_PASSWORD to initialize the database.
It also allows for extensions to the MySQL configuration file my.cnf by placing custom config files in /etc/mysql/conf.d.

This is a perfect use-case for ConfigMaps and Secrets.
The MYSQL_ROOT_PASSWORD can be set in a Secret and added to the container as an environment variable,
and the configuration files can be stored in a ConfigMap and mounted into the container as a file on startup.

```bash
$ kubectl config current-context
minikube

$ kubectl version --short
Client Version: v1.16.2
Server Version: v1.16.2
```


## Secrets

> Secrets are a Kubernetes object intended for storing a small amount of sensitive data.
> It is worth noting that Secrets are stored base64-encoded within Kubernetes, so they are not wildly secure.
> Make sure to have appropriate role-based access controls (RBAC) to protect access to Secrets.
> Even so, extremely sensitive Secrets data should probably be stored using something like HashiCorp Vault.

### Create a `Secret` using `YAML` file

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-secret.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-secret.yaml -->
```yaml
---
apiVersion: v1
kind: Secret

metadata:
  name: mariadb-root-password

type: Opaque
data:
  # echo -n 'KubernetesRocks!' | base64
  # n: not print the trailing newline character
  password: S3ViZXJuZXRlc1JvY2tzIQ==
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ kubectl apply --filename labs/mysql-secret.yaml
secret/mariadb-root-password created
```

```bash
$ kubectl describe secret mariadb-root-password
Name:         mariadb-root-password
Namespace:    default
Labels:       <none>
Annotations:
Type:         Opaque

Data
====
password:  16 bytes
```

```bash
$ kubectl get secret mariadb-root-password --output jsonpath='{.data.password}' | base64 --decode | xargs
KubernetesRocks!
```

### Create a `Secret` using `kubectl` command

A Secret can hold more than one key/value pair, so you can create a single Secret to hold both strings.

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/create-secret.sh) -->
<!-- The below code snippet is automatically added from labs/create-secret.sh -->
```sh
#!/usr/bin/env bash
# Why?

set -o pipefail
# Why?

kubectl create secret generic mariadb-user-creds \
  --from-literal=MYSQL_USER=kubeuser \
  --from-literal=MYSQL_PASSWORD=kube-still-rocks

# secret/mariadb-user-creds created
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ kubectl get secret mariadb-user-creds --output jsonpath='{.data.MYSQL_USER}' | base64 --decode | xargs
kubeuser

$ kubectl get secret mariadb-user-creds --output jsonpath='{.data.MYSQL_PASSWORD}' | base64 --decode | xargs
kube-still-rocks
```


## ConfigMaps

> ConfigMaps are similar to Secrets.
> They can be created (YAML, kubectl) and shared in the containers in the same ways.
> The only big difference between them is the base64-encoding obfuscation.
> ConfigMaps are intended for non-sensitive data—configuration data—like config files and environment variables and are a great way to create customized running services from generic container images.

### Create a ConfigMap from an existing file

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/max_allowed_packet.cnf) -->
<!-- The below code snippet is automatically added from labs/max_allowed_packet.cnf -->
```cnf
[mysqld]
max_allowed_packet = 64M
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/create-configmap.sh) -->
<!-- The below code snippet is automatically added from labs/create-configmap.sh -->
```sh
kubectl create configmap mariadb-config --from-file=max_allowed_packet.cnf

# configmap/mariadb-config created
```
<!-- AUTO-GENERATED-CONTENT:END -->

- By default, using `--from-file=<filename>` (as above) will store the contents of the file as the value, and the name of the file will be stored as the key.
- However, the key name can be explicitly set, too. For example, if you used --from-file=max-packet=max_allowed_packet.cnf when you created the ConfigMap, the key would be max-packet rather than the file name.

```bash
$ kubectl describe configmap mariadb-config
Name:         mariadb-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
max_allowed_packet.cnf:
----
[mysqld]
max_allowed_packet = 64M

Events:  <none>
```

```bash
$ kubectl edit configmap mariadb-config

apiVersion: v1
data:
  max_allowed_packet.cnf: |
    [mysqld]
    max_allowed_packet = 64M
kind: ConfigMap
metadata:
  creationTimestamp: "2019-11-03T12:46:26Z"
  name: mariadb-config
  namespace: default
  resourceVersion: "38334"
  selfLink: /api/v1/namespaces/default/configmaps/mariadb-config
  uid: 0e2f092c-136e-4f02-9e44-98868c6b2a91
```

```bash
$ kubectl get configmap mariadb-config --output "jsonpath={.data['max_allowed_packet\.cnf']}"
[mysqld]
max_allowed_packet = 64M
```


## Using Secrets and ConfigMaps

> Secrets and ConfigMaps can be mounted as environment variables or as files within a container.

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mariadb-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/mariadb-deployment.yaml -->
```yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  labels:
    app: mariadb
  name: mariadb-deployment

spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb

  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
        - image: docker.io/mariadb:10.4
          name: mariadb

          # Add the Secrets as environment variables
          env:
            # Name of the environment variable that is added to the container
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mariadb-root-password
                  key: password

          envFrom:
            - secretRef:
                name: mariadb-user-creds

          ports:
            - containerPort: 3306
              protocol: TCP
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: mariadb-volume-1
            - mountPath: /etc/mysql/conf.d
              name: mariadb-config-volume
      volumes:
        - emptyDir: {}
          name: mariadb-volume-1
        - configMap:
            name: mariadb-config
            items:
              - key: max_allowed_packet.cnf
                path: max_allowed_packet.cnf
          name: mariadb-config-volume
```
<!-- AUTO-GENERATED-CONTENT:END -->


## References

- [An Introduction to Kubernetes Secrets and ConfigMaps](https://opensource.com/article/19/6/introduction-kubernetes-secrets-and-configmaps)
