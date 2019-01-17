layout: true
class: middle

---

# Introduction to Docker and Kubernetes

---

# About 2hog.codes

* Founders of [SourceLair](https://www.sourcelair.com) online IDE + Dimitris Togias
* Docker and DevOps training and consulting

---

# Antonis Kalipetis

* Docker Captain and Docker Certified Associate
* Python lover and developer
* Technology lead at SourceLair, Private Company

.footnote[[@akalipetis](https://twitter.com/akalipetis)]

---

# Paris Kasidiaris

* Python lover and developer
* CEO at SourceLair, Private Company
* Docker training and consulting

.footnote[[@pariskasid](https://twitter.com/pariskasid)]

---

# Dimitris Togias

* Self-luminous, minimalist engineer
* Co-founder of Warply and Niobium Labs
* Previously, Mobile Engineer and Craftsman at Skroutz

.footnote[[@demo9](https://twitter.com/demo9)]

---
class: center

# [p.2hog.codes/intro-docker-containers](https://p.2hog.codes/intro-docker-containers)

---

# Agenda

1. From servers to clusters: intro to containerized infrastructure
1. Pods — what are they all about
1. Kubernetes in practice, getting to know the CLI
1. Kubernetes controllers — abstracting pods
1. Exposing applications to the world
1. Deployments as a first class citizen
1. Security principles best practices
1. RBAC in Kubernetes
1. Checking application health in Kubernetes

---

class: center

# What is a Container?

Containers are a set of **kernel tools and features** that **jail** and **limit** a process based on our needs.

---

# Virtuals Machines vs. Containers?

They should co-exist. We should run N Containers in M Virtual Machines (N > M).

Imagine a Virtual Machine as a multi-floor building and a Container as a rented flat.

- **Virtual Machines** provide deep isolation, so they are heavy and not versatile
- **Containers** are fast and lightweight

???
* They share the same plumbing
* Each flat has its own limits
* They all must cooperate for the good operation of the building

VS

* You have your own pool
* You can turn up the heat whenever you want
* Comes at a cost
* Fixing infrastructure issues is more time and money consuming

---

# What is a Container? (in a bit more details)

* It’s a process
* Isolated in it’s own world, using **namespaces**
* With limited resources, using **cgroups**

---

# Namespaces

.center[A **namespace** wraps a global system resource in an abstraction that makes it appear to the processes within the namespace that **they have their own isolated instance of the global resource**. Changes to the global resource are visible to other processes that are members of the namespace, but are invisible to other processes. One use of namespaces is to **implement containers**.]

.footnote[The Linux man-pages project:<br />http://man7.org/linux/man-pages/man7/namespaces.7.html]

---

# Popular Namespaces

* net
* mnt
* user
* pid

---

# cgroups

.center[**cgroups** (abbreviated from control groups) is a Linux kernel feature that **limits, accounts for, and isolates** the resource **usage** (CPU, memory, disk I/O, network, etc.) of a collection of processes.]

.footnote[Wikipedia:<br />https://en.wikipedia.org/wiki/Cgroups]

---

# Popular cgroups

* memory
* cpu/cpuset
* devices
* blkio
* network*

.footnote[*network is not a real cgroup, it’s used though for metering]

---

# Let's run our first container

```bash
docker run -it alpine sh
```

--

```bash
whoami
uname -a
top
exit
```

---

# What did just happen?

--
* The Alpine image was pulled

--
* A new container (aka a process) was started using that image

--
* The process was isolated is its own namespace

--
* A TTY was opened for us, so we could run commands

---

# Deconstructing `docker run`

- `docker`: Invokes the Docker Engine client
- `run`: Instructs `docker` to run a container
- `node:8-alpine`: The image to use as root file system
- `node --version`: The command that should be run as a container

https://docs.docker.com/engine/reference/commandline/run/

---

# Docker Images

The basis for Docker Containers

* They provide the root file system for a Docker Container
* They contain the meta data needed to run (e.g. exposed ports, health check instructions etc.)
* They are structured in sequential layers
* They are distributed via Docker Registry instances (mostly via [https://hub.docker.com/](https://hub.docker.com/))

---

# Let's create our first image

--

In order to create a Docker image, we need each recipe - the Dockerfile

[https://git.io/vdhKH](https://git.io/vdhKH)

---

# The `Dockerfile`

The Dockerfile is a text file that contains all commands needed to build an image.

*(The Dockerfile plays the same role as a recipe for a food)*

## Example

```dockerfile
FROM openjdk:8

COPY Main.java /usr/src/app/Main.java
WORKDIR /usr/src/app
RUN javac Main.java
CMD ["java", "Main"]
```

.footnote[https://docs.docker.com/engine/reference/builder/]

---

# Building our Docker Image

Run the following command to build our Docker Image, based on the Dockerfile and run a container with it.

*(The Docker Image plays the same role as the cooked food of the recipe)*

## Example

```bash
docker build -t myjava .
docker run myjava
```

---

# Deconstructing `docker build`

- `docker`: Invokes the Docker Engine client
- `build`: Instructs `docker` to build a new image
- `-t myjava`: Give the name `myjava` to the resulting image
- `.`: Use the current directory to find the Dockerfile and needed files

https://docs.docker.com/engine/reference/commandline/build/

---

# Dockerfile, image and container

* Dockerfile -> Source code - the recipe to build an image
* Image -> Class - the actual, built output of the Dockerfile
* Container -> Object - the thing that runs

---

# The container best-practice list

--

1. Containers should be considered ephemeral
2. The container should be single-purposed program (e.g. avoid using `supervisord`)
3. The image should be lightweight and slim
4. Configuration should be made by the environment, with sane defaults
5. Orchestration should be carried out by an external tool

???

* Following these principles and good practices, allows for better management and utilization of the underlying infrastructure
* This also imposes some issues

---
class: center

# From servers to clusters: intro to containerized infrastructure

???

* We talked about running Docker containers in a single node, but we need more for production
* Kubernetes takes care of managing our whole cluster
* You don't have to know the health of each container any more
* Start knowing the health of your services

---

# What is Kubernetes?

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

---

# What does that mean though?

--

Kubernetes does the following tasks for you:

* Abstracts low level resources, like containers, so that we don't have to pumper our cluster
* Automates deployment, by applying our needs and wants to inside a cluster
* Integrates with cloud providers, allowing easy access to compute and storage

---

# Core Kubernetes components

--

* Kubernetes API server
* Controllers
    * Kube controller manager
    * Cloud controller manager

---

# Key concepts

--

* Master node(s)
  * The server(s) responsible for meta data storage, API availability and decision making
* Worker nodes
  * The server(s) that are used to run workloads, decided by the management plane
* Pods
  * A collection of one or more containers, the atom of Kubernetes workloads
* Controllers
  * Components responsible for creating or removing pods, based on certain criteria
* Services
  * Logical sets of Pods with an access policy, abstracting the mortallity of Pods

---

# Kubernetes Topology

.center[![:scale 50%](/images/intro-docker-kubernetes/kube-architecture.png)]

---

# Kubernetes Topology — a more common example

.center[![:scale 50%](/images/intro-docker-kubernetes/kube-architecture-combined.png)]

---

# Declarative vs imperative infrastructure

Say what you want, not how to achieve this

---

# A simple example

* _Declarative:_ I want a coffee, sweet, without milk
--

  * ...never drink sweet coffee, but ¯\\_(ツ)_/¯
--


VS

--

* _Imperative:_ I want you to take the beans, ground them, boil water and then mix them. Then, add some sugar and give it to me.

---

# A bit more on declarative infrastructure

* It's easier for the user, as long as the software is logical
* All the state is saved within the cluster
* The cluster continuously tries to make sure that the declared state and the current state of the cluster are a match

---

# Where is everything stored?

--

* Behind the scenes, Kubernetes is using a distributed KV store, based on RAFT - ETCD
* RAFT is a consensus algorithm, also used in other distributed systems like Swarm or Consul
* It needs at least N / 2 + 1 members to be able to operate
  * Always create clusters with odd number of members

---
exclude: true

.center[<iframe src="https://raft.github.io/raftscope/index.html" style="border: 0; width: 800px; height: 580px; margin-bottom: 20px"></iframe>]

---
class: center

# Pods — what are they all about

---

# What is a Pod?

* The atom of Kubernetes
* Every pod is a collection of one or more containers, with shared resources:
  * Network
  * Storage
  * Lifecycle

???

* Pods are the building block of Kubernetes
* They are the minimum deployable unit
* Single-container pods are the most common example, but there are use cases for multi-container pods

---

# When **not** to use pods

???

* The co-location and shared resources of pods, might be trick someone into merging similar containers
* This has bad consequences

--

* It's thought to be _easier_ to colocate two containers
* Two or more containers need to share some resources
* Your code is not configurable to find another container somewhere other than localhost

---

# When to use pods

???

* There are though use-cases for multi-container pods
* Sidecars
* Sidecars are containers that provide an abstraction 
* File-system refresh containers

--

For implementing Sidecars.

* Abstraction over the network — see Istio and co
* Abstraction over the file system

---

# Getting our hands dirty

```bash
ssh workshop@workshop-vm-XX-00.akalipetis.com
git clone https://github.com/2hog/docker-training-samples
```

---

# Let's create a pod

```bash
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: main
    image: nginx:alpine
  - name: sidecar
    image: alpine:latest
    args:
      - "sleep"
      - "3600"
EOF
```

---

# And check it out

```bash
kubectl exec nginx --container=sidecar -it sh
apk add -U curl
curl localhost
```

---
class: center

# Kubernetes in practice, getting to know the CLI

---

# Kubernetes objects

Everything is an object

???

As we saw before, when deploying a Kubernetes pod, we created a file with a Kind

---

# Kubernetes API

* universal, allowing the user to manage all objects in the same way
* versioned, separating stable from experimental objects
* easy to navigate

---

# Kubernetes objects

* Everything has a `kind` and a `spec`
* Sample object definition:
  ```yaml
  apiVersion: the API version to use
  kind: the type of the object to create
  metadata:
    name: ...
    ...
  spec: the desired state
  ```

???

* Kind is like the class of the object, Kubernetes knows how to handle it
* Meta data, is information that Kubernetes will use to better identify the object to be created
* Spec is the desired state that we want this object to reach, after the object is created, Kubernetes has controllers that will reconcile it

---

# Listing and inspecting objects

* Use any abbreviation, singular or plural of a resource type
* `kubectl get po`
* `kubectl get pod`
* `kubectl get pods`

---

# What's running on our machine though?

```bash
docker ps
kubectl get po
```

--

Where all those containers running?

---

# Enter Kubernetes namespaces

* Namespaces are logical resource groups
* They provide no security or isolation, they are there for organization only
* Name uniqueness for example, is enforced per namespace

--

```bash
kubectl get ns
kubectl get po --all-namespaces
kubectl get po --namespace=kube-system
```

---

# Enter Kubernetes namespaces

* Kubernetes has namespaced and global resources
* By default, resources are created and viewed on the default namespace
* Kubernetes comes with `kube-public` and `kube-system` namespaces baked in
* View all namespace `kubectl get ns`
  * Namespaces are objects!

---

# Inspecting objects

```bash
# Inspect a namespace, with YAML output!
kubectl get ns kube-system --output=yaml
# Or a pod, on a different namespace
kubectl get po --namespace kube-system kube-dns-86f4d74b45-8hr4v
# Or even all services on all namespaces and also watch them
kubectl get services --all-namespaces --watch
```

---
class: center

# Kubernetes controllers — abstracting pods

---

# So, do I always need to create pods and manage them?

Of course not!

---

# Kubernetes controllers

Controllers are management components of Kubernetes, which abstracts the way workloads are deployed

---

# Kubernetes controllers

* ReplicaSet — the default one, makes sure the given number of replicas are deployed at each point in time
* StatefulSet — makes deploying stateful services easier, by assigning sticky identities and giving guarantees to make this happen
* DaemonSet — runs specific workloads on (almost) every node in the cluster
* Jobs — fire oneoff tasks
* CronJob — run repeated tasks based on a cron schedule

---

# Deploying a ReplicaSet

* Define the replicas to run
* Define the template of the pods to create

--

```bash
kubectl apply -f kube/replicaset-demo.yml
```

---

# Let's see it in action

```bash
# Get all the running pods
kubectl get po
# Kill one of them
kubectl delete po dummy-replicaset-ft4p4
# Get them again
kubectl get po
```

???

* Initially, we see 3 pods started, the same number we selected in the replica set
* After removing one of the pods, we see that a new one gets created

---
class: center

# Exposing applications to the world

---

# Let's see our replica set demo containers

--

* Kubernetes is using services, in order to abstract the access to a set of pods
* We don't need to be aware of the IPs and status of pods at each point it time

---

# Let's create our first replica set

```bash
kubectl expose replicaset demo-replicaset --type=NodePort
kubectl get services
```

---

# What is a service?

* A Kubernetes `Service` is an abstraction which defines a logical set of Pods and a policy by which to access them
* Simply put, is just a virtual cluster IP, which load balances traffic to all pods selected

--

How are pods _selected_ then?

--

```bash
kubectl get svc replicaset-demo --output=yaml | less
kubectl get po demo-replicaset-8ksqx --output=yaml | less
```

???

* Services are usually — especially in the beginning — mapping 1-1 the resources we deploy
* Later on, they can be used for things like blue green deployments, service different portions of traffic to different deployments, etc

---

## Let's check this out

???

* No matter which node you are in, the port opens
* This is because Kubernetes has ingress load balancing

--

```bash
curl localhost:`kubectl \
  get svc demo-replicaset \
  --output=json | jq '(.spec.ports)[0].nodePort'`
```

???

You can also open the external IP, port of a node

---

# Kubernetes load-balancing

--

* Each service in the Kubernetes gets a virtual IP
  * Kubernetes services make sure connections to this internal IP are routed to the correct container, in any host in the cluster
* Multi-host networking is made with CNI plugins
* If desired, services can integrate with external load balancers or simply open a port to each node in the cluster
  * Connections, as soon as they enter the cluster, are routed in the exact same way

???

Benefits:
* You don't need to know where in the cluster every pod runs
* You don't need to do health management

---

# The Kubernetes networking model

--

* Kubernetes supports everything implementing the CNI
* All pods and nodes in the cluster are routable within a flat network
  * That means that there's no network separation and thus all workloads should be trusted, or resources secured
* Every pod gets an IP
* Pods and nodes get DNS names, which work inside the cluster

???

* Sensitive resources should be secured
* There are ways to handle that, but out of topic for this course

---

# How is DNS resolved in Kubernetes

* Services
    * A record: `my-svc.my-namespace.svc.cluster.local`
        * Multiple A records for "headless" services
    * SRV record: `_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local`
* Pods
    * A record: `pod-ip-address.my-namespace.pod.cluster.local`

---

# Search domains

Except from the full DNS records, you can also search the following DNS names

* Services within the same namespace
  * `svc` will resolve to `svc.the-namespace.cluster.local` when queried from a pod in this namespace
* Services within the same cluster
  * `svc.the-namespace` will resolve to `svc.the-namespace.cluster.local`, even when queried from other namespaces in the same cluster

???

* The `cluster.local` suffix is there to support cluster federation in the future
* Clusters could potentially be in the same address space
* Search domains allow for simplifying the configuration of applications, within the same namespace
* There are times where applications do not respect search domains, be careful with that

---

# Let's check out DNS resolution in Kubernetes

```bash
kubectl exec nginx --container=sidecar -it sh
apk add -U bind-tools
host demo-replicaset
dig demo-replicaset.svc.default.cluster.local
```

---
class: center

# Deployments as a first class citizen

---

# Kubernetes deployments

Deployment controllers apply changes to pod controllers which apply changes to pods

_Simple enough?_

---

# What are deployments after all?

Deployments describe a desired state and the Deployment controller changes the _actual state_ to the _desired state_ at a **controlled rate**.

--

You can think of the abstractions like this:

* Pod
* Pod controller (ReplicaSet, Job, DaemonSet, etc)
* Deployment

---

# What can I do with deployments?

* Rolling updates
* Rollbacks
* Scale ups (and downs)
* Check out deployment status
* Keep revisions of deployments

---

# Let's see it in action

```bash
kubectl apply -f kube/deployment-demo.yml
kubectl rollout status deployment demo-deployment
curl http://localhost:`kubectl get svc demo-deployment-svc --output=json | jq '(.spec.ports)[0].nodePort'`
```

???

We will now take the previous Replica Set and include it in a deployment

---

# Updating the deployment

```bash
# Edit kube/deployment-demo.yml first
kubectl apply -f kube/deployment-demo.yml
kubectl rollout status deployment demo-deployment
curl http://localhost:`kubectl get svc demo-deployment-svc --output=json | jq '(.spec.ports)[0].nodePort'`
```

--

_Cool tip_: naming ports allows deployments to use different ports, without an issue!

---
class: center

# Security principles best practices

---

# Securing pods

* Run pods as non-root users
* Make the pod filesystem readonly
* Do not add capabilities that are not needed to pods

---

# Securing services within the cluster

* Services and pods within a cluster are accessible from any pod
* If untrusted pods are run, or if user-facing services exist with lesser access control, services should be secured even if they are internal

---

# Securing services within the cluster

* Adding TLS connection support
* Using API keys and other credential types
* Using tools like Istio to control and secure connections between applications

---
class: center

# RBAC in Kubernetes

--

* Every pod in Kubernetes gets a service account
* Since the Kubernetes API is routable from every pod, without RBAC the cluster is completely vulnerable

---

# Defaults

* `kubeadm` created a cluster where pods by default do not have access
* The Kubernetes API is secured with HTTPS

---

# RBAC roles in Kubernetes

* Roles define permissions in a Kubernetes cluster
* Permissions for roles are additive (ie whitelist)
* There are two types of Roles in Kubernetes
    * `Role` — defines roles, operating within one namespace
    * `ClusterRole` — defines roles, operating cluster wide

---

# Binding roles to users and service accounts

* `RoleBinding` binds `Role`s to users or service accounts
* `ClusterRoleBinding` binds `ClusterRole`s to users or service accounts
* `ClusterRole` can operate as a `Role` and bound with a `RoleBinding`

---

# Checking out the dashboard `Role` and `RoleBinding`

* https://github.com/kubernetes/dashboard/blob/master/src/deploy/recommended/kubernetes-dashboard.yaml
* https://gist.githubusercontent.com/akalipetis/968a29bd42b7944f788cb6332b480b62/

---

# How service accounts work

* Service accounts create the needed files in `/var/run/secrets/kubernetes.io/serviceaccount/`
* The files created contain the `namespace` and the `token`

```bash
# [workshop-vm-XX-00]
kubectl -n kube-system exec weave-net-c9kzt -c weave -it sh
ls /var/run/secrets/kubernetes.io/serviceaccount/
```

---
class: center

# Checking application health in Kubernetes

---

# What if the process is running, but my application does not respond?

* A running process does not indicate a responsive application
* There are many reasons why an application might be running, but not responding

???

* An application might be simply stuck
* An application might be working, but some backing services or connections might be broken

---

# Enter health probes

Earth to Mars, are you alive?

![](/images/intro-docker-kubernetes/mars-rover.png)

---

# Earth to Mars, are you alive?

* Health probes define a custom way for Kubernetes to understand if a container is healthy
* They are quite flexible and should match any logic
* When health probes fail, containers get restarted

???

This allows us to make sure our application is responding correctly

---

# Command probe

* Run an arbitrary command
* Check if the exit code is 0 or not

---

# HTTP GET probe

* Do an HTTP GET request, with the given parameters
* 2XX and 3XX codes are considered success
* 4XX and 5XX codes are considered failure

---

# TCP probe


* The are times where we just want to test a TCP connection
* Using an exec probe is not an option, since we don't want to use a client, or a client is not available


Enter the TCP probe, which just checks if a TCP connection can be made

---

# Ready VS healthy

--

* What if we have different tolerance when an application starts?
* What if we want to make a more complex check before we consider an application ready

---

# Readiness probes

* Same as the liveness probes
* Should be successful before an application is considered ready
* The probe syntax is identical

---
class: center

# Thanks!
