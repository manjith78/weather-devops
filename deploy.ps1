# Weather DevOps - Terraform + Ansible Automated Deployment (PowerShell)
# This script automates the entire deployment process on Windows

Write-Host "╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🚀 WEATHER APP - TERRAFORM + ANSIBLE DEPLOYMENT SCRIPT 🚀             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Function to show step
function Show-Step {
    param([string]$Title)
    Write-Host "`n[STEP] $Title" -ForegroundColor Blue
}

# Function to show success
function Show-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

# Function to show warning
function Show-Warning {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

# Step 1: Prerequisites Check
Show-Step "Checking Prerequisites"
Write-Host "Checking Terraform..." -NoNewline
$terraformExists = & { terraform version 2>&1 } -and $?
if ($terraformExists) { Show-Success "Terraform found" } else { Write-Host "❌ Not found"; exit 1 }

Write-Host "Checking Ansible..." -NoNewline
$ansibleExists = & { ansible --version 2>&1 } -and $?
if ($ansibleExists) { Show-Success "Ansible found" } else { Write-Host "❌ Not found"; exit 1 }

Write-Host "Checking Azure CLI..." -NoNewline
$azExists = & { az account show 2>&1 } -and $?
if ($azExists) { Show-Success "Azure CLI logged in" } else { Write-Host "❌ Not logged in"; exit 1 }

Write-Host "Checking SSH key..." -NoNewline
$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
if (Test-Path $sshKeyPath) {
    Show-Success "SSH key found at $sshKeyPath"
} else {
    Show-Warning "SSH key not found at $sshKeyPath"
    Write-Host "Run this to generate: ssh-keygen -t rsa -b 4096 -f $sshKeyPath" -ForegroundColor Yellow
    exit 1
}

# Step 2: Terraform Init
Show-Step "Initializing Terraform"
terraform init
Show-Success "Terraform initialized"

# Step 3: Terraform Plan
Show-Step "Planning Terraform deployment"
terraform plan -out=tfplan
Show-Success "Terraform plan created"

# Step 4: Terraform Apply
Show-Step "Applying Terraform (Creating Azure Resources)"
Write-Host "⏳ This may take 5-10 minutes..." -ForegroundColor Yellow
terraform apply tfplan
Show-Success "Azure resources created"

# Get Public IP
$PUBLIC_IP = terraform output -raw public_ip_address
Write-Host "✅ VM Public IP: $PUBLIC_IP" -ForegroundColor Green

# Step 5: Wait for VM and SSH Test
Show-Step "Waiting for VM to boot and testing SSH"
Write-Host "⏳ Waiting 60 seconds for VM to fully boot..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

$sshConnected = $false
for ($i = 1; $i -le 10; $i++) {
    Write-Host "⏳ Attempt $i/10: Testing SSH connection..." -ForegroundColor Yellow
    $sshOutput = & { ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i $sshKeyPath azureuser@$PUBLIC_IP "echo 'SSH Connected'" 2>&1 }
    if ($LASTEXITCODE -eq 0) {
        Show-Success "SSH connection successful"
        $sshConnected = $true
        break
    }
    Start-Sleep -Seconds 10
}

if (-not $sshConnected) {
    Write-Host "❌ SSH connection failed" -ForegroundColor Red
    exit 1
}

# Step 6: Create Ansible Inventory
Show-Step "Creating Ansible inventory"
$inventoryContent = @"
[weather_servers]
weather_vm ansible_host=$PUBLIC_IP ansible_user=azureuser ansible_ssh_private_key_file=$sshKeyPath

[weather_servers:vars]
ansible_python_interpreter=/usr/bin/python3
"@

$inventoryContent | Out-File -FilePath "ansible/inventory.ini" -Encoding UTF8 -NoNewline
Show-Success "Ansible inventory created at ansible/inventory.ini"

# Test Ansible connectivity
Write-Host "Testing Ansible connectivity..." -ForegroundColor Yellow
& { ansible all -i ansible/inventory.ini -m ping 2>&1 }

# Step 7: Run Ansible Playbook
Show-Step "Running Ansible playbook (Installing Docker)"
& { ansible-playbook -i ansible/inventory.ini ansible/setup.yml -v 2>&1 }
Show-Success "Docker installed and configured"

# Deploy App
Show-Step "Deploying Weather App Container"
$dockerScript = @"
echo "🐳 Pulling Docker image..."
sudo docker pull urk23cs1011/weather-app:latest
echo "🚀 Starting container..."
sudo docker run -d -p 80:80 --name weather-app --restart always urk23cs1011/weather-app:latest
echo "✅ Container running"
sudo docker ps
"@

& { ssh -i $sshKeyPath azureuser@$PUBLIC_IP $dockerScript 2>&1 }

# Success Message
Write-Host "`n$(for($i=0;$i -lt 79;$i++){Write-Host '═' -NoNewline})" -ForegroundColor Green
Write-Host "✅ DEPLOYMENT SUCCESSFUL! ✅" -ForegroundColor Green -Foreground Black
Write-Host "$(for($i=0;$i -lt 79;$i++){Write-Host '═' -NoNewline})" -ForegroundColor Green

Write-Host "`n🌐 Access your app at:" -ForegroundColor Green
Write-Host "   http://$PUBLIC_IP" -ForegroundColor Yellow

Write-Host "`n📊 Deployment Summary:" -ForegroundColor Green
Write-Host "   ✅ Azure infrastructure created" -ForegroundColor Green
Write-Host "   ✅ Docker installed via Ansible" -ForegroundColor Green
Write-Host "   ✅ Weather app running" -ForegroundColor Green
Write-Host "   ✅ Public IP: $PUBLIC_IP" -ForegroundColor Green

Write-Host "`n🧹 To cleanup later, run:" -ForegroundColor Green
Write-Host "   terraform destroy" -ForegroundColor Yellow

Write-Host "`n📝 Inventory file created at: ansible/inventory.ini" -ForegroundColor Green
Write-Host "`n🎉 Ready to revolutionize your infrastructure!" -ForegroundColor Cyan
