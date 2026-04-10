# Terraform + Ansible Automated Deployment Guide

## 🚀 Complete Workflow

This guide shows how to use **Terraform** (infrastructure) + **Ansible** (configuration) to deploy your weather app to Azure automatically.

---

## 📋 Prerequisites

1. **Azure CLI** installed and logged in
   ```bash
   az account show
   ```

2. **Terraform** installed
   ```bash
   terraform version
   ```

3. **Ansible** installed
   ```bash
   ansible --version
   ```

4. **SSH key generated** (required for authentication)
   ```bash
   # If you don't have one, create it:
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   # Press Enter when asked for passphrase (or set one for security)
   ```

---

## 🔧 Step 1: Deploy Infrastructure with Terraform

### 1.1 Initialize Terraform
```bash
cd c:\Users\manjith\Documents\weather-devops
terraform init
```

**Expected output:**
```
Terraform has been successfully configured!
```

### 1.2 Plan Deployment
```bash
terraform plan -out=tfplan
```

This shows what will be created:
- ✅ Resource Group
- ✅ Virtual Network & Subnet
- ✅ Network Security Groups
- ✅ Public IP
- ✅ Network Interface
- ✅ Linux VM (Ubuntu 22.04 LTS)

### 1.3 Apply Terraform Configuration
```bash
terraform apply tfplan
```

**Wait for completion** (~5-10 minutes)

**Expected output:**
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
public_ip_address = "XX.XX.XX.XX"
vm_id = "/subscriptions/.../weatherapp-vm"
```

### 1.4 Save Public IP
```bash
# Get the public IP
$PUBLIC_IP = terraform output -raw public_ip_address
Write-Host "✅ Public IP: $PUBLIC_IP"
```

---

## 🔑 Step 2: Set Up SSH Access

### 2.1 Test SSH Connection
```bash
# Wait 30-60 seconds for VM to fully boot
ssh -i ~/.ssh/id_rsa azureuser@$PUBLIC_IP

# You should see Ubuntu welcome message
exit
```

### 2.2 Fix Permissions (if needed)
```bash
# On Windows, Ansible might have SSH permission issues
# Run this if SSH fails:
icacls $env:USERPROFILE\.ssh\id_rsa /inheritance:r /grant:r "$($env:USERNAME):(F)"
```

---

## 📝 Step 3: Create Ansible Inventory

Create a file: `ansible/inventory.ini`

```ini
[weather_servers]
weather_vm ansible_host=PUBLIC_IP_HERE ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa

[weather_servers:vars]
ansible_python_interpreter=/usr/bin/python3
```

**Replace `PUBLIC_IP_HERE` with your actual IP** (from Step 1.4)

Example:
```ini
[weather_servers]
weather_vm ansible_host=20.145.167.89 ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa

[weather_servers:vars]
ansible_python_interpreter=/usr/bin/python3
```

---

## 🎯 Step 4: Update Ansible Playbook for Remote

Edit `ansible/setup.yml` - change `hosts` from `localhost` to `weather_servers`:

**Change this:**
```yaml
hosts: localhost
connection: local
become: yes
```

**To this:**
```yaml
hosts: weather_servers
connection: ssh
become: yes
```

---

## ✅ Step 5: Run Ansible Playbook

### 5.1 Test Connection
```bash
ansible all -i ansible/inventory.ini -m ping
```

**Expected output:**
```
weather_vm | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 5.2 Run Docker Installation
```bash
ansible-playbook -i ansible/inventory.ini ansible/setup.yml -v
```

**Expected output:**
```
PLAY [DevOps Setup - Docker Installation] ****
TASK [Update system package cache] ...
TASK [Install Docker and dependencies] ...
TASK [Start Docker service] ...
✅ Docker installed: Docker version 24.0.x
PLAY RECAP
weather_vm : ok=X changed=Y failed=0
```

---

## 🐳 Step 6: Deploy Container to VM

Execute bash script on the VM to run Docker container:

```bash
$PUBLIC_IP = terraform output -raw public_ip_address

ssh -i ~/.ssh/id_rsa azureuser@$PUBLIC_IP << 'EOF'
  # Inside the VM
  sudo docker pull urk23cs1011/weather-app:latest
  sudo docker run -d -p 80:80 --name weather-app urk23cs1011/weather-app:latest
  sudo docker ps
EOF
```

---

## 🌐 Step 7: Access Your App

### Direct Access
```
http://$PUBLIC_IP
```

Example: `http://20.145.167.89`

### Test with curl
```bash
$PUBLIC_IP = terraform output -raw public_ip_address
curl http://$PUBLIC_IP
```

---

## 📊 Complete Automation Script

Save this as `deploy.ps1`:

```powershell
# Weather DevOps - Terraform + Ansible Deployment Script

Write-Host "🚀 Starting Weather App Deployment..." -ForegroundColor Green

# Step 1: Terraform
Write-Host "`n📦 Running Terraform..." -ForegroundColor Yellow
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Get Public IP
$PUBLIC_IP = terraform output -raw public_ip_address
Write-Host "✅ VM Created with IP: $PUBLIC_IP" -ForegroundColor Green

# Wait for VM to boot
Write-Host "`n⏳ Waiting for VM to boot..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Step 2: Test SSH
Write-Host "`n🔑 Testing SSH connection..." -ForegroundColor Yellow
ssh -i ~/.ssh/id_rsa azureuser@$PUBLIC_IP "echo 'SSH Working!'"

# Step 3: Create Inventory
Write-Host "`n📝 Creating Ansible inventory..." -ForegroundColor Yellow
$inventory = @"
[weather_servers]
weather_vm ansible_host=$PUBLIC_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa

[weather_servers:vars]
ansible_python_interpreter=/usr/bin/python3
"@
$inventory | Out-File -FilePath "ansible/inventory.ini" -Encoding UTF8

# Step 4: Run Ansible
Write-Host "`n⚙️ Running Ansible playbook..." -ForegroundColor Yellow
ansible-playbook -i ansible/inventory.ini ansible/setup.yml -v

# Step 5: Deploy App
Write-Host "`n🐳 Deploying Docker container..." -ForegroundColor Yellow
ssh -i ~/.ssh/id_rsa azureuser@$PUBLIC_IP << 'DOCKER'
  sudo docker pull urk23cs1011/weather-app:latest
  sudo docker run -d -p 80:80 --name weather-app urk23cs1011/weather-app:latest
  sudo docker ps
DOCKER

# Final Status
Write-Host "`n✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "🌐 Access your app at: http://$PUBLIC_IP" -ForegroundColor Green
```

**Run it:**
```bash
./deploy.ps1
```

---

## 🔄 Workflow Summary

```
1. Terraform init
   ↓
2. Terraform plan
   ↓
3. Terraform apply (Creates Azure VM)
   ↓
4. SSH test
   ↓
5. Create Ansible inventory
   ↓
6. Ansible playbook (Installs Docker)
   ↓
7. Deploy Docker container
   ↓
8. Access at public IP ✅
```

---

## 🧹 Cleanup (When Done)

**Destroy Azure resources:**
```bash
terraform destroy
```

**This will:**
- Delete VM
- Delete VNet
- Delete NSG
- Delete all other resources
- Stop Azure charges ✅

---

## ⚠️ Troubleshooting

### SSH Connection Refused
```bash
# Wait longer for VM to boot
Start-Sleep -Seconds 120

# Or check VM status
az vm get-instance-view -d --resource-group weather-rg --name weather-vm
```

### Ansible Hosts File Issues
```bash
# Check inventory syntax
ansible-inventory -i ansible/inventory.ini --list

# Test connectivity again
ansible all -i ansible/inventory.ini -m ping
```

### Docker Not Running
```bash
# SSH into VM and check logs
ssh -i ~/.ssh/id_rsa azureuser@$PUBLIC_IP
sudo docker logs weather-app
sudo journalctl -xe
```

### Public IP Not Accessible
```bash
# Check NSG rules
az network nsg rule list --resource-group weather-rg --nsg-name weather-nsg
```

---

## 📚 Files Involved

| File | Purpose |
|------|---------|
| `main.tf` | Terraform infrastructure |
| `ansible/setup.yml` | Docker installation playbook |
| `ansible/inventory.ini` | VM inventory (created during deploy) |
| `Dockerfile` | Container definition |
| `.github/workflows/ci-cd.yml` | GitHub Actions (separate pipeline) |

---

## ✨ Result

After following this guide, you'll have:

✅ Azure VM running on Azure  
✅ Docker installed via Ansible  
✅ Weather app container running  
✅ Accessible via public IP  
✅ Fully automated & repeatable  

---

**Ready to deploy? Start with Step 1! 🚀**
