resource "datadog_monitor" "monitor" {
  name                     = var.name
  query                    = var.query
  type                     = var.type
  message                  = var.message
  priority                 = var.priority
  no_data_timeframe        = var.no_data_timeframe
  notification_preset_name = var.notification_preset_name
  notify_audit             = var.notify_audit
  notify_by                = var.notify_by
  on_missing_data          = var.on_missing_data
  renotify_interval        = var.renotify_interval
  renotify_occurrences     = var.renotify_occurrences
  renotify_statuses        = var.renotify_statuses
  require_full_window      = var.require_full_window
  restricted_roles         = var.restricted_roles
  validate                 = var.validate
  notify_no_data           = var.notify_no_data
  timeout_h                = var.timeout_h
  escalation_message       = var.escalation_message
  tags                     = var.tags
  evaluation_delay         = var.evaluation_delay
  enable_logs_sample       = var.enable_logs_sample
  force_delete             = var.force_delete
  group_retention_duration = var.group_retention_duration
  groupby_simple_monitor   = var.groupby_simple_monitor
  include_tags             = var.include_tags
  new_group_delay          = var.new_group_delay

  dynamic "variables" {
    for_each = var.variables == null ? [] : var.variables
    content {
      dynamic "event_query" {
        for_each = lookup(variables.value, "event_query", null) == null ? [] : lookup(variables.value, "event_query")
        content {
          data_source = lookup(event_query.value, "data_source")
          name        = lookup(event_query.value, "name")
          indexes     = lookup(event_query.value, "indexes")
          dynamic "compute" {
            for_each = lookup(event_query.value, "compute", null) == null ? [] : lookup(event_query.value, "compute")
            content {
              aggregation = lookup(compute.value, "aggregation")
              metric      = lookup(compute.value, "metric")
            }
          }
          dynamic "search" {
            for_each = lookup(event_query.value, "search", null) == null ? [] : lookup(event_query.value, "search")
            content {
              query = lookup(search.value, "query")
            }
          }
          dynamic "group_by" {
            for_each = lookup(event_query.value, "group_by", null) == null ? [] : lookup(event_query.value, "group_by")
            content {
              facet = lookup(group_by.value, "facet")
              limit = lookup(group_by.value, "limit")
              dynamic "sort" {
                for_each = lookup(group_by.value, "sort", null) == null ? [] : lookup(group_by.value, "sort")
                content {
                  aggregation = lookup(sort.value, "aggregation")
                  metric      = lookup(sort.value, "metric")
                  order       = lookup(sort.value, "order")
                }
              }
            }
          }
        }
      }
    }
  }
  dynamic "scheduling_options" {
    for_each = var.scheduling_options == null ? [] : var.scheduling_options
    content {
      dynamic "evaluation_window" {
        for_each = lookup(scheduling_options.value, "evaluation_window", null) == null ? [] : lookup(scheduling_options.value, "evaluation_window")
        content {
          day_starts   = lookup(evaluation_window.value, "day_starts")
          hour_starts  = lookup(evaluation_window.value, "hour_starts")
          month_starts = lookup(evaluation_window.value, "month_starts")
        }
      }
    }
  }
  dynamic "monitor_threshold_windows" {
    for_each = var.monitor_threshold_windows == null ? [] : var.monitor_threshold_windows
    content {
      recovery_window = lookup(monitor_threshold_windows.value, "recovery_window")
      trigger_window  = lookup(monitor_threshold_windows.value, "trigger_window")
    }
  }
  dynamic "monitor_thresholds" {
    for_each = var.monitor_thresholds == null ? [] : var.monitor_thresholds
    content {
      critical          = lookup(monitor_thresholds.value, "critical")
      critical_recovery = lookup(monitor_thresholds.value, "critical_recovery")
      ok                = lookup(monitor_thresholds.value, "ok")
      unknown           = lookup(monitor_thresholds.value, "unknown")
      warning           = lookup(monitor_thresholds.value, "warning")
      warning_recovery  = lookup(monitor_thresholds.value, "warning_recovery")
    }
  }
}
