# Terraform Learning Path - Hands-On Exercises

Complete these exercises in your Codespace terminal to master Terraform!

## Exercise 1: Explore Your Configuration

### Task 1.1: View Configuration Files
Run these commands in your terminal:

```bash
cd /workspaces/learning-terraform

# See what files we have
ls -la

# View the main configuration
cat main.tf

# View variables
cat variables.tf

# View outputs
cat outputs.tf

# View providers
cat providers.tf
```

### Task 1.2: Validate Syntax
```bash
# Check for syntax errors
terraform validate

# Format code (auto-fixes formatting)
terraform fmt

# Check formatting was correct
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

---

## Exercise 2: Understand Variables

### Task 2.1: View Available Variables
```bash
# This shows all variables defined
terraform console

# Inside the console, type:
# var.instance_type
# var.environment
# var.enable_monitoring
# var.additional_tags
# (Press Ctrl+D to exit)
```

### Task 2.2: Override Variables from Command Line
```bash
# Plan with different instance type
terraform plan -var="instance_type=t3.micro"

# Plan with different environment
terraform plan -var="environment=prod"

# Plan with multiple variables
terraform plan \
  -var="instance_type=t3.small" \
  -var="environment=staging" \
  -var="enable_monitoring=true"
```

### Task 2.3: Create a tfvars File
```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# View it
cat terraform.tfvars

# Edit it (you can use nano or vim)
# nano terraform.tfvars
```

---

## Exercise 3: Plan Your Infrastructure

### Task 3.1: See What Will Be Created
```bash
# Basic plan (no variables)
terraform plan

# This will show:
# - aws_instance.web (EC2 instance)
# - aws_iam_role.web_role (IAM role)
# - aws_iam_instance_profile.web_profile (instance profile)
```

### Task 3.2: Save Plan to File
```bash
# Create a plan file
terraform plan -out=my-plan.tfplan

# View the saved plan
terraform show my-plan.tfplan
```

### Task 3.3: Understand Plan Output
Look for these sections in the plan:
- **# aws_instance.web will be created** - New EC2 instance
- **# aws_iam_role.web_role will be created** - New IAM role
- **# aws_iam_instance_profile.web_profile will be created** - New instance profile

Each resource shows:
- `+` = will be created
- `-` = will be deleted
- `~` = will be modified
- `-/+` = will be replaced

---

## Exercise 4: Inspect Data Sources

### Task 4.1: Understand the AMI Data Source
```bash
# View the data source in main.tf
grep -A 10 "data \"aws_ami\"" main.tf

# This queries AWS for the latest Bitnami Tomcat AMI
# It filters by:
# - name pattern: bitnami-tomcat-*-x86_64-hvm-ebs-nami
# - virtualization type: hvm
# - owner: 979382823631 (Bitnami's AWS account)
```

### Task 4.2: Reference Data Source in Console
```bash
terraform console

# Inside console, type:
# data.aws_ami.app_ami.id
# data.aws_ami.app_ami.name
# data.aws_ami.app_ami.arn
# (Exit with Ctrl+D)
```

---

## Exercise 5: Understand Outputs

### Task 5.1: Check Output Definitions
```bash
# View all outputs
cat outputs.tf

# Count outputs
grep "^output" outputs.tf | wc -l
```

### Task 5.2: Test Output Formatting
```bash
# These will fail without deployed resources, but show syntax:
terraform validate outputs.tf

# View which outputs reference which resources:
grep "aws_instance.web" outputs.tf
grep "aws_iam_role.web_role" outputs.tf
```

---

## Exercise 6: State Management (Conceptual)

### Task 6.1: Understand Terraform State
```bash
# Check if state file exists
ls -la terraform.tfstate* 2>/dev/null || echo "No state files yet (expected - nothing deployed)"

# Terraform tracks state in:
# 1. terraform.tfstate (local)
# 2. .terraform/terraform.tfstate (in working directory)
# 3. Remote (S3, Terraform Cloud, etc.)

# View current state (empty before deployment)
terraform show
```

### Task 6.2: State File Format
```bash
# State files are JSON (but shouldn't be edited manually)
cat terraform.tfstate 2>/dev/null || echo "State file not found (expected)"

# Key rules:
# - NEVER edit terraform.tfstate directly
# - NEVER commit it to Git
# - ALWAYS back it up
# - Use 'terraform' commands to modify state
```

---

## Exercise 7: Interactive Commands

### Task 7.1: Terraform Console
```bash
# Interactive Terraform evaluator
terraform console

# Try these expressions:
# var.instance_type
# var.environment
# "${var.instance_name}-${var.environment}"
# merge(var.additional_tags, {"New" = "Tag"})

# Exit with Ctrl+D
```

### Task 7.2: Terraform Fmt
```bash
# Auto-format all .tf files
terraform fmt -recursive

# Check what would change
terraform fmt -check -recursive

# Format with specific style
terraform fmt -list
```

### Task 7.3: Terraform Graph
```bash
# Show resource dependency graph
terraform graph

# Save as image (optional - requires Graphviz)
terraform graph | dot -Tsvg > graph.svg
```

---

## Exercise 8: Variable Validation Practice

### Task 8.1: Test Valid Values
```bash
# This should work (valid environment)
terraform plan -var="environment=dev"
terraform plan -var="environment=staging"
terraform plan -var="environment=prod"

# This should FAIL (invalid environment)
terraform plan -var="environment=invalid"
```

### Task 8.2: Test Different Instance Types
```bash
# These should all work
terraform plan -var="instance_type=t3.nano"
terraform plan -var="instance_type=t3.micro"
terraform plan -var="instance_type=t3.small"
```

### Task 8.3: Test Boolean Variable
```bash
# Enable monitoring
terraform plan -var="enable_monitoring=true"

# Disable monitoring (default)
terraform plan -var="enable_monitoring=false"
```

---

## Exercise 9: Debugging & Troubleshooting

### Task 9.1: Enable Debug Logging
```bash
# Run terraform with debug enabled
TF_LOG=DEBUG terraform plan

# Different log levels:
# TF_LOG=TRACE - Most verbose
# TF_LOG=DEBUG - Detailed debugging
# TF_LOG=INFO - General info
# TF_LOG=WARN - Warnings only
# TF_LOG=ERROR - Errors only
```

### Task 9.2: Validate Configuration
```bash
# Check syntax
terraform validate

# Check formatting
terraform fmt -check

# Check against schema
terraform validate -json
```

### Task 9.3: Common Issues
```bash
# If you see "Error: Missing provider" - run:
terraform init

# If you see "Invalid value" - check variables:
terraform plan -var-file="nonexistent.tfvars"  # This will fail

# If you see "Resource does not support" - check attribute names:
grep "instance_type" main.tf
```

---

## Exercise 10: Advanced Concepts

### Task 10.1: Resource Meta-Arguments
```bash
# View depends_on in configuration
grep -A 2 "depends_on" main.tf

# View merge function for tags
grep -A 5 "merge(" main.tf

# View jsonencode for policy
grep -A 10 "jsonencode" main.tf
```

### Task 10.2: Interpolation & Functions
```bash
terraform console

# Try these:
# join("-", ["app", var.environment, "instance"])
# contains(["dev", "staging", "prod"], var.environment)
# upper(var.instance_name)
# lower(var.environment)
# startswith(var.instance_name, "Hello")

# Exit with Ctrl+D
```

### Task 10.3: For Expressions
```bash
terraform console

# Try these:
# [for tag, value in var.additional_tags : "${tag}=${value}"]
# { for k, v in var.additional_tags : k => upper(v) }

# Exit with Ctrl+D
```

---

## Quick Reference

### Essential Commands
```bash
terraform init      # Initialize directory
terraform validate  # Check syntax
terraform fmt      # Format code
terraform plan     # Preview changes
terraform apply    # Apply changes
terraform destroy  # Delete resources
terraform show     # Show state
terraform console  # Interactive eval
terraform output   # Show outputs
terraform refresh  # Update state
terraform import   # Import existing resource
```

### Common Patterns
```bash
# Plan with variables
terraform plan -var="key=value"

# Plan from file
terraform plan -var-file="prod.tfvars"

# Apply without confirmation
terraform apply -auto-approve

# Destroy without confirmation
terraform destroy -auto-approve

# Save plan for later
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

### Directory Structure
```
learning-terraform/
├── main.tf                          # Main resource definitions
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
├── providers.tf                     # Provider configuration
├── terraform.tfvars.example         # Example variables file
├── .terraform/                      # Provider plugins (auto-created)
├── terraform.tfstate                # Local state (auto-created)
├── terraform.tfstate.backup         # State backup (auto-created)
├── .terraform.lock.hcl              # Dependency lock file (auto-created)
└── .gitignore                       # Git ignore file
```

---

## Next Steps

After completing these exercises:

1. **Add AWS Credentials** when ready:
   - Follow AWS_SETUP_GUIDE.md
   - Run `terraform apply` to deploy

2. **Modules** - Organize reusable infrastructure:
   - Create a modules/ directory
   - Refactor configuration into modules
   - Call modules from main configuration

3. **Remote State** - Team collaboration:
   - Store state in S3
   - Use Terraform Cloud
   - Enable locking for team workflows

4. **Testing** - Validate configurations:
   - Learn Terraform Test language
   - Create test cases
   - Automated validation

5. **CI/CD** - Automate deployments:
   - GitHub Actions + Terraform
   - Plan on PR, apply on merge
   - Automated testing in pipeline

---

## Pro Tips

✅ **DO:**
- Use version constraints in providers
- Name resources meaningfully
- Use descriptive variable names
- Document with comments
- Use consistent formatting
- Store sensitive data securely

❌ **DON'T:**
- Commit terraform.tfstate to Git
- Store credentials in code
- Use hardcoded values (use variables!)
- Edit .tfstate files manually
- Use * versions for providers
- Deploy without reviewing plan

---

## Getting Help

```bash
# Help for any command
terraform -help
terraform plan -help
terraform apply -help

# Terraform documentation
# https://www.terraform.io/docs/

# AWS Provider documentation
# https://registry.terraform.io/providers/hashicorp/aws/latest

# Terraform Registry
# https://registry.terraform.io/
```
