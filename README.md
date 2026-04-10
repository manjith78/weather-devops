# Weather App - DevOps Project

A complete DevOps project demonstrating containerization, CI/CD, Kubernetes deployment, and Infrastructure as Code.

## 🏗️ Project Architecture

```
Frontend (HTML/CSS/JS) 
    ↓
Docker Container (nginx:alpine)
    ↓
Kubernetes (Minikube / Azure)
    ↓
Azure VM (Terraform)
```

## 📋 Prerequisites

- Docker
- Kubernetes (Minikube for local testing)
- Ansible
- Terraform
- Git

## 🚀 Quick Start

### 1. Local Docker Testing
```bash
docker build -t weather-app:v1 .
docker run -d -p 8080:80 --name weather-test weather-app:v1
# Access: http://localhost:8080
```

### 2. Kubernetes Deployment (Minikube)
```bash
minikube start
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
minikube service weather-service
```

### 3. Ansible Setup
```bash
ansible-playbook ansible/setup.yml
```

### 4. Terraform Deployment (Azure)
```bash
# Create SSH key if needed: ssh-keygen -t rsa -b 4096
terraform init
terraform plan
terraform apply
```

## 📦 Components

### Frontend
- **index.html**: Weather dashboard with Chart.js graphs
- Professional UI with gradient background
- Form validation and error handling
- Temperature trend visualization

### Containerization
- **Dockerfile**: nginx:alpine base image
- Lightweight and production-ready
- Serves static content

### CI/CD
- **GitHub Actions**: Automated build and push to DockerHub
- DockerHub integration for image storage
- Build caching for faster deployments

### Kubernetes
- **deployment.yaml**: 2 replicas for HA
- **service.yaml**: NodePort service (port 30007)

### Infrastructure as Code
- **main.tf**: Complete Azure deployment including:
  - Virtual Network and Subnets
  - Network Security Groups
  - Public IP and NIC
  - Ubuntu 22.04 LTS VM
  - Automatic Docker installation via user data

### Configuration Management
- **ansible/setup.yml**: Docker installation and verification
- Comprehensive error handling
- Service status monitoring

## 🔐 GitHub Secrets Required

For CI/CD pipeline, add these secrets to your GitHub repository:
- `DOCKER_USERNAME`: Your DockerHub username
- `DOCKER_PASSWORD`: Your DockerHub personal access token

## 📊 Features

✅ Professional weather dashboard UI
✅ Docker containerization
✅ Kubernetes orchestration
✅ Automated CI/CD pipeline
✅ Infrastructure as Code (Terraform)
✅ Configuration automation (Ansible)
✅ High availability (multiple replicas)
✅ Security groups and network policies

## 🧪 Testing

```bash
# Local testing
curl http://localhost:8080

# Kubernetes testing
kubectl get pods
kubectl logs <pod-name>

# Minikube service
minikube service weather-service

# Azure VM access
ssh azureuser@<public-ip>
docker ps
```

## 📝 Deployment Steps

1. **Local**: `docker build` + `docker run`
2. **Kubernetes**: `kubectl apply -f deployment.yaml`
3. **Cloud**: `terraform apply`

## 🛠️ Configuration

### Docker Image Registry
```
urk23cs1011/weather-app:latest
```

### Azure VM
- **Size**: Standard_B2s
- **OS**: Ubuntu 22.04 LTS
- **Authentication**: SSH key-based
- **Public IP**: Static

## 📞 Support

For issues or questions, check logs:
```bash
docker logs weather-test
kubectl logs -f <pod-name>
az vm get-instance-view -d --resource-group weather-rg --name weather-vm
```

---

**Project Status**: ✅ Complete and Ready for Deployment
