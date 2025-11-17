# OPA Policy: Security Group Rules
# Purpose: Enforce secure security group configurations
# Phase: 2 (CI Security Gate)
# Language: Rego

package terraform.security_groups

# ==============================================================================
# POLICY: SSH (port 22) must not be open to the internet (0.0.0.0/0)
# ==============================================================================

deny contains msg if {
    # Find all security groups
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"

    # Check ingress rules
    rule := resource.change.after.ingress[_]

    # Check if SSH port is open
    is_ssh_port(rule)

    # Check if open to the internet
    is_open_to_internet(rule)

    # Generate violation message
    msg := sprintf(
        "Security group '%s' allows SSH (port 22) from 0.0.0.0/0. Restrict to specific IP addresses.",
        [resource.address]
    )
}

# ==============================================================================
# POLICY: RDP (port 3389) must not be open to the internet
# ==============================================================================

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"

    rule := resource.change.after.ingress[_]

    # Check if RDP port is open
    is_rdp_port(rule)

    # Check if open to the internet
    is_open_to_internet(rule)

    msg := sprintf(
        "Security group '%s' allows RDP (port 3389) from 0.0.0.0/0. Restrict to specific IP addresses.",
        [resource.address]
    )
}

# ==============================================================================
# POLICY: Database ports must not be exposed to the internet
# ==============================================================================

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"

    rule := resource.change.after.ingress[_]

    # Check if database port is open
    is_database_port(rule)

    # Check if open to the internet
    is_open_to_internet(rule)

    port := rule.from_port

    msg := sprintf(
        "Security group '%s' exposes database port %d to 0.0.0.0/0. Database should only be accessible from application servers.",
        [resource.address, port]
    )
}

# ==============================================================================
# POLICY: Security group rules must have descriptions
# ==============================================================================

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"

    rule := resource.change.after.ingress[_]

    # Check if description is missing or empty
    not rule.description

    msg := sprintf(
        "Security group '%s' has an ingress rule without a description. Add description for documentation.",
        [resource.address]
    )
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"

    rule := resource.change.after.ingress[_]

    # Check if description is empty string
    rule.description == ""

    msg := sprintf(
        "Security group '%s' has an ingress rule with empty description. Provide meaningful description.",
        [resource.address]
    )
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Check if rule applies to SSH port (22)
is_ssh_port(rule) if {
    rule.from_port <= 22
    rule.to_port >= 22
}

# Check if rule applies to RDP port (3389)
is_rdp_port(rule) if {
    rule.from_port <= 3389
    rule.to_port >= 3389
}

# Check if rule applies to database ports
is_database_port(rule) if {
    # MySQL/MariaDB
    rule.from_port <= 3306
    rule.to_port >= 3306
}

is_database_port(rule) if {
    # PostgreSQL
    rule.from_port <= 5432
    rule.to_port >= 5432
}

is_database_port(rule) if {
    # MongoDB
    rule.from_port <= 27017
    rule.to_port >= 27017
}

is_database_port(rule) if {
    # Redis
    rule.from_port <= 6379
    rule.to_port >= 6379
}

# Check if rule allows access from the internet (0.0.0.0/0)
is_open_to_internet(rule) if {
    cidr_block := rule.cidr_blocks[_]
    cidr_block == "0.0.0.0/0"
}

is_open_to_internet(rule) if {
    ipv6_cidr_block := rule.ipv6_cidr_blocks[_]
    ipv6_cidr_block == "::/0"
}
