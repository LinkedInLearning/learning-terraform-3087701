# 🚀 Quick Start - Try These Commands NOW!

Copy and paste these into your Codespace terminal to see Terraform in action:

## Step 1: Validate (30 seconds)
```bash
cd /workspaces/learning-terraform
terraform validate
```
Expected output: ✅ **Success! The configuration is valid.**

---

## Step 2: Plan (1 minute)
```bash
terraform plan
```
See what WOULD be created (without AWS credentials needed!)

Look for:
- `Plan: 3 to add, 0 to change, 0 to destroy.`
- Shows: EC2 instance + IAM role + instance profile

---

## Step 3: Console - Interactive Mode (2 minutes)
```bash
terraform console
```

Try these one by one (copy/paste):
```hcl
var.instance_type

var.environment

"${var.instance_name}-${var.environment}"

contains(["dev", "staging", "prod"], var.environment)

var.enable_monitoring ? "Monitoring ON" : "Monitoring OFF"

merge(var.additional_tags, {"Team" = "DevOps"})

[for tag in keys(var.additional_tags) : upper(tag)]
```

Exit: Press `Ctrl+D`

---

## Step 4: Try Variables (2 minutes)
```bash
# See plan with different settings
terraform plan -var="environment=prod"
terraform plan -var="instance_type=t3.small"
terraform plan -var="enable_monitoring=true"
```

Notice how the output changes!

---

## Step 5: Explore Configuration (2 minutes)
```bash
# View the resources
cat main.tf

# View the variables
cat variables.tf

# View the outputs
cat outputs.tf
```

---

## Step 6: Advanced - Copy Exercise
Try to create a new variable by copying this pattern:

```bash
# Edit variables.tf
nano variables.tf

# Add this new variable at the end:
variable "instance_root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.instance_root_volume_size >= 8 && var.instance_root_volume_size <= 1000
    error_message = "Volume size must be between 8 and 1000 GB"
  }
}

# Save: Ctrl+O, Enter, Ctrl+X

# Validate
terraform validate

# Test it
terraform plan -var="instance_root_volume_size=100"
```

---

## 🎯 What You Learned

✅ Terraform validates code without AWS  
✅ terraform console lets you test expressions  
✅ Variables make configurations flexible  
✅ terraform plan shows what would happen  
✅ You can override defaults on command line  

---

## 📚 Next: Pick One

**Option A: Learn More Terraform Functions**
- Read [CODESPACE_LEARNING.md](/workspaces/learning-terraform/CODESPACE_LEARNING.md)
- Try exercises 1-10

**Option B: Create Environment Files**
```bash
# Create dev environment config
cp terraform.tfvars.example dev.tfvars

# Create prod environment config
cp terraform.tfvars.example prod.tfvars

# Modify them
nano dev.tfvars
nano prod.tfvars

# Test both
terraform plan -var-file="dev.tfvars"
terraform plan -var-file="prod.tfvars"
```

**Option C: Create a New Module**
```bash
mkdir modules/web_server
cd modules/web_server
touch main.tf variables.tf outputs.tf
# Create a reusable module!
```

**Option D: Explore the Registry**
- Visit https://registry.terraform.io/
- Search for providers: aws, google, azurerm
- Browse resource examples

---

## 💡 Remember

You can do ALL of this without AWS! No credentials needed.
When you're ready to deploy, you'll have:
1. AWS account + credentials
2. Run: `terraform apply`
3. Destroy after: `terraform destroy`

**Happy Learning!** 🎉
