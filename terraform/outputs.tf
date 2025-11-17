# Output Values
# Purpose: Defines outputs that are shown after 'terraform apply'
# Outputs display important information about created resources

# ============================================================================
# VPC OUTPUTS
# ============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

# ============================================================================
# EC2 OUTPUTS
# ============================================================================

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.web_server.private_ip
}

output "ec2_availability_zone" {
  description = "Availability zone where the EC2 instance is running"
  value       = aws_instance.web_server.availability_zone
}

output "web_server_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web_server.public_ip}"
}

# ============================================================================
# S3 OUTPUTS
# ============================================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.data.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.data.arn
}

output "s3_bucket_region" {
  description = "Region where the S3 bucket is located"
  value       = aws_s3_bucket.data.region
}

# ============================================================================
# SECURITY GROUP OUTPUTS
# ============================================================================

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_server.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.web_server.name
}

# ============================================================================
# GENERAL OUTPUTS
# ============================================================================

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.name
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# ============================================================================
# COST TRACKING OUTPUT
# ============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (assumes Free Tier resources)"
  value       = <<-EOT

  ESTIMATED MONTHLY COST (Free Tier):
  - EC2 t2.micro (750 hrs/month):  $0.00 (Free Tier)
  - S3 storage (5GB):               $0.00 (Free Tier)
  - VPC (basic):                    $0.00 (Free)
  - Data Transfer (1GB):            $0.00 (Free Tier)

  TOTAL: $0.00/month (within Free Tier limits)

  WARNING: Costs apply if:
  - Instance runs >750 hours/month
  - S3 storage exceeds 5GB
  - Data transfer exceeds 1GB

  IMPORTANT: Run 'terraform destroy' after testing!
  EOT
}

# ============================================================================
# SECURITY REMINDER OUTPUT
# ============================================================================

output "security_reminders" {
  description = "Important security reminders"
  value       = <<-EOT

  SECURITY REMINDERS:
  ⚠️  SSH is allowed from 0.0.0.0/0 (INSECURE - for testing only!)
  ⚠️  Remember to destroy resources after testing: terraform destroy
  ✅  S3 bucket has encryption enabled
  ✅  S3 bucket blocks public access
  ✅  EC2 root volume is encrypted

  To restrict SSH access, update var.allowed_ssh_cidr to your IP address.
  EOT
}

# ============================================================================
# NEXT STEPS OUTPUT
# ============================================================================

output "next_steps" {
  description = "What to do after deployment"
  value       = <<-EOT

  NEXT STEPS:

  1. Verify EC2 instance is running:
     aws ec2 describe-instances --instance-ids ${aws_instance.web_server.id}

  2. Access the web server:
     Open in browser: http://${aws_instance.web_server.public_ip}

  3. SSH to the instance (if needed):
     ssh -i your-key.pem ec2-user@${aws_instance.web_server.public_ip}
     Note: You need to create an SSH key pair first!

  4. Check S3 bucket:
     aws s3 ls s3://${aws_s3_bucket.data.id}

  5. Test drift detection (Phase 4):
     - Manually modify a resource in AWS Console
     - Run: driftctl scan

  6. DESTROY resources after testing:
     terraform destroy

  7. Verify destruction:
     - Check AWS Console
     - Check billing dashboard
  EOT
}
