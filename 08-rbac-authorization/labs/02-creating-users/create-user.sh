#!/usr/bin/env bash
set -eoux pipefail

## Create cert dirs
mkdir -p ~/.certs/kubernetes/minikube/

## Private key
openssl genrsa -out ~/.certs/kubernetes/minikube/harrison.key 2048

## Certificate sign request
openssl req -new -key ~/.certs/kubernetes/minikube/harrison.key -out /tmp/harrison.csr -subj "/CN=harrison/O=devs/O=tech-lead"

## Certificate
openssl x509 -req -in /tmp/harrison.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ~/.certs/kubernetes/minikube/harrison.crt -days 500

# Check the content of the certificate
openssl x509 -in "$HOME/.certs/kubernetes/minikube/harrison.crt" -text -noout

# Add new kubectl context

# This one is not necessary
# MINIKUBE_IP=$(minikube ip)
# kubectl config set-cluster minikube --certificate-authority=$HOME/.certs/kubernetes/minikube/ca.crt --embed-certs=true --server=https://${MINIKUBE_IP}:6443

kubectl config set-credentials harrison@minikube --client-certificate="$HOME/.certs/kubernetes/minikube/harrison.crt" --client-key="$HOME/.certs/kubernetes/minikube/harrison.key" --embed-certs=true

kubectl config set-context harrison@minikube --cluster=minikube --user=harrison@minikube

# Set new context
kubectl config use-context harrison@minikube

# Try
kubectl get pods
