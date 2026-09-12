# Octa Byte AI Infrastructure & Deployment

This repository contains the Terraform infrastructure code and CI/CD documentation for the Octa Byte AI assessment.

## Repository Structure
- **application/** (Application Code & GitHub Actions CI/CD)
- **terraform/** (Infrastructure as Code)
  - `bootstrap/` - Terraform backend setup (S3 + DynamoDB)
  - `modules/` - Reusable Terraform modules
  - `environments/staging/` - Staging Environment
  - `environments/production/` - Production Environment

## How to Set Up and Run the Infrastructure
1. **Prerequisites:**
   - AWS CLI configured with administrator access.
   - Terraform (>= 1.5.0)
   - A GitHub repository with OIDC configured for AWS.

2. **Bootstrap Backend:**
   ```bash
   cd terraform/bootstrap
   terraform init && terraform apply -auto-approve
   ```

3. **Deploy Staging:**
   ```bash
   cd terraform/environments/staging
   terraform init
   terraform apply -auto-approve
   ```

4. **Deploy Production:**
   ```bash
   cd terraform/environments/production
   terraform init
   terraform apply -auto-approve
   ```

## Architecture Decisions
- **Immutable Infrastructure:** EC2 instances are created via Auto Scaling Groups and Launch Templates. No direct SSH access is needed; SSM is used for deployment and access.
- **Canary Deployments (Production):** A Blue/Green ASG architecture was implemented using an active/inactive slot system. The CI/CD pipeline deploys the new Docker container to the inactive slot, shifts ALB weights to 50/50, and monitors CloudWatch composite alarms. If errors/latency spike, it automatically shifts traffic back to the healthy slot.
- **Database:** Amazon RDS for PostgreSQL in a private subnet, utilizing AWS Secrets Manager for credential rotation.

## Security Considerations
- **No Public Instances:** All EC2 instances and RDS databases reside in private subnets. Only the ALB resides in the public subnet.
- **Least Privilege IAM:** Roles are strictly scoped. GitHub Actions uses OIDC (no hardcoded keys). EC2 Instance Profiles only have access to specific ECR repositories, SSM parameters, and Secrets.
- **Encryption:** KMS is used for EBS volumes, RDS, Secrets Manager, and SSM Parameters.
- **Security Scanning:** Trivy, Gitleaks, and OWASP ZAP are integrated into the GitHub Actions CI/CD pipeline.

## Cost Optimization Measures
- **Graviton Instances:** `t4g.micro` / `t4g.small` ARM-based Graviton instances are used for the application tier to significantly reduce compute costs.
- **Auto Scaling:** Minimum bounds are kept low (e.g., 1 per slot) and automatically scale based on CPU utilization metrics to ensure capacity closely tracks demand.
- **Lifecycle Policies:** ECR is configured to only retain the 5 most recent container images, keeping storage costs minimal.
- **S3 Tiering:** State buckets are configured to transition non-current versions to cheaper storage tiers.

