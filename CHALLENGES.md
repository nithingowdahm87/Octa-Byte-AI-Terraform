# Challenges Faced and Resolutions

## 1. Circular Dependencies with Database Endpoint
**Challenge:** 
When passing the database endpoint directly to the EC2 Launch Template User Data, Terraform created a circular dependency because the ASG required the DB, but the DB took a long time to provision. During earlier iterations, a dummy hostname was passed which broke the application startup sequence, causing a `500 Internal Server Error`.
**Resolution:** 
Restructured the Terraform modules so the RDS endpoint is passed securely into the User Data script upon RDS creation. We also wrapped the Database Initialization script (`db.create_all()`) in the application to gracefully catch connection errors instead of crashing immediately.

## 2. Terraform `ResourceInUse` Error on Target Groups
**Challenge:** 
When we changed the application port from `8000` to `80`, Terraform attempted to destroy the old Application Load Balancer Target Groups while they were still bound to the ALB Listener, resulting in a `ResourceInUse` locking error.
**Resolution:** 
We used the `name_prefix` lifecycle hook coupled with `create_before_destroy = true` for the Target Groups. We also carefully ordered the `aws_lb_listener` updates to ensure Terraform swapped the Default Actions to the new Target Groups before destroying the deposed resources.

## 3. RDS Default Username Mismatch
**Challenge:** 
The RDS module provisioned the PostgreSQL instance with the default master username `appadmin`. However, the deployment script expected to dynamically fetch this from an SSM Parameter that wasn't populated in that exact format, defaulting to `admin`. This caused `FATAL: password authentication failed for user "admin"` and crashed the backend containers.
**Resolution:** 
Since the username is statically defined in the Terraform infrastructure (and handled by Secrets Manager), we updated the `user-data.sh.tftpl` to dynamically extract the `username` field directly from the AWS Secrets Manager JSON payload via `jq`, ensuring the deployment script always authenticates with the exact username the database was provisioned with.

## 4. Race Condition in Automated Canary Deployment
**Challenge:** 
The GitHub Actions Pipeline performs a Canary Deployment by issuing an `aws ssm send-command` to the newly scaled "inactive" ASG slot. However, immediately after an Auto Scaling Group refresh, the newly spawned EC2 instances hadn't finished installing and booting the AWS SSM Agent. The pipeline queried for targets, got an empty list, skipped the wait loop, and shifted production ALB traffic to an empty slot, causing a brief `502 Bad Gateway`.
**Resolution:** 
Added a robust polling loop in the GitHub Actions workflow (`production.yml`) to query `aws ssm describe-instance-information` with a filter for `PingStatus==Online`. The pipeline explicitly blocks and waits until the target instance's SSM agent comes online before executing the deployment shell script.

## 5. False Positive Health Checks During App Crashes
**Challenge:** 
The initial EC2 `user-data` deployment script validated successful deployment by executing `curl -s http://localhost:80/health`. Even when the internal Gunicorn Python server crashed and Nginx returned a `502 Bad Gateway`, `curl` successfully completed the HTTP transaction, returning a `0` exit code, which falsely signaled a successful deployment to the pipeline.
**Resolution:** 
Appended the `--fail` (`-f`) flag to the `curl` command. This ensures `curl` returns a non-zero exit code on HTTP errors (like `5XX` or `4XX`), failing the shell script and immediately notifying the CI/CD pipeline of the deployment failure.
