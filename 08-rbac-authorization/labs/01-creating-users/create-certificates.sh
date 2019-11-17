#!/usr/bin/env bash
set -eoux pipefail

# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r CERT_DIR=".certificates"

# Create cert dirs
rm -rf ${CERT_DIR}
mkdir ${CERT_DIR}
cp ~/.minikube/ca.crt ${CERT_DIR}

# Private Key
openssl genrsa -out ${CERT_DIR}/harrison.key 2048
cat ${CERT_DIR}/harrison.key

# Certificate Sign Request
openssl req -new -key ${CERT_DIR}/harrison.key -out ${CERT_DIR}/harrison.csr -subj "/CN=harrison/O=devs/O=tech-lead"
cat ${CERT_DIR}/harrison.csr

# Certificate
openssl x509 -req -in ${CERT_DIR}/harrison.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${CERT_DIR}/harrison.crt -days 500
cat ${CERT_DIR}/harrison.crt

# Check the content of the certificate
openssl x509 -in ${CERT_DIR}/harrison.crt -text -noout
