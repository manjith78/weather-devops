# 🚀 AKS Deployment Guide - Complete Setup

This guide covers the complete deployment of the Weather App to Azure Kubernetes Service (AKS) using Terraform and GitHub Actions CI/CD.

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Local Terraform Setup](#local-terraform-setup)
4. [GitHub Actions Configuration](#github-actions-configuration)
5. [Deployment Steps](#deployment-steps)
6. [Accessing Your App](#accessing-your-app)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture Overview

```
GitHub Push
    ↓
GitHub Actions Triggered
    ↓
    ├─→ Job 1: Build & Push Docker Image
    │        └─→ Verify Image
    │
    ├─→ Job 2: Provision AKS Cluster (Terraform)
    │        ├─→ Terraform Init
    │        ├─→ Terraform Plan
    │        ├─→ Terraform Apply
    │        └─→ Get Credentials
    │
    └─→ Job 3: Deploy App to AKS
             ├─→ Update Manifests
             └─→ kubectl apply
    
Result: Weather App Running on Azure AKS ✅
```

### Technology Stack
- **Infrastructure as Code**: Terraform
- **Cloud Platform**: Microsoft Azure
- **Kubernetes**: Azure Kubernetes Service (AKS)
- **CI/CD**: GitHub Actions
- **Container Registry**: Docker Hub
- **Container Runtime**: Docker

---

## 📋 Prerequisites

### 1. Required Tools (Install Locally)
```bash
# Install Terraform (already done: v1.7.0)
terraform --version

# Install Azure CLI
# Download from: https://aka.ms/azurecli
az --version

# Install kubectl
az aks install-cli

# Verify installations
terraform version
az version
kubectl version --client
```

### 2. GitHub Secrets Required

Go to: **GitHub Repo → Settings → Secrets and variables → Actions**

Add these secrets:

| Secret | Value | Example |
|--------|-------|---------|
| `DOCKER_USERNAME` | Your DockerHub username | `urk23cs1011` |
| `DOCKER_PASSWORD` | DockerHub personal access token | `dckr_pat_...` |
| `AZURE_CREDENTIALS` | Azure service principal JSON | (See below) |

### 3. Create Azure Service Principal

```bash
# Login to Azure
az login

# Get subscription ID
az account show --query id -o tsv

# Create service principal (replace SUBSCRIPTION_ID)
az ad sp create-for-rbac \
  --name "github-weather-app" \
  --role "Contributor" \
  --scopes "/subscriptions/SUBSCRIPTION_ID" \
  --sdk-auth
```

**Output format** - Copy this entire JSON to GitHub Secret `AZURE_CREDENTIALS`:
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "...",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

---

## 🔧 Local Terraform Setup

### Step 1: Navigate to Terraform Directory
```bash
cd terraform-aks
```

### Step 2: Initialize Terraform
```bash
terraform init
```

Output:
```
✓ Backend initialized
✓ Terraform has been successfully configured!
```

### Step 3: Validate Configuration
```bash
terraform validate
```

### Step 4: Create Plan (Preview)
```bash
terraform plan -out=tfplan
```

Review the output - should show resources to be created:
- `azurerm_resource_group` (weather-rg)
- `azurerm_kubernetes_cluster` (weather-aks)

### Step 5: Apply (Create Resources)
```bash
terraform apply tfplan
```

**⏱️ Expected Time**: 10-15 minutes

Terraform will output important values:
```
Outputs:
  cluster_name = "weather-aks"
  resource_group_name = "weather-rg"
  host = "https://..."
```

### Step 6: Configure kubectl Locally
```bash
az aks get-credentials \
  --resource-group weather-rg \
  --name weather-aks
```

This creates/updates your `~/.kube/config` file.

### Step 7: Verify Connection
```bash
kubectl get nodes
```

Expected output:
```
NAME                                STATUS   ROLES   AGE     VERSION
aks-nodepool1-12345678-vmss000000   Ready    agent   2m      v1.XX.X
aks-nodepool1-12345678-vmss000001   Ready    agent   2m      v1.XX.X
```

---

## 🔄 GitHub Actions Configuration

### Workflow File
Location: `.github/workflows/ci-cd.yml`

The pipeline now has 3 jobs:

**Job 1: build-and-push**
- Builds Docker image
- Pushes to DockerHub
- Runs on every push

**Job 2: provision-aks**
- Logs into Azure
- Runs Terraform init/plan/apply
- Gets AKS credentials
- Verifies kubectl connection
- Runs only on main branch push

**Job 3: deploy-to-kubernetes**
- Waits for build and provision jobs
- Updates deployment manifests
- Deploys to AKS (kubectl apply)
- Shows deployment status
- Runs only on main branch push

### How It Works

1. **You push code to GitHub**
   ```bash
   git add .
   git commit -m "Update app"
   git push origin main
   ```

2. **GitHub Actions Triggers**
   - Runs build-and-push job
   - Builds Docker image
   - Pushes to DockerHub

3. **Provision AKS (if needed)**
   - Terraform creates AKS cluster (first time only)
   - Subsequent pushes skip this (cluster already exists)
   - Gets credentials for kubectl

4. **Deploy App**
   - Updates deployment manifest with new image
   - Applies manifests to AKS
   - App is live! 🚀

---

## 🚀 Deployment Steps

### Option A: Automatic (Recommended)
```bash
# Just push to GitHub
git add .
git commit -m "Deploy to AKS"
git push origin main

# GitHub Actions handles the rest ✅
# Watch the pipeline at: https://github.com/YOUR_USERNAME/weather-devops/actions
```

### Option B: Manual Local Deployment

1. **Create AKS Cluster**
   ```bash
   cd terraform-aks
   terraform init
   terraform apply
   ```

2. **Get Credentials**
   ```bash
   az aks get-credentials --resource-group weather-rg --name weather-aks
   kubectl get nodes
   ```

3. **Deploy Application**
   ```bash
   cd ..
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

4. **Verify Deployment**
   ```bash
   kubectl get deployments
   kubectl get pods
   kubectl get svc
   ```

---

## 🌐 Accessing Your App

### Get the Service IP
```bash
kubectl get svc weather-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Output: `20.XX.XX.XX`

### Access the App
```
http://20.XX.XX.XX
```

Or use this command to open in browser:
```bash
kubectl get svc weather-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | xargs -I {} echo "Open: http://{}"
```

### View Logs
```bash
# Check pod status
kubectl get pods

# View pod logs
kubectl logs -f deployment/weather-app

# Describe deployment
kubectl describe deployment weather-app
```

---

## 🔍 Monitoring & Management

### View Resources
```bash
# All resources
kubectl get all

# Deployments
kubectl get deployments
kubectl describe deployment weather-app

# Pods
kubectl get pods
kubectl describe pod <pod-name>

# Services
kubectl get svc
kubectl describe svc weather-service
```

### Scale the Application
```bash
# Increase replicas to 5
kubectl scale deployment weather-app --replicas=5

# View autoscaling status
kubectl get hpa
```

### Update Deployment
```bash
# Update image
kubectl set image deployment/weather-app weather-container=urk23cs1011/weather-app:latest

# Check rollout status
kubectl rollout status deployment/weather-app
```

---

## 🐛 Troubleshooting

### Issue: "No nodes ready"
```bash
# Check node status
kubectl get nodes

# Fix: Wait or add more nodes
az aks nodepool add --cluster-name weather-aks \
  --resource-group weather-rg \
  --name nodepool2 \
  --node-count 2
```

### Issue: Pod not starting
```bash
# Check pod logs
kubectl logs <pod-name>

# Check pod events
kubectl describe pod <pod-name>

# Check image exists on DockerHub
docker pull urk23cs1011/weather-app:latest
```

### Issue: Service has no external IP
```bash
# Wait for IP assignment (takes ~2 minutes)
kubectl get svc --watch

# If stuck, check Azure quota
az compute resource-skus list --query "[?name=='Standard_B2s'].restrictions"
```

### Issue: Terraform apply fails
```bash
# Check Azure credentials
az account show

# Validate Azure CLI login
az aks list

# Check Terraform state
terraform state list
```

### Issue: kubectl can't connect to cluster
```bash
# Reconfigure credentials
az aks get-credentials --resource-group weather-rg --name weather-aks --overwrite-existing

# Verify context
kubectl config current-context

# Switch context
kubectl config use-context weather-aks
```

---

## 🧹 Cleanup (Delete All Resources)

⚠️ **WARNING: This will delete the AKS cluster and all data!**

```bash
# Option 1: Using Terraform (recommended)
cd terraform-aks
terraform destroy

# Option 2: Using Azure CLI
az group delete --name weather-rg --yes
```

---

## 📊 Cost Optimization

### Current Configuration
- **Cluster**: 2 nodes (Standard_B2s)
- **Estimated Cost**: ~$120-150/month

### Cost-Saving Options
1. **Use smaller VMs**
   ```bash
   # In variables.tf, change:
   vm_size = "Standard_B1s"  # Cheaper
   ```

2. **Enable autoscaling**
   - Already enabled (min: 1, max: 5)
   - Scales down during low traffic

3. **Use Azure Spot instances**
   - Add to terraform/main.tf for 70% discount

---

## 🎓 Learning Resources

- [AKS Best Practices](https://learn.microsoft.com/azure/aks/best-practices)
- [Terraform AKS Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

---

## ✅ Deployment Checklist

- [ ] Install Azure CLI
- [ ] Create Azure service principal
- [ ] Add GitHub secrets (DOCKER_USERNAME, DOCKER_PASSWORD, AZURE_CREDENTIALS)
- [ ] Run `terraform init` locally
- [ ] Run `terraform plan` to verify
- [ ] Push changes to GitHub
- [ ] Monitor GitHub Actions workflow
- [ ] Get AKS service IP
- [ ] Access app in browser
- [ ] Monitor logs and metrics

---

## 🎉 Success!

Your Weather App is now running on Azure Kubernetes Service with:
- ✅ Automated infrastructure provisioning (Terraform)
- ✅ Containerization (Docker)
- ✅ Orchestration (Kubernetes/AKS)
- ✅ CI/CD Pipeline (GitHub Actions)
- ✅ Production-ready setup

This is **real enterprise DevOps architecture**! 🚀
