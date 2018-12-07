layout: true
class: middle

---
class: center

# Kubernetes - Managing application health

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

# [p.2hog.codes/kubernetes-health](https://p.2hog.codes/kubernetes-health)

---

# Agenda

1. Understanding pod Lifecycle
1. Enter health probes
1. Pod resource requirements

---
class: center

# Understanding pod Lifecycle

.center[![](/images/kubernetes-health/circus-wheel.jpg)]

---

# Let's clone some examples

```bash
ssh workshop@workshop-vm-XX-00.akalipetis.com
git clone https://github.com/2hog/samples-kubernetes-health
```

---

# The different statuses of a pod

--

* _Pending_ — the first state of every pod, right before an image gets pulled, or before the scheduler schedules the pod
* _Running_	— All Containers have been created and at least one is running/starting/restarting
* _Succeeded_	— All Containers have terminated successfully and will not be restarted
* _Failed_	— All Containers have terminated and at least one Container has terminated in failure
* _Unknown_ —	The state of the pod cannot be defined

???

Failed: That is, the Container either exited with non-zero status or was terminated by the system
Unknown: Typically due to an error in communicating with the host of the Pod

---

# But, before we understand pods

We need to understand container states

--

* _Waiting_ — the container is waiting for something to happen
* _Running_ — the container is running
* _Terminated_ — the container has been terminated

???

Waiting: the container has not started yet, or is waiting to be restarted
Terminated: because of an exit code (either 0 or not) or by the system

---

# Going back to the pods

--

.center[![](/images/kubernetes-health/pod-statuses.png)]

---

# Let's see that in action

--

```bash
kubectl run --image=nginx:alpine nginx
for i in `seq 20`; do
  kubectl describe po nginx;
  sleep 2;
done |\
grep -e '\(State\|Status\)' -A 2
```

---

# What did we just do?

--

1. Create a new deployment — which created a new pod
1. Described the pod to see the status and the state every 2 seconds

???

Go back now and understand the diagram again

---

# Another example

--

```bash
kubectl run --image=alpine to-crash
for i in `seq 20`; do
kubectl describe po to-crash;
  sleep 2;
done | grep -e '\(Status\|State\)'
```

???

Although the container is being terminated, the pod Status is running
The container is still waiting to be restarted.

---

# Successful VS Failed

--

* Only one-off pods can be successful or failed
* The exit code defines the exit status

---

# Let's see an example

--

```bash
kubectl run --image alpine --restart=Never my-job
for i in `seq 20`;
do kubectl describe po my-job;
  sleep 2;
done | grep -e '\(Status\|State\)'
```

--

```bash
kubectl run --image alpine --restart=Never my-failed-job -- sh -c 'exit 17'
for i in `seq 20`;
do kubectl describe po my-failed-job;
  sleep 2;
done | grep -e '\(Status\|State\)'
```

???

The container was terminated in both cases, the exit code determined the status

---

# Container state and Pod status bottom line

* Containers might stop or restart, without affecting pod status
* A pod's status is derived from its container states and its restart policy

???

* A container restarting, does not mean it will affect its pod's status
* An exited container, does not necessarily mark a pod as failed
* In case of multi-container pods, the status only changes if all containers exit

---

# Will I ever care about Container state and Pod status?

--

* It's unlikely that you will monitor this yourself
* It's important though to understand how Kubernetes defines state and status to debug bad situations

---

# What if the process is running, but my application does not respond?

--

* A running process does not indicate a responsive application
* There are many reasons why an application might be running, but not responding

???

* An application might be simply stuck
* An application might be working, but some backing services or connections might be broken

---
class: center

# Enter health probes

Earth to Mars, are you alive?

![](/images/kubernetes-health/mars-rover.png)

---

# Earth to Mars, are you alive?

--

* Health probes define a custom way for Kubernetes to understand if a container is healthy
* They are quite flexible and should match any logic
* When health probes fail, containers get restarted

???

This allows us to make sure our application is responding correctly

---

# Command probe

--

* Run an arbitrary command
* Check if the exit code is 0 or not

---

# Command probe

```bash
kubectl apply -f health-probe-exec.yml
watch -n 2 'kubectl describe pod health-probe-exec | grep Events: -A 20'
```

???

* The command gets executed every 5 seconds
* After 2 consecutive fails, the container is marked as unhealthy and gets restarted
* Also, if the command blocks, it's considered failed when it times out after 10 seconds

---

# HTTP GET probe

* Do an HTTP GET request, with the given parameters
* 2XX and 3XX codes are considered success
* 4XX and 5XX codes are considered failure

---

# HTTP GET probe

--

```bash
kubectl apply -f health-probe-http-get.yml
watch -n 2 'kubectl describe pod health-probe-http-get | grep Events: -A 20'
```

???

* The  gets executed every 5 seconds
* After 2 consecutive fails, the container is marked as unhealthy and gets restarted
* Also, if the command blocks, it's considered failed when it times out after 10 seconds

---

# TCP probe

--

* The are times where we just want to test a TCP connection
* Using an exec probe is not an option, since we don't want to use a client, or a client is not available

--

Enter the TCP probe, which just checks if a TCP connection can be made

---

# TCP probe

```bash
kubectl apply -f health-probe-tcp.yml
watch -n 2 'kubectl describe pod health-probe-tcp | grep Events: -A 20'
```

???

* The TCP connection is tested every 10 seconds
* After 3 consecutive fails (default), the container is marked as unhealthy and gets restarted
* Also, if the connection initialization blocks, it's considered failed when it times out after 1 second (default)

---

# Ready VS healthy

--

* What if we have different tolerance when an application starts?
* What if we want to make a more complex check before we consider an application ready

---

# Readiness probes

--

* Same as the liveness probes
* Should be successful before an application is considered ready
* The probe syntax is identical

---

# Readiness probes

```bash
kubectl apply -f health-ready-probe.yml
watch -n 2 'kubectl describe pod health-ready | grep Events: -A 20'
```

---

# Preparing a pod, before the actual containers run

--

* What happens when you need to ...
  * Collect static assets
  * Warm up a cache
  * Run migrations

???

* There are times, where you need to run initialization code in advance
* Your application is not ready to handle it
* Initialization code should not (or is Ok not to) run more than once for every pod
* Running the same code from all pods is fine
* Give them access to different things, like secrets, than app containers

---

# Initialization containers

```bash
kubectl apply -f init-container.yml
watch -n 2 'kubectl describe pod init-container | grep Events: -A 20'
kubectl exec -it init-container bash
curl localhost:8000
```

---

# How initialization containers work

* Each container is started in order
* If the container exits with a successful exit code, the system continues to the next one
* In case of an error, the pod's restart policy kicks in

---

# Hooking to lifecycle events

--

* Run special actions when a container starts/before it stops
* Register/deregister pods for service discovery
* Update custom metrics

---

# Let's get hooked

```bash
kubectl apply -f hooks.yml
kubectl exec -it lifecycle-demo sh
cat /usr/share/nginx/html/hook
```

---
class: center

# Pod resource requirements

![](/images/kubernetes-health/blocks.jpg)

---

# Kubernetes resource types

--

* Kubernetes accounts RAM and CPU as resource types
* Resources are used to
  * Make sure a pod does not abuse the available resources
  * Help the scheduler better do its job

---

# Kubernetes `requests` vs `limits`

* `requests` — the "lego" size, that the Kubernetes API will use for packing nodes
* `limits` — the actual limit, which will not be surpassed by the container

---

# Imposing limits

* Limits are imposed by the underlying container runtime
* For Docker (and containerd), this is done with a Linux feature called cgroups

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

---

# Limiting memory

* Memory is limited by the OS, which kills the container if it exceeds it
* Memory is measured in bytes

---

# Limiting CPU

* CPU is limited in fractions of a CPU core
* CPU is limited as if the given fraction of a core was in use
* By default, CPU shares are refreshed every 100ms

???

i.e. if 100m means that the container can consume the same amount of cycles, as if the container was using 10% CPU for the whole time

---

# Let's see this in action

```bash
kubectl apply -f limits.yml
```

---

# Scheduling with resource requests

* The scheduler selects a node which has enough resources available
* It takes into account the requests of the currently running pods, not the actual usage
* Available resources are either automatically computed, or defined by the user

---

# Scheduling with multi-container pods

* The scheduler computes the effective requests
* Effective requests are the sum of all application containers combined

---

# Scheduling with init containers

* Init containers can also have requests and limits
* In that case, the scheduling request is the maximum between effective request and the init container requests

---

# Let's play a bit with limits and scheduling

???

1. Try to create a ReplicaSet and scale it up and down
2. Include init containers and more than one app container

---

# Is it possible to manage resources other than RAM and CPU?

--

* Device plugins can advertise third party resources
* The plugin advertises the available resources per node
* The scheduler then kicks in and makes source pods are scheduled with sufficient resources

---

# Quality of service

* Pods can be given a QoS class
* This depends on the different requests and limits of their containers

---

# Quality of service classes

* `Guaranteed` — all containers have requests and limits, which are the same
* `Burstable` — at least one container has requests or limits and the pod's class is not `Guaranteed`
* `BestEffort` — the pod's class is neither `Guaranteed`, not `Burstable`

---
class: center

# Thanks!
