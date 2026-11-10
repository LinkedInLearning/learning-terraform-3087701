#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🚀 Terraform Deploy, Verify, and Cleanup Script"
echo "================================================"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Step 1: Initialize Terraform
log_info "Step 1: Initializing Terraform..."
terraform init
log_success "Terraform initialized"

# Step 2: Plan
log_info "Step 2: Planning deployment..."
terraform plan -out=tfplan
log_success "Plan created"

# Step 3: Ask for confirmation
log_warning "Review the plan above. Continue with deployment?"
read -p "Type 'yes' to deploy: " -r CONFIRM
if [[ ! $CONFIRM =~ ^[Yy][Ee][Ss]$ ]]; then
    log_error "Deployment cancelled"
    exit 1
fi

# Step 4: Apply
log_info "Step 3: Applying configuration..."
terraform apply tfplan
log_success "Infrastructure deployed"

# Step 5: Get outputs
log_info "Step 4: Getting infrastructure details..."
echo ""
terraform output
INSTANCE_ID=$(terraform output -raw instance_id 2>/dev/null || echo "unknown")
PUBLIC_IP=$(terraform output -raw instance_public_ip 2>/dev/null || echo "unknown")

echo ""
log_success "Deployment Complete!"
echo -e "${GREEN}Instance ID: $INSTANCE_ID${NC}"
echo -e "${GREEN}Public IP: $PUBLIC_IP${NC}"

# Step 6: Verification
log_info "Step 5: Verifying infrastructure is running..."
sleep 10  # Give AWS time to fully start the instance

if [ "$PUBLIC_IP" != "unknown" ] && [ "$PUBLIC_IP" != "" ]; then
    log_info "Attempting to reach instance at $PUBLIC_IP..."
    
    # Try to ping or curl (may fail if security group doesn't allow it)
    if timeout 5 bash -c "echo >/dev/tcp/$PUBLIC_IP/80" 2>/dev/null; then
        log_success "Instance is responding on port 80!"
    else
        log_warning "Could not reach instance on port 80 (may need security group adjustment)"
        log_info "Instance is running. SSH connection: ssh -i your-key-pair.pem ec2-user@$PUBLIC_IP"
    fi
else
    log_warning "Could not determine public IP"
fi

echo ""
read -p "Keep infrastructure running? (yes/no): " -r KEEP_RUNNING

if [[ ! $KEEP_RUNNING =~ ^[Yy][Ee][Ss]$ ]]; then
    log_warning "Step 6: Destroying infrastructure to save costs..."
    read -p "Type 'yes' to confirm destruction: " -r DESTROY_CONFIRM
    
    if [[ $DESTROY_CONFIRM =~ ^[Yy][Ee][Ss]$ ]]; then
        terraform destroy -auto-approve
        log_success "Infrastructure destroyed"
        rm -f tfplan
        log_success "Cleanup complete - costs minimized!"
    else
        log_warning "Destruction cancelled - remember to destroy later with: terraform destroy"
    fi
else
    log_info "Infrastructure will remain running"
    log_warning "Remember to run 'terraform destroy' when done to avoid charges"
fi

echo ""
log_success "Script completed!"
