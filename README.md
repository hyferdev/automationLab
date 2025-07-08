# Automation Lab - Infrastructure as Code

This repository contains the Terraform code and CI/CD pipelines to build and manage the AWS infrastructure for the "Automation Lab" project. It uses a modular, multi-environment approach to automatically deploy development (`dev`), production (`prod`), and a collaborative `sandbox` environment.

## Architecture & Technology Stack

- **Infrastructure as Code:** [Terraform](https://www.terraform.io/)
- **CI/CD:** [GitHub Actions](https://github.com/features/actions)
- **State Management & Secrets:** [Terraform Cloud](https://www.terraform.io/cloud)
- **Cloud Provider:** [Amazon Web Services (AWS)](https://aws.amazon.com/)

## Directory Structure

- **`.github/workflows/`**: Contains the GitHub Actions workflow files.
  - `terraform.yml`: The main CI/CD pipeline for planning and applying infrastructure changes.
  - `terraform-destroy.yml`: A manually-triggered workflow to destroy infrastructure.
- **`terraform/`**: The root directory for all Terraform code.
  - **`main.tf`**: The main entry point that calls the modules.
  - **`variables.tf`**: Defines the input variables for the root module.
  - **`modules/`**: Contains reusable, modular infrastructure components.
    - **`vpc/`**: A module to create a Virtual Private Cloud (VPC) and subnets.
    - **`compute/`**: A module to create EC2 instances for testing.

## CI/CD Deployment Process

The deployment process is fully automated based on Git branches:

1.  **`sandbox` Environment:** Pushing a commit to the `sandbox` branch will trigger a `terraform apply` that requires **manual approval** from a designated reviewer in GitHub. This is a safe environment for collaborators.
2.  **`dev` Environment:** Pushing a commit to the `dev` branch will automatically trigger a `terraform apply` for the development environment.
3.  **`prod` Environment:** Pushing a commit to the `main` branch will automatically trigger a `terraform apply` for the production environment.
4.  **Pull Requests:** Opening a pull request against the `main` branch will trigger a `terraform plan` to show the expected changes, but it will not apply them.

## Environment Management

This project uses **Terraform Cloud Workspaces** to manage separate environments. This is the standard and safest way to ensure state files are completely isolated.

-   The `sandbox` branch maps to the `automationLab-sandbox` workspace in Terraform Cloud.
-   The `dev` branch maps to the `automationLab-dev` workspace in Terraform Cloud.
-   The `main` branch maps to the `automationLab-prod` workspace in Terraform Cloud.

## Configuration Setup

### 1. Terraform Cloud

All infrastructure configuration variables are securely stored in Terraform Cloud. You must configure the following in your organization (`automationLab`):

-   **Three Workspaces:** `automationLab-dev`, `automationLab-prod`, and `automationLab-sandbox`.
-   **Variables:** For each workspace, navigate to the **Variables** tab and set the required Terraform variables (e.g., `vpc_cidr`, `environment`, etc.). The values should be different for each environment to ensure network isolation.

### 2. GitHub Repository

Navigate to **`Settings > Secrets and variables > Actions`** in your GitHub repository and configure the following secrets:

-   **`TF_API_TOKEN`**: An API token generated from your Terraform Cloud user account.
-   **`TF_CLOUD_ORGANIZATION`**: Your Terraform Cloud organization name (e.g., `automationLab`).
-   **`AWS_ACCOUNT_ID`**: Your 12-digit AWS Account ID, used by the pipeline to assume the correct IAM Role.

Navigate to **`Settings > Environments`** and configure three environments: `dev`, `prod`, and `sandbox`. For the `sandbox` environment, add a **"Required reviewers"** protection rule to enable the manual approval gate.

## Destroying Infrastructure

To tear down an environment, a separate, manual workflow is provided to prevent accidental deletion.

1.  Go to the **Actions** tab in the repository.
2.  Select the **Terraform Destroy** workflow.
3.  Click **Run workflow** and choose `dev`, `prod`, or `sandbox` from the dropdown menu.
4.  Confirm by clicking the green **Run workflow** button.

**Warning:** This operation is irreversible and will permanently delete all resources in the selected environment.
