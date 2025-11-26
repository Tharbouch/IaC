# Test: Fully compliant resources
# Expected: Should PASS all OPA policies
# Note: These are test files for OPA policies, not SAST policies

resource "aws_s3_bucket" "compliant_test" {
  #checkov:skip=CKV2_AWS_62:Test file for OPA policies
  #checkov:skip=CKV2_AWS_61:Test file for OPA policies
  #checkov:skip=CKV_AWS_144:Test file for OPA policies
  bucket = "opa-test-compliant-${random_id.suffix.hex}"

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
    CostCenter  = "Engineering"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "compliant_test" {
  bucket = aws_s3_bucket.compliant_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "compliant_test" {
  bucket = aws_s3_bucket.compliant_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "compliant_test" {
  bucket = aws_s3_bucket.compliant_test.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Compliant security group
resource "aws_security_group" "compliant_test" {
  #checkov:skip=CKV2_AWS_5:Test file for OPA policies
  #trivy:skip=AVD-AWS-0104:Test file for OPA policies
  name        = "opa-test-compliant-sg"
  description = "Compliant security group for testing"

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Internal network only
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

resource "aws_kms_key" "s3" {
  #checkov:skip=CKV_AWS_7:Test file for OPA policies
  #checkov:skip=CKV2_AWS_64:Test file for OPA policies
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 7

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
