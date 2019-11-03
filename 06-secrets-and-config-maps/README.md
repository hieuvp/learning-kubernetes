# Kubernetes Secrets and ConfigMaps

> Kubernetes has two types of objects that can inject configuration data into a container when it starts up: Secrets and ConfigMaps.
> Secrets and ConfigMaps behave similarly in Kubernetes,
> both in how they are created and because they can be exposed inside a container as mounted files or volumes or environment variables.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Secrets](#secrets)
- [ConfigMaps](#configmaps)
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


## ConfigMaps

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/max_allowed_packet.cnf) -->
<!-- The below code snippet is automatically added from labs/max_allowed_packet.cnf -->
```cnf
[mysqld]
max_allowed_packet = 64M
```
<!-- AUTO-GENERATED-CONTENT:END -->


## Using Secrets and ConfigMaps

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
          env:
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
