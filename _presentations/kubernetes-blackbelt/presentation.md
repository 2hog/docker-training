layout: true
class: middle

---
class: center

# Kubernetes - Blackbelt

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

# [p.2hog.codes/kubernetes-blackbelt](https://p.2hog.codes/kubernetes-blackbelt)

---

# Agenda

* Where do Pods come from?
* Pods, with a twist
* How do my Pods get placed?
* Messing with the Kubernetes API
* Open convo on random Kubernetes and container stuff

---

.center[# Where do Pods come from?]

.center[![](/images/kubernetes-blackbelt/its-a-girl.jpg)]

.footnote[<a href="https://www.freepik.com/free-photos-vectors/background">Vector created by Freepik</a>]

---

# Let's get the code

```bash
git clone https://github.com/2hog/docker-training-samples
```

---

# Kubernetes controllers

* Kubernetes saves declared state in etcd
* Controllers are the components that pickup the declared state, compare it with the current state and create Pods
* Each controller has a different strategy and is meant for a different use case

---

# ReplicaSet (or ReplicationController)

* Makes sure that the given number of replicas is running at all times within the cluster
* Is a low level controller, that you will probably not use directly

???

ReplicationControllers are the predecessor of ReplicaSets

---

# ReplicaSet (or ReplicationController)

```bash
# Actually, a replication controller, but 🤷‍
kubectl run nginx --image=nginx --replicas=5 --generator=run/v1
kubectl get po -w
```

???

Try deleting a Pod and see it re-created

---

# DaemonSet

* Runs a Pod to each Node
* It is usually used in order to deploy services that need to run on every Node (or a set of Nodes)
* Most common applications are log collectors, node metrics exporter, or storage providers

---

# StatefulSet

* Used to manage stateful applications in Kubernetes
* Provides guarantees on the ordering and the uniqueness of the created pods
* Gives a sticky identity to each pod

---

# StatefulSet guarantees

* Stable, unique network identifiers
* Stable, persistent storage
* Ordered, graceful deployment and scaling
* Ordered, automated rolling updates

---

# StatefulSet updates

* Ordered creation and termination is guaranteed
  * Every new pod gets created only after the previous one is ready
  * Every pod is removed only after the next one has been removed
* Rolling updates take down and update each pod one by one

---

# Deployment

* They are a higher level abstraction, as they do not directly manage Pods
* Deployments provide a declarative updates to ReplicaSets
* They enable a controlled change rate, between two different states

--

Deployments create two ReplicaSets and gradually reduce the replicas of the old one and increase the replicas of the new one at a controlled change rate.

---

# How much control do we have over this?

* We can choose between Recreate and Rolling update strategies
* We can define the number or percentage of Pods to be created
* We can define the number or percentage of Pods to be unavailable
* We can define the time the Deployment waits before being failed
* We can define the time the deployment waits before a Pod is considered healthy

???

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

---

# Let's see a deployment in action

```bash
kubectl apply -f kube/deployment-demo.yml
kubectl get svc demo-deployment-svc
# Open http://workshop-vm-XX-01.akalipetis.com:PORT/
```

---

# A rolling update in action

```bash
kubectl edit deploy demo-deployment
# change image to akalipetis/headers and containerPort to 5000
```

---

# See the history of a deployment and rollback

```bash
kubectl rollout history deploy demo-deployment
kubectl rollout undo deploy demo-deployment
kubectl rollout status deploy demo-deployment
```

---

# Zero downtime deployments in Kubernetes

* Nothing comes for free
* But we have good tooling to get around it

---

# Zero downtime deployments in Kubernetes

* Health checks allows services to better route traffic to healthy Pods only
* Deployments can make sure that even if things go south, there will be remaining replicas to service traffic
* Health is also taken into account by Deployments

???

* Add a healthcheck to the Pods
```
    livenessProbe:
      httpGet:
        path: /
        port: web
      initialDelaySeconds: 5
      periodSeconds: 5
```

---
class: center

# Pods, with a twist

![](/images/kubernetes-blackbelt/twist.jpg)

---

# Sidecars

Containers that run alongside the main containers of the Pod, to provide additional functionality

---

# Sidecar examples

* Smart proxy, like Envoy, to better route traffic
* ConfigMap watcher, which reloads the main application when the file changes
* A container that can 

---

# A Pod's security context

* By default, Pods have reduced capabilities and permissions
* In specific use cases, we might need to increase or reduce even more those capabilities

---

# The principle of least privilege

* Ideally, every Pod should have access to as little as possible within the system
* Well-tuned Pods, should use a white-listing approach
* There's pretty powerful tooling for the job, like Linux Capabilities, seccomp and AppArmor

???

Linux Capabilities: Give a process some privileges, but not all the privileges of the root user.
AppArmor: Use program profiles to restrict the capabilities of individual programs.
Seccomp: Filter a process’s system calls.

https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

---

# Read-only Pods

```bash
echo "apiVersion: v1
kind: Pod  
metadata:  
  name: readonly-sleepy 
spec:  
  containers:
  - name: sleepy
    image: alpine
    command:
    - sleep
    - '600'
    securityContext:
      readOnlyRootFilesystem: true  
      runAsNonRoot: true" | kubectl apply -f -
```

???

Add the security context below to fix crash 

```
  securityContext:
    runAsUser: 1000
```

---

# Read-only Pods, with mounted volumes

```bash
echo "apiVersion: v1
kind: Pod  
metadata:  
  name: readonly-sleepy-with-volume 
spec:  
  containers:
  - name: sleepy
    image: alpine
    command:
    - sleep
    - '600'
    securityContext:
      readOnlyRootFilesystem: true  
      runAsNonRoot: true
    volumeMounts:
    - mountPath: /tmp
      name: tmp-volume
  volumes:
  - name: tmp-volume
    emptyDir:
      medium: Memory
  securityContext:
    runAsUser: 1000" | kubectl apply -f -
```

---
class: center

# How do my Pods get placed

![](/images/kubernetes-blackbelt/jenga.jpg)

---

# How pod scheduling works

1. A pod is born
1. The nodes that match get filtered
1. Remaining nodes get prioritized
1. A random high-score node is chosen in a round-robin fashion

---

# How are nodes filtered?

1. Gets all the Nodes that have enough RAM/CPU for the Pod
1. Checks the Pod's node selectors
1. Uses affinity, taints and tolerations

---

# Adding biases to the orchestrator

* By default, Kubernetes would schedule all Pods to any Node with enough RAM/CPU
* There are cases, where Pods need to either be directly scheduled to a specific group of Nodes, or away from them

---

# Using node selectors on Pods

* Node selectors target specific node labels
* Node labels can be easily changed using `kubectl`

---

# Using node selectors on Pods

```yaml
  nodeSelector:
    node-role.kubernetes.io/master: ""
```

???

* Add this node selector to a pod
* See it not being scheduled

---

# Repelling pods from nodes

* Taints add a mark on nodes, that make pods get away from them
* They can be no-schedule, prefer no-schedule, or no-execute
* Pods can counter attack taints with tolerations

---

# Example taint

```bash
kubectl taint nodes node1 key1=value1:NoSchedule
kubectl taint nodes node1 key1=value1:NoExecute
kubectl taint nodes node1 key2=value2:NoSchedule
```

--

and toleration

```yaml
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoExecute"
```

---

# Why `NoSchedule` and `NoExecute`?

* More gradual removal of pods, they mostly get evicted during deployments
* Dynamic tainting of nodes, through the system
    * `node.kubernetes.io/memory-pressure`
    * `node.kubernetes.io/disk-pressure`
    * `node.kubernetes.io/out-of-disk`
    * `node.kubernetes.io/unschedulable`

---

# Attracting pods to nodes

* Use node affinity to make pods get scheduled to nodes
* Choose between preferred and required based on how mandatory the scheduling decision is

---

# Adding affinity to nodes

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/e2e-az-name
          operator: In
          values:
          - e2e-az1
          - e2e-az2
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      preference:
        matchExpressions:
        - key: another-node-label-key
          operator: In
          values:
          - another-node-label-value
```

---

# Or to other Pods

```yaml
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: security
          operator: In
          values:
          - S1
      topologyKey: failure-domain.beta.kubernetes.io/zone
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S2
        topologyKey: kubernetes.io/hostname
```


---
class: center

# Messing with the Kubernetes API

![](/images/kubernetes-blackbelt.jpg)

---

# Why should I even touch the Kubernetes API?

* There are times where the stock Kubernetes is not enough
* There are behaviors that do not match all use cases
* Kubernetes is a very complex environment, with too many possible configurations

---

# Adding custom resources to Kubernetes

* Everything in Kunernetes is an object
* The Kubernetes API and `kubectl` are (almost) just a CRUD API server and a client
* Kubernetes control plane is the combination of different controllers that try to achieve the declared state

---

# When to use CRDs

* When you want to create and manage custom resources within a Kubernetes cluster
* When the way default Kubernetes controllers cannot provide the needed functionality

---

# The operator pattern

* The operator pattern was the initial idea, which later became CRDs
* Was introduced by CoreOS (now acquired Red Hat)
* Has a great list of tools and resources for creating operators

.footnote[Operator Framework on Github](https://github.com/operator-framework)

???

Examples could include a database that we want to migrate to and from a specific schema.
Also, the initialization process might require multiple steps

https://coreos.com/blog/introducing-operators.html


---

# A CRD before CRDs: Ingress

* Ingress is a standard Kubernetes resource
* It does not include a controller component by default though

--

Ingress is a way to expose HTTP and HTTPS routes from outside the cluster to services within the cluster.

---

# Community provided Ingress controllers

* Contour — based on Envoy
* NGINX — provided by NGINX Inc or Kubernetes itself
* Kong — based on NGINX, using LUA scripting
* Traefik — written in Go

---

# Creating a manual ingress

```bash
git checkout code-ceryx
kubectl apply -f kube/ceryx/
```

---

# Add a route to Ceryx

```bash
kubectl exec ceryx-api-67949c759b-5w6wm -- \
  curl -XPOST \
    -H 'Content-Type: application/json' \
    http://localhost:5555/api/routes \
    -d '{
      "source": "ceryx.workshop-vm-XX-00.akalipetis.com",
      "target": "ceryx-web.default.svc.cluster.local"
    }'

# open http://ceryx.workshop-vm-XX-00.akalipetis.com
```

---

# Creating a super simple CRD using the Operator Framework

```bash
kubectl apply -f - << EOF
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
    - name: v1
      served: true
      storage: true
  scope: Namespaced # either Namespaced or Cluster
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
EOF
```

???

* All we have to do now, is create a controller manager that spits CronJobs from CronTabs

---

# Intercepting the Kubernetes API

* There are times where we want to add custom logic on the Kubernetes API
* CRDs in combination with operators are not enough

--

Say hello to admission controllers.

An admission controller is a piece of code that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

---

# Default (and recommended) admission controllers

* NamespaceLifecycle
* LimitRanger
* ServiceAccount
* PersistentVolumeClaimResize
* DefaultStorageClass
* DefaultTolerationSeconds
* MutatingAdmissionWebhook
* ValidatingAdmissionWebhook
* ResourceQuota
* Priority

---

# Adding an admission controller

* We need to edit the way the Kubernetes API server is run
* We'll change the local file that the kubelet watches for uses to apply new changes

---

# Adding an admission controller

```bash
kubectl run --generator=run-pod/v1 --namespace=i-do-not-exist --image=nginx nginx-pod
kubectl get ns
sudo vim /etc/kubernetes/manifests/kube-apiserver.yaml
# Add NamespaceAutoProvision to --enable-admission-plugins
kubectl run --generator=run-pod/v1 --namespace=i-do-not-exist --image=nginx nginx-pod
kubectl get ns
```

---

# What did just happen?

1. We used `kubectl` to send a request to the API server
1. We referenced a non-existing pod
1. Before the request was serviced, it was parsed by the `NamespaceAutoProvision` admission controller
1. The admission controller created the `i-do-not-exist` namespace
1. The request was serviced successfully

---
class: center

# Open convo on random Kubernetes and container stuff

![](/images/kubernetes-blackbelt/play-time.jpg)

---
class: center

# Thanks!
