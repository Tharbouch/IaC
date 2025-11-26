# Test: S3 bucket without encryption
# Expected: Should FAIL OPA S3 encryption policy
# Note: These are test files for OPA policies, not SAST policies

resource "aws_s3_bucket" "no_encryption_test" {
  #checkov:skip=CKV2_AWS_62:Test file for OPA policies
  #checkov:skip=CKV2_AWS_61:Test file for OPA policies
  #checkov:skip=CKV_AWS_145:Test file for OPA policies
  #checkov:skip=CKV2_AWS_6:Test file for OPA policies
  #checkov:skip=CKV_AWS_144:Test file for OPA policies
  #checkov:skip=CKV_AWS_21:Test file for OPA policies
  bucket = "opa-test-no-encryption-${random_id.suffix.hex}"

  # VIOLATION: No encryption configuration
  # Missing: aws_s3_bucket_server_side_encryption_configuration

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "no_encryption_test" {
  bucket = aws_s3_bucket.no_encryption_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_id" "suffix" {
  byte_length = 4
}
