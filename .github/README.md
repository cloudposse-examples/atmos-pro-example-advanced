# atmos-pro-example-advanced

An advanced reference repository showing how to use Atmos Pro with GitHub Actions to deploy infrastructure.

## Introduction

This example goes beyond the basics to demonstrate a full-featured setup, including multiple components, dependencies,
and coordinated workflows. It’s designed to help you understand how Atmos Pro streamlines complex infrastructure
management in real-world scenarios. This example component dependency mapping is as follows:

```mermaid
---
title: Ordered Dependencies of Components
---

graph LR;
    cache --> vpc
    database --> vpc
    load-balancer --> vpc
    cluster --> vpc
    cluster --> load-balancer
    cdn --> object-storage
    cdn --> frontend
    api --> database
    api --> cluster
    frontend --> cache
    frontend --> api
```

For comprehensive documentation and advanced features, visit [atmos-pro.com/docs](https://atmos-pro.com/docs).

## Usage

### Installation

<details>
<summary><strong>Prerequisites for Running Atmos Locally</strong></summary>

In order to trigger workflows from this GitHub repository, the Atmos Pro GitHub App will execute `atmos` on your behalf
in GitHub Actions. You do not need to install anything locally.

However if you wish to execute `atmos` locally, you will need to install:

- **Atmos** - For installation instructions, visit the [Atmos installation guide](https://atmos.tools/install)
- **Terraform or OpenTofu** - Atmos requires either Terraform or OpenTofu to be installed locally. For installation
  instructions:
  - Terraform: [Install Terraform](https://developer.hashicorp.com/terraform/downloads)
  - OpenTofu: [Install OpenTofu](https://opentofu.org/docs/intro/install/)

</details>

<details>
<summary><strong>Required Prerequisites for Using Atmos Pro (Advanced Example)</strong></summary>

The following prerequisites are **required** to use this advanced example with real infrastructure:

#### Required Infrastructure Components

This advanced example requires three infrastructure components to be deployed:

1. **Terraform State Backend** - Remote state storage (S3 bucket and DynamoDB table for state locking)
2. **Terraform Plan Storage Backend** - Plan file storage (S3 bucket and DynamoDB table for storing Terraform plans
   between planning and applying phases)
3. **GitHub OIDC Integration** - Secure authentication (GitHub OIDC provider and IAM roles for GitHub Actions to
   authenticate with AWS)

#### Deployment Options

You can deploy these infrastructure components using one of the following approaches:

**Option A: Use Terraform Components**

Our reference architecture documentation for AWS provides instructions for using Terraform to manage the S3 backend.

- For the Terraform state backend setup, see:
  [Initialize Terraform State Backend](https://docs.cloudposse.com/layers/accounts/initialize-tfstate/)
- For the plan storage setup, see:
  [Setup GitOps with GitHub Actions](https://docs.cloudposse.com/layers/gitops/setup-gitops-with-github-actions/)
- For the GitHub OIDC setup, see:
  [How to use GitHub OIDC with AWS](https://docs.cloudposse.com/layers/github-actions/github-oidc-with-aws/)

**Option B: Use the CloudFormation template**

CloudFormation is a practical, Infrastructure as Code Alternative for bootstrapping the Terraform backend. With our
CloudFormation template, you can:

- Deploy all three dependencies at once using the
  [CloudFormation template for Terraform backend](https://github.com/cloudposse/aws-cloudformation-terraform-backend)
- This template creates the S3 buckets, DynamoDB tables, and GitHub OIDC provider in a single deployment

</details>

### Quick Start

Follow these steps to get started with this Atmos Pro example:

1. **Fork this repository**

   - Click the "Fork" button in the top right corner of this repository on GitHub

2. **Deploy prerequisites**

   - See the "Required Prerequisites for Using Atmos Pro (Advanced Example)" section above for deployment options

3. **Install the Atmos Pro GitHub App**

   - Follow the [Atmos Pro documentation](https://atmos-pro.com/install) to sign up for Atmos Pro and install the GitHub
     App in your forked repository.

4. **Set up GitHub Variables**

   - `ATMOS_PRO_WORKSPACE_ID` - Your Atmos Pro workspace ID.
     [Find your workspace ID](https://atmos-pro.com/docs/configure/workspaces).
   - `ATMOS_VERSION` - The version of Atmos to use (e.g., `1.181.0`,
     [see releases](https://github.com/cloudposse/atmos/releases))
   - `ATMOS_CONFIG_PATH` - Path to your Atmos configuration file (e.g., `atmos.yaml`)

   For more information about GitHub variables, see the
   [GitHub documentation](https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables).

Now to test it out, create a pull request and let Atmos Pro do the rest!

For example, you can modify an example component in `stacks/orgs/ex1/plat/dev/us-east-2/demo.yaml` and create a pull
request on GitHub to trigger the Atmos Pro workflows. Try changing the value of `foo`, sit back, and see what happens!

### How it works

This example demonstrates a comprehensive configuration for using Atmos Pro with GitHub Actions. The workflow follows
these steps:

<details>
<summary><strong>On Pull Requests</strong></summary>

When a pull request is created or updated, Atmos Pro triggers
[`atmos terraform plan`](.github/workflows/atmos-terraform-plan.yaml):

1. **Developer makes a change** - You modify your infrastructure code
2. **Code is pushed to feature branch** - Changes are committed and pushed
3. **GitHub Actions trigger Atmos affected stacks** - Atmos identifies which stacks are affected by your changes
4. **Atmos uploads affected stacks** - The affected stack configurations are uploaded to Atmos Pro
5. **Atmos Pro dispatches plan workflows** - Atmos Pro automatically runs `atmos terraform plan` for affected components
6. **Atmos Pro updates status comment** - Results are posted as a comment on your pull request

This gives you visibility into what changes will be made to your infrastructure before merging.

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant AA as GitHub Actions
    participant Atmos as Atmos CLI
    participant AP as Atmos Pro
    participant TF as Terraform
    participant AWS as AWS

    Dev->>GH: Create/update PR
    GH->>AA: Trigger workflow
    AA->>Atmos: atmos affected stacks
    Atmos->>Atmos: Identify affected stacks
    Atmos->>AP: Upload affected stacks to Atmos Pro API
    AP->>AA: Dispatch plan workflows
    AA->>Atmos: atmos terraform plan
    Atmos->>TF: terraform plan
    TF->>AWS: Check current state
    AWS->>TF: Current state
    TF->>AA: Plan results
    AA->>GH: Workflow status
    AP->>GH: Check workflow status
    AP->>GH: Update PR comment
```

</details>

<details>
<summary><strong>On Merged Pull Requests</strong></summary>

When a pull request is merged, Atmos Pro triggers
[`atmos terraform apply`](.github/workflows/atmos-terraform-apply.yaml):

1. **Pull request is merged** - Your changes are merged into the main branch
2. **GitHub Actions trigger Atmos affected stacks** - Atmos identifies which stacks need to be updated
3. **Atmos uploads affected stacks** - The affected stack configurations are uploaded to Atmos Pro
4. **Atmos Pro dispatches apply workflows** - Atmos Pro automatically runs `atmos terraform apply` for affected
   components
5. **Atmos Pro updates status comment** - Deployment results are posted as a comment on the merged PR

This ensures your infrastructure changes are automatically deployed when code is merged.

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant AA as GitHub Actions
    participant Atmos as Atmos CLI
    participant AP as Atmos Pro
    participant TF as Terraform
    participant AWS as AWS

    Dev->>GH: Merge PR
    GH->>AA: Trigger workflow
    AA->>Atmos: atmos affected stacks
    Atmos->>Atmos: Identify affected stacks
    Atmos->>AP: Upload affected stacks to Atmos Pro API
    AP->>AA: Dispatch apply workflows
    AA->>Atmos: atmos terraform apply
    Atmos->>TF: terraform apply
    TF->>AWS: Apply infrastructure changes
    AWS->>TF: Apply results
    TF->>AA: Apply results
    AA->>GH: Workflow status
    AP->>GH: Check workflow status
    AP->>GH: Update PR comment
```

</details>

For more detailed configuration options and advanced features, refer to the
[Atmos Pro documentation](https://atmos-pro.com/docs).

### Building Documentation

To build the documentation for this repository, run:

```bash
atmos docs generate readme
```

This command generates the README.md file from the README.yaml configuration.

### Repository Structure

```
.
├── .github/
│   ├── README.md              # Generated README for GitHub
│   ├── README.md.gotmpl       # Template for README generation
│   ├── workflows/             # GitHub Actions workflows
│   │   ├── atmos-pro.yaml                   # Main Atmos Pro workflow
│   │   ├── atmos-release.yaml               # Release workflow
│   │   ├── atmos-terraform-apply.yaml       # Dispatched workflow for applying Terraform changes
│   │   ├── atmos-terraform-plan.yaml        # Dispatched workflow for planning Terraform changes
│   │   ├── draft-release.yaml               # Draft release workflow
│   │   ├── labeler.yml                      # Issue/PR labeling
│   │   └── validate.yml                     # Template validation
│   ├── actions/               # GitHub Actions custom actions
│   ├── CODEOWNERS             # Repository code owners
│   ├── draft-release.yaml     # Release workflow
│   ├── labeler.yaml           # Issue/PR labeling
│   ├── mergify.yml            # Merge automation
│   ├── PULL_REQUEST_TEMPLATE.md # Pull request template
│   └── renovate.json          # Dependency updates
├── README.yaml                # Main documentation source
├── atmos.yaml                 # Atmos configuration
├── components/                # Infrastructure components
│   └── terraform/             # Example Terraform root modules
└── stacks/                    # Atmos stack configurations
    ├── catalog/               # Component catalog definitions
    ├── mixins/                # Stack mixins (atmos-pro, region, stage)
    ├── orgs/                  # Organization stacks
    │   └── ex1/               # Example organization
    │       ├── core/          # Core infrastructure
    │       └── plat/          # Platform infrastructure
    ├── schemas/               # Validation schemas
    └── workflows/             # Workflow definitions
```

## License

<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge" alt="License"></a>

<details>
<summary>Preamble to the Apache License, Version 2.0</summary>
<br/>
<br/>

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```

</details>

---

Copyright © 2017-2025 [Cloud Posse, LLC](https://cpco.io/copyright)
