FROM dtzar/helm-kubectl:2.16.1

WORKDIR /root

COPY certificates .certificates

# Add new kubectl context
ARG MINIKUBE_IP=192.168.99.101

RUN kubectl config set-cluster minikube \
    --certificate-authority=.certificates/ca.crt \
    --embed-certs=true \
    --server=https://${MINIKUBE_IP}:8443

RUN kubectl config set-credentials harrison@minikube \
    --client-certificate=.certificates/harrison.crt \
    --client-key=.certificates/harrison.key \
    --embed-certs=true

RUN kubectl config set-context harrison@minikube \
    --cluster=minikube \
    --user=harrison@minikube

# Set new context
RUN kubectl config use-context harrison@minikube

# Keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
