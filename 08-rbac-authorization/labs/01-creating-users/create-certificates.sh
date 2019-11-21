#!/usr/bin/env bash
set -eoux pipefail

# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r OUTPUT_DIR=".certificates"
declare -r USERNAME="harrison"

# Create a clean directory to store certificates
rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR}

cp ~/.minikube/ca.crt ${OUTPUT_DIR}

# RSA is popular format use to create asymmetric key pairs those named public and private key
# Generate an RSA Private Key
openssl genrsa -out ${OUTPUT_DIR}/${USERNAME}.key 2048
openssl rsa -in .certificates/${USERNAME}.key -check

# Certificate Sign Request
openssl req -new \
  -key ${OUTPUT_DIR}/${USERNAME}.key \
  -out ${OUTPUT_DIR}/${USERNAME}.csr \
  -subj "/CN=${USERNAME}/O=devs/O=tech-lead"
cat ${OUTPUT_DIR}/${USERNAME}.csr

# Certificate
openssl x509 -req \
  -in ${OUTPUT_DIR}/${USERNAME}.csr \
  -CA ~/.minikube/ca.crt \
  -CAkey ~/.minikube/ca.key \
  -CAcreateserial \
  -out ${OUTPUT_DIR}/${USERNAME}.crt \
  -days 500
cat ${OUTPUT_DIR}/${USERNAME}.crt

# Check the content of the certificate
openssl x509 -in ${OUTPUT_DIR}/${USERNAME}.crt -text -noout
