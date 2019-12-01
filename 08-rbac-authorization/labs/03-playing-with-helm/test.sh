#!/usr/bin/env bash
set -x pipefail

# Try deploying a dokuwiki chart
kubectl config use-context harrison@minikube
helm install stable/dokuwiki --namespace=test

# We need to grant some extra permissions for harrison to access tiller
kubectl apply --filename 01-helm-tiller-access.yaml
kubectl apply --filename 02-harrison-use-tiller.yaml

# Try now
kubectl config use-context harrison@minikube
helm list
helm install stable/dokuwiki --namespace=test
kubectl get pods --namespace=test --watch

helm install stable/dokuwiki
kubectl run --image=bitnami/dokuwiki dokuwiki
kubectl get pods
helm install stable/dokuwiki --namespace=kube-system

# Let's delete tiller
helm reset --force
helm init

# Let's try now
helm list
kubectl config use-context harrison@minikube
helm install stable/dokuwiki

# Let's fix this
kubectl apply --filename 03-tiller-serviceaccount.yaml
kubectl apply --filename 04-tiller-clusterrolebinding.yaml

# Redeploy helm
# Update the tiller pod
helm init --upgrade --service-account tiller-sa

# Let's check if Tiller works now
helm list
