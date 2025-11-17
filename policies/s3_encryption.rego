# OPA Policy: S3 Bucket Encryption
# Purpose: Enforce that all S3 buckets must have server-side encryption enabled
# Phase: 2 (CI Security Gate)
# Language: Rego

package terraform.s3_encryption

# ==============================================================================
# POLICY: S3 buckets must have encryption enabled
# ==============================================================================

# Deny rule - returns violation messages
deny contains msg if {
    # Find all S3 buckets in the Terraform plan
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"

    # Get the bucket address (name in Terraform)
    bucket_address := resource.address

    # Check if there's a corresponding encryption configuration
    not has_encryption_config(bucket_address)

    # Generate violation message
    msg := sprintf(
        "S3 bucket '%s' does not have encryption enabled. Add aws_s3_bucket_server_side_encryption_configuration resource.",
        [bucket_address]
    )
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Check if encryption configuration exists for a bucket
has_encryption_config(bucket_address) if {
    # Look for encryption configuration resource
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Check if it references our bucket
    # The encryption config's bucket attribute should match the bucket resource
    # We use strict equality here or check inclusion
    encryption.change.after.bucket == bucket_address
}

# Alternative: Check if encryption is inline (older Terraform syntax)
has_encryption_config(bucket_address) if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.address == bucket_address

    # Check if server_side_encryption_configuration block exists
    resource.change.after.server_side_encryption_configuration
}

# ==============================================================================
# POLICY: Encryption must use strong algorithms
# ==============================================================================

deny contains msg if {
    # Find encryption configurations
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get the encryption algorithm
    rule := resource.change.after.rule[_]
    algorithm := rule.apply_server_side_encryption_by_default.sse_algorithm

    # Check if algorithm is weak
    not strong_encryption(algorithm)

    msg := sprintf(
        "S3 encryption configuration '%s' uses weak encryption algorithm '%s'. Use 'AES256' or 'aws:kms'.",
        [resource.address, algorithm]
    )
}

# Define strong encryption algorithms
strong_encryption(algorithm) if {
    algorithm == "AES256"
}

strong_encryption(algorithm) if {
    algorithm == "aws:kms"
}
