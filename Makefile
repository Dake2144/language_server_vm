# =============================================================================
# Makefile - Common Commands
# =============================================================================

.PHONY: help init plan apply destroy ssh docker-up docker-down docker-logs

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "  Terraform:"
	@echo "    make init      - Initialize Terraform"
	@echo "    make plan      - Preview infrastructure changes"
	@echo "    make apply     - Apply infrastructure changes"
	@echo "    make destroy   - Destroy infrastructure"
	@echo ""
	@echo "  Docker:"
	@echo "    make docker-up    - Start Docker containers"
	@echo "    make docker-down  - Stop Docker containers"
	@echo "    make docker-logs  - View Docker logs"
	@echo ""
	@echo "  VM:"
	@echo "    make ssh       - SSH into the VM"
	@echo ""

# -----------------------------------------------------------------------------
# Terraform Commands
# -----------------------------------------------------------------------------
init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan

apply:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy

# Validate Terraform configuration
validate:
	cd terraform && terraform validate

# Format Terraform files
fmt:
	cd terraform && terraform fmt -recursive

# -----------------------------------------------------------------------------
# Docker Commands (run on VM)
# -----------------------------------------------------------------------------
docker-up:
	cd docker && docker compose up -d

docker-down:
	cd docker && docker compose down

docker-logs:
	cd docker && docker compose logs -f

docker-ps:
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# -----------------------------------------------------------------------------
# VM Commands
# -----------------------------------------------------------------------------
ssh:
	@echo "Run: gcloud compute ssh talant-center-prod-vm --zone=<YOUR_ZONE>"

# Copy files to VM
deploy:
	gcloud compute scp --recurse ./docker/* talant-center-prod-vm:/opt/app/ --zone=<YOUR_ZONE>
