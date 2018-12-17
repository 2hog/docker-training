
layout: true
class: middle

---

# Role Based Access Control (RBAC) on Kubernetes

--

[p.2hog.codes/rbac-in-kubernetes](https://p.2hog.codes/rbac-in-kubernetes)

---


# About 2hog.codes

- Founders of [SourceLair](https://www.sourcelair.com) online IDE + Dimitris Togias
- Docker and DevOps training and consulting

---

# Antonis Kalipetis

- Docker Captain and Docker Certified Associate
- Python lover and developer
- Technology lead at SourceLair, Private Company

.footnote[[@akalipetis](https://twitter.com/akalipetis)]

---

# Paris Kasidiaris

- Python lover and developer
- CEO at SourceLair, Private Company
- Docker training and consulting

.footnote[[@pariskasid](https://twitter.com/pariskasid)]

---

# Dimitris Togias

- Self-luminous, minimalist engineer
- Co-founder of Warply and Niobium Labs
- Previously, Mobile Engineer and Craftsman at Skroutz

.footnote[[@demo9](https://twitter.com/demo9)]

---

class: center

# [p.2hog.codes/rbac-in-kubernetes](https://p.2hog.codes/rbac-in-kubernetes)

---

# Agenda

1. Intro to RBAC in Kubernetes
2. RBAC Kubernetes Objects
3. RBAC subjects
4. Examples

---

# Intro to RBAC in Kubernetes

---

# RBAC authorization

Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise.

---

# Status of RBAC in Kubernetes

As of Kubernetes 1.8, **RBAC mode is stable** and backed by the `rbac.authorization.k8s.io/v1` API.

RBAC uses the `rbac.authorization.k8s.io` API group to drive authorization decisions, allowing admins to dynamically configure policies through the Kubernetes API.

To enable RBAC, start the apiserver with `--authorization-mode=RBAC`.

---

# Use Cases

1. Kubernetes Dashboard
2. CI/CD via Jenkins running in a `Pod`
3. Operators (high-level managers for distiributed software; Prometheus, Vault etc.)

---

# Hacking time

---

# Hacking time

```
$ ssh workshop@workshop-vm-xx-yy.akalipetis.com
$ ps aux | grep kube-apiserver
```

---

# 💡 Heads up!

- Every `Pod` in Kubernetes gets a `ServiceAccount`
- Since the Kubernetes API is routable from every `Pod`, without RBAC the cluster is completely vulnerable

---

# Defaults

- `kubeadm` creates a cluster where pods by default do not have access
- The Kubernetes API is secured with HTTPS

---

# RBAC Kubernetes Objects

---

# RBAC Kubernetes Objects

1. `Role`
2. `ClusterRole`
3. `RoleBindings`
4. `ClusterRoleBindings`

---

# `Roles`

A `Role` object contains rules that represent a set of permissions.

A `Role` can only be used to grant access to resources within a single namespace.

.footnote[Permissions are purely additive (there are no “deny” rules).]

---

# Your first `Role`

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

---

# `ClusterRole`

A `ClusterRole` object is almost identical to a `Role` object, but grants cluster-wide permissions.

Because `ClusterRoles` are cluster-scoped, they can also be used to grant access to:

1. Cluster-scoped resources ( `Nodes`)
2. Non-resource endpoints (e.g. `/healthz`)
3. Namespaced resources across all namespaces (e.g. `Pods`):
    ```
    kubectl get pods --all-namespaces
    ```

---

# Your first `ClusterRole`

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

---

# `RoleBindings`

A `RoleBinding` object grants the permissions defined in a `Role` to a user or set of users.

It holds a list of subjects (users, groups, or service accounts) and a reference to the `Role` being granted.

---

# Your first `RoleBinding`

```yaml
# This role binding allows "dave" to read secrets in the "development" namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-secrets
  namespace: development # This only grants permissions within the "development" namespace.
subjects:
- kind: User
  name: dave # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

---

# `ClusterRoleBindings`

A `ClusterRoleBindings` object grants the permissions defined in a `ClusterRole` to a user or set of users.

It holds a list of subjects (users, groups, or service accounts) and a reference to the `ClusterRole` being granted. 

---

# Your first `ClusterRoleBinding`

```yaml
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

---

# RBAC subjects

---

# RBAC subjects

`Role` and `ClusterRole` objects can be bound to:

- Users
- Service Accounts

---

# Users

Users in a Kubernetes cluster are assumed to be managed by an outside, independent service (e.g. Keystone or Google Accounts).

Kubernetes does not have objects which represent normal user accounts.

**Users cannot be added to a cluster through an API call**.
 
---

# We won't mess with users

---

# Service accounts

---

# Service accounts

- Service accounts are for processes, which run in pods.
- Service accounts are namespaced.
- Service account creation is intended to be lightweight, allowing cluster users to create service accounts for specific tasks (principle of least privilege).

---

# How service accounts work

- Service accounts create the needed files in `/var/run/secrets/kubernetes.io/serviceaccount/`
- The files created contain the `namespace` and the `token`

---

# Hacking time!

---

```
$ ssh workshop@workshop-vm-xx-yy.akalipetis.com
$ kubectl describe clusterrolebinding/system:coredns
```

---

# Examples

---

# Kubernetes Dashboard

https://github.com/kubernetes/dashboard/blob/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

---

# Kubernetes Dashboard with RBAC

https://gist.github.com/parisk/375d409cf00b88e8022417a4e863ce06

---

# Ask your most weird questions!

---

class: center

# Thanks!
