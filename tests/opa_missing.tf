# This file contains INTENTIONAL violations to test the OPA policies.
# We want the pipeline to DETECT these and BLOCK (turn Red).

# NOTE: Provider configuration is handled by the pipeline. Do NOT add a provider block here.

# ============================================================================
# VIOLATION SET 1: TAGGING POLICIES (policies/required_tags.rego)
# ============================================================================
# 1. Missing 'CostCenter' tag (Recommended)
# 2. 'Project' tag is empty (Required - Invalid)
# 3. 'Owner' tag is not a valid email (Required - Invalid)
# 4. 'Environment' tag is 'testing' (Required - Invalid)

# checkov:skip=CKV2_AWS_61: "Intentional violation for OPA testing"
# checkov:skip=CKV_AWS_145: "Intentional violation for OPA testing"
# checkov:skip=CKV2_AWS_6: "Intentional violation for OPA testing"
# checkov:skip=CKV_AWS_144: "Intentional violation for OPA testing"
# checkov:skip=CKV_AWS_19: "Intentional violation for OPA testing"
resource "aws_s3_bucket" "violation_bucket" {
  bucket = "policy-violation-bucket-example-unique-123"

  tags = {
    Project     = ""              # Violation: Empty value
    Owner       = "invalid-owner" # Violation: Invalid email format
    Environment = "testing"       # Violation: Invalid environment value
    # CostCenter tag is missing completely
  }
}

# ============================================================================
# VIOLATION SET 2: S3 ENCRYPTION (policies/s3_encryption.rego)
# ============================================================================
# 5. Missing Encryption Configuration
# We omit the encryption resource to trigger the "must have encryption" policy.

# checkov:skip=CKV_AWS_19: "Intentional violation for OPA testing"
# trivy:ignore:AVD-AWS-0088: "Intentional violation for OPA testing"
# checkov:skip=CKV2_AWS_6: "Intentional violation for OPA testing"

# (Resource omitted intentionally to trigger violation)

# ============================================================================
# VIOLATION SET 3: SECURITY GROUPS (policies/security_groups.rego)
# ============================================================================
# 6. SSH (22) open to 0.0.0.0/0 (Critical)
# 7. Missing rule description

# checkov:skip=CKV_AWS_24: "Intentional violation: SSH open to world"
# checkov:skip=CKV_AWS_260: "Intentional violation: Security group description"
resource "aws_security_group" "violation_sg" {
  name        = "violation-sg"
  description = "Security group with violations"
  vpc_id      = "vpc-12345678" # Dummy VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Violation: SSH open to world
    # Violation: Missing description
  }
}
