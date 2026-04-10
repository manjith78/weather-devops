#!/bin/bash
# Weather DevOps - Terraform + Ansible Automated Deployment
# This script automates the entire deployment process

set -e  # Exit on error

echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║     🚀 WEATHER APP - TERRAFORM + ANSIBLE DEPLOYMENT SCRIPT 🚀             ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Prerequisites Check
echo -e "\n${BLUE}[1/7] Checking Prerequisites...${NC}"
echo "Checking Terraform..."
terraform version > /dev/null || { echo "❌ Terraform not installed"; exit 1; }
echo "✅ Terraform found"

echo "Checking Ansible..."
ansible --version > /dev/null || { echo "❌ Ansible not installed"; exit 1; }
echo "✅ Ansible found"

echo "Checking Azure CLI..."
az account show > /dev/null || { echo "❌ Azure CLI not configured"; exit 1; }
echo "✅ Azure CLI logged in"

echo "Checking SSH key..."
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "⚠️ SSH key not found. Please run:"
    echo "ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa"
    exit 1
fi
echo "✅ SSH key found"

# Step 2: Terraform Init
echo -e "\n${BLUE}[2/7] Initializing Terraform...${NC}"
terraform init
echo "✅ Terraform initialized"

# Step 3: Terraform Plan
echo -e "\n${BLUE}[3/7] Planning Terraform deployment...${NC}"
terraform plan -out=tfplan
echo "✅ Terraform plan created"

# Step 4: Terraform Apply
echo -e "\n${BLUE}[4/7] Applying Terraform (Creating Azure Resources)...${NC}"
echo "⏳ This may take 5-10 minutes..."
terraform apply tfplan
echo "✅ Azure resources created"

# Get Public IP
PUBLIC_IP=$(terraform output -raw public_ip_address)
echo -e "${GREEN}✅ VM Public IP: $PUBLIC_IP${NC}"

# Step 5: Wait for VM and SSH Test
echo -e "\n${BLUE}[5/7] Waiting for VM to boot and testing SSH...${NC}"
echo "⏳ Waiting 90 seconds for VM to fully boot..."
sleep 90

for i in {1..10}; do
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa azureuser@$PUBLIC_IP "echo 'SSH Connected'" 2>/dev/null; then
        echo "✅ SSH connection successful"
        break
    else
        echo "⏳ Attempt $i/10: Waiting for SSH..."
        sleep 10
    fi
done

# Step 6: Create Ansible Inventory
echo -e "\n${BLUE}[6/7] Creating Ansible inventory...${NC}"
cat > ansible/inventory.ini << EOF
[weather_servers]
weather_vm ansible_host=$PUBLIC_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa

[weather_servers:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
echo "✅ Ansible inventory created"

# Test Ansible connectivity
echo "Testing Ansible connectivity..."
ansible all -i ansible/inventory.ini -m ping

# Step 7: Run Ansible Playbook
echo -e "\n${BLUE}[7/7] Running Ansible playbook (Installing Docker)...${NC}"
ansible-playbook -i ansible/inventory.ini ansible/setup.yml -v
echo "✅ Docker installed and configured"

# Deploy App
echo -e "\n${BLUE}[Bonus] Deploying Weather App Container...${NC}"
ssh -i ~/.ssh/id_rsa azureuser@$PUBLIC_IP << 'DOCKER'
echo "🐳 Pulling Docker image..."
sudo docker pull urk23cs1011/weather-app:latest
echo "🚀 Starting container..."
sudo docker run -d -p 80:80 --name weather-app --restart always urk23cs1011/weather-app:latest
echo "✅ Container running"
sudo docker ps
DOCKER

# Success!
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                   ✅ DEPLOYMENT SUCCESSFUL! ✅                             ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Access your app at:${NC}"
echo -e "${YELLOW}   http://$PUBLIC_IP${NC}"
echo ""
echo -e "${GREEN}📊 Deployment Summary:${NC}"
echo "   ✅ Azure infrastructure created"
echo "   ✅ Docker installed via Ansible"
echo "   ✅ Weather app running"
echo "   ✅ Public IP: $PUBLIC_IP"
echo ""
echo -e "${GREEN}🧹 To cleanup later, run:${NC}"
echo "   terraform destroy"
echo ""
