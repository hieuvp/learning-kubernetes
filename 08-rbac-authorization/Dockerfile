FROM dtzar/helm-kubectl:2.16.1

WORKDIR /root

COPY labs/01-creating-users/02-configure-kubectl.sh labs/01-creating-users/
COPY labs/01-creating-users/test.sh labs/01-creating-users/

COPY labs/02-setting-rbac-rules/test.sh labs/02-setting-rbac-rules/

COPY labs/03-playing-with-helm/test.sh labs/03-playing-with-helm/

RUN chmod +x labs/**/*.sh

# Keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
