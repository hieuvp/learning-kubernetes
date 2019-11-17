#!/usr/bin/env bash
set -eoux pipefail

## Add new kubectl context
#
## This one is not necessary
## MINIKUBE_IP=$(minikube ip)
## kubectl config set-cluster minikube --certificate-authority=$HOME/.certs/kubernetes/minikube/ca.crt --embed-certs=true --server=https://${MINIKUBE_IP}:6443
#
#kubectl config set-credentials harrison@minikube --client-certificate="$HOME/.certs/kubernetes/minikube/harrison.crt" --client-key="$HOME/.certs/kubernetes/minikube/harrison.key" --embed-certs=true
#
#kubectl config set-context harrison@minikube --cluster=minikube --user=harrison@minikube
#
## Set new context
#kubectl config use-context harrison@minikube
#
## Try
#kubectl get pods
