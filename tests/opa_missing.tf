# This file is self-contained for OPA testing.
# It intentionally violates policies to ensure OPA detects them.
# The provider configuration is handled by the CI pipeline, so we do NOT define it here.

# VIOLATION 1 & 2: TAGGING POLICIES
# - Missing 'CostCenter' tag
# - 'Project' tag is empty
# - 'Owner' tag is not a valid email address
# - 'Environment' tag is 'testing' (Invalid)

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

# VIOLATION 3: S3 ENCRYPTION
# - Uses 'AES128' (Invalid)

# checkov:skip=CKV_AWS_19: "Intentional violation for OPA testing"
# trivy:ignore:AVD-AWS-0088: "Intentional violation for OPA testing"
# checkov:skip=CKV2_AWS_6: "Intentional violation for OPA testing"
resource "aws_s3_bucket_server_side_encryption_configuration" "violation_encryption" {
  bucket = aws_s3_bucket.violation_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES128" # Violation: Weak algorithm
    }
  }
}

# VIOLATION 4: SECURITY GROUPS
# - SSH (22) open to 0.0.0.0/0

# checkov:skip=CKV_AWS_24: "Intentional violation: SSH open to world"
# checkov:skip=CKV_AWS_260: "Intentional violation: Security group description"
resource "aws_security_group" "violation_sg" {
  name        = "violation-sg"
  description = "Security group with violations"
  vpc_id      = "vpc-12345678" # Dummy VPC ID for planning

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Violation: SSH open to world
    description = "SSH access"
  }
}
