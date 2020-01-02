# Kubernetes Secrets and ConfigMaps

> [Secrets](#secrets) and [ConfigMaps](#configmaps) behave similarly in Kubernetes,
> both in how they are created and exposed inside a container as
> [mounted files](labs/mariadb-deployment.yaml#L82) or [volumes](labs/mariadb-deployment.yaml#L67) or [environment variables](labs/mariadb-deployment.yaml#L28).

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Secrets](#secrets)
  - [Create a `Secret` using `YAML` file](#create-a-secret-using-yaml-file)
  - [Create a `Secret` using `kubectl` command](#create-a-secret-using-kubectl-command)
- [ConfigMaps](#configmaps)
  - [Create a `ConfigMap` from an existing file](#create-a-configmap-from-an-existing-file)
- [Using Secrets and ConfigMaps](#using-secrets-and-configmaps)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Secrets

- **Secrets** are intended for storing a small amount of sensitive data.
- Be sure to have appropriate **Role-based Access Controls** ([RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)) to protect access to **Secrets**.
- Extremely sensitive **Secrets** data should probably be stored using something like [HashiCorp Vault](https://www.vaultproject.io/).

### Create a `Secret` using `YAML` file

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mariadb-secret.yaml) -->
<!-- The below code snippet is automatically added from labs/mariadb-secret.yaml -->

```yaml
---
apiVersion: v1
kind: Secret

metadata:
  name: mariadb-root-password

type: Opaque

# Define key-value pairs here
# "Secrets" and "ConfigMaps" can hold more than one pair
data:
  # "Secrets" are stored base64-encoded, so they are not wildly secure

  # $ echo -n 'KubernetesRocks!' | base64
  # - n: not print the trailing newline character
  password: S3ViZXJuZXRlc1JvY2tzIQ==
```

<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ kubectl apply --filename labs/mariadb-secret.yaml
secret/mariadb-root-password created
```

```bash
$ kubectl describe secret mariadb-root-password
Name:         mariadb-root-password
Namespace:    default
Labels:       <none>
Annotations:
Type:         Opaque

Data
====
password:  16 bytes
```

```bash
$ kubectl get secret mariadb-root-password --output jsonpath='{.data.password}' | base64 --decode
KubernetesRocks!
```

### Create a `Secret` using `kubectl` command

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/create-secret.sh) -->
<!-- The below code snippet is automatically added from labs/create-secret.sh -->

```sh
#!/usr/bin/env bash
set -eoux pipefail

# generic         : create a secret from a local file, directory or literal value
# docker-registry : create a secret for use with a Docker registry
# tls             : create a TLS secret
kubectl create secret generic mariadb-user-creds \
  --from-literal=MYSQL_USER=kubeuser \
  --from-literal=MYSQL_PASSWORD=kube-still-rocks
```

<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/create-secret.sh
+ kubectl create secret generic mariadb-user-creds --from-literal=MYSQL_USER=kubeuser --from-literal=MYSQL_PASSWORD=kube-still-rocks
secret/mariadb-user-creds created
```

```bash
$ kubectl get secret mariadb-user-creds --output jsonpath='{.data.MYSQL_USER}' | base64 --decode
kubeuser
```

```bash
$ kubectl get secret mariadb-user-creds --output jsonpath='{.data.MYSQL_PASSWORD}' | base64 --decode
kube-still-rocks
```

## ConfigMaps

- **ConfigMaps** are similar to [Secrets](#secrets). They can be created by using `YAML` files or `kubectl`, and shared in the containers in the same ways.
- The only big difference between them is the **base64-encoding** obfuscation.
- **ConfigMaps** are intended for non-sensitive configuration data.
- **Config files** and **environment variables** are a great way to create customized running services from generic container images.

### Create a `ConfigMap` from an existing file

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/max_allowed_packet.cnf) -->
<!-- The below code snippet is automatically added from labs/max_allowed_packet.cnf -->

```cnf
[mysqld]
max_allowed_packet = 96M
```

<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/create-configmap.sh) -->
<!-- The below code snippet is automatically added from labs/create-configmap.sh -->

```sh
#!/usr/bin/env bash
# Run a command through "/usr/bin/env" has a benefit of
# looking for whatever the default version of the program is in your current environment

# $ /usr/bin/env bash
# Output: bash-5.0

# $ /bin/bash
# Output: bash-3.2

# Fail fast and be aware of exit codes
# @see: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail
set -eoux pipefail
# -e: any command returning a non-zero exit code will cause an immediate exit
# -o: set the exit code of a pipeline (which is a sequence of commands separated by "|" or "|&")
#     to the rightmost command that exits with a non-zero status,
#     or to zero if all commands of the pipeline exit successfully
# -u: cause the bash shell to treat unset variables as an error and exit immediately
# -x: cause the bash shell to print each command before executing it,
#     great help when debugging a failure

kubectl create configmap mariadb-config --from-file=labs/max_allowed_packet.cnf
```

<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/create-configmap.sh
+ kubectl create configmap mariadb-config --from-file=labs/max_allowed_packet.cnf
configmap/mariadb-config created
```

- By default, using `--from-file=<filename>` will store the content of the file as the **value**,
  and the name of the file will be stored as the **key**.
- However, the **key** name can be explicitly set, too.
  If you used `--from-file=max-packet=labs/max_allowed_packet.cnf` when you created the `ConfigMap`,
  the **key** would be `max-packet` rather than the file name.

```bash
$ kubectl describe configmap mariadb-config
Name:         mariadb-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
max_allowed_packet.cnf:
----
[mysqld]
max_allowed_packet = 96M

Events:  <none>
```

```bash
$ kubectl edit configmap mariadb-config

apiVersion: v1
data:
  max_allowed_packet.cnf: |
    [mysqld]
    max_allowed_packet = 96M
kind: ConfigMap
metadata:
  creationTimestamp: "2019-11-10T04:30:59Z"
  name: mariadb-config
  namespace: default
  resourceVersion: "5265"
  selfLink: /api/v1/namespaces/default/configmaps/mariadb-config
  uid: df7c1e1e-6380-405d-aabd-423721e1342f
```

```bash
$ kubectl get configmap mariadb-config --output "jsonpath={.data['max_allowed_packet\.cnf']}"
[mysqld]
max_allowed_packet = 96M
```

## Using Secrets and ConfigMaps

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mariadb-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/mariadb-deployment.yaml -->

```yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  name: mariadb
  labels:
    app: mariadb

spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb

  template:
    metadata:
      labels:
        app: mariadb

    spec:
      containers:
        - name: mariadb
          image: docker.io/mariadb:10.4

          # Add "Secrets" (or "ConfigMaps") as environment variables
          # Define a list one by one
          env:
            # Name of the environment variable that is added to the container
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  # Or "configMapKeyRef" for a "ConfigMap"
                  name: mariadb-root-password
                  key: password

          # Set environment variables from
          # all key-value pairs of a "Secret" or "ConfigMap"
          envFrom:
            # Use the "key name" as the "environment variable name"
            # and the "key value" as the "environment variable value"
            - secretRef:
                # In this case,
                # set the "MYSQL_USER" and "MYSQL_PASSWORD"
                # from the "mariadb-user-creds" Secret
                name: mariadb-user-creds

          # Ports to expose from the container
          ports:
            - containerPort: 3306
              protocol: TCP

          # Volumes to mount into the container's filesystem
          volumeMounts:
            # Create a volume mount for "mariadb-data-volume",
            # directory "/var/lib/mysql" is where the data located
            - name: mariadb-data-volume
              mountPath: /var/lib/mysql

            # Create a volume mount for "mariadb-config-volume"
            # to directory "/etc/mysql/conf.d"
            - name: mariadb-config-volume
              mountPath: /etc/mysql/conf.d

      # Both "Secrets" and "ConfigMaps" can be the source of k8s "volumes"
      # and mounted into the containers
      volumes:
        # An "emptyDir" (effectively a temporary or ephemeral) volume
        # mounted into "/var/lib/mysql" to store the MariaDB data
        - name: mariadb-data-volume
          emptyDir: {}
        # As the name says, it is initially empty
        # When a Pod is removed from a Node for any reason,
        # the data in the "emptyDir" is deleted forever

        # Add our "ConfigMap" as a source
        - name: mariadb-config-volume
          configMap:
            name: mariadb-config

            # The files we want to add into this volume
            items:
              - key: max_allowed_packet.cnf
                path: max_allowed_packet.cnf
```

<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ kubectl apply --filename labs/mariadb-deployment.yaml                                                                                                                   127 ↵
deployment.apps/mariadb created
```

```bash
$ kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
mariadb-6b7b7cdc4b-zsxjh   1/1     Running   0          112s
```

- Verify whether the **Pod** is using the **Secrets** and **ConfigMaps**:

```bash
$ kubectl exec -it mariadb-6b7b7cdc4b-zsxjh env | grep MYSQL
MYSQL_PASSWORD=kube-still-rocks
MYSQL_USER=kubeuser
MYSQL_ROOT_PASSWORD=KubernetesRocks!
```

```bash
$ kubectl exec -it mariadb-6b7b7cdc4b-zsxjh cat /etc/mysql/conf.d/max_allowed_packet.cnf
[mysqld]
max_allowed_packet = 96M
```

## References

- [An Introduction to Kubernetes Secrets and ConfigMaps](https://opensource.com/article/19/6/introduction-kubernetes-secrets-and-configmaps)
