# Test: Invalid tag values (invalid email, invalid environment)
# Expected: Should FAIL OPA policies
# Note: These are test files for OPA policies, not SAST policies

resource "aws_s3_bucket" "invalid_tags_test" {
  #checkov:skip=CKV2_AWS_62:Test file for OPA policies
  #checkov:skip=CKV2_AWS_61:Test file for OPA policies
  #checkov:skip=CKV2_AWS_6:Test file for OPA policies
  #checkov:skip=CKV_AWS_144:Test file for OPA policies
  #checkov:skip=CKV_AWS_21:Test file for OPA policies
  bucket = "opa-test-invalid-tags-${random_id.suffix.hex}"

  tags = {
    Project     = "TestProject"
    Owner       = "not-an-email" # INVALID: Not a valid email format
    Environment = "production"   # INVALID: Should be "prod", not "production"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "invalid_tags_test" {
  bucket = aws_s3_bucket.invalid_tags_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
