layout: true
class: middle

---

# Kubernetes Networking

---


# About 2hog.codes

* Founders of [SourceLair](https://www.sourcelair.com) online IDE
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

class: center

# [p.2hog.codes/kubernetes-networking](https://p.2hog.codes/kubernetes-networking)

---

# Agenda

* Kubernetes networking topology
* Services
* Service meshes

---

# Let's get the code

```console
git clone https://github.com/2hog/kubernetes-networking
cd kubernetes-networking
```

---
class: center

# Kubernetes networking topology

![](/images/kubernetes-networking/networking.jpg)

---

# What problems is Kubernetes networking trying to solve

* Highly-coupled container-to-container communications
* Pod-to-Pod communications
* Pod-to-Service communications
* External-to-internal communications

---

# The Kubernetes networking model

--

* Kubernetes supports everything implementing the CNI
* All Pods and Nodes in the cluster are routable within a flat network
  * That means that there's no network separation and thus all workloads should be trusted, or resources secured
* Every Pod gets an IP
* Pods and nodes get DNS names, which work inside the cluster

???

* Sensitive resources should be secured
* There are ways to handle that, but out of topic for this course

---

# Hello, CNI

CNI (Container Network Interface), a Cloud Native Computing Foundation project, consists of a specification and libraries for writing plugins to configure network interfaces in Linux containers, along with a number of supported plugins.

---

# Networking fundamental requirements

* All containers can communicate with all other containers without NAT
* All nodes can communicate with all containers (and vice-versa) without NAT
* The routable IP of the container is the one that the container sees internally

???

Kubernetes has a flat networking model
There is no restriction for which containers can communicate with which containers within the cluster
This imposes possible security issues, more on that later

---

# How to implement networking within the cluster

1. Supply the underlay network
2. Pick the network plugin of choice
3. Deploy the networking plugin in the cluster

---

# Network plugin examples

* BPF, in-kernel routing — ie Cillium
* Using provider routing tables and ipvlan — ie cni-ipvlan-vpc-k8s and GCE
* IPVS/LVS routing — ie Kube-router
* Overlay — ie Romana or Weave

---

# Let's see how network plugins are deployed

```console
kubectl get pod -n kube-system
kubectl describe pod -n kube-system weave-net-hlc5g
```

???

Network plugins are just pods, deployed in Kubernetes
A Kubernetes cluster can exist without a network plugin, but pods cannot be scheduled to nodes
That's why Weave has the `node.kubernetes.io/network-unavailable:NoSchedule` toleration

---

# Our current networking setup

* Digital Ocean private network as underlay
* Weave as Kubernetes network plugin

---

# Let's reach a pod

```console
# Run an NGINX pod
kubectl run nginx --image=nginx --generator=run-pod/v1
# Get the IP and hit NGINX's port 80
kubectl describe pod nginx | grep IP
curl 10.44.0.2
```

---

# Pod networking

* Every Pod has it's own localhost
* Network namespace it initialized by the pause container
* Pod containers are attached to the same network namespace

---

# Pod networking

```console
# workshop-vm-XX-01
docker ps | grep nginx
# inspect the pause container
docker inspect c73aa1644001
# inspect the nginx container and search for NetworkMode
docker inspect 35a40f6dbdb3
```

???

The Pod created two containers, while we just requested one
The two containers have the same network interface — this is just for the initialization of the network namespace
https://github.com/kubernetes/kubernetes/tree/v1.19.4/build/pause

---

# Pod networking

```console
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-sleepy
spec:
  containers:
  - name: nginx
    image: nginx:alpine
  - name: sleepy
    image: alpine
    command:
    - sleep
    - "3600"
EOF
```

---

# Pod networking

```console
kubectl exec nginx-sleepy -c sleepy -it sh
apk add -U curl
curl localhost
netstat -tulpn
exit
kubectl exec nginx-sleepy -c nginx netstat -tulpn
```

???

While we're in a different container within the pod, we can hit localhost hitting the main container
We cannot see the PID of the process opening the port though, since we're in a different container

---
class: center

# Services

---

# Getting through Pod mortality

* Pods are ephemeral, they might be created and destroyed in a fast pace
* A service can be consisted of one or more Pods
* The number of Pods might change, due to many different factors

---

# Say hello to Services

Services are an abstraction, which defines a logical set of Pods and an access policy

---

# Kubernetes Services

* API objects
* Use a label selector for choosing the related Pods
* For every Pod added or removed, Endpoints pointing to the remaining Pods are created

---

# Kubernetes Service load-balancing

--

* Each Service in the Kubernetes gets a virtual IP
  * Kubernetes Services make sure connections to this internal IP are routed to the correct container, in any host in the cluster
* Multi-host networking is made with CNI plugins
* If desired, services can integrate with external load balancers or simply open a port to each node in the cluster
  * Connections, as soon as they enter the cluster, are routed in the exact same way

???

Benefits:
* You don't need to know where in the cluster every pod runs
* You don't need to do health management

---

# Label selectors in action

```console
# Create a single Pod and a service
kubectl apply -f nginx-selected.yml
kubectl apply -f service.yml
kubectl describe svc my-service | grep IP:
curl 10.101.9.233
```
--

```console
# Add another Pod with the same selector
kubectl apply -f web-selected.yml
curl 10.101.9.23
```

--

```console
# Change target port to "web", instead of a specific number
kubectl apply -f service.yml
```

???

* Services target pods using label selectors
* They can either target a specific port, or a named port
  * This allows services to transition between different pods seamlessly, even if they change ports

---

# How do Kubernetes Services work

* They sit in front of Pods, exposing a Cluster-routable IP
* When TCP connections are made to this IP, then kube-proxy takes control to move the traffic to one of the Pods

---

# Service types

* `ClusterIP` — the default one, only exposing an internal IP
* `NodePort` — also exposing a port on each node
* `LoadBalancer` — integrated with a cloud provider, exposing a static public IP for a Kubernetes service
* `ExternalName` — just a dummy CNAME record to an external DNS record
* `Headless` — exposing multiple A records, one for each Pod, without the intermediate proxying

---

# `NodePort` use cases

* Expose ports 80 and 443, without the need of an external load balancer or static IP
* Expose service to alternative ports, like an SSH or FTP service
* Expose a service, adding it behind a load balancer when the `LoadBalancer` integration does not exist

---

# `LoadBalancer` use cases

* The most common use case, exposing a Kubernetes service to a static IP
* Usually, one should use this one for exposing the public facing services within a Kubernetes cluster

---

# `ExternalName` use cases

* Mostly used for transitioning from an external service, to a Kubernetes one
* Initially, this service points to an external domain
* When the service is deployed within the cluster, the service type can be updated to point to the newly deployed Pods

---

# `Headless` use cases

* Used when there's a complicated way that sessions should be handled

---

# Discovering Services

* Service information is exposed to the environment
  ```console
  kubectl exec web-selected printenv | grep SERVICE
  ```
* Service IP can be easily queried from a known DNS record
  ```console
  kubectl exec web-selected -it bash
  apt update && apt install -y dnsutils
  dig my-service.default.svc.cluster.local
  ```


In order for the DNS records to work, CoreDNS should be configured

---

# How is DNS resolved in Kubernetes

* Services
    * A record: `my-svc.my-namespace.svc.cluster.local`
        * Multiple A records for "headless" services
    * SRV record: `_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local`
* Pods
    * A record: `pod-ip-address.my-namespace.pod.cluster.local`

---

# Service DNS records in Kubernetes

* Each Service gets a `my-svc.my-namespace.svc.cluster.local` A record
* And a `_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local` SRV record

---

# Special cases in Services DNS records

* Headless services return multiple answers for their A record, one for each Pod
* StatefulSets also include the following A records `my-statefulset-{0..N-1}.my-svc.my-namespace.svc.cluster.local`

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

```console
kubectl exec nginx --container=sidecar -it sh
apk add -U bind-tools
host demo-replicaset
dig demo-replicaset.svc.default.cluster.local
```

---

# A bit deeper on Service routing

* userspace proxy-mode — opens a random port on each node and traffic flows through that port
* iptables proxy-mode — endpoints are matched with iptables rules, this is the default mode
* ipvs proxy-mode — still in beta, uses IPVS for routing connections and has more options for balancing algorithms

???

IPVS algorithms

* rr: round-robin
* lc: least connection
* dh: destination hashing
* sh: source hashing
* sed: shortest expected delay
* nq: never queue

---

# Making connections more sticky

* Services also support `sessionAffinity`, making connections sticky
* Session affinity can be either based on client IP, or a cookie

---

# Things to keep in mind when using Services

* usermode proxying does not scale very well in large clusters
* source IP information might be lost if a request passes through a service (ie in usermode, or in iptables when coming from the outside)
* Using services without proper Readiness or Liveness probes loses a lot of the good things

---

# Adding policy to network connections

* Kubernetes supports network policies
* The implementation of those policies though, is left to the network plugin

---

# How does a network policy work

* Selects pods using label selectors
* Adds a list of ingress/egress policy rules

--

```yaml
  ...
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          user: alice
    - podSelector:
        matchLabels:
          role: client
  ...
```

---

# Let's see this in action

```console
kubectl exec nginx-selected -it sh
apk add -U curl
curl -I www.google.com
exit

kubectl apply -f policy.yml
kubectl exec nginx-selected -it sh
curl -I https://13.91.101.219 -k
```

---

# How does Weave implement network policies

* Weave is using iptables on the host machine to implement the network policies
* This is great, but it's not ideal since there's no security on the Pod level and there are many iptable rules needed

???

A better alternative could be to implement those policies on the Pod level, using something like Istio

---
class: center

# Service meshes

![](/images/kubernetes-networking/blue-red-pill.jpeg)

---

# Kubernetes networking issues

* Flat network means that every Pod is accessible from any other Pod in the cluster
* Connections between Pods are not encrypted
* Load balancing is good, but might not be great for some use cases

---

# Enter the service mesh

A service mesh is a dedicated infrastructure layer for making service-to-service communication safe, fast, and reliable.

.footnote[[Buoyant blog](https://blog.buoyant.io/2017/04/25/whats-a-service-mesh-and-why-do-i-need-one/)]

---

# What is the service mesh consisted of

* A data plane full of intelligent proxies
* A control plane, fully integrated with the Kubernetes API, managing those proxies

---

# What does a Service Mesh actually do

* Provide rich metrics on the network traffic within the cluster
* Secure and encrypt connections between Pods
* Apply network access policies
* Out of the box load balancing and health checking

---

# Service Mesh implementations

* Istio — IBM and Google, CNCF member project
* Linkerd — Buoyant, CNCF member project

---

# How is a Service Mesh deployed

* The control plane is deployed as Kubernetes resources
* The data plane, is either automatically injected, or added "by hand"

---

# Let's deploy a service mesh

```console
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin
linkerd check --pre
linkerd install | kubectl apply -f -
kubectl edit svc -n linkerd linkerd-web
```

---

# Let's go through the dashboard quickly

Open http://workshop-vm-XX-00.akalipetis.com:8084

---

# Let's inject our first deployment

```console
linkerd inject deployment.yml | kubectl apply -f -
```

---

# What did just happen

* An init container was injected, to set up everything for Linkerd proxy
* The Linkerd proxy was deployed alongside our container

```console
kubectl edit deployments env-example-deployment
```

---

# Big wins

* No need for any change to our service
* Quick and easy overview of what is happening

---

# TLS without the hassle

```console
linkerd install --tls=optional | kubectl apply -f -
linkerd stat authority -n linkerd
```

---

# Thanks!
