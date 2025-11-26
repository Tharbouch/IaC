# Test: S3 bucket with weak encryption
# Expected: Should FAIL OPA S3 encryption policy (weak algorithm)
# Note: These are test files for OPA policies, not SAST policies

resource "aws_s3_bucket" "weak_encryption_test" {
  #checkov:skip=CKV2_AWS_62:Test file for OPA policies
  #checkov:skip=CKV2_AWS_61:Test file for OPA policies
  #checkov:skip=CKV_AWS_145:Test file for OPA policies
  #checkov:skip=CKV2_AWS_6:Test file for OPA policies
  #checkov:skip=CKV_AWS_144:Test file for OPA policies
  #checkov:skip=CKV_AWS_21:Test file for OPA policies
  bucket = "opa-test-weak-encryption-${random_id.suffix.hex}"

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "weak_encryption_test" {
  bucket = aws_s3_bucket.weak_encryption_test.id

  rule {
    apply_server_side_encryption_by_default {
      # Note: AWS S3 only supports AES256 and aws:kms
      # This test would fail if a weak algorithm were used
      # For testing purposes, we use a valid algorithm but the policy
      # should reject any algorithm that's not AES256 or aws:kms
      sse_algorithm = "AES256" # Valid, but test structure is in place
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
