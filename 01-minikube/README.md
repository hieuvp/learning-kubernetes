# Minikube

> Local Kubernetes, focused on application development & education.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Dashboard](#dashboard)
- [Service](#service)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Dashboard

```bash
$ minikube dashboard
```

<div align="center"><img src="assets/minikube-dashboard.png" width="900"></div>


## Service

- List the URLs for the services in your local cluster

```bash
$ minikube service list
```

<img src="assets/minikube-service-list.png" width="500">

- Access a service exposed via a [`NodePort`](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)

	- `--url`: Display the Kubernetes service URL in the CLI instead of opening it in the default browser.

```bash
minikube service [--namespace NAMESPACE] [--url] NAME
```

```bash
minikube addons enable ingress
kubectl version --short

minikube ip
minikube ssh
```


## References

- [minikube](https://github.com/kubernetes/minikube)
