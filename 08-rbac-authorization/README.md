# RBAC Authorization

> **Role-Based Access Control** (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Key Concepts](#key-concepts)
  - [Understanding RBAC API Objects](#understanding-rbac-api-objects)
  - [Subjects: Users and Service Accounts](#subjects-users-and-service-accounts)
- [RBAC in Deployments: A use case](#rbac-in-deployments-a-use-case)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Key Concepts

- **Subjects**: These are the objects (Users, Groups, Processes) allowed access to the Kubernetes API,
based on **API Resources** and **Verbs**.

- **API Resources**: These are the Kubernetes API Objects available on the clusters.
They are the Pods, Deployments, Services, Nodes, PersistentVolumes and other things that make up Kubernetes.

- **Verbs**: The set of operations that can be executed to the resources above.
There are many verbs (e.g. get, watch, create, delete,...),
but ultimately all of them are Create, Read, Update or Delete (CRUD) operations.

<div align="center">
  <img src="assets/types-of-rbac.jpg" width="560">
  <br />
  <em>Types of Role-Based Access Control</em>
  <br />
</div>
<br />

- These three elements combine into giving a user permission
to execute certain operations on a set of resources
by using Roles (which connects API Resources and Verbs)
and RoleBindings (connecting Subjects like Users, Groups and Service Accounts to Roles).


Users are authenticated using one or more authentication modes. These include client certificates, passwords, and various tokens.
After this, each user action or request on the cluster is authorized against the rules assigned to a user through roles.

There are two kinds of users: Service Accounts managed by Kubernetes, and normal users.
These normal users come from an identity store outside Kubernetes.
This means that accessing Kubernetes with multiple users, or even multiple roles, is something that needs to be carefully thought out.
Which identity source will you use? Which access control mode most suits you?
Which attributes or roles should you define? For larger deployments,
it's become standard to give each app a dedicated Service Account and launch the app with it.
Ideally, each app would run in a dedicated namespace, as it's fairly easy to assign roles to namespaces.

Kubernetes does lend itself to securing namespaces,
granting only permissions where needed so users don't see resources in their authorized namespace for isolation.
It also limits resource creation to specific namespaces, and applies quotas.

Many organizations take this one step further and lock down access even more,
so only tooling in their CI/CD pipeline can access Kubernetes, via Service Accounts.
This locks out real, actual humans, as they are expected to interact with Kubernetes clusters only indirectly.


### Understanding RBAC API Objects

- **Roles**: Will connect API Resources and Verbs.
These can be reused for different Subjects.
These are bound to one namespace (we cannot use wildcards to represent more than one, but we can deploy the same role object in different namespaces).
If we want the role to be applied cluster-wide, the equivalent object is called ClusterRoles.

- **RoleBinding**: Will connect the remaining entity-subjects.
Given a Role, which already binds API Objects and Verbs,
we will establish which subjects can use it.
For the cluster-level, non-namespaced equivalent, there are ClusterRoleBindings.


### Subjects: Users and Service Accounts

- **Users**: These are global, and meant for humans or processes living outside the cluster.
- **Service Accounts**: These are namespaced and meant for intra-cluster processes running inside Pods.


## RBAC in Deployments: A use case


## References

- [Kubernetes RBAC: Giving Users Access](https://platform9.com/blog/the-gorilla-guide-to-kubernetes-in-the-enterprise-chapter-4-putting-kubernetes-to-work/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Demystifying RBAC in Kubernetes](https://www.cncf.io/blog/2018/08/01/demystifying-rbac-in-kubernetes/)
