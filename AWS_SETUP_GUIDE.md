# AWS & Terraform Setup Guide for GitHub Codespace

This guide walks you through setting up AWS credentials in your Codespace and deploying infrastructure with cost controls.

## Prerequisites

- ✅ Terraform v1.17.1 (already installed)
- AWS Account with credentials
- GitHub Codespace with terminal access

## Step 1: Get AWS Credentials

You need two things from AWS:
1. **AWS Access Key ID**
2. **AWS Secret Access Key**

### How to Create AWS Credentials

1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Click your username → **Security Credentials**
3. Under "Access Keys" → **Create New Access Key**
4. **Download** and save the CSV file (you'll only see the secret once!)
5. Keep this file safe - never commit it to GitHub

## Step 2: Configure AWS in Codespace

### Option A: Using AWS CLI Configuration (Recommended - Most Secure)

Run these commands in your Codespace terminal:

```bash
# Create AWS config directory
mkdir -p ~/.aws

# Create credentials file with your AWS keys
cat > ~/.aws/credentials << 'EOF'
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
EOF

# Set proper permissions (important for security!)
chmod 600 ~/.aws/credentials

# Create AWS config file for region
cat > ~/.aws/config << 'EOF'
[default]
region = us-west-2
output = json
EOF

# Verify connection
aws sts get-caller-identity
```

You should see output like:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

### Option B: Using Environment Variables

If you prefer environment variables (less secure, but works):

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-west-2"

# Verify
aws sts get-caller-identity
```

**⚠️ Warning**: Environment variables are visible in process lists and history. Don't use in production environments.

## Step 3: Test Terraform Connection

```bash
cd /workspaces/learning-terraform

# Initialize Terraform (downloads AWS provider)
terraform init

# Check what will be created
terraform plan

# You should see it will create:
# - aws_instance.web
# - aws_iam_role.web_role  
# - aws_iam_instance_profile.web_profile
```

## Step 4: Deploy to AWS

### Option A: Use the Automated Script (Recommended)

```bash
cd /workspaces/learning-terraform
./deploy-and-cleanup.sh
```

This script will:
1. ✅ Initialize Terraform
2. ✅ Show what will be created (plan)
3. ✅ Ask for confirmation
4. ✅ Deploy resources
5. ✅ Display outputs (Instance ID, Public IP)
6. ✅ Verify instance is running
7. ✅ Ask if you want to keep it or destroy (cost control!)

### Option B: Manual Deployment

```bash
# See what will be created
terraform plan

# Deploy it
terraform apply

# View outputs
terraform output

# Get specific values
terraform output instance_id
terraform output instance_public_ip
```

## Step 5: Verify It's Running

After deployment, you can:

### Check via AWS Console
1. Go to [EC2 Dashboard](https://console.aws.amazon.com/ec2/)
2. Look for instance named "HelloWorld"
3. Check if "Instance State" = "running"

### Check via CLI
```bash
# List instances
aws ec2 describe-instances --region us-west-2 \
  --filters "Name=tag:Name,Values=HelloWorld" \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]'
```

### SSH to Instance (if you have key pair)
```bash
# Note: You'll need the EC2 Key Pair for this
ssh -i /path/to/key.pem ec2-user@<public-ip>
```

## Step 6: Destroy Resources (Save Money! 💰)

**IMPORTANT**: Don't leave resources running - you'll be charged!

```bash
# See what will be deleted
terraform plan -destroy

# Delete everything
terraform destroy

# OR with auto-approval (no confirmation prompt)
terraform destroy -auto-approve
```

After destruction, you should see:
```
Destroy complete! Resources: 3 destroyed.
```

## Cost Management Tips

### Monitor Costs
```bash
# Check estimated costs before deploying
terraform plan

# The t3.nano instance is ~$0.0116/hour (very cheap!)
# But don't leave it running for months!
```

### Recommended Workflow
1. ✅ Deploy in the morning
2. ✅ Test and verify
3. ✅ Destroy before leaving
4. ✅ Repeat next day if needed

### Destroy Automation
You can set a cleanup schedule:

```bash
# Destroy with a reminder
read -p "Destroying in 5 seconds... (Ctrl+C to cancel)" && sleep 5 && terraform destroy -auto-approve
```

## Customize Deployment

### Use Different Instance Type
```bash
# Smaller/cheaper instances
terraform apply -var="instance_type=t3.micro"

# Larger instances
terraform apply -var="instance_type=t3.small"
```

### Add Tags for Cost Tracking
```bash
# Create terraform.tfvars
cat > terraform.tfvars << 'EOF'
instance_name = "HelloWorld"
environment   = "dev"
instance_type = "t3.nano"

additional_tags = {
  CostCenter = "Learning"
  Project    = "Terraform-Training"
  Owner      = "your-name"
}
EOF

terraform apply
```

### Use Different Region
Edit [providers.tf](/workspaces/learning-terraform/providers.tf):
```hcl
provider "aws" {
  region = "us-east-1"  # Change to desired region
}
```

## Troubleshooting

### "AWS credentials not found"
```bash
# Check if credentials are set
aws sts get-caller-identity

# If error, reconfigure:
mkdir -p ~/.aws
# Then follow "Option A" setup above
```

### "Error: error reading EC2 Instance"
- Instance might be starting up, wait 30 seconds
- Check security groups allow required access

### "terraform init fails"
```bash
# Clean and reinit
rm -rf .terraform/
terraform init
```

### Check Instance Status
```bash
# See if instance is running
aws ec2 describe-instances \
  --region us-west-2 \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,LaunchTime]' \
  --output table
```

## Files Reference

| File | Purpose |
|------|---------|
| [main.tf](/workspaces/learning-terraform/main.tf) | EC2 instance, IAM role, instance profile definitions |
| [variables.tf](/workspaces/learning-terraform/variables.tf) | Input variables (instance type, environment, tags, etc.) |
| [outputs.tf](/workspaces/learning-terraform/outputs.tf) | Output values (instance ID, public IP, ARN, etc.) |
| [providers.tf](/workspaces/learning-terraform/providers.tf) | AWS provider configuration |
| [terraform.tfvars.example](/workspaces/learning-terraform/terraform.tfvars.example) | Example variables file (copy to terraform.tfvars) |
| [deploy-and-cleanup.sh](/workspaces/learning-terraform/deploy-and-cleanup.sh) | Automated deploy/verify/cleanup script |

## Security Best Practices

### Protect Your Credentials
```bash
# Never commit credentials!
echo "terraform.tfvars" >> .gitignore
echo "~/.aws/credentials" >> ~/.gitignore
```

### Sensitive Outputs
```bash
# Outputs marked as sensitive won't show in logs
terraform output -json  # Still visible here
```

### IAM Best Practices
The configuration creates an IAM role for EC2. Never embed credentials in code!

## Next Steps

After you're comfortable with deploy/destroy:
1. 📚 Learn about **Modules** - Reuse configurations
2. 🔄 Explore **Remote State** - Team collaboration
3. 🏢 Create **Multiple Environments** - dev, staging, prod
4. 🧪 Try **Terraform Testing** - Validate configurations

## Quick Reference Commands

```bash
# Initialize working directory
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Show what will happen
terraform plan

# Apply changes
terraform apply

# Destroy all resources
terraform destroy

# View outputs
terraform output

# Get specific output
terraform output instance_public_ip

# View current state
terraform show

# Refresh state
terraform refresh

# Clean up local files
rm -rf .terraform/ terraform.tfstate* .terraform.lock.hcl
```

## Support

If you get stuck:
1. Run `terraform validate` to check for syntax errors
2. Check AWS console to see actual resource state
3. Review logs: `terraform plan` shows detailed messages
4. Read error messages carefully - they often tell you what's wrong!

Happy learning! 🚀
