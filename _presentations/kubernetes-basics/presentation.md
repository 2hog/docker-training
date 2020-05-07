layout: true
class: middle

---

# Kubernetes — get to know the basics

---

# .center[2hog]

.center[We teach the lessons we have learnt the hard way in production.]
.center[Consulting, training and contracting services on containers, APIs and infrastructure]

.footnote[https://2hog.codes]

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
class: center

# [dojo.2hog.codes](https://dojo.2hog.codes)

# [p.2hog.codes/kubernetes-basics](https://p.2hog.codes/kubernetes-basics)

---

# Agenda

1. From servers to clusters: intro to containerized infrastructure
1. Pods — what are they all about
1. Kubernetes in practice, getting to know the CLI
1. Kubernetes controllers — abstracting pods
1. Exposing applications to the world
1. Deploying as a first class citizen
1. Security principles best practices
1. Checking application health

---
class: center

# From servers to clusters: intro to containerized infrastructure

???

* We talked about running Docker containers in a single node, but we need more for production
* Kubernetes takes care of managing your whole cluster
* You don't have to know the health of each container any more
* Start knowing the health of your services

---

# What is Kubernetes?

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

--

What does that mean though?

--

Kubernetes does the following tasks for you:

* Abstracts low level resources, like containers, so that we don't have to pumper our cluster
* Automates deployment, by applying our needs and wants to inside a cluster
* Integrates with cloud providers, allowing easy access to compute and storage

---

# Core Kubernetes components

* Kubernetes API server
* Controllers
    * Kube controller manager
    * Cloud controller manager

---

# Key concepts

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

.center[![:scale 50%](/images/kubernetes-basics/kube-architecture.png)]

---

# Kubernetes Topology — a more common example

.center[![:scale 50%](/images/kubernetes-basics/kube-architecture-combined.png)]

---

# Declarative vs imperative infrastructure

--

## Say what you want, not how to achieve this

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

* Behind the scenes, Kubernetes is using a distributed KV store, based on RAFT - ETCD
* RAFT is a consensus algorithm, also used in other distributed systems like Swarm or Consul
* It needs at least N / 2 + 1 members to be able to operate
  * Always create clusters with odd number of members

---

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


* It's thought to be _easier_ to colocate two containers
* Two or more containers need to share some resources
* Your code is not configurable to find another container somewhere other than localhost

???

* The co-location and shared resources of pods, might be trick someone into merging similar containers
* This has bad consequences

---

# When to use pods

--

For implementing Sidecars.

--

* Abstraction over the network — see Istio and co
* Abstraction over the file system

???

* There are though use-cases for multi-container pods
* Sidecars
* Sidecars are containers that provide an abstraction 
* File-system refresh containers

---

# Getting our hands dirty

```bash
git clone https://github.com/2hog/docker-training-samples
```

---

# Let's create a pod

```bash
# Let's create the pause container, the one holding all the shared resources
docker run --name=pause -d -p 8080:80 -v ${PWD}:/usr/share/nginx/html k8s.gcr.io/pause
```

--

```bash
# Let's create the main container, a simple web server
docker run --name=main --network=container:pause --volumes-from=pause -d nginx:alpine
```

--

```bash
# Let's create a sidecar container to change the data
docker run --name=sidecar --network=container:pause --volumes-from=pause -it alpine sh
apk add -U curl
curl localhost:80
cat /usr/share/nginx/html/index.html
```

---

# Let's do it the Kubernetes way now

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
kubectl exec nginx --container=sidecar -it -- sh
apk add -U curl
curl localhost:80
cat /usr/share/nginx/html/index.html
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

--

```bash
kubectl get po
ssh workshop@workshop-vm-XX-Y.akalipetis.com #pass 2hog-docker
docker ps --filter=label=io.kubernetes.pod.namespace=default
```

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

# Creating and updating objects

--

* Imperatively
  ```bash
  kubectl run nginx-2 --image nginx --generator=run-pod/v1
  kubectl set image pod/nginx-2 nginx-2=nginx:latest
  ```
--
* Declaratively
  ```bash
    cat << EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-2
    spec:
      containers:
      - name: nginx-2
        image: nginx:alpine
    EOF
  ```

???

* Apply plays a major role here, using create would crash the endpoint
* Apply checks for existing resources and applies diffs, if needed

---
class: center

# Kubernetes controllers — abstracting pods

---

# So, do I always need to create pods and manage them?

--

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
kubectl delete po demo-replicaset-ft4p4
# Get them again
kubectl get po
```

???

* Initially, we see 3 pods started, the same number we selected in the replica set
* After removing one of the pods, we see that a new one gets created

---

# Creating jobs

* Run one-off tasks
* Useful for things like migrations or static assets
* Mostly used during deployments

---

# Let's create our job

```bash
kubectl apply -f kube/job-demo.yml
```

---

# Now, let's check it out

```bash
# Wait for the job
bash kube/wait-for.sh job job-demo
# Alternatively, on Kube 1.11 you can use kubectl wait
# Get the logs
kubectl logs job-demo-kddrj
```

---
class: center

# Exposing applications to the world

---

# Let's see our replica set demo containers

* Kubernetes is using services, in order to abstract the access to a set of pods
* We don't need to be aware of the IPs and status of pods at each point it time

---

# Let's expose our first replica set

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

```bash
kubectl get svc demo-replicaset
curl -I workshop-vm-XX-1.akalipetis.com:PORT
curl -I workshop-vm-XX-2.akalipetis.com:PORT
curl -I workshop-vm-XX-3.akalipetis.com:PORT
```

???

* No matter which node you are in, the port opens
* This is because Kubernetes has ingress load balancing
* You can also open the external IP, port of a node

---

# Kubernetes load-balancing

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
kubectl exec nginx --container=sidecar -it -- sh
apk add -U bind-tools
host demo-replicaset
dig demo-replicaset.default.svc.cluster.local
```

---
class: center

# Deploying as a first class citizen

---

# Kubernetes deployments

Deployment controllers apply changes to pod controllers which apply changes to pods

--

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
* Scale outs (and ins)
* Check out deployment status
* Keep revisions of deployments

---

# Let's see it in action


```bash
kubectl apply -f kube/deployment-demo.yml
kubectl rollout status deployment demo-deployment
kubectl get svc demo-deployment-svc
curl http://workshop-vm-XX-Y.akalipetis.com:PORT
```

???

We will now take the previous Replica Set and include it in a deployment

---

# Updating the deployment

```bash
# Edit kube/deployment-demo.yml first
kubectl apply -f kube/deployment-demo.yml
kubectl rollout status deployment demo-deployment
curl http://workshop-vm-XX-Y.akalipetis.com:PORT
```

--

_Cool tip_: naming ports allows deployments to use different ports, without an issue!

---

# Breaking things

```bash
kubectl set image deployment demo-deployment web=akalipetis/headers
kubectl rollout status deployment demo-deployment
```

---

# How to get to a previous state

* Kubernetes deployments keep the history of each deployment
* Let's head to the previous version!

---

# Rolling back

To fix things...

```bash
kubectl rollout undo deployment demo-deployment
kubectl rollout status deployment demo-deployment
# Or to a specific version
# kubectl rollout undo deployment demo-deployment --to-revision=2
kubectl rollout history deployment demo-deployment
kubectl apply -f kube/deployment-demo.yml --record
```

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

# RBAC in Kubernetes

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

# How service accounts work

* Service accounts create the needed files in `/var/run/secrets/kubernetes.io/serviceaccount/`
* The files created contain the `namespace` and the `token`

```bash
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

.center[![](/images/intro-docker-kubernetes/mars-rover.png)]

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
