# Test: Security group violations
# Expected: Should FAIL OPA security group policies
# Note: These are test files for OPA policies, not SAST policies

# Security group with SSH open to internet
resource "aws_security_group" "ssh_open" {
  #checkov:skip=CKV_AWS_24:Test file for OPA policies
  #checkov:skip=CKV_AWS_23:Test file for OPA policies
  #checkov:skip=CKV2_AWS_5:Test file for OPA policies
  #trivy:skip=AVD-AWS-0104:Test file for OPA policies
  name        = "opa-test-ssh-open"
  description = "Test security group with SSH open to internet"

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # VIOLATION: SSH open to internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

# Security group with RDP open to internet
resource "aws_security_group" "rdp_open" {
  #checkov:skip=CKV_AWS_25:Test file for OPA policies
  #checkov:skip=CKV2_AWS_5:Test file for OPA policies
  name        = "opa-test-rdp-open"
  description = "Test security group with RDP open to internet"

  ingress {
    description = "RDP from internet"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # VIOLATION: RDP open to internet
  }

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

# Security group with database port open to internet
resource "aws_security_group" "db_open" {
  #checkov:skip=CKV2_AWS_5:Test file for OPA policies
  name        = "opa-test-db-open"
  description = "Test security group with MySQL open to internet"

  ingress {
    description = "MySQL from internet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # VIOLATION: Database port open to internet
  }

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

# Security group with missing description
resource "aws_security_group" "no_description" {
  #checkov:skip=CKV_AWS_23:Test file for OPA policies
  #checkov:skip=CKV2_AWS_5:Test file for OPA policies
  name = "opa-test-no-description"

  ingress {
    # VIOLATION: Missing description
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}

# Security group with empty description
resource "aws_security_group" "empty_description" {
  #checkov:skip=CKV_AWS_23:Test file for OPA policies
  #checkov:skip=CKV2_AWS_5:Test file for OPA policies
  name        = "opa-test-empty-description"
  description = "Test security group"

  ingress {
    description = "" # VIOLATION: Empty description
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Project     = "TestProject"
    Owner       = "admin@example.com"
    Environment = "dev"
  }
}
