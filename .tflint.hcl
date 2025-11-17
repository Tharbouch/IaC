# TFLint Configuration
# Purpose: Terraform linter configuration
# Phase: 1 (Pre-Commit) and 2 (CI)
#
# What is TFLint?
# - Linter for Terraform code
# - Finds errors, warnings, and style issues
# - Enforces best practices

config {
  # Enable module inspection
  module = true

  # Force provider plugin installation
  force = false
}

# AWS plugin configuration
plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enable Terraform rules
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# ==============================================================================
# TERRAFORM RULES
# ==============================================================================

# Enforce naming conventions
rule "terraform_naming_convention" {
  enabled = true

  variable {
    format = "snake_case"
  }

  locals {
    format = "snake_case"
  }

  output {
    format = "snake_case"
  }

  resource {
    format = "snake_case"
  }

  module {
    format = "snake_case"
  }

  data {
    format = "snake_case"
  }
}

# Require variable descriptions
rule "terraform_documented_variables" {
  enabled = true
}

# Require output descriptions
rule "terraform_documented_outputs" {
  enabled = true
}

# Disallow deprecated syntax
rule "terraform_deprecated_index" {
  enabled = true
}

# Check for unused declarations
rule "terraform_unused_declarations" {
  enabled = true
}

# Standard module structure
rule "terraform_standard_module_structure" {
  enabled = false  # Disabled for flexibility
}

# ==============================================================================
# AWS-SPECIFIC RULES
# ==============================================================================

# Ensure resources have tags
rule "aws_resource_missing_tags" {
  enabled = true
  tags = [
    "Project",
    "Environment",
  ]
}

# Check for invalid instance types
rule "aws_instance_invalid_type" {
  enabled = true
}

# Check for invalid AMI
rule "aws_instance_invalid_ami" {
  enabled = true
}

# S3 bucket naming
rule "aws_s3_bucket_name" {
  enabled = true
  regex   = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
}
