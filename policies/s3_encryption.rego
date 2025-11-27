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

# Extract base resource address from a Terraform reference
# This handles references like "aws_s3_bucket.data.id" -> "aws_s3_bucket.data"
extract_base_address(ref_string) := base_address if {
    is_string(ref_string)
    # Split by dots and take first two parts (resource_type.resource_name)
    parts := split(ref_string, ".")
    count(parts) >= 2
    base_address := sprintf("%s.%s", [parts[0], parts[1]])
}

# Convert any reference format to a string representation for comparison
# This helps handle various Terraform plan JSON structures
reference_to_string(ref) := ref_str if {
    is_string(ref)
    ref_str := ref
}

reference_to_string(ref) := ref_str if {
    is_object(ref)
    ref["__tfmeta"]
    ref["__tfmeta"]["path"]
    ref_str := ref["__tfmeta"]["path"]
}

reference_to_string(ref) := ref_str if {
    is_object(ref)
    ref["expression"]
    is_string(ref["expression"])
    ref_str := ref["expression"]
}

reference_to_string(ref) := ref_str if {
    is_object(ref)
    ref["reference"]
    is_string(ref["reference"])
    ref_str := ref["reference"]
}

reference_to_string(ref) := ref_str if {
    is_object(ref)
    ref["resource_address"]
    ref_str := ref["resource_address"]
}

# Check if a reference points to a specific bucket address
# Handles multiple formats:
# 1. Direct string match: "aws_s3_bucket.bucket_name"
# 2. String with attribute: "aws_s3_bucket.bucket_name.id"
# 3. Computed value object: {"__tfmeta": {"path": "aws_s3_bucket.bucket_name"}}
# 4. Resolved value: actual bucket ID/name string
# 5. Terraform plan reference objects with various structures
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
    # Case 2b: String reference that contains bucket address (for cases where format might vary)
    is_string(ref)
    contains(ref, bucket_address)
    # Ensure it's a proper reference format
    startswith(ref, "aws_")
    # Extract base address and compare
    base := extract_base_address(ref)
    base == bucket_address
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
    # Case 3b: Computed value object with path that has attribute access
    is_object(ref)
    ref["__tfmeta"]
    ref["__tfmeta"]["path"]
    path := ref["__tfmeta"]["path"]
    is_string(path)
    # Path starts with bucket address followed by attribute
    startswith(path, sprintf("%s.", [bucket_address]))
}

references_bucket(ref, bucket_address) if {
    # Case 3c: Computed value object with path that contains bucket address
    is_object(ref)
    ref["__tfmeta"]
    ref["__tfmeta"]["path"]
    path := ref["__tfmeta"]["path"]
    is_string(path)
    # Extract base address from path and compare
    base := extract_base_address(path)
    base == bucket_address
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

references_bucket(ref, bucket_address) if {
    # Case 6: Handle references stored in expressions or expressions_after
    # Some Terraform plans store references in expression structures
    is_object(ref)
    ref["expressions"]
    expr := ref["expressions"][_]
    expr["references"]
    bucket_address == expr["references"][_]
}

references_bucket(ref, bucket_address) if {
    # Case 7: Handle references in expression_after structure
    is_object(ref)
    ref["expression"]
    is_string(ref["expression"])
    expr := ref["expression"]
    # Expression might be a string like "aws_s3_bucket.data.id"
    startswith(expr, sprintf("%s.", [bucket_address]))
}

references_bucket(ref, bucket_address) if {
    # Case 7b: Handle references in expression - extract base address
    is_object(ref)
    ref["expression"]
    is_string(ref["expression"])
    expr := ref["expression"]
    # Extract base address from expression
    base := extract_base_address(expr)
    base == bucket_address
}

references_bucket(ref, bucket_address) if {
    # Case 8: Handle references that might be in a "reference" field
    is_object(ref)
    ref["reference"]
    is_string(ref["reference"])
    ref_str := ref["reference"]
    # Reference might be a string like "aws_s3_bucket.data.id"
    startswith(ref_str, sprintf("%s.", [bucket_address]))
}

references_bucket(ref, bucket_address) if {
    # Case 8b: Handle references in "reference" field - extract base address
    is_object(ref)
    ref["reference"]
    is_string(ref["reference"])
    ref_str := ref["reference"]
    # Extract base address from reference
    base := extract_base_address(ref_str)
    base == bucket_address
}

references_bucket(ref, bucket_address) if {
    # Case 9: Handle references in "references" array
    is_object(ref)
    ref["references"]
    bucket_address == ref["references"][_]
}

references_bucket(ref, bucket_address) if {
    # Case 10: Universal approach - convert any reference to string and check
    # This is a fallback that tries to extract the reference from any structure
    ref_str := reference_to_string(ref)
    # Direct match
    ref_str == bucket_address
}

references_bucket(ref, bucket_address) if {
    # Case 10b: Universal approach - check if string representation starts with bucket address
    ref_str := reference_to_string(ref)
    startswith(ref_str, sprintf("%s.", [bucket_address]))
}

references_bucket(ref, bucket_address) if {
    # Case 10c: Universal approach - extract base address from string representation
    ref_str := reference_to_string(ref)
    base := extract_base_address(ref_str)
    base == bucket_address
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
    # Handle cases where bucket might be in after or before
    bucket_ref := encryption.change.after.bucket
    bucket_ref != null

    # Check if reference points to our bucket (handles all formats)
    references_bucket(bucket_ref, bucket_address)
}

# Alternative: Check if encryption config references bucket via before value
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Find encryption config that references this bucket
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Check before value (for updates or when after is null/undefined)
    bucket_ref := encryption.change.before.bucket
    bucket_ref != null
    references_bucket(bucket_ref, bucket_address)
}

# Additional check: Try to match by converting reference to string and checking
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference (try after first, then before)
    bucket_ref := encryption.change.after.bucket
    bucket_ref != null

    # Convert to string and check
    ref_str := reference_to_string(bucket_ref)
    # Check if it matches or starts with bucket address
    ref_str == bucket_address
}

has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference from before if after is null
    bucket_ref := encryption.change.before.bucket
    bucket_ref != null

    # Convert to string and check
    ref_str := reference_to_string(bucket_ref)
    # Check if it matches or starts with bucket address
    ref_str == bucket_address
}

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
    bucket_ref != null

    # Convert to string and extract base address
    ref_str := reference_to_string(bucket_ref)
    base := extract_base_address(ref_str)
    base == bucket_address
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

# Alternative: Check if bucket reference matches resolved bucket ID (handle computed values)
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Get resolved bucket ID (if available)
    bucket_id := bucket_resource.change.after.id
    is_string(bucket_id)

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference (could be resolved value or computed)
    bucket_ref := encryption.change.after.bucket

    # Check if reference matches resolved bucket ID (string comparison)
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

# Handle resources with count/index (e.g., aws_s3_bucket_server_side_encryption_configuration.data[0])
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Find encryption config (may have index like [0] in address)
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Extract base address from encryption resource (remove index if present)
    # Address might be like "aws_s3_bucket_server_side_encryption_configuration.data[0]"
    # or "aws_s3_bucket_server_side_encryption_configuration.data"
    base_encryption_address := encryption.address
    # Check if it references our bucket
    bucket_ref := encryption.change.after.bucket

    # Try to match reference
    references_bucket(bucket_ref, bucket_address)
}

# Additional check: Handle cases where reference might be in a different format
# Some Terraform plans use different structures for references
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Get resolved bucket ID (if available)
    bucket_id := bucket_resource.change.after.id

    # Find encryption config
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Get bucket reference
    bucket_ref := encryption.change.after.bucket

    # Check if it's an object that might contain the reference in a nested structure
    is_object(bucket_ref)
    # Look for common reference patterns in objects
    # Some plans use nested structures like {"value": "aws_s3_bucket.data.id"}
    bucket_ref["value"]
    is_string(bucket_ref["value"])
    references_bucket(bucket_ref["value"], bucket_address)
}

# Helper function to extract base resource name (remove array index if present)
extract_resource_base_name(resource_name) := base_name if {
    contains(resource_name, "[")
    base_name := split(resource_name, "[")[0]
}

extract_resource_base_name(resource_name) := base_name if {
    not contains(resource_name, "[")
    base_name := resource_name
}

# Fallback: Check if encryption config exists by resource address pattern
# This handles cases where the reference format is not recognized but the resource exists
has_encryption_config(bucket_address) if {
    # Find the bucket resource
    bucket_resource := input.resource_changes[_]
    bucket_resource.type == "aws_s3_bucket"
    bucket_resource.address == bucket_address

    # Extract resource name from bucket address (e.g., "aws_s3_bucket.data" -> "data")
    parts := split(bucket_address, ".")
    count(parts) == 2
    bucket_resource_name := parts[1]

    # Find encryption config with matching resource name
    # The encryption config should be named similarly (e.g., "aws_s3_bucket_server_side_encryption_configuration.data")
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    # Check if encryption resource address contains the bucket resource name
    # This handles cases like "aws_s3_bucket_server_side_encryption_configuration.data"
    encryption_parts := split(encryption.address, ".")
    count(encryption_parts) >= 2
    encryption_resource_name := encryption_parts[1]

    # Remove any array index from resource name (e.g., "data[0]" -> "data")
    encryption_base_name := extract_resource_base_name(encryption_resource_name)

    # Match if resource names are the same
    encryption_base_name == bucket_resource_name
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
