# Terraform + Jenkins CI/CD – End‑to‑End Guide

This README documents the **exact end‑to‑end steps** followed to build and fix a working **Terraform Jenkins pipeline** using:

* Azure authentication via Jenkins credentials
* Terraform root folder + single module folder
* Manual approval before apply
* Common errors faced and how they were resolved

This is written so **any DevOps engineer or interviewer** can clearly understand the full flow.

---

## 1. Problem Statement

Terraform pipeline was failing in Jenkins with errors like:

* `Terraform initialized in an empty directory`
* `Error: No configuration files`
* `Failed to read file backend.tf`

Root cause was **Terraform running from the wrong directory** and **invalid backend configuration reference**.

---

## 2. Final Working Repository Structure

```
Infra-Framework/
└── JioCloudInfra/          # Terraform ROOT folder
    ├── main.tf
    ├── provider.tf        # Provider + backend block is here
    └── module/            # SINGLE module folder
        ├── main.tf
        └── variables.tf
```

### Important Rules

* Terraform commands **MUST run only from `JioCloudInfra/`**
* `module/` folder contains only reusable logic
* Terraform should **never** be executed inside `module/`

---

## 3. Azure Authentication Strategy

Azure authentication is done using **Service Principal credentials stored in Jenkins**.

### Jenkins Credentials Used

| Credential ID       | Purpose               |
| ------------------- | --------------------- |
| `arm-client-id`     | Azure Client ID       |
| `arm-client-secret` | Azure Client Secret   |
| `arm-sub-id`        | Azure Subscription ID |
| `arm-tenant-id`     | Azure Tenant ID       |

These are exposed to Terraform using environment variables:

```
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```

Terraform automatically picks these up via the AzureRM provider.

---

## 4. Backend Configuration Decision

There is **NO separate `backend.tf` file**.

The backend configuration is written **directly inside `provider.tf`**.

### Key Decision

Because `backend.tf` does not exist:

* ❌ `terraform init -backend-config=backend.tf` was **REMOVED**
* ✅ Only `terraform init` is used

This fixed the error:

```
Failed to read file backend.tf
```

---

## 5. Jenkins Workspace Reality

Jenkins workspace path:

```
/var/lib/jenkins/workspace/Infra-Framework
```

Inside this workspace, Terraform files are located at:

```
/var/lib/jenkins/workspace/Infra-Framework/JioCloudInfra
```

Hence Jenkins must explicitly enter this directory before running Terraform.

---

## 6. Final Production‑Ready Jenkins Pipeline

```groovy
pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('arm-client-id')
        ARM_CLIENT_SECRET   = credentials('arm-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('arm-sub-id')
        ARM_TENANT_ID       = credentials('arm-tenant-id')

        TF_ROOT = 'JioCloudInfra'
        TF_PLAN = 'tfplan'
    }

    options {
        timestamps()
        skipStagesAfterUnstable()
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Akshay-Pakade/InfraFramework-Pipeline.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_ROOT}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_ROOT}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_ROOT}") {
                    sh "terraform plan -out=${TF_PLAN}"
                }
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Approve Infrastructure Deployment?'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_ROOT}") {
                    sh "terraform apply -auto-approve ${TF_PLAN}"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```

---

## 7. Errors Faced & Fixes

### ❌ Error: No configuration files

**Reason:** Terraform executed outside Terraform root

**Fix:**

```
dir('JioCloudInfra') { terraform ... }
```

---

### ❌ Error: Failed to read file backend.tf

**Reason:** backend.tf file does not exist

**Fix:**

* Removed `-backend-config=backend.tf`
* Used plain `terraform init`

---

### ❌ Invalid option ansiColor

**Reason:** AnsiColor plugin not installed

**Fix:**

* Removed `ansiColor('xterm')` from pipeline options

---

## 8. Final Terraform Execution Flow

```
Git Checkout
   ↓
Terraform Init (root folder)
   ↓
Terraform Validate
   ↓
Terraform Plan
   ↓
Manual Approval
   ↓
Terraform Apply
```

---

## 9. Interview‑Ready Explanation (Short)

> "We use Jenkins to run Terraform from a defined root folder. Azure authentication is handled using Service Principal credentials stored securely in Jenkins. Terraform modules are kept isolated inside a module directory, and we never execute Terraform from inside modules. The pipeline enforces validation, planning, and manual approval before applying infrastructure changes, making it production‑safe."

---

## 10. Final Notes

* This setup is **production‑ready**
* Follows Terraform + Jenkins best practices
* Easily explainable in interviews
* Avoids common beginner mistakes

---

✅ **Status: Pipeline stable & working**
