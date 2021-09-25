# Helm


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Overview](#overview)
- [Discovering Helm](#discovering-helm)
- [-------------------------------------------------------------](#-------------------------------------------------------------)
- [Pluralsight - Installing a Local Kubernetes Cluster with Helm](#pluralsight---installing-a-local-kubernetes-cluster-with-helm)
- [IBM - Installing Helm on IBM Cloud Kubernetes Service](#ibm---installing-helm-on-ibm-cloud-kubernetes-service)
- [Pluralsight - Building Helm Charts](#pluralsight---building-helm-charts)
- [IBM - I just want to deploy!](#ibm---i-just-want-to-deploy)
- [Pluralsight - Customizing Charts with Helm Templates](#pluralsight---customizing-charts-with-helm-templates)
- [IBM - I need to change but want none of the hassle](#ibm---i-need-to-change-but-want-none-of-the-hassle)
- [Pluralsight - Managing Dependencies](#pluralsight---managing-dependencies)
- [IBM - Keeping track of the deployed application](#ibm---keeping-track-of-the-deployed-application)
- [Pluralsight - Using Existing Helm Charts](#pluralsight---using-existing-helm-charts)
- [IBM - I like sharing](#ibm---i-like-sharing)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Overview

<div align="center"><img src="assets/guestbook-ui.png" width="900"></div>
<br />

<div align="center"><img src="assets/guestbook-architecture.png" width="780"></div>
<br />

```bash
$ minikube ip
192.168.99.100
```

```bash
$ cat /etc/hosts

# Experiment - Minikube
192.168.99.100	frontend.minikube.local
192.168.99.100	backend.minikube.local
```

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/apply.sh) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/apply.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

# Database
kubectl apply --filename labs/01-without-helm/mongodb-secret.yaml
kubectl apply --filename labs/01-without-helm/mongodb-pv.yaml
kubectl apply --filename labs/01-without-helm/mongodb-pvc.yaml
kubectl apply --filename labs/01-without-helm/mongodb-deployment.yaml
kubectl apply --filename labs/01-without-helm/mongodb-service.yaml

# Backend API
kubectl apply --filename labs/01-without-helm/backend-secret.yaml
kubectl apply --filename labs/01-without-helm/backend-deployment.yaml
kubectl apply --filename labs/01-without-helm/backend-service.yaml

# Frontend
kubectl apply --filename labs/01-without-helm/frontend-config.yaml
kubectl apply --filename labs/01-without-helm/frontend-deployment.yaml
kubectl apply --filename labs/01-without-helm/frontend-service.yaml
kubectl apply --filename labs/01-without-helm/ingress.yaml
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/01-without-helm/apply.sh
+ kubectl apply --filename labs/01-without-helm/mongodb-secret.yaml
secret/mongodb-secret created
+ kubectl apply --filename labs/01-without-helm/mongodb-pv.yaml
persistentvolume/mongodb-pv created
+ kubectl apply --filename labs/01-without-helm/mongodb-pvc.yaml
persistentvolumeclaim/mongodb-pvc created
+ kubectl apply --filename labs/01-without-helm/mongodb-deployment.yaml
deployment.apps/mongodb created
+ kubectl apply --filename labs/01-without-helm/mongodb-service.yaml
service/mongodb created
+ kubectl apply --filename labs/01-without-helm/backend-secret.yaml
secret/backend-secret created
+ kubectl apply --filename labs/01-without-helm/backend-deployment.yaml
deployment.apps/backend created
+ kubectl apply --filename labs/01-without-helm/backend-service.yaml
service/backend created
+ kubectl apply --filename labs/01-without-helm/frontend-config.yaml
configmap/frontend-config created
+ kubectl apply --filename labs/01-without-helm/frontend-deployment.yaml
deployment.apps/frontend created
+ kubectl apply --filename labs/01-without-helm/frontend-service.yaml
service/frontend created
+ kubectl apply --filename labs/01-without-helm/ingress.yaml
ingress.networking.k8s.io/guestbook-ingress created
```

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/mongodb-secret.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/mongodb-secret.yaml -->
```yaml
# Filename: labs/01-without-helm/mongodb-secret.yaml
---
apiVersion: v1
kind: Secret

metadata:
  name: mongodb-secret

data:
  mongodb-username: YWRtaW4=
  mongodb-password: cGFzc3dvcmQ=
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/mongodb-pv.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/mongodb-pv.yaml -->
```yaml
# Filename: labs/01-without-helm/mongodb-pv.yaml
---
kind: PersistentVolume
apiVersion: v1

metadata:
  name: mongodb-pv
  labels:
    type: local

spec:
  storageClassName: manual

  capacity:
    storage: 100Mi

  accessModes:
    - ReadWriteOnce

  hostPath:
    path: /mnt/data
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/mongodb-pvc.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/mongodb-pvc.yaml -->
```yaml
# Filename: labs/01-without-helm/mongodb-pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim

metadata:
  name: mongodb-pvc

spec:
  storageClassName: manual

  accessModes:
    - ReadWriteOnce

  resources:
    requests:
      storage: 100Mi
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/mongodb-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/mongodb-deployment.yaml -->
```yaml
# Filename: labs/01-without-helm/mongodb-deployment.yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  name: mongodb

spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb

  template:
    metadata:
      labels:
        app: mongodb

    spec:
      containers:
        - name: mongodb
          image: mongo

          env:
            - name: MONGO_INITDB_DATABASE
              value: guestbook

            - name: MONGO_INITDB_ROOT_USERNAME
              valueFrom:
                secretKeyRef:
                  name: mongodb-secret
                  key: mongodb-username

            - name: MONGO_INITDB_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mongodb-secret
                  key: mongodb-password

          ports:
            - name: mongodb
              containerPort: 27017

          volumeMounts:
            - name: data-volume
              mountPath: /data/db

      volumes:
        - name: data-volume
          persistentVolumeClaim:
            claimName: mongodb-pvc
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/mongodb-service.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/mongodb-service.yaml -->
```yaml
# Filename: labs/01-without-helm/mongodb-service.yaml
---
apiVersion: v1
kind: Service

metadata:
  name: mongodb
  labels:
    name: mongodb

spec:
  selector:
    app: mongodb

  type: NodePort

  ports:
    - name: mongodb
      port: 27017
      targetPort: 27017

      # Port on each Node on which this Service is exposed
      nodePort: 31111
      # $ minikube service list
```
<!-- AUTO-GENERATED-CONTENT:END -->

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/backend-secret.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/backend-secret.yaml -->
```yaml
# Filename: labs/01-without-helm/backend-secret.yaml
---
apiVersion: v1
kind: Secret

metadata:
  name: backend-secret

data:
  # yamllint disable-line rule:line-length
  mongodb-uri: bW9uZ29kYjovL2FkbWluOnBhc3N3b3JkQG1vbmdvZGI6MjcwMTcvZ3Vlc3Rib29rP2F1dGhTb3VyY2U9YWRtaW4=
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/backend-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/backend-deployment.yaml -->
```yaml
# Filename: labs/01-without-helm/backend-deployment.yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  name: backend

spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend

  template:
    metadata:
      labels:
        app: backend

    spec:
      containers:
        - name: backend
          image: phico/backend:2.0
          imagePullPolicy: Always

          ports:
            - name: backend
              containerPort: 3000

          env:
            - name: MONGODB_URI
              valueFrom:
                secretKeyRef:
                  name: backend-secret
                  key: mongodb-uri
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/backend-service.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/backend-service.yaml -->
```yaml
# Filename: labs/01-without-helm/backend-service.yaml
---
apiVersion: v1
kind: Service

metadata:
  name: backend
  labels:
    name: backend

spec:
  selector:
    app: backend

  ports:
    - protocol: "TCP"
      port: 80
      targetPort: 3000
```
<!-- AUTO-GENERATED-CONTENT:END -->

<br />

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/frontend-config.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/frontend-config.yaml -->
```yaml
# Filename: labs/01-without-helm/frontend-config.yaml
---
apiVersion: v1
kind: ConfigMap

metadata:
  name: frontend-config

data:
  guestbook-name: "MyPopRock Festival 2.0"
  backend-uri: "http://backend.minikube.local/guestbook"
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/frontend-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/frontend-deployment.yaml -->
```yaml
# Filename: labs/01-without-helm/frontend-deployment.yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  name: frontend

spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend

  template:
    metadata:
      labels:
        app: frontend

    spec:
      containers:
        - name: frontend
          image: phico/frontend:2.0
          imagePullPolicy: Always

          ports:
            - name: frontend
              containerPort: 4200

          env:
            - name: GUESTBOOK_NAME
              valueFrom:
                configMapKeyRef:
                  name: frontend-config
                  key: guestbook-name

            - name: BACKEND_URI
              valueFrom:
                configMapKeyRef:
                  name: frontend-config
                  key: backend-uri
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/frontend-service.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/frontend-service.yaml -->
```yaml
# Filename: labs/01-without-helm/frontend-service.yaml
---
apiVersion: v1
kind: Service

metadata:
  name: frontend
  labels:
    name: frontend

spec:
  selector:
    app: frontend

  ports:
    - protocol: "TCP"
      port: 80
      targetPort: 4200
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/01-without-helm/ingress.yaml) -->
<!-- The below code snippet is automatically added from labs/01-without-helm/ingress.yaml -->
```yaml
# Filename: labs/01-without-helm/ingress.yaml
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress

metadata:
  name: guestbook-ingress

spec:
  rules:
    - host: frontend.minikube.local
      http:
        paths:
          - path: /
            backend:
              serviceName: frontend
              servicePort: 80

    - host: backend.minikube.local
      http:
        paths:
          - path: /
            backend:
              serviceName: backend
              servicePort: 80
```
<!-- AUTO-GENERATED-CONTENT:END -->


## Discovering Helm

> Helm is a package manager for Kubernetes.

<div align="center"><img src="assets/package-managers.png" width="580"></div>
<br />

<div align="center"><img src="assets/how-it-works.png" width="900"></div>
<br />

- **Helm client**: a command-line client for end users.
It communicates to **Tiller** through the **Helm API** (HAPI) which uses **gRPC**.

- **Tiller server**: an in-cluster server that interacts with the **Helm client**,
and interfaces with the **Kubernetes API server**.
It interacts directly with the **Kubernetes API server**
to install, upgrade, query, and remove Kubernetes resources.

<div align="center"><img src="assets/helm-v3-tiller.png" width="280"></div>
<br />

- **Chart**: contains all of the resource definitions necessary to run
an application, tool, or service inside of a Kubernetes cluster.
In short, a **Chart** is basically a package of pre-configured Kubernetes resources.

```
# Helm 3 - Chart File Structure
.
├── Chart.yaml          # A YAML file containing information about the chart
├── LICENSE             # A plain text file containing the license for the chart
├── README.md           # A human-readable README file
├── values.yaml         # The default configuration values for this chart
├── values.schema.json  # A JSON Schema for imposing a structure on the values.yaml file
├── charts/             # A directory containing any charts upon which this chart depends
├── crds/               # Custom Resource Definitions
├── templates/          # A directory of templates that, when combined with values,
|                       # will generate valid Kubernetes manifest files
├── templates/NOTES.txt # A plain text file containing short usage notes
```

- **Release**: a specific instance of a **Chart** which has been deployed to the Kubernetes cluster using **Helm**.

- **Repository**: a place where published **Charts** reside and can be shared with others.


## -------------------------------------------------------------


## Pluralsight - Installing a Local Kubernetes Cluster with Helm

## IBM - Installing Helm on IBM Cloud Kubernetes Service


## Pluralsight - Building Helm Charts

## IBM - I just want to deploy!


## Pluralsight - Customizing Charts with Helm Templates

## IBM - I need to change but want none of the hassle


## Pluralsight - Managing Dependencies

## IBM - Keeping track of the deployed application


## Pluralsight - Using Existing Helm Charts

## IBM - I like sharing


## References

- [Packaging Applications with Helm for Kubernetes](https://app.pluralsight.com/library/courses/packaging-applications-helm-kubernetes/table-of-contents)
- [Source Code for Labs](https://github.com/phcollignon/helm)
- [IBM Helm 101](https://github.com/IBM/helm101/tree/master/tutorial)
- [Kubernetes Helm 101](https://www.aquasec.com/wiki/display/containers/Kubernetes+Helm+101)
