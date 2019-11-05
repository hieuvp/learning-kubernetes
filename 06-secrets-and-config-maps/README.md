# Kubernetes Secrets and ConfigMaps

> Kubernetes has two types of objects that can inject configuration data into a container when it starts up: Secrets and ConfigMaps.
> Secrets and ConfigMaps behave similarly in Kubernetes,
> both in how they are created and because they can be exposed inside a container as mounted files or volumes or environment variables.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Secrets](#secrets)
  - [Create a `Secret` using `YAML` file](#create-a-secret-using-yaml-file)
  - [Create a `Secret` using `kubectl` command](#create-a-secret-using-kubectl-command)
- [ConfigMaps](#configmaps)
  - [Create a ConfigMap from an existing file](#create-a-configmap-from-an-existing-file)
- [Using Secrets and ConfigMaps](#using-secrets-and-configmaps)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

scenario:

You're running the official MariaDB container image in Kubernetes and must do some configuration to get the container to run.
The image requires an environment variable to be set for MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD, or MYSQL_RANDOM_ROOT_PASSWORD to initialize the database.
It also allows for extensions to the MySQL configuration file my.cnf by placing custom config files in /etc/mysql/conf.d.

This is a perfect use-case for ConfigMaps and Secrets.
The MYSQL_ROOT_PASSWORD can be set in a Secret and added to the container as an environment variable,
and the configuration files can be stored in a ConfigMap and mounted into the container as a file on startup.

This exercise explained how to create Kubernetes Secrets and ConfigMaps
and how to use those Secrets and ConfigMaps by adding them as environment variables or files
inside of a running container instance.
This makes it easy to keep the configuration of individual instances of containers
separate from the container image.
By separating the configuration data, overhead is reduced to maintaining only
a single image for a specific type of instance while retaining
the flexibility to create instances with a wide variety of configurations.


```bash
$ kubectl config current-context
minikube

$ kubectl version --short
Client Version: v1.16.2
Server Version: v1.16.2
```


## Secrets

> Secrets are a Kubernetes object intended for storing a small amount of sensitive data.
> Make sure to have appropriate role-based access controls (RBAC) to protect access to Secrets.
> Even so, extremely sensitive Secrets data should probably be stored using something like HashiCorp Vault.

### Create a `Secret` using `YAML` file

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mysql-secret.yaml) -->
<!-- The below code snippet is automatically added from labs/mysql-secret.yaml -->
```yaml
---
apiVersion: v1
kind: Secret

metadata:
  name: mariadb-root-password

type: Opaque

# Define key-value pairs here
# "Secrets" (or "ConfigMaps") can hold more than one pair
data:
  # "Secrets" are stored base64-encoded, so they are not wildly secure

  # $ echo -n 'KubernetesRocks!' | base64
  # - n: not print the trailing newline character
  password: S3ViZXJuZXRlc1JvY2tzIQ==
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ kubectl apply --filename labs/mysql-secret.yaml
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
$ kubectl get secret mariadb-root-password --output jsonpath='{.data.password}' | base64 --decode | xargs
KubernetesRocks!
```

### Create a `Secret` using `kubectl` command

A Secret can hold more than one key/value pair, so you can create a single Secret to hold both strings.

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/create-secret.sh) -->
<!-- The below code snippet is automatically added from labs/create-secret.sh -->
```sh
#!/usr/bin/env bash
# Why?

set -o pipefail
# Why?

kubectl create secret generic mariadb-user-creds \
  --from-literal=MYSQL_USER=kubeuser \
  --from-literal=MYSQL_PASSWORD=kube-still-rocks
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/create-secret.sh
secret/mariadb-user-creds created
```

```bash
$ kubectl get secret mariadb-user-creds --output jsonpath='{.data.MYSQL_USER}' | base64 --decode | xargs
kubeuser

$ kubectl get secret mariadb-user-creds --output jsonpath='{.data.MYSQL_PASSWORD}' | base64 --decode | xargs
kube-still-rocks
```


## ConfigMaps

> ConfigMaps are similar to Secrets.
> They can be created (YAML, kubectl) and shared in the containers in the same ways.
> The only big difference between them is the base64-encoding obfuscation.
> ConfigMaps are intended for non-sensitive data—configuration data—like config files and environment variables and are a great way to create customized running services from generic container images.

### Create a ConfigMap from an existing file

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/max_allowed_packet.cnf) -->
<!-- The below code snippet is automatically added from labs/max_allowed_packet.cnf -->
```cnf
[mysqld]
max_allowed_packet = 64M
```
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/create-configmap.sh) -->
<!-- The below code snippet is automatically added from labs/create-configmap.sh -->
```sh
#!/usr/bin/env bash
# Why?

set -o pipefail
# Why?

kubectl create configmap mariadb-config --from-file=labs/max_allowed_packet.cnf
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/create-configmap.sh
configmap/mariadb-config created
```

- By default, using `--from-file=<filename>` (as above) will store the contents of the file as the value, and the name of the file will be stored as the key.
- However, the key name can be explicitly set, too. For example, if you used --from-file=max-packet=max_allowed_packet.cnf when you created the ConfigMap, the key would be max-packet rather than the file name.

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
max_allowed_packet = 64M

Events:  <none>
```

```bash
$ kubectl edit configmap mariadb-config

apiVersion: v1
data:
  max_allowed_packet.cnf: |
    [mysqld]
    max_allowed_packet = 64M
kind: ConfigMap
metadata:
  creationTimestamp: "2019-11-03T12:46:26Z"
  name: mariadb-config
  namespace: default
  resourceVersion: "38334"
  selfLink: /api/v1/namespaces/default/configmaps/mariadb-config
  uid: 0e2f092c-136e-4f02-9e44-98868c6b2a91
```

```bash
$ kubectl get configmap mariadb-config --output "jsonpath={.data['max_allowed_packet\.cnf']}"
[mysqld]
max_allowed_packet = 64M
```


## Using Secrets and ConfigMaps

> Secrets and ConfigMaps can be mounted as environment variables or as files within a container.

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/mariadb-deployment.yaml) -->
<!-- The below code snippet is automatically added from labs/mariadb-deployment.yaml -->
```yaml
---
apiVersion: apps/v1
kind: Deployment

metadata:
  name: mariadb-deployment
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

          # Add the "Secrets" (or "ConfigMaps") as environment variables
          # Define a list, one by one
          env:
            # Name of the environment variable that is added to the container
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                # Or using "configMapRef" for a "ConfigMap"
                secretKeyRef:
                  name: mariadb-root-password
                  key: password

          # Set environment variables from all key-value pairs
          # in a "Secret" or "ConfigMap"
          envFrom:
            # Automatically use the key name as the environment variable name
            # and the key value as the environment variable value
            - secretRef:
                # In this case,
                # set the MYSQL_USER and MYSQL_PASSWORD
                # from the mariadb-user-creds Secret
                # we created earlier
                name: mariadb-user-creds

          ports:
            - containerPort: 3306
              protocol: TCP

          # The "volumeMounts" is pretty self-explanatory
          volumeMounts:
            # On most distribution's version of MySQL,
            # the data directory is located in the /var/lib/mysql/ directory.
            - name: mariadb-data-volume
              mountPath: /var/lib/mysql

              # Create a volume mount for the mariadb-config-volume
              # (specified in the volumes list below it)
              # to the path /etc/mysql/conf.d
            - name: mariadb-config-volume
              mountPath: /etc/mysql/conf.d

      # Both "Secrets" and "ConfigMaps" can be the source of
      # Kubernetes "volumes"
      # and mounted into the containers instead of
      # using a filesystem or block device as the volume to be mounted
      volumes:
        # An emptyDir (effectively a temporary or ephemeral)
        # volume mounted to /var/lib/mysql to store the MariaDB data
        - emptyDir: {}
          name: mariadb-data-volume
        # When the Pod restarts, the data in the emptyDir volume is lost

        # add your ConfigMap as a source by adding it
        # to the volume list and then adding a volumeMount
        # for it to the container definition
        - configMap:
            name: mariadb-config
            items:
              - key: max_allowed_packet.cnf
                path: max_allowed_packet.cnf
          name: mariadb-config-volume
```
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ kubectl apply --filename labs/mariadb-deployment.yaml
$ kubectl get pods
```

Verify the instance is using the Secrets and ConfigMap

```bash
$ kubectl exec -it mariadb-deployment-5465c6655c-7jfqm env | grep MYSQL
MYSQL_PASSWORD=kube-still-rocks
MYSQL_USER=kubeuser
MYSQL_ROOT_PASSWORD=KubernetesRocks!
```

```bash
$ kubectl exec -it mariadb-deployment-5465c6655c-7jfqm ls /etc/mysql/conf.d
max_allowed_packet.cnf

$ kubectl exec -it mariadb-deployment-5465c6655c-7jfqm cat /etc/mysql/conf.d/max_allowed_packet.cnf
[mysqld]
max_allowed_packet = 32M
```


## References

- [An Introduction to Kubernetes Secrets and ConfigMaps](https://opensource.com/article/19/6/introduction-kubernetes-secrets-and-configmaps)
