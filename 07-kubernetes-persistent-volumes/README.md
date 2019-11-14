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

<br />
<div align="center"><img src="assets/architecture-diagram.png" width="450"></div>
<br />

```
$ minikube ssh ls /mnt
sda1
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/apply.sh) -->
<!-- The below code snippet is automatically added from labs/apply.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

# MySQL - Hollow Database
kubectl apply --filename labs/mysql-pv.yaml
kubectl apply --filename labs/mysql-pvc.yaml
kubectl apply --filename labs/mysql-deployment.yaml
kubectl apply --filename labs/mysql-service.yaml

# Hollow App
kubectl apply --filename labs/hollow-config.yaml
kubectl apply --filename labs/hollow-deployment.yaml
kubectl apply --filename labs/hollow-service.yaml
kubectl apply --filename labs/hollow-ingress.yaml
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/apply.sh
+ kubectl apply --filename labs/mysql-pv.yaml
persistentvolume/database-volume created
+ kubectl apply --filename labs/mysql-pvc.yaml
persistentvolumeclaim/database-volume-claim created
+ kubectl apply --filename labs/mysql-deployment.yaml
deployment.apps/hollow-database created
+ kubectl apply --filename labs/mysql-service.yaml
service/hollow-database created
+ kubectl apply --filename labs/hollow-config.yaml
configmap/hollow-config created
+ kubectl apply --filename labs/hollow-deployment.yaml
deployment.apps/hollow-app created
+ kubectl apply --filename labs/hollow-service.yaml
service/hollow-app created
+ kubectl apply --filename labs/hollow-ingress.yaml
ingress.networking.k8s.io/hollow-ingress created
```


### Deploy MySQL

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-pv.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-pv.yaml -->
```yaml
---
apiVersion: v1
kind: PersistentVolume

metadata:
  name: database-volume

spec:
  # "storageClassName" parameter is one of the ways that
  # a "PersistentVolumeClaim" can find the matching "PersistentVolume"
  storageClassName: manual

  capacity:
    storage: 10Gi

  accessModes:
    # "ReadWriteOnce" : the Volume can be mounted as read-write by a single Node
    # "ReadWriteMany" : the Volume can be mounted as read-write by many Nodes
    # "ReadOnlyMany"  : the Volume can be mounted as read-only by many Nodes
    - ReadWriteOnce

  # Using a file or directory on the host Node
  # to emulate network-attached storage
  hostPath:
    path: "/mnt/data"
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ minikube ssh ls /mnt/data
auto.cnf    client-cert.pem  ib_buffer_pool  ibdata1  performance_schema  server-cert.pem
ca-key.pem  client-key.pem   ib_logfile0     ibtmp1   private_key.pem	  server-key.pem
ca.pem	    hollow	     ib_logfile1     mysql    public_key.pem	  sys
```

```bash
$ kubectl get pv
```

<img src="assets/kubectl-get-pv.png" width="900">
<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-pvc.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-pvc.yaml -->
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim

metadata:
  name: database-volume-claim

spec:
  # PVCs may reference PVs by specifying a "storageClassName",
  # or targeting them with a "selector",
  # or a combination of both
  storageClassName: manual
  # This PVC is searching for a PV with "storageClassName": "manual"

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

<img src="assets/kubectl-get-pvc.png" width="680">
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
    # The "Recreate" strategy is a dummy deployment
    # which consists of shutting down version A then
    # deploying version B after version A is turned off
    # This technique implies downtime of the service that
    # depends on both shutdown and boot duration of the application
    type: Recreate
    # Default deployment is "RollingUpdate"

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
            - name: data-volume
              mountPath: /var/lib/mysql

      volumes:
        - name: data-volume
          # Reference to a "PersistentVolumeClaim"
          persistentVolumeClaim:
            claimName: database-volume-claim
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
      targetPort: 5000
      protocol: TCP
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/hollow-ingress.yaml) -->
<!-- The below code snippet is automatically added from labs/hollow-ingress.yaml -->
```yaml
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress

metadata:
  name: hollow-ingress
  labels:
    app: hollow-app

spec:
  # Host rules
  rules:
    - host: frontend.minikube.local
      http:
        # Define a collection of paths that map requests to backends
        paths:
          - path: /
            # The referenced service endpoint
            # to which the traffic will be forwarded to
            backend:
              serviceName: hollow-app
              servicePort: 5000
```
<!-- AUTO-GENERATED-CONTENT:END -->

<br />

<div align="center"><img src="assets/using-hollow-app.gif" width="900"></div>

```
Username : harrison
Email    : harrison@shopback.com
Password : 123456
Message  : Hello! I am Harrison.
```


### Test Database Resiliency

We have a Persistent Volume with our database in it.
Therefore, we should be able to kill that database Pod
and a new one will take its place and attach to the Persistent Volume.

<br />
<div align="center"><img src="assets/disaster-diagram.png" width="450"></div>
<br />

```bash
$ kubectl delete pod hollow-database-5786674b65-bjbrb
pod "hollow-database-5786674b65-bjbrb" deleted
```

<br />
<div align="center">
  <img src="assets/unhealthy-hollow-app.png" width="200">
  <br />
  <em>The net result will be an outage, but when it comes back up, our data should still be there.</em>
  <br />
</div>

<br />
<div align="center"><img src="assets/kubectl-get-pods.gif" width="720"></div>

<br />
<div align="center">
  <img src="assets/healthy-hollow-app.png" width="900">
  <br />
  <em>Once I am logged in,</em>
  <em>I can see my previous post which means my database is functioning even though its in a new Pod.</em>
  <em>The volume still stored the correct data and was re-attached to the new Pod.</em>
</div>


## References

- [Kubernetes - Persistent Volumes](https://theithollow.com/2019/03/04/kubernetes-persistent-volumes/)
