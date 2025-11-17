#!/bin/bash

# DevSecOps Framework - Prerequisites Verification Script
# Purpose: Checks that all required tools are installed correctly
# Usage: bash verify-prerequisites.sh

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DevSecOps Framework Prerequisites Check${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Function to check if a command exists
check_command() {
    local cmd=$1
    local name=$2
    local version_cmd=$3

    echo -n "Checking $name... "

    if command -v $cmd &> /dev/null; then
        version=$($version_cmd 2>&1 | head -n 1)
        echo -e "${GREEN}✓ INSTALLED${NC} - $version"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ NOT FOUND${NC}"
        echo -e "  ${YELLOW}Install command: See PREREQUISITES.md${NC}"
        ((FAILED++))
        return 1
    fi
}

# Function to check Python package
check_python_package() {
    local package=$1
    local name=$2

    echo -n "Checking $name... "

    if pip3 show $package &> /dev/null; then
        version=$(pip3 show $package | grep Version | awk '{print $2}')
        echo -e "${GREEN}✓ INSTALLED${NC} - v$version"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ NOT FOUND${NC}"
        echo -e "  ${YELLOW}Install command: pip3 install $package${NC}"
        ((FAILED++))
        return 1
    fi
}

echo -e "${BLUE}1. Core System Tools${NC}"
echo "===================="
check_command "git" "Git" "git --version"
check_command "python3" "Python 3" "python3 --version"
check_command "pip3" "pip3" "pip3 --version"
echo ""

echo -e "${BLUE}2. Infrastructure Tools${NC}"
echo "======================="
check_command "terraform" "Terraform" "terraform --version"
check_command "aws" "AWS CLI" "aws --version"
echo ""

echo -e "${BLUE}3. Security Tools${NC}"
echo "================="
check_python_package "pre-commit" "Pre-commit Framework"
check_command "gitleaks" "Gitleaks" "gitleaks version"
check_python_package "checkov" "Checkov"
check_command "trivy" "Trivy" "trivy --version"
check_command "opa" "Open Policy Agent" "opa version"
check_command "driftctl" "Driftctl" "driftctl version"
echo ""

echo -e "${BLUE}4. Optional Tools${NC}"
echo "================="
echo -n "Checking GitHub CLI... "
if command -v gh &> /dev/null; then
    version=$(gh --version | head -n 1)
    echo -e "${GREEN}✓ INSTALLED${NC} - $version"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠ NOT INSTALLED${NC} (optional)"
    echo -e "  ${YELLOW}Install command: See PREREQUISITES.md${NC}"
    ((WARNINGS++))
fi
echo ""

echo -e "${BLUE}5. Configuration Checks${NC}"
echo "======================="

# Check Git configuration
echo -n "Checking Git user.name... "
if git config user.name &> /dev/null; then
    name=$(git config user.name)
    echo -e "${GREEN}✓ CONFIGURED${NC} - $name"
    ((PASSED++))
else
    echo -e "${RED}✗ NOT CONFIGURED${NC}"
    echo -e "  ${YELLOW}Run: git config --global user.name \"Your Name\"${NC}"
    ((FAILED++))
fi

echo -n "Checking Git user.email... "
if git config user.email &> /dev/null; then
    email=$(git config user.email)
    echo -e "${GREEN}✓ CONFIGURED${NC} - $email"
    ((PASSED++))
else
    echo -e "${RED}✗ NOT CONFIGURED${NC}"
    echo -e "  ${YELLOW}Run: git config --global user.email \"your.email@example.com\"${NC}"
    ((FAILED++))
fi

# Check AWS credentials
echo -n "Checking AWS credentials... "
if aws sts get-caller-identity &> /dev/null; then
    account=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    echo -e "${GREEN}✓ CONFIGURED${NC} - Account: $account"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠ NOT CONFIGURED${NC}"
    echo -e "  ${YELLOW}This is OK if you haven't set up AWS yet${NC}"
    echo -e "  ${YELLOW}Run: aws configure (after creating AWS account)${NC}"
    ((WARNINGS++))
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical prerequisites are installed!${NC}"
    echo -e "${GREEN}You're ready to proceed with repository setup.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some prerequisites are missing.${NC}"
    echo -e "${YELLOW}Please install the missing tools before proceeding.${NC}"
    echo -e "${YELLOW}See PREREQUISITES.md for installation instructions.${NC}"
    exit 1
fi
