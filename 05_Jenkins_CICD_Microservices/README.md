5. Jenkins - CI/CD Pipeline for Microservices
Problem: Developers need automated builds, testing, and deployments for a microservices architecture. Tools/Services Used: Jenkins, GitHub, Docker, Kubernetes, Helm, SonarQube. Implementation Steps:
1. Install Jenkins and configure necessary plugins.
2. Set up a GitHub webhook for automatic builds.
3. Define a Jenkins pipeline with stages (Build, Test, Dockerize, Deploy).
4. Run unit tests using JUnit and static analysis using SonarQube.
5. Build and push a Docker image to Docker Hub.
6. Deploy the container to Kubernetes using Helm charts.
7. Verify the deployment and rollback on failure.



Arquitecture:
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
    ├── SonarQube
    ├── Docker Build
    ├── Docker Push
    └── Deploy
             │
             ▼
        Kubernetes
             │
             ▼
          Helm


1. Install Jenkins and configure necessary plugins.
1.1 Creacte the EC2 instance:
Ubuntu 24.04
t3.medium

Install:
Jenkins
Docker
Git
Java
kubectl
Helm
