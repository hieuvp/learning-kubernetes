# Helm


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Pluralsight - Installing a Local Kubernetes Cluster with Helm](#pluralsight---installing-a-local-kubernetes-cluster-with-helm)
- [IBM - Installing Helm on IBM Cloud Kubernetes Service](#ibm---installing-helm-on-ibm-cloud-kubernetes-service)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Pluralsight - Installing a Local Kubernetes Cluster with Helm


PluralSight Packaging applications with Helm for Kubernetes
 
Please follow instruction in module : Installing Kubernetes and Helm

Here bellow are the commands to be launched :

Minikube installation

```
curl -o minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo cp minikube /usr/local/bin/minikube
minikube version
minikube start
```

Helm installation

```
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.14.3-linux-amd64.tar.gz
tar -zxvf helm-v2.14.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

helm version --short
kubectl config view
helm init
helm version --short
kubectl get all --namespace=kube-system -l name=tiller
helm create nginx-demo
helm install nginx-demo
kubectl get all | grep nginx-demo
```

Helm local tiller

```
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.14.3-linux-amd64.tar.gz 
tar -zxvf helm-v2.14.3-linux-amd64.tar.gz
sudo mv linux-amd64/tiller /usr/local/bin/tiller
tiller

sudo mv linux-amd64/helm /usr/local/bin/helm
helm init --client-only
export HELM_HOME=/home/$(whoami)/.helm
helm version --short
export HELM_HOST=localhost:44134
helm version --short

helm create nginx-localtiller-demo
helm install nginx-localtiller-demo
kubectl get all | grep localtiller
kubectl get pod --namespace=kube-system -l name=tiller
kubectl get configmaps --namespace=kube-system
```

Helm delete

```
helm list
helm delete calling-horse
kubectl get configmaps --namespace=kube-system
helm delete calling-horse --purge
helm reset
```


## IBM - Installing Helm on IBM Cloud Kubernetes Service

There are two parts to installing Helm: the client (helm) and the server (Tiller).

`helm help`

Installing the Helm Server (Tiller)

Run the command: `$ helm init`. This will initialize the Helm CLI and also install Tiller into the Kubernetes cluster under the tiller-namespace.

You can verify that the client and server are installed correctly by running the command, helm version. This should return both the client and server versions. Refer to the doc installing Tiller for more details.


## References

- [Packaging Applications with Helm for Kubernetes](https://app.pluralsight.com/library/courses/packaging-applications-helm-kubernetes/table-of-contents)
