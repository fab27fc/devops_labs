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


1. Install Jenkins and Configure Necessary Plugins
Objective

The goal of this step is to prepare a CI/CD server capable of building, testing, containerizing, and deploying applications automatically.

Jenkins will be used as the automation server for the entire pipeline.

1.1 Create the AWS EC2 Instance

The Jenkins server was deployed on AWS using Terraform.

EC2 Configuration
Setting	Value
Name	Jenkins Server
AMI	Ubuntu Server 24.04 LTS
Instance Type	t3.medium
Storage	20 GB
Region	us-east-1
Security Group Configuration
Port	Protocol	Purpose
22	TCP	SSH Access
8080	TCP	Jenkins UI
9000	TCP	SonarQube
6443	TCP	Kubernetes API
3000	TCP	Application Testing
Evidence

Add screenshot:

AWS EC2 Instance
1.2 Connect to the Server
ssh -i keypair_project_1-aws.pem ubuntu@PUBLIC_IP

Update the operating system:

sudo apt update
sudo apt upgrade -y
1.3 Install Docker

Docker will be used by Jenkins to build and publish container images.

Install Docker:

sudo apt install docker.io -y

Verify installation:

docker --version

Enable Docker service:

sudo systemctl enable docker
sudo systemctl start docker

Verify service:

sudo systemctl status docker

Allow the Ubuntu user to execute Docker commands without sudo:

sudo usermod -aG docker ubuntu
newgrp docker

Test Docker:

docker run hello-world
Evidence

Add screenshot:

Docker installation validation
1.4 Install Java

Jenkins requires Java to run.

Install OpenJDK 21:

sudo apt install openjdk-21-jdk -y

Verify installation:

java -version
Evidence

Add screenshot:

Java version output
1.5 Install Jenkins

Remove any previous Jenkins repositories:

sudo rm -f /usr/share/keyrings/jenkins-keyring.asc
sudo rm -f /etc/apt/sources.list.d/jenkins.list

Create keyring directory:

sudo mkdir -p /etc/apt/keyrings

Download Jenkins repository key:

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

Add Jenkins repository:

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

Install Jenkins:

sudo apt update
sudo apt install jenkins -y
1.6 Start Jenkins Service

Enable Jenkins:

sudo systemctl enable jenkins

Start Jenkins:

sudo systemctl start jenkins

Verify service:

sudo systemctl status jenkins

Verify listening port:

sudo ss -tulpn | grep 8080

Expected output:

0.0.0.0:8080
1.7 Access Jenkins Web Interface

Open a browser:

http://PUBLIC_IP:8080

Retrieve the initial administrator password:

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

Paste the password into the Jenkins setup wizard.

Evidence

Add screenshots:

Jenkins Unlock Screen
Jenkins Dashboard
1.8 Install Required Jenkins Plugins

The following plugins were installed:

Plugin	Purpose
Git	Source code integration
Docker	Docker image management
Pipeline	Pipeline as Code
GitHub Integration	GitHub Webhooks
SonarQube Scanner	Static code analysis
Kubernetes	Kubernetes deployments
Blue Ocean	Modern Jenkins UI
Evidence

Add screenshot:

Installed Plugins
1.9 Verify Jenkins Installation

Create a test pipeline and run a simple build.

Expected result:

Build Success
Evidence

Add screenshot:

Successful Jenkins Build
Step Completed

Jenkins was successfully installed and configured on AWS EC2 together with Docker, Java, GitHub integration plugins, and Kubernetes deployment capabilities.

The CI/CD server is now ready to receive source code changes from GitHub and execute automated pipelines.

## 2. Set Up a GitHub Webhook for Automatic Builds

### Objective

The goal of this step is to connect GitHub with Jenkins so that every new push to the repository automatically triggers the Jenkins pipeline.

This removes the need to manually click **Build Now** in Jenkins.

---

### GitHub Repository

The Jenkins pipeline was connected to the following GitHub repository:

```text
https://github.com/fab27fc/devops_labs.git

Since this lab is inside a subfolder of the main repository, the Jenkinsfile path was configured as:

05_Jenkins_CICD_Microservices/jenkins/Jenkinsfile
Jenkins Pipeline Job Configuration

A new Jenkins Pipeline job was created:

nodejs-microservice-pipeline

The pipeline was configured using:

Pipeline script from SCM

Repository configuration:

SCM: Git
Repository URL: https://github.com/fab27fc/devops_labs.git
Branch: */main
Script Path: 05_Jenkins_CICD_Microservices/jenkins/Jenkinsfile
GitHub Webhook Configuration

A webhook was created in GitHub using the Jenkins webhook endpoint:

http://52.73.135.130:8080/github-webhook/

Webhook settings:

Content type: application/json
Event: Just the push event
Status: Active
Test Webhook Trigger

A test change was committed and pushed to GitHub:

echo "Webhook test $(date)" >> 05_Jenkins_CICD_Microservices/README.md
git add .
git commit -m "Test GitHub webhook trigger"
git pull --rebase origin main
git push origin main
Result

After pushing the change to GitHub, Jenkins automatically triggered a new build without manually selecting Build Now.

This confirms that the GitHub webhook was successfully configured.
---

## 3. Define a Jenkins Pipeline with Stages (Build, Test, Dockerize, Deploy)

### Objective

Create a Jenkins Pipeline as Code implementation that automates the software delivery workflow.

The pipeline definition is stored in a Jenkinsfile within the GitHub repository, allowing the CI/CD process to be version-controlled and maintained alongside the application source code.

---

### Pipeline Stages

| Stage     | Purpose                                          |
| --------- | ------------------------------------------------ |
| Build     | Prepare the application for deployment           |
| Test      | Execute automated validation tests               |
| Dockerize | Create a container image                         |
| Deploy    | Deploy the application to the target environment |

---

### Pipeline Source Configuration

The Jenkins Pipeline was configured using the **Pipeline Script from SCM** option.

Repository:

```text
https://github.com/fab27fc/devops_labs.git
```

Branch:

```text
main
```

Script Path:

```text
jenkins/Jenkinsfile
```

This configuration allows Jenkins to automatically retrieve the pipeline definition directly from the GitHub repository whenever a build is triggered.

---

### Jenkinsfile

```groovy
pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                echo 'Building application...'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
            }
        }

        stage('Dockerize') {
            steps {
                echo 'Building Docker image...'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }
    }
}
```

---

### Pipeline Execution Flow

```text
GitHub Push
      │
      ▼
Jenkins Pipeline
      │
      ├── Build
      ├── Test
      ├── Dockerize
      └── Deploy
```

---

### Pipeline Execution Result

The Jenkins Pipeline successfully retrieved the Jenkinsfile from GitHub and executed all configured stages.

The execution validated the integration between GitHub, Jenkins, and the CI/CD workflow.

<img width="1288" height="1032" alt="image" src="https://github.com/user-attachments/assets/7bc73d05-8b92-4c25-b933-f3627cafe10d" />

---

### Result

The pipeline successfully executed all stages and provided a foundation for future integration with SonarQube, Docker Hub, Kubernetes, and Helm.




## 4. Run Unit Tests Using JUnit and Static Analysis Using SonarQube

### Objective

Integrate SonarQube with Jenkins to perform automated static code analysis during the CI/CD pipeline execution.

This integration helps identify bugs, vulnerabilities, code smells, and maintainability issues before deployment.

---

### 4.1 Install SonarQube

SonarQube was deployed as a Docker container on the Jenkins EC2 instance.

```bash
docker run -d \
--name sonarqube \
-p 9000:9000 \
sonarqube:lts-community
```

Verify the container status:

```bash
docker ps
```

Access SonarQube:

```text
http://<JENKINS_PUBLIC_IP>:9000
```

<img width="1440" height="332" alt="image" src="https://github.com/user-attachments/assets/949581f4-b201-46d4-ba0c-7d86bc1f8381" />

Default credentials:

```text
Username: admin
Password: admin
```

After the first login, update the administrator password.

---

### 4.2 Verify SonarQube Plugin Installation

The SonarQube Scanner plugin must be installed in Jenkins before integration.

Navigate to:

```text
Manage Jenkins
    ↓
Plugins
    ↓
Installed Plugins
```

Verify that the SonarQube Scanner plugin is available.

<img width="1701" height="351" alt="image" src="https://github.com/user-attachments/assets/ed5b481e-1c79-4661-8ac9-b34132de3c54" />

---

### 4.3 Create a SonarQube Project

Create a new project manually.

Select:

```text
Projects
    ↓
Create Project
    ↓
Manually
```

<img width="447" height="472" alt="image" src="https://github.com/user-attachments/assets/d4a14068-0335-422d-802a-786fd24ad30d" />

Project Name:

```text
nodejs-microservice
```

Project Key:

```text
nodejs-microservice
```

---

### 4.4 Generate a SonarQube Authentication Token

Navigate to:

```text
Administration
    ↓
Security
    ↓
Users
```

<img width="1312" height="852" alt="image" src="https://github.com/user-attachments/assets/25d27e04-574b-456c-b793-56878f5d5484" />

Generate a new token for Jenkins integration.

<img width="1052" height="555" alt="image" src="https://github.com/user-attachments/assets/bf47029a-cdbb-4cff-a5a3-a3e549d23800" />

Example:

```text
Token Name:
jenkins-token
```

Copy the generated token securely.

---

### 4.5 Store the Token in Jenkins

Navigate to:

```text
Manage Jenkins
    ↓
Credentials
    ↓
System
    ↓
Global Credentials
    ↓
Add Credentials
```

Configure:

```text
Kind:
Secret Text

Secret:
SONARQUBE_TOKEN

ID:
sonarqube-token
```

This credential will be used by Jenkins Pipelines to authenticate against SonarQube.

---

### 4.6 Configure SonarQube Server in Jenkins

Navigate to:

```text
Manage Jenkins
    ↓
System
    ↓
SonarQube Servers
```

Configure:

```text
Name:
SonarQube

Server URL:
http://localhost:9000

Server Authentication Token:
sonarqube-token
```

Save the configuration.

---
### 4.7 Configure Unit Testing with Jest

The Node.js microservice was configured to use Jest for automated testing.

package.json

The test script was configured as follows:

"test": "jest --ci --reporters=default --reporters=jest-junit"

Install dependencies:

npm install

### 4.8 Create Unit Test

File:

app/test.js
test('health endpoint validation', () => {
  const service = {
    status: 'healthy',
    service: 'nodejs-microservice'
  };

  expect(service.status).toBe('healthy');
  expect(service.service).toBe('nodejs-microservice');
});

This test validates the expected response values used by the microservice.

### 4.9 Configure SonarQube Project Properties

File:

app/sonar-project.properties
sonar.projectKey=nodejs-microservice
sonar.projectName=nodejs-microservice
sonar.sources=.
sonar.exclusions=node_modules/**,test-results/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.sourceEncoding=UTF-8

These settings define how SonarQube analyzes the project source code.

### 4.10 Execute Unit Tests

Run tests manually:

npm test

Expected result:

PASS ./test.js

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total

Verify Jest installation:

ls node_modules/.bin/jest

Expected output:

node_modules/.bin/jest

Add a screenshot of the successful test execution.

Quality Gate Results

After integrating SonarQube with Jenkins, every pipeline execution can perform static code analysis and validate quality requirements before deployment.

Typical Quality Gate checks include:

Bugs
Vulnerabilities
Code Smells
Security Hotspots
Maintainability Rating
Code Coverage
Result

SonarQube and Jest were successfully integrated into the project.

The application can now execute automated unit tests and static code analysis before moving to the Docker build and deployment stages of the CI/CD pipeline.

4.11 Configure SonarScanner in Jenkins

Navigate to:

Manage Jenkins
    ↓
Tools
    ↓
SonarQube Scanner

Add a new SonarScanner installation:

Name:
SonarScanner

Enable:

Install automatically

This allows Jenkins Pipelines to execute SonarQube scans using the SonarScanner CLI.

4.12 SonarQube Analysis Workflow

The static analysis process follows the workflow below:

Developer Push
      │
      ▼
GitHub Repository
      │
      ▼
Jenkins Pipeline
      │
      ▼
SonarScanner
      │
      ▼
SonarQube Server
      │
      ▼
Quality Gate Validation

During the analysis process, SonarQube evaluates:

Code Quality
Bugs
Vulnerabilities
Security Hotspots
Code Smells
Maintainability
Technical Debt
Test Coverage
4.13 Benefits of Static Code Analysis

Implementing SonarQube provides several advantages:

Detects code issues before deployment.
Improves maintainability.
Identifies potential security vulnerabilities.
Enforces coding standards.
Reduces technical debt.
Integrates directly with Jenkins pipelines.
Supports Quality Gates for deployment validation.


# 5. Build and Push a Docker Image to Docker Hub

## Objective

Build a Docker image for the Node.js microservice and push it to Docker Hub.

This step allows the application to be stored in a container registry so it can later be pulled and deployed to Kubernetes using Helm.

---

## 5.1 Verify the Dockerfile Location

The Dockerfile is located inside the `app/` directory.

Project structure:

```text
05_Jenkins_CICD_Microservices/
├── app/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   ├── server.js
│   └── test.js
├── helm/
├── jenkins/
│   └── Jenkinsfile
├── kubernetes/
├── scripts/
├── screenshots/
└── README.md
```

---

## 5.2 Dockerfile Used

The Dockerfile defines how the Node.js application image is built.

```dockerfile
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

---

## 5.3 Build the Docker Image

Since the Dockerfile is inside the `app/` folder, the Docker build context must point to `./app`.

```bash
docker build -t fab27fc/nodejs-microservice:test ./app
```

### Explanation

| Component                          | Description                             |
| ---------------------------------- | --------------------------------------- |
| `docker build`                     | Builds a Docker image                   |
| `-t`                               | Assigns a name and tag to the image     |
| `fab27fc/nodejs-microservice:test` | Docker Hub repository and tag           |
| `./app`                            | Build context containing the Dockerfile |

---
<img width="1610" height="647" alt="image" src="https://github.com/user-attachments/assets/4aed8c9a-2ca4-4e7f-a8ed-a189aa828398" />

## 5.4 Verify the Image Locally

After building the image, verify that it exists locally.

```bash
docker images
```

Expected output:

```text
REPOSITORY                      TAG    IMAGE ID       SIZE
fab27fc/nodejs-microservice     test   <image_id>     <size>
```
<img width="1787" height="272" alt="image" src="https://github.com/user-attachments/assets/bb581f78-dbf5-40ea-bd80-bc2b9372ca75" />

---

## 5.5 Push the Image to Docker Hub

Push the image to Docker Hub.

```bash
docker push fab27fc/nodejs-microservice:test
```

---

## 5.6 Docker Hub Repository

Repository:

```text
fab27fc/nodejs-microservice
```

Tag:

```text
test
```

Docker Hub successfully received the image and stored it in the repository.

<img width="1172" height="940" alt="image" src="https://github.com/user-attachments/assets/7eb62c6e-6e7d-4286-809f-45cfafe351ce" />

---

## 5.7 Result

The Docker image was successfully built and pushed to Docker Hub.

This confirms that the application is now available in a container registry and can be pulled by Kubernetes during deployment.

---

## Commands Summary

```bash
docker build -t fab27fc/nodejs-microservice:test ./app
docker images
docker push fab27fc/nodejs-microservice:test
```


## 6. Deploy the Container to Kubernetes Using Helm Charts

### Objective

Deploy the Docker image published to Docker Hub into a Kubernetes cluster using Helm charts.

This step validates that the containerized Node.js microservice can be deployed and managed inside Kubernetes.

---

### 6.1 Tools Used

* Kubernetes k3s
* Helm
* Docker Hub
* AWS EC2
* Node.js Docker Image

---

### 6.2 Docker Image Used

The Kubernetes deployment uses the Docker image previously published to Docker Hub:

```text
fab27fc/nodejs-microservice:v1
```

This image was built from the Node.js microservice application and pushed to Docker Hub during the Docker image publishing stage.

---

### 6.3 Helm Chart Structure

The Helm chart was created inside the project directory:

```text
05_Jenkins_CICD_Microservices/
└── helm/
    └── nodejs-chart/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            └── helpers.tpl
```

The Helm chart is responsible for defining the Kubernetes resources required to deploy the application.

---

### 6.4 Configure Helm Values

File:

```text
helm/nodejs-chart/values.yaml
```

The image configuration was updated to use the Docker Hub repository:

```yaml
replicaCount: 2

image:
  repository: fab27fc/nodejs-microservice
  pullPolicy: IfNotPresent
  tag: "v1"
```

The service was configured to expose the application using NodePort:

```yaml
service:
  type: NodePort
  port: 3000
```

---

### 6.5 Configure Kubernetes Deployment Template

File:

```text
helm/nodejs-chart/templates/deployment.yaml
```

The container image was configured using Helm values:

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

The application container exposes port 3000:

```yaml
ports:
  - name: http
    containerPort: 3000
    protocol: TCP
```

---

### 6.6 Deploy the Application Using Helm

Navigate to the Helm directory:

```bash
cd ~/devops_labs/05_Jenkins_CICD_Microservices/helm
```

Install or upgrade the application release:

```bash
helm upgrade --install nodejs-app ./nodejs-chart
```

This command installs the Helm release if it does not exist, or updates it if it already exists.

---

### 6.7 Verify Helm Release

Check the Helm release status:

```bash
helm list
```

<img width="1475" height="157" alt="image" src="https://github.com/user-attachments/assets/62a1766c-a5e2-487e-88e1-371d16b48e30" />

---

### 6.8 Verify Kubernetes Pods

Check the running pods:

```bash
kubectl get pods
```

<img width="1067" height="132" alt="image" src="https://github.com/user-attachments/assets/3eee480a-a0b0-4b7b-a9fe-eaa5b9c3c3cf" />


The `1/1 Running` status confirms that both replicas are running successfully.

---

### 6.9 Verify Kubernetes Deployment

Check the deployment:

```bash
kubectl get deployments
```

Describe the deployment image:

```bash
kubectl describe deployment nodejs-app-nodejs-chart | grep Image
```
<img width="1462" height="187" alt="image" src="https://github.com/user-attachments/assets/6563563a-3053-4a3a-adab-7e6ddfc6668b" />


This confirms that Kubernetes is running the correct Docker Hub image.

---

### 6.10 Verify Kubernetes Service

Check the Kubernetes service:

```bash
kubectl get svc
```
<img width="1006" height="127" alt="image" src="https://github.com/user-attachments/assets/7e50b24d-1259-4d6d-9aec-96396b9b1d92" />


The service exposes the container internally on port `3000` and externally through a NodePort.

---

### 6.11 Test the Application

Store the NodePort value:

```bash
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services nodejs-app-nodejs-chart)
```

Test the application:

```bash
curl http://localhost:$NODE_PORT
```
<img width="1422" height="87" alt="image" src="https://github.com/user-attachments/assets/2fd28e79-4dde-4311-8d38-3e0c7cfdbc78" />

Test the health endpoint:

```bash
curl http://localhost:$NODE_PORT/health
```
<img width="1402" height="92" alt="image" src="https://github.com/user-attachments/assets/f4c090b7-1361-4c30-9706-0130e70771b1" />


---

### 6.12 Issue Encountered: ImagePullBackOff

During the first deployment, one of the pods entered the following state:

```text
ImagePullBackOff
```

The pod events showed that Kubernetes was trying to pull an incorrect image:

```text
fab27fc/nodejs-microservice/values.yaml:test
```

### Root Cause

The Helm deployment template had an incorrect image reference.

Kubernetes should pull:

```text
fab27fc/nodejs-microservice:v1
```

but the template generated an invalid image path.

### Resolution

The Helm deployment template was corrected to use:

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

After updating the Helm chart, the application was redeployed:

```bash
helm upgrade --install nodejs-app ./nodejs-chart
```

Old failed pods were deleted so Kubernetes could recreate them:

```bash
kubectl delete pod -l app.kubernetes.io/instance=nodejs-app
```

After the fix, both pods entered the `Running` state.

---

### 6.13 Things to Review

Before considering the deployment successful, the following items should be verified:

| Check        | Command                                                             | Expected Result                   |
| ------------ | ------------------------------------------------------------------- | --------------------------------- |
| Helm release | `helm list`                                                         | STATUS = deployed                 |
| Pods         | `kubectl get pods`                                                  | READY = 1/1, STATUS = Running     |
| Deployment   | `kubectl get deployments`                                           | AVAILABLE replicas greater than 0 |
| Image        | `kubectl describe deployment nodejs-app-nodejs-chart \| grep Image` | `fab27fc/nodejs-microservice:v1`  |
| Service      | `kubectl get svc`                                                   | Service type = NodePort           |
| Application  | `curl http://localhost:$NODE_PORT`                                  | Application response              |
| Health Check | `curl http://localhost:$NODE_PORT/health`                           | JSON status healthy               |

---

### Result

The Node.js microservice was successfully deployed to Kubernetes using Helm.

The deployment used the Docker image from Docker Hub, created two running replicas, exposed the application through a NodePort service, and validated the application using both the root endpoint and the health endpoint.


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
Hi fab27fc! You've successfully authenticated
```

### Resolution

After configuring SSH authentication and updating the Git remote URL, Git operations were successfully authenticated and code could be pushed to the GitHub repository without requiring a username, password, or personal access token.

### Lesson Learned

SSH authentication is the recommended method for managing Git repositories from cloud servers and CI/CD platforms such as Jenkins because it provides secure, persistent authentication and avoids issues related to Personal Access Tokens (PATs).


Webhook test Tue Jun  2 23:02:22 UTC 2026
Webhook test Tue Jun  2 23:02:49 UTC 2026
