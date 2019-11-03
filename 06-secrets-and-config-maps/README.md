# Kubernetes Secrets and ConfigMaps


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Secrets](#secrets)
- [ConfigMaps](#configmaps)
- [Using Secrets and ConfigMaps](#using-secrets-and-configmaps)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


```bash
$ kubectl config current-context
minikube
```


## Secrets

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
