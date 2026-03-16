variable "enabled" {
  description = "Whether to create the EventBridge rule, Lambda targets, and invoke permissions."
  type        = bool
  default     = true
}

variable "rule_name" {
  description = "Name of the EventBridge rule."
  type        = string
}

variable "event_pattern" {
  description = "Event pattern object for an EventBridge rule. Exactly one of event_pattern or schedule_expression must be set."
  type        = any
  default     = null

  validation {
    condition     = !var.enabled || ((var.event_pattern == null) != (var.schedule_expression == null))
    error_message = "Exactly one of event_pattern or schedule_expression must be set when enabled is true."
  }
}

variable "schedule_expression" {
  description = "Schedule expression for a scheduled EventBridge rule, for example cron(...) or rate(...). Exactly one of event_pattern or schedule_expression must be set when enabled is true."
  type        = string
  default     = null
}

variable "lambda_targets" {
  description = "Lambda targets for the EventBridge rule."
  type = list(object({
    name       = string
    lambda_arn = string
    input      = optional(string)
    input_path = optional(string)
  }))

  validation {
    condition     = !var.enabled || length(var.lambda_targets) > 0
    error_message = "At least one lambda target must be provided when enabled is true."
  }

  validation {
    condition     = !var.enabled || length(distinct([for t in var.lambda_targets : t.name])) == length(var.lambda_targets)
    error_message = "Each lambda target name must be unique."
  }

  validation {
    condition = !var.enabled || alltrue([
      for t in var.lambda_targets :
      !(try(t.input, null) != null && try(t.input_path, null) != null)
    ])
    error_message = "A lambda target cannot set both input and input_path."
  }
}

variable "tags" {
  description = "Tags to apply to the EventBridge rule."
  type        = map(string)
  default     = {}
}