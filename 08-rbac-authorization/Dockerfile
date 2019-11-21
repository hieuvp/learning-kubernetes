FROM dtzar/helm-kubectl:2.16.1

WORKDIR /root

COPY .certificates/ca.crt .certificates/
COPY .certificates/harrison.crt .certificates/
COPY .certificates/harrison.key .certificates/

COPY labs/01-creating-users/configure-kubectl.sh 01-creating-users/
RUN chmod +x 01-creating-users/configure-kubectl.sh
RUN ./01-creating-users/configure-kubectl.sh

COPY labs/01-creating-users/test.sh 01-creating-users/
RUN chmod +x 01-creating-users/test.sh

COPY labs/02-setting-rbac-rules/test.sh 02-setting-rbac-rules/
RUN chmod +x 02-setting-rbac-rules/test.sh

COPY labs/03-playing-with-helm/test.sh 03-playing-with-helm/
RUN chmod +x 03-playing-with-helm/test.sh

# Keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
