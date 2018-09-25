layout: true
class: middle

---

class: center

# Intro to Docker and Containers

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

# [p.2hog.codes/intro-docker-containers](https://p.2hog.codes/intro-docker-containers/)

---

# Agenda

1. What is a container
2. What is Docker
3. Docker Containers
4. Docker Images
5. Volumes and networks
6. Docker Compose

---

class: center

# Why Docker?

---

# An outdated software delivery pipeline

1. A developer implements a new software feature
2. The developer commits the new feature in Source Control (e.g. Git, SVN etc.)
3. The developer requests from an "operations person" to deploy the new feature
4. The "operations person" prepares the host machine (updates libraries etc.)
5. The "operations person" pulls and runs the new version of the software, replacing the old

---

# Issues

1. Man hours are wasted on chores
2. High risk of mistakes due to human factor
3. High infrastructure costs
4. Clear productivity bottleneck

---

# An old-school software delivery pipeline

1. A developer implements a new software feature
2. The developer commits the new feature in Source Control (e.g. Git, SVN etc.)
3. A Virtual Machine with the new software gets deployed on the cloud

---

# Issues

1. Super complex setup procedure
2. Long lasting deployments
3. High infrastructure costs

---

# A fresh software delivery pipeline

1. A developer implements a new software feature
2. The developer commits the new feature in Source Control (e.g. Git, SVN etc.)
3. A new Docker Container gets deployed, replacing the old one automatically

---

class: center

# What is a Container though?

Containers are a set of **kernel tools and features** that **jail** and **limit** a process based on our needs.

---

# Virtuals Machines vs. Containers?

They should co-exist. We should run N Containers in M Virtual Machines (N > M).

Imagine a Virtual Machine as a multi-floor building and a Container as a rented flat.

- **Virtual Machines** provide deep isolation, so they are heavy and not versatile
- **Containers** are fast and lightweight

???
* They share the same plumbing
* Each flat has its own limits
* They all must cooperate for the good operation of the building

VS

* You have your own pool
* You can turn up the heat whenever you want
* Comes at a cost
* Fixing infrastructure issues is more time and money consuming

---

# What is a Container? (in a bit more details)

* It’s a process
* Isolated in it’s own world, using **namespaces**
* With limited resources, using **cgroups**

---

# Namespaces

.center[A **namespace** wraps a global system resource in an abstraction that makes it appear to the processes within the namespace that **they have their own isolated instance of the global resource**. Changes to the global resource are visible to other processes that are members of the namespace, but are invisible to other processes. One use of namespaces is to **implement containers**.]

.footnote[The Linux man-pages project:<br />http://man7.org/linux/man-pages/man7/namespaces.7.html]

---

# Popular Namespaces

* net
* mnt
* user
* pid

---

# cgroups

.center[**cgroups** (abbreviated from control groups) is a Linux kernel feature that **limits, accounts for, and isolates** the resource **usage** (CPU, memory, disk I/O, network, etc.) of a collection of processes.]

.footnote[Wikipedia:<br />https://en.wikipedia.org/wiki/Cgroups]

---

# Popular cgroups

* memory
* cpu/cpuset
* devices
* blkio
* network*

.footnote[*network is not a real cgroup, it’s used though for metering]
---

# What is Docker

Docker is an operating system for your data center.

---

# Docker core features

* Copy on Write file system
* Software Defined Networking
* Volume management
* Built-in Orchestration

???

* Custom OS, lightning fast
* Join multi-host SDNs
* Take your data with your
* Stop managing and caring about machines

---

# The Docker platform building blocks

--

* runc - the runtime
* containerd - the container manager
* Docker Swarm - the orchestrator

???

* Makes sure your applications run in a container
* Managed containers for your, in a single machine
* Orchestrates the distribution of containers in multiple nodes

Today we're going to interact with the first two layers only

---

# Run your first container

```bash
docker run -it alpine sh
```

--

```bash
whoami
uname -a
top
exit
```

---

# What did just happen?

--
* The Alpine image was pulled

--
* A new container (aka a process) was started using that image

--
* The process was isolated is its own namespace

--
* A TTY was opened for us, so we could run commands

---

# Run your first container(s)

```bash
# Next, run the following commands and compare the output

docker run node:8-alpine node --version

docker run node:6-alpine node --version
```

???
* Let them run a container with a different image tag, to see that pulling happens and understand the containment
* Let them run a container twice, to see that pulling happens only once
* Show the speed of container start, as it's just a process

---

# Deconstructing `docker run`

- `docker`: Invokes the Docker Engine client
- `run`: Instructs `docker` to run a container
- `node:8-alpine`: The image to use as root file system
- `node --version`: The command that should be run as a container

https://docs.docker.com/engine/reference/commandline/run/

---

# Let's try something a bit different

--
```bash
# First, run this command to create a sleeping container

docker run -d alpine sleep 600
```

--
```bash
# Then, run this command to jump into the host's PID namespace and see all the processes

docker run -it --pid=host alpine sh

top
exit
```

???

* If we jump out of our namespace, we can see everything that is running in the host
* Containers are processes, so we can see the previous container

---

# How can I see all these containers?

--
```bash
# List running containers
docker container ls

➜  ~ docker container ls
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
2ccff4c6edbf        alpine              "sleep 600"              4 minutes ago       Up 4 minutes

```

--
```bash
# List all containers, including dead ones
➜  ~ docker container ls --all
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
fc72afff0e78        alpine              "sh"                12 minutes ago      Exited (0) 12 minutes ago                       happy_minsky
2ccff4c6edbf        alpine              "sleep 600"         12 minutes ago      Up 12 minutes                                   thirsty_allen
95a5a31b4ad7        node:8-alpine       "node --version"    17 minutes ago      Exited (0) 17 minutes ago                       reverent_shannon
5306c8b25632        node:6-alpine       "node --version"    17 minutes ago      Exited (0) 17 minutes ago                       admiring_lamport
```

???

* We're now using containerd, to get the status of the different containers
* runc is on the process level, we don't interact directly with it

---
# Docker Images

The basis of Docker Containers

* They provide the root file system for a Docker Container
* They contain the meta data needed to run (e.g. exposed ports, health check instructions etc.)
* They are structured in sequential layers
* They are distributed via Docker Registry instances (mostly via [https://hub.docker.com/](https://hub.docker.com/))

---

# Create your first image

--

In order to create a Docker image, we need each recipe - the Dockerfile

[https://git.io/vdhKH](https://git.io/vdhKH)

---

# The `Dockerfile`

The Dockerfile is a text file that contains all commands needed to build an image.

*(The Dockerfile plays the same role as a recipe for a food)*

## Example

```dockerfile
FROM openjdk:8

COPY Main.java /usr/src/app/Main.java
WORKDIR /usr/src/app
RUN javac Main.java
CMD ["java", "Main"]
```

https://docs.docker.com/engine/reference/builder/

---

# Building your Docker Image

Run the following command to build your Docker Image, based on the Dockerfile and run a container with it.

*(The Docker Image plays the same role as the cooked food of the recipe)*

## Example

```bash
docker build -t myjava .
docker run myjava
```

---

# Deconstructing `docker build`

- `docker`: Invokes the Docker Engine client
- `build`: Instructs `docker` to build a new image
- `-t myjava`: Give the name `myjava` to the resulting image
- `.`: Use the current directory to find the Dockerfile and needed files

https://docs.docker.com/engine/reference/commandline/build/

---

# Dockerfile, image and container

* Dockerfile -> Source code - the recipe to build an image
* Image -> Class - the actual, built output of the Dockerfile
* Container -> Object - the thing that runs

---

# The container best-practice list

--

1. Containers should be considered ephemeral
2. The container should be single-purposed program (e.g. avoid using `supervisord`)
3. The image should be lightweight and slim
4. Configuration should be made by the environment, with sane defaults
5. Orchestration should be carried out by an external tool

???

* Following these principles and good practices, allows for better management and utilization of the underlying infrastructure
* This also imposes some issues

---

# Networks and service discovery
--

* Every container gets an IP inside the SDNs that it participates
* Service discovery is made using the embedded DNS server
* There are different plugins for the networking implementation

???

* There are different implementations for networking plugins, sporting differet sets of features
* There are two major container networking standards, CNM (Docker) and CNI (Kubernetes)
* They are probably going to be merged into one some time in the future

---

# Let's see a demo

```bash
# First, we need to create a network
docker network create demonet
```
--

```bash
# Then, we need to start an NGINX container
docker container run -d --network demonet --network-alias nginx nginx:alpine
```
--

```bash
# Last, let's try hitting it from another container
docker container run -it --network demonet alpine sh
apk add -U curl bind-tools
dig nginx
curl nginx
```

???

* The container got an IP inside this network
* The internal DNS server, resolved the nginx domain to that IP
* We could easily hit the container from another container, as long as they are in the same network

---

# Managing data
--

* Containers cannot always be stateless, they need to store state
* Since containers are ephemeral, we need a persistent way to store data between runs
* Volume plugins abstract the source of the data and mount a directory inside a container

???

* Volumes are needed for containers like databases, caches, or other applications that need to store state in the disk
* Volume plugins include implementations for things like GlusterFS, NFS, block storate, even S3 storage
* The container finds the previous state in place when it starts

---

# Let's see a demo

```bash
 # First, we need to create a volume
docker volume create demovol
```
--

```bash
# Then, we need to start a container, attaching this volume and adding some data
docker container run -v demovol:/mnt/data -it alpine sh
cd /mnt/data/
ls
echo 'Docker is awesome' > what-is-docker.txt
```
--

```bash
# Last, we can view this data from another container
docker container run -d -p 9090:80 -v demovol:/usr/share/nginx/html nginx:alpine
open localhost:9090/what-is-docker.txt
```

???

* The data was persisted inside this volume, which was then passed to the next container
* The default volume plugin is the local one, which stores all data in locally created directories in the host
* Other plugins might be able to transfer volumes between hosts, so that the data follows the container

---

class: center

# Docker Compose

---

# Docker Compose

A tool for defining and running multi-container Docker applications.

It manages complete stacks containing:

- Containers
- Networks
- Volumes

[https://docs.docker.com/compose/](https://docs.docker.com/compose/)

---

# Why Docker Compose

* Declarative format, simple YAML syntax
* Can be used for development, testing and production

???

* No need to run or rember complex Docker commands
* Always make sure that an application is deployed in the same way
* Mastering it allows for powerful development/deployment workflows

---

# Let's see an example

https://git.io/vbasP
--

```bash
# After saving the docker-compose.yml file locally, run the following command
docker-compose up
```

---

class: center

# That's all folks!

## Thank you