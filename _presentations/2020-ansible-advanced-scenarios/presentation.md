layout: true
class: middle
---


# Ansible Advanced Scenarios

--

[p.2hog.codes/2020-ansible-advanced-scenarios](https://p.2hog.codes/2020-ansible-advanced-scenarios)

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

# [p.2hog.codes/2020-ansible-advanced-scenarios](https://p.2hog.codes/2020-ansible-advanced-scenarios)

---

# Agenda

1. Inventories Deep Dive
2. Playbooks Deep Dive
3. Custom Roles
4. Advanced Scenarios

---

# Ansible Advanced Scenarios

---

# Inventories Deep Dive

---

# Host Ranges

Ansible can handle ranges of hosts based on name patterns, in additional to single hosts.

---

# `inventory.yml`

```yaml
mine:
  hosts:
    managed-node-01:
    managed-node-02:
attendees:
  hosts:
    workshop-vm-[00:17]-[1:2].akalipetis.com:
```

---

# (More) Host Ranges

---

# `inventory.yml`

```yaml
mine:
  hosts:
    managed-node-01:
    managed-node-02:
first_ten_attendees:
  hosts:
    workshop-vm-[00:09]-[1:2].akalipetis.com:
last_attendees:
  hosts:
    workshop-vm-[10:17]-[1:2].akalipetis.com:
```

---

# Inventory Variables

---

# Inventory Variables

You can store variable values that relate to a specific host or group in inventory.

---

# `inventory.yml` -- Host Variables

```yaml
mine:
  hosts:
    managed-node-01:
    managed-node-02:
first_ten_attendees:
  hosts:
    workshop-vm-[00:09]-[1:2].akalipetis.com:
last_attendees:
  hosts:
    workshop-vm-[10:17]-[1:2].akalipetis.com:
```

---

# `inventory.yml` -- Group Variables

```yaml
mine:
  hosts:
    managed-node-01:
      redis_version: 5.0.9
    managed-node-02:
first_ten_attendees:
  hosts:
    workshop-vm-[00:09]-[1:2].akalipetis.com:
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
last_attendees:
  hosts:
    workshop-vm-[10:17]-[1:2].akalipetis.com:
```

---

# Let's get organised

We can split up host and group variables in new files.

This is recommended, so we can keep inventory files maintainable.

---

# `host_vars/managed-node-01.yml`

```yaml
redis_version: 5.0.9
```

---

# `group_vars/first_ten_attendees.yml`

```yaml
ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

---

# `inventory.yml`

```yaml
mine:
  hosts:
    managed-node-01:
    managed-node-02:
first_ten_attendees:
  hosts:
    workshop-vm-[00:09]-[1:2].akalipetis.com:
last_attendees:
  hosts:
    workshop-vm-[10:17]-[1:2].akalipetis.com:
```

---

# Ansible behavioral inventory parameters

Ansible provides us with variables that control how Ansible interacts with remote hosts.

https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#connecting-to-hosts-behavioral-inventory-parameters

---

# Playbooks Deep Dive

---

# First Playbook

```yaml
- name: My First Playbook
  hosts: all
  tasks:
    - name: Echo "Success" in a file
      shell:
        echo "Success!" >> /root/alright.txt
```

---

# Using Variables

---

# Using Variables

```yaml
- name: Redis Version
  hosts: managed-node-01
  tasks:
    - name: Echo desired Redis version in file
      shell:
        echo "{{redis_version}}" >> /root/redis_version.txt
```

---

# First Playbook

Our first Ansible Playbook is a super simple example with a single play (?).

---

# Plays?

Plays are more or less a sports analogy.

A Playbook can have multiple plays. You can run different plays at different times.

---

# A Playbook with Multiple Plays

---

# A Playbook with Multiple Plays

```yaml
---
- name: Hello
  hosts: first_ten_attendees
  tasks:
    - name: Echo hello
      shell:
        echo "Hello from $(whoami) at $(hostname)!"  > /root/hello.txt

- name: Hi
  hosts: last_attendees
  tasks:
    - name: Echo hi
      shell:
        echo "Hi from $(whoami) at $(hostname)!"  > /root/hi.txt
```

---

# Handlers

---

# Handlers

Handlers are lists of tasks, referenced by a globally unique name.

Handlers run only when notified by notifiers.

Regardless of how many tasks notify a handler, it will run only once, after all of the tasks complete in a particular play.

---

# Your First Handler

---

# Your First Handler

```yaml
handlers:
  - name: restart lxd
    service:
      name: lxd-containers
      state: restart
```

---

# Invoking Your First Handler

---

# `playbook-with-handlers.txt`

```yaml
---
- name: Hello
  hosts: first_ten_attendees
  tasks:
    - name: Echo hello
      shell:
        echo "Hello from $(whoami) at $(hostname)!"  > /root/hello.txt
    - name: Echo hi
      shell:
        echo "Hi from $(whoami) at $(hostname)!"  > /root/hi.txt
      notify:
        - restart lxd
  handlers:
    - name: restart lxd
      service:
        name: lxd-containers
        state: restart
```

---

# Custom Roles

---

# Custom Roles

We can create our custom Roles as well.

https://galaxy.ansible.com/docs/contributing/creating_role.html

---

# Your First Role

---

# Your First Role

We will create a super important and serious Ansible Role.

---

# Your First Role

This Ansible Role, should just run... `docker info`.

```console
ansible-galaxy init docker-info
```

---

# Let's write our task

---

# `docker-info/tasks/main.yml`

```yaml
---
- name: Run `docker info`
  shell:
    docker info
```
---

# Advanced Scenarios

---

# Install Docker

---

# Install Docker

Let's create a Playbook based on https://docs.docker.com/engine/install/ubuntu/.

---

# Enable Docker experimental

---

# `daemon.json`

```json
{
  "experimental": true
}
```

---

# `advanced-playbook.yml`

```yaml
- name: Copy daemon.json
  copy:
    src: /root/ansible-class/daemon.json
    dest: /etc/docker/daemon.json
```

---

# Set up daily `docker system prune`

---

# `advanced-playbook.yml`

```yaml
- name: Run `docker system prune` daily
  cron:
    name: "Clean up Docker resources"
    special_time: daily
    job: "docker system prune"
```

(☝️ Should we try an entry for the next minute?)

---

# Allow incoming traffic to `22`, `80`, `443`

---

# Enable UFW in `advanced-playbook.yml`

```yaml
- name: Enable UFW
  ufw:
    state: enabled
```

---

# Deny all traffic in `advanced-playbook.yml`

```yaml
- name: Deny all traffic
  ufw:
    rule: deny
    direction: in
```

---

# Allow SSH traffic in `advanced-playbook.yml`

```yaml
- name: Allow incoming traffic to TCP port 22
  ufw:
    rule: allow
    port: "22"
    proto: tcp
```

---

# Allow HTTP/S traffic in `advanced-playbook.yml`

```yaml
- name: Allow incoming traffic to TCP port 80
  ufw:
    rule: allow
    port: "80"
    proto: tcp
- name: Allow incoming traffic to TCP port 443
  ufw:
    rule: allow
    port: "443"
    proto: tcp
```

---

# Let's keep playing...

---

# This was a quite complete Ansible Playbook example

---

# One more thing...

---

# Let's do something edgy

---

# Kernel Upgrade on 36 nodes with 1 command

---

# Try me. Ask your weirdest questions!

---

class: center

# Thanks!
