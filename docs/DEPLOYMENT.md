# Deployment Guide

## Prerequisites

1. **Google Cloud SDK** installed and configured
2. **Terraform** >= 1.0.0 installed
3. **GCP Project** with billing enabled
4. **Service Account** with appropriate permissions

## Quick Start

### 1. Configure GCP Authentication

```bash
# Login to GCP
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 2. Initialize Terraform

```bash
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
# vim terraform.tfvars

# Initialize Terraform
terraform init
```

### 3. Deploy Infrastructure

```bash
# Preview changes
terraform plan

# Apply changes
terraform apply
```

### 4. Connect to VM

```bash
# Using gcloud (recommended)
gcloud compute ssh talant-center-prod-vm --zone=<YOUR_ZONE>

# Or using SSH key
ssh -i ~/.ssh/your-key user@EXTERNAL_IP
```

### 5. Setup VM (if not using startup script)

```bash
# On the VM, run the setup script
curl -sSL https://raw.githubusercontent.com/YOUR_REPO/main/scripts/setup-vm.sh | bash

# Or manually
./scripts/setup-vm.sh
```

### 6. Deploy Application

```bash
# Copy docker files to VM
gcloud compute scp --recurse ./docker/* talant-center-prod-vm:/opt/app/ --zone=<YOUR_ZONE>

# SSH into VM
gcloud compute ssh talant-center-prod-vm --zone=<YOUR_ZONE>

# Start services
cd /opt/app
docker compose up -d
```

## Directory Structure

```
/opt/app/
├── docker-compose.yml    # Main compose file
├── .env                  # Environment variables
├── data/                 # Persistent data
├── logs/                 # Application logs
├── backups/              # Backup files
└── configs/              # Configuration files
```

## Common Operations

### View Logs

```bash
docker compose logs -f
docker compose logs -f app
```

### Restart Services

```bash
docker compose restart
docker compose restart app
```

### Update Application

```bash
docker compose pull
docker compose up -d
```

### Backup Database

```bash
docker exec talant-db pg_dump -U app talant > /opt/app/backups/backup-$(date +%Y%m%d).sql
```

## Troubleshooting

### Docker Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
exit
```

### View Startup Script Logs

```bash
sudo cat /var/log/startup-script.log
```

### Check VM Serial Output

```bash
gcloud compute instances get-serial-port-output talant-center-prod-vm --zone=<YOUR_ZONE>
```

## Security Checklist

- [ ] Restrict SSH access to specific IPs
- [ ] Use static IP for production
- [ ] Enable OS Login
- [ ] Configure firewall rules properly
- [ ] Use secrets management for sensitive data
- [ ] Enable Cloud Armor (if using Load Balancer)
- [ ] Set up monitoring and alerting
