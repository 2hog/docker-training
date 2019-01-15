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

Kubernetes allows separation of concerns between developers and system administrators.

Kubernetes provides fundamental configuration management capabilities.

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

# Use cases for ConfigMaps

ConfigMaps are great for holding information such as

1. Data store locations (e.g. `redis://myapp.redis.cache.windows.net/0`)
2. Environment name (e.g. `production`, `staging` etc.)
3. Hosts allowed to access web service

---

# Creating your first ConfigMap

```shell
paris at ~ ⠕ kubectl create configmap greeter-config --from-literal=environment=training
configmap "greeter-config" created
```

<small>
  <a href="https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-configmap-em-" target="_blank">
    <code>kubectl create configmap</code> docs
  </a>
</small>
---

# Your first ConfigMap

```shell
paris at ~ ⠕ kubectl get configmap greeter-config -o yaml
apiVersion: v1
data:
  environment: training
kind: ConfigMap
metadata:
  creationTimestamp: 2018-12-06T06:59:14Z
  name: greeter-config
  namespace: default
  resourceVersion: "241140"
  selfLink: /api/v1/namespaces/default/configmaps/greeter-config
  uid: 70e6b091-f924-11e8-a189-025000000001
```

---

# ConfigMaps

Based on the previous example we should state that ConfigMaps:

1. Are **just a key-value store** for configuration data.
2. Are **not aware** of how they will be presented to the application.

---

# ConfigMap structure

As first-class Kubernetes objects, ConfigMaps have a strict structure:

- `apiVersion`: value should be `v1`
- `kind`: value should be `ConfigMap`
- `binaryData`: key-value pairs outside the UTF-8 range
- `data`: key-value pairs inside the UTF-8 range
- `metadata`: [`ObjectMeta` type](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta)

---

# A richer ConfigMap example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
  labels:
    app: docker-training-samples-redis
data:
  REDIS_DB: 0
  REDIS_HOST: redis
```

---

# Consuming ConfigMap data inside a Pod

There are 2 options for consuming ConfigMap data inside a Pod:

1. Environment variables
2. Volumes

---

# ConfigMap data as environment variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      env:
        - name: ENVIRONMENT  # Name of environment variable in container
          valueFrom:
            configMapKeyRef:
              name: greeter-config  # Name of ConfigMap
              key: environment # Key inside the `data` section of ConfigMap
```

The developer is in charge of the configuration baseline.

---

# All ConfigMap data as environment

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      envFrom:
        - configMapRef:
            name: greeter-config  # Name of ConfigMap
```

The system administrator is in charge of the configuration baseline.

---

# ConfigMap as volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: greeter-config  # Name of ConfigMap
```

---

# ConfigMap data as files in custom path


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: greeter-config  # Name of ConfigMap
        items:
          - key: environment
            path: vars
```

---

# ConfigMaps restrictions

1. You must create a `ConfigMap` before referencing it in a `Pod` specification.
2. If you use `envFrom` to define environment variables from `ConfigMaps`, invalid keys will be skipped.
3. `ConfigMaps` reside in a specific namespace. A `ConfigMap` can only be referenced by `Pods` in the same namespace.

---

# ConfigMaps worst practices

1. Using `ConfigMaps` to store secret data (e.g. database passwords)

---

# Let's see ConfigMaps in practice!

https://bit.ly/2ClUAbL

---

# Secrets

---

# Secrets

Secrets are first-class Kubernetes objects.

Secrets allow you to decouple configuration artifacts from image content to keep containerized applications portable.

Secrets are intended to hold sensitive information.

---

# Use cases for Secrets

Secrets are great for holding information such as

1. Database credentials
2. OAuth tokens
3. TLS keys and certificates

---

# Secret types

Kubernetes supports three distinct secret types:

1. Generic secrets: Any kind of data intended to be kept secret
2. Docker Registry secrets: Computer generated authentication certificates for pulling images
3. TLS secrets: Computer generated TLS certificates and keys based on a key pair

---

# Generic secrets

We will only examine generic secrets here.

Docker Registry and TLS secrets are not intended to be used as application configuration.

<small>Beware that generic secrets **are not** actually secrets, <em>yet</em>.</small>

---

# Creating your first Secret

```shell
paris at ~ ⠕ kubectl create secret generic greeter-secret --from-literal=secret_key=mystikouli
secret "greeter-secret" created
```

<small>
  <a href="https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-generic-em-" target="_blank">
    <code>kubectl create secret generic</code> docs
  </a>
</small>

---

# Your first Secret

```shell
paris at ~ ⠕ kubectl get secret greeter-secret -o yaml
apiVersion: v1
data:
  secret_key: bXlzdGlrb3VsaQ==
kind: Secret
metadata:
  creationTimestamp: 2018-12-06T07:44:35Z
  name: greeter-secret
  namespace: default
  resourceVersion: "244134"
  selfLink: /api/v1/namespaces/default/secrets/greeter-secret
  uid: c697a841-f92a-11e8-a189-025000000001
type: Opaque
```

---

# Secret structure

As first-class Kubernetes objects, Secrets have a strict structure:

- `apiVersion`: value should be `v1`
- `kind`: value should be `Secret`
- `data`: key-value pairs inside the UTF-8 range
- `stringData`: non-binary secret data in string form
- `metadata`: [`ObjectMeta` type](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta)

---

# Consuming Secret data inside a Pod

There are 2 options for consuming Secret data inside a Pod:

1. Environment variables
2. Volumes

---

# Secret data as environment variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      env:
        - name: AUTH_USER  # Name of environment variable in container
          valueFrom:
            secretKeyRef:
              name: greeter-secret  # Name of Secret
              key: auth_user # Key inside the `data` section of Secret
        - name: AUTH_PASSWORD
          valueFrom:
            secretKeyRef:
              name: greeter-secret
              key: auth_password
```

---

# Secret data as volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      volumeMounts:
      - name: secret-volume
        mountPath: /run/secrets
  volumes:
    - name: secret-volume
      secret:
        secretName: greeter-secret  # Name of Secret
```

---

# Secret data with read-only permissions

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      volumeMounts:
      - name: secret-volume
        mountPath: /run/secrets
        readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: greeter-secret  # Name of Secret
```

---

# Secret data in custom path

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-training-samples-micro-flask
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      volumeMounts:
      - name: secret-volume
        mountPath: /run/secrets
        readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: greeter-secret  # Name of Secret
        items:
          - key: auth_user
            path: credentials/user
          - key: auth_password
            path: credentials/password
```

---

# Prepared configuration file as seret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
stringData:
  settings.yml: |-
    environment: production
    db:
      host: myapp.postgres.database.azure.com
      username: 2hog
      password: training
```

This should be used only as part of a transition path in legacy apps.

---

# Secrets restrictions

1. You must create a `Secret` before referencing it in a `Pod` specification.
2. Individual secrets are limited to 1MB in size.
3. References via `secretKeyRef` to keys that do not exist in a named Secret will prevent the Pod from starting

---

# Secrets worst practices

1. Using Secrets to store whole configuration files

---

# Let's see Secrets in practice!

https://bit.ly/2QOUtL4

---

# The big win of ConfigMaps and Secrets

ConfigMaps and Secrets provide a clean contract between developers and system administrators.

System administrators control ConfigMaps and Secrets regardless of how they are being consumed.

---

# Ask your most weird questions!

---

class: center

# Thanks!
