# TEST CASE: Hardcoded AWS Credentials
# Purpose: Test secret detection in Phase 1 (Gitleaks)
# Expected: This should be BLOCKED by pre-commit hooks
#
# SECURITY ISSUE: Hardcoded AWS credentials in code
# SEVERITY: CRITICAL
# DETECTED BY: Gitleaks

# WARNING: This is INTENTIONALLY VULNERABLE for testing!
# DO NOT use real credentials!

provider "aws" {
  region = "us-east-1"

  # VULNERABILITY: Hardcoded AWS credentials
  # Real AWS access keys follow this pattern:
  # Access Key ID: AKIA followed by 16 characters
  # Secret Key: 40 characters
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

resource "aws_s3_bucket" "test" {
  bucket = "my-test-bucket-with-hardcoded-creds"

  tags = {
    Name        = "Test Bucket"
    Environment = "test"
  }
}

# TESTING INSTRUCTIONS:
# 1. Try to commit this file
# 2. Gitleaks should detect the hardcoded credentials
# 3. Commit should be BLOCKED
# 4. Screenshot the blocked commit for your thesis

# EXPECTED OUTPUT FROM GITLEAKS:
# ○
#     │╲│
#     │ ○
#     ○ ░
#     ░    gitleaks
#
# Finding:     line 16
# Secret:      AKIAIOSFODNN7EXAMPLE
# RuleID:      aws-access-token
# Entropy:     3.684564
# File:        tests/vulnerable/hardcoded-secret.tf
# Line:        16
# Commit:      [commit hash]
#
# 1 finding(s) found in 1 commit(s)

# HOW TO FIX:
# 1. Remove hardcoded credentials
# 2. Use AWS CLI configuration: aws configure
# 3. Credentials stored in ~/.aws/credentials (not in code!)
