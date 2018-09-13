name: inverse
layout: true
class: middle, inverse

---

class: center

# Infrastructure as Code

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

# [p.2hog.codes/infrastructure-as-code/](https://p.2hog.codes/infrastructure-as-code/)

---

# Agenda

1. What does infrastructure as code mean
2. What is Terraform
3. Basic Terraform concepts
4. Provisioning a cluster with Terraform

---

# What does infrastructure as code mean?

--

1. Version control your infrastructure, having a logged history of it
2. Easily replicate your infrastructure, between different environments
3. Automate everything, keeping human error to the minimum

???

* You know when something changed and by whom
* Infrastructure is reproducible, making it ideal for failure recovery and replicating environments
* Automation eliminates mistakes and makes changes easier]
* Also, move between providers easier, but not for free

---

# Different methods

--

Pull vs Push

???

* Push goes and configures the service
* Pull has the configuration available and the servers pull it and apply it

---

# Infrastructure as code tooling

* Ansible (Python, push)
* CFEngine CFEngine (Pull)
* Chef (Ruby, pull)
* Otter (Push)
* Puppet (Ruby, pull)
* SaltStack (Python, push and pull)
* Terraform (Go, push)
* Infrakit (Go, push and pull)

---

# What is Terraform

Terrafrom is a declarative infrastructure as code tool, that pushes changes to servers, written in Go

--

* Built by HashiCorp
* Uses HCL (HashiCorp configuration language)
* Has lots of addons and tooling for different use cases
* Works with all major clouds

---

# Basic Terraform concepts

--

* State — keeps track of what has happened and is used to compute what is going to happen next
* Providers — provide the way to provision infrastructure in different cloud environments
* Provisioners — set up the machine, after they're up and running

---

# State

--

* State can be either local, or backed by one of the supported backends
* Keeps track of what has been provisioned up to now
* Is used to **plan** and **apply** changes to the existing infrastructure

--

# Plan and what?

--

How does Terraform work?

--

1. First of all, it loads the current state, optionally loading dynamic information from the different providers
2. Then, it **plans** what needs to be done, by computing the diff between the current and the declared state
3. Finally, it **applies** the diff and updates the state

---

# Enough said, time for action!

--

[github.com/2hog/workshop-infra](https://github.com/2hog/workshop-infra)

---


# That's all folks!

## Thank you
