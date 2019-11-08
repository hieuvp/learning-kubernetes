# Kubernetes Persistent Volumes


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Theory](#theory)
  - [Persistent Volumes (PVs)](#persistent-volumes-pvs)
    - [Static Volumes](#static-volumes)
    - [Dynamic Volumes](#dynamic-volumes)
  - [Persistent Volume Claims (PVCs)](#persistent-volume-claims-pvcs)
  - [Reclaim Policies](#reclaim-policies)
- [Practice](#practice)
  - [Deploy MySQL](#deploy-mysql)
  - [Deploy the App](#deploy-the-app)
  - [Test Database Resiliency](#test-database-resiliency)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Theory

### Persistent Volumes (PVs)

- **Persistent Volumes** are simply a piece of storage in your cluster.
Similar to how you have a disk resource in a server,
a **Persistent Volume** provides storage resources for objects in the cluster.

- This storage resource exists independently from any **Pods** that may consume it.
Meaning, that if the **Pod** dies, the storage should remain intact assuming the [Reclaim Policies](#reclaim-policies) are correct.

#### Static Volumes

- Static PVs simply means that a cluster administrator creates a number of PVs.

- They carry the details of the real storage, which is available for use by cluster users.

#### Dynamic Volumes

- When none of the static PVs the administrator created match a user's `PersistentVolumeClaim`,
the cluster may try to dynamically provision a volume specially for the PVC.

- This provisioning is based on StorageClasses:
    - The PVC must request a storage class.
    - The administrator must have created and configured that class for dynamic provisioning to occur.

### Persistent Volume Claims (PVCs)

- **Pods** that need access to persistent storage, obtain that access through the use of a **Persistent Volume Claim**.

- A **PVC** binds a **Persistent Volume** to a **Pod** that requested it.
Indirectly the Pods get access to the PV, but only through the use of a PVC.

### Reclaim Policies

A Persistent Volume can have several different reclaim policies associated with it:

- `Retain`: when the claim is deleted, the volume remains.
- `Delete`: when the claim is deleted, the volume is deleted.
- [`Recycle`](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recycle) is deprecated. Instead, the recommended approach is to use dynamic provisioning.


## Practice

<div align="center"><img src="assets/architecture-diagram.png" width="370"></div>

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/apply.sh) -->
<!-- The below code snippet is automatically added from labs/apply.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

kubectl apply --filename labs/mysql-pv.yaml
kubectl apply --filename labs/mysql-pvc.yaml
kubectl apply --filename labs/mysql-deployment.yaml
kubectl apply --filename labs/mysql-service.yaml

kubectl apply --filename labs/hollow-config.yaml
kubectl apply --filename labs/hollow-deployment.yaml
kubectl apply --filename labs/hollow-service.yaml
kubectl apply --filename labs/hollow-ingress.yaml
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/apply.sh
```


### Deploy MySQL

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-pv.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-pv.yaml -->
```yaml
---
apiVersion: v1
kind: PersistentVolume

metadata:
  name: mysql-volume

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

```bash
$ kubectl get pv
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-pvc.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-pvc.yaml -->
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim

metadata:
  name: mysql-volume

spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ kubectl get pvc
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-deployment.yaml -->
```yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  name: hollow-database
  labels:
    app: hollow-database

spec:
  replicas: 1
  strategy:
    # The "Recreate" strategy is a dummy deployment which consists of
    # shutting down version A then
    # deploying version B after version A is turned off
    # This technique implies downtime of the service that
    # depends on both shutdown and boot duration of the application
    type: Recreate
    # Default is "RollingUpdate"

  selector:
    matchLabels:
      app: hollow-database

  template:
    metadata:
      labels:
        app: hollow-database

    spec:
      containers:
        - name: mysql
          image: eshanks16/hollowdb-mysql:v4
          imagePullPolicy: Always

          ports:
            - containerPort: 3306

          env:
            - name: MYSQL_USER
              value: "app"
            - name: MYSQL_PASSWORD
              value: "Passw0rd123"
            - name: MYSQL_DATABASE
              value: "hollow"

          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql

      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: mysql-volume
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-service.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-service.yaml -->
```yaml
---
apiVersion: v1
kind: Service

metadata:
  name: hollow-database

spec:
  selector:
    app: hollow-database

  ports:
    - name: mysql
      port: 3306
      targetPort: 3306
      protocol: TCP
```
<!-- AUTO-GENERATED-CONTENT:END -->


### Deploy the App

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/hollow-config.yaml) -->
<!-- The below code snippet is automatically added from labs/hollow-config.yaml -->
```yaml
---
apiVersion: v1
kind: ConfigMap

metadata:
  name: hollow-config

data:
  db.string: "mysql+pymysql://app:Passw0rd123@hollow-database:3306/hollow"
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/hollow-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/hollow-deployment.yaml -->
```yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  name: hollow-app
  labels:
    app: hollow-app

spec:
  replicas: 1
  strategy:
    type: Recreate

  selector:
    matchLabels:
      app: hollow-app

  template:
    metadata:
      labels:
        app: hollow-app

    spec:
      containers:
        - name: hollow-app
          image: eshanks16/k8s-hollowapp:v5
          imagePullPolicy: Always

          ports:
            - containerPort: 5000

          env:
            - name: DATABASE_URL
              valueFrom:
                configMapKeyRef:
                  name: hollow-config
                  key: db.string
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/hollow-service.yaml) -->
<!-- The below code snippet is automatically added from labs/hollow-service.yaml -->
```yaml
---
apiVersion: v1
kind: Service

metadata:
  name: hollow-app
  labels:
    app: hollow-app

spec:
  selector:
    app: hollow-app

  ports:
    - port: 5000
      protocol: TCP
      targetPort: 5000
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/hollow-ingress.yaml) -->
<!-- The below code snippet is automatically added from labs/hollow-ingress.yaml -->
```yaml
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress

metadata:
  name: hollow-app
  labels:
    app: hollow-app

spec:
  rules:
    - host: frontend.minikube.local
      http:
        paths:
          - path: /
            backend:
              serviceName: hollow-app
              servicePort: 5000
```
<!-- AUTO-GENERATED-CONTENT:END -->

Add a .gif for using HollowApp


### Test Database Resiliency

Now that the app works, lets test the database resiliency.
Remember that with replica set, Kubernetes will make sure that we have a certain number of pods always running.
If one fails, it will be rebuilt.
Great when there is no state involved.
Now we have a persistent volume with our database in it.
Therefore, we should be able to kill that database pod and a new one will take its place and attach to the persistent storage.
The net result will be an outage, but when it comes back up, our data should still be there.
The diagram below demonstrates what will happen.

<div align="center"><img src="assets/disaster-diagram.png" width="520"></div>

```bash
kubectl delete pod [database pod name]
```

Make a gif for this command

And once I am logged in, I can see my previous post which means my database is functioning even though its in a new pod.
The volume still stored the correct data and was re-attached to the new pod.


## References

- [Kubernetes - Persistent Volumes](https://theithollow.com/2019/03/04/kubernetes-persistent-volumes/)
