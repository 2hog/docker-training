layout: true
class: middle

---

# Application configuration on Kubernetes

--

[p.2hog.codes/2020-application-configuration-on-kubernetes/](https://p.2hog.codes/2020-application-configuration-on-kubernetes/)

[dojo.2hog.codes/classes/4/decks/3/](https://dojo.2hog.codes/classes/4/decks/3/)

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

1. Configuration in Kubernetes
2. ConfigMaps
3. Examples with ConfigMaps
4. Secrets
5. Examples with Secrets

---

class: center

# Application configuration on Kubernetes

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

```console
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

```console
paris at ~ ⠕ kubectl get configmap greeter-config -o yaml
apiVersion: v1
data:
  environment: training
kind: ConfigMap
metadata:
  creationTimestamp: "2020-05-07T21:46:25Z"
  name: greeter-config
  namespace: default
  resourceVersion: "411"
  selfLink: /api/v1/namespaces/default/configmaps/greeter-config
  uid: 33507e2b-90ac-11ea-bd52-02428f875c88
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
  creationTimestamp: "2020-05-07T21:50:28Z"
  name: greeter-secret
  namespace: default
  resourceVersion: "725"
  selfLink: /api/v1/namespaces/default/secrets/greeter-secret
  uid: c3ef222a-90ac-11ea-bd52-02428f875c88
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
