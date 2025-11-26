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
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Get the bucket ID/name (resolved value)
    bucket_id := bucket_resource.change.after.id
    bucket_name := bucket_resource.change.after.bucket

    # Find encryption config that references this bucket
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get the bucket reference from encryption config
    bucket_ref := encryption.change.after.bucket

    # The bucket reference can be:
    # 1. Direct address match: "aws_s3_bucket.bucket_name"
    # 2. Reference expression: "aws_s3_bucket.bucket_name.id" or similar
    # 3. Resolved value (bucket ID/name)

    # Check if reference matches bucket address directly
    bucket_ref == bucket_address
}

# Alternative: Check if bucket reference contains the bucket address (for .id, .arn references)
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference
    bucket_ref := encryption.change.after.bucket

    # Extract resource name from reference (e.g., "aws_s3_bucket.opa_test" from "aws_s3_bucket.opa_test.id")
    # Check if reference starts with bucket address
    startswith(bucket_ref, bucket_address)
}

# Alternative: Check if bucket reference matches resolved bucket ID or name
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Get resolved bucket values
    bucket_id := bucket_resource.change.after.id
    bucket_name := bucket_resource.change.after.bucket

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference (could be resolved value)
    bucket_ref := encryption.change.after.bucket

    # Check if reference matches resolved bucket ID or name
    bucket_ref == bucket_id
}

has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Get resolved bucket name
    bucket_name := bucket_resource.change.after.bucket

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference (could be resolved value)
    bucket_ref := encryption.change.after.bucket

    # Check if reference matches resolved bucket name
    bucket_ref == bucket_name
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
