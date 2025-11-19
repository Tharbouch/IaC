# DevSecOps Tools Explained - For Thesis Understanding

**Purpose:** This document clarifies which tools we're using and why, especially addressing common confusion points.

---

## Security Scanning Tools Overview

### The Tool Landscape Evolution

**Important Update (2024):**
- ❌ **tfsec** (Terraform Security Scanner) - **DEPRECATED**
- ✅ **Trivy** now includes all tfsec functionality
- 📝 If you see older tutorials mentioning tfsec, use Trivy instead

---

## Tool #1: Trivy (Comprehensive Security Scanner)

### What is Trivy?

**Trivy** is a comprehensive security scanner maintained by Aqua Security.

**Official repo:** https://github.com/aquasecurity/trivy

### What Can Trivy Scan?

Trivy has multiple scanning modes:

```bash
# 1. Container Images (vulnerabilities in packages)
trivy image nginx:latest

# 2. Infrastructure as Code (security misconfigurations)
trivy config terraform/           # ← This is what we use!
trivy config cloudformation/
trivy config kubernetes/

# 3. Filesystems (secrets, misconfigs, vulnerabilities)
trivy fs /path/to/project

# 4. Git Repositories
trivy repo https://github.com/user/repo
```

### For Our Project: Trivy Config Mode

**We use:**
```bash
trivy config terraform/ --severity CRITICAL,HIGH
```

**What it checks:**
- ✅ Terraform security misconfigurations
- ✅ AWS resource security issues
- ✅ Compliance violations
- ✅ Best practice violations
- ✅ **Everything tfsec used to check** (since tfsec merged into Trivy)

**Example detections:**
- Unencrypted S3 buckets
- Overly permissive security groups
- Missing encryption for EBS volumes
- Public access to sensitive resources

---

## Tool #2: Checkov (Policy-as-Code Scanner)

### What is Checkov?

**Checkov** is a static code analysis tool for Infrastructure as Code maintained by Bridgecrew (now part of Palo Alto Networks).

**Official repo:** https://github.com/bridgecrewio/checkov

### What Can Checkov Scan?

```bash
# Terraform
checkov -d terraform/             # ← What we use!

# CloudFormation
checkov -f cloudformation.yaml

# Kubernetes
checkov -f deployment.yaml

# Dockerfiles
checkov -f Dockerfile

# ARM templates, Helm charts, and more...
```

### For Our Project: Checkov for Terraform

**We use:**
```bash
checkov -d terraform/ --framework terraform
```

**What it checks:**
- ✅ Security best practices
- ✅ Compliance frameworks (CIS, PCI-DSS, HIPAA, etc.)
- ✅ Custom policies you define
- ✅ Resource relationships and dependencies
- ✅ Secrets in code

**Example detections:**
- S3 buckets without versioning
- Missing backup configurations
- Inadequate logging
- Compliance violations

---

## Trivy vs Checkov: Why Use Both?

### Coverage Comparison

| Feature | Trivy | Checkov |
|---------|-------|---------|
| **Terraform scanning** | ✅ Excellent (via tfsec) | ✅ Excellent |
| **Vulnerability detection** | ✅ Strong | ⚠️ Limited |
| **Compliance frameworks** | ⚠️ Basic | ✅ Extensive (CIS, PCI, etc.) |
| **Custom policies** | ⚠️ Complex | ✅ Easy (custom checks) |
| **Graph analysis** | ❌ No | ✅ Yes |
| **Multi-IaC support** | ✅ Good | ✅ Excellent |
| **Speed** | ✅ Very fast | ⚠️ Moderate |
| **Secrets detection** | ✅ Yes | ✅ Yes |

### Detection Overlap Study (For Your Thesis!)

**Research Question:** Do Trivy and Checkov find the same issues?

**Answer:** Partial overlap with unique detections!

**Example Test Case: Unencrypted S3 Bucket**

```hcl
# tests/vulnerable/unencrypted-s3.tf
resource "aws_s3_bucket" "test" {
  bucket = "my-unencrypted-bucket"
  # Missing: server_side_encryption_configuration
}
```

**Detection Results:**

✅ **Trivy detects:**
```
CRITICAL: S3 bucket does not have encryption enabled
Rule: AVD-AWS-0088
```

✅ **Checkov detects:**
```
Check: CKV_AWS_19: "Ensure S3 bucket has encryption enabled"
Check: CKV_AWS_21: "Ensure S3 bucket has versioning enabled"
Check: CKV_AWS_18: "Ensure S3 bucket has access logging enabled"
```

**Observation:**
- Both caught the encryption issue ✅
- Checkov provided additional checks Trivy didn't flag
- This demonstrates **complementary coverage**

### Why This Matters for Your Thesis

**Defense in Depth:**
- Using multiple tools reduces false negatives
- Different detection engines = better coverage
- Industry best practice (don't rely on a single scanner)

**Metrics You Can Collect:**
1. Detections unique to Trivy
2. Detections unique to Checkov
3. Detections found by both (overlap)
4. False positive rates for each tool
5. Execution time comparison

---

## Tool #3: Gitleaks (Secret Detection)

### What is Gitleaks?

**Gitleaks** scans Git repositories for hardcoded secrets, passwords, API keys, etc.

**Official repo:** https://github.com/gitleaks/gitleaks

### What Does Gitleaks Find?

```bash
gitleaks detect --source . --verbose
```

**Detects:**
- ✅ AWS Access Keys (AKIA...)
- ✅ AWS Secret Keys
- ✅ API tokens (GitHub, Slack, etc.)
- ✅ Private keys (RSA, SSH)
- ✅ Database passwords
- ✅ Generic secrets (based on entropy)

**Example detection:**
```
Finding: AWS Access Key
Secret: AKIAIOSFODNN7EXAMPLE
File: terraform/main.tf
Line: 15
```

### Why Separate from Trivy/Checkov?

**Gitleaks specializes in secrets:**
- Uses entropy analysis (detects random-looking strings)
- Checks Git history (finds secrets in old commits)
- Optimized for secret patterns
- Fewer false positives for secrets

**Trivy/Checkov** can detect some secrets but aren't specialized for it.

**Result:** Use Gitleaks for comprehensive secret detection!

---

## Tool #4: Open Policy Agent (OPA)

### What is OPA?

**OPA** is a policy engine that lets you write custom rules in the Rego language.

**Official site:** https://www.openpolicyagent.org

### Why Use OPA When We Have Trivy/Checkov?

**OPA provides custom policies specific to YOUR organization:**

**Example:** Your university requires:
- All resources must have tags: `Project`, `Owner`, `Environment`
- All S3 buckets must be in `us-east-1` region
- EC2 instances can only use `t2.micro` or `t3.micro`

**Can Trivy/Checkov enforce this?**
- ❌ No, these are custom organizational policies
- ✅ OPA can enforce ANY custom rule you write

### OPA in Our Framework

**We'll write Rego policies like:**

```rego
# policies/required_tags.rego
package terraform.required_tags

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.tags.Project
  msg := sprintf("S3 bucket %v missing required tag: Project", [resource.address])
}
```

**This enforces:** All S3 buckets MUST have a `Project` tag.

---

## Tool #5: Driftctl (Drift Detection)

### What is Driftctl?

**Driftctl** detects infrastructure drift - differences between your Terraform code and actual deployed resources.

**Official repo:** https://github.com/snyk/driftctl

### What Problem Does It Solve?

**Scenario:**
1. You deploy infrastructure with Terraform
2. Someone manually changes something in AWS Console
3. Your Terraform code is now out of sync with reality

**Driftctl detects:**
- Resources created manually (not in Terraform)
- Resources deleted manually (but still in Terraform)
- Resources modified manually (changed attributes)

**Example:**
```bash
driftctl scan

# Output:
Found 3 resources:
  - 2 managed by Terraform
  - 1 not managed (drift)

aws_s3_bucket.my_bucket:
  - encryption_configuration: changed (drift detected!)
```

### Why Not Just Use Terraform?

**Terraform has drift detection:**
```bash
terraform plan  # Shows drift
```

**But Driftctl offers:**
- ✅ Better visualization of drift
- ✅ Can scan without Terraform state access
- ✅ JSON output for automation
- ✅ Filters and ignores
- ✅ Continuous monitoring integration

**For thesis:** You can compare `terraform plan` vs `driftctl scan` output!

---

## Tool Summary Table

| Tool | Primary Purpose | What It Scans | When It Runs | Phase |
|------|----------------|---------------|--------------|-------|
| **Gitleaks** | Secret detection | Git commits | Pre-commit | 1 |
| **Trivy** | Security misconfigurations + vulnerabilities | Terraform files | Pre-commit & CI | 1 & 2 |
| **Checkov** | Policy compliance + security | Terraform files | CI | 2 |
| **OPA** | Custom policy enforcement | Terraform plans | CI | 2 |
| **Driftctl** | Infrastructure drift | Deployed AWS resources | Scheduled | 4 |
| **Terraform** | Infrastructure provisioning | N/A | Deployment | 3 |

---

## How They Work Together

### Example: Creating an S3 Bucket

**1. Developer writes code:**
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}
```

**2. Developer commits → Phase 1 (Pre-commit):**
- ✅ **Gitleaks:** No secrets found
- ✅ **Trivy:** Detects missing encryption
- ❌ **Commit blocked!**

**3. Developer adds encryption:**
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

**4. Developer commits → Phase 1:**
- ✅ All checks pass locally

**5. Developer creates PR → Phase 2 (CI):**
- ✅ **Trivy:** Passes (encryption configured)
- ✅ **Checkov:** Passes (encryption configured)
- ⚠️ **OPA:** Fails - "Missing required tag: Project"

**6. Developer adds tags:**
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
  tags = {
    Project = "DevSecOps-Thesis"
    Owner   = "student@university.edu"
  }
}
```

**7. PR updated → Phase 2:**
- ✅ All checks pass
- ✅ PR approved and merged

**8. Merge to main → Phase 3 (Deployment):**
- ✅ Terraform plan generated
- ✅ Manual approval requested
- ✅ Infrastructure deployed to AWS

**9. Next day → Phase 4 (Monitoring):**
- ✅ **Driftctl:** Scans infrastructure
- ⚠️ Detects someone manually disabled bucket versioning in AWS Console
- 📧 Alert sent

**10. Remediation:**
- Developer updates Terraform to match (or reverts AWS change)
- Infrastructure back in sync

---

## Tool Version Compatibility

**As of November 2024:**

| Tool | Version | Notes |
|------|---------|-------|
| Trivy | 0.47+ | Includes all tfsec functionality |
| Checkov | 2.4+ | Stable, actively maintained |
| Gitleaks | 8.18+ | Latest stable version |
| OPA | 0.58+ | Stable |
| Driftctl | 0.40+ | Maintained by Snyk |
| Terraform | 1.6+ | Latest stable |

---

## Common Misconceptions (Important for Thesis!)

### Misconception #1: "tfsec vs Trivy"

❌ **Wrong:** "We need to choose between tfsec and Trivy"
✅ **Correct:** "tfsec is now part of Trivy - use Trivy"

### Misconception #2: "Checkov replaces Trivy"

❌ **Wrong:** "If we use Checkov, we don't need Trivy"
✅ **Correct:** "Use both for defense in depth and complementary coverage"

### Misconception #3: "OPA is redundant"

❌ **Wrong:** "Checkov has policies, so OPA is unnecessary"
✅ **Correct:** "OPA enforces custom organizational policies that Checkov can't"

### Misconception #4: "One tool is enough"

❌ **Wrong:** "Pick the best tool and use only that"
✅ **Correct:** "Each tool specializes in different detection methods - use multiple"

---

## For Your Thesis: Tool Comparison Section

### Suggested Analysis Structure:

**1. Tool Selection Rationale**
- Why these specific tools were chosen
- Comparison with alternatives
- Industry adoption statistics

**2. Detection Capability Analysis**
- Test suite of 20+ vulnerable configurations
- Which tool(s) detected each issue
- Overlap vs unique detections
- False positive analysis

**3. Performance Metrics**
- Execution time per tool
- Resource usage (CPU, memory)
- Scalability considerations

**4. Integration Complexity**
- Setup effort per tool
- Configuration complexity
- Maintenance requirements

**5. Cost Analysis**
- All tools are free/open-source
- Compare with commercial alternatives (Snyk, Prisma Cloud, etc.)

---

## Quick Reference Commands

### Trivy
```bash
# Scan Terraform
trivy config terraform/ --severity CRITICAL,HIGH

# Output as JSON
trivy config terraform/ --format json --output trivy-results.json
```

### Checkov
```bash
# Scan Terraform directory
checkov -d terraform/ --framework terraform

# Output as JSON
checkov -d terraform/ --output json > checkov-results.json

# Skip specific checks
checkov -d terraform/ --skip-check CKV_AWS_18
```

### Gitleaks
```bash
# Scan current repo
gitleaks detect --source . --verbose

# Scan with report
gitleaks detect --source . --report-path gitleaks-report.json
```

### OPA
```bash
# Test policy against Terraform plan
opa eval -i tfplan.json -d policies/ "data.terraform.deny"

# Run as test
opa test policies/ tests/
```

### Driftctl
```bash
# Scan for drift
driftctl scan --from tfstate://terraform.tfstate

# Output as JSON
driftctl scan --output json://drift-results.json
```

---

## Additional Resources

### Official Documentation
- **Trivy:** https://aquasecurity.github.io/trivy
- **Checkov:** https://www.checkov.io/documentation
- **Gitleaks:** https://github.com/gitleaks/gitleaks/wiki
- **OPA:** https://www.openpolicyagent.org/docs
- **Driftctl:** https://docs.driftctl.com

### tfsec Migration Guide
- **tfsec → Trivy:** https://github.com/aquasecurity/trivy/discussions/1703

### Community Resources
- **Pre-commit Terraform:** https://github.com/antonbabenko/pre-commit-terraform
- **Terraform AWS Modules:** https://registry.terraform.io/namespaces/terraform-aws-modules

---

## Questions for Understanding (Self-Check)

Before proceeding, make sure you understand:

1. ✅ Why tfsec is deprecated and Trivy replaces it
2. ✅ What each of the 5 tools does differently
3. ✅ Why we use multiple scanning tools instead of just one
4. ✅ What "defense in depth" means in this context
5. ✅ How the tools work together across 4 phases

**If unclear on any point, review the relevant section above!**

---

**Ready to implement?** These tools will all come together in the next phases!
