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
├── verify-prerequisites.sh            # Installation verification script
│
├── .github/workflows/                 # CI/CD Pipelines (4 workflows)
│   ├── 00-security-scan.yml           # All 4 Phases : SAST (Checkov + Trivy),  OPA policy validation, Terraform deployment with manual approval, Drift monitoring
│   └── 02-drift-detection.yml         # Drift monitoring (scheduled)
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
- **Policy Engine:** Open Policy Agent (OPA) v0.x
- **Drift Detection:** Driftctl v0.x

### Pre-commit Framework
- **Framework:** pre-commit v3.x
- **Hooks:** Gitleaks, Terraform fmt/validate

---

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

