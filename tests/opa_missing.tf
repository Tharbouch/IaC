# VIOLATION 1 & 2: TAGGING POLICIES
# This resource violates 'policies/required_tags.rego':
# - Missing 'CostCenter' tag
# - 'Project' tag is empty
# - 'Owner' tag is not a valid email address
# - 'Environment' tag is 'testing' (Must be dev, staging, or prod)
# checkov:skip=CKV2_AWS_61
# checkov:skip=CKV_AWS_145
# checkov:skip=CKV2_AWS_6
# checkov:skip=CKV_AWS_144
# checkov:skip=CKV_AWS_19
resource "aws_s3_bucket" "violation_bucket" {
  bucket = "policy-violation-bucket-example"

  tags = {
    Project     = ""              # Violation: Empty value
    Owner       = "invalid-owner" # Violation: Invalid email format
    Environment = "testing"       # Violation: Invalid environment value
    # CostCenter tag is missing completely
  }
}

# VIOLATION 3: S3 ENCRYPTION
# This resource violates 'policies/s3_encryption.rego':
# - Uses 'AES128' instead of required 'AES256' or 'aws:kms'
# checkov:skip=CKV_AWS_19
# trivy:ignore:AVD-AWS-0088
# checkov:skip=CKV2_AWS_6
resource "aws_s3_bucket_server_side_encryption_configuration" "violation_encryption" {
  bucket = aws_s3_bucket.violation_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES128" # Violation: Weak algorithm
    }
  }
}
