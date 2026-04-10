# AKS Quick Reference - Common Commands

## 🔐 Authentication & Configuration

```bash
# Login to Azure
az login

# List all AKS clusters
az aks list

# Get AKS credentials (configure kubectl)
az aks get-credentials --resource-group weather-rg --name weather-aks

# Set default namespace
kubectl config set-context --current --namespace=default

# View current context
kubectl config current-context

# Switch context
kubectl config use-context weather-aks
```

---

## 📦 Cluster Information

```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Detailed node info
kubectl describe nodes

# Get node metrics
kubectl top nodes

# Get cluster version
kubectl version --short
```

---

## 🚀 Deployment Management

```bash
# Deploy app
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# View deployments
kubectl get deployments

# Detailed deployment info
kubectl describe deployment weather-app

# View rollout history
kubectl rollout history deployment/weather-app

# Rollback to previous version
kubectl rollout undo deployment/weather-app

# Check rollout status
kubectl rollout status deployment/weather-app

# Delete deployment
kubectl delete deployment weather-app
```

---

## 📦 Pod Management

```bash
# List all pods
kubectl get pods

# List pods with more details
kubectl get pods -o wide

# Watch pods (real-time)
kubectl get pods --watch

# Detailed pod info
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Follow pod logs (streaming)
kubectl logs -f <pod-name>

# View logs from all pods in deployment
kubectl logs -l app=weather --tail=50

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh

# Copy files from pod
kubectl cp <pod-name>:/path/to/file ./local/path

# Delete pod
kubectl delete pod <pod-name>
```

---

## 🌐 Service Management

```bash
# List services
kubectl get svc

# Get service details
kubectl describe svc weather-service

# Get external IP
kubectl get svc weather-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Port forward to local machine
kubectl port-forward svc/weather-service 8080:80

# Delete service
kubectl delete svc weather-service
```

---

## 📊 Monitoring & Metrics

```bash
# Get node metrics (requires metrics-server)
kubectl top nodes

# Get pod metrics
kubectl top pods

# Get resource usage per pod
kubectl get pods -o json | jq '.items[].spec.containers[]' | grep -i resource

# Get all events in cluster
kubectl get events

# Get events sorted by timestamp
kubectl get events --sort-by='.lastTimestamp'

# Monitor pod status
kubectl get pods --watch
```

---

## 🔧 Scaling & Updates

```bash
# Scale deployment replicas
kubectl scale deployment weather-app --replicas=5

# Check horizontal pod autoscaler
kubectl get hpa

# Create horizontal pod autoscaler
kubectl autoscale deployment weather-app --min=2 --max=5 --cpu-percent=80

# Update image
kubectl set image deployment/weather-app weather-container=urk23cs1011/weather-app:latest

# Set resource limits
kubectl set resources deployment weather-app -c weather-container --limits=cpu=500m,memory=512Mi --requests=cpu=250m,memory=256Mi

# View deployment strategy
kubectl describe deployment weather-app | grep -A 10 "Strategy:"
```

---

## 🔌 Network & Connectivity

```bash
# Get all network policies
kubectl get networkpolicies

# Test service connectivity
kubectl exec <pod-name> -- curl http://weather-service

# DNS test from pod
kubectl exec <pod-name> -- nslookup weather-service

# Check service endpoint
kubectl get endpoints weather-service

# Port forward to access service locally
kubectl port-forward svc/weather-service 8080:80
# Then access: http://localhost:8080
```

---

## 🔑 RBAC & Permissions

```bash
# Get current user/service account
kubectl auth can-i list pods

# Check if user can perform action
kubectl auth can-i get pods --as=system:serviceaccount:default:default

# Get service accounts
kubectl get serviceaccounts

# Get roles
kubectl get roles

# Get role bindings
kubectl get rolebindings
```

---

## 🗂️ Namespace Management

```bash
# Create namespace
kubectl create namespace production

# List namespaces
kubectl get namespaces

# Get resources in namespace
kubectl get pods -n production

# Set default namespace
kubectl config set-context --current --namespace=production

# Delete namespace
kubectl delete namespace production
```

---

## 🎯 ConfigMaps & Secrets

```bash
# Create config map
kubectl create configmap app-config --from-literal=key=value

# Get config maps
kubectl get configmaps

# View config map
kubectl describe configmap app-config

# Create secret
kubectl create secret generic app-secret --from-literal=password=mysecret

# Get secrets
kubectl get secrets

# View secret (base64 encoded)
kubectl get secret app-secret -o yaml
```

---

## 📋 Resource Quotas & Limits

```bash
# Create resource quota
kubectl create resourcequota compute-quota --hard=requests.cpu=10,requests.memory=20Gi --namespace=default

# View resource quotas
kubectl get resourcequotas

# View pod resource requests
kubectl describe pod <pod-name> | grep -A 5 "Limits\|Requests"
```

---

## 🚨 Debugging

```bash
# Describe pod for issues
kubectl describe pod <pod-name>

# Get pod events
kubectl get events --field-selector involvedObject.name=<pod-name>

# Check pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous crashed container

# Debug pod interactively
kubectl run debug --image=ubuntu --rm -it -- /bin/bash

# Check node connectivity
kubectl debug node/<node-name> -it --image=ubuntu
```

---

## 🗑️ Cleanup

```bash
# Delete all resources in current namespace
kubectl delete all --all

# Delete specific resource
kubectl delete deployment weather-app

# Delete using label selector
kubectl delete pods -l app=weather

# Delete all persistent volume claims
kubectl delete pvc --all

# Clean up completed jobs
kubectl delete job --field-selector status.successful=1
```

---

## 🔄 Azure CLI Integration

```bash
# Get AKS credentials
az aks get-credentials --resource-group weather-rg --name weather-aks

# Scale AKS cluster node pool
az aks nodepool scale --cluster-name weather-aks -g weather-rg -n nodepool1 --node-count 3

# Add new node pool
az aks nodepool add --cluster-name weather-aks -g weather-rg -n nodepool2 --node-count 2

# Check AKS cluster status
az aks show --resource-group weather-rg --name weather-aks

# Enable monitoring
az aks enable-addons --resource-group weather-rg --name weather-aks --addons monitoring

# Get AKS diagnostics
az aks diagnostics-logs --resource-group weather-rg --name weather-aks
```

---

## 🔗 Useful Aliases (Add to ~/.bashrc or ~/.zshrc)

```bash
# Add these to your shell profile
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'

# Source after adding
source ~/.bashrc  # or ~/.zshrc
```

---

## 📚 More Information

```bash
# Get help for any kubectl command
kubectl --help
kubectl get --help
kubectl apply --help

# Kubectl cheat sheet official
kubectl api-resources

# View API group versions
kubectl api-versions

# Get supported API resources
kubectl get api-resources
```
