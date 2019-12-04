# kubectl

> `kubectl` is a command line interface for running commands against Kubernetes clusters.

<br />

```bash
$ kubectl [command] [TYPE] [NAME] [flags]
```


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


## Version

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.2", GitCommit:"c97fe5036ef3df2967d086711e6c0c405941e14b", GitTreeState:"clean", BuildDate:"2019-10-15T23:42:50Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.2", GitCommit:"c97fe5036ef3df2967d086711e6c0c405941e14b", GitTreeState:"clean", BuildDate:"2019-10-15T19:09:08Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64"}
```

```bash
$ kubectl version --short
Client Version: v1.16.2
Server Version: v1.16.2
```


## Context

> A `context` element in a `kubeconfig` file
> is used to group access parameters under a convenient name.
> Each context has three parameters: `cluster`, `user`, and `namespace`.

```bash
$ kubectl config get-contexts
```

<img src="assets/kubectl-config-get-contexts.png" width="650">

<br />

```bash
# Display the "current-context"

$ kubectl config current-context
minikube
```

<br />

```bash
# Set the default context to "minikube"

$ kubectl config use-context minikube
Switched to context "minikube".
```


## [Imperative Object Configuration](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/#imperative-object-configuration)

- Create the objects defined in a configuration file

```bash
$ kubectl create --filename nginx.yaml
```

- Delete the objects defined in two configuration files

```bash
$ kubectl delete --filename nginx.yaml --filename redis.yaml
```

- Update the objects defined in a configuration file by **overwriting the live configuration**

```bash
$ kubectl replace --filename nginx.yaml
```


## [Declarative Object Configuration](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/#declarative-object-configuration)

Process all object configuration files in the `configs/` directory, and **create** or **patch** the **live objects**. You can first `diff` to see what changes are going to be made, and then `apply`.

```bash
$ kubectl diff --filename configs/
$ kubectl apply --filename configs/
```


## [Viewing, Finding Resources](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#viewing-finding-resources)

```bash
$ kubectl get nodes
```

<img src="assets/kubectl-get-nodes.png" width="520">

```bash
$ kubectl get pods
```

<img src="assets/kubectl-get-pods.png" width="520">

<br />

- Print a detailed description of the selected resources, including related resources such as events or controllers

```bash 
$ kubectl describe nodes minikube
$ kubectl describe pods hello-pod
```

<img src="assets/kubectl-describe-pods-hello-pod.png" width="520">


## [Interacting with Running Pods](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#interacting-with-running-pods)

```bash
$ kubectl logs gitea-pod
```

<img src="assets/kubectl-logs-gitea-pod.png" width="550">


## References

- [Kubectl Reference Docs](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
