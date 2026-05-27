# 3. Ansible - Automated Configuration Management for Multiple Web Servers

## Problem

Managing configuration across multiple servers manually is error-prone and time-consuming.

---

# Tools / Services Used

- Ansible
- AWS EC2
- Azure VM
- YAML
- Linux
- SSH

---

# Implementation Steps

1. Install Ansible on a control node.
2. Define an inventory file with server IPs.
3. Write an Ansible playbook to install and configure Nginx.
4. Use Ansible roles to modularize configurations.
5. Run the playbook using ansible-playbook site.yml.
6. Verify the setup by accessing the web server from different nodes.

---

# 1. Create the Infrastructure

## 1.1 Create the Control Node

```text
Name: project_n3_ansible-control-node
OS: Ubuntu 24.04
Instance Type: t3.micro

Purpose:
This server will manage all other servers using Ansible.

