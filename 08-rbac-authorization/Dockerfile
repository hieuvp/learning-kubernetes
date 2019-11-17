FROM dtzar/helm-kubectl:2.16.1

WORKDIR /root

COPY certificates .certificates

COPY labs/01-creating-users/configure-kubectl.sh .
RUN chmod +x configure-kubectl.sh
RUN ./configure-kubectl.sh

# Keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
