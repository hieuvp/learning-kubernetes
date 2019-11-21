#!/usr/bin/env bash
set -eoux pipefail

# Give the user privileges to see pods in the "test" namespace
kubectl apply -f ./yaml/01-pod-access-role.yaml
kubectl apply -f ./yaml/03-devs-read-pods.yaml

# Switch to the new user and try executing these commands now
kubectl get pods
kubectl get pods --namespace=test
kubectl run --namespace=test nginx --image=nginx --replicas=2

# Now we will grant administrator access in the namespace
kubectl apply -f ./yaml/02-ns-admin-role.yaml
kubectl apply -f ./yaml/04-salme-ns-admin.yaml

# Switch to the user and let's try deploying
kubectl config use-context harrison@minikube
kubectl run nginx --namespace=test --image=nginx --replicas=2
kubectl get pods --namespace=test --watch
kubectl expose deployment nginx --namespace=test --type=NodePort --port=80
kubectl get services --namespace=test

kubectl run nginx --image=nginx --replicas=2

# Finally, we will grant the user full pod read access
kubectl config use-context minikube
kubectl apply -f ./yaml/05-all-pods-access.yaml
kubectl apply -f ./yaml/06-salme-reads-all-pods.yaml

# Test now
kubectl get pods --namespace=test
kubectl get pods
kubectl get pods --namespace=kube-system

kubectl get services
kubectl run nginx --image=nginx --replicas=2
