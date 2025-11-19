# Provider Configuration
# Purpose: Configures the AWS provider for Terraform
# This file tells Terraform how to connect to AWS

terraform {
  # Specify required Terraform version
  # Using >= means "this version or newer"
  required_version = ">= 1.6.0"

  # Specify required providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Official AWS provider from HashiCorp
      version = "~> 5.0"        # Use version 5.x (any minor version)
    }
  }

  # Backend configuration (where Terraform state is stored)
  # In production, you'd use remote state (S3 + DynamoDB)

  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "devsecops/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources
  # This is a best practice - helps with cost tracking and organization
  default_tags {
    tags = {
      Project     = "DevSecOps-Thesis"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = var.owner_email
    }
  }
}
