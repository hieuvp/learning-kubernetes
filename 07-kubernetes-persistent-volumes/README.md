# Kubernetes Persistent Volumes

> Containers are often times short lived. They might scale based on need, and will redeploy when issues occur.
> This functionality is welcomed, but sometimes we have state to worry about and state is not meant to be short lived.
> Kubernetes persistent volumes can help to resolve this discrepancy.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [The Theory](#the-theory)
- [In Action](#in-action)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## The Theory


## In Action

<div align="center"><img src="assets/diagram.png" width="400"></div>

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-pv.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-pv.yaml -->
```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysqlvol
spec:
  storageClassName: manual
  capacity:
    # Size of the volume
    storage: 10Gi
  accessModes:
    # Type of access
    - ReadWriteOnce
  hostPath:
    # host location
    path: "/mnt/data"
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-pvc.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-pvc.yaml -->
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysqlvol
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-deployment.yaml -->
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hollowdb
  labels:
    app: hollowdb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hollowdb
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: hollowdb
    spec:
      containers:
        - name: mysql
          image: eshanks16/hollowdb-mysql:v4
          imagePullPolicy: Always
          ports:
            - containerPort: 3306
          volumeMounts:
            - name: mysqlstorage
              mountPath: /var/lib/mysql
      volumes:
        - name: mysqlstorage
          persistentVolumeClaim:
            claimName: mysqlvol
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-service.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-service.yaml -->
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: hollowdb
spec:
  ports:
    - name: mysql
      port: 3306
      targetPort: 3306
      protocol: TCP
  selector:
    app: hollowdb
```
<!-- AUTO-GENERATED-CONTENT:END -->


## References

- [Kubernetes - Persistent Volumes](https://theithollow.com/2019/03/04/kubernetes-persistent-volumes/)
- [Kubernetes Volumes 2: Understanding Persistent Volume (PV) and Persistent Volume Claim (PVC)](https://www.youtube.com/watch?v=OulmwTYTauI)
