layout: true
class: middle

---

# Application Configuration on Kubernetes

--

[p.2hog.codes/2020-application-configuration-on-kubernetes/](https://p.2hog.codes/2020-application-configuration-on-kubernetes/)

[dojo.2hog.codes](https://dojo.2hog.codes/)

---

# About 2hog.codes

* Founders of [SourceLair](https://www.sourcelair.com)
* Docker and DevOps training and consulting

---

# Antonis Kalipetis

* Senior Software Engineer at e-food
* Docker Captain and Docker Certified Associate
* Python lover and developer
* Docker training and consulting

.footnote[[@akalipetis](https://twitter.com/akalipetis)]

---

# Paris Kasidiaris

* CEO at SourceLair
* Python lover and developer
* Docker Certified Associate
* Docker training and consulting

.footnote[[@pariskasid](https://twitter.com/pariskasid)]

---

# Agenda

1. Software configuration
2. Configuration in Kubernetes
3. ConfigMaps
4. Examples with ConfigMaps
5. Secrets
6. Examples with Secrets

---

class: center

# Application Configuration on Kubernetes

---

# Software Configuration

---

# What is Software Configuration?

---

# Source Code, Configuration and Applications

**Applications** are entities executables by the machine.

**Applications** the result of **Source Code** and **Configuration** processing.

---

# Source Code, Configuration and Applications

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

# Option 1: Environment Variables

Environment variables are **dynamic-named values** that can affect the way running processes behave on a computer.

Environment variables provide **granular, fully orthogonal** configuration for applications.

---

# Restrictions of Environment Variables

1. Their names consist solely of uppercase characters, digits and the underscore ([source](https://stackoverflow.com/a/2821183/577598))
2. Updating the environment for a process tree is cumbersome ([source](https://support.cloud.engineyard.com/hc/en-us/articles/205407508-Environment-Variables-and-Why-You-Shouldn-t-Use-Them))

---

# Worst Practices for Environment Variables

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

# Restrictions of Files

1. Configuration files can be accidentally checked into version control
2. The contents and structure of each configuration file are unpredictable
---

# Worst Practices for Files

1. Not using well-adopted structures in configuration files (e.g. YAML or JSON)
2. Storing code in configuration files (e.g. `settings_local.py`)

---

# Case Studies

1. **NGINX** gets configured by a file tree ([source](http://nginx.org/en/docs/beginners_guide.html#conf_structure)) <small><a href="https://github.com/sourcelair/ceryx" >or does it?</a></small>
2. **Rails** applications by `.rb` (👎) and `.yml` files ([source](https://guides.rubyonrails.org/configuring.html))
3. **PostgreSQL** gets configured by `postgresql.conf` ([source](https://www.postgresql.org/docs/9.6/config-setting.html#CONFIG-SETTING-CONFIGURATION-FILE))

---

# Option 3: External Data Stores

External data stores deticated for storing configuration are great for distributed applications.

An external data store is a better choice for storing secrets.

Great external data stores for configuration are Redis, Etcd, Consul, Riak and Vault.

---

# Restrictions of External Data Stores

1. Applications depending on them need additional libraries
2. They introduce complexity to the system (as they have to be HA)
3. They consume additional resources

---

# Worst Practices for External Data Stores

1. Storing secrets in data stores not crafted for storing secrets
2. Using external data stores for small, non-distributed apps

---

# Case Studies

1. **Kubernetes** uses etcd to extend its API
2. **Wordpress** stores almost the entirety of its configuration in MySQL (😢)
3. **Adobe** uses Vault to store secrets ([source](https://www.hashicorp.com/resources/adobe-100-trillion-transactions-hashicorp-vault))

---

# Mixing Configuration Options

Mixing different configuration options should be avoided.

We can mix different configuration options depending on limitations.

---

# Legit Examples of Mixing Configuration Options

1. Non-secret configuration in the environment and secrets in memory mapped files
2. Non-secret configuration in the environment and secrets in Vault
3. Using an environment variable to determine the location of a configuration file

---

# Configuration in Kubernetes

---

# Configuration in Kubernetes

Kubernetes allows separation of concerns between developers and system administrators.

Kubernetes provides fundamental configuration management capabilities.

---

# Configuration Objects in Kubernetes

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

# Use Cases for ConfigMaps

ConfigMaps are great for holding information such as

1. Data store locations (e.g. `redis://myapp.redis.cache.windows.net/0`)
2. Environment name (e.g. `production`, `staging` etc.)
3. Hosts allowed to access web service

---

# Creating your first ConfigMap

```console
kubectl create configmap my-first-config --from-literal=environment=training
```

---

# Creating your first ConfigMap

```console
paris at ~ ⠕ kubectl create configmap my-first-config --from-literal=environment=training
configmap/my-first-config created
```

<small>
  <a href="https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-configmap-em-" target="_blank">
    <code>kubectl create configmap</code> docs
  </a>
</small>

---

# Your First ConfigMap

```console
kubectl get configmap my-first-config -o yaml
```

---

# Your First ConfigMap

```console
paris at ~ ⠕ kubectl get configmap my-first-config -o yaml
apiVersion: v1
data:
  environment: training
kind: ConfigMap
metadata:
  creationTimestamp: "2020-05-08T07:38:04Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:environment: {}
    manager: kubectl
    operation: Update
    time: "2020-05-08T07:38:04Z"
  name: my-first-config
  namespace: default
  resourceVersion: "99491"
  selfLink: /api/v1/namespaces/default/configmaps/my-first-config
  uid: 909cd03d-b38e-41d3-875e-d784d42d9701
```

---

# ConfigMaps

Based on the previous example we should state that ConfigMaps:

1. Are **just a key-value store** for configuration data.
2. Are **not aware** of how they will be presented to the application.

---

# ConfigMap Structure

As first-class Kubernetes objects, ConfigMaps have a strict structure:

- `apiVersion`: value should be `v1`
- `kind`: value should be `ConfigMap`
- `data`: key-value pairs inside the UTF-8 range
- `metadata`: [`ObjectMeta` type](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta)

---

# A Richer ConfigMap Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
  labels:
    app: docker-training-samples-redis
data:
  REDIS_DB: "0"
  REDIS_HOST: "redis"
```

---

# Consuming ConfigMap data inside a Pod

There are 2 options for consuming ConfigMap data inside a Pod:

1. Environment variables
2. Volumes

---

# ConfigMap Data as Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod-example-1
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      env:
        - name: ENVIRONMENT  # Name of environment variable in container
          valueFrom:
            configMapKeyRef:
              name: my-first-config  # Name of ConfigMap
              key: environment # Key inside the `data` section of ConfigMap
```

The developer is in charge of the configuration baseline.

---

# All ConfigMap Data as Environment

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod-example-2
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      envFrom:
        - configMapRef:
            name: my-first-config  # Name of ConfigMap
```

The system administrator is in charge of the configuration baseline.

---

# ConfigMap as Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod-example-3
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
        name: my-first-config  # Name of ConfigMap
```

---

# ConfigMap Data as Files in Custom Path


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod-example-4
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
        name: my-first-config  # Name of ConfigMap
        items:
          - key: environment  # Key in ConfigMap
            path: environment # Path in containers of Pod
          - key: environment
            path: environment_again # Path in containers of Pod
```

---

# ConfigMaps Restrictions

1. You must create a `ConfigMap` before referencing it in a `Pod` specification.
2. If you use `envFrom` to define environment variables from `ConfigMaps`, invalid keys will be skipped.
3. `ConfigMaps` reside in a specific namespace. A `ConfigMap` can only be referenced by `Pods` in the same namespace.

---

# ConfigMaps Worst Practices

1. Using `ConfigMaps` to store secret data (e.g. database passwords)
2. **NOT** using ConfigMaps for the rest of your configuration! 😂

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

# Use Cases for Secrets

Secrets are great for holding information such as

1. Database credentials
2. OAuth tokens
3. TLS keys and certificates

---

# Secret Types

Kubernetes supports three distinct secret types:

1. Generic secrets: Any kind of data intended to be kept secret
2. Docker Registry secrets: Computer generated authentication certificates for pulling images
3. TLS secrets: Computer generated TLS certificates and keys based on a key pair

---

# Generic Secrets

We will only examine generic secrets here.

Docker Registry and TLS secrets are not intended to be used as application configuration.

<small>Beware that generic secrets **are not** actually secrets, <em>yet</em>.</small>

---

# Creating your first Secret

```console
kubectl create secret generic my-first-secret --from-literal=my_secret=combination
```

---

# Creating your first Secret

```console
paris at ~ ⠕ kubectl create secret generic my-first-secret --from-literal=my_secret=combination
secret/my-first-secret created
```

<small>
  <a href="https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-generic-em-" target="_blank">
    <code>kubectl create secret generic</code> docs
  </a>
</small>

---

# Your First Secret

```console
kubectl get secret my-first-secret -o yaml
```

---

# Your First Secret

```console
paris at ~ ⠕ kubectl get secret my-first-secret -o yaml
apiVersion: v1
data:
  my_secret: Y29tYmluYXRpb24=
kind: Secret
metadata:
  creationTimestamp: "2020-05-08T07:35:29Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:my_secret: {}
      f:type: {}
    manager: kubectl
    operation: Update
    time: "2020-05-08T07:35:29Z"
  name: my-first-secret
  namespace: default
  resourceVersion: "99121"
  selfLink: /api/v1/namespaces/default/secrets/my-first-secret
  uid: 7279f991-db1c-42f5-8929-1c6bed853ba2
type: Opaque
```

---

# Secret Structure

As first-class Kubernetes objects, Secrets have a strict structure:

- `apiVersion`: value should be `v1`
- `kind`: value should be `Secret`
- `data`: key-value pairs inside the UTF-8 range
- `metadata`: [`ObjectMeta` type](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta)

---

# A Richer Secret

```console
kubectl create secret generic richer-secret --from-literal=auth_user=velti --from-literal=auth_password=training
```

---

# Consuming Secret data inside a Pod

There are 2 options for consuming Secret data inside a Pod:

1. Environment variables
2. Volumes

---

# Secret Data as Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-in-pod-example-1
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      env:
        - name: AUTH_USER  # Name of environment variable in container
          valueFrom:
            secretKeyRef:
              name: richer-secret  # Name of Secret
              key: auth_user # Key inside the `data` section of Secret
        - name: AUTH_PASSWORD
          valueFrom:
            secretKeyRef:
              name: richer-secret
              key: auth_password
```

---

# Secret Data as Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-in-pod-example-2
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      volumeMounts:
      - name: secret-volume
        mountPath: /etc/secrets
  volumes:
    - name: secret-volume
      secret:
        secretName: richer-secret
```

---

# Secret Data in Custom Path

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-in-pod-example-3
spec:
  containers:
    - name: docker-training-samples-micro-flask
      image: 2hog/docker-training-samples-micro-flask
      volumeMounts:
      - name: secret-volume
        mountPath: /etc/secrets
  volumes:
    - name: secret-volume
      secret:
        secretName: richer-secret
        items:
          - key: auth_user
            path: credentials/user
          - key: auth_password
            path: credentials/password
```

---

# Prepared Configuration File as Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-with-prepared-data
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

# Secrets Restrictions

1. You must create a `Secret` before referencing it in a `Pod` specification.
2. Individual secrets are limited to 1MB in size.
3. References via `secretKeyRef` to keys that do not exist in a named Secret will prevent the Pod from starting

---

# Secrets worst practices

1. Using Secrets to store whole configuration files
2. **NOT** using Secrets for configuration with sensitive data 😂!

---

# Let's see Secrets in practice!

https://bit.ly/2QOUtL4

---

# The Big Win of ConfigMaps and Secrets

ConfigMaps and Secrets provide a clean contract between developers and system administrators.

System administrators control ConfigMaps and Secrets regardless of how they are being consumed.

---

# Try me. Ask your weirdest questions!

---

class: center

# Thanks!
