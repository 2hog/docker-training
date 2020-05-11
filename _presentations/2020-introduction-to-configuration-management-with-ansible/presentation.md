layout: true
class: middle
---


# Introduction to Configuration Management with Ansible

--

[p.2hog.codes/2020-introduction-to-configuration-management-with-ansible](https://p.2hog.codes/2020-introduction-to-configuration-management-with-ansible)

[dojo.2hog.codes](https://dojo.2hog.codes)

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
* Senior Software Engineer at e-food

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

# [p.2hog.codes/2020-introduction-to-configuration-management-with-ansible](https://p.2hog.codes/2020-introduction-to-configuration-management-with-ansible)

---

# Agenda

1. System Configuration
2. Configuration Management for Systems
3. Introduction to Ansible
4. Ansible Concepts
5. Ansible Architecture

---

# Introduction to Configuration Management with Ansible

---

# System Configuration

---

# What is system configuration?

---

# What is system configuration?

System configuration is the process of tailoring our systems (computers) to run our workloads (applications).

---

# Do you like cooking?

---

# What is system configuration?

Configuring our system is like cleaning up our kitchen and putting all tools in the right place to cook.

---

# Can you configure tens of instances at the same time by hand?

---

# Can you configure tens of instances at the same time by hand?

No, you can't. You are not Dr. Manhattan.

---

# Should you configure instances by hand?

---

# Should you configure instances by hand?

**No**, you shouldn't!

---

# Should you configure instances by hand?

**No**, you shouldn't!

Even if you are Dr. Manhattan.

---

# Should you configure instances by hand?

**No**, you shouldn't!

Even if you are Dr. Manhattan.

At least not in production.

---

# Should you configure instances by hand?

**No**, you shouldn't!

Even if you are Dr. Manhattan.

At least not in production.

Please.

---

# Enter Configuration Management for Systems

---

# Configuration Management for Systems

Configuration management for systems allow system administrators to manage **multiple systems**, **securely** and **confidently**.

---

# Configuration Management vs Source Control Management

Configuration Management is for configuration what Source Control Management is for source code.

---

# Configuration Management

Configuration Management provides a uniform way for system administrators to:

1. Track and control changes in system configuration.
2. Establish system configuration baselines.
3. Apply configuration to multiple systems concurrently.

---

# Well-known System Configuration Management Software

1. Ansible
2. Capistrano
3. Puppet
4. Chef

---

# Recap: System Configuration Management

1. It should by used by system administrators.
2. It helps avoid mistakes or roll them back.
3. It saves time when configuring multiple systems.

---

# Introduction to Ansible

---

# What is Ansible?

---

# What is Ansible? (in their own words)

> Ansible is a radically simple IT automation engine that automates cloud provisioning, configuration management, application deployment, intra-service orchestration, and many other IT needs.

---

# What is Ansible? (in my own oversimplified words)

Ansible is a sophisticated programmable SSH client that keeps track of history.

_(Actually, it's way much more, but this is what we will focus on here.)_

---

# Case studies for system configuration management with Ansible

---

# Case studies for system configuration management with Ansible
- Upgrade system packages (`apt`, `yum` etc.)
- Upgrade distribution version
- Upgrade Kernel

---

# Concepts of Ansible

---

# Concepts of Ansible
- Nodes
- Inventory
- Modules
- Tasks
- Playbooks

---

# Nodes

---

# Nodes

Nodes are machines — computers. Ansible works with two types of nodes:

- **Control Nodes**: Machines with Ansible installed. (_cannot be running Windows_)
- **Managed Nodes**: The machines you manage from Control Nodes. (_do not need Ansible installed_)

---

# Examples of Control Nodes

- Local computers (laptop, dekstop etc.)
- GitLab Runners
- Dojo (Docker Workspace)

---

# Examples of Managed Nodes

- Testing servers
- QA servers
- Production Servers
- ...and so on

---

class: center

## Node topology

![Node topology](/presentations/2020-introduction-to-configuration-management-with-ansible/images/node-topology.jpg)

---

# Inventory

---

# Inventory

An inventory — also called a _hostfile_ — is a **list of Managed Nodes**.

Inventories contain nodes either in flat structure or in groups, supporting nesting as well.

Inventories can withe be static, written in `INI` or `YAML` syntax, or dynamic.

---

# Example Static Inventory (INI)

```ini
ada.example.com
alan.example.com
grace.example.com
```

---

# Example Static Inventory (YAML)

```yaml
all:
  hosts:
    ada.example.com:
    alan.example.com:
    grace.example.com:
```

---

# Example Static Inventory with Groups (INI)

```ini
ada.example.com

[webservers]
alan.example.com
grace.example.com
```

---

# Example Static Inventory with Groups (YAML)

```yaml
all:
  hosts:
    ada.example.com:
  children:
    webservers:
      hosts:
        alan.example.com:
        grace.example.com:
```

---

# Your First Inventory

---

# Your First Inventory (`inventory.yml`)

```yaml
all:
  hosts:
    managed-node-01:
```

---

# Your First Command

```console
ansible -i inventory.yml all -m shell -a 'echo "Hello from $(hostname)!"'
```

---

# Your First Command

```console
$ ansible -i inventory.yml all -m shell -a 'echo "Hello from $(hostname)!"'
managed-node-01 | CHANGED | rc=0 >>
Hello from ubuntu-s-1vcpu-1gb-fra1-01!
```

---

# That was just a first taste

You will rarely run ad-hoc commands like this.

Let's move on for now.

---

# Modules

---

# Modules

Modules are the units of code Ansible executes on Managed Nodes.

---

# Example Modules

- `shell`: Executes shell commands on Managed Nodes.
- `apt`: Manages `apt` packages on Ubuntu or Debian-like Managed Nodes.
- `copy`: Copies files from Control Nodes to Managed Nodes.

---

# Do you remember your first command?

---

# Your First Command

```console
ansible -i inventory.yml all -m shell -a 'echo "Hello from $(hostname)!"'
```

---

# Your First Command

```console
ansible [...] -m shell [...]
```

---

# Your First Command

```console
ansible [...] -m shell -a 'echo "Hello from $(hostname)!"'
```

---

# Your First Command

We instructed Ansible to

- **Run** the `shell` module via the `-m` flag
- **Pass** `'echo "Hello from $(hostname)!"'` as module argument via the `-a` flag

---

# Tasks

---

# Tasks

Tasks are the units of action in Ansible. You can execute a single task once with an ad-hoc command.

---

# Playbooks

---

# Playbooks

Playbooks are YAML files with ordered lists of tasks, so you can run them in that order repeatedly.

---

# Your First Playbook

---

# Your First Playbook (`playbooks.yml`)

```yaml
- name: My first Playbook
  hosts: all
  tasks:
    - name: Echo "Success" in a file
      shell:
        echo "Success!" >> /root/alright.txt
```

---

# Execute your first Playbook

```console
ansible-playbook -i inventory.yml playbooks.yml
```

---

# Execute your first Playbook

```console
$ ansible-playbook -i inventory.yml playbooks.yml

PLAY [My first Playbook] **********************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************
ok: [managed-node-01]

TASK [Echo "Success" in a file] ***************************************************************************************************
changed: [managed-node-01]

PLAY RECAP ************************************************************************************************************************
managed-node-01            : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

---

class: center

# Architecture of Ansible

---

# Architecture of Ansible

![Architecture of Ansible](/presentations/2020-introduction-to-configuration-management-with-ansible/images/architecture-of-ansible.jpg)

---

# Try me. Ask your weirdest questions!

---

class: center

# Thanks!
