# Kubernetes Deployment Guide

## Prerequisites
- Minikube installed and running
- kubectl configured
- Docker container image available

## Setup Instructions

### 1. Start Minikube Cluster
```bash
# Windows (WSL2)
minikube start --driver=docker --cpus=4 --memory=4096

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

### 2. Deploy Application
```bash
# Apply deployment (2 replicas)
kubectl apply -f deployment.yaml

# Verify deployment
kubectl get deployments
kubectl get pods
kubectl describe pod <pod-name>
```

### 3. Expose Service
```bash
# Apply service configuration
kubectl apply -f service.yaml

# Verify service
kubectl get svc
kubectl describe svc weather-service
```

### 4. Access Application
```bash
# Get service URL (Minikube)
minikube service weather-service

# Or manually find the IP and port
kubectl get svc weather-service
# Access: http://<CLUSTER-IP>:30007

# For local testing
kubectl port-forward svc/weather-service 8080:80
# Access: http://localhost:8080
```

## Deployment Configuration Details

### deployment.yaml
- **API Version**: apps/v1
- **Kind**: Deployment
- **Replicas**: 2 (High Availability)
- **Container Image**: urk23cs1011/weather-app:latest
- **Port**: 80 (HTTP)
- **Selector**: app=weather

### service.yaml
- **API Version**: v1
- **Kind**: Service
- **Type**: NodePort
- **Port**: 80 (service port)
- **TargetPort**: 80 (container port)
- **NodePort**: 30007 (external access port)

## Monitoring Commands

```bash
# Watch pod status
kubectl get pods --watch

# View logs
kubectl logs -f <pod-name>

# Check pod events
kubectl describe pod <pod-name>

# Get resource usage
kubectl top pods

# View service endpoints
kubectl get endpoints weather-service

# Test connectivity
kubectl exec -it <pod-name> -- curl localhost
```

## Scaling

```bash
# Scale up to 4 replicas
kubectl scale deployment weather-app --replicas=4

# Scale down to 1 replica
kubectl scale deployment weather-app --replicas=1

# Check current replicas
kubectl get deployment weather-app
```

## Cleanup

```bash
# Delete service
kubectl delete svc weather-service

# Delete deployment
kubectl delete deployment weather-app

# Delete all resources
kubectl delete -f deployment.yaml -f service.yaml

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Cannot pull image
```bash
# Ensure Docker credentials are configured
docker login
# Update image pull policy in deployment.yaml
```

### Service not accessible
```bash
# Check service is bound to pods
kubectl get endpoints weather-service

# Check NodePort
kubectl get svc weather-service

# Verify network policies
kubectl get networkpolicies
```

## Advanced Deployment Options

### Rolling Update
```bash
# Update image version
kubectl set image deployment/weather-app weather-container=urk23cs1011/weather-app:v2

# Check rollout status
kubectl rollout status deployment/weather-app

# Rollback if needed
kubectl rollout undo deployment/weather-app
```

### Helm Chart (Optional)
For production deployments, consider creating a Helm chart for easier package management.

---

**Status**: ✅ Configuration ready for deployment
