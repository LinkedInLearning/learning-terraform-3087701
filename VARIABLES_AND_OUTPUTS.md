# Terraform Variables and Outputs Guide

## Overview
Variables and Outputs are core Terraform features that make your infrastructure code flexible, reusable, and maintainable.

## Variables Basics

### What are Variables?
Variables allow you to parameterize your Terraform configurations. They act as input parameters to your infrastructure code.

### Variable Types
1. **string** - Text values
2. **number** - Integer or float values
3. **bool** - True/false values
4. **list** - Ordered collection of values
5. **map** - Key-value pairs
6. **set** - Unordered collection of unique values
7. **object** - Complex data structure with multiple attributes
8. **any** - Accept any type (use sparingly)

### Variable Definition Components

```hcl
variable "instance_type" {
  description = "Type of EC2 instance to provision"
  type        = string
  default     = "t3.nano"
  sensitive   = false
  nullable    = false
  validation {
    condition     = contains(["t3.nano", "t3.micro", "t3.small"], var.instance_type)
    error_message = "Instance type must be a valid t3 type."
  }
}
```

**Key Attributes:**
- **description**: Documents what the variable does
- **type**: Specifies the data type (required for good practices)
- **default**: Default value if not provided (optional)
- **sensitive**: Hides the value in logs (good for passwords, tokens)
- **nullable**: Whether null values are allowed
- **validation**: Custom validation rules

## Using Variables in Configuration

```hcl
# Access variables using var.variable_name
resource "aws_instance" "web" {
  instance_type = var.instance_type
  tags = {
    Environment = var.environment
  }
}
```

## Setting Variable Values

### 1. Command Line (Highest Priority)
```bash
terraform apply -var="instance_type=t3.small"
terraform apply -var='additional_tags={"Environment"="prod"}'
```

### 2. Environment Variables
```bash
export TF_VAR_instance_type="t3.small"
export TF_VAR_environment="prod"
terraform apply
```

### 3. Variable Files (.tfvars)
```bash
terraform apply -var-file="prod.tfvars"
terraform apply -var-file="terraform.tfvars"  # Loaded automatically
```

### 4. Default Values (Lowest Priority)
If no value is provided, Terraform uses the default value in the variable definition.

### Priority Order (Highest to Lowest)
1. Command-line `-var` flags
2. Environment variables (TF_VAR_*)
3. `.tfvars` files
4. Default values in variable definition

## Outputs Guide

### What are Outputs?
Outputs expose values from your Terraform configuration to users and external systems. They display important information after `terraform apply`.

### Output Attributes

```hcl
output "instance_id" {
  description   = "The ID of the EC2 instance"
  value         = aws_instance.web.id
  sensitive     = false
  depends_on    = []  # Explicit dependencies if needed
}
```

**Key Attributes:**
- **description**: Documents what the output represents
- **value**: The actual value to output (required)
- **sensitive**: Hides the value in output (for passwords, tokens)
- **depends_on**: Explicit dependencies between outputs

### Accessing Outputs

After `terraform apply`, view outputs:
```bash
# Display all outputs
terraform output

# Display specific output
terraform output instance_id

# Output as JSON (useful for scripting)
terraform output -json
```

### Output Scenarios

**1. Simple Single Value**
```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

**2. Complex Object**
```hcl
output "instance_details" {
  value = {
    id        = aws_instance.web.id
    public_ip = aws_instance.web.public_ip
    arn       = aws_instance.web.arn
  }
}
```

**3. List of Values**
```hcl
output "all_instance_ids" {
  value = [for instance in aws_instance.web : instance.id]
}
```

**4. Sensitive Data**
```hcl
output "database_password" {
  value     = random_password.db.result
  sensitive = true  # Won't show in logs/terminal
}
```

## Practical Examples in This Project

### Example 1: Override Instance Type
```bash
terraform apply -var="instance_type=t3.small"
```

### Example 2: Change Environment and Get Details
```bash
terraform apply -var="environment=prod" -var="enable_monitoring=true"
terraform output instance_details
```

### Example 3: Use a tfvars File
```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Then apply (it will be used automatically)
terraform apply
```

### Example 4: Output as JSON for Scripts
```bash
# Get outputs as JSON
terraform output -json > infrastructure.json

# Extract specific value
terraform output -json instance_details | jq '.public_ip'
```

## Best Practices

### Variables
1. **Always use type constraints** - Makes code more maintainable
2. **Provide meaningful defaults** - Reduces required input
3. **Add validation rules** - Catches errors early
4. **Use descriptions** - Documents intent for users
5. **Use sensitive flag** - Protects secrets in logs
6. **Organize by concern** - Group related variables

### Outputs
1. **Document important values** - Use descriptions
2. **Expose computed attributes** - Make derived values accessible
3. **Use sensitive for secrets** - Hide passwords, tokens, keys
4. **Export for downstream systems** - Enable automation chains
5. **Provide multiple formats** - Single values + complex objects
6. **Keep outputs relevant** - Don't expose unnecessary details

### Variable Files
1. **.gitignore terraform.tfvars** - Never commit local values
2. **Use .example files** - Show required variables
3. **Environment-specific files** - dev.tfvars, prod.tfvars, etc.
4. **Document required variables** - In README or comments

## Validation Examples

### Validate Enum Values
```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Validate String Pattern
```hcl
variable "app_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.app_name))
    error_message = "App name must start with letter and contain only lowercase letters, numbers, and hyphens."
  }
}
```

### Validate Numeric Range
```hcl
variable "replica_count" {
  type = number
  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 10
    error_message = "Replica count must be between 1 and 10."
  }
}
```

## Troubleshooting

### Variable Not Being Used
- Check syntax: `var.variable_name`
- Ensure variable is defined in `variables.tf`
- Verify variable hasn't been misspelled

### Output Not Displaying
- Run `terraform apply` (not just `terraform plan`)
- Check output value references correct resource
- Use `terraform output -json` for JSON format

### Value Not Being Applied
- Check variable priority order
- Use `terraform console` to debug
- Verify file is in correct location (.tfvars)

## Next Steps
- Explore **Modules** - Reuse and organize configurations
- Learn **State Management** - Understand how Terraform tracks resources
- Study **Remote State** - Collaborate with team members
- Practice **Multiple Environments** - Create dev, staging, prod setups
