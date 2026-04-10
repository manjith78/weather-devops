# QUICK START GUIDE

## 🎯 Next Steps

### Step 1: Verify Local Docker (Already Done ✅)
```bash
# Docker container running on localhost:8080
# Status: ✅ Verified
```

### Step 2: Push to GitHub
```bash
cd c:\Users\manjith\Documents\weather-devops
git init
git add .
git commit -m "Initial commit: Weather DevOps Project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/weather-devops.git
git push -u origin main
```

### Step 3: Add GitHub Secrets
Go to: `https://github.com/YOUR_USERNAME/weather-devops/settings/secrets/actions`

Add these secrets:
- **DOCKER_USERNAME**: Your DockerHub username
- **DOCKER_PASSWORD**: Your DockerHub personal access token (not password)

### Step 4: Deploy to Kubernetes
```bash
# Start Minikube
minikube start --driver=docker

# Deploy application
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Access application
minikube service weather-service
```

### Step 5: Deploy to Azure
```bash
# Generate SSH key if needed
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Deploy infrastructure
cd weather-devops
terraform init
terraform plan
terraform apply

# Get public IP
terraform output public_ip_address

# Access application
http://<PUBLIC_IP>
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| [README.md](README.md) | Project overview & architecture |
| [KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md) | K8s deployment instructions |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | Complete reference |
| [COMPLETION_SUMMARY.md](COMPLETION_SUMMARY.md) | Project summary |

---

## 🐳 Docker Commands

```bash
# Build image
docker build -t weather-app:v1 .

# Run container
docker run -d -p 8080:80 weather-app:v1

# View logs
docker logs -f weather-test

# Stop container
docker stop weather-test

# Push to DockerHub
docker tag weather-app:v1 YOUR_USERNAME/weather-app:latest
docker push YOUR_USERNAME/weather-app:latest
```

---

## ☸️ Kubernetes Commands

```bash
# Apply configurations
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check status
kubectl get pods
kubectl get svc
kubectl describe pod <pod-name>

# View logs
kubectl logs -f <pod-name>

# Scale deployment
kubectl scale deployment weather-app --replicas=4

# Port forward
kubectl port-forward svc/weather-service 8080:80

# Cleanup
kubectl delete deployment weather-app
kubectl delete svc weather-service
```

---

## 🏗️ Terraform Commands

```bash
# Initialize
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan

# View outputs
terraform output

# Destroy infrastructure
terraform destroy
```

---

## 🔐 SSH Access to Azure VM

```bash
# Get public IP
PUBIP=$(terraform output -raw public_ip_address)

# SSH into VM
ssh -i ~/.ssh/id_rsa azureuser@$PUBIP

# Inside VM: Check Docker
docker ps
docker logs <container-id>
```

---

## ✅ Verification Checklist

- [ ] Docker image built and tested locally
- [ ] GitHub repository created
- [ ] GitHub Secrets added (DOCKER_USERNAME, DOCKER_PASSWORD)
- [ ] First push triggers GitHub Actions
- [ ] Docker image appears in DockerHub
- [ ] Kubernetes manifests deployed (if using K8s)
- [ ] Terraform infrastructure provisioned (if using Azure)
- [ ] Application accessible at public IP (if using Azure)

---

## 📊 Architecture Overview

```
Your Code
    ↓
GitHub Repository
    ↓
GitHub Actions CI/CD
    ↓
DockerHub Registry
    ↓
├─→ Kubernetes Cluster (Minikube/AKS)
├─→ Azure VM (Terraform)
└─→ Local Docker (Development)
```

---

## 🆘 Troubleshooting

### Docker Not Starting
```bash
docker version
docker ps
# Check Docker daemon is running
```

### Kubernetes Cluster Issues
```bash
minikube status
kubectl cluster-info
kubectl get nodes
```

### Terraform Errors
```bash
terraform validate
terraform plan
# Review error messages carefully
```

### GitHub Actions Not Triggering
- Check GitHub Secrets are set correctly
- Verify .github/workflows/ci-cd.yml exists
- Check branch name matches (main)

---

## 🎓 What You've Learned

✅ Frontend: HTML/CSS/JavaScript with Chart.js  
✅ Docker: Containerization & optimization  
✅ Kubernetes: Orchestration & high availability  
✅ CI/CD: GitHub Actions automation  
✅ IaC: Terraform & Azure deployment  
✅ CM: Ansible automation  
✅ Cloud: Azure VM provisioning  
✅ Security: SSH keys, NSG rules  

---

## 📞 Resources

- Docker Docs: https://docs.docker.com/
- Kubernetes Docs: https://kubernetes.io/docs/
- Terraform Docs: https://www.terraform.io/docs/
- Ansible Docs: https://docs.ansible.com/
- Azure Docs: https://docs.microsoft.com/azure/

---

**Start with Step 2: Push to GitHub when ready! 🚀**
