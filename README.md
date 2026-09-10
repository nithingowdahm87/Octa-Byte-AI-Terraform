# OctaByte-Nithin Infrastructure (Terraform)

This repository provisions the secure, VPC-isolated infrastructure for the OctaByte-Nithin project.

## Architecture

- **Staging VPC (10.10.0.0/16)**: Single ASG, isolated test environment.
- **Production VPC (10.20.0.0/16)**: Canary release environment containing two Auto Scaling Groups (Stable and Canary).

### Real Canary Deployment

Unlike a Blue/Green cutover, this environment performs a true Canary release:
- `Stable` ASG and `Canary` ASG receive independent AWS Lambda-controlled traffic weights (e.g. 50/50).
- The `release-controller` Lambda adjusts ALB Listener Rules, preventing Terraform state drift during live traffic shifts.
- If CloudWatch Composite Alarms detect elevated 5XX errors or latency during the 5-minute canary window, an SNS-triggered `rollback-safety` Lambda automatically reverts weights to `100/0` instantly.

### EC2 Bootstrap (Immutable Deployment)

EC2 instances use **Amazon Linux 2023** dynamically resolved via SSM Parameter Store.
`user-data` uses `dnf` to install `docker`, `amazon-cloudwatch-agent`, and `amazon-ssm-agent`.
Images are deployed exclusively by their immutable `sha256` digest via VPC endpoints, removing the need for SSH access.

## Runbook

### Terraform Bootstrap
```bash
make bootstrap-init
make bootstrap-apply
```

### Staging Apply
```bash
ENV=staging make init
ENV=staging make plan
ENV=staging make apply
```

### Manual Rollback
If a deployment degrades and the auto-rollback safety net fails:
1. Log into AWS Console -> Lambda.
2. Invoke `octabyte-nithin-production-release-controller` with:
   `{"environment": "production", "stable_weight": 100, "canary_weight": 0, "deployment_id": "manual"}`
3. The active slot (tracked in `/octabyte-nithin/production/active-slot`) will instantly receive 100% traffic.
