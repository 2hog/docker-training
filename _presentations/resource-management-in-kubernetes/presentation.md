
layout: true
class: middle

---

# Resource management in Kubernetes

--

[p.2hog.codes/resource-management-in-kubernetes](https://p.2hog.codes/resource-management-in-kubernetes)

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

# [p.2hog.codes/resource-management-in-kubernetes](https://p.2hog.codes/resource-management-in-kubernetes)

---

# Agenda

1. Intro to resource management in Kubernetes
2. Concepts
3. Measuring resources
4. Beyond requests and limits

---
class: center

# Resource management in Kubernetes

---

# Resource management in Kubernetes

Kubernetes lets you manage the resources consumed by your `Pods`.

This means that you can:

1. Reserve resources for consumption by Pods
2. Limit consumption of resources by Pods
3. Schedule Pods according to resource availability

---

# Use cases

1. Optimal cluster utilization
2. Healthy applications by definition

---

# Concepts

---

# Concepts

1. Requests
2. Limits
3. Limit ranges
4. Affinity

---

# Requests

Resource can be requested in `Containers` of `Pods` via the `requests` key.

When `Containers` have resource requests specified, the scheduler can make better decisions about which nodes to place `Pods` on.

---

# A `Pod` with `requests`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql
spec:
  containers:
    - name: db
      image: mysql
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password"
      resources:
        requests:
          memory: "64M"
          cpu: "250m"
```

---

# Limits

Kubernetes can limit the resources available for usage by `Containers` of `Pods` via the `limits` key.

When `Containers` have resource requests specified, the scheduler can make better decisions about which nodes to place `Pods` on.

---

# A `Pod` with `limits`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql
spec:
  containers:
    - name: db
      image: mysql
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password"
      resources:
        limits:
          memory: "512M"
          cpu: "500m"
```

---

# Kubernetes `requests` vs `limits`

* `requests`: the "lego" size, that the Kubernetes API will use for packing nodes
* `limits`: the actual limit, which will not be surpassed by the container

---

# Measuring resources

---

# Measurable resources

- CPU
- Memory (RAM)

---

# Measuring CPU

In Kubernetes CPU is measured in amount of CPU cores.

```yaml
requests:
  cpu: 0.1  # Requests 10% of a CPU core's time
---
requests:
  cpu: 100m  # Requests 10% of a CPU core's time, expressed in "millis"
---
limits:
  cpu: 2  # Limits CPU usage to not exceed the full capacity of 2 cores
```

.footnote[CPU is always requested as an absolute quantity; 0.1 is the on a single-core, or 48-core machine.]

---

# Measuring memory

In Kubernetes memory is measured in bytes.

```yaml
requests:
  memory: 1024  # 1024 bytes
---
requests:
  memory: 256M  # 256 * 1000 * 1000 bytes
---
limits:
  memory: 512Mi  # 512 * 1024 * 1024 bytes
```

---

# What if I don't add requests and limits?

---

# What if I don't add requests and limits?

Hello `LimitRange`!

---

# `LimitRange`

- Default requests and limits per container
- Can be overriden inside the pod template

---

# Your first `LimitRange` 

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
```

---

# 💡 Heads up!

The `LimitRange` applies to all Containers in the namespace, if they don't define their own requests and limits!

---

# Beyond requests and limits

---

# ResourceQuotas

---

# ResourceQuotas

Kubernetes allows restricting available resources in a namespace.

Resource quotas are expressed via the `ResourceQuota` object.

.footnote[This is useful when several teams share a cluster, to ensure fair share of resources.]

---

# Use cases

- Limit the total CPU and Memory that can be used within a namespace
- Limit `Pods` that can be created within a namespace
- Limit load balancers, node ports and other resources in a namespace

---

# Your first ResourceQuota

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
spec:
  hard:
    pods: "4"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    requests.nvidia.com/gpu: 4
```

---

# Affinity

---

# Affinity

Kubernetes lets us attract Pods to (or repel from) Nodes via the `affinity` attribute.

Node affinity allows you to constrain which nodes your pod is eligible to be scheduled on, based on labels on the node.

---

# Attracting Pods to nodes

- Use node `affinity` to make pods get scheduled to nodes
- Choose between preferred and required based on how mandatory the scheduling decision is

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

# Or to other nodes

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

# Taints and tolerations

---

# Taints and tolerations

Taints and tolerations allow a node to repel a set of Pods.

Essentially taints are the opposite of affinity.

---

# Use cases

- **Dedicated Nodes**: Dedicate a set of nodes for exclusive use by a particular set of users
- **Nodes with special hardware**: Keep pods that don’t need GPUs off nodes with GPU cards

---

# Taints

- Taints add a mark on nodes, that make Pods get away from them
- They can be no-schedule, prefer no-schedule, or no-execute

---

# Your first taint

```bash
kubectl taint nodes node1 key=value:NoSchedule
```

No Pod can be schedules on node `node1`, unless it has a matching toleration for `key`.

---

# Removing your first taint

```bash
kubectl taint nodes node1 key:NoSchedule-
```

---

# Tolerations

Tolerations allow Pods to be scheduled on Nodes with matching taints.

Tolerations are being specified in Pod specs.

---

# Toleration example

```yaml
tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```

A toleration "matches" a taint if the keys are the same and the effects are the same.

---

# Why `NoSchedule` and `NoExecute`?

- More gradual removal of pods, they mostly get evicted during deployments
- Dynamic tainting of nodes, through the system

---

# Ask your most weird questions!

---

class: center

# Thanks!
