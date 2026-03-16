locals {
  lambda_targets_by_name = {
    for t in var.lambda_targets : t.name => t
  }
}

resource "aws_cloudwatch_event_rule" "rule" {
  count = var.enabled ? 1 : 0

  name                = var.rule_name
  event_pattern       = var.event_pattern != null ? jsonencode(var.event_pattern) : null
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_targets" {
  for_each = var.enabled ? local.lambda_targets_by_name : {}

  rule      = aws_cloudwatch_event_rule.rule[0].name
  target_id = each.key
  arn       = each.value.lambda_arn

  input      = try(each.value.input, null)
  input_path = try(each.value.input_path, null)
}

resource "aws_lambda_permission" "eventbridge_invoke" {
  for_each = var.enabled ? local.lambda_targets_by_name : {}

  statement_id  = "evb-${substr(md5("${var.rule_name}:${each.key}"), 0, 24)}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule[0].arn
}