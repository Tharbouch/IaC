# DevSecOps Framework - Prerequisites Installation Guide

**Purpose:** This guide will help you install all required tools for your DevSecOps thesis project.

**Your Environment:** WSL (Windows Subsystem for Linux) on Windows 10

**Estimated Time:** 45-60 minutes

---

## Table of Contents
1. [System Requirements Check](#system-requirements-check)
2. [Tool Installation](#tool-installation)
3. [Account Setup](#account-setup)
4. [Verification](#verification)

---

## System Requirements Check

### Step 1: Verify WSL is Working

**What you're doing:** Confirming your Linux environment is ready.

```bash
uname -a
```

**Expected output:** Something like `Linux ... x86_64 GNU/Linux`

**What this means:** You're running in a Linux environment within Windows.

---

### Step 2: Update Package Manager

**What you're doing:** Updating the list of available packages (like updating an app store).

```bash
sudo apt update && sudo apt upgrade -y
```

**Why:** Ensures you get the latest versions of tools.

**Time:** 2-5 minutes depending on internet speed.

**Expected output:** You'll see packages being fetched and upgraded.

---

## Tool Installation

### 1. Git Installation

**What it is:** Version control system that tracks changes to your code.

**Why we need it:** Everything in this project uses Git for version control.

#### Installation:

```bash
sudo apt install git -y
```

#### Configuration (IMPORTANT):

```bash
# Replace with your actual name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### Verification:

```bash
git --version
```

**Expected output:** `git version 2.x.x` or higher

#### Troubleshooting:
- If git command not found: The installation failed. Try `sudo apt install git-all`

---

### 2. Python 3 Installation

**What it is:** Programming language used by many DevOps tools.

**Why we need it:** Pre-commit framework, Checkov, and other tools run on Python.

#### Check if already installed:

```bash
python3 --version
```

**Expected output:** `Python 3.8.x` or higher

#### If not installed or version is too old:

```bash
sudo apt install python3 python3-pip python3-venv -y
```

**What these packages do:**
- `python3` - The Python interpreter
- `python3-pip` - Package installer for Python (like an app store for Python tools)
- `python3-venv` - Creates isolated Python environments

#### Verification:

```bash
python3 --version
pip3 --version
```

**Expected output:**
```
Python 3.8.x (or higher)
pip 20.x.x (or higher)
```

---

### 3. Terraform Installation

**What it is:** Tool that lets you define cloud infrastructure using code.

**Why we need it:** This is the core IaC tool for your thesis.

#### Installation:

```bash
# Add HashiCorp GPG key (verifies downloads are authentic)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update && sudo apt install terraform -y
```

#### Verification:

```bash
terraform --version
```

**Expected output:** `Terraform v1.6.x` or higher

#### Test Terraform:

```bash
terraform -help
```

**Expected output:** A help menu showing various Terraform commands.

**What this means:** Terraform is ready to use!

---

### 4. AWS CLI Installation

**What it is:** Command-line tool to interact with Amazon Web Services.

**Why we need it:** To manage AWS resources and configure credentials.

#### Installation:

```bash
# Download AWS CLI installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Install unzip if needed
sudo apt install unzip -y

# Unzip the installer
unzip awscliv2.zip

# Run the installer
sudo ./aws/install

# Clean up
rm -rf aws awscliv2.zip
```

#### Verification:

```bash
aws --version
```

**Expected output:** `aws-cli/2.x.x Python/3.x.x Linux/...`

**Note:** We'll configure AWS credentials later after you create your AWS account.

---

### 5. Pre-commit Framework

**What it is:** A framework that manages and runs Git hooks automatically.

**Why we need it:** This is the foundation of Phase 1 (Pre-Commit Security Validation).

#### Installation:

```bash
pip3 install pre-commit
```

#### Verification:

```bash
pre-commit --version
```

**Expected output:** `pre-commit 3.x.x`

#### Troubleshooting:
- If command not found: The install location isn't in your PATH. Try:
  ```bash
  python3 -m pre_commit --version
  ```
- If this works, add to PATH: `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc`

---

### 6. Gitleaks Installation

**What it is:** Tool that scans code for hardcoded secrets (passwords, API keys, etc.).

**Why we need it:** Prevents accidental commit of sensitive credentials.

#### Installation:

```bash
# Download latest release
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.1/gitleaks_8.18.1_linux_x64.tar.gz

# Extract
tar -xzf gitleaks_8.18.1_linux_x64.tar.gz

# Move to system path
sudo mv gitleaks /usr/local/bin/

# Clean up
rm gitleaks_8.18.1_linux_x64.tar.gz README.md LICENSE
```

#### Verification:

```bash
gitleaks version
```

**Expected output:** `v8.18.1`

---

### 7. Checkov Installation

**What it is:** Static analysis tool that scans IaC for security misconfigurations.

**Why we need it:** Primary SAST tool for Phase 2.

#### Installation:

```bash
pip3 install checkov
```

#### Verification:

```bash
checkov --version
```

**Expected output:** `2.x.xxxx` (version number)

#### Test Checkov:

```bash
checkov --help
```

**Expected output:** Help menu with various scanning options.

---

### 8. Trivy Installation

**What it is:** Comprehensive security scanner for vulnerabilities, misconfigurations, and secrets. **Trivy replaced tfsec** (the former Terraform-specific scanner that was deprecated in 2024).

**Why we need it:**
- Scans Terraform for security misconfigurations (replaces tfsec)
- Detects vulnerabilities in dependencies
- Complements Checkov with additional security checks
- Provides defense-in-depth alongside other tools

**Important:** If you see tutorials mentioning "tfsec", use Trivy instead - all tfsec functionality is now built into Trivy's `config` scanning mode.

#### Installation:

```bash
# Add Aqua Security repository
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Install
sudo apt update && sudo apt install trivy -y
```

#### Verification:

```bash
trivy --version
```

**Expected output:** `Version: 0.x.x`

#### Test Trivy's Terraform Scanning:

```bash
trivy config --help
```

**Expected output:** Help menu showing config scanning options, including support for Terraform.

**What this confirms:** Trivy can scan Terraform files (the tfsec replacement functionality).

---

### 9. Open Policy Agent (OPA) Installation

**What it is:** Policy engine that enforces rules on your infrastructure code.

**Why we need it:** Implements Policy-as-Code in Phase 2.

#### Installation:

```bash
# Download OPA binary
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64

# Make it executable
chmod +x opa

# Move to system path
sudo mv opa /usr/local/bin/

```

#### Verification:

```bash
opa version
```

**Expected output:** `Version: 0.x.x`

#### Test OPA:

```bash
opa run --help
```

**Expected output:** Help menu for OPA commands.

---

### 10. Driftctl Installation

**What it is:** Tool that detects infrastructure drift (differences between code and actual deployed resources).

**Why we need it:** Core tool for Phase 4 (Continuous Monitoring).

#### Installation:

```bash
# Download and install
curl -L https://github.com/snyk/driftctl/releases/latest/download/driftctl_linux_amd64 -o driftctl

# Make executable
chmod +x driftctl

# Move to system path
sudo mv driftctl /usr/local/bin/
```

#### Verification:

```bash
driftctl version
```

**Expected output:** `driftctl version 0.x.x`

---

## Account Setup

### 1. GitHub Account

**What it is:** Platform for hosting Git repositories and running CI/CD pipelines.

**What you need to do:**

1. Go to https://github.com/signup
2. Create a free account if you don't have one
3. Verify your email address

**Why:** We'll host your code here and use GitHub Actions for CI/CD.

**Cost:** Free (we'll only use free features)

---

### 2. AWS Account (Free Tier)

**What it is:** Amazon's cloud platform where you'll deploy infrastructure.

**What you need to do:**

1. Go to https://aws.amazon.com/free
2. Click "Create a Free Account"
3. Follow the signup process (requires credit card but won't charge for free tier usage)
4. Complete identity verification

**IMPORTANT WARNINGS:**
- ⚠️ We'll only use free tier resources (t2.micro EC2, S3 with minimal storage)
- ⚠️ Always destroy resources after testing to avoid charges
- ⚠️ Set up billing alerts (I'll show you how)

**Why:** This is where your Terraform code will create actual cloud infrastructure.

**Cost:** $0 if you stay within free tier limits and destroy resources promptly

---

### 3. AWS Credentials Setup (CRITICAL FOR SECURITY)

**Do this AFTER you create your AWS account:**

#### Step 1: Create an IAM User

**What is IAM?** Identity and Access Management - controls who can access what in AWS.

1. Log into AWS Console: https://console.aws.amazon.com
2. Search for "IAM" in the top search bar
3. Click "Users" in the left sidebar
4. Click "Create user"
5. User name: `terraform-thesis-user`
6. Click "Next"
7. Select "Attach policies directly"
8. Search for and select these policies:
   - `AmazonEC2FullAccess`
   - `AmazonS3FullAccess`
   - `AmazonVPCFullAccess`
9. Click "Next" then "Create user"

#### Step 2: Create Access Keys

1. Click on the user you just created (`terraform-thesis-user`)
2. Click "Security credentials" tab
3. Scroll to "Access keys" section
4. Click "Create access key"
5. Select "Command Line Interface (CLI)"
6. Check the confirmation box
7. Click "Next"
8. Add description tag: "Terraform thesis project"
9. Click "Create access key"

**CRITICAL:** You'll see:
- Access key ID (looks like: AKIAIOSFODNN7EXAMPLE)
- Secret access key (looks like: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY)

**⚠️ SAVE THESE IMMEDIATELY:**
- Download the CSV file
- Store it in a secure location (NOT in your code repository)
- You'll never see the secret access key again

#### Step 3: Configure AWS CLI

**What you're doing:** Storing your AWS credentials locally so tools can access AWS.

```bash
aws configure
```

**You'll be prompted for:**

```
AWS Access Key ID [None]: <paste your access key ID>
AWS Secret Access Key [None]: <paste your secret access key>
Default region name [None]: us-east-1
Default output format [None]: json
```

**What these mean:**
- **Access Key ID & Secret:** Your credentials to access AWS
- **Region:** us-east-1 (Virginia) - has the most free tier eligible services
- **Output format:** json - how AWS returns data

#### Verification:

```bash
aws sts get-caller-identity
```

**Expected output:**
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-thesis-user"
}
```

**What this means:** AWS credentials are configured correctly!

---

## Complete Verification Script

I'll create a script that checks all installations at once.

**Note:** After installing all tools above, run this script to verify everything is working.

---

## Estimated Time Summary

| Task | Time |
|------|------|
| System update | 5 min |
| Git installation | 2 min |
| Python installation | 3 min |
| Terraform installation | 3 min |
| AWS CLI installation | 5 min |
| Pre-commit installation | 2 min |
| Gitleaks installation | 2 min |
| Checkov installation | 3 min |
| Trivy installation | 3 min |
| OPA installation | 2 min |
| Driftctl installation | 2 min |
| GitHub CLI installation | 3 min |
| GitHub account setup | 5 min |
| AWS account setup | 10 min |
| AWS credentials setup | 5 min |
| **TOTAL** | **45-60 min** |

---

## What's Next?

After completing these prerequisites, you'll be ready to:
1. Set up your repository structure
2. Begin implementing Phase 1 (Pre-Commit Security Validation)

---

## Common Issues and Solutions

### Issue: "Permission denied" when running sudo commands
**Solution:** Make sure you're running WSL with appropriate permissions. You might need to restart WSL.

### Issue: "Command not found" after installation
**Solution:** The to
ol's location isn't in your PATH. Try:
1. Close and reopen your terminal
2. Run `source ~/.bashrc`
3. Check installation location and add to PATH manually

### Issue: AWS CLI configuration not working
**Solution:**
1. Make sure you copied the complete access key and secret (no extra spaces)
2. Try `aws configure` again
3. Check `~/.aws/credentials` file exists

### Issue: Python/pip installation issues
**Solution:**
```bash
sudo apt install python3-pip python3-dev build-essential -y
```

---

## Security Reminders

1. ✅ **NEVER** commit AWS credentials to Git
2. ✅ **NEVER** share your AWS secret access key
3. ✅ **ALWAYS** destroy AWS resources after testing
4. ✅ **ALWAYS** check billing dashboard after creating resources
5. ✅ Store credentials in `~/.aws/credentials` (this directory is automatically ignored by Git)

---

## Ready to Start?

Once all verifications pass, proceed to repository setup!
