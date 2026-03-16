output "rule_name" {
  description = "EventBridge rule name."
  value       = try(aws_cloudwatch_event_rule.rule[0].name, null)
}

output "rule_arn" {
  description = "EventBridge rule ARN."
  value       = try(aws_cloudwatch_event_rule.rule[0].arn, null)
}