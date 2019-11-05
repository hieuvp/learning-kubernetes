# Kubernetes Persistent Volumes

> Containers are often times short lived. They might scale based on need, and will redeploy when issues occur.
> This functionality is welcomed, but sometimes we have state to worry about and state is not meant to be short lived.
> Kubernetes persistent volumes can help to resolve this discrepancy.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [The Theory](#the-theory)
  - [Persistent Volumes](#persistent-volumes)
  - [Persistent Volume Claims](#persistent-volume-claims)
  - [Claim Policies](#claim-policies)
- [In Action](#in-action)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## The Theory

### Persistent Volumes

Persistent Volumes are simply a piece of storage in your cluster. Similar to how you have a disk resource in a server, a persistent volume provides storage resources for objects in the cluster. At the most simple terms you can think of a PV as a disk drive. It should be noted that this storage resource exists independently from any pods that may consume it. Meaning, that if the pod dies, the storage should remain intact assuming the claim policies are correct. Persistent Volumes are provisioned in two ways, Statically or Dynamically.
Static Volumes – A static PV simply means that some k8s administrator provisioned a persistent volume in the cluster and it’s ready to be consumed by other resources.
Dynamic Volumes – In some circumstances a pod could require a persistent volume that doesn’t exist. In those cases it is possible to have k8s provision the volume as needed if storage classes were configured to demonstrate where the dynamic PVs should be built. This post will focus on static volumes for now.

### Persistent Volume Claims
    
Pods that need access to persistent storage, obtain that access through the use of a Persistent Volume Claim. A PVC, binds a persistent volume to a pod that requested it.
When a pod wants access to a persistent disk, it will request access to the claim which will specify the size , access mode and/or storage classes that it will need from a Persistent Volume. Indirectly the pods get access to the PV, but only through the use of a PVC.

### Claim Policies

We also reference claim policies earlier. A Persistent Volume can have several different claim policies associated with it including:
Retain – When the claim is deleted, the volume remains.
Recycle – When the claim is deleted the volume remains but in a state where the data can be manually recovered.
Delete – The persistent volume is deleted when the claim is deleted.
The claim policy (associated at the PV and not the PVC) is responsible for what happens to the data on when the claim has been deleted.


## In Action

<div align="center"><img src="assets/architecture-diagram.png" width="400"></div>

The database pod will use a volume claim and a persistent volume to store the database for our application.

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


```bash
$ kubectl get pv
```

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

```bash
$ kubectl get pvc
```

Great, the volume is setup and a claim ready to be used.
Now we can deploy our database pod and service.
The database pod will mount the volume via the claim and we’re specifying in our pod code,
that the volume will be mounted in the /var/lib/mysql directory so it can store our database for mysql.

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

Deploy our app.

In this example, my application container, checks to see if there is a database for the app created already.
If there is, it will use that database, if there isn’t, it will create a database on the mysql server.

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/hollow-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/hollow-deployment.yaml -->
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hollow-app
  name: hollow-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hollow-app
  strategy:
    type: Recreate
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
            - name: SECRET_KEY
              value: "my-secret-key"
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
  type: ClusterIP
  ports:
    - port: 5000
      protocol: TCP
      targetPort: 5000
  selector:
    app: hollow-app
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

Now that the app works, lets test the database resiliency.
Remember that with replica set, Kubernetes will make sure that we have a certain number of pods always running.
If one fails, it will be rebuilt.
Great when there is no state involved.
Now we have a persistent volume with our database in it.
Therefore, we should be able to kill that database pod and a new one will take its place and attach to the persistent storage.
The net result will be an outage, but when it comes back up, our data should still be there.
The diagram below demonstrates what will happen.

<div align="center"><img src="assets/disaster-diagram.png" width="600"></div>

kubectl delete pod [database pod name]
Make a gif for this command

And once I'm logged in, I can see my previous post which means my database is functioning even though its in a new pod.
The volume still stored the correct data and was re-attached to the new pod.


## References

- [Kubernetes - Persistent Volumes](https://theithollow.com/2019/03/04/kubernetes-persistent-volumes/)
