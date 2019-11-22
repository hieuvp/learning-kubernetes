#!/usr/bin/env bash
set -x pipefail

# Try deploying a dokuwiki chart
kubectl config use-context harrison@minikube
helm install stable/dokuwiki --namespace=test

# We need to grant some extra permissions for harrison to access tiller
kubectl config use-context minikube
kubectl apply -f ./yaml/07-helm-tiller-access.yaml
kubectl apply -f ./yaml/08-salme-use-tiller.yaml

# Try now
kubectl config use-context harrison@minikube
helm ls
helm install stable/dokuwiki --namespace=test
kubectl get pods --namespace=test --watch

helm install stable/dokuwiki
kubectl run --image=bitnami/dokuwiki dokuwiki
kubectl get pods
helm install stable/dokuwiki --namespace=kube-system

# Let's delete tiller
kubectl config use-context minikube
helm reset --force
helm init

# Let's try now
helm ls
kubectl config use-context harrison@minikube
helm install stable/dokuwiki

# Let's fix this
kubectl config use-context minikube
kubectl create serviceaccount tiller-sa --namespace=kube-system
kubectl apply -f yaml/09-tiller-clusterrolebinding.yaml

# Redeploy helm
helm init --upgrade --service-account tiller-sa