5. Jenkins - CI/CD Pipeline for Microservices
Problem: Developers need automated builds, testing, and deployments for a microservices architecture. Tools/Services Used: Jenkins, GitHub, Docker, Kubernetes, Helm, SonarQube. Implementation 
Steps:

1. Install Jenkins and configure necessary plugins.
2. Set up a GitHub webhook for automatic builds.
3. Define a Jenkins pipeline with stages (Build, Test, Dockerize, Deploy).
4. Run unit tests using JUnit and static analysis using SonarQube.
5. Build and push a Docker image to Docker Hub.
6. Deploy the container to Kubernetes using Helm charts.
7. Verify the deployment and rollback on failure.



# Jenkins - CI/CD Pipeline for Microservices

## Project Overview

This project demonstrates the implementation of a complete CI/CD pipeline for a containerized microservice application using Jenkins, GitHub, Docker, Kubernetes, Helm, and SonarQube.

The goal is to automate the software delivery lifecycle, including source code integration, testing, static code analysis, container image creation, deployment to Kubernetes, and rollback capabilities.

---

## Technologies Used

* AWS EC2
* Ubuntu Server 24.04
* Jenkins
* GitHub
* Docker
* Docker Hub
* Kubernetes (k3s)
* Helm
* SonarQube
* Java 21

---

## Architecture

```text
Developer
    │
    ▼
GitHub
    │
    ▼
Webhook
    │
    ▼
Jenkins
    │
    ├── Build
    ├── Test
    ├── SonarQube Scan
    ├── Docker Build
    ├── Docker Push
    └── Deploy
             │
             ▼
        Kubernetes
             │
             ▼
          Helm
```

---

# 1. Install Jenkins and Configure Necessary Plugins

### Environment Information

| Component        | Value               |
| ---------------- | ------------------- |
| Cloud Provider   | AWS                 |
| Operating System | Ubuntu Server 24.04 |
| Instance Type    | t3.medium           |
| CI/CD Platform   | Jenkins             |

### Security Group Configuration

| Port | Protocol | Purpose             |
| ---- | -------- | ------------------- |
| 22   | TCP      | SSH Access          |
| 8080 | TCP      | Jenkins Web UI      |
| 9000 | TCP      | SonarQube Dashboard |
| 6443 | TCP      | Kubernetes API      |
| 3000 | TCP      | Application Testing |

### EC2 Creation

EC2 instance was provisioned using Terraform.
main.tf  outputs.tf  providers.tf  scripts  terraform.tfstate  terraform.tfvars  variables.tf  version.tf
Files:
main.tf:
<img width="597" height="1237" alt="image" src="https://github.com/user-attachments/assets/4d5fb217-19f6-44da-8f8e-94d5dec3000d" />

outputs.tf:
<img width="376" height="187" alt="image" src="https://github.com/user-attachments/assets/ffbb2c62-abb6-4aee-847c-bc5ac6c8f998" />

providers.tf:
<img width="380" height="81" alt="image" src="https://github.com/user-attachments/assets/5ca6913b-3395-46e5-a8d4-ac5f64025cb9" />

scripts:  
<img width="462" height="238" alt="image" src="https://github.com/user-attachments/assets/a684b476-c5ec-4289-ab87-80ebdb6a1bf3" />


terraform.tfvars:
<img width="417" height="127" alt="image" src="https://github.com/user-attachments/assets/06e78fc4-1907-4dea-a96a-4562047bbeff" />

variables.tf:
<img width="420" height="338" alt="image" src="https://github.com/user-attachments/assets/2db51cc5-3f3e-4efe-86a8-9b9647af3a18" />


version.tf:
<img width="390" height="212" alt="image" src="https://github.com/user-attachments/assets/ad1f4e78-13aa-4c70-8b24-db361ca5453f" />


### Install Jenkins

(Todo lo que ya documentaste)

### Installed Jenkins Plugins

| Plugin             | Purpose                        |
| ------------------ | ------------------------------ |
| Git                | Source code integration        |
| Docker             | Build and manage Docker images |
| Pipeline           | Pipeline as Code               |
| GitHub Integration | GitHub webhook integration     |
| SonarQube Scanner  | Static code analysis           |
| Kubernetes         | Kubernetes deployments         |
| Blue Ocean         | Modern Jenkins UI              |

---

# 2. Set Up a GitHub Webhook for Automatic Builds

### GitHub Repository Configuration

mkdir -p 05_Jenkins_CICD_Microservices/{app,jenkins,kubernetes,helm,docs,screenshots,scripts}
cd 05_Jenkins_CICD_Microservices

touch README.md
touch .gitignore

Upload to git:
git init
git add .
git commit -m "Initial project structure"
git branch -M main
git remote add origin <TU_REPO_GITHUB>
git push -u origin main

### Configure Webhook

Payload URL:

```text
http://JENKINS_PUBLIC_IP:8080/github-webhook/
```

Events:

```text
Push Events
```

### Verification

Push a commit and verify that Jenkins automatically triggers a new build.

[Agregar screenshot aquí]

---

# 3. Define a Jenkins Pipeline with Build, Test, Dockerize and Deploy Stages

### Project Structure

```text
05_Jenkins_CICD_Microservices/
├── app/
├── jenkins/
├── kubernetes/
├── helm/
├── docs/
├── scripts/
└── README.md
```

### CI/CD Pipeline Flow

```text
GitHub Push
      │
      ▼
Webhook Trigger
      │
      ▼
Jenkins Pipeline
      │
      ├── Build
      ├── Unit Tests
      ├── SonarQube Analysis
      ├── Docker Build
      ├── Docker Push
      └── Helm Deployment
                │
                ▼
           Kubernetes
```

### Jenkinsfile

(Agregar Jenkinsfile aquí)

---

# 4. Run Unit Tests Using JUnit and Static Analysis Using SonarQube

### SonarQube Installation

(Documentar instalación)

### SonarQube Analysis

(Documentar configuración Jenkins + SonarQube)

### Quality Gate Results

[Agregar screenshot aquí]

---

# 5. Build and Push a Docker Image to Docker Hub

### Docker Build

```bash
docker build -t nodejs-microservice .
```

### Docker Tag

```bash
docker tag nodejs-microservice fab27fc/nodejs-microservice:v1
```

### Docker Push

```bash
docker push fab27fc/nodejs-microservice:v1
```

### Verification

[Agregar screenshot Docker Hub]

---

# 6. Deploy the Container to Kubernetes Using Helm Charts

### Install Kubernetes (k3s)

(Documentar instalación)

### Install Helm

(Documentar instalación)

### Create Helm Chart

```bash
helm create nodejs-chart
```

### Deploy Application

```bash
helm install nodejs-app ./nodejs-chart
```

### Verification

```bash
kubectl get pods
kubectl get svc
```

[Agregar screenshots]

---

# 7. Verify the Deployment and Rollback on Failure

### Deployment Verification

```bash
kubectl get deployments
kubectl get pods
```

### Application Verification

```bash
curl http://APPLICATION_IP
```

### Rollback Example

```bash
helm rollback nodejs-app 1
```

### Verification After Rollback

```bash
helm history nodejs-app
```

[Agregar screenshot]

---

## Security Considerations

* SSH access is restricted to authorized administrators.
* Jenkins administrative access is protected by credentials.
* Docker containers provide process isolation.
* Secrets should not be stored directly in Jenkinsfiles.
* The EC2 Security Group only exposes required ports.

---

## DevOps Best Practices Applied

* Infrastructure hosted in AWS Cloud.
* Source control managed with GitHub.
* CI/CD automation using Jenkins.
* Static code analysis using SonarQube.
* Containerization using Docker.
* Kubernetes-based deployments.
* Helm chart deployment automation.
* Pipeline as Code implementation.

---

## Lessons Learned

* Jenkins automates software delivery pipelines.
* GitHub webhooks enable event-driven automation.
* Docker provides portable application environments.
* Kubernetes simplifies container orchestration.
* Helm standardizes Kubernetes deployments.

---

## Future Enhancements

* Implement Jenkins agents for distributed builds.
* Integrate AWS Secrets Manager.
* Add Prometheus and Grafana monitoring.
* Implement GitOps using ArgoCD.
* Integrate Trivy vulnerability scanning.

---

## Conclusion

This project demonstrates a complete CI/CD pipeline implementation using Jenkins, GitHub, Docker, SonarQube, Kubernetes, and Helm.

```
```


This project demonstrates a complete CI/CD pipeline implementation using Jenkins, GitHub, Docker, SonarQube, Kubernetes, and Helm.

The solution automates the software delivery lifecycle from source code commit to Kubernetes deployment while incorporating code quality analysis, containerization, and deployment automation practices commonly used in modern DevOps environments.


## Common Issues and Resolutions
## Issue Encountered: GitHub Authentication Failure

### Problem

When attempting to push code from the Jenkins EC2 instance to GitHub, the following error was received:

```text
remote: Permission to fab27fc/devops_labs.git denied to fab27fc.
fatal: unable to access 'https://github.com/fab27fc/devops_labs.git/': The requested URL returned error: 403
```

### Root Cause

GitHub no longer supports password authentication for Git operations over HTTPS.

Additionally, the EC2 instance did not have a configured SSH key associated with the GitHub account.

### Troubleshooting Performed

Verified the configured Git remote:

```bash
git remote -v
```

Output:

```text
https://github.com/fab27fc/devops_labs.git
```

Cleared cached credentials:

```bash
rm -f ~/.git-credentials
git config --global --unset credential.helper
```

Generated a new SSH key:

```bash
ssh-keygen -t ed25519 -C "fab27fc@gmail.com"
```

Displayed the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Added the public key to GitHub:

```text
GitHub
 └── Settings
      └── SSH and GPG Keys
            └── New SSH Key
```

Updated the repository remote URL:

```bash
git remote set-url origin git@github.com:fab27fc/devops_labs.git
```

Verified SSH connectivity:

```bash
ssh -T git@github.com
```

Expected output:

```text
Hi fab27fc! You've successfully authenticated.
```

### Resolution

After configuring SSH authentication and updating the Git remote URL, Git operations were successfully authenticated and code could be pushed to the GitHub repository without requiring a username, password, or personal access token.

### Lesson Learned

SSH authentication is the recommended method for managing Git repositories from cloud servers and CI/CD platforms such as Jenkins because it provides secure, persistent authentication and avoids issues related to Personal Access Tokens (PATs).


Webhook test Tue Jun  2 23:02:22 UTC 2026
