layout: true
class: middle

---

# Development with Docker and containers

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

# [p.2hog.codes/docker-development](https://p.2hog.codes/docker-development)

---

# Agenda

1. Why develop applications in containers?
1. Setting up a containerized development environment
1. Building efficient images

---
class: center

# Why develop applications in containers?

---

# Current state in development environments

* We use our local machine
  * Almost certainly miss-configured
* We use a virtual machine
  * How easy can you keep system dependencies in sync?
  * Do you really deploy in a single machine?
* We test some part of our infrastructure
  * Mocking is great, but how do you make good end to end testing while developing?

---

# The tooling

* Vagrant
  * Create a well-configured VM
* Docker
  * Make sure you develop in the correct runtime
* Docker Compose
  * Make sure you develop in the correct stack

---

# When reality strikes

* Is setting up dev environments quick and easy?
  * How much time do you need? Can you easily create a second environment?
* What’s the divergence between your dev environment and production
  * How many backing services you mock or don’t run at all?
* Is your developer environment disposable?
  * How confident are you to just completely delete it?

---

# Multiple staging environments is (not) the answer

--

* It costs time and money to maintain
* It’s either incomplete
  * …or is costs more time and money to maintain
* You get easily locked out
  * …or you need even more staging environments

---

# The DevOps dream

---

# Getting from here

.center[![:scale 50%](/images/docker-development/before-devops.png)]

--

# To here

.center[![:scale 50%](/images/docker-development/after-devops.png)]

---

# Quick and easy setup process

* All your development infrastructure is defined in code
* Image caching makes updates seamless
* There's no "setup manual"

---

# Docker as a runtime and image format

* Allows for easily distributing a runnable unit in different environments
* Docker containers are always built and run in the same way
* Avoid needing a complex VM setup process to develop applications locally

---

# Why have the same environment everywhere?

* Avoid works-on-my-machine excuses — it should work everywhere in the same way
* Easily test new features, as the whole stack can run from your local computer, to your CI and production cluster

---

# Disposability for the win!

* Development environment are ephemeral
  * State is saved at volumes and can be reused if needed
* Can easily have multiple environments running side by side without any hassle
* Re-create the whole environment at the glimpse of an eye

---
class: center

# Setting up a containerized development environment

---

# The local toolchain

* Your editor of choice
* Docker for Mac/Windows
  * Native support for the OS
* Docker Compose

---

# The tooling needed for development

* Auto reloading web servers
  * Nodemon, gin, Django, Flask, etc
* Web-based on container-native debuggers
  * Python `wdb`, Node.js `--inspect`, _your favorite language/debugger combination here_

---

# Development vs Production

In development we have a few needs that do not exist in production, staging, qa etc. environments:

1. Docker image building
2. Running app without rebuilding Docker image
3. Access running app locally — outside of container runtime's network


---

# The app we'll develop

.center[![](/images/docker-development/microservices-app.png)]

---

# Development patterns

1. Develop each app in isolation
2. Develop an app, using other apps as external services
3. Develop all apps concurrently

---

# Develop each app in isolation

The application does not need any backing services (or uses mocks)

---

# Let's get our hands dirty!

```bash
git clone https://github.com/2hog/docker-training-samples-micro-flask
```

???

Develop the Flask application, as a standalone app

---

# Develop an app, using other apps as external services

Use the rest of the apps as backing services, using pre-built images living  in the app's own private network

---

# Let's get our hands dirty!

```bash
git clone https://github.com/2hog/docker-training-samples-micro-django
```

???

Develop the Django application, as a standalone app using the rest of the apps as backing services

---

# Develop all apps concurrently

1. All apps will be launched with direct access to the source code
2. Dependencies will be assumed to be already running
3. All apps will live in a shared network, using the same `COMPOSE_PROJECT_NAME`

---
class: center

# Building efficient Docker images

---

# Base your images to lightweight images

--

* You base images might include a lot of bloat, that you probably do not need
* Your Docker images do not need to include everything you might think of
* You probably do not need a full OS to run your simple process

---

# Let's see an example

--

```bash
docker pull centos
docker pull alpine
docker image inspect centos --format '{{ .Size }}' | awk '{print $1 / 1024 / 1024, "MB"}'
docker image inspect alpine --format '{{ .Size }}' | awk '{print $1 / 1024 / 1024, "MB"}'
```

---

# Keep the same base image for most of your applications

--

* Start with a base image from Docker Hub
* Create your own base image on top of it
* Try to use this as the base image for all your applications

???

Even if the base image is large enough, basing all images of it allows for quicker pulls and less storage
Keeping up with security updates is easier if you make sure your base images is always secure

---

# Do not add stuff you do not need

--

* Don't add a debugger, you won't debug your containers
* Don't add cURL

???

* If you need to add a debugging tool to debug a container, you can do it on-demand when you need it
* Adding tools you might not need increases the image size, the attack surface and makes builds slower

---

# Group commands to optimize layers

--

* Group commands that do a clean up
* Otherwise, you'll still ship the "large" layer with your image
* Each image layer only _adds up_ space, it doesn't truncate it

---

# Let's see an example

--

```bash
# Dockerfile.split
FROM alpine:latest
RUN apk add -U bind-tools
RUN rm -f /var/cache/apk/*
```

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

--

* Place commands that break the cache further down the Dockerfile
* Place commands that are time-consuming but do not change often at the top

---

# Let's see an example

```dockerfile
# Dockerfile.simple
FROM python:3.6
WORKDIR /code
ADD . /code
RUN pip install -r requirements.txt
```

--

```dockerfile
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

--

* Start from a thin image
* Add all needed dependencies to build your artifact
* Start again, from a smaller image
* Copy your artifact
* Produce a thinner final image

---

# Multi-stage build examples

--

* Builds a {JAR, Go/C/C++ binary}, copy it over
* Build some static assets with Node for your {Python, Go, you-name-it} application
* Build a needed library, with lots of dependencies

---

# Thanks!
