# OPA Policy: S3 Bucket Encryption
# Purpose: Enforce that all S3 buckets must have server-side encryption enabled
# Phase: 2 (CI Security Gate)
# Language: Rego
#
# ENHANCED: This policy now handles:
# - Computed values (values not yet resolved in Terraform plan)
# - Resource references by address (e.g., "aws_s3_bucket.name.id")
# - Multiple reference formats in Terraform plan JSON
# - Both string and object-based references
#
# Reference Formats Supported:
# 1. Direct string: "aws_s3_bucket.bucket_name"
# 2. String with attribute: "aws_s3_bucket.bucket_name.id"
# 3. Computed object: {"__tfmeta": {"path": "aws_s3_bucket.bucket_name"}}
# 4. Resolved values: actual bucket ID/name strings

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

# Check if a reference points to a specific bucket address
# Handles multiple formats:
# 1. Direct string match: "aws_s3_bucket.bucket_name"
# 2. String with attribute: "aws_s3_bucket.bucket_name.id"
# 3. Computed value object: {"__tfmeta": {"path": "aws_s3_bucket.bucket_name"}}
# 4. Resolved value: actual bucket ID/name string
references_bucket(ref, bucket_address) if {
    # Case 1: Direct string match
    is_string(ref)
    ref == bucket_address
}

references_bucket(ref, bucket_address) if {
    # Case 2: String reference with attribute access (e.g., "aws_s3_bucket.name.id")
    is_string(ref)
    startswith(ref, sprintf("%s.", [bucket_address]))
}

references_bucket(ref, bucket_address) if {
    # Case 3: Computed value object with __tfmeta.path
    is_object(ref)
    ref["__tfmeta"]
    ref["__tfmeta"]["path"]
    path := ref["__tfmeta"]["path"]
    is_string(path)
    # Direct path match
    path == bucket_address
}

references_bucket(ref, bucket_address) if {
    # Case 3b: Computed value object with path that starts with bucket address (exact match)
    is_object(ref)
    ref["__tfmeta"]
    ref["__tfmeta"]["path"]
    path := ref["__tfmeta"]["path"]
    is_string(path)
    # Path exactly matches bucket address
    path == bucket_address
}

references_bucket(ref, bucket_address) if {
    # Case 3c: Computed value object with path that has attribute
    is_object(ref)
    ref["__tfmeta"]
    ref["__tfmeta"]["path"]
    path := ref["__tfmeta"]["path"]
    is_string(path)
    startswith(path, sprintf("%s.", [bucket_address]))
}

references_bucket(ref, bucket_address) if {
    # Case 4: Object with resource_address field
    is_object(ref)
    ref["resource_address"]
    ref["resource_address"] == bucket_address
}

references_bucket(ref, bucket_address) if {
    # Case 5: Handle unknown values (computed values that aren't resolved yet)
    # Check if it's an object that might contain reference information
    is_object(ref)
    # Look for common Terraform reference patterns
    # Some computed values might have different structures
    # Try to match if any field contains the bucket address
    ref[_] == bucket_address
}

# Check if encryption configuration exists for a bucket
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Find encryption config that references this bucket
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get the bucket reference from encryption config (can be string, object, or computed)
    bucket_ref := encryption.change.after.bucket

    # Check if reference points to our bucket (handles all formats)
    references_bucket(bucket_ref, bucket_address)
}

# Alternative: Check if bucket reference matches resolved bucket ID or name
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Get resolved bucket values (if available)
    bucket_id := bucket_resource.change.after.id
    bucket_name := bucket_resource.change.after.bucket

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference (could be resolved value)
    bucket_ref := encryption.change.after.bucket

    # Check if reference matches resolved bucket ID or name (string comparison)
    is_string(bucket_ref)
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

    # Check if reference matches resolved bucket name (string comparison)
    is_string(bucket_ref)
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

# Handle references in change.before (for updates)
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Check before value (for updates)
    bucket_ref_before := encryption.change.before.bucket
    references_bucket(bucket_ref_before, bucket_address)
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
