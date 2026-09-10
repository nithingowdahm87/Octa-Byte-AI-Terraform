
resource "aws_cloudwatch_log_group" "logs" {
  for_each = toset([
    "/${var.project_name}/${var.environment}/application",
    "/${var.project_name}/${var.environment}/system",
    "/${var.project_name}/${var.environment}/cloud-init",
    "/${var.project_name}/${var.environment}/docker",
    "/${var.project_name}/${var.environment}/lambda/db-password-rotation",
    "/${var.project_name}/${var.environment}/lambda/db-username-rotation",
    "/${var.project_name}/${var.environment}/lambda/weekend-scaling"
  ])

  name              = each.key
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_kms_encryption ? var.logs_kms_key_arn : null

  tags = merge(var.tags, { Name = each.key })
}

resource "aws_sns_topic" "alerts" {
  count      = var.create_alarm_sns_topic ? 1 : 0
  name       = "${var.project_name}-${var.environment}-alerts"
  kms_key_id = var.enable_log_kms_encryption ? var.logs_kms_key_arn : null
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.create_alarm_sns_topic && var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_dashboard" "app" {
  dashboard_name = "${var.project_name}-${var.environment}-app-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0, y = 0, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Request Count"
        }
      },
      {
        type = "metric"
        x    = 12, y = 0, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ASG CPU Utilization"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "db" {
  dashboard_name = "${var.project_name}-${var.environment}-db-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0, y = 0, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_identifier]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "RDS CPU Utilization"
        }
      }
    ]
  })
}
