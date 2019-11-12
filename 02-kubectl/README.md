# kubectl


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Version](#version)
- [Context](#context)
- [Imperative Object Configuration](#imperative-object-configuration)
- [Declarative Object Configuration](#declarative-object-configuration)
- [Viewing, Finding Resources](#viewing-finding-resources)
- [Interacting with Running Pods](#interacting-with-running-pods)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


> [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) is a command line interface for running commands against Kubernetes clusters.

- **Syntax**: `kubectl [command] [TYPE] [NAME] [flags]`.

- **Kubectl Reference Docs**: [https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands).

## Version

- Check for the Kubernetes **client** and **server** version information

```bash
kubectl version
kubectl version --short
```

<img src="images/kubectl-version.png" width="850">

## Context

> A [context](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context) element in a `kubeconfig` file is used to group access parameters under a convenient name. Each context has three parameters: **Cluster**, **Namespace**, and **User**.

```bash
kubectl config get-contexts
```

<img src="images/kubectl-config-get-contexts.png" width="650">

- Display the `current-context`

```bash
kubectl config current-context
```

- Set the default context to `minikube`

```bash
kubectl config use-context minikube
```

## [Imperative Object Configuration](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/#imperative-object-configuration)

- Create the objects defined in a configuration file

```bash
kubectl create --filename nginx.yaml
```

- Delete the objects defined in two configuration files

```bash
kubectl delete --filename nginx.yaml --filename redis.yaml
```

- Update the objects defined in a configuration file by **overwriting the live configuration**

```bash
kubectl replace --filename nginx.yaml
```

## [Declarative Object Configuration](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/#declarative-object-configuration)

Process all object configuration files in the `configs/` directory, and **create** or **patch** the **live objects**. You can first `diff` to see what changes are going to be made, and then `apply`.

```bash
kubectl diff --filename configs/
kubectl apply --filename configs/
```

## [Viewing, Finding Resources](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#viewing-finding-resources)

```bash
kubectl get nodes
```

<img src="images/kubectl-get-nodes.png" width="520">

```bash
kubectl get pods
```

<img src="images/kubectl-get-pods.png" width="520">

<br />

- Print a detailed description of the selected resources, including related resources such as events or controllers

```bash 
kubectl describe nodes minikube
kubectl describe pods hello-pod
```

<img src="images/kubectl-describe-pods-hello-pod.png" width="520">

## [Interacting with Running Pods](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#interacting-with-running-pods)

```bash
kubectl logs gitea-pod
```

<img src="images/kubectl-logs-gitea-pod.png" width="550">


## References
