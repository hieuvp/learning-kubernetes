#!/usr/bin/env bash
set -eoux pipefail

# "declare" is a built-in command of the Bash shell
# It declares shell variables and functions,
# sets their attributes, and displays their values
# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"
# -r: make the named items read-only,
# they cannot subsequently be reassigned values or unset

# Create a clean directory to store certificates
rm -rf ${CERTIFICATE_DIR}
mkdir ${CERTIFICATE_DIR}

#####################################################################
# Developer
# 1. Create an RSA Private Key if it does not exist
# 2. Create a CSR (Certificate Signing Request) from the Private Key
# 3. Send the newly created CSR to Administrator
#####################################################################

# RSA is a popular format use to create asymmetric key pairs
# those named Public Key and Private Key
openssl genrsa -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key 2048

# Read your RSA Private Key
openssl rsa -check -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key
# -check: verify key consistency

# The CSR (Certificate Signing Request) is created using the PEM format
# and contains the Public Key portion of the Private Key
# as well as information about you (or your company)
openssl req -new \
  -key ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -subj "/CN=${CERTIFICATE_USER}/O=devs/O=tech-lead"
# -subj: set or modify request subject
# /CN (Common Name): Kubernetes will interpret this value as a "User"
# /O (Organization): Kubernetes will interpret this value as a "Group"

# Read your CSR
openssl req -text -noout -verify -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr
# -text: text form of request
# -noout: do not output REQ
# -verify: verify signature on REQ

########################################################################
# Administrator
# 1. Create a certificate from the CSR using the Certificate Authority
########################################################################

# Certificate Authority (CA)
# Public Certificate
cp ~/.minikube/ca.crt ${CERTIFICATE_DIR}/
# Private Key
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
docker cp ${CERTIFICATE_DIR}/ca.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
docker cp ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt ${CONTAINER_NAME}:/${CONTAINER_USER}/${CERTIFICATE_DIR}
