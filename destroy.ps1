# =============================================================================
# AWS Resources Destroy Script (Using AWS CLI - PowerShell)
# Purpose: Delete all deployed AWS resources manually
# =============================================================================

$ErrorActionPreference = "Continue"

$PROJECT_NAME = "devsecops-iac"
$REGION = "us-east-1"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "AWS Resources Destruction (AWS CLI)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Ask for confirmation
Write-Host "WARNING: This will DELETE all resources!" -ForegroundColor Red
$Confirmation = Read-Host "Are you sure you want to destroy all resources? (yes/no)"

if ($Confirmation -ne "yes") {
    Write-Host "Destroy cancelled." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Starting resource deletion..." -ForegroundColor Yellow
Write-Host ""

# Note: This PowerShell script uses bash script as reference
Write-Host "Note: For Windows, it's recommended to use Git Bash or WSL to run destroy.sh" -ForegroundColor Yellow
Write-Host "This PowerShell script provides equivalent commands for reference." -ForegroundColor Yellow
Write-Host ""

# Instructions for manual deletion
Write-Host "To delete resources using AWS CLI in PowerShell:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Run the bash script using Git Bash or WSL:" -ForegroundColor White
Write-Host "   bash destroy.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Or delete resources manually in this order:" -ForegroundColor White
Write-Host "   a. Terminate EC2 instances" -ForegroundColor Gray
Write-Host "   b. Delete VPC Flow Logs" -ForegroundColor Gray
Write-Host "   c. Delete IAM roles and instance profiles" -ForegroundColor Gray
Write-Host "   d. Empty and delete S3 buckets" -ForegroundColor Gray
Write-Host "   e. Delete CloudWatch log groups" -ForegroundColor Gray
Write-Host "   f. Delete security groups" -ForegroundColor Gray
Write-Host "   g. Delete subnets" -ForegroundColor Gray
Write-Host "   h. Delete route tables" -ForegroundColor Gray
Write-Host "   i. Delete internet gateways" -ForegroundColor Gray
Write-Host "   j. Delete VPC" -ForegroundColor Gray
Write-Host "   k. Schedule KMS key deletion" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Or use the AWS Console to delete resources manually" -ForegroundColor White
Write-Host ""

Write-Host "Recommended: Use Git Bash or WSL to run destroy.sh for automated deletion" -ForegroundColor Yellow
