# OctaByte-Nithin Infrastructure

This repository contains the Terraform infrastructure code for the OctaByte-Nithin project.
It provisions a robust, multi-tier AWS architecture with dedicated environments for `staging` and `production`.

## Architecture

The architecture consists of two completely isolated environments, each in its own VPC.

- **Staging VPC**: `10.10.0.0/16`
- **Production VPC**: `10.20.0.0/16`

Each VPC contains:
- Public subnets for Application Load Balancers and NAT/Bastion (if applicable).
- Private app subnets for the EC2 Auto Scaling Groups.
- Private db subnets for the RDS instances.
- VPC Endpoints for Systems Manager (SSM) to allow secure shell access without public IPs.

### Compute (EC2)
EC2 instances run on `t3.micro` which is AWS Free Tier eligible.
Instead of a hardcoded AMI, the compute module dynamically resolves the latest **Amazon Linux 2023** AMI via AWS Systems Manager Parameter Store (`/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64`), ensuring the instances always boot with the latest patched OS kernel while remaining free-tier eligible.

*Note: Free tier eligibility for `t3.micro` depends on your AWS account's age and region.*

### Canary Deployment (Production Only)

Production deployments use a true Canary Rollout pattern without relying on CodeDeploy.
- **Components**: 2 Auto Scaling Groups (Blue/Green), 2 Target Groups, and 1 ALB.
- **Traffic Shift**: GitHub Actions orchestrates the shift. It deploys the new code to the idle ASG, shifts ALB listener weights to 50/50, and holds for 5 minutes.
- **Wait Loop**: During the 5-minute hold, a GitHub Actions polling loop continuously checks a CloudWatch composite alarm (5XX errors OR High Latency).
- **Finalize/Rollback**: If the alarm triggers, traffic is instantly rolled back to 100% on the old ASG and the pipeline fails. If the hold completes successfully, traffic is shifted to 100% on the new ASG.

## GitHub Actions & CI/CD

Both the Application and Terraform repositories are fully driven by GitHub Actions pipelines, notifying the `#octa-byte-ai` Slack channel.

- **AWS Authentication**: OIDC (OpenID Connect) federation is used exclusively. There are no static AWS credentials.
- **Staging Pipeline (App)**: Triggered on push to `stage`. Runs Pytest, SonarQube, Trivy SCA, Docker Build, Trivy Image Scan, and SSM Deployment.
- **Production Pipeline (App)**: Triggered on PR and Merge to `main`. Pre-merge validates with OWASP ZAP. Post-merge executes the Canary Rollout.
- **Terraform Pipeline**: Runs `tfsec`/`checkov`, `terraform plan` on PRs, and `terraform apply` on merge to `main`.

## Usage

```bash
# Initialize bootstrap
make bootstrap-init
make bootstrap-apply

# Plan/Apply staging
ENV=staging make init
ENV=staging make plan
ENV=staging make apply
```

## Repository Cleanup
In the v3 refactor, legacy artifacts such as `dev` environments, `fix_vars.py`, and empty placeholder files were removed to ensure repository hygiene.
