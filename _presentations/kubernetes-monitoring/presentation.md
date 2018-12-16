layout: true
class: middle

---

# Monitoring and Troubleshooting applications on Kubernetes

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

# [p.2hog.codes/kubernetes-monitoring](https://p.2hog.codes/kubernetes-monitoring)

---

# Agenda

1. What is monitoring
1. Monitoring containers and micro-services
1. Monitoring tools for Kubernetes
1. Troubleshooting failures in Kubernetes

---
class: center

# What is monitoring?

![](/images/kubernetes-monitoring/detective.jpg)

---

# Let's get the code

```bash
git clone https://github.com/2hog/kubernetes-monitoring
```

---

# A bit of monitoring history

* We started with physical machines
* Moved to virtual machines
* Now we have containers


---

# What is monitoring after all?

* _Application performance monitoring_, monitoring and management of performance and availability of software applications
* _Business transaction monitoring_, managing information technology from a business transaction perspective
* _Network monitoring_, systems that constantly monitors a computer network for slow or failing components and that notifies the network administrator
* _System monitoring_, a process within a distributed system for collecting and storing state data
* _Website monitoring_, the process of testing and verifying that end-users can interact with a website or web application as expected

---

# What is monitoring after all?

* **Application performance monitoring**, monitoring and management of performance and availability of software applications
* _Business transaction monitoring_, managing information technology from a business transaction perspective
* _Network monitoring_, systems that constantly monitors a computer network for slow or failing components and that notifies the network administrator
* **System monitoring**, a process within a distributed system for collecting and storing state data
* **Website monitoring**, the process of testing and verifying that end-users can interact with a website or web application as expected

---

# Classic monitoring

* Was mostly just website monitoring
* Websites resided in dedicated machines, so those machines were checked
* Inter-component communication was straight-forward

---

# Classic monitoring tooling

* `tail`, `top`
* `ping` and `curl`

---

# VM-style monitoring

* Included APM
* VM groups were assigned to applications, so those groups were checked
* Some application specific metrics were collected for easier tracing
* Inter-component communication was not straight-forward, but not very complex either

---

# VM-style monitoring tooling

* `tail`, `top`
* `ping` and `curl`
* Cloud provider dashboards
* Basic counters for application metrics

---
class: center

# Monitoring containers and micro-services

![](/images/kubernetes-monitoring/ocean.jpg)

---

# Challenges when monitoring containers VS VMs

* You don't really know where each container is running
* Containers are ephemeral, changing IDs like host names all the time and not persisting any data
* The container lifecycle, does not necessarily match that of the version deployed

---

# Challenges when monitoring micro-services VS monoliths

* The architecture is more complex
* There are many different components that might misbehave
* Identifying the failing components might not be as easy as it sounds

---

# From this...

.center[![](/images/kubernetes-monitoring/relaxed.jpg)]

---

# ...to this

.center[![](/images/kubernetes-monitoring/milky-way.jpg)]

---

# Monitoring tools for Kubernetes

* Monitor things "by hand", either using CLI or graphical tools
* Use log aggregators, to centrally store, manage and analyze logs
* Use metric collectors, to have a history of the different states of the metrics

???

* Basic tools include the Kubernetes CLI and dashboard
* Log aggregators could be things like ELK, DataDog or Papertrail
* Metric collectors could be the ELK stack, Prometheus with Grafana, New Relic or DataDog

---

# Inspecting pods using the Kubernetes API

---

# Using the Kubernetes CLI — kubectl

* Directly hit the Kubernetes API
* See current information, or past information like restarts and events
* Manually check all the different objects

---

# Get general information about the cluster

```bash
kubectl cluster-info
```

---

# Get information about nodes

```bash
kubectl get no
kubectl describe node workshop-vm-XX-00
kubectl describe node workshop-vm-XX-01
kubectl descibe nodes
kubectl get componentstatuses
```

---

# See what's running inside the cluster

--

```bash
kubectl get all --all-namespaces
```

---

# The Kubernetes Dashboard

* Installed by default on most offerings
* Is the de-facto dashboard for Kubernetes clusters
* Gives a birds-eye view of the whole cluster quickly

---

# Installing the Kubernetes dashboard

```bash
kubectl apply -f dashboard/deploy.yml
# Open https://workshop-vm-ΧΧ-00.akalipetis.com:30443
```

---

# Navigating through the Kubernetes dashboard

* Check the different nodes
* Check what is running in each namespace
* Exec into containers and test things

???

* This allows for easy and quick debugging

---

# Basic container metrics

* We want to track container memory and CPU usage, not only their reservations
* We want to be able to do the same for nodes

---

# Low level container metrics

* Kubernetes has an API for pulling metrics from the different container runtimes
* The kubelet of each node is responsible for that
* Then, the metrics are gathered from the runtime using the CRI\*

.footnote[The CRI was introduced recently, to easily plug different container runtimes to Kubernetes, providing the needed APIs]

---

# Checking those metrics without Kubernetes

* Docker is running under the hood, which acts as the container runtime
* Let's use the Docker CLI to grab those metrics

```bash
docker container stats --no-stream
```

---

# Should I check those out on a per-node basis though?

--

* Of course not, there's a Kubernetes way of doing that
* It's easy to check any pod inside the cluster using `kubectl`

---

# Installing the Kubernetes metrics server

```bash
kubectl apply -f metrics-server
kubectl get po --all-namespaces
kubectl -n kube-system top po kube-proxy-p9zp2
kubectl top no workshop-vm-XX-00
```

---

# Still, we don't have a way to centrally gather all those metrics

--

* We need a tool for storing time series data
* We need a way to preview that data in a nice way
* We need to organize our dashboards

---

# Monitoring data strategies (Pull VS Push)

* Before we start, we need to decide between pull and push
* _Pull_ strategy means that the tool discovers and scrapes the data
* _Push_ strategy means that the application pushes the data to the too

---

# Why pull?

* The tool does not need to be highly available and withstand great load
* You can run your monitoring on your laptop when developing changes
* You can more easily tell if a target is down
* You can manually go to a target and inspect its health with a web browser

.footnote[Read about Pull VS Push and more [Prometheus FAQ](https://prometheus.io/docs/introduction/faq/#why-do-you-pull-rather-than-push?)]

---

# Pulling all the metrics to a centralized place

* Prometheus is one of the most commonly used tools for gathering and saving metrics
* Graduated from the CNCF
* Has really great integration with Kubernetes and the tooling around it

---

# Installing Prometheus

```bash
kubectl apply -f prometheus/
# Open http://workshop-vm-00-00.akalipetis.com:30090/
```

---

# Why is prometheus not running?

---

# Querying some metrics

```promql
container_memory_usage_bytes{pod_name=~"metrics-server-.*"}
kube_pod_container_status_restarts_total
```

---

# Combining application-specific metrics

* Prometheus can query metrics from applications
* You can even push metrics, using the Push Gateway
* Then, you can combine those metrics with RAM and CPU for even better insights

---

# Monitoring the network mesh

* When monitoring multiple micro-services, understanding their connections is crucial
* Both the flow and knowing the failing component can help in debugging failing situations

---

# Network monitoring solutions

* Distributed tracing (OpenTracing, Jaeger)
* Service mesh tracing (Istio, Linkerd)

---

# Distributed tracing

* See the time different services and/or actions add to the total request time
* Dive through the metrics and see the components slowing it down
* Better root cause analysis

---

# Distributed tracing

.center[![](/images/kubernetes-monitoring/spans-traces.png)]

---

# Service mesh tracing

* Chart the topology and component connections
* Gather metrics such as request count, duration, size or bytes transfered

---

# Service mesh tracing

.center[![](/images/kubernetes-monitoring/mixer.svg)]

---
class: center

# Troubleshooting failures in Kubernetes

![](/images/kubernetes-monitoring/mud.jpg)

---

# Reading logs is usually the first thing to do

--

```bash
kubectl -n kube-system logs deployment/coredns
kubectl -n kube-system logs -f weave-net-txtw8 -c weave
```

---

# Checking DNS and connectivity

```bash
# Jump into a container
kubectl exec -it 
# Check the DNS records for the service and the tasks
kubectl run --image=alpine --generator=run-pod/v1 sleepy sleep 600
kubectl exec -it sleepy sh
apk add bind-tools curl
dig kubernetes.default.svc.cluster.local
curl https://10.96.0.1 -k
```

---

# Checking other pods

Using the IPs previously acquired

--

```bash
kubectl -n kube-system describe po coredns-86c58d9df4-kkjfg | grep IP
kubectl exec -it sleepy sh
ping 10.32.0.2
```

---

# Taking a pod out for further investigation

* There are times where a pod needs to be investigated
* It should continue to be running
* It should be replaced so that the application recovers from the failure

---

# Taking a pod out for further investigation

```bash
kubectl run --image=nginx:alpine --generator=run/v1 nginx
kubectl get po
kubectl edit po nginx-6ddjx
# add -debug suffix to labels
kubectl get po
kubectl exec -it nginx-6ddjx sh
```

---
class: center

# Thanks!
