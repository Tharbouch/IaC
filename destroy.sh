#!/bin/bash
# =============================================================================
# AWS Resources Destroy Script (Using AWS CLI)
# Purpose: Delete all deployed AWS resources manually
# =============================================================================

set +e  # Don't exit on errors, continue trying to delete

PROJECT_NAME="devsecops-iac"
REGION="us-east-1"

echo "=========================================="
echo "AWS Resources Destruction (AWS CLI)"
echo "=========================================="
echo ""

# Ask for confirmation
echo "WARNING: This will DELETE all resources!"
read -p "Are you sure you want to destroy all resources? (yes/no): " CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
    echo "Destroy cancelled."
    exit 0
fi

echo ""
echo "Starting resource deletion..."
echo ""

# =============================================================================
# Step 1: Terminate EC2 Instances
# =============================================================================
echo "Step 1: Terminating EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances \
    --region $REGION \
    --filters "Name=tag:Project,Values=DevSecOps-Thesis" "Name=instance-state-name,Values=running,stopped" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text)

if [ -n "$INSTANCE_IDS" ]; then
    echo "  Terminating instances: $INSTANCE_IDS"
    aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_IDS
    echo "  Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --region $REGION --instance-ids $INSTANCE_IDS || true
    echo "  ✓ Instances terminated"
else
    echo "  No instances found"
fi

# =============================================================================
# Step 2: Delete VPC Flow Logs
# =============================================================================
echo ""
echo "Step 2: Deleting VPC Flow Logs..."
FLOW_LOG_IDS=$(aws ec2 describe-flow-logs \
    --region $REGION \
    --filter "Name=tag:Project,Values=DevSecOps-Thesis" \
    --query 'FlowLogs[*].FlowLogId' \
    --output text)

if [ -n "$FLOW_LOG_IDS" ]; then
    echo "  Deleting flow logs: $FLOW_LOG_IDS"
    aws ec2 delete-flow-logs --region $REGION --flow-log-ids $FLOW_LOG_IDS
    echo "  ✓ Flow logs deleted"
else
    echo "  No flow logs found"
fi

# =============================================================================
# Step 3: Delete IAM Instance Profiles and Roles
# =============================================================================
echo ""
echo "Step 3: Deleting IAM instance profiles and roles..."

# Detach instance profile from role
PROFILE_NAME="${PROJECT_NAME}-ec2-profile"
ROLE_NAME="${PROJECT_NAME}-ec2-role"
VPC_FLOW_ROLE="${PROJECT_NAME}-vpc-flow-logs-role"

# EC2 Profile and Role
if aws iam get-instance-profile --instance-profile-name $PROFILE_NAME &>/dev/null; then
    echo "  Removing role from instance profile..."
    aws iam remove-role-from-instance-profile \
        --instance-profile-name $PROFILE_NAME \
        --role-name $ROLE_NAME || true

    echo "  Deleting instance profile..."
    aws iam delete-instance-profile --instance-profile-name $PROFILE_NAME
    echo "  ✓ Instance profile deleted"
fi

if aws iam get-role --role-name $ROLE_NAME &>/dev/null; then
    echo "  Detaching policies from EC2 role..."
    aws iam detach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" || true

    echo "  Deleting EC2 role..."
    aws iam delete-role --role-name $ROLE_NAME
    echo "  ✓ EC2 role deleted"
fi

# VPC Flow Logs Role
if aws iam get-role --role-name $VPC_FLOW_ROLE &>/dev/null; then
    echo "  Deleting inline policies from VPC Flow Logs role..."
    POLICY_NAMES=$(aws iam list-role-policies --role-name $VPC_FLOW_ROLE --query 'PolicyNames[*]' --output text)
    for policy in $POLICY_NAMES; do
        aws iam delete-role-policy --role-name $VPC_FLOW_ROLE --policy-name $policy
    done

    echo "  Deleting VPC Flow Logs role..."
    aws iam delete-role --role-name $VPC_FLOW_ROLE
    echo "  ✓ VPC Flow Logs role deleted"
fi

# =============================================================================
# Step 4: Empty and Delete S3 Buckets
# =============================================================================
echo ""
echo "Step 4: Emptying and deleting S3 buckets..."
BUCKET_NAME=$(aws s3api list-buckets \
    --query "Buckets[?contains(Name, '$PROJECT_NAME')].Name" \
    --output text)

if [ -n "$BUCKET_NAME" ]; then
    echo "  Emptying bucket: $BUCKET_NAME"
    aws s3 rm s3://$BUCKET_NAME --recursive || true

    echo "  Deleting bucket versions..."
    aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION || true
    echo "  ✓ S3 bucket deleted"
else
    echo "  No S3 buckets found"
fi

# =============================================================================
# Step 5: Delete CloudWatch Log Groups
# =============================================================================
echo ""
echo "Step 5: Deleting CloudWatch log groups..."
LOG_GROUPS=$(aws logs describe-log-groups \
    --region $REGION \
    --log-group-name-prefix "/aws/vpc/${PROJECT_NAME}" \
    --query 'logGroups[*].logGroupName' \
    --output text)

if [ -n "$LOG_GROUPS" ]; then
    for log_group in $LOG_GROUPS; do
        echo "  Deleting log group: $log_group"
        aws logs delete-log-group --region $REGION --log-group-name $log_group
    done
    echo "  ✓ Log groups deleted"
else
    echo "  No log groups found"
fi

# =============================================================================
# Step 6: Delete Security Groups (except default)
# =============================================================================
echo ""
echo "Step 6: Deleting security groups..."
VPC_ID=$(aws ec2 describe-vpcs \
    --region $REGION \
    --filters "Name=tag:Project,Values=DevSecOps-Thesis" \
    --query 'Vpcs[0].VpcId' \
    --output text)

if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    SG_IDS=$(aws ec2 describe-security-groups \
        --region $REGION \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
        --output text)

    if [ -n "$SG_IDS" ]; then
        for sg in $SG_IDS; do
            echo "  Deleting security group: $sg"
            aws ec2 delete-security-group --region $REGION --group-id $sg || true
        done
        echo "  ✓ Security groups deleted"
    fi
fi

# =============================================================================
# Step 7: Delete Subnets
# =============================================================================
echo ""
echo "Step 7: Deleting subnets..."
if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    SUBNET_IDS=$(aws ec2 describe-subnets \
        --region $REGION \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[*].SubnetId' \
        --output text)

    if [ -n "$SUBNET_IDS" ]; then
        for subnet in $SUBNET_IDS; do
            echo "  Deleting subnet: $subnet"
            aws ec2 delete-subnet --region $REGION --subnet-id $subnet
        done
        echo "  ✓ Subnets deleted"
    fi
fi

# =============================================================================
# Step 8: Delete Route Tables (except main)
# =============================================================================
echo ""
echo "Step 8: Deleting route tables..."
if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    RT_IDS=$(aws ec2 describe-route-tables \
        --region $REGION \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' \
        --output text)

    if [ -n "$RT_IDS" ]; then
        for rt in $RT_IDS; do
            echo "  Deleting route table: $rt"
            aws ec2 delete-route-table --region $REGION --route-table-id $rt || true
        done
        echo "  ✓ Route tables deleted"
    fi
fi

# =============================================================================
# Step 9: Detach and Delete Internet Gateways
# =============================================================================
echo ""
echo "Step 9: Deleting internet gateways..."
if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    IGW_IDS=$(aws ec2 describe-internet-gateways \
        --region $REGION \
        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query 'InternetGateways[*].InternetGatewayId' \
        --output text)

    if [ -n "$IGW_IDS" ]; then
        for igw in $IGW_IDS; do
            echo "  Detaching internet gateway: $igw"
            aws ec2 detach-internet-gateway --region $REGION --internet-gateway-id $igw --vpc-id $VPC_ID
            echo "  Deleting internet gateway: $igw"
            aws ec2 delete-internet-gateway --region $REGION --internet-gateway-id $igw
        done
        echo "  ✓ Internet gateways deleted"
    fi
fi

# =============================================================================
# Step 10: Delete VPC
# =============================================================================
echo ""
echo "Step 10: Deleting VPC..."
if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    echo "  Deleting VPC: $VPC_ID"
    aws ec2 delete-vpc --region $REGION --vpc-id $VPC_ID
    echo "  ✓ VPC deleted"
fi

# =============================================================================
# Step 11: Schedule KMS Key Deletion (requires special permissions)
# =============================================================================
echo ""
echo "Step 11: Scheduling KMS key deletion (7-day waiting period)..."
KMS_KEYS=$(aws kms list-keys --region $REGION --query 'Keys[*].KeyId' --output text)

for key_id in $KMS_KEYS; do
    # Check if key has our project tag
    TAGS=$(aws kms list-resource-tags --region $REGION --key-id $key_id --query 'Tags[?TagKey==`Project`].TagValue' --output text 2>/dev/null || true)

    if [ "$TAGS" = "DevSecOps-Thesis" ]; then
        echo "  Scheduling deletion for KMS key: $key_id"
        aws kms schedule-key-deletion \
            --region $REGION \
            --key-id $key_id \
            --pending-window-in-days 7 2>/dev/null || \
        echo "    ⚠ Warning: Insufficient permissions to delete KMS key. Delete manually in AWS Console."
    fi
done

# =============================================================================
# Step 12: Delete KMS Aliases
# =============================================================================
echo ""
echo "Step 12: Deleting KMS aliases..."
for alias in "alias/${PROJECT_NAME}-s3" "alias/${PROJECT_NAME}-cloudwatch"; do
    aws kms delete-alias --region $REGION --alias-name $alias 2>/dev/null || \
    echo "  Alias $alias not found or already deleted"
done

echo ""
echo "=========================================="
echo "Resource deletion complete!"
echo "=========================================="
echo ""
echo "Notes:"
echo "- KMS keys are scheduled for deletion (7-30 day waiting period)"
echo "- If KMS deletion failed due to permissions, delete manually in AWS Console"
echo "- Check AWS Console to verify all resources are deleted"
echo ""
