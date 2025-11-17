# DevSecOps Framework for Infrastructure as Code

**Master's Thesis Project:** Automating Cloud Resources Through Infrastructure as Code - A DevSecOps Methodology Driven Approach

---

## 📚 Project Overview

This repository contains a **complete, production-ready implementation** of a four-phase DevSecOps framework that integrates security controls across the entire Infrastructure as Code (IaC) lifecycle.

### The Complete Framework

```
Developer          Version Control       CI/CD Pipeline         Cloud Provider        Monitoring
    │                     │                     │                      │                   │
    │  1. Pre-Commit      │  2. CI Security     │  3. CI/CD           │  4. Continuous    │
    │     Validation      │     Gates           │     Deployment      │     Monitoring    │
    │  (Can be bypassed)  │  (Cannot bypass)    │  (Manual approval)  │  (Detects all)    │
    │                     │                     │                      │                   │
    ├──────────────►      ├──────────────►      ├──────────────►      ├──────────────►    │
    │                     │                     │                      │                   │
    │ • Gitleaks          │ • Checkov           │ • Terraform         │ • Driftctl        │
    │ • TFLint            │ • Trivy             │ • GitHub Actions    │ • Compliance      │
    │ • Pre-commit        │ • OPA Policies      │ • Manual Approval   │   Scanning        │
    │                     │ • Gitleaks          │ • AWS               │ • Alerting        │
    │                     │                     │                      │                   │
    └────────────────────────────────────────────────────────────────────────────────►    │
                                   Defense-in-Depth Security Across All Phases
```

### Security Controls by Phase

| Phase | Location | Tools | Bypass? | Detection Time | Action |
|-------|----------|-------|---------|----------------|---------|
| **Phase 1: Pre-Commit** | Developer's machine | Gitleaks, TFLint, Pre-commit | ✅ Yes (`--no-verify`) | Instant (<10s) | Block commit |
| **Phase 2: CI Security Gate** | GitHub Actions | Checkov, Trivy, OPA, Gitleaks | ❌ **No** (enforced) | Fast (~2 min) | Block PR merge |
| **Phase 3: CI/CD Deployment** | GitHub Actions + AWS | Terraform, Manual approval | ❌ **No** (required) | Medium (~5 min) | Block deployment |
| **Phase 4: Monitoring** | GitHub Actions + AWS | Driftctl, Compliance scans | ❌ **No** (monitors all) | Daily (scheduled) | Alert + Issue |

**Key Thesis Point:** Even if Phase 1 is bypassed, Phases 2-4 provide mandatory, multi-layer security enforcement that cannot be circumvented.

---

## 🎯 Complete Implementation Status

### 📊 Framework Statistics

| Metric | Value |
|--------|-------|
| **Total security tools** | 6 (Gitleaks, Checkov, Trivy, TFLint, OPA, Driftctl) |
| **Security layers** | 4 (defense-in-depth) |
| **GitHub Actions workflows** | 4 automated workflows |
| **Total documentation** | 4 phase guides + 1 completion summary |
| **Test cases included** | Vulnerable + compliant configurations |
| **AWS resources deployed** | 18 (VPC, EC2, S3, IAM, KMS, CloudWatch) |
| **Implementation time** | 4-6 hours total |
| **Cost** | $0 (AWS Free Tier + GitHub Actions Free) |

---

## 🚀 Quick Start
### Prerequisites

**Install required tools:** [PREREQUISITES.md](PREREQUISITES.md)

**Verify installation:**
```bash
bash verify-prerequisites.sh
```

### Implementation Sequence

```
Prerequisites    →      Phase 1      →      Phase 2     →      Phase 3         → Phase 4 
      ↓                   ↓                   ↓                   ↓                  ↓
  All tools         Pre-commit hooks     CI security        CI/CD deployment    Drift detection
  installed           configured         gates passing       with approval       monitoring
```

---

## 📁 Repository Structure

```
DevSecOps-IaC/
├── README.md                          # This file - project overview
├── TOOLS-EXPLAINED.md                 # Tool comparison and rationale
├── verify-prerequisites.sh            # Installation verification script
│
├── .github/workflows/                 # CI/CD Pipelines (4 workflows)
│   ├── 01-security-scan.yml           # Phase 2: SAST (Checkov + Trivy)
│   ├── 02-policy-check.yml            # Phase 2: OPA policy validation
│   ├── 03-deploy.yml                  # Phase 3: CI/CD deployment (manual approval)
│   └── 04-drift-detection.yml         # Phase 4: Drift monitoring (scheduled)
│
├── terraform/                         # Infrastructure as Code
│   ├── main.tf                        # Main infrastructure (security-hardened)
│   ├── variables.tf                   # Input variables with validation
│   ├── outputs.tf                     # Output values
│   ├── provider.tf                    # AWS provider configuration
│   └── terraform.tfvars.example       # Example variable values
│
├── policies/                          # OPA Policies (Policy-as-Code)
│   ├── s3_encryption.rego             # Enforce S3 encryption
│   ├── security_groups.rego           # Restrict security group rules
│   └── required_tags.rego             # Enforce resource tagging
├── docs/                              # Complete thesis documentation
│   ├── PHASE1-IMPLEMENTATION.md       # Phase 1: Pre-commit hooks
│   ├── PHASE2-IMPLEMENTATION.md       # Phase 2: CI security gates
│   ├── PHASE2-ANALYSIS.md             # Phase 2: Initial scan results
│   ├── PHASE2-COMPLETION-SUMMARY.md   # Phase 2: Complete metrics & analysis
│   ├── PHASE3-IMPLEMENTATION.md       # Phase 3: CI/CD deployment (AWS)
│   ├── PHASE4-IMPLEMENTATION.md       # Phase 4: Drift detection
│   ├── screenshots/                   # Screenshots for thesis
│   └── test-results/                  # Scan results and reports
│
├── .pre-commit-config.yaml            # Phase 1: Pre-commit hooks config
├── .gitleaks.toml                     # Phase 1: Secret scanning config
├── .tflint.hcl                        # Phase 1: Terraform linting config
└── .gitignore                         # Security-focused Git ignore rules
```

---

## 🔧 Technology Stack

### Infrastructure & Cloud
- **IaC Tool:** Terraform v1.6+
- **Cloud Provider:** AWS (Free Tier eligible)
- **Version Control:** Git + GitHub
- **CI/CD:** GitHub Actions (Free Tier)

### Security Tools
- **Secret Scanning:** Gitleaks v8.18+
- **SAST:** Checkov v2.x, Trivy v0.x
- **Linting:** TFLint
- **Policy Engine:** Open Policy Agent (OPA) v0.x
- **Drift Detection:** Driftctl v0.x

### Pre-commit Framework
- **Framework:** pre-commit v3.x
- **Hooks:** Gitleaks, TFLint, Terraform fmt/validate

---

### Defense-in-Depth Validation

This framework proves that **multiple security layers** are essential:

| Attack Scenario | Layer 1 (Phase 1) | Layer 2 (Phase 2) | Layer 3 (Phase 3) | Layer 4 (Phase 4) |
|----------------|-------------------|-------------------|-------------------|-------------------|
| **Developer bypasses pre-commit** | ❌ Bypassed | ✅ **Caught** | N/A | N/A |
| **Vulnerable code in PR** | ⚠️ May bypass | ✅ **Caught** | ⚠️ Blocked | N/A |
| **Manual AWS Console change** | N/A | N/A | N/A | ✅ **Detected** |
| **Credentials in code** | ✅ **Caught** | ✅ **Caught** | N/A | N/A |

### Complete Metrics for Thesis

**Detection Metrics:**
- Total vulnerabilities tested: 17
- Detection rate: 100% (17/17)
- False positives: 0
- False negatives: 0
- Tool overlap: 24% (4/17 detected by both Trivy and Checkov)
- Checkov additional coverage: 69% (9/13 unique to Checkov)

**Performance Metrics:**
- Phase 1 execution time: <10 seconds
- Phase 2 pipeline duration: ~2 minutes
- Phase 3 deployment time: ~5 minutes
- Phase 4 scan time: 30-60 seconds

**Security Fixes Applied:**
- Critical issues: 4 → 0
- High-severity: 9 → 0
- Total fixes: 12 security enhancements
- Lines of code changed: 355 insertions, 289 deletions

## 🔐 Security Features Implemented

### Infrastructure Security Controls

**VPC & Networking:**
- ✅ VPC Flow Logs (encrypted with KMS)
- ✅ Default security group restricted (deny all)
- ✅ Network segmentation (public subnet only for web tier)

**Compute (EC2):**
- ✅ IAM instance profile (no hardcoded credentials)
- ✅ Systems Manager (SSM) access (no SSH keys needed)
- ✅ Encrypted EBS volumes
- ✅ IMDSv2 enforced (metadata security)
- ✅ Detailed monitoring enabled
- ✅ EBS optimization enabled

**Storage (S3):**
- ✅ KMS customer-managed encryption
- ✅ Versioning enabled
- ✅ Public access blocked
- ✅ Lifecycle policies configured
- ✅ Abort incomplete multipart uploads

**Logging & Monitoring:**
- ✅ CloudWatch Log Groups (KMS encrypted)
- ✅ VPC Flow Logs (all traffic)
- ✅ 7-day retention (Free Tier optimized)

**Identity & Access:**
- ✅ IAM roles (no access keys in code)
- ✅ Least-privilege policies (5 specific permissions, not AdministratorAccess)
- ✅ Resource-specific permissions (no wildcard `*`)

**Encryption:**
- ✅ KMS customer-managed keys (not AWS-managed)
- ✅ Key rotation enabled
- ✅ Comprehensive key policies
- ✅ All data encrypted at rest

---

## ⚠️ Important Reminders

### AWS Cost Management

✅ **DO:**
- Use only Free Tier resources (t2.micro, small S3 buckets)
- Destroy resources immediately after testing
- Set up billing alerts ($0 threshold)
- Check billing dashboard daily
- Use us-east-1 region (most Free Tier eligible)

❌ **DON'T:**
- Leave EC2 instances running overnight
- Create resources outside us-east-1
- Use non-Free Tier instance types
- Skip the teardown steps

**Teardown command:**
```bash
cd terraform
terraform destroy
```

## 📝 License

This is a Master's thesis project for educational purposes.

---

## 🙏 Acknowledgments

This framework implements industry-standard DevSecOps practices using open-source tools:
- HashiCorp (Terraform)
- GitHub (Actions, Version Control)
- Aqua Security (Trivy)
- Bridgecrew/Palo Alto (Checkov)
- Open Policy Agent (OPA)
- Gitleaks (Secret Scanning)
- Snyk (Driftctl)

---

---

**Author:** [Harbouch Taha]
**Institution:** ENSA - Ibn tofail Univeristy
**Program:** Master's in Information Systems Security
**Year:** 2024-2025
**Status:** Complete 4-Phase DevSecOps Framework - Production Ready

---

