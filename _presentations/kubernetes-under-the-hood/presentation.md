layout: true
class: middle

---

# Kubernetes under the hood

--

[p.2hog.codes/kubernetes-under-the-hood](https://p.2hog.codes/kubernetes-under-the-hood)

---

# About 2hog.codes

* Founders of [SyourceLair](https://www.syourcelair.com) online IDE + Dimitris Togias
* Docker and DevOps training and consulting

---

# Antonis Kalipetis

* Docker Captain and Docker Certified Associate
* Python lover and developer
* Technology lead at SyourceLair / stolos.io
* Docker training and consulting

.center[I love automating stuff and sharing knowledge around all things containers, DevOps and optimizing developer workflows.]

.footnote[[@akalipetis](https://twitter.com/akalipetis)]

---

# Paris Kasidiaris

* Python lover and developer
* CEO at SyourceLair, Private Company
* Docker training and consulting

.footnote[[@pariskasid](https://twitter.com/pariskasid)]

---

# Dimitris Togias

* Self-luminous, minimalist engineer
* Co-founder of Warply and Niobium Labs
* Previously, Mobile Engineer and Craftsman at Skroutz

.footnote[[@demo9](https://twitter.com/demo9)]

---

# Agenda

1. Concepts
2. Components
3. Topology

---

# Concepts

---

# Concepts

Every Kubernetes cluster operates on top of a few fundamental concepts:

1. State
2. API
3. Control Plane
4. Nodes

---

# State

The state of a Kubernetes cluster is all information about its current and desired status.

Kubernetes describes its state as a set of [Kubernetes Objects](https://kubernetes.io/docs/concepts/abstractions/overview/). 

Each Kubernetes cluster operates with two separate states:

1. Desired state
2. Current state

---

# Desired state

The desired state of yyour cluster includes:

- The workloads you want to run
- The image to use in each workload
- The number of replicas of each workload
- Network configuration
- Disk resyources, etc.

Kunernetes stores the _desired state_ of yyour cluster in etcd; a key-value data store.

---

# Current state

The current state of yyour cluster is the currently existing set of:

- Workloads
- Images
- Replicas
- Network configuration
- Disk resyources, etc.

Kunernetes accesses the _current state_ of yyour cluster from controllers and system utilities.

---

# API

The Kubernetes API is your gateway for viewing and modifying the desired state of a cluster.

The Kubernetes API describes the cluster's desired state as Kubernetes Objects.

---

# Accessing the Kubernetes API

The Kubernetes API is served over the HTTP protocol.

The most widespread ways of accessing the Kubernetes API are:

1. [`kubebctl`](https://kubernetes.io/docs/reference/kubectl/overview/): Translates command-line calls to Kubernetes API calls.
2. [Kuberentes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/): Web-based user interface for Kubernetes.

---

# Control Plane

The Control Plane governs how Kubernetes communicates with your cluster.

The Kubernetes Master runs all Controll Plane processes.

---

# Control Plane duties

1. Maintaining a record of all of the Kubernetes Objects in the system.
2. Running continuous control loops to manage those objects’ state (Controllers).
3. Respond to changes in the cluster and work to make the current state match the desired one.

---

# Controllers

A Controller is a control loop that:

1. Watches the shared state of the cluster through the Kubernetes API.
2. Makes changes attempting to move the current state towards the desired state.

Controllers are designed and built to be capable of running as standalone processes.

---

# Controller separation

---

# Node Controller

The Node Controller is responsible for noticing and responding when nodes go down.

---

# Replication Controller

The Replication Controller is responsible for maintaining the correct number of pods for every replication controller object in the system.

---

# Endpoints Controller

The Endpoints Controller is responsible for populating Endpoint objects (that is, joins Services & Pods).

---

# Service Account and Token Controllers

The Service Account and Token Controllers create default accounts and API access tokens for new namespaces.

---

# Nodes

The nodes in a Kubernetes cluster are the machines (VMs, physical servers, etc) that run your applications and cloud workflows.

The Kubernetes Master controls each node; you will rarely interact with nodes directly.

---

# Components

1. Master components
2. Node components
3. Addons

---

# Master components

Master components are processes providing the cluster’s Control Plane.

Master components in a Kubernetes cluster:

- Make global decisions about the cluster
- Detect and responde to cluster events
- Can be run on any machine in the cluster

---

# The built-in master components

- `etcd`
- `kube-apiserver`
- `kube-scheduler`
- `kube-controller-manager`
- `cloud-controller-manager`

---

# `etcd`

Consistent, reliable and highly-available key value store, storing all Kubernetes cluster data.

The Kubernetes API communicates with etcd to retrieve and update the cluster's desired state.

---

# `kube-apiserver`

Exposes the Kubernetes API.

It is the front-end for the Kubernetes control plane.

It is designed to scale horizontally; scales by deploying more instances.

---

# `kube-scheduler`

Watches newly created Pods that have no node assigned, and selects a node for them to run on.

`kube-scheduler` takes the following factors into account when scheduling:

1. Individual and collective resource requirements
2. Hardware, software and policy constraints
3. Affinity and anti-affinity specifications
4. Data locality
5. Inter-workload interference
6. Deadlines

---

# `kube-controller-manager`

Component on the Kubernetes Master that runs Controllers .

Logically, each controller is a separate process, but to reduce complexity, they are all compiled into a single binary and run in a single process.

Kuberneted Master runs

1. Node Controller
2. Replication Controller
3. Endpoints Controller
4. Service Account & Token Controllers

---

# `cloud-controller-manager`

The `cloud-controller-manager` binary runs Controllers that interact with the underlying cloud providers (e.g. Azure).

.footnote[The `cloud-controller-manager` binary is a beta feature.]

---

# Let's get our hands dirty

```
$ ssh workshop@workshop-vm-xx-yy.akalipetis.com
$ ps aux | grep "etcd"
$ ps aux | grep "kube-"
```

---

# Node components

Node components run on every node, maintaining running pods and providing the Kubernetes runtime environment.

---

# Built-in node components

1. `kubelet`
2. `kube-proxy`
3. Container Runtime

---

# `kubelet`

`kubelet` is a binary that runs on each node in the cluster ensuring that containers are running in a pod.

The `kubelet` binary takes a set of PodSpecs and ensures that the containers described in those PodSpecs are running and healthy.

The `kubelet` binary doesn’t manage containers which were not created by Kubernetes.

---

# `kube-proxy`

The `kube-proxy` binary is the Kubernetes network proxy runs on each node.

The `kube-proxy` binary reflects services as defined in the Kubernetes API on each node and can do simple TCP, UDP, and SCTP stream forwarding.

This is achieved by:

1. Maintaining network rules on the host.
2. Performing connection forwarding.

---

# Container Runtime

The container runtime is the software that is responsible for running containers.

Kubernetes supports several runtimes: Docker, rkt, runc and any [OCI runtime-spec implementation](https://github.com/opencontainers/runtime-spec).

---

# Let's get our hands dirty

```
$ ssh workshop@workshop-vm-xx-yy.akalipetis.com
$ ps aux | grep kube-proxy
$ ps aux | grep dockerd
$ docker ps | grep kube
```

---

# Addons

Addons are Pods and Services that implement cluster features.

These Pods may be managed by Deployments, ReplicationControllers and so on.

Namespaced addon objects are created in the `kube-system` namespace.

---

# Selected addons

- DNS
- Web UI
- Container Resource Monitoring

---

# Topology

---

# Topology

A Kubernetes cluster consists of one or more hosts.

A Kubernetes host can either be either a physical or a virtual machines.

All Kubernetes hosts should be accessible from each other in the same network.

---

# Kubernetes Master and Node combination

A Kubernetes Master can also be a Node and run workloads.

This should be avoided in production clusters though!

---

# Multiple Kubernetes Masters

High-Availability Kubernetes Masters are an **alpha feature**.

---

# Multiple Kubernetes Masters

In most cases a Kubernetes cluster will run with a single Kubernetes Master.

In a Kubernetes cluster with multiple Kubernetes Masters, each master replica will run the following components:

- `etcd`: All instances will be clustered together using consensus.
- `kube-apiserver`: Each server will talk to local `etcd` - all API servers in the cluster will be available.
- Controllers and `kube-scheduler`: Will use lease mechanism - only one instance of each of them will be active in the cluster.
- `kube-addon-manager`: Each manager will work independently trying to keep add-ons in sync.

---

# 💡 Tips for multiple Kubernetes Masters

1. Try to place master replicas in different zones.
2. Do not use a cluster with an even number master replicas.
3. When you add a master replica, speed up etcd data copying by migrating etcd data directory.

---

![Kubernetes Cluster](/presentations/kubernetes-under-the-hood/images/kubernetes-cluster.png)

---

# Ask your most weird questions!

---

class: center

# Thanks!
