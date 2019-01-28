
layout: true
class: middle

---

# Spinning up a Kubernetes cluster

--

[p.2hog.codes/spinning-up-a-kubernetes-cluster](https://p.2hog.codes/spinning-up-a-kubernetes-cluster)

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

# [p.2hog.codes/spinning-up-a-kubernetes-cluster](https://p.2hog.codes/spinning-up-a-kubernetes-cluster)

---

# Agenda

1. Kubernetes crash course
2. Spin up cluster
3. Inspect cluster

---
class: center

# Kubernetes crash course

---

# Kubernetes crash course

1. Components
2. Nodes
3. Topology

---

# Components

---

# Components

- Master Components
- Node (Worker) Components
- Addons

---

# Master components

- `etcd`
- `kube-apiserver`
- `kube-scheduler`
- `kube-controller-manager`
- `cloud-controller-manager`

---

# Node (Worker) components

- `kubelet`
- `kube-proxy`
- Container runtime

---

# Addons

- Prometheus
- Dashboard
- CoreDNS

---

# Nodes

---

# Node types

- Master nodes
  - The servers responsible for meta data storage, API availability and decision making
  - The servers running the master components
- Worker nodes
  - The servers that are used to run workloads, decided by the Control Plane
  - The servers running the worker components

---

# Topology

---

.center[![A Kubernetes cluster](/presentations/spinning-up-a-kubernetes-cluster/images/kube-cluster.png)]

---

# Spin up cluster

---

# Our cluster

---

.center[![Our Kubernetes cluster](/presentations/spinning-up-a-kubernetes-cluster/images/our-kube-cluster.png)]

---

# `kubeadm` — making Kubernetes cluster bootstrap easy

---

# `kubeadm`

--

Kubeadm is a tool built to provide `kubeadm init` and `kubeadm join` as best-practice "fast paths" for creating Kubernetes clusters

???

* Making Kubernetes cluster management more close to Swarm
* Making it more secure

--

* Generates a self-signed CA, used to create and verify identities of components in the cluster
* Bootstraps an etcd backend, if an external one is not provided
* Generates default `kubectl` configuration for talking to the cluster

---

# Bootstrapping the cluster

https://github.com/2hog/workshop-infra

--

```bash
# [workshop-vm-XX-00]
sudo kubeadm init
```

???

* This makes the API server be publicly available
* Possibly, we'd like to change this to a private IP, but during the training that's easier if we want to remotely access the cluster
* This has set up a single master node cluster, without any networking

---

# Add the cluster credentials to the `workshop` user

--

```bash
# [workshop-vm-XX-00]
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

# Bootstrap networking

--

* Kubernetes supports any network plugin, as long as it's CNI compatible
* `kubeadm` does not have any network plugin installed, to allow the user to decide one
* We'll go with Weave

???

* Easy to use and deploy
* Fast
* Even supports multicast

---

# Setting up Weave

--

```bash
# [workshop-vm-XX-00]
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl rollout status daemonset weave-net -n kube-system
```

---

# Scaling the cluster

---

# Joining more nodes to the cluster

```bash
# [workshop-vm-XX-01]
sudo kubeadm join $KUBERNETES_MASTER_IP:6443 --token TTT --discovery-token-ca-cert-hash sha256:HHH
```

---

# What happened here?

* `kubeadm` connected to the API server, used the token to authenticate and downloaded the information
* Used the CA cert hash to validate that the information is originated from the correct CA

---

# See that everything works

???

* Let's deploy the Kubernetes dashboard
* Let's start inspecting some things there

--

```bash
# [workshop-vm-XX-00]
kubectl apply -f https://gist.githubusercontent.com/akalipetis/968a29bd42b7944f788cb6332b480b62/raw/43c030a7cfd8490b83afd03ce2fb77ee27d1e359/dashboard-rbac.yml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl -n kube-system rollout status deployment kubernetes-dashboard
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
kubectl proxy
```

---

# Let's check out the dashboard

--

```bash
# [laptop]
ssh -L 8001:127.0.0.1:8001 -C -N workshop@workshop-vm-XX-00.akalipetis.com
```

--

Open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

---
class: center

# Inspecting the cluster

---

# Get general information about the cluster

--

```bash
# [workshop-vm-XX-00]
kubectl cluster-info
```

---

# Get information about nodes

--

```bash
# [workshop-vm-XX-00]
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
# [workshop-vm-XX-00]
kubectl get all --all-namespaces
```

---

# Ask your most weird questions!

---

class: center

# Thanks!
