#!/usr/bin/env bash
set -eoux pipefail

# "declare" is a built-in command of the Bash shell
# It declares shell variables and functions,
# sets their attributes, and displays their values
# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"
# -r: make the named items read-only, they cannot subsequently be assigned values or unset

# Create a clean directory to store certificates
rm -rf ${CERTIFICATE_DIR}
mkdir ${CERTIFICATE_DIR}

#####################################################################
# Developer
# 1. Create an RSA private key if it does not exist
# 2. Create a CSR (Certificate Signing Request) from the private key
# 3. Send the CSR to the Administrator
#####################################################################

# RSA is popular format use to create asymmetric key pairs those named public and private key
openssl genrsa -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key 2048

# Read your RSA private key
openssl rsa -in .certificates/${CERTIFICATE_USER}.key -check

# The CSR (or Certificate Signing Request) is created using the PEM format
# and contains the public key portion of the private key
# as well as information about you (or your company)
openssl req -new \
  -key ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -subj "/CN=${CERTIFICATE_USER}/O=devs/O=tech-lead"
# Common Name (CN): Kubernetes will interpret this value as the User
# Organization (O): Kubernetes will interpret this value as the Group

# Read your Certificate Signing Request
openssl req -text -noout -verify -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr

#####################################################################
# Administrator
# 1. Create a certificate from the CSR using the Cluster Authority
#####################################################################

# Certificate Authority (CA)
# ca.crt: public certificate
cp ~/.minikube/ca.crt ${CERTIFICATE_DIR}/
# ca.key: private key
cp ~/.minikube/ca.key ${CERTIFICATE_DIR}/
# Every SSL certificate signed with this CA will be accepted by the Kubernetes API

# An X.509 certificate is a digital certificate
# that uses the widely accepted international X.509 public key infrastructure (PKI) standard
# to verify that a public key belongs to
# the user, computer or service identity contained within the certificate
# 3. Sign your CSR with minikube CA
openssl x509 -req \
  -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt \
  -CA ${CERTIFICATE_DIR}/ca.crt \
  -CAkey ${CERTIFICATE_DIR}/ca.key \
  -CAcreateserial \
  -days 500
# CAcreateserial: this option will create a file (ca.srl) containing a serial number

# Read X509 Certificate
# Print Certificate Purpose
openssl x509 -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt -text -noout -purpose

#####################################################################
# Developer
# 4. Download the Cluster Authority and generated certificate
#####################################################################

tree ${CERTIFICATE_DIR}

declare -r CONTAINER_NAME="rbac-authorization"
declare -r CONTAINER_USER="root"

docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} rm -rf /${CONTAINER_USER}/${CERTIFICATE_DIR}
docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} mkdir /${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp .certificates/harrison.key ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp .certificates/harrison.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp .certificates/ca.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
