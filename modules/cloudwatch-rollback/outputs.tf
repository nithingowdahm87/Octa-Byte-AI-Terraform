output "composite_alarm_name" {
  value = aws_cloudwatch_composite_alarm.canary_rollback_trigger.alarm_name
}
