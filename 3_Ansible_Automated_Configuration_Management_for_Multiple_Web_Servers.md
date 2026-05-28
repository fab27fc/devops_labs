3. Ansible - Automated Configuration Management for Multiple Web Servers
Problem

Managing configuration across multiple servers manually is error-prone and time-consuming.

Tools / Services Used
Ansible
AWS EC2
Azure VM
YAML
Linux
SSH
GitHub
Terraform
Implementation Steps
Install Ansible on a control node.
Define an inventory file with server IPs.
Write an Ansible playbook to install and configure Nginx.
Use Ansible roles to modularize configurations.
Run the playbook using ansible-playbook site.yml.
Verify the setup by accessing the web server from different nodes.
Project Objective

The goal of this project is to automate the installation and configuration of Nginx across multiple Linux web servers using Ansible.

Terraform is used to provision the infrastructure, while Ansible is responsible for configuring and managing the web servers.

This approach follows Infrastructure as Code (IaC) and Configuration Management best practices.

Architecture

The Ansible Control Node connects to multiple Linux web servers using SSH and applies the same configuration automatically.

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

---

# Prerequisites

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

---
## 2. Define an Inventory File with Server IPs

### 2.1 Create Web Servers with Terraform

Control Node
├── ansible-project/
│   └── site.yml
│
└── terraform/
    ├── inventory/
    │   └── hosts.ini
    ├── inventory.tpl
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    └── versions.tf

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

TERRAFORM FILES:
1- inventory.tpl 
[webservers]
%{ for index, server in webservers ~}
web0${index + 1} ansible_host=${server.private_ip} ansible_user=ubuntu
%{ endfor ~}

[webservers:vars]
ansible_ssh_private_key_file=~/.ssh/keypair_project_1-aws.pem

2- main.tf
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

resource "aws_instance" "web" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-web0${count.index + 1}"
    Role = "webserver"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory/hosts.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    webservers = aws_instance.web
  })
}

3- terraform.tfvars 
key_name  = "keypair_project_1-aws"
vpc_id    = "vpc-0cc9e77c72331c0c7"
subnet_id = "subnet-0e37eae31da360f78"
my_ip     = "107.22.72.201/32"

4- variables.tf
variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "project3-ansible"
}

variable "key_name" {
  description = "AWS Key Pair"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_id" {
  description = "Subnet ID"
}

variable "my_ip" {
  description = "Public IP for SSH access"
}

5- version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


KEY: 
Move the key from the local computer to the EC2:
scp -i keypair_project_1-aws.pem keypair_project_1-aws.pem ubuntu@107.22.72.201:/home/ubuntu/.ssh/
chmod 400 keypair_project_1-aws.pem

Need to install:
sudo apt update
sudo apt install awscli -y

Test:
aws --version
aws sts get-caller-identity

Terraform doesnt have AWS credentials:
EC2 → Instances → selecciona control node
→ Actions → Security
→ Modify IAM role  → AdministratorAccess 


ssh-keyscan -H 10.0.2.142 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.0.2.24 >> ~/.ssh/known_hosts


Terraform was used to create two EC2 instances:

- web01
- web02

### 2.2 Terraform Generates the Ansible Inventory

Terraform automatically creates the file:
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

DEVOPS:
Developer makes a commit
Jenkins runs:
terraform plan -out=tfplan
Team reviews the plan
Manual approval
terraform apply tfplan

When we do a small change
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

chmod 400 ~/.ssh/keypair_project_1-aws.pem

```text
inventory/hosts.ini
```

Example output:

```ini
[webservers]
web01 ansible_host=PRIVATE_IP_WEB01 ansible_user=ubuntu
web02 ansible_host=PRIVATE_IP_WEB02 ansible_user=ubuntu

[webservers:vars]
ansible_ssh_private_key_file=~/AnsibleKeyPair.pem
```

### 2.3 Test Connectivity

```bash
ansible -i inventory/hosts.ini webservers -m ping
```
<img width="1053" height="366" alt="image" src="https://github.com/user-attachments/assets/3f94cac4-39d9-4298-a5f6-dd5477a2680d" />

---


## 3. Write an Ansible Playbook to Install and Configure Nginx

### 3.1 Create the Main Playbook

```bash
nano site.yml
```

---

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


