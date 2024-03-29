# Kubernetes Debugging

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Feature Gates](#feature-gates)
- [Debugging With An Ephemeral Debug Container](#debugging-with-an-ephemeral-debug-container)
- [Debugging Using A Copy Of The Pod](#debugging-using-a-copy-of-the-pod)
- [Debugging `CrashLoopBackOff` Application](#debugging-crashloopbackoff-application)
- [Debugging Cluster Node](#debugging-cluster-node)
- [Alternative Debugging Approaches](#alternative-debugging-approaches)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Feature Gates

Kubernetes alpha/experimental features can be enabled or disabled
by the `--feature-gates` flag on the `minikube start` command.

```shell
minikube start --driver=virtualbox --feature-gates=EphemeralContainers=true
```

## Debugging With An Ephemeral Debug Container

`$ kubectl debug` allows us to debug running pods.<br />
It injects special type of container called **Ephemeral Container** into problematic pod.

<br />

```shell
$ kubectl run some-app --image=k8s.gcr.io/pause:3.1 --restart=Never
pod/some-app created

$ kubectl debug -it some-app --image=busybox --target=some-app
Defaulting debug container name to debugger-thsvx.
If you don't see a command prompt, try pressing enter.

/ # id
uid=0(root) gid=0(root) groups=10(wheel)
```

- `-it` these two parameters are responsible for keeping the stdin open and allocating a TTY.
- `--image` is the name of the image for the ephemeral container.
- `--target` lets the ephemeral container targeting processes
  in the defined container name inside a pod.

<br />

```shell
kubectl describe pod some-app
```

![Describe Pod](assets/describe-pod.png)

<br />

```shell
$ kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
some-app   1/1     Running   0          8m10s

$ kubectl delete pod some-app
pod "some-app" deleted
```

## Debugging Using A Copy Of The Pod

```shell
$ kubectl run some-app --image=nginx --restart=Never
pod/some-app created
```

<br />

```shell
kubectl debug -it some-app --image=busybox --share-processes --copy-to=some-app-debug
```

<div align="center"><img src="assets/debug-pod.png" width="860"></div>

- `--share-processes`: when used with `--copy-to`,
  enable **process namespace sharing** in the copy.
- `--copy-to`: create a copy of the target pod with this name.

<br />

```shell
$ kubectl get pods
NAME             READY   STATUS     RESTARTS   AGE
some-app         1/1     Running    0          5m19s
some-app-debug   1/2     NotReady   0          5m2s
```

The new debug pod has 2 containers in comparison
to the original one as it also includes the ephemeral container.

<br />

```shell
$ kubectl get pod some-app-debug -o json | jq .spec.shareProcessNamespace
true
```

To verify whether the process sharing is allowed in a pod.

<br />

```shell
$ kubectl delete pod some-app some-app-debug
pod "some-app" deleted
pod "some-app-debug" deleted
```

## Debugging `CrashLoopBackOff` Application

A common situation is that application keeps crashing upon container start,
making it difficult to debug as there's not enough time to get shell session
into the container and run some troubleshooting commands.<br />
In this case, the solution would be
to create a new container with different entry point (or command),
which would stop the application from crashing immediately
and allowing us to perform debugging.

<br />

```shell
$ kubectl run crashing-app --image=mikephammer/crashloopbackoff
pod/crashing-app created

$ kubectl get pods
NAME           READY   STATUS             RESTARTS   AGE
crashing-app   0/1     CrashLoopBackOff   1          38s
```

<br />

```shell
$ kubectl debug crashing-app -it --copy-to=crashing-app-debug --container=crashing-app -- sh
If you don't see a command prompt, try pressing enter.

/ # id
uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),11(floppy),20(dialout),26(tape),27(video)
```

1. Create a copy of `crashing-app` pod.
2. Change the command of `crashing-app` container to `sh`.

<br />

```shell
$ kubectl get pods
NAME                 READY   STATUS             RESTARTS   AGE
crashing-app         0/1     CrashLoopBackOff   4          2m34s
crashing-app-debug   1/1     Running            1          82s

$ kubectl delete pod crashing-app crashing-app-debug
pod "crashing-app" deleted
pod "crashing-app-debug" deleted
```

## Debugging Cluster Node

`$ kubectl debug` allows for debugging of nodes
by creating pod that will run on specified node with node's root filesystem mounted.
This essentially acts as an SSH connection into node,
considering that we can even use `$ chroot` to get access to host binaries.

<br />

```shell
$ kubectl get nodes
NAME       STATUS   ROLES                  AGE   VERSION
minikube   Ready    control-plane,master   23m   v1.20.2

$ kubectl debug node/minikube -it --image=ubuntu
Creating debugging pod node-debugger-minikube-45hqx with container debugger on node minikube.
If you don't see a command prompt, try pressing enter.

root@minikube:/# ls /host
Users  data  etc   init  lib64    linuxrc  mnt  preloaded.tar.lz4  root  sbin  sys  usr
bin    dev   home  lib   libexec  media    opt  proc               run   srv   tmp  var

root@minikube:/# chroot /host

sh-5.0# pwd
/

sh-5.0# ls
Users  data  etc   init  lib64	  linuxrc  mnt	preloaded.tar.lz4  root  sbin  sys  usr
bin    dev   home  lib	 libexec  media    opt	proc		   run	 srv   tmp  var
```

- `$ chroot`: run commands with a special root directory.
- When get attached to the pod,
  we use `$ chroot /host` to break out of jail and gain full access to the host.

## Alternative Debugging Approaches

If, for whatever reason, enabling **Ephemeral Containers** is not an option, then try to:

- Use debug version of application image which would include troubleshooting tools.
- Temporarily change pod's container's command directive to stop it from crashing.

## References

- [The Easiest Way to Debug Kubernetes Workloads](https://towardsdatascience.com/the-easiest-way-to-debug-kubernetes-workloads-ff2ff5e3cc75)
- [Debug Running Pods](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/)
