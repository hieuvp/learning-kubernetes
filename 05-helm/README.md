# Helm


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Introduction](#introduction)
- [Discovering HELM](#discovering-helm)
  - [Helm Terms](#helm-terms)
- [Installing a Local Kubernetes Cluster with Helm](#installing-a-local-kubernetes-cluster-with-helm)
- [Building Helm Charts](#building-helm-charts)
- [Customizing Charts with Helm Templates](#customizing-charts-with-helm-templates)
- [Managing Dependencies](#managing-dependencies)
- [Using Existing Helm Charts](#using-existing-helm-charts)
- [Installing Helm on IBM Cloud Kubernetes Service](#installing-helm-on-ibm-cloud-kubernetes-service)
- [I just want to deploy!](#i-just-want-to-deploy)
- [I need to change but want none of the hassle](#i-need-to-change-but-want-none-of-the-hassle)
- [Keeping track of the deployed application](#keeping-track-of-the-deployed-application)
- [I like sharing](#i-like-sharing)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Introduction

<div align="center"><img src="assets/guestbook-application-ui.png" width="900"></div>

<div align="center"><img src="assets/guestbook-application-architecture.png" width="800"></div>

```bash
$ minikube ip

192.168.99.105
```

```bash
$ cat /etc/hosts

# Lab - Guestbook Application
192.168.99.105	frontend.minikube.local
192.168.99.105	backend.minikube.local
```

```bash
$ minikube addons enable ingress
```

```bash
$ cd labs/01-without-helm

$ kubectl apply --filename backend-secret.yaml
$ kubectl apply --filename backend-service.yaml
$ kubectl apply --filename backend.yaml

$ kubectl apply --filename frontend-configmap.yaml
$ kubectl apply --filename frontend-service.yaml
$ kubectl apply --filename frontend.yaml

$ kubectl apply --filename ingress.yaml

$ kubectl apply --filename mongodb-persistent-volume.yaml
$ kubectl apply --filename mongodb-persistent-volume-claim.yaml
$ kubectl apply --filename mongodb-secret.yaml
$ kubectl apply --filename mongodb-service.yaml
$ kubectl apply --filename mongodb.yaml
```


## Discovering HELM

> Helm is a package manager for Kubernetes.

<div align="center"><img src="assets/package-managers.png" width="600"></div>
<br />

<div align="center"><img src="assets/how-it-works.png" width="800"></div>
<br />

### Helm Terms

- Chart: It contains all of the resource definitions necessary to run an application, tool, or service inside of a Kubernetes cluster. A chart is basically a package of pre-configured Kubernetes resources.
- Config: Contains configuration information that can be merged into a packaged chart to create a releasable object.
- helm: Helm client. Communicates to Tiller through the Helm API - HAPI which uses gRPC.
- Release: An instance of a chart running in a Kubernetes cluster.
- Repository: Place where charts reside and can be shared with others.
- Tiller: Helm server. It interacts directly with the Kubernetes API server to install, upgrade, query, and remove Kubernetes resources.

Helm is organized around several key concepts:
- A **chart** is a package of pre-configured Kubernetes resources.
- A **release** is a specific instance of a chart which has been deployed to the cluster using Helm.
- A **repository** is a group of published charts which can be made available to others.

- **The Helm Client** is a command-line client for end users.
- **The Tiller Server** is an in-cluster server that interacts with the Helm client, and interfaces with the Kubernetes API server.


## Installing a Local Kubernetes Cluster with Helm


## Building Helm Charts


## Customizing Charts with Helm Templates


## Managing Dependencies


## Using Existing Helm Charts


## Installing Helm on IBM Cloud Kubernetes Service


## I just want to deploy!


## I need to change but want none of the hassle


## Keeping track of the deployed application


## I like sharing


## References

- [Packaging Applications with Helm for Kubernetes](https://app.pluralsight.com/library/courses/packaging-applications-helm-kubernetes/table-of-contents)
- [Source Code for Labs](https://github.com/phcollignon/helm)
- [IBM Helm 101](https://github.com/IBM/helm101/tree/master/tutorial)
- [Kubernetes Helm 101](https://www.aquasec.com/wiki/display/containers/Kubernetes+Helm+101)
