# 3. Ansible - Automated Configuration Management for Multiple Web Servers

## Problem

Managing configuration across multiple servers manually is error-prone and time-consuming.

---

## Tools / Services Used

- Ansible
- AWS EC2
- Azure VM
- YAML
- Linux
- SSH
- GitHub
- Terraform

---

## Implementation Steps

1. Install Ansible on a control node.
2. Define an inventory file with server IPs.
3. Write an Ansible playbook to install and configure Nginx.
4. Use Ansible roles to modularize configurations.
5. Run the playbook using ansible-playbook site.yml.
6. Verify the setup by accessing the web server from different nodes.

---

## Project Objective

The goal of this project is to automate the installation and configuration of Nginx across multiple Linux web servers using Ansible.

Terraform is used to provision the infrastructure, while Ansible is responsible for configuring and managing the web servers.

This approach follows Infrastructure as Code (IaC) and Configuration Management best practices.

---

## Architecture

The Ansible Control Node connects to multiple Linux web servers using SSH and applies the same configuration automatically.

```text
                +----------------------+
                |  Ansible Control Node |
                +----------------------+
                           |
                           | SSH
          -------------------------------
          |                             |
          |                             |
+----------------+           +----------------+
|   Web Server 1 |           |   Web Server 2 |
|      Nginx     |           |      Nginx     |
+----------------+           +----------------+
```

---

## Prerequisites

Before starting the project, make sure you have:

- AWS EC2 instances or Azure VMs running Linux
- SSH access to all servers
- A PEM private key file
- Internet connectivity
- Security Groups allowing:
  - SSH (Port 22)
  - HTTP (Port 80)


  # Implementation Steps

## 1. Install Ansible on a Control Node

### 1.1 Create the Infrastructure

Create:

- 1 Control Node
- 2 Web Servers

Example:

| Server | Purpose |
|---|---|
| ansible-control-node | Runs Ansible |
| web01 | Nginx Web Server |
| web02 | Nginx Web Server |

---

### 1.2 Connect to the Control Node

```bash
ssh -i AnsibleKeyPair.pem ubuntu@CONTROL_NODE_IP
```

---

### 1.3 Update the Server

```bash
sudo apt update -y
```

---

### 1.4 Install Ansible

```bash
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

---

### 1.5 Verify the Installation

```bash
ansible --version
```

## 2. Define an Inventory File with Server IPs

### 2.1 Create Web Servers with Terraform

Terraform was used to provision the AWS infrastructure and automatically generate the Ansible inventory file. This approach eliminates manual server creation and reduces the need to manually update inventory files whenever server IP addresses change.

#### 2.1.1 Project Structure

The following directory structure was used on the Ansible Control Node:

```text
terraform/
├── inventory/
│   └── hosts.ini
├── inventory.tpl
├── main.tf
├── variables.tf
├── terraform.tfvars
└── versions.tf
```

#### 2.1.2 Terraform Workflow

```text
Terraform
   ↓
Creates EC2 Web Servers
   ↓
Generates Ansible Inventory
   ↓
Ansible Control Node
   ↓
Runs Playbook
   ↓
Installs and Configures Nginx
```

#### 2.1.3 inventory.tpl

This file is used as a template to automatically generate the Ansible inventory file based on the EC2 instances created by Terraform.

Example:

```ini
[webservers]
web01 ansible_host=10.0.2.142 ansible_user=ubuntu
web02 ansible_host=10.0.2.24 ansible_user=ubuntu
```

Purpose:

* Automatically builds the inventory file.
* Uses EC2 private IP addresses.
* Eliminates manual inventory updates.

---

#### 2.1.4 main.tf

The main Terraform configuration file responsible for creating AWS resources.

Resources managed:

* EC2 instances
* Security Groups
* Dynamic inventory generation

Example:

```hcl
resource "aws_instance" "web" {
  count         = 2
  instance_type = "t3.micro"
}
```

Purpose:

* Creates infrastructure resources.
* Defines server configuration.
* Associates Security Groups and Key Pairs.

---

#### 2.1.5 terraform.tfvars

Stores deployment-specific values that can change between environments.

Example:

```hcl
key_name  = "keypair_project_1-aws"
aws_region = "us-east-1"
```

Purpose:

* Separates configuration from code.
* Simplifies deployments.
* Improves reusability.

---

#### 2.1.6 variables.tf

Defines reusable Terraform variables used throughout the project.

Example:

```hcl
variable "aws_region" {
  default = "us-east-1"
}
```

Purpose:

* Reduces hardcoded values.
* Makes the project more flexible.
* Simplifies maintenance.

---

#### 2.1.7 versions.tf

Defines Terraform provider requirements and version compatibility.

Example:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

Purpose:

* Ensures provider compatibility.
* Maintains consistent deployments.
* Prevents version conflicts.

---

### 2.2 Configure AWS CLI and SSH Access

#### 2.2.1 Copy the SSH Key

Copy the private key from the local machine to the Ansible Control Node.

```bash
scp -i keypair_project_1-aws.pem keypair_project_1-aws.pem ubuntu@CONTROL_NODE_IP:/home/ubuntu/.ssh/
```

Set the appropriate permissions:

```bash
chmod 400 ~/.ssh/keypair_project_1-aws.pem
```

#### 2.2.2 Install AWS CLI

Install the AWS CLI on the Control Node.

```bash
sudo apt update
sudo apt install awscli -y
```

Verify the installation:

```bash
aws --version
```

#### 2.2.3 Verify AWS Credentials

Confirm that Terraform can access the AWS account.

```bash
aws sts get-caller-identity
```

If credentials are not available, attach an IAM Role to the Control Node.

```text
EC2
→ Instances
→ Select Control Node
→ Actions
→ Security
→ Modify IAM Role
→ AdministratorAccess
```

#### 2.2.4 Add Known Hosts

Add the target servers to the SSH known hosts file.

```bash
ssh-keyscan -H 10.0.2.142 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.0.2.24 >> ~/.ssh/known_hosts
```

---

### 2.3 Deploy Terraform Infrastructure

Initialize Terraform:

```bash
terraform init
```

Format Terraform files:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Review the execution plan:

```bash
terraform plan
```

Deploy the infrastructure:

```bash
terraform apply
```

Terraform creates the following servers:

* web01
* web02

---

### 2.4 Terraform Generates the Ansible Inventory

Terraform automatically creates the inventory file:

```text
inventory/hosts.ini
```

Example output:

```ini
[webservers]
web01 ansible_host=PRIVATE_IP_WEB01 ansible_user=ubuntu
web02 ansible_host=PRIVATE_IP_WEB02 ansible_user=ubuntu
```

---

### 2.5 Test Connectivity

Verify connectivity between the Control Node and the managed servers.

```bash
ansible -i inventory/hosts.ini webservers -m ping
```

Expected result:

```text
web01 | SUCCESS
web02 | SUCCESS
```

This confirms that Ansible can communicate successfully with all managed hosts.

<img width="1076" height="381" alt="image" src="https://github.com/user-attachments/assets/d5eda30a-d0d1-4818-8ec2-9f2fcae5bcd0" />


---


## 3. Write an Ansible Playbook to Install and Configure Nginx

### 3.1 Create the Main Playbook

Create the main Ansible playbook:

```bash
nano site.yml
```

Add the following configuration:

```yaml
---
- name: Configure Web Servers
  hosts: webservers
  become: true

  tasks:
    - name: Update package cache
      apt:
        update_cache: yes

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

### 3.2 Configure the Playbook

```yaml
---
- name: Configure multiple web servers
  hosts: webservers
  become: yes

  roles:
    - nginx
```

---

## 4. Use Ansible Roles to Modularize Configurations

### 4.1 Create the Nginx Role

```bash
nano roles/nginx/tasks/main.yml
```

---

### 4.2 Configure Nginx Tasks

```yaml
---
- name: Install Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Start and enable Nginx
  service:
    name: nginx
    state: started
    enabled: yes

- name: Create custom index page
  copy:
    content: |
      <h1>Nginx configured by Ansible</h1>
      <p>Automation successful.</p>
    dest: /var/www/html/index.html
  notify: Restart Nginx
```

---

### 4.3 Create the Handler

```bash
nano roles/nginx/handlers/main.yml
```

---

### 4.4 Configure the Handler

```yaml
---
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

---

## 5. Run the Playbook Using ansible-playbook site.yml

### 5.1 Execute the Playbook

```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

---

### 5.2 Expected Result

- Nginx installed successfully
- Nginx service started
- Web page deployed automatically

---

## 6. Verify the Setup by Accessing the Web Server from Different Nodes

### 6.1 Open the Web Servers in a Browser

```text
http://WEB_SERVER_1_PUBLIC_IP
http://WEB_SERVER_2_PUBLIC_IP
```

---

### 6.2 Verify the Output

Expected output:

```text
Nginx configured by Ansible
Automation successful.
```

---

# Git Commands

## Initialize Git Repository

```bash
git init
```

---

## Add Project Files

```bash
git add .
```

---

## Commit Changes

```bash
git commit -m "Add Ansible automation project"
```

---

## Push to GitHub

```bash
git push -u origin main
```

---

# Screenshots

Add screenshots for:

1. EC2 / VM instances
2. Successful Ansible ping
3. Playbook execution
4. Nginx running in browser
5. GitHub repository

---

# Conclusion

This project demonstrates how Ansible automates configuration management across multiple Linux web servers. Using inventory files, playbooks, and roles improves scalability, consistency, and reduces manual configuration errors.


