# eks-gitea-infra

Infrastructure as Code for deploying Gitea on Amazon EKS using Terraform.
Gitea is a self-hosted Git service deployed on a production-grade Kubernetes 
cluster with full CI/CD, Helm-based deployments, and observability.

## Architecture

- **Cloud:** AWS (eu-central-1)
- **Orchestration:** EKS (Kubernetes 1.35)
- **IaC:** Terraform 1.15 with S3 remote state
- **CI/CD:** GitHub Actions with OIDC authentication
- **App:** Gitea with RDS MySQL backend

## Stages

### ✅ Stage 1 — EKS Cluster & Networking
- VPC with public and private subnets across 2 availability zones
- NAT Gateways for private subnet outbound traffic
- EKS cluster with managed node group (t3.small × 2)
- OIDC provider configured for IRSA

### ✅ Stage 2 — Container Image & ECR
- ECR repository provisioned via Terraform
- Custom Dockerfile wrapping official Gitea image
- GitHub Actions pipeline to build and push image to ECR

### ✅ Stage 3 — Helm Deployment & ALB
- Helm chart for Gitea deployment
- RDS MySQL backend
- Secrets injected via AWS Parameter Store and IRSA
- App exposed publicly via AWS Load Balancer Controller

### ✅ Stage 4 — CI/CD Pipeline
- Full GitHub Actions pipeline on push to main
- Image vulnerability scanning with Trivy
- Automated Helm upgrade on EKS

### ✅ Stage 5 — Observability
- Prometheus and Grafana via kube-prometheus-stack
- Custom Grafana dashboard for cluster and app metrics
- AlertManager rules for critical alerts

### 🔄 Stage 6 — Load Testing & Auto-scaling Simulation
- Install Metrics Server for cluster resource metrics
- Configure Horizontal Pod Autoscaler (HPA) for Gitea deployment
- Load test simulation with k6 to validate auto-scaling and observability