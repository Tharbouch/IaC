# OPA Policy: Required Resource Tags
# Purpose: Enforce organizational tagging standards on all resources
# Phase: 2 (CI Security Gate)
# Language: Rego

package terraform.required_tags

# ==============================================================================
# CONFIGURATION: Define required tags
# ==============================================================================

# List of tags that MUST be present on all resources
required_tags := [
    "Project",
    "Owner",
    "Environment",
]

# Optional: Tags that are recommended but not required
recommended_tags := [
    "CostCenter",
    "ManagedBy",
]

# ==============================================================================
# CONFIGURATION: Define taggable resource types
# ==============================================================================

# List of AWS resource types that support tagging
taggable_resources := [
    "aws_instance",
    "aws_s3_bucket",
    "aws_vpc",
    "aws_subnet",
    "aws_security_group",
    "aws_db_instance",
    "aws_ebs_volume",
    "aws_elasticache_cluster",
    "aws_lambda_function",
    "aws_rds_cluster",
]

# ==============================================================================
# POLICY: All taggable resources must have required tags
# ==============================================================================

deny contains msg if {
    # Find all resource changes
    resource := input.resource_changes[_]

    # Check if resource type is taggable
    is_taggable(resource.type)

    # Check if resource is being created or updated
    resource.change.actions[_] == "create"

    # Check each required tag
    tag := required_tags[_]

    # Check if tag is missing
    not has_tag(resource, tag)

    # Generate violation message
    msg := sprintf(
        "Resource '%s' (type: %s) is missing required tag: '%s'",
        [resource.address, resource.type, tag]
    )
}

# ==============================================================================
# POLICY: Tag values must not be empty
# ==============================================================================

deny contains msg if {
    resource := input.resource_changes[_]
    is_taggable(resource.type)

    # Check each required tag
    tag := required_tags[_]

    # Tag exists but value is empty
    has_tag(resource, tag)
    resource.change.after.tags[tag] == ""

    msg := sprintf(
        "Resource '%s' has empty value for required tag: '%s'",
        [resource.address, tag]
    )
}

# ==============================================================================
# POLICY: Owner tag must be a valid email address
# ==============================================================================

deny contains msg if {
    resource := input.resource_changes[_]
    is_taggable(resource.type)

    # Check if Owner tag exists
    has_tag(resource, "Owner")

    # Get Owner tag value
    owner := resource.change.after.tags.Owner

    # Check if it's a valid email format
    not is_valid_email(owner)

    msg := sprintf(
        "Resource '%s' has invalid email format for Owner tag: '%s'",
        [resource.address, owner]
    )
}

# ==============================================================================
# POLICY: Environment tag must be valid
# ==============================================================================

deny contains msg if {
    resource := input.resource_changes[_]
    is_taggable(resource.type)

    # Check if Environment tag exists
    has_tag(resource, "Environment")

    # Get Environment tag value
    environment := resource.change.after.tags.Environment

    # Check if environment is valid
    not valid_environment(environment)

    msg := sprintf(
        "Resource '%s' has invalid Environment tag: '%s'. Must be one of: dev, staging, prod",
        [resource.address, environment]
    )
}

# =============================================================================
# POLICY: tags required
#==============================================================================

deny contains msg if {
    resource := input.resource_changes[_]
    is_taggable(resource.type)

    # 1. Get tags, defaulting to empty object if missing
    # object.get(object, key, default_value)
    tags := object.get(resource.change.after, "tags", {})

    # 2. Check for required tags
    req_tag := required_tags[_]
    not tags[req_tag]

    msg := sprintf("Resource '%s' is missing required tag: '%s'", [resource.address, req_tag])
}

# ==============================================================================
# WARNING: Resources missing recommended tags
# ==============================================================================

warn contains msg if {
    resource := input.resource_changes[_]
    is_taggable(resource.type)

    tag := recommended_tags[_]
    not has_tag(resource, tag)

    msg := sprintf(
        "Resource '%s' is missing recommended tag: '%s'",
        [resource.address, tag]
    )
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Check if resource type is in the taggable list
is_taggable(resource_type) if {
    resource_type == taggable_resources[_]
}

# Check if a specific tag exists on a resource
has_tag(resource, tag_name) if {
    resource.change.after.tags[tag_name]
}

# Validate email format (basic check)
is_valid_email(email) if {
    contains(email, "@")
    contains(email, ".")
    not contains(email, " ")
}

# Define valid environments
valid_environment(env) if {
    env == "dev"
}

valid_environment(env) if {
    env == "staging"
}

valid_environment(env) if {
    env == "prod"
}

# ==============================================================================
# REPORTING: Summary of compliance
# ==============================================================================

# Count total taggable resources using Rego v1 comprehensions
taggable_resource_count := count([r |
    r := input.resource_changes[_]
    is_taggable(r.type)
])

# Count compliant resources (all required tags present)
compliant_resource_count := count([r |
    r := input.resource_changes[_]
    is_taggable(r.type)
    all_tags_present(r)
])

# Helper: Check if all required tags are present
all_tags_present(resource) if {
    # Ensure every required tag is present
    every tag in required_tags {
        has_tag(resource, tag)
    }
}
