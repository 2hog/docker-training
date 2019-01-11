
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

# Microservices principles

---

# Microservices principles

1. Microservices are processes communicating over a network using technology-agnostic protocols (e.g. HTTP, gRPC).
2. Services in a microservice architecture are independently deployable.
3. Services are organized around fine-grained business capabilities. 🙌 This is key in differentiating Microservices from SOA.

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

# Let's take a few quizes!

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

# Microservice architecture in Kubernetes

---

# Microservice development with Docker

---

# Ask your most weird questions!

---

class: center

# Thanks!
