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
  db_backup_retention_days = 0
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

module "alb" {
  source                         = "../../modules/alb"
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
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment







  tags         = var.tags
}

module "compute" {
  source                     = "../../modules/compute"
  project_name               = var.project_name
  environment                = var.environment
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

module "asg-scaling" {
  source                          = "../../modules/asg-scaling"
  project_name                    = var.project_name
  environment                     = var.environment
  launch_template_id              = module.compute.launch_template_id
  instance_warmup_seconds = 300
  #  module.compute.launch_template_latest_version
  private_app_subnet_ids = module.vpc.private_app_subnets
  target_group_arn = module.alb.target_group_arn
  asg_min_size = var.asg_min_size
  asg_max_size = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  # health_check_type = "ELB"
  # health_check_grace_period = 300
  cpu_target_value = var.target_tracking_target_value
  tags                            = var.tags
}

module "github-oidc" {
  source                  = "../../modules/github-oidc"
  project_name            = var.project_name
  environment             = var.environment
  create_github_oidc_role = true
  github_org              = "nithingowdahm87"
  github_repository       = "Octa-Byte-AI-Application"
  github_branch           = "stage"
  github_environment      = "staging"
}
