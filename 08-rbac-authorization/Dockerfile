FROM dtzar/helm-kubectl:2.16.1

WORKDIR /root

COPY labs/01-creating-users/02-config-kubectl.sh config-kubectl.sh
RUN chmod +x config-kubectl.sh

COPY labs/01-creating-users/test.sh labs/01-creating-users-test.sh
COPY labs/02-setting-rbac-rules/test.sh labs/02-setting-rbac-rules-test.sh

COPY labs/03-playing-with-helm/init.sh labs/03-playing-with-helm-init.sh
COPY labs/03-playing-with-helm/init-with-sa.sh labs/03-playing-with-helm-init-with-sa.sh
COPY labs/03-playing-with-helm/test.sh labs/03-playing-with-helm-test.sh

RUN chmod +x labs/*.sh

# Keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
