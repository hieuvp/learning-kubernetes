#!/usr/bin/env bash
set -eoux pipefail

# declare: is a built-in command of the Bash shell
# It declares shell variables and functions, sets their attributes, and displays their values
# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r CERTIFICATE_OUTPUT_DIR=".certificates"
declare -r CERTIFICATE_USERNAME="harrison"
declare -r CONTAINER_NAME="rbac-authorization"
declare -r CONTAINER_USER="root"

# Create a clean directory to store certificates
rm -rf ${CERTIFICATE_OUTPUT_DIR}
mkdir ${CERTIFICATE_OUTPUT_DIR}

# RSA is popular format use to create asymmetric key pairs those named public and private key
# 1. Generate an RSA private key
openssl genrsa -out ${CERTIFICATE_OUTPUT_DIR}/${CERTIFICATE_USERNAME}.key 2048

# Read your RSA private key
openssl rsa -in .certificates/${CERTIFICATE_USERNAME}.key -check

# The CSR (or Certificate Signing Request) is created using the PEM format
# and contains the public key portion of the private key
# as well as information about you (or your company)
# 2. Generate a CSR from the private key
openssl req -new \
  -key ${CERTIFICATE_OUTPUT_DIR}/${CERTIFICATE_USERNAME}.key \
  -out ${CERTIFICATE_OUTPUT_DIR}/${CERTIFICATE_USERNAME}.csr \
  -subj "/CN=${CERTIFICATE_USERNAME}/O=devs/O=tech-lead"
# CN : Common Name
# O  : Organization

# Read your Certificate Signing Request
openssl req -text -noout -verify -in ${CERTIFICATE_OUTPUT_DIR}/${CERTIFICATE_USERNAME}.csr

# Certificate Authority (CA)
# ca.crt: the certificate file
# ca.key: the RSA private key
cp ~/.minikube/ca.crt ${CERTIFICATE_OUTPUT_DIR}/
cp ~/.minikube/ca.key ${CERTIFICATE_OUTPUT_DIR}/

# An X.509 certificate is a digital certificate
# that uses the widely accepted international X.509 public key infrastructure (PKI) standard
# to verify that a public key belongs to
# the user, computer or service identity contained within the certificate
# 3. Sign your CSR with minikube CA
openssl x509 -req \
  -in ${CERTIFICATE_OUTPUT_DIR}/${CERTIFICATE_USERNAME}.csr \
  -out ${CERTIFICATE_OUTPUT_DIR}/${CERTIFICATE_USERNAME}.crt \
  -CA ${CERTIFICATE_OUTPUT_DIR}/ca.crt \
  -CAkey ${CERTIFICATE_OUTPUT_DIR}/ca.key \
  -CAcreateserial \
  -days 500
# CAcreateserial: this option will create a file (ca.srl) containing a serial number

# Read X509 Certificate
# Print Certificate Purpose
openssl x509 -in ${CERTIFICATE_OUTPUT_DIR}/${CERTIFICATE_USERNAME}.crt -text -noout -purpose

tree ${CERTIFICATE_OUTPUT_DIR}

docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} rm -rf /${CONTAINER_USER}/${CERTIFICATE_OUTPUT_DIR}
docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} mkdir /${CONTAINER_USER}/${CERTIFICATE_OUTPUT_DIR}
docker cp .certificates/harrison.key ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_OUTPUT_DIR}
docker cp .certificates/harrison.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_OUTPUT_DIR}
docker cp .certificates/ca.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_OUTPUT_DIR}
