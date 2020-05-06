
layout: true
class: middle

---
class: center

# Migrating legacy applications to containers

---

# .center[2hog]

.center[We teach the lessons we have learnt the hard way in production.]
.center[Consulting, training and contracting services on containers, APIs and infrastructure]

.footnote[https://2hog.codes]

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

# [dojo.2hog.codes](https://dojo.2hog.codes)

# [p.2hog.codes/docker-legacy-apps](https://p.2hog.codes/docker-legacy-apps)


---

# Agenda

1. The DevOps dream
1. Efficient Docker images
1. Exercise: setting up a Ruby microservice with Sinatra
1. Exercise: setting up a Python microservice with Django, which connects to the other two services and needs migrations
1. Exercise: setting up a PHP microservice with Slim
1. Case study: from monoliths to a fully-containerized infrastructure

---

# The DevOps dream

---

# Getting from here

.center[![:scale 50%](/images/docker-development/before-devops.png)]

--

# To here

.center[![:scale 50%](/images/docker-development/after-devops.png)]

---

# Why have the same environment everywhere?

---

* Avoid works-on-my-machine excuses — it should work everywhere in the same way
* Easily test new features, as the whole stack can run from your local computer, to your CI
* Speed up project onboarding time

---

# Optimizing your delivery pipeline

* Same runtime in development, CI and production
* Use the same declarative format all the way
* Focus on what you do best

???

* Docker Compose works both in one node and Docker Swarm
* Developers should code
* Ops should manage infrastructure
* Application management is left to the Swarm

---

# Docker as a runtime and image format

* Allows for easily distributing a runnable unit in different environments
* Docker containers always run in the same way

---

# Docker in your CI system

* Use the same Docker Compose file to run your tests
* Spin up a test infrastructure in no time and tear it back down
* Do not maintain external testing infrastructure, requiring your build agents to synchronize

---
class: center

# Building efficient Docker images

---

# Base your images to lightweight images

* You base images might include a lot of bloat, that you probably do not need
* Your Docker images do not need to include everything you might think of
* You probably do not need a full OS to run your simple process

---

# Let's see an example

```bash
docker pull centos
docker pull alpine
docker image inspect centos --format '{{ .Size }}' | awk '{print $1 / 1024 / 1024, "MB"}'
docker image inspect alpine --format '{{ .Size }}' | awk '{print $1 / 1024 / 1024, "MB"}'
```

---

# Keep the same base image for most of your applications

* Start with a base image from Docker Hub
* Create your own base image on top of it
* Try to use this as the base image for all your applications

???

Even if the base image is large enough, basing all images of it allows for quicker pulls and less storage
Keeping up with security updates is easier if you make sure your base images is always secure

---

# Do not add stuff you do not need

* Don't add a debugger, you won't debug your containers
* Don't add cURL

???

* If you need to add a debugging tool to debug a container, you can do it on-demand when you need it
* Adding tools you might not need increases the image size, the attack surface and makes builds slower

---

# Group commands to optimize layers

* Group commands that do a clean up
* Otherwise, you'll still ship the "large" layer with your image
* Each image layer only _adds up_ space, it doesn't truncate it

---

# Let's see an example

```bash
# Dockerfile.split
FROM alpine:latest
RUN apk add -U bind-tools
RUN rm -f /var/cache/apk/*
```

--

```bash
# Dockerfile.grouped
FROM alpine:latest
RUN apk add -U bind-tools && \
    rm -f /var/cache/apk/*
```

--

```bash
docker build -t split --file=Dockerfile.split .
docker build -t grouped --file=Dockerfile.grouped .
docker image inspect split --format '{{ .Size }}' | awk '{print $1 / 1024 / 1024, "MB"}'
docker image inspect grouped --format '{{ .Size }}' | awk '{print $1 / 1024 / 1024, "MB"}'
```

---

# Optimize cache

* Place commands that break the cache further down the Dockerfile
* Place commands that are time-consuming but do not change often at the top

---

# Let's see an example

```bash
# Dockerfile.simple
FROM python:3.6
WORKDIR /code
ADD . /code
RUN pip install -r requirements.txt
```

--

```bash
# Dockerfile.cached
FROM python:3.6
WORKDIR /code
ADD requirements.txt /code/requirements.txt
RUN pip install -r requirements.txt
ADD . /code
```

???

* Although we're creating one more layer, the final image can utilize cache better
* Caching helps a lot during development and CI, as it speeds builds up

---

# Use multi-stage builds

* Start from a thick image
* Add all needed dependencies to build your artifact
* Start again, from a smaller image
* Copy your artifact
* Produce a thinner final image

---

# Multi-stage build examples

* Builds a {JAR, Go/C/C++ binary}, copy it over
* Build some static assets with Node for your {Python, Go, you-name-it} application
* Build a needed library, with lots of dependencies

---
class: center

# Exercises

---

# Let's get the code

```bash
git clone --recurse-submodules https://github.com/2hog/docker-training-samples
cd docker-training-samples
```

---

# Exercise: setting up a Ruby microservice with Sinatra

???

* Secrets
* Overriden as env variables
* Test with .env file

---

# Exercise: setting up a Python microservice with Flask

???

* Overriden build args

---

# Exercise: setting up a Python microservice with Django

.footnote[connects to the other two services, builds assets with Node.js and needs migrations]

???

* Multi-stage builds
* Use existing images for integration testing

---

# Exercise: setting up a PHP microservice with Slim

???

* NGINX + FPM
* Two different images built
* Different mount points

---
class: center

# Case study: from monoliths to a fully-containerized infrastructure

---

# The stack

* Classic Java monoliths
* Deployed to customer servers by people
* Minimal automation, mainly with scripts

---

# The need

* A SaaS-like service, serving the same purpose as the customer-deployed products
* Quicker iterations on new versions and features
* Multiple deployed versions of the software at once
* Easy scale up/down of specific components

---

# The answer

Docker all the things!

---

# First, baby steps

* Put everything in a container
* Create supporting software to make it work as we pleased

---

# Get a PoC ready

* Create a container cluster
* Deploy the monolith (in a container)
* Showcase that things can work in containers too

---

# Start splitting

* Split parts that are not needed by the new service
* Make logical splits, where things should be separated or scaled differently

---

# Create a continuous integration and deployment system

* Make sure tests pass on each push
* Define a branching strategy
* Create a Docker image on master branch and all tags
* Deploy automatically each version that lands in master

---

# Start using the new infrastructure and see how it performs

* Monitor all the services for RAM and CPU usage — prometheus to the rescue
* Create nice graphs using Grafana, so that everyone starts to take a glimpse of what is happening
* Try to stabilize the resource usage of the different components

---

# Health check your applications

* Better deployments, since traffic is routed only after a service is healthy
* Kill services that are unhealthy, automatically

---

# Create reservations and enforce limits

* After deciding on the optimal memory and CPU usage of each component, start deciding on the reservation and limit to impose
* Use the average with small increase as a reservation, if you don't have a lot of spikes
* Use the (expected) spikes as a hard limit

---

# Plan ahead

* Now that you know how each service performs, it's easy to estimate your cluster size
* Start with the reserved memory and CPU, include information from spikes and add some padding for safety
* If you need (small) dynamic scaling, allow for some more space to avoid continuously scale up/down your cluster

---
class: center

# Thanks!
