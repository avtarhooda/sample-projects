variable "name" {

  type = string
}
variable "message" {

  type = string
}
variable "query" {

  type = string
}
variable "type" {

  type = string
}
variable "priority" {

  type    = string
  default = null
}
variable "escalation_message" {

  type    = string
  default = null
}
variable "timeout_h" {

  type    = number
  default = null
}
variable "evaluation_delay" {

  type    = number
  default = null
}
variable "notify_no_data" {

  type    = bool
  default = false
}
variable "enable_logs_sample" {

  type    = bool
  default = null
}
variable "force_delete" {

  type    = bool
  default = null
}

variable "group_retention_duration" {

  type    = string
  default = null
}

variable "groupby_simple_monitor" {

  type    = bool
  default = null
}

variable "include_tags" {

  type    = bool
  default = true
}
variable "tags" {

  type    = set(string)
  default = []
}
variable "new_group_delay" {

  type    = number
  default = null
}
variable "new_host_delay" {

  type    = number
  default = 300
}
variable "no_data_timeframe" {

  type    = number
  default = 10
}
variable "notification_preset_name" {

  type    = string
  default = null
}
variable "notify_audit" {

  type    = bool
  default = false
}
variable "notify_by" {

  type    = set(string)
  default = []
}
variable "on_missing_data" {

  type    = string
  default = null
}
variable "renotify_interval" {

  type    = number
  default = null
}
variable "renotify_occurrences" {

  type    = number
  default = null
}
variable "renotify_statuses" {

  type    = set(string)
  default = []
}
variable "require_full_window" {

  type    = bool
  default = null
}
variable "restricted_roles" {

  type    = set(string)
  default = []
}
variable "validate" {

  type    = bool
  default = null
}
variable "monitor_threshold_windows" {

  type = list(object({
    recovery_window = string
    trigger_window  = string
  }))
  default = null
}
variable "monitor_thresholds" {

  type = list(object({
    critical          = optional(number)
    critical_recovery = optional(number)
    ok                = optional(number)
    unknown           = optional(number)
    warning           = optional(number)
    warning_recovery  = optional(number)
  }))
  default = null
}

variable "scheduling_options" {

  type = list(object({
    evaluation_window = list(object({
      day_starts   = optional(string)
      hour_starts  = optional(number)
      month_starts = optional(number)
    }))
  }))
  default = null
}
variable "variables" {

  type = list(object({
    event_query = optional(list(object({
      data_source = string
      name        = string
      compute = list(object({
        aggregation = number
        interval    = optional(number)
        metric      = optional(string)
      }))
      search = list(object({
        query = string
      }))
      group_by = optional(list(object({
        facet = string
        limit = optional(number)
        sort = optional(list(object({
          aggregation = string
          metric      = optional(string)
          order       = optional(string)
        })))
      })))
    })))
  }))
  default = null
}

