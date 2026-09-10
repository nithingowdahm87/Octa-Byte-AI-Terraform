
resource "aws_db_subnet_group" "db" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-db-subnet-group" })
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.project_name}-${var.environment}-db"
  engine                  = "postgres"
  engine_version          = "15" # Or desired version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  storage_type            = "gp3"
  multi_az                = var.db_multi_az
  db_name                 = var.db_name
  username                = var.db_master_username
  password                = var.db_master_password
  port                    = var.db_port
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [var.rds_sg_id]
  storage_encrypted       = true
  kms_key_id              = var.rds_kms_key_arn
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  backup_retention_period = var.db_backup_retention_days
  backup_window           = "18:00-19:00"
  maintenance_window      = "sun:19:00-sun:20:00"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-db" })
}
