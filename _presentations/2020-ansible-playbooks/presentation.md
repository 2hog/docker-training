layout: true
class: middle
---


# Ansible Playbooks

--

[p.2hog.codes/2020-ansible-playbooks](https://p.2hog.codes/2020-2020-ansible-playbooks)

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

# [p.2hog.codes/2020-ansible-playbooks](https://p.2hog.codes/2020-ansible-playbooks)

---

# Agenda

1. Introduction to Ansible Playbooks
2. Example Playbooks
3. Roles
4. Playbooks with Roles

---

# Introduction to Ansible Playbooks

---

# What is a playbook, in general?

---

# What is a playbook?

- A notebook containing diagrammed American football plays
- A stock of usual tactics or methods

https://www.merriam-webster.com/dictionary/playbook

---

# A Playbook

![A Playbook](/presentations/2020-ansible-playbooks/images/ansible-playbook.jpg)

---

# What are Ansible Playbooks?

Playbooks are YAML files with ordered lists of tasks, so you can run them in that order repeatedly.

---

# Your First Playbook

---

# Your First Playbook (`playbook.yml`)

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

# Let's see some examples

---

# Let's install Python 3 on our remote system

---

# `pb-python3.yml`

```yml
- name: Install Python 3
  hosts: all
  tasks:
    - name: Run apt-get update and install Python 3
      apt:
        name: python3
        update_cache: yes
```

---

# Install Python 3

```console
ansible-playbook -i inventory.yml pb-python3.yml
```

---

# Let's install pip as well

---

# `pb-python3.yml`

```yml
- name: Install Python 3 and pip
  hosts: all
  tasks:
    - name: Run apt-get update and install Python 3
      apt:
        name: python3
        update_cache: yes
    - name: Install pip
      apt:
        name: python3-pip
```

---

# Install Python 3 and pip

```console
ansible-playbook -i inventory.yml pb-python3.yml
```

---

# Let's create symbolic links

We would want to use `python` and `pip`, instead of `python3` and `pip3` respectively.

- `/usr/bin/python` → `/usr/bin/python3`
- `/usr/bin/pip` → `/usr/bin/pip3`

---

# `pb-python3.yml`

```yml
- name: Install Python 3 and pip
  hosts: all
  tasks:
    - name: Run apt-get update and install Python 3
      apt:
        name: python3
        update_cache: yes
    - name: Install pip
      apt:
        name: python3-pip
    - name: Create symlink for python executable
      file:
        src: /usr/bin/python3
        dest: /usr/bin/python
        state: link
    - name: Create symlink for pip executable
      file:
        src: /usr/bin/pip3
        dest: /usr/bin/pip
        state: link
```

---

# Install Python 3 and pip and create symbolic links

```console
ansible-playbook -i inventory.yml pb-python3.yml
```

---

# Install Python 3 and pip and create symbolic links

```console
$ ansible-playbook -i inventory.yml pb-python3.yml

# ... truncated output

managed-node-01            : ok=5    changed=2  # ...truncated output
```

---

# Let's run this again

```console
ansible-playbook -i inventory.yml pb-python3.yml
```

---

# Let's run this again

```console
$ ansible-playbook -i inventory.yml pb-python3.yml

# ... truncated output

managed-node-01            : ok=5    changed=0  # ...truncated output
```

---

# Roles

---

# Roles

Roles are ways of automatically loading certain vars_files (?), tasks, and handlers (?) based on a known file structure.

Grouping content by roles also allows easy sharing (?) of roles with other users.

---

# Too many unknown words.

---

# Roles (in my own words)

Roles are re-usable automation packages for Ansible.

---

# Let's use our first Role

---

# Let's use our first Role

```console
ansible-galaxy install nginxinc.nginx
```

---

# Wow! Hold up.

---

# Wow! Hold up.

What is `ansible-galaxy`?

---

# Ansible Galaxy

---

# Ansible Galaxy

Ansible Galaxy is a free website for finding, downloading, and sharing community developed Ansible Roles.

https://galaxy.ansible.com

---

# `ansible-galaxy`

---

# `ansible-galaxy`

`ansible-galaxy` is a command-line program (CLI) to manage Ansible Roles in shared repositories.

The default repository for `ansible-galaxy` is the Ansible Galaxy website: https://galaxy.ansible.com.

---

# `ansible-galaxy --help`

```console
usage: ansible-galaxy [-h] [--version] [-v] TYPE ...

Perform various Role and Collection related operations.

positional arguments:
  TYPE
    collection   Manage an Ansible Galaxy collection.
    role         Manage an Ansible Galaxy role.
```

---

# `ansible-galaxy role --help`

```console
usage: ansible-galaxy role [-h] ROLE_ACTION ...

positional arguments:
  ROLE_ACTION
    init       Initialize new role with the base structure of a role.
    remove     Delete roles from roles_path.
    delete     Removes the role from Galaxy. It does not remove or alter the actual GitHub repository.
    list       Show the name and version of each role installed in the roles_path.
    search     Search the Galaxy database by tags, platforms, author and multiple keywords.
    import     Import a role
    setup      Manage the integration between Galaxy and the given source.
    login      Login to api.github.com server in order to use ansible-galaxy role sub command such as 'import', 'delete',
               'publish', and 'setup'
    info       View more details about a specific role.
    install    Install role(s) from file(s), URL(s) or Ansible Galaxy
```

---

# `ansible-galaxy role install --help`

```console
usage: ansible-galaxy role install [-h] [-s API_SERVER] [--api-key API_KEY] [-c] [-v] [-f] [-p ROLES_PATH] [-i]
                                   [-n | --force-with-deps] [-r ROLE_FILE] [-g]
                                   [role_name [role_name ...]]

positional arguments:
  role_name             Role name, URL or tar file
```

This can also be used a `ansible-galaxy install`

---

# Ansible Playbooks with Roles

---

# Now, let's do use our first Role

```console
ansible-galaxy install nginxinc.nginx
```

---

# `nginx.yml`

```yaml
- name: Install NGINX
  hosts: all
  roles:
    - nginxinc.nginx
```

---

# Install NGINX

```console
ansible-playbook -i inventory.yml nginx.yml
```

---

# How do I learn more about the `nginxinc.nginx` Ansible Role?

---

# How do I learn more about the `nginxinc.nginx` Ansible Role?

https://galaxy.ansible.com/nginxinc/nginx

---

# What if I want to tailored behavior?

---

# Enter variables

---

# Ansible Variables

Ansible lets us use variables to tailor Inventories, Roles and Playbooks according to our needs.

We will focus on Playbook variables.

---

# Variable names

Variable names should be letters, numbers, and underscores. Variables should always start with a letter.

- **👍 Fine:** `foo_port`, `foo5`
- **👎 Not Fine:** `foo-port`, `foo port`, `foo.port`, `12`

---

# `redis.yml`

```yaml
- hosts: all
  roles:
    - davidwittman.redis
  vars:
    redis_version: 5.0.9
```

---

# Install Redis 5.0.9

```console
ansible-playbook -i inventory.yml redis.yml
```

---

# Now let's combine everything in one Playbook

---

# `main.yml`

```yaml
- name: Setup system with Python, NGINX and Redis
  hosts: all
  tasks:
    - name: Run apt-get update and install Python 3
      apt:
        name: python3
        update_cache: yes
    - name: Install pip
      apt:
        name: python3-pip
    - name: Create symlink for python executable
      file:
        src: /usr/bin/python3
        dest: /usr/bin/python
        state: link
    - name: Create symlink for pip executable
      file:
        src: /usr/bin/pip3
        dest: /usr/bin/pip
        state: link
  roles:
    - nginxinc.nginx
    - davidwittman.redis
  vars:
    redis_version: 5.0.9
```

---

# Try me. Ask your weirdest questions!

---

class: center

# Thanks!
