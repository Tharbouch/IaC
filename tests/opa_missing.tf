# Test: Violates OPA (missing tags) but passes SAST (has encryption + security)

resource "aws_s3_bucket" "opa_test" {
  #checkov:skip=CKV2_AWS_62
  #checkov:skip=CKV2_AWS_61
  #checkov:skip=CKV_AWS_144
  bucket = "opa-test-missing-tags-${random_id.suffix.hex}"

  # Missing required tags: Project, Owner, Environment
  # This will FAIL OPA but PASS SAST
}

resource "aws_s3_bucket_server_side_encryption_configuration" "opa_test" {
  bucket = aws_s3_bucket.opa_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "opa_test" {
  bucket = aws_s3_bucket.opa_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "opa_test" {
  bucket = aws_s3_bucket.opa_test.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
