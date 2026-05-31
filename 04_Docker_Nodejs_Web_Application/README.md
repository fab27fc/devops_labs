# Docker - Containerizing a Node.js Web Application

## Project Overview

This project demonstrates how to containerize a Node.js web application using Docker and Docker Compose and deploy it to an AWS EC2 instance.

The goal is to provide developers with a portable, reproducible, and isolated runtime environment that can be deployed consistently across development, testing, and production environments.

---

## Technologies Used

* AWS EC2
* Ubuntu Server 24.04
* Docker
* Docker Compose
* Node.js
* Express.js
* Docker Hub
* GitHub

---

## Architecture

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
AWS EC2 Ubuntu
    │
    ▼
Docker Engine
    │
    ▼
Node.js Container
    │
    ▼
Port 3000
```

---

## Prerequisites

* AWS Account
* Ubuntu EC2 Instance
* SSH Access
* Docker Installed
* Docker Compose Installed
* Docker Hub Account
* Git Installed


## Project Structure:

<img width="255" height="395" alt="image" src="https://github.com/user-attachments/assets/a88753ae-a97d-4a14-a38d-ea5577de7b8b" />


## File Description

File	Purpose
Dockerfile	Defines the container image build process
docker-compose.yml	Manages application deployment
server.js	Node.js web application
package.json	Application dependencies
build.sh	Automates Docker image creation
deploy.sh	Automates container deployment
push-dockerhub.sh	Publishes images to Docker Hub
.dockerignore	Excludes files from Docker builds
.gitignore	Excludes files from Git tracking


1. Install Docker on the development machine.
Create the EC2 in aws:
Name: Install Docker on the development machine.
AMI: Ubuntu Server 24.04 LTS
Type: t2.micro o t3.micro
Security Group:
SSH (22) desde tu IP
HTTP (80) desde Anywhere
TCP 3000 desde Anywhere (para probar Node.js directamente)

1.1 Remote the EC2 and install Docker:
ssh -i .ssh/keypair_project_1-aws.pem ubuntu@IP_PUBLICA

sudo apt update
sudo apt upgrade -y

sudo apt install docker.io -y
docker --version
sudo usermod -aG docker ubuntu
sudo apt install docker-compose-plugin -y <- Error
Fix:
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
sudo ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

docker compose version
<img width="717" height="41" alt="image" src="https://github.com/user-attachments/assets/3ca8dffb-543d-4f29-ba83-960324100d81" />

Run Docker:
chmod +x scripts/*.sh
./scripts/build.sh
./scripts/deploy.sh

<img width="1027" height="523" alt="image" src="https://github.com/user-attachments/assets/0e50f74a-0eb1-4aa6-9c2f-42b5985147f5" />

Test:
docker ps
curl http://localhost:3000
curl http://localhost:3000/health

## 2. Create the Node.js Application

The application uses Express.js to expose a simple web service running on port 3000.

### Create the Application Directory

```bash
mkdir -p docker-nodejs-app/app
cd docker-nodejs-app/app
```

### Create package.json

```bash
nano package.json
```

```json
{
  "name": "nodejs-docker-app",
  "version": "1.0.0",
  "description": "Node.js web application containerized with Docker",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.21.0"
  }
}
```

### Create server.js

```bash
nano server.js
```

```javascript
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Node.js application running inside Docker on AWS EC2!');
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'nodejs-docker-app'
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

Install dependencies:

```bash
npm install
```

---

## 3. Create the Docker Configuration

### Create the Dockerfile

```bash
nano Dockerfile
```

```dockerfile
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### Create docker-compose.yml

```bash
nano docker-compose.yml
```

```yaml
services:
  nodeapp:
    build: ./app
    container_name: nodejs-app
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - NODE_ENV=production
```

---

## 4. Build and Run the Container

### Build the Image

```bash
docker-compose build
```

### Start the Container

```bash
docker-compose up -d
```

### Verify Running Containers

```bash
docker ps
```

Expected output:

```text
nodejs-app    Up
```


5. Push the Docker image to Docker Hub for future deployments.
5.1 Login Docker:
docker login
<img width="1119" height="427" alt="image" src="https://github.com/user-attachments/assets/ab1747b3-7f70-441a-8de8-d9ada60a4860" />

Copy the code: XXXX-XXXX

5.2:
Open your browser:
https://login.docker.com/activate
<img width="512" height="693" alt="image" src="https://github.com/user-attachments/assets/75310c01-1900-4034-8b3a-a49b1188ffb7" />

Password:

<img width="512" height="857" alt="image" src="https://github.com/user-attachments/assets/4f97df5c-e1f3-4a92-af7b-81c1649256bc" />

<img width="511" height="545" alt="image" src="https://github.com/user-attachments/assets/e203e524-c01a-4db0-8580-6857c6e3e861" />

After that:
docker images
docker tag docker-nodejs-app-nodeapp fab27fc/nodejs-app:v1
docker push fab27fc/nodejs-app:v1

<img width="1118" height="452" alt="image" src="https://github.com/user-attachments/assets/e5120986-23b8-4898-a1a2-e9b49c862316" />

<img width="1175" height="328" alt="image" src="https://github.com/user-attachments/assets/115edc90-7ede-4b93-99de-8f4aa855d47b" />

## 6. Deploy the Application to AWS EC2

The application was deployed on an AWS EC2 Ubuntu instance using Docker Compose.

### Security Group Configuration

| Port | Protocol | Purpose             |
| ---- | -------- | ------------------- |
| 22   | TCP      | SSH Remote Access   |
| 3000 | TCP      | Node.js Application |
| 80   | TCP      | Future HTTP Access  |

### Validate External Connectivity

Open a browser and navigate to:

```text
http://34.229.86.237:3000/
```
<img width="632" height="120" alt="image" src="https://github.com/user-attachments/assets/de0550bd-80ac-43dc-b51c-0a352529b155" />


### Application Health Check

```text
http://34.229.86.237:3000/health
```
<img width="628" height="190" alt="image" src="https://github.com/user-attachments/assets/bda9670d-7e16-459a-880b-f3750bbcb6fc" />

## Docker Image Repository

Docker Hub Repository:

```text
https://hub.docker.com/r/fab27fc/nodejs-app
```
<img width="1672" height="902" alt="image" src="https://github.com/user-attachments/assets/c80f8e96-0d19-4cc5-aba6-c80bca9946c6" />


The image can be pulled from any Docker host using:

```bash
docker pull fab27fc/nodejs-app:v1
```

---

## Validation

Verify the deployment:

```bash
docker ps
curl http://localhost:3000
curl http://localhost:3000/health
```

## Security Considerations

* SSH access is restricted to authorized administrators.
* Docker containers provide application isolation.
* Sensitive files are excluded using `.gitignore`.
* Docker build context is optimized using `.dockerignore`.
* No credentials are stored in the repository.
* The EC2 Security Group only exposes required ports.

---

## Useful Docker Commands

### Build Image

```bash
docker-compose build
```

### Start Containers

```bash
docker-compose up -d
```

### List Running Containers

```bash
docker ps
```

### View Logs

```bash
docker logs nodejs-app
```

### Stop Containers

```bash
docker-compose down
```

### List Docker Images

```bash
docker images
```

---

## DevOps Best Practices Applied

* Infrastructure deployed in AWS Cloud.
* Application containerization using Docker.
* Source code managed with GitHub.
* Container image distribution through Docker Hub.
* Deployment automation using shell scripts.
* Environment consistency across deployments.
* Documentation-first approach.
* Health check endpoint implementation.

---

## Lessons Learned

* Docker provides application portability.
* Docker Compose simplifies container lifecycle management.
* Docker Hub enables centralized image distribution.
* Containerized applications are easier to deploy and maintain.
* AWS EC2 can be used as a lightweight container hosting platform.
* Automation reduces manual deployment errors.

---

## Conclusion

This project successfully demonstrates the complete lifecycle of containerizing a Node.js application using Docker and Docker Compose, publishing the image to Docker Hub, and deploying the solution on an AWS EC2 instance.

In addition to containerization, the project incorporates source control with GitHub, deployment automation through shell scripts, image management using Docker Hub, and cloud hosting in AWS.

The resulting solution represents a practical DevOps workflow commonly used to build, package, distribute, and deploy modern applications in cloud environments.



********************************************************************************************************************
# Future Enhancements

* Implement CI/CD using GitHub Actions.
* Add Nginx as a reverse proxy.
* Enable HTTPS using Let's Encrypt.
* Store secrets using AWS Secrets Manager.
* Deploy the application using Amazon ECS.
* Deploy the application on Kubernetes.
* Integrate monitoring with Prometheus and Grafana.
* Implement vulnerability scanning with Trivy.

# Proposed Future Architecture

Current State
      ↓
Docker + EC2
      ↓
GitHub Actions (CI/CD)
      ↓
Nginx + HTTPS
      ↓
Secrets Management
      ↓
Monitoring
      ↓
Security Scanning
      ↓
ECS / Kubernetes

---









