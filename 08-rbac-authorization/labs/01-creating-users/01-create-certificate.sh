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

########################################################################
# DEVELOPER
# 1. Create an RSA Private Key if it does not exist
# 2. Create a CSR (Certificate Signing Request) from the Private Key
# 3. Send the newly created CSR to Administrator
########################################################################

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
# /CN (Common Name): K8S will interpret this value as a "User"  (e.g. harrison)
# /O (Organization): K8S will interpret this value as a "Group" (e.g. devs, tech-lead)

# Read your CSR
openssl req -verify -text -noout -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr
# -verify: verify signature on REQ
# -text: text form of REQ
# -noout: do not output REQ

########################################################################
# ADMINISTRATOR
# 1. Sign the Developer's CSR with your CA (Certificate Authority)
########################################################################

# Minikube CA (Certificate Authority)
# CA Public Certificate
cp ~/.minikube/ca.crt ${CERTIFICATE_DIR}/
# CA Private Key
cp ~/.minikube/ca.key ${CERTIFICATE_DIR}/

# An X.509 Certificate is a Digital Certificate that
# uses the widely accepted international X.509 Public Key Infrastructure (PKI) standard
# to verify that a Public Key belongs to
# the user, computer or service identity contained within the Certificate
openssl x509 -req \
  -CA ${CERTIFICATE_DIR}/ca.crt \
  -CAkey ${CERTIFICATE_DIR}/ca.key \
  -CAcreateserial \
  -days 500 \
  -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.csr \
  -out ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt
# -CAcreateserial: create serial number file (e.g. ca.srl) if it does not exist
# -days: how long till expiry of a signed certificate (default: 30 days)

# Read Developer's X.509 Certificate
openssl x509 -text -noout -purpose -in ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt
# -purpose: print out certificate purposes

########################################################################
# DEVELOPER
# 4. Download the CA Public Certificate and your generated Certificate
# ├── ca.crt
# ├── harrison.crt
# └── harrison.key
########################################################################

tree ${CERTIFICATE_DIR}

declare -r CONTAINER_NAME="rbac-authorization"
declare -r CONTAINER_USER="root"
declare -r CONTAINER_CERTIFICATE_DIR="/${CONTAINER_USER}/${CERTIFICATE_DIR}"

docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} rm -rf ${CONTAINER_CERTIFICATE_DIR}
docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} mkdir ${CONTAINER_CERTIFICATE_DIR}
docker cp ${CERTIFICATE_DIR}/ca.crt ${CONTAINER_NAME}:${CONTAINER_CERTIFICATE_DIR}
docker cp ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key ${CONTAINER_NAME}:${CONTAINER_CERTIFICATE_DIR}
docker cp ${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt ${CONTAINER_NAME}:${CONTAINER_CERTIFICATE_DIR}
docker exec -it --user=${CONTAINER_USER} ${CONTAINER_NAME} ls -lia ${CONTAINER_CERTIFICATE_DIR}
