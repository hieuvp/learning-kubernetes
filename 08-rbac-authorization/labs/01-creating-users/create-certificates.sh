#!/usr/bin/env bash
set -eoux pipefail

# @see: https://www.computerhope.com/unix/bash/declare.htm
declare -r OUTPUT_DIR=".certificates"
declare -r USERNAME="harrison"

# Create a clean directory to store certificates
rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR}

# RSA is popular format use to create asymmetric key pairs those named public and private key
# Generate an RSA private key
openssl genrsa -out ${OUTPUT_DIR}/${USERNAME}.key 2048

# Read your RSA private key
openssl rsa -in .certificates/${USERNAME}.key -check

# The CSR (or Certificate Signing Request) is created using the PEM format
# and contains the public key portion of the private key
# as well as information about you (or your company)
openssl req -new \
  -key ${OUTPUT_DIR}/${USERNAME}.key \
  -out ${OUTPUT_DIR}/${USERNAME}.csr \
  -subj "/CN=${USERNAME}/O=devs/O=tech-lead"

# Read your Certificate Signing Request
openssl req -text -noout -verify -in ${OUTPUT_DIR}/${USERNAME}.csr

# Certificate Authority (CA)
# ca.crt: the certificate file
# ca.key: the RSA private key
cp ~/.minikube/ca.crt ${OUTPUT_DIR}/
cp ~/.minikube/ca.key ${OUTPUT_DIR}/

# An X.509 certificate is a digital certificate
# that uses the widely accepted international X.509 public key infrastructure (PKI) standard
# to verify that a public key belongs to
# the user, computer or service identity contained within the certificate
# To sign your CSR with minikube CA
openssl x509 -req \
  -in ${OUTPUT_DIR}/${USERNAME}.csr \
  -CA ${OUTPUT_DIR}/ca.crt \
  -CAkey ${OUTPUT_DIR}/ca.key \
  -CAcreateserial \
  -out ${OUTPUT_DIR}/${USERNAME}.crt \
  -days 500

# Read X509 Certificate
# Print Certificate Purpose
openssl x509 -in ${OUTPUT_DIR}/${USERNAME}.crt -text -noout -purpose
