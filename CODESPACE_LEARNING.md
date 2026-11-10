# Terraform Learning in Codespace - No AWS Required!

Perfect! You can learn tons of Terraform in Codespace without AWS credentials. Here's what we'll do:

## 1. Practice with terraform console (Interactive Mode)

This is the best way to learn Terraform functions and expressions!

### Start the Console
```bash
cd /workspaces/learning-terraform
terraform console
```

### Try These Commands

**1.1 - Variables**
```hcl
# View variable values
var.instance_type
var.environment
var.enable_monitoring
var.additional_tags

# Output should show their defaults
```

**1.2 - String Interpolation**
```hcl
# Build strings
"${var.instance_name}-${var.environment}"
"Instance: ${var.instance_name} in ${var.environment}"
```

**1.3 - String Functions**
```hcl
upper(var.environment)
lower(var.instance_name)
startswith(var.instance_name, "Hello")
endswith(var.instance_name, "World")
length(var.instance_name)
substr(var.instance_name, 0, 5)
```

**1.4 - List Functions**
```hcl
# Create lists
["dev", "staging", "prod"]

# List functions
contains(["dev", "staging", "prod"], "dev")
contains(["dev", "staging", "prod"], "test")
length(["dev", "staging", "prod"])
join(",", ["dev", "staging", "prod"])
split(",", "dev,staging,prod")
```

**1.5 - Map Functions**
```hcl
# View tags
var.additional_tags

# Map functions
merge(var.additional_tags, {"NewTag" = "NewValue"})
keys(var.additional_tags)
values(var.additional_tags)
```

**1.6 - Type Conversions**
```hcl
tostring(123)
tonumber("456")
try(tonumber("abc"), 0)  # Returns 0 on error
```

**1.7 - Math Operations**
```hcl
1 + 2
10 * 5
20 / 4
23 % 5
max(1, 5, 3)
min(1, 5, 3)
```

**1.8 - Conditional Logic**
```hcl
# Ternary operator
var.enable_monitoring ? "enabled" : "disabled"
contains(["prod"], var.environment) ? "production" : "non-production"
```

**1.9 - For Expressions**
```hcl
# For with lists
[for tag in keys(var.additional_tags) : upper(tag)]

# For with maps
{for k, v in var.additional_tags : k => upper(v)}

# For with filtering
[for env in ["dev", "staging", "prod"] : env if env != "dev"]
```

**Exit console**: Press `Ctrl+D`

---

## 2. Practice terraform plan

Learn how Terraform plans changes without making them!

```bash
# Basic plan
terraform plan

# Plan with different variables
terraform plan -var="instance_type=t3.small"
terraform plan -var="environment=prod"
terraform plan -var="enable_monitoring=true"

# Save plan (but don't apply)
terraform plan -out=example.tfplan

# View saved plan
terraform show example.tfplan

# Human-readable plan format
terraform plan -out=plan.tfplan
terraform show -no-color plan.tfplan | less
```

---

## 3. Create Multiple Example Configurations

Let's create different Terraform configurations to explore:

### Create a Local Example
```bash
cd /workspaces/learning-terraform

# Create examples directory
mkdir -p examples/local-development
mkdir -p examples/staging
mkdir -p examples/production
```

Then we can create different variable files for each environment...

---

## 4. Learn Terraform Language Features

No deployment needed - just pure Terraform learning!

### 4.1 Create a Practice File
```bash
# Create a learning file (won't be executed)
cat > /workspaces/learning-terraform/learn.tf << 'EOF'
# LOCAL VARIABLES (computed values)
locals {
  # Build a server name dynamically
  server_name = "${var.instance_name}-${var.environment}-${data.aws_ami.app_ami.id}"
  
  # Build tags dynamically
  common_tags = merge(
    var.additional_tags,
    {
      Name        = var.instance_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
  
  # Conditionally set values
  monitoring_enabled = var.environment == "prod" ? true : var.enable_monitoring
  
  # Map-based lookup
  instance_types = {
    dev     = "t3.nano"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

# Note: This is just for learning - won't actually create resources
EOF

cat /workspaces/learning-terraform/learn.tf
```

### 4.2 Study It
```bash
# Understand locals
grep -A 20 "locals {" learn.tf

# These show:
# - String interpolation
# - merge() function
# - Conditional ternary operator
# - Nested maps
```

---

## 5. Explore Terraform Registry

Practice looking up resources (no execution):

```bash
# Learn about available AWS resources
echo "Visit: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance"

# Some common resources to explore:
# - aws_instance (EC2)
# - aws_s3_bucket (S3)
# - aws_lambda_function (Lambda)
# - aws_rds_instance (RDS)
# - aws_dynamodb_table (DynamoDB)
# - aws_iam_role (IAM)
# - aws_security_group (Security)
# - aws_vpc (Networking)
```

---

## 6. Practice Exercises (Codespace Only)

### Exercise 1: String Building
```bash
terraform console
# Try to build these strings:
# "app-dev-instance"
# "PRODUCTION"
# "Config: dev=true, staging=false"
# Exit with Ctrl+D
```

### Exercise 2: List Operations
```bash
terraform console
# Create lists and practice:
# [for x in range(1,6) : x * 2]  # Output: [2, 4, 6, 8, 10]
# [for env in ["a", "b", "c"] : upper(env)]
# Exit with Ctrl+D
```

### Exercise 3: Conditional Logic
```bash
terraform console
# Practice conditionals:
var.environment == "prod" ? "Production" : "Development"
contains(["dev", "staging"], var.environment) ? "Non-Prod" : "Prod"
# Exit with Ctrl+D
```

### Exercise 4: Map Transformations
```bash
terraform console
# Transform maps:
{ for k, v in var.additional_tags : k => upper(v) }
{ for k, v in var.additional_tags : upper(k) => v }
# Exit with Ctrl+D
```

### Exercise 5: Validation Rules
```bash
# Look at validation in variables.tf
cat variables.tf | grep -A 5 "validation"

# Try to understand:
# - contains() - checks if value is in list
# - can() - checks if expression is valid
# - regex() - pattern matching
```

---

## 7. Understand State (Conceptually)

Even without AWS, you can learn state concepts:

```bash
# View current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web  # (will be empty until deployed)

# State commands available
terraform state -help
```

---

## 8. Debugging & Learning Tools

```bash
# Terraform version and info
terraform version

# Show current working directory
pwd

# List all .tf files
ls *.tf

# View specific resource schema
grep "resource \"aws_instance\"" -A 50 main.tf

# Validate your configuration
terraform validate

# Format check
terraform fmt -check

# Get provider docs (online)
# https://registry.terraform.io/providers/hashicorp/aws/latest
```

---

## 9. Create a Learning Checklist

Try these in order (they all work in Codespace):

- [ ] Run `terraform console` and explore var.instance_type
- [ ] Build a string using interpolation: `"${var.name}-${var.environment}"`
- [ ] Use a list function: `contains(["dev", "staging", "prod"], var.environment)`
- [ ] Use a map function: `merge(var.tags, {"New" = "Tag"})`
- [ ] Run `terraform plan` and read the output
- [ ] Use a ternary operator: `var.enable_monitoring ? "yes" : "no"`
- [ ] Create a for expression: `[for tag in keys(var.tags) : upper(tag)]`
- [ ] Run `terraform validate`
- [ ] Run `terraform fmt`
- [ ] Read through main.tf and understand each resource
- [ ] Modify variables.tf and add a new variable
- [ ] Add a new output to outputs.tf

---

## 10. Next Learning Topics (In Order)

1. **Locals** (computed values)
   - Simplify repeated expressions
   - Store calculated values

2. **Data Sources** (query existing resources)
   - Already using: `data.aws_ami.app_ami`
   - Learn to query what exists

3. **Modules** (reuse code)
   - Create a module directory
   - Call modules from main config
   - Pass variables to modules

4. **Conditionals** (if/then logic)
   - `count` - create N resources
   - `for_each` - create resources from map
   - `if` in for expressions

5. **Functions** (HCL built-in functions)
   - String: upper, lower, substr, replace
   - List: concat, flatten, sort, reverse
   - Map: keys, values, merge
   - Type: can, try, type

6. **Expressions** (language features)
   - Interpolation: `"${var.name}"`
   - Splat: `aws_instance.*.id`
   - Dynamic blocks

7. **State** (tracking)
   - Local state files
   - Remote state (S3, Terraform Cloud)
   - State locking
   - State migrations

---

## Commands to Practice Now

```bash
# 1. Initialize (download providers)
terraform init

# 2. Validate syntax
terraform validate

# 3. Check formatting
terraform fmt -check

# 4. Plan (see what would happen)
terraform plan

# 5. Interactive console
terraform console

# 6. Show current state
terraform show

# 7. List state resources
terraform state list

# 8. View outputs
terraform output -json

# 9. Get help
terraform -help
terraform plan -help
```

---

## Pro Tips for Learning

✅ **DO:**
- Experiment in `terraform console` - it's safe!
- Read error messages carefully
- Try modifying variables.tf and re-running commands
- Use `terraform fmt` to learn proper syntax
- Reference the [Terraform Docs](https://www.terraform.io/docs)

❌ **DON'T:**
- Don't worry about deploying yet
- Don't memorize all functions
- Don't skip `terraform validate`
- Don't edit .tfstate files

---

## Resources

- Terraform Console Tutorial: Run this now!
- Terraform Functions Docs: https://www.terraform.io/language/functions
- HCL Syntax Docs: https://www.terraform.io/language
- AWS Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest

---

**Ready? Start with:**
```bash
cd /workspaces/learning-terraform
terraform console
var.instance_type
# (explore!)
```
