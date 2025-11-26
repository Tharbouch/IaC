# Test: Empty tag values
# Expected: Should FAIL OPA policies
# Note: These are test files for OPA policies, not SAST policies

resource "aws_s3_bucket" "empty_tags_test" {
  #checkov:skip=CKV2_AWS_62:Test file for OPA policies
  #checkov:skip=CKV2_AWS_61:Test file for OPA policies
  #checkov:skip=CKV_AWS_145:Test file for OPA policies
  #checkov:skip=CKV2_AWS_6:Test file for OPA policies
  #checkov:skip=CKV_AWS_144:Test file for OPA policies
  #checkov:skip=CKV_AWS_21:Test file for OPA policies
  bucket = "opa-test-empty-tags-${random_id.suffix.hex}"

  tags = {
    Project     = "" # INVALID: Empty value
    Owner       = "owner@example.com"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "empty_tags_test" {
  bucket = aws_s3_bucket.empty_tags_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
