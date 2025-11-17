# Variable Definitions
# Purpose: Defines input variables for the Terraform configuration
# Variables make the code reusable and customizable

# ============================================================================
# GENERAL VARIABLES
# ============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1" # Virginia - most services available in free tier

  validation {
    condition     = can(regex("^us-east-1$|^us-west-2$|^eu-west-1$", var.aws_region))
    error_message = "Region must be us-east-1, us-west-2, or eu-west-1 for free tier eligibility."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "owner_email" {
  description = "Email address of the resource owner (for tagging)"
  type        = string
  default     = "email@example.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "project_name" {
  description = "Name of the project (used in resource naming)"
  type        = string
  default     = "devsecops-thesis"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# ============================================================================
# S3 BUCKET VARIABLES
# ============================================================================

variable "s3_bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
  default     = "" # Will be auto-generated if empty

  validation {
    condition     = var.s3_bucket_name == "" || can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.s3_bucket_name))
    error_message = "S3 bucket name must be lowercase, alphanumeric, and can contain hyphens."
  }
}

variable "enable_s3_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_s3_encryption" {
  description = "Enable server-side encryption on the S3 bucket"
  type        = bool
  default     = true
}

# ============================================================================
# EC2 INSTANCE VARIABLES
# ============================================================================

variable "ec2_instance_type" {
  description = "EC2 instance type (t2.micro for free tier)"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.ec2_instance_type)
    error_message = "Instance type must be t2.micro or t3.micro for free tier eligibility."
  }
}

variable "ec2_instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "devsecops-test-instance"
}

variable "enable_ec2_monitoring" {
  description = "Enable detailed monitoring for EC2 instance"
  type        = bool
  default     = false # Detailed monitoring costs extra
}

# ============================================================================
# VPC AND NETWORKING VARIABLES
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to the instance (use your IP for security)"
  type        = string
  default     = "203.0.113.1/32" # 203.0.113.0/24 is reserved for documentation/examples (RFC 5737)

}

# ============================================================================
# TAGS
# ============================================================================

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
