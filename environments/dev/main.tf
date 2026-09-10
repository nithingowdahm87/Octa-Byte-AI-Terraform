
provider "aws" {
  region = var.aws_region
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

module "security_groups" {
  source              = "../../modules/security-groups"
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  application_port    = var.application_port
  enable_https        = var.enable_https
  create_bastion_host = var.create_bastion_host
  enable_bastion_ssh  = var.enable_bastion_ssh
  allowed_admin_cidrs = var.allowed_admin_cidrs
  tags                = var.tags
}

module "vpc_endpoints" {
  source                      = "../../modules/vpc-endpoints"
  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  vpc_id                      = module.vpc.vpc_id
  private_app_subnet_ids      = module.vpc.private_application_subnet_ids
  private_app_route_table_ids = module.vpc.private_app_route_table_ids
  vpc_endpoints_sg_id         = module.security_groups.vpc_endpoints_sg_id
  tags                        = var.tags
}
