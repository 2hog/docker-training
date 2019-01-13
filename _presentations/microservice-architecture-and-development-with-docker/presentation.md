
layout: true
class: middle

---

# Microservice architecture and development with Docker

--

[p.2hog.codes/microservice-architecture-and-development-with-docker](https://p.2hog.codes/microservice-architecture-and-development-with-docker)

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

# [p.2hog.codes/microservice-architecture-and-development-with-docker](https://p.2hog.codes/microservice-architecture-and-development-with-docker)

---

# Agenda

1. Intro to Microservices
2. Microservice architecture in Kubernetes
3. Microservice development with Docker

---

# Intro to Microservices

---

# Microservices

Microservices are a variant of the Service Oriented Architecture (SOA) style.

---

# Service Oriented Architecture?

---

# Service Oriented Architecture

Service Oriented Architecture is a software development style structuring applications as collections of loosely coupled services.

In Service Oriented Architecture services are provided to other components, through a communication protocol over a network.

---

# Back to Microservices

---

# Microservices

In Microservices architecture, services are fine-grained and the protocols are lightweight.

---

# Microservices principles

---

# Microservices principles

1. Microservices are processes communicating over a network using technology-agnostic protocols (e.g. HTTP, gRPC).
2. Microservices are independently deployable.
3. Microservices are organized around fine-grained business capabilities.
    > ☝️ This is key in differentiating Microservices from SOA.

---

# Quiz time!

---

# Is it OK for two Microservices to depend both on each other?

---

# Is it OK for two Microservices to depend both on each other?

**No**.

---

# Is it OK for two Microservices to depend both on each other?

**No**.

This would go against the Service Oriented Architecture nature of Microservices:

> In Service Oriented Architecture applications are structured as collections of loosely coupled services.

> The components of a loosely coupled system make use of little or no knowledge of the definitions of other components.

---

# Is it OK for two Microservices to need concurrent or sequencial deployments?

---

# Is it OK for two Microservices to need concurrent or sequencial deployments?

**No**.

---

# Is it OK for two Microservices to need concurrent or sequencial deployments?

**No**.

This would go against the 2nd Microservice principle:

> Services in a Microservices architecture are independently deployable.

---

# Microservices "Do"s and "Don't"s

---

# Microservices "Do"s

Below are a few practices that you _can_ apply in Microservice architecture:

1. Develop each Microservice with a dedicated team
2. Use different programming languages among Microservices (be reasonable!)
3. Use API versioning in each Microservice with dependants

---

# Microservices "Don't"s

Below are a few practices that you **should** avoid when developing microservices

1. Use the same store (e.g. the same database) in multiple Microservices
2. Have two (or more) Microservices depending on each other
3. Hardcode Microservice endpoints in dependant applications

---

# Benefits and caveats

---

# Benefits of Microservices

1. Independently scalable components
2. Agility in big organizations
3. Focused teams delivering specific results

---

# Caveats of Microservices

---

# Caveats of Microservices

1. Shipping an end-user-facing feature may imply coordination among multiple teams
2. Debugging and tracing can get complex and time consuming
3. Transactional operations **are a nightmare** to implement

---

# Quiz time!

---

# Is Redis itself considered a Microservice?

---

# Is Redis itself considered a Microservice?

**No**. Redis uses its own technology-aware protocol.

> **Microservices principle #1:** Microservices are processes communicating over a network using technology-agnostic protocols (e.g. HTTP, gRPC).

---

# Can I store multiple microservices in the same repo?

**Technically yes**. This would make getting independent deployment right tougher though.

> **Microservices principle #2:** Services in a microservice architecture are independently deployable.

---

# Should I adapt my application to Microservice architecture?

---

# Should I adapt my application to Microservice architecture?

**Only you can answer that!**

Microservices architecture **is not** a best-practice!

Microservices architecture is just a software architecture paradigm. Embrace it only if it makes sense for your business.

---

# Microservices in a nutshell

Microservices embrace the Unix philosophy of "Do one thing and do it well" over the network.

---

# Microservices architecture in Kubernetes

---

# Microservices architecture in Kubernetes

Now that we know what Microservices are, let's see how to implement them in Kubernetes.

---

# Microservices

Technically, Microservices are **processes** communicating over lightweight **network** protocols.

---

# Implementing Microservices in Kubernetes

We need three Kubernetes objects to implement Microservices in Kubernetes.

---

# Pods

---

# Pods

A Pod is a group of one or more containers, with shared network and a specification for how to run the containers.

Microservices processes will be materialized as Kubernetes Pods.

---

# Services

---

# Services

A Service is an abstraction defining a logical set of Pods and a policy to access them over the network.

Microservices processes will be made accessible via the Kubernetes' network using Services.

---

# ConfigMaps and Secrets

---

# ConfigMaps and Secrets

ConfigMaps and Secrets bind configuration to your Pods' containers at runtime.

ConfigMaps and Secrets will help Microservices know how to reach each other.

---

# A Microservices application on Kubernetes

---

# High-level overview

![Microservices app](/presentations/microservice-architecture-and-development-with-docker/images/microservices-app.png)

---

# Django application

https://github.com/2hog/docker-training-samples-micro-django

Implements a single endpoint (`GET /`) which:

1. Requires session authentication
2. Requests a greeting via a `POST` request from the greeting service
3. Requests an HTML fragment for the received greeting via a `GET` request from the content service
4. Returns an HTML document to the user, including the received HTML fragment

---

# Sinatra application

https://github.com/2hog/docker-training-samples-micro-sinatra

Implements a single endpoint (`POST /`) which:

1. Requires basic authentication
2. Returns a JSON response with a greeting

---

# Flask application

https://github.com/2hog/docker-training-samples-micro-flask

Implements a single endpoint (GET /) which:

1. Requires basic authentication
2. Returns an HTML page fragment, based on the given greeting URL parameter

---

# High-level overview

![Microservices app](/presentations/microservice-architecture-and-development-with-docker/images/microservices-app.png)

---

# Let's get our hands dirty!

---

# Microservices development with Docker

---

# Microservices development with Docker

We have seen what Microservices architecture is and how to implement it in Kubernetes.

But, _how are we going to get there?_

---

# Development vs Production

In development we have a few needs that do not exist in production, staging, qa etc. environments:

1. Docker image building
2. Running app without rebuilding Docker image
3. Access running app locally — outside of container runtime's network

---

# Required tools

1. Editor
2. Docker
3. Docker Compose

---

# Development patterns

1. Develop each app in isolation
2. Develop all apps concurrently

---

# Develop each app in isolation

1. Each app will run its dependencies as Docker images
2. Each app and its dependencies will live in the app's own private network

---

# Let's get our hands dirty!

---

# Develop all apps concurrently

1. All apps will be launched with direct access to the source code
2. Dependencies will be assumed to be already running
3. All apps will live in a shared network

---

# Develop all Microservices together

---

# Let's get our hands dirty!

---

# Ask your most weird questions!

---

class: center

# Thanks!
