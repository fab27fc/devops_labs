# 1. AWS - Auto Scaling Web Application with EC2 and ELB (ALB)

## Problem

A web application faces high traffic fluctuations and requires an auto-scaling solution to handle varying loads efficiently.

---

# Tools / Services Used

# Architecture

Internet
    ↓
Application Load Balancer (ALB)
    ↓
Auto Scaling Group
    ↓
EC2 Instances

---

# Implementation Steps

1. Create an AWS VPC and subnets.
2. Configure a security group allowing HTTP and SSH access.
3. Launch an EC2 instance, install a web server, and configure the application.
4. Create an AMI of the EC2 instance for auto-scaling.
5. Configure an Auto Scaling Group with launch templates and policies.
6. Attach an Elastic Load Balancer (ELB) to distribute traffic.
7. Set up CloudWatch alarms and auto-scaling policies.
8. Test by generating load traffic and monitoring auto-scaling.

---

# 1. Create the VPC

## 1.1 Create the VPC

```text
Name: vpc-project-1-aws
CIDR: 10.0.0.0/16
```

---

## 1.2 Create Public Subnets

### Public Subnet 1A

```text
Name: subnet-public-1a
CIDR: 10.0.1.0/24
Availability Zone: us-east-1a
```

### Public Subnet 1B

```text
Name: subnet-public-1b
CIDR: 10.0.2.0/24
Availability Zone: us-east-1b
```

---

## 1.3 Create the Internet Gateway

```text
Name: ig-project-1-aws
```

Attach the Internet Gateway to:

```text
vpc-project-1-aws
```

---

## 1.4 Create the Public Route Table

```text
Name: route-table-project-1-aws
```

Add Route:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
```

Associate Subnets:

```text
subnet-public-1a
subnet-public-1b
```

---

# 2. Create Security Group

## 2.1 Create Security Group

```text
Name: sg-project-1-aws
```

### Inbound Rules

```text
HTTP  TCP 80    0.0.0.0/0
SSH   TCP 22    YOUR-IP
```

### Outbound Rules

```text
All traffic
```

---

# 3. Create EC2 Instance

## 3.1 Launch EC2 Instance

```text
Name: ec2-project-1-aws
AMI: Ubuntu
Instance Type: t3.micro
```

### Key Pair

```text
keypair_project_1-aws.pem
```

### Security Group

```text
sg-project-1-aws
```

### Subnet

```text
subnet-public-1a
```

Enable:

```text
Auto-assign Public IP
```

---

## 3.2 Install Apache Web Server

### Option 1 — Basic Apache Installation

```bash
#!/bin/bash

apt update -y
apt install apache2 -y

systemctl start apache2
systemctl enable apache2
```

---

### Option 2 — Create the Website Automatically

```bash
#!/bin/bash

apt update -y
apt install apache2 -y

echo "<h1>Hola Fabian - Ubuntu Apache</h1>" > /var/www/html/index.html

systemctl start apache2
systemctl enable apache2
systemctl restart apache2
```

---

## 3.3 Move the Key Pair from Windows to Ubuntu

```bash
cd /mnt/c/Users/andyp/Downloads

scp keypair_project_1-aws.pem fabian@192.168.100.151:~/.ssh/

chmod 400 ~/.ssh/keypair_project_1-aws.pem
```

---

## 3.4 Connect to the EC2 Instance

```bash
ssh -i ~/.ssh/keypair_project_1-aws.pem ubuntu@13.219.85.19
```

---

### Troubleshooting Timeout Errors

Verify key permissions:

```bash
chmod 400 keypair_project_1-aws.pem
```

Verify:

- Security Group allows SSH (TCP 22)
- Route Table contains:

```text
0.0.0.0/0 → Internet Gateway
```

- Instance has a Public IPv4 address

Verify correct username:

```text
Ubuntu AMI → ubuntu
Amazon Linux → ec2-user
```

---

## 3.5 Create the Website Manually

```bash
cd /var/www/html

sudo nano index.html
```

Example:

```html
<h1>This is the Main Server</h1>
<h2>Project AWS 1</h2>
```

---

## 3.6 Create a Dynamic Website

```bash
OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')

HOST=$(hostname)

IP=$(hostname -I | awk '{print $1}')

sudo bash -c "cat > /var/www/html/index.html" <<EOF
<h1>This is the Main Server</h1>

<p><b>Hostname:</b> $HOST</p>
<p><b>IP:</b> $IP</p>
<p><b>OS:</b> $OS</p>
EOF
```

Restart Apache:

```bash
sudo systemctl restart apache2
```

---

## 3.7 Test the Website

Open in browser:

```text
http://13.219.85.19
```

Expected Output:

```text
This is the Main Server

Hostname: AWS-PROJECT-1

IP: 10.0.1.25

OS: Ubuntu 24.04 LTS
```

---

# 4. Create an AMI of the EC2 Instance

## 4.1 Create the AMI

Go to:

```text
EC2 → Instances → Actions → Image and templates → Create image
```

Example:

```text
AMI Name: ami-project-1-aws
```

This AMI will be used by the Auto Scaling Group to launch new EC2 instances automatically.

---

# 5. Configure Auto Scaling Group

## 5.1 Create Launch Template

Go to:

```text
EC2 → Launch Templates → Create template from instance
```

Configuration:

```text
Name: template-project-1-aws
AMI: ami-project-1-aws
Instance Type: t3.micro
Security Group: sg-project-1-aws
Key Pair: keypair_project_1-aws

Note:
The subnet selection will be configured later in the Auto Scaling Group.
```

---

## 5.2 Create Auto Scaling Group

Go to:

```text
EC2 → Auto Scaling Groups → Create Auto Scaling Group
```

Configuration:

```text
Name: asg-project-1-aws
Launch Template: template-project-1-aws
```

Select VPC:

```text
vpc-project-1-aws
```

Select Subnets:

```text
subnet-public-1a ->     use1-az2 (us-east-1a) | subnet-084d5b32ce97260af (vpc-project-1-aws-PUBLIC-1A)   10.0.1.0/24
subnet-public-1b ->     use1-az4 (us-east-1b) | subnet-0e37eae31da360f78 (vpc-project-1-aws-PUBLIC-1B)   10.0.2.0/24
Balance best effort


Benefits:
- High availability
- Load balancing across Availability Zones (AZs)
- Automatic scaling

NEXT
Attach to a new load balancer
Load balancer name: lb-project-1-aws-1
Internet-facing
Availability Zones and subnets:
2 Subnets
Listeners and routing: 80
New target: tg-project-1-aws
Enable health checks
Health check grace period -> 300
```

---

## 5.3 Configure Capacity

```text
Desired Capacity: 1
Minimum Capacity: 1
Maximum Capacity: 4

Automatic scaling: Target tracking scaling policy

Metric:
Average CPU utilization

Target value:
70

Instance maintenance policy: No policy
Additional capacity settings: Default
Auto Scaling group deletion protection - new: Default
NEXT -> NEXT -> NEXT -> Create Auto Scaling Group

The Auto Scaling Group launches EC2 instances automatically based on the desired capacity configuration.
Example:
1-  ec2-project-1-aws
2-  ec2-project-1-aws
3-  ec2-project-1-aws

http://lb-project-1-aws-1-1120625375.us-east-1.elb.amazonaws.com

# Troubleshooting
Issue:
Website was not accessible through the Load Balancer.

Checks performed:

1. Verify VPC DNS settings
- Enable DNS hostnames
- Enable DNS resolution

2. Verify Security Group rules
- Allow HTTP TCP 80 from 0.0.0.0/0

3. Verify Route Table
- Confirm route:
0.0.0.0/0 → Internet Gateway
```

---

# 6. Attach Elastic Load Balancer (ELB)

## 6.1 Create Target Group

Go to:

```text
EC2 → Target Groups → Create target group
```

Configuration:

```text
Name: tg-project-1-aws
Protocol: HTTP
Port: 80
Target Type: Instance
Registered targets (2)
FIRST EC2:  i-0f6ca00cbd19a800a  |  ec2-project-1-aws  |  80  |  us-east-1a (use1-az2)
SECOND EC2: i-07f657e05a6cbe381  |  ec2-project-1-aws  |  80  |  us-east-1b (use1-az4)

```

Register EC2 instances.

---

## 6.2 Create Application Load Balancer

Go to:

```text
EC2 → Load Balancers → Create Application Load Balancer
```

Configuration:

```text
Name: lb-project-1-aws
Scheme: Internet-facing
IP Type: IPv4
```

Select Subnets:

```text
subnet-public-1a
subnet-public-1b
```

Select Security Group:

```text
sg-project-1-aws
```

Listener:

```text
HTTP : 80
```

Forward traffic to:

```text
tg-project-1-aws
```

---

## 6.3 Attach ALB to Auto Scaling Group

Go to:

```text
EC2 → Auto Scaling Groups → asg-project-1-aws
```

Attach:

```text
tg-project-1-aws
```

---

# 7. Configure CloudWatch Alarms and Scaling Policies

## 7.1 Create Scale-Out Policy

Go to:

```text
EC2 → Auto Scaling Groups → Automatic Scaling
```

Create policy:

```text
Policy Type: Target Tracking
Metric: Average CPU Utilization
Target Value: 70%
The Auto Scaling Group automatically increases or decreases the number of EC2 instances to maintain the target CPU utilization.
```

Action:

```text
AWS automatically adds instances to maintain the target CPU utilization.
```

---

## 7.2 Create Scale-In Policy

Configuration:

```text
Remove 1 instance when CPU < 30%
```

---

# 8. Test Auto Scaling

## 8.1 Generate Traffic

Install Apache Benchmark:

```bash
sudo apt install apache2-utils -y
```

Run load test:

```bash
ab -n 10000 -c 100 http://LOAD-BALANCER-DNS/
```

Example:

```bash
ab -n 10000 -c 100 http://alb-project-1-aws-123456.us-east-1.elb.amazonaws.com/
```

---

## 8.2 Monitor Auto Scaling

Go to:

```text
EC2 → Auto Scaling Groups → Activity
```

Verify:

- New EC2 instances are launched automatically
- CPU metrics increase in CloudWatch
- Load Balancer distributes traffic correctly
- Instances terminate automatically when traffic decreases

- Installing stress:
sudo apt update
sudo apt install stress -y

Running the process:
stress --cpu 4 --timeout 600
stress-ng --cpu 4 --timeout 10m --metrics-brief

Run a load test against the Load Balancer:
ab -n 5000 -c 50 http://lb-project-1-aws-1-1120625375.us-east-1.elb.amazonaws.com/

This command generates HTTP traffic against the Load Balancer to increase CPU utilization and trigger Auto Scaling events.
