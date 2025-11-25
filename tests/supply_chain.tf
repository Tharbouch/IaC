# Test File: Supply Chain Vulnerabilities
# Purpose: Demonstrates Terraform supply chain security risks
# Expected Result: Should be flagged by security scanners (Trivy, Checkov)
#
# This file intentionally contains supply chain vulnerabilities to test
# detection capabilities in the DevSecOps pipeline.
#
# IMPORTANT: This file is for TESTING ONLY - never use in production!

# ============================================================================
# VULNERABILITY: Using Outdated/Vulnerable Provider Version
# ============================================================================
# Using an old AWS provider version with known security vulnerabilities

terraform {
  required_version = ">= 0.12" # VULNERABILITY: Very old Terraform version

  required_providers {
    # VULNERABILITY: Using old AWS provider version (3.x has known issues)
    # Current version is 5.x, but we're using 3.x
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.75.0" # VULNERABILITY: Outdated version from 2022
    }

    # VULNERABILITY: Using random provider without version constraint
    random = {
      source = "hashicorp/random"
      # MISSING: No version specified - will use latest (unpredictable)
    }

  }
}
