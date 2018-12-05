layout: true
class: middle

---

# Configuring applications on Kubernetes

--

[p.2hog.codes/configuring-applications-on-kubernetes](https://p.2hog.codes/configuring-applications-on-kubernetes)

---

# About 2hog.codes

* Founders of [SourceLair](https://www.sourcelair.com) online IDE + Dimitris Togias
* Docker and DevOps training and consulting

---

# Antonis Kalipetis

* Docker Captain and Docker Certified Associate
* Python lover and developer
* Technology lead at SourceLair / stolos.io
* Docker training and consulting

.footnote[[@akalipetis](https://twitter.com/akalipetis)]

---

# Paris Kasidiaris

* Python lover and developer
* CEO at SourceLair
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

1. Software Configuration
2. Configuration in Kubernetes
3. ConfigMaps
4. Examples with ConfigMaps
5. Secrets
6. Examples with Secrets

---

class: center

# Software Configuration

---

# What is Software Configuration?

---

# Source Code, Config and Apps

**Applications** are entities executables by the machine.

**Applications** the result of **Source Code** and **Configuration** processing.

---

# Source Code, Config and Apps

![Configuration in Applications](/presentations/configuring-applications-on-kubernetes/images/config-vs-code.svg)

---

# Configuration vs. Source Code

- Configuration is controlled by System Administrators
- Source Code is controlled by Developers

---

# Configuration Options

We have a few options to choose on how to configure our applications.

We will focus on the 3 most prominent ones.

---

# Option 1: Environment variables

Environment variables are **dynamic-named values** that can affect the way running processes behave on a computer.

Environment variables provide **granular, fully orthogonal** configuration for applications.

---

# Environment variable based configuration restrictions

1. Their names consist solely of uppercase characters, digits and the underscore ([source](https://stackoverflow.com/a/2821183/577598))
2. Updating the environment for a process tree is cumbersome ([source](https://support.cloud.engineyard.com/hc/en-us/articles/205407508-Environment-Variables-and-Why-You-Shouldn-t-Use-Them))

---

# Environment variable based configuration worst practices

1. Storing secrets in production in environment variables
2. Storing structured configuration like YAML in a single environment variable

---

# Case Studies

1. Linux and Unix programs depending on `$HOME`, `$PATH` etc.
2. The Python interpreter can get configured via `$PYTHON*` environment variables ([source](https://docs.python.org/3/using/cmdline.html#environment-variables))
3. **Flask** can get configured via `$FLASK_*` environment variables ([source](http://flask.pocoo.org/docs/1.0/config/#environment-and-debug-features))

---

# Option 2: Files

Files let us retrieve data from a path.

Files provide more freedom and options compared to environment variables.

Files don't have to be necessarily stored on disk 🤯.

---

# File based configuration restrictions

1. Configuration files can be accidentally checked into version control
2. The contents and structure of each configuration file are unpredictable
---

# File based configuration worst practices

1. Not using well-adopted structures in configuration files (e.g. YAML or JSON)
2. Storing code in configuration files (e.g. `settings_local.py`)

---

# Case studies

1. **NGINX** gets configured by a file tree ([source](http://nginx.org/en/docs/beginners_guide.html#conf_structure)) <small><a href="https://github.com/sourcelair/ceryx" >or does it?</a></small>
2. **Rails** applications by `.rb` (👎) and `.yml` files ([source](https://guides.rubyonrails.org/configuring.html))
3. **PostgreSQL** gets configured by `postgresql.conf` ([source](https://www.postgresql.org/docs/9.6/config-setting.html#CONFIG-SETTING-CONFIGURATION-FILE))

---

# Option 3: External data stores

External data stores deticated for storing configuration are great for distributed applications.

An external data store is a better choice for storing secrets.

Great external data stores for configuration are Redis, Etcd, Consul, Riak and Vault.

---

# External data store based configuration restrictions

1. Applications depending on them need additional libraries
2. They introduce complexity to the system (as they have to be HA)
3. They consume additional resources

---

# External data store based configuration worst practices

1. Storing secrets in data stores not crafted for storing secrets
2. Using external data stores for small, non-distributed apps

---

# Case studies

1. **Kubernetes** uses etcd to extend its API
2. **Wordpress** stores almost the entirety of its configuration in MySQL (😢)
3. **Adobe** uses Vault to store secrets ([source](https://www.hashicorp.com/resources/adobe-100-trillion-transactions-hashicorp-vault))

---

# Mixing configuration options

Mixing different configuration options should be avoided.

We can mix different configuration options depending on limitations.

---

# Legit examples of mixing configuration options

1. Non-secret configuration in the environment and secrets in memory mapped files
2. Non-secret configuration in the environment and secrets in Vault
3. Using an environment variable to determine the location of a configuration file

---

# Configuration Management

Turns out there are several ways for software to access configuration.

System administrators need a single uniform way to manage software configuration.

---

# Configuration Management vs Source Control Management

Configuration Management is for configuration what Source Control Management is for source code.

---

# Configuration Management

Configuration Management provides a uniform way for system administrators to:

1. Track and control changes in software configuration
2. Establish software configuration baselines

---

# Well-known configuration management software

1. Ansible
2. Capistrano
3. Puppet

---

# Recap: Software Configuration

1. Configuration is fundamental to release apps
2. Configuration is controlled by System Administrators
3. Configuration needs to be managed by a tool

---

# Configuration in Kubernetes

---

# Configuration in Kubernetes

Kubernetes provides fundamental configuration management capabilities.

Kubernetes allows separation of concerns between developers and system administrators.

---

# Configuration objects in Kubernetes

- **ConfigMaps** for non-secret configuration data
- **Secrets** for secret configuration data

---

# ConfigMaps

---

# ConfigMaps

ConfigMaps are first-class Kubernetes objects.

ConfigMaps allow you to decouple configuration artifacts from image content to keep containerized applications portable.

ConfigMaps should be used to store non-secret data.

---

# Creating your first ConfigMap

```shell
$ kubectl create configmap greeter-config --from-literal=greeting=Hey
$ kubectl get configmap greeter-config -o yaml
```

---

# ConfigMaps

ConfigMaps **are just a key-value store for configuration data**.

ConfigMaps **are not aware of how they will be presented to the application**.

---

# Configuration options for ConfigMap 

1. Environment Variables
2. Files

---

# Use cases for ConfigMaps

1. ...
2. ...
3. ...

---

# ConfigMap keys

- `apiVersion`: value should be `v1`
- `kind`: value should be `ConfigMap`
- `binaryData`: key-value pairs outside the UTF-8 range
- `data`: key-value pairs inside the UTF-8 range
- `metadata`: [`ObjectMeta` type](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta)

---

# ConfigMap example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  labels:
    app: docker-training-samples-postgres
data:
  POSTGRES_DB: postgres
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: password
  POSTGRES_HOST: docker-training-samples-postgres
```

---

# Referencing a ConfigMap

...

---

# ConfigMap as Environment Variables

...

---

# ConfigMap as Volumes

...

---

# ConfigMap as Volumes in custom path

...

---

# ConfigMaps restrictions

1. You must create a `ConfigMap` before referencing it in a `Pod` specification.
2. If you use `envFrom` to define environment variables from `ConfigMaps`, invalid keys will be skipped.
3. `ConfigMaps` reside in a specific namespace. A `ConfigMap` can only be referenced by `Pods` in the same namespace.

---

# ConfigMaps worst practices

1. Using `ConfigMaps` to store secret data (e.g. database passwords)

---

class: center

# Thanks!
