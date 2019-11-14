# RBAC Authorization

> Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Key Concepts](#key-concepts)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Key Concepts

Verbs: This is a set of operations that can be executed on resources. There are many verbs, but they’re all Create, Read, Update, or Delete (also known as CRUD).
API Resources: These are the objects available on the clusters. They are the pods, services, nodes, PersistentVolumes and other things that make up Kubernetes.
Subjects: These are the objects (users, groups, processes) allowed access to the API, based on Verbs and Resources.

<img src="assets/types-of-rbac.jpg" width="560">


## References

- [Kubernetes RBAC: Giving Users Access](https://platform9.com/blog/the-gorilla-guide-to-kubernetes-in-the-enterprise-chapter-4-putting-kubernetes-to-work/)
- [Demystifying RBAC in Kubernetes](https://www.cncf.io/blog/2018/08/01/demystifying-rbac-in-kubernetes/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
