# Kubernetes Service Accounts

<div align="center">
  <img src="assets/diagram.png" width="900">
  <br />
  <br />
  <p>A <strong>ServiceAccount</strong> is used by <strong>Containers</strong> running in a <strong>Pod</strong>,</p>
  <p>to communicate with the <strong>API Server</strong> of the Kubernetes cluster</p>
</div>


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Accessing the API Server from a `Pod`](#accessing-the-api-server-from-a-pod)
- [Using the Namespace Default `ServiceAccount`](#using-the-namespace-default-serviceaccount)
  - [Anonymous call of the API server](#anonymous-call-of-the-api-server)
  - [Call using the ServiceAccount token](#call-using-the-serviceaccount-token)
- [Using a Custom `ServiceAccount`](#using-a-custom-serviceaccount)
  - [Creation of a ServiceAccount](#creation-of-a-serviceaccount)
  - [Creation of a Role](#creation-of-a-role)
  - [Binding the Role with the ServiceAccount](#binding-the-role-with-the-serviceaccount)
  - [Using the ServiceAccount within a Pod](#using-the-serviceaccount-within-a-pod)
- [Main Takeaways](#main-takeaways)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Accessing the API Server from a `Pod`

To communicate with the API Server,
a `Pod` uses a `ServiceAccount` containing an authentication token.
Roles or ClusterRoles can then be bound to this ServiceAccount.
Respectively with a RoleBinding or a ClusterRoleBinding,
so the ServiceAccount is authorized to perform those actions.

- From the outside of the cluster:
the API server can be accessed using the `cluster.server` specified in the kubeconfig file (`~/.kube/config` by default).
As an example, if you use Minikube,
the endpoint is something like `https://192.168.99.100:8443`

```bash
$ curl https://192.168.99.100:8443/api/v1 --insecure
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/api/v1\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
}
```

- From the inside of the cluster:
the API server can be accessed using the dedicated service of type ClusterIP named kubernetes.
This service is there by default and automatically recreated if it is deleted by error.

```bash
$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   65m
```


## Using the Namespace Default `ServiceAccount`

Each namespace has a default ServiceAccount, named `default`.

```bash
$ kubectl get serviceaccounts --all-namespaces | grep default
default                default                              1         73m
kube-node-lease        default                              1         73m
kube-public            default                              1         73m
kube-system            default                              1         73m
kubernetes-dashboard   default                              1         73m
```

```bash
$ kubectl get serviceaccount default --output=yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2019-12-02T09:00:41Z"
  name: default
  namespace: default
  resourceVersion: "335"
  selfLink: /api/v1/namespaces/default/serviceaccounts/default
  uid: 45fcb6c2-2ff4-4a0d-ac15-4fa2b0b75fa4
secrets:
- name: default-token-frgh2
```

```bash
$ kubectl get secret default-token-frgh2 --output=yaml
apiVersion: v1
data:
  ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRFNE1EZ3dNekEyTkRVd09Gb1hEVEk0TURnd01UQTJORFV3T0Zvd0ZURVRNQkVHQTFVRQpBeE1LYldsdWFXdDFZbVZEUVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT2NFCnhTRXQ5OTV0UVdqemJHZVlsb2ZidGRiSSthWno0RkRoQmlCUkVSU3pYQ1pEQVd4aWlQdzNkYWIyV0NmRkFHMmwKaWx4UnlBandFZSs0ZXkzdDBGbXBQUDhPRzJNdVdqUk1zMmJHREdhNVUvUFdEcTFHRk1lMDY3emZYTXRzUVh3QQpTMlI1YVlyWFZlb0loU29wdWZ4d1RiNXF1VkdicnUzOG9XNnBOVmsybHk4MVljQkJQaENRby9ua3MzaExhRXh6Ck93T3BwdlFZZzAxdy90RkZ2VnRoRHRxY2RzNWV0bXN3SzlXOWFNMUQvc3YvRDFMVnc5dXdwNGdOVWlYS2VTQ1oKTS9rUWowTWREQTZCWUNRRWN6STFCZEpYQjdTSklQSm16T3U2QTEramdMc3BWWExjc0UvbXRQcHkwMmozRW5udwpvS1VkZjljNU0vQTlNb0cyL0UwQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFCQjgydC9rMjVrMlR5M0RiT2VhdUtsQ2hFNng2dWFwQ0NKUkZMR0ViQmVpRVo3YkRFVgpxL29ZbEJsS2FtSmdVaXRnNkVOMUhqUllTNEZvWnpjN3hEU2hSMG1wQWpHU0U3eTZkTS95RzlCMmFzMWZYeFlWCi9PUllZNFczQlZUdFBZelBUSUlOTTVrV0s1aDJzV0lEQVVySFJucVpUOUxtaXRXUXNscys0dzBYTFp6bGhKNjEKUHhhM0U0ajM1cEZzc2wxdlZsb0VwWW1NckNnU1ZXL1BWaGJsYUpMYkYyY3JVUThlMGZOV1ZVYmdGNWMrNzNzMwpiUFVGOWYxM3VLS0x3UVpncVFRQURwbHArejR0YU92S3BYUzNaVm8yMGhGTzRmVVkvSGtldGQ3OSttcUs2NldRCjREZ3pENktmSXR1dG1KNWJIRE1SREplNXNYQmUvcmF2WVYzTQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  namespace: ZGVmYXVsdA==
  token: ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkltNXJTM1ZQZUVGd2EwTnRNakpyYmpoM2FrZGZZbUpSUTNVellqRnpTVlJqTTFoeFIyMUNZbkE0YmswaWZRLmV5SnBjM01pT2lKcmRXSmxjbTVsZEdWekwzTmxjblpwWTJWaFkyTnZkVzUwSWl3aWEzVmlaWEp1WlhSbGN5NXBieTl6WlhKMmFXTmxZV05qYjNWdWRDOXVZVzFsYzNCaFkyVWlPaUprWldaaGRXeDBJaXdpYTNWaVpYSnVaWFJsY3k1cGJ5OXpaWEoyYVdObFlXTmpiM1Z1ZEM5elpXTnlaWFF1Ym1GdFpTSTZJbVJsWm1GMWJIUXRkRzlyWlc0dFpuSm5hRElpTENKcmRXSmxjbTVsZEdWekxtbHZMM05sY25acFkyVmhZMk52ZFc1MEwzTmxjblpwWTJVdFlXTmpiM1Z1ZEM1dVlXMWxJam9pWkdWbVlYVnNkQ0lzSW10MVltVnlibVYwWlhNdWFXOHZjMlZ5ZG1salpXRmpZMjkxYm5RdmMyVnlkbWxqWlMxaFkyTnZkVzUwTG5WcFpDSTZJalExWm1OaU5tTXlMVEptWmpRdE5HRXdaQzFoWXpFMUxUUm1ZVEppTUdJM05XWmhOQ0lzSW5OMVlpSTZJbk41YzNSbGJUcHpaWEoyYVdObFlXTmpiM1Z1ZERwa1pXWmhkV3gwT21SbFptRjFiSFFpZlEuaXBwcndBZXlOZnVYR21EcGN1TWk3aUdvTHNneUh0R09hNm5ZdElNYWpQZmFuemNxUmFlcU1GS1gwd25oblFqXy1KWHQwQjA2M1lqX2loRGVmZE5PdTE4bTZOVUoxVXFic3l6am15S3YyLUZxMGt0VWxlTzhZMGhjclJrWmhoZTBYc2FBeVg1TFVNUHgtaGdwWHdxVW9wTURqQ1VXYVZwQlhxNlNtZVp4cDN1TXVNcWFrWV9nTTRMX3hTNEcwZkVQRm1TWU1jeE1IMTJ3WWstZW9XalNMSlhwX1NOQmViZnZiUGdXdHNuOENxdi1JZDNvMlkzZWl2ZnF4RzJpdGxrdERJaTh4WElBVzJJYm1GUExOSjVuQnBERFhNdEs4STIxZmNBOU9lbFJ6cjZwSERndHBRS01LcHpGRWh3aE9zN0pTWEtXak1udVFjOG1jdjFWUGQwSnBB
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: default
    kubernetes.io/service-account.uid: 45fcb6c2-2ff4-4a0d-ac15-4fa2b0b75fa4
  creationTimestamp: "2019-12-02T09:00:41Z"
  name: default-token-frgh2
  namespace: default
  resourceVersion: "332"
  selfLink: /api/v1/namespaces/default/secrets/default-token-frgh2
  uid: b07164c5-4875-44cd-88c3-f4c1104d5e2d
type: kubernetes.io/service-account-token
```

- `ca.crt`: the Base64 encoding of the cluster certificate.
- `namespace`: the Base64 encoding of the current namespace.
- `token`: the Base64 encoding of the JWT used to authenticate against the API server.

This payload of decoded token has the following format:

```json
{
  "iss": "kubernetes/serviceaccount",
  "kubernetes.io/serviceaccount/namespace": "default",
  "kubernetes.io/serviceaccount/secret.name": "default-token-frgh2",
  "kubernetes.io/serviceaccount/service-account.name": "default",
  "kubernetes.io/serviceaccount/service-account.uid": "45fcb6c2-2ff4-4a0d-ac15-4fa2b0b75fa4",
  "sub": "system:serviceaccount:default:default"
}
```

We will see below how to use this token from within a simple Pod,
based on the following specification:

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/default-pod.yaml) -->
<!-- The below code snippet is automatically added from labs/default-pod.yaml -->
```yaml
---
apiVersion: v1
kind: Pod

metadata:
  name: default-pod

spec:
  containers:
    # BusyBox - The Swiss Army Knife of Embedded Linux
    # @see: https://github.com/docker-library/busybox
    - name: busybox
      image: busybox:musl
      command:
        - "sleep"
        - "10000"
#      lifecycle:
#        postStart:
#          exec:
#            command:
#              ["/bin/sh", "-c", "apk update", "apk add bash", "apk add curl"]
#            command: ["/bin/sh","-c"]
#            args: ["command one; command two; command three"]
# apk update
# apk upgrade
# apk add bash

# sh calls the program sh as interpreter and
# the -c flag means execute the following command
# as interpreted by this program.
# In Ubuntu,
# sh is usually symlinked to /bin/dash,
# meaning that if you execute a command with sh -c the
# dash shell will be used to
# execute the command instead of bash.
# The shell called with sh depends on the symlink -
# you can find out with readlink -e $(which sh).
# You should use sh -c when you want to execute a command
# specifically with that shell instead of bash.
```
<!-- The below code snippet is automatically added from labs/01-without-helm/mongodb-secret.yaml -->
<!-- AUTO-GENERATED-CONTENT:END -->

Assuming this specification is in the pod-default.yaml file,
you can create the Pod with the following (and standard) command:

```bash
$ kubectl apply --filename labs/default-pod.yaml
pod/default-pod created
```

As no `serviceAccountName` key is specified,
the default ServiceAccount of the Pod's namespace is used.
We can confirm this by checking the specification of this Pod once created
(Kubernetes adds a lot of things for us during the creation process).

```bash
$ kubectl get pod default-pod --output=yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"default-pod","namespace":"default"},"spec":{"containers":[{"command":["sleep","10000"],"image":"alpine:3.9","name":"alpine"}]}}
  creationTimestamp: "2019-12-02T10:27:13Z"
  name: default-pod
  namespace: default
  resourceVersion: "7518"
  selfLink: /api/v1/namespaces/default/pods/default-pod
  uid: a21d171b-2aa3-4ab0-87e3-6e4c875c5c5c
spec:
  containers:
  - command:
    - sleep
    - "10000"
    image: alpine:3.9
    imagePullPolicy: IfNotPresent
    name: alpine
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-frgh2
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: minikube
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: default-token-frgh2
    secret:
      defaultMode: 420
      secretName: default-token-frgh2
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2019-12-02T10:27:13Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2019-12-02T10:27:20Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2019-12-02T10:27:20Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2019-12-02T10:27:13Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://9c8e5070e212758d79a04dd1b3e01e66a7b5e3d27cab2969af00739a060689db
    image: alpine:3.9
    imageID: docker-pullable://alpine@sha256:7746df395af22f04212cd25a92c1d6dbc5a06a0ca9579a229ef43008d4d1302a
    lastState: {}
    name: alpine
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2019-12-02T10:27:20Z"
  hostIP: 192.168.99.100
  phase: Running
  podIP: 172.17.0.7
  podIPs:
  - ip: 172.17.0.7
  qosClass: BestEffort
  startTime: "2019-12-02T10:27:13Z"
```

Important things to note here:
- The `serviceAccountName` key is set with the name of the default ServiceAccount.
- The information of the ServiceAccount is mounted inside the container of the Pod,
through the usage of volume, in `/var/run/secrets/kubernetes.io/serviceaccount`
(more on that in a bit).


### Anonymous call of the API server

Let's run a shell within this container and install the `curl` utility:

```bash
$ kubectl exec -it default-pod test.sh
# apk add --update curl
```

From this shell,
we can try to get information from the API server without authentication.

```bash
# curl https://kubernetes/api/v1 --insecure
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/api/v1\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
```

Note: as said above,
from a Pod running in the cluster,
the API server can be reached using the Kubernetes ClusterIP service.

We then get an error message,
as an unauthenticated user is not allowed to perform this request.

Let's go one step further and
try to issue the same query using the token of the default ServiceAccount.


### Call using the ServiceAccount token

From the alpine container,
the token of the default ServiceAccount can be retrieved from
`/run/secrets/kubernetes.io/serviceaccount/token`
(remember the volume/volumeMounts instructions above).
Using this token, we can use it as a Bearer token to authenticate against the API server:

```bash
# TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
# curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/ --insecure
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "componentstatuses",
      "singularName": "",
      "namespaced": false,
      "kind": "ComponentStatus",
      "verbs": [
        "get",
        "list"
      ],
      "shortNames": [
        "cs"
      ]
    },
    {
      "name": "configmaps",
      "singularName": "",
      "namespaced": true,
      "kind": "ConfigMap",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "cm"
      ],
      "storageVersionHash": "qFsyl6wFWjQ="
    },
    {
      "name": "endpoints",
      "singularName": "",
      "namespaced": true,
      "kind": "Endpoints",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "ep"
      ],
      "storageVersionHash": "fWeeMqaN/OA="
    },
    {
      "name": "events",
      "singularName": "",
      "namespaced": true,
      "kind": "Event",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "ev"
      ],
      "storageVersionHash": "r2yiGXH7wu8="
    },
    {
      "name": "limitranges",
      "singularName": "",
      "namespaced": true,
      "kind": "LimitRange",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "limits"
      ],
      "storageVersionHash": "EBKMFVe6cwo="
    },
    {
      "name": "namespaces",
      "singularName": "",
      "namespaced": false,
      "kind": "Namespace",
      "verbs": [
        "create",
        "delete",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "ns"
      ],
      "storageVersionHash": "Q3oi5N2YM8M="
    },
    {
      "name": "namespaces/finalize",
      "singularName": "",
      "namespaced": false,
      "kind": "Namespace",
      "verbs": [
        "update"
      ]
    },
    {
      "name": "namespaces/status",
      "singularName": "",
      "namespaced": false,
      "kind": "Namespace",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "nodes",
      "singularName": "",
      "namespaced": false,
      "kind": "Node",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "no"
      ],
      "storageVersionHash": "XwShjMxG9Fs="
    },
    {
      "name": "nodes/proxy",
      "singularName": "",
      "namespaced": false,
      "kind": "NodeProxyOptions",
      "verbs": [
        "create",
        "delete",
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "nodes/status",
      "singularName": "",
      "namespaced": false,
      "kind": "Node",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "persistentvolumeclaims",
      "singularName": "",
      "namespaced": true,
      "kind": "PersistentVolumeClaim",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "pvc"
      ],
      "storageVersionHash": "QWTyNDq0dC4="
    },
    {
      "name": "persistentvolumeclaims/status",
      "singularName": "",
      "namespaced": true,
      "kind": "PersistentVolumeClaim",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "persistentvolumes",
      "singularName": "",
      "namespaced": false,
      "kind": "PersistentVolume",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "pv"
      ],
      "storageVersionHash": "HN/zwEC+JgM="
    },
    {
      "name": "persistentvolumes/status",
      "singularName": "",
      "namespaced": false,
      "kind": "PersistentVolume",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "pods",
      "singularName": "",
      "namespaced": true,
      "kind": "Pod",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "po"
      ],
      "categories": [
        "all"
      ],
      "storageVersionHash": "xPOwRZ+Yhw8="
    },
    {
      "name": "pods/attach",
      "singularName": "",
      "namespaced": true,
      "kind": "PodAttachOptions",
      "verbs": [
        "create",
        "get"
      ]
    },
    {
      "name": "pods/binding",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "pods/eviction",
      "singularName": "",
      "namespaced": true,
      "group": "policy",
      "version": "v1beta1",
      "kind": "Eviction",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "pods/exec",
      "singularName": "",
      "namespaced": true,
      "kind": "PodExecOptions",
      "verbs": [
        "create",
        "get"
      ]
    },
    {
      "name": "pods/log",
      "singularName": "",
      "namespaced": true,
      "kind": "Pod",
      "verbs": [
        "get"
      ]
    },
    {
      "name": "pods/portforward",
      "singularName": "",
      "namespaced": true,
      "kind": "PodPortForwardOptions",
      "verbs": [
        "create",
        "get"
      ]
    },
    {
      "name": "pods/proxy",
      "singularName": "",
      "namespaced": true,
      "kind": "PodProxyOptions",
      "verbs": [
        "create",
        "delete",
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "pods/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Pod",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "podtemplates",
      "singularName": "",
      "namespaced": true,
      "kind": "PodTemplate",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "storageVersionHash": "LIXB2x4IFpk="
    },
    {
      "name": "replicationcontrollers",
      "singularName": "",
      "namespaced": true,
      "kind": "ReplicationController",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "rc"
      ],
      "categories": [
        "all"
      ],
      "storageVersionHash": "Jond2If31h0="
    },
    {
      "name": "replicationcontrollers/scale",
      "singularName": "",
      "namespaced": true,
      "group": "autoscaling",
      "version": "v1",
      "kind": "Scale",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "replicationcontrollers/status",
      "singularName": "",
      "namespaced": true,
      "kind": "ReplicationController",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "resourcequotas",
      "singularName": "",
      "namespaced": true,
      "kind": "ResourceQuota",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "quota"
      ],
      "storageVersionHash": "8uhSgffRX6w="
    },
    {
      "name": "resourcequotas/status",
      "singularName": "",
      "namespaced": true,
      "kind": "ResourceQuota",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "secrets",
      "singularName": "",
      "namespaced": true,
      "kind": "Secret",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "storageVersionHash": "S6u1pOWzb84="
    },
    {
      "name": "serviceaccounts",
      "singularName": "",
      "namespaced": true,
      "kind": "ServiceAccount",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "sa"
      ],
      "storageVersionHash": "pbx9ZvyFpBE="
    },
    {
      "name": "services",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "create",
        "delete",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "svc"
      ],
      "categories": [
        "all"
      ],
      "storageVersionHash": "0/CO1lhkEBI="
    },
    {
      "name": "services/proxy",
      "singularName": "",
      "namespaced": true,
      "kind": "ServiceProxyOptions",
      "verbs": [
        "create",
        "delete",
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "services/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    }
  ]
```

This time the request goes fine - no more error querying this end point.
The list of resources is returned.

Let's now try something more ambitious,
and use this token to list all the Pods within the default namespace:

```bash
# curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/ --insecure
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "pods is forbidden: User \"system:serviceaccount:default:default\" cannot list resource \"pods\" in API group \"\" in the namespace \"default\"",
  "reason": "Forbidden",
  "details": {
    "kind": "pods"
  },
  "code": 403
```

The default ServiceAccount does not have enough rights to perform this query.
In the following part,
we will create our own ServiceAccount and
provide it with the additional rights it needs for this action.


## Using a Custom `ServiceAccount`

### Creation of a ServiceAccount

Let's create a new ServiceAccount in the default namespace and call it demo-sa.
This ServiceAccount is defined in the following specification and
created with the standard `kubectl apply -f` command.

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/demo-sa.yaml) -->
<!-- The below code snippet is automatically added from labs/demo-sa.yaml -->
```yaml
---
apiVersion: v1
kind: ServiceAccount

metadata:
  name: demo-sa
```
<!-- AUTO-GENERATED-CONTENT:END -->


### Creation of a Role

A ServiceAccount is not that useful unless certain rights are bound to it.
Rights are known as Role or ClusterRole in Kubernetes.
They are associated with a ServiceAccount,
with RoleBinding and ClusterRoleBinding respectively.

A Role (the same applies to a ClusterRole) contains a list of rules.
Each rule defines some actions that can be performed (e.g: list, get, watch)
against a list of resources (e.g: Pod, Service, Secret)
within apiGroups (eg: core, apps/v1).
While a Role defines rights for a specific namespace,
the scope of a ClusterRole is the entire cluster.

The following specification defines a Role
allowing to list all the Pods in the default namespace.

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/pod-access-role.yaml) -->
<!-- The below code snippet is automatically added from labs/pod-access-role.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role

metadata:
  name: pod-access
  namespace: default

rules:
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - get
      - list
```
<!-- AUTO-GENERATED-CONTENT:END -->


### Binding the Role with the ServiceAccount

In the last step,
we bind the Role and the ServiceAccount created above.
In order to do so, we define a RoleBinding with the following specification:

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/demo-reads-pods.yaml) -->
<!-- The below code snippet is automatically added from labs/demo-reads-pods.yaml -->
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: demo-reads-pods
  namespace: default

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-access

subjects:
  - kind: ServiceAccount
    name: demo-sa
    namespace: default
```
<!-- AUTO-GENERATED-CONTENT:END -->

Once the RoleBinding is created,
the demo-sa ServiceAccount can list the Pods
in the default namespace
(this is the action defined under the rules key within the specification of the Role).
Let's check this.


### Using the ServiceAccount within a Pod

We create a simple Pod from the following specification:

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/demo-pod.yaml) -->
<!-- The below code snippet is automatically added from labs/demo-pod.yaml -->
```yaml
---
apiVersion: v1
kind: Pod

metadata:
  name: demo-pod

spec:
  serviceAccountName: demo-sa
  containers:
    # change to busy box
    - name: alpine
      image: alpine:3.9
      command:
        - "sleep"
        - "10000"
```
<!-- AUTO-GENERATED-CONTENT:END -->

The `serviceAccountName` key is specified and
contains the name of the ServiceAccount used by that Pod, demo-sa.
As we saw above,
if the serviceAccountName is not specified in the Pod specification,
the default ServiceAccount of the namespace is used.

As we did with the `pod-default` Pod,
we now run a shell within the alpine container of the Pod `pod-demo-sa`,
get the token belonging to the demo-sa ServiceAccount,
and use it to query the list of Pods within the default namespace.


<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/demo-apply.sh) -->
<!-- The below code snippet is automatically added from labs/demo-apply.sh -->
```sh
#!/usr/bin/env bash
set -eoux pipefail

kubectl delete --filename labs/demo-sa.yaml || true
kubectl delete --filename labs/pod-access-role.yaml || true
kubectl delete --filename labs/demo-reads-pods.yaml || true
kubectl delete --filename labs/demo-pod.yaml || true

kubectl apply --filename labs/demo-sa.yaml
kubectl apply --filename labs/pod-access-role.yaml
kubectl apply --filename labs/demo-reads-pods.yaml
kubectl apply --filename labs/demo-pod.yaml
```
<!-- The below code snippet is automatically added from labs/demo-pod.yaml -->
<!-- AUTO-GENERATED-CONTENT:END -->

```bash
$ labs/demo-apply.sh
+ kubectl apply --filename labs/demo-serviceaccount.yaml
serviceaccount/demo-sa created
+ kubectl apply --filename labs/list-pods.yaml
role.rbac.authorization.k8s.io/list-pods created
+ kubectl apply --filename labs/list-pods-demo-sa.yaml
rolebinding.rbac.authorization.k8s.io/list-pods-demo-sa created
+ kubectl apply --filename labs/pod-demo-sa.yaml
pod/pod-demo-sa created
```

```bash
$ kubectl exec -it pod-demo-sa sh

# apk add --update curl

# Get the ServiceAccount token from within the Pod's container
# TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)

# Call an API Server's endpoint (using the ClusterIP kubernetes service)
# to get all the Pods running in the default namespace
# curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/ --insecure
```

No more error this time, as the ServiceAccount has the rights to perform this action.
We get a list of Pods running in the default namespace.

```json
{
  "kind": "PodList",
  "apiVersion": "v1",
  "metadata": {
    "selfLink": "/api/v1/namespaces/default/pods/",
    "resourceVersion": "11711"
  },
  "items": [
    {
      "metadata": {
        "name": "default-pod",
        "namespace": "default",
        "selfLink": "/api/v1/namespaces/default/pods/default-pod",
        "uid": "a21d171b-2aa3-4ab0-87e3-6e4c875c5c5c",
        "resourceVersion": "7518",
        "creationTimestamp": "2019-12-02T10:27:13Z",
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{},\"name\":\"default-pod\",\"namespace\":\"default\"},\"spec\":{\"containers\":[{\"command\":[\"sleep\",\"10000\"],\"image\":\"alpine:3.9\",\"name\":\"alpine\"}]}}\n"
        }
      },
      "spec": {
        "volumes": [
          {
            "name": "default-token-frgh2",
            "secret": {
              "secretName": "default-token-frgh2",
              "defaultMode": 420
            }
          }
        ],
        "containers": [
          {
            "name": "alpine",
            "image": "alpine:3.9",
            "command": [
              "sleep",
              "10000"
            ],
            "resources": {

            },
            "volumeMounts": [
              {
                "name": "default-token-frgh2",
                "readOnly": true,
                "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount"
              }
            ],
            "terminationMessagePath": "/dev/termination-log",
            "terminationMessagePolicy": "File",
            "imagePullPolicy": "IfNotPresent"
          }
        ],
        "restartPolicy": "Always",
        "terminationGracePeriodSeconds": 30,
        "dnsPolicy": "ClusterFirst",
        "serviceAccountName": "default",
        "serviceAccount": "default",
        "nodeName": "minikube",
        "securityContext": {

        },
        "schedulerName": "default-scheduler",
        "tolerations": [
          {
            "key": "node.kubernetes.io/not-ready",
            "operator": "Exists",
            "effect": "NoExecute",
            "tolerationSeconds": 300
          },
          {
            "key": "node.kubernetes.io/unreachable",
            "operator": "Exists",
            "effect": "NoExecute",
            "tolerationSeconds": 300
          }
        ],
        "priority": 0,
        "enableServiceLinks": true
      },
      "status": {
        "phase": "Running",
        "conditions": [
          {
            "type": "Initialized",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T10:27:13Z"
          },
          {
            "type": "Ready",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T10:27:20Z"
          },
          {
            "type": "ContainersReady",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T10:27:20Z"
          },
          {
            "type": "PodScheduled",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T10:27:13Z"
          }
        ],
        "hostIP": "192.168.99.100",
        "podIP": "172.17.0.7",
        "podIPs": [
          {
            "ip": "172.17.0.7"
          }
        ],
        "startTime": "2019-12-02T10:27:13Z",
        "containerStatuses": [
          {
            "name": "alpine",
            "state": {
              "running": {
                "startedAt": "2019-12-02T10:27:20Z"
              }
            },
            "lastState": {

            },
            "ready": true,
            "restartCount": 0,
            "image": "alpine:3.9",
            "imageID": "docker-pullable://alpine@sha256:7746df395af22f04212cd25a92c1d6dbc5a06a0ca9579a229ef43008d4d1302a",
            "containerID": "docker://9c8e5070e212758d79a04dd1b3e01e66a7b5e3d27cab2969af00739a060689db",
            "started": true
          }
        ],
        "qosClass": "BestEffort"
      }
    },
    {
      "metadata": {
        "name": "pod-demo-sa",
        "namespace": "default",
        "selfLink": "/api/v1/namespaces/default/pods/pod-demo-sa",
        "uid": "c3bcc29b-5ca9-4cb6-a3cd-297700d12cae",
        "resourceVersion": "11564",
        "creationTimestamp": "2019-12-02T11:17:13Z",
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{},\"name\":\"pod-demo-sa\",\"namespace\":\"default\"},\"spec\":{\"containers\":[{\"command\":[\"sleep\",\"10000\"],\"image\":\"alpine:3.9\",\"name\":\"alpine\"}],\"serviceAccountName\":\"demo-sa\"}}\n"
        }
      },
      "spec": {
        "volumes": [
          {
            "name": "demo-sa-token-77f8p",
            "secret": {
              "secretName": "demo-sa-token-77f8p",
              "defaultMode": 420
            }
          }
        ],
        "containers": [
          {
            "name": "alpine",
            "image": "alpine:3.9",
            "command": [
              "sleep",
              "10000"
            ],
            "resources": {

            },
            "volumeMounts": [
              {
                "name": "demo-sa-token-77f8p",
                "readOnly": true,
                "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount"
              }
            ],
            "terminationMessagePath": "/dev/termination-log",
            "terminationMessagePolicy": "File",
            "imagePullPolicy": "IfNotPresent"
          }
        ],
        "restartPolicy": "Always",
        "terminationGracePeriodSeconds": 30,
        "dnsPolicy": "ClusterFirst",
        "serviceAccountName": "demo-sa",
        "serviceAccount": "demo-sa",
        "nodeName": "minikube",
        "securityContext": {

        },
        "schedulerName": "default-scheduler",
        "tolerations": [
          {
            "key": "node.kubernetes.io/not-ready",
            "operator": "Exists",
            "effect": "NoExecute",
            "tolerationSeconds": 300
          },
          {
            "key": "node.kubernetes.io/unreachable",
            "operator": "Exists",
            "effect": "NoExecute",
            "tolerationSeconds": 300
          }
        ],
        "priority": 0,
        "enableServiceLinks": true
      },
      "status": {
        "phase": "Running",
        "conditions": [
          {
            "type": "Initialized",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T11:17:13Z"
          },
          {
            "type": "Ready",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T11:17:14Z"
          },
          {
            "type": "ContainersReady",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T11:17:14Z"
          },
          {
            "type": "PodScheduled",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2019-12-02T11:17:13Z"
          }
        ],
        "hostIP": "192.168.99.100",
        "podIP": "172.17.0.8",
        "podIPs": [
          {
            "ip": "172.17.0.8"
          }
        ],
        "startTime": "2019-12-02T11:17:13Z",
        "containerStatuses": [
          {
            "name": "alpine",
            "state": {
              "running": {
                "startedAt": "2019-12-02T11:17:14Z"
              }
            },
            "lastState": {

            },
            "ready": true,
            "restartCount": 0,
            "image": "alpine:3.9",
            "imageID": "docker-pullable://alpine@sha256:7746df395af22f04212cd25a92c1d6dbc5a06a0ca9579a229ef43008d4d1302a",
            "containerID": "docker://edd17b07d104012fc52ec7d1aace4b9291cace0d0f8f1f510598b04f6cf3335c",
            "started": true
          }
        ],
        "qosClass": "BestEffort"
      }
    }
  ]
}
```


## Main Takeaways

By default,
each Pod can communicate with the API server of the cluster it is running on.
If no ServiceAccount is specified,
it uses the default ServiceAccount of its namespace.
As the default ServiceAccounts only have limited rights,
it is generally best practice to create a ServiceAccount for each application,
giving it the rights it needs (and no more).

To authenticate against the API server,
a Pod uses the token of the attached ServiceAccount.
This token is available in the filesystem of each container of the Pod.


## References

- [Kubernetes Tips: Using a ServiceAccount](https://medium.com/better-programming/k8s-tips-using-a-serviceaccount-801c433d0023)
