# Talant Center - Infrastructure as Code

Infrastructure as Code (IaC) for GCP deployment using Terraform, with Docker-based application deployment.

## 🏗️ Architecture

- **Cloud Provider**: Google Cloud Platform (GCP)
- **VM**: e2-medium (2 vCPUs, 4 GB Memory)
- **OS**: Debian 12 (Bookworm)
- **Container Runtime**: Docker + Docker Compose

## 📁 Project Structure

```
.
├── terraform/                 # Infrastructure as Code
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Variable definitions
│   ├── outputs.tf            # Output definitions
│   ├── terraform.tfvars.example  # Example variables
│   └── scripts/
│       └── startup.sh        # VM startup script
├── docker/                    # Docker configurations
│   ├── docker-compose.yml    # Application stack
│   └── .env.example          # Environment variables
├── scripts/                   # Utility scripts
│   └── setup-vm.sh           # Manual VM setup script
├── docs/                      # Documentation
│   └── DEPLOYMENT.md         # Deployment guide
└── Makefile                   # Common commands
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- GCP Project with billing enabled

### 1. Authenticate with GCP

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Deploy Infrastructure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

### 3. Connect to VM

```bash
gcloud compute ssh talant-center-prod-vm --zone=<YOUR_ZONE>
```

### 4. Deploy Application

```bash
cd /opt/app
docker compose up -d
```

## 🔧 Configuration

### VM Specifications

| Property | Value |
|----------|-------|
| Name | talant-center-prod-vm |
| Machine Type | e2-medium |
| vCPUs | 2 |
| Memory | 4 GB |
| Boot Disk | 30 GB Balanced PD |
| Region/Zone | Configurable (see terraform.tfvars) |

### Firewall Rules

- **HTTP**: Port 80
- **HTTPS**: Port 443
- **SSH**: Port 22 (restrict in production!)
- **App Ports**: 8080, 3000 (configurable)

## 📚 Documentation

- [Deployment Guide](docs/DEPLOYMENT.md)

## 🔐 Security Notes

1. Restrict SSH access to specific IPs in production
2. Use static IP for production deployments
3. Store secrets in Secret Manager, not in code
4. Enable OS Login for better access control

## 📝 License

See [LICENSE](LICENSE) file.
