resource "aws_ssm_parameter" "active_color" {
  name  = "/${var.project_name}/${var.environment}/active-color"
  type  = "String"
  value = "stable"
  
  lifecycle {
    ignore_changes = [value]
  }
}

module "vpc" {
  source                   = "../../modules/vpc"
  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zone_count  = var.availability_zone_count
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  tags                     = var.tags
}

module "security-groups" {
  source       = "../../modules/security-groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  tags         = var.tags
}

module "secrets" {
  source       = "../../modules/secrets"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "rds" {
  source               = "../../modules/rds"
  project_name         = var.project_name
  environment          = var.environment
  private_db_subnet_ids = module.vpc.private_db_subnets
  rds_sg_id = module.security-groups.rds_sg_id
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_master_password = "dummy"
  rds_kms_key_arn = module.kms.rds_kms_key_arn
  db_multi_az = false
  db_port = 5432
  db_deletion_protection = false
  db_skip_final_snapshot = true
  db_max_allocated_storage = 100
  db_master_username = var.db_username
  db_backup_retention_days = 7
  tags                 = var.tags
}

module "kms" {
  enable_key_rotation = true
  delete_wait_days = 7
  source       = "../../modules/kms"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "alb-canary" {
  source                         = "../../modules/alb-canary"
  project_name                   = var.project_name
  environment                    = var.environment
  vpc_id                         = module.vpc.vpc_id
  public_subnet_ids              = module.vpc.public_subnets
  alb_sg_id                      = module.security-groups.alb_sg_id
  application_port               = var.application_port
  health_check_path              = var.health_check_path
  alb_enable_deletion_protection = var.alb_enable_deletion_protection
  enable_https                   = false
  acm_certificate_arn            = ""
  tags                           = var.tags
  stable_weight                    = var.stable_weight
  canary_weight                   = var.canary_weight
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment





  tags         = var.tags
}

module "compute-stable" {
  source                     = "../../modules/compute"
  project_name               = var.project_name
  environment                = "${var.environment}-stable"
  app_sg_id                  = module.security-groups.ec2_sg_id
  ec2_instance_profile_name  = module.iam.ec2_instance_profile_name
  root_volume_size           = var.root_volume_size
  root_volume_type           = var.root_volume_type
  ebs_kms_key_arn            = module.kms.ebs_kms_key_arn
  enable_detailed_monitoring = var.enable_detailed_monitoring
  user_data                  = templatefile("${path.module}/user-data.sh.tftpl", {
    db_host_secret_arn = module.secrets.rds_secret_arn
    region             = var.aws_region
  })
  tags                       = var.tags
}

module "asg-stable" {
  source                          = "../../modules/asg-scaling"
  project_name                    = var.project_name
  environment                     = "${var.environment}-stable"
  launch_template_id              = module.compute-stable.launch_template_id
  instance_warmup_seconds = 300
  #  module.compute-stable.launch_template_latest_version
  private_app_subnet_ids = module.vpc.private_app_subnets
  target_group_arn = module.alb-canary.target_group_stable_arn
  asg_min_size = 1 # Ensure at least 1 running here
  asg_max_size = var.asg_max_size
  asg_desired_capacity = 1
  # health_check_type = "ELB"
  # health_check_grace_period = 300
  cpu_target_value = var.target_tracking_target_value
  tags                            = var.tags
}

module "compute-canary" {
  source                     = "../../modules/compute"
  project_name               = var.project_name
  environment                = "${var.environment}-canary"
  app_sg_id                  = module.security-groups.ec2_sg_id
  ec2_instance_profile_name  = module.iam.ec2_instance_profile_name
  root_volume_size           = var.root_volume_size
  root_volume_type           = var.root_volume_type
  ebs_kms_key_arn            = module.kms.ebs_kms_key_arn
  enable_detailed_monitoring = var.enable_detailed_monitoring
  user_data                  = templatefile("${path.module}/user-data.sh.tftpl", {
    db_host_secret_arn = module.secrets.rds_secret_arn
    region             = var.aws_region
  })
  tags                       = var.tags
}

module "asg-canary" {
  source                          = "../../modules/asg-scaling"
  project_name                    = var.project_name
  environment                     = "${var.environment}-canary"
  launch_template_id              = module.compute-canary.launch_template_id
  instance_warmup_seconds = 300
  #  module.compute-canary.launch_template_latest_version
  private_app_subnet_ids = module.vpc.private_app_subnets
  target_group_arn = module.alb-canary.target_group_canary_arn
  asg_min_size = 1
  asg_max_size = var.asg_max_size
  asg_desired_capacity = 1
  # health_check_type = "ELB"
  # health_check_grace_period = 300
  cpu_target_value = var.target_tracking_target_value
  tags                            = var.tags
}

module "cloudwatch-rollback" {
  sns_topic_arn = module.rollback-safety.sns_topic_arn
  source         = "../../modules/cloudwatch-rollback"
  project_name   = var.project_name
  environment    = var.environment
  alb_arn_suffix = module.alb-canary.alb_arn_suffix
}

resource "aws_ssm_parameter" "deployment_state" {
  name  = "/${var.project_name}/${var.environment}/canary/deployment-state"
  type  = "String"
  value = "SUCCEEDED"
  lifecycle { ignore_changes = [value] }
}

module "release-controller" {
  source = "../../modules/release-controller"
  project_name = var.project_name
  environment = var.environment
  listener_arn = module.alb-canary.alb_arn
  stable_tg_arn = module.alb-canary.target_group_stable_arn
  canary_tg_arn = module.alb-canary.target_group_canary_arn
}

module "rollback-safety" {
  source = "../../modules/rollback-safety"
  project_name = var.project_name
  environment = var.environment
  deployment_state_param = aws_ssm_parameter.deployment_state.name
  release_controller_func = "${var.project_name}-${var.environment}-release-controller"
}
