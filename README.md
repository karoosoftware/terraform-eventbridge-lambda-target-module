# AWS EventBridge Lambda Target Module

This module creates a single AWS EventBridge rule with one or more Lambda targets and the required Lambda invoke permissions. It supports both event-pattern rules and scheduled rules.

## What This Module Creates

- 1 EventBridge rule
- 1 or more EventBridge targets for Lambda functions
- Lambda invoke permissions for EventBridge

## Usage

Scheduled rule example:

```hcl
module "eventbridge_lambda_target" {
  source = "git::ssh://git@github.com/karoosoftware/terraform-eventbridge-lambda-target-module.git?ref=<commit-sha>"

  rule_name = "weekly-seeder"

  schedule_expression = "cron(0 3 ? * MON *)"

  lambda_targets = [
    {
      name       = "weekly-seeder"
      lambda_arn = "arn:aws:lambda:eu-west-2:123456789012:function:weekly-seeder"
      input = jsonencode({
        job = "weekly-seeder"
      })
    }
  ]

  tags = {
    Environment = "prod"
    Service     = "leaderboards"
  }
}
```

Event-pattern rule example:

```hcl
module "eventbridge_lambda_target" {
  source = "git::ssh://git@github.com/karoosoftware/terraform-eventbridge-lambda-target-module.git?ref=<commit-sha>"

  rule_name = "cognito-delete-user-audit"

  event_pattern = {
    source      = ["aws.cognito-idp"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["cognito-idp.amazonaws.com"]
      eventName   = ["AdminDeleteUser", "DeleteUser"]
    }
  }

  lambda_targets = [
    {
      name       = "cognito-delete-user-audit"
      lambda_arn = "arn:aws:lambda:eu-west-2:123456789012:function:cognito-delete-user-audit"
      input_path = "$.detail"
    }
  ]

  tags = {
    Environment = "prod"
    Service     = "auth"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `enabled` | Whether to create the EventBridge rule, Lambda targets, and invoke permissions | `bool` | `true` | no |
| `rule_name` | Name of the EventBridge rule | `string` | n/a | yes |
| `event_pattern` | Event pattern object for an EventBridge rule. Exactly one of `event_pattern` or `schedule_expression` must be set | `any` | `null` | no |
| `schedule_expression` | Schedule expression for a scheduled EventBridge rule, for example `cron(...)` or `rate(...)`. Exactly one of `event_pattern` or `schedule_expression` must be set | `string` | `null` | no |
| `lambda_targets` | Lambda targets for the EventBridge rule | `list(object({ name = string, lambda_arn = string, input = optional(string), input_path = optional(string) }))` | n/a | yes |
| `tags` | Tags to apply to the EventBridge rule | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `rule_name` | Name of the EventBridge rule |
| `rule_arn` | ARN of the EventBridge rule |

## Notes

- This module supports both event-pattern rules and scheduled rules.
- Exactly one of `event_pattern` or `schedule_expression` must be set.
- At least one Lambda target must be provided.
- Each Lambda target name must be unique.
- A Lambda target cannot set both `input` and `input_path`.
- Non-Lambda EventBridge targets are out of scope for this module.

## Release Process

- Open a pull request and let the Terraform validation workflow pass.
- Merge the change to `main`.
- Create and push a version tag, for example:

```bash
git tag v1.0.0
git push origin v1.0.0
```

- Pushing the tag triggers the release workflow and creates the GitHub release.
- Consume released versions from other Terraform repos by pinning the module source with `?ref=v1.0.0`.

## Prerequisites

- Terraform 1.5 or later
- AWS provider configured in the root module
- IAM permissions to create EventBridge rules, EventBridge targets, and Lambda permissions
