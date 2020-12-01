layout: true
class: middle

---
class: center

# Helm deep dive

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

# [p.2hog.codes/kubernetes-helm](https://p.2hog.codes/kubernetes-helm)

---

# Agenda

1. What is Helm?
1. Helm conecpts
1. Using Helm

---
class: center

# What is Helm?

![](/images/kubernetes-helm/helm.jpg)

---

# What is Helm in Kubernetes-land?

* The package manager for Kubernetes
* A way to define, install, and upgrade even the most complex Kubernetes application


---

# Why use Helm?

* Simplify huge and complex Kubernetes manifests
* Easily template Kubernetes manifests
* Profit from a wide range of "well-structured" packages

---

# Helm architecture

* Helm client — CLI that encapsulates all the Helm logic and communicates with the Kubernetes API

--

_Differences with Helm 2_:

* Helm had a client-server model
* Helm was a simple CLI
* All the logic was implemented server-side with Tiller

---

# Important Helm concepts

* Helm charts - the Helm packages that can be deployed inside a Kubernetes cluster
* Helm repositories - the place too store and retrieve Charts, either public or private
* Helm releases - the instance of a Chart, running inside a Kubernetes cluster

_Tip_: Use `helm search repo` to look for repositories and charts from the CLI

---

# Installing Helm

* Done, you didn't need to do anything, only having the CLI is enough!

--

_Differences with Helm 2_:
* Helm 2 needed Tiller to be deployed inside the cluster
* Tiller deployment had a complex RBAC setup, which was either too permissive, or too complicated to implement

---

# Let's deploy our first chart

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-db bitnami/postgresql
```

---

# Adding a cluster-wide addon

```bash
helm repo add rimusz https://charts.rimusz.net
helm install hostpath-provisioner \
  --namespace kube-system \
  rimusz/hostpath-provisioner
```

---

# Install the whole ELK stack

```bash
helm repo add elastic https://helm.elastic.co
kubectl create ns elastic
helm install -n elastic --values=elasticsearch.yml   elasticsearch elastic/elasticsearch
helm install -n elastic logstash elastic/logstash
helm install -n elastic \
  --set service.type=NodePort,nodePort=35601 \
  kibana elastic/kibana
helm install -n elastic filebeat elastic/filebeat
```


???

Cleanup: kubectl delete --all -ikkk

---

# Configuring the way a Chart is deployed

```bash
helm uninstall my-db
helm install my-db --set=persistence.storageClass=hostpath bitnami/postgresql
```

---

# Configuring default values

```bash
helm show values bitnami/postgresql > values.yml
# Set storage class to hostpath and
# Set nodePort: 5432
vim values.yml
export POSTGRESQL_PASSWORD=$(kubectl get secret \
  my-db-postgresql \
  -o jsonpath="{.data.postgresql-password}" \
  |base64 --decode)
helm upgrade -f=values.yml --set postgresqlPassword=$POSTGRESQL_PASSWORD my-db bitnami/postgresql
```

???

* Use a file with the default values and only change the ones you need

---

# Where do I find those charts?

* We can quickly `helm search`
* Or go to https://artifacthub.io/

---

# What's in a Chart?

```bash
helm fetch bitnami/postgresql --untar
```

---

# Understanding the Chart structure

```bash
my-awesome-chart/
  Chart.yaml          # A YAML file containing information about the chart
  LICENSE             # OPTIONAL: A plain text file containing the license for the chart
  README.md           # OPTIONAL: A human-readable README file
  requirements.yaml   # OPTIONAL: A YAML file listing dependencies for the chart
  values.yaml         # The default configuration values for this chart
  charts/             # A directory containing any charts upon which this chart depends.
  templates/          # A directory of templates that, when combined with values,
                      # will generate valid Kubernetes manifest files.
  templates/NOTES.txt # OPTIONAL: A plain text file containing short usage notes
```

---

# Helm templates

* Simple Kubernetes manifests, with a pinch of salt
* Go template language
* Extensive collection of available functions

---

# Let's examine the PostgreSQL templates

```bash
vim templates/statefulset.yaml
```

---

# Playing with the `helm` CLI

```bash
helm ls
helm status my-db
helm history my-db
helm rollback my-db 1
```

---

# Enhancing the CLI with plugins

```bash
helm plugin install https://github.com/databus23/helm-diff --version master
helm diff upgrade \
  -f=values.yml \
  --set postgresqlPassword=$POSTGRESQL_PASSWORD \
  my-db bitnami/postgresql
```

---

# How does Helm determine what to deploy?

* Helm is using 3-way merge
* Takes into account the initial deployment state
* Then, compares it with any possible runtimes changes in the application
* And finally, finds the differences regarding the new version

--

_Differences with Helm 2_:

* Helm 2 did not support 3-way merge, only 2-way
* This created issues, especially when values are dynamically changed, like replicas for example

---

# 3-way merge in action

```bash
kubectl edit sts my-db-postgresql
helm diff upgrade \
  -f=values.yml \
  --set postgresqlPassword=$POSTGRESQL_PASSWORD \
  my-db bitnami/postgresql
```

---

# Creating our first Chart

```bash
helm create my-awesome-chart
cd my-awesome-chart
vim Chart.yaml
vim values.yaml
```

---

# Provided values

* Helm provides several top level objects, for more dynamic templating
* These are both related to the Chart and the specific Release

---

# Provided values

* Release
* Chart
* Files
* Capabilities
* Template

https://helm.sh/docs/chart_template_guide/builtin_objects/

???

* Release: This object describes the release itself. It has several objects inside of it:
* Values: Values passed into the template from the values.yaml file and from user-supplied files. By default, Values is empty.
* Chart: The contents of the Chart.yaml file. Any data in Chart.yaml will be accessible here. For example {{.Chart.Name}}-{{.Chart.Version}} will print out the mychart-0.1.0.
* Files: This provides access to all non-special files in a chart. While you cannot use it to access templates, you can use it to access other files in the chart. See the section Accessing Files for more.
* Capabilities: This provides information about what capabilities the Kubernetes cluster supports.
* Template: Contains information about the current template that is being executed

---

# User defined values

* There's also a Values top level object
* It contains the merge of the user-defined values with the default values

---

# Using functions

* Helm has a plethora of predefined functions for us to use
* Include things like `quote`, `trim`, `default`, `now` and many others
* Most of them are defined by the Go Template library and [sprig](http://masterminds.github.io/sprig/)

---

# Chain multiple functions together

* Helm supports pipelines
* Pipelines allow one to chain the call of multiple functions at once
* You can do things like `now | upper | trim 64 | quote`

---

# Flow control

* Helm support flow control statements
* You can use `if`, `with` or `range`
* You can even use other `template`s, or `define` new ones

---

# Template helpers

* Have some stubs ready, to use them throughout the Chart
* DRY — there are many parts in Kubernetes manifests which are repetitive

---

# Some template hacks

* Use `{{-` to trim all trailing white space from the proceeding text
* Use `-}}` to trim all leading white space until the following text
* `quote` or just `"1"` numbers or unknown values to avoid YAML type conversions

---

# Adding Hooks to releases

* There are times when specific "things" need to run in between releases
* Helm gives us a handy way to deploy "things" to Kubernetes when those "things" happen

???

* pre-install: Executes after templates are rendered, but before any resources are created in Kubernetes.
* post-install: Executes after all resources are loaded into Kubernetes
* pre-delete: Executes on a deletion request before any resources are deleted from Kubernetes.
* post-delete: Executes on a deletion request after all of the release's resources have been deleted.
* pre-upgrade: Executes on an upgrade request after templates are rendered, but before any resources are loaded into Kubernetes (e.g. before a Kubernetes apply operation).
* post-upgrade: Executes on an upgrade after all resources have been upgraded.
* pre-rollback: Executes on a rollback request after templates are rendered, but before any resources have been rolled back.
* post-rollback: Executes on a rollback request after all resources have been modified.
* crd-install: Adds CRD resources before any other checks are run. This is used only on CRD definitions that are used by other manifests in the chart.

---

# What would one usually add as a hook?

* Run migrations — before a release is deployed
* Fill a database with initial data, as soon as it is deployed
* Register a new version to an internal registry
* Orchestrate the creation of a Redis cluster
* Load a ConfigMap or Secret during install before any other charts are loaded

---

# Adding Hooks to releases

```yaml
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "5"
    "helm.sh/hook-delete-policy": hook-succeeded
```

---

# Helm best practices

* Use the Charts on https://artifacthub.io/, at least as a starting point
* Create a private Helm repository for common internal services
* Have specific charts version controlled alongside their repositories

---

# Thanks
