variable "resource_group_name" {
  type = string
}

variable "tags" {
  default = {}
  type    = map(string)
}

variable "servicebus_namespaces" {
  type = object({
    name               = string
    sku                = string
    capacity           = string
    zone_redundant     = bool
    local_auth_enabled = bool
  })
  default = null
}

variable "namespace_authorization_rule" {
  type = map(object({
    listen = optional(bool)
    send   = optional(bool)
    manage = optional(bool)
  }))
  default = null
}

variable "timeouts" {
  type    = map(string)
  default = {}
}

variable "servicebus_namespaces_queue" {
  type = map(object({
    auto_delete_on_idle                     = string
    default_message_ttl                     = string
    duplicate_detection_history_time_window = string
    enable_express                          = bool
    enable_partitioning                     = bool
    lock_duration                           = string
    max_size_in_megabytes                   = string
    requires_duplicate_detection            = bool
    requires_session                        = bool
    dead_lettering_on_message_expiration    = string
    max_delivery_count                      = string
    enable_batched_operations               = bool
    max_message_size_in_kilobytes           = string
  }))
  default = null
}

variable "servicebus_topic" {
  type = map(object({
    auto_delete_on_idle                     = string
    default_message_ttl                     = string
    duplicate_detection_history_time_window = string
    enable_batched_operations               = bool
    enable_express                          = bool
    enable_partitioning                     = bool
    max_message_size_in_kilobytes           = string
    max_size_in_megabytes                   = string
    status                                  = string
    requires_duplicate_detection            = bool
    support_ordering                        = bool
  }))
  default = null
}

variable "servicebus_subscription" {
  type = map(object({
    auto_delete_on_idle                       = string
    dead_lettering_on_filter_evaluation_error = bool
    dead_lettering_on_message_expiration      = bool
    default_message_ttl                       = string
    enable_batched_operations                 = bool
    lock_duration                             = string
    max_delivery_count                        = string
    requires_session                          = bool
    status                                    = string
    topic                                     = string
    name                                      = string
    client_scoped_subscription_enabled        = optional(bool)
  }))
  default = null
}

variable "servicebus_subscription_rule" {
  type = map(object({
    name        = string
    filter_type = string
    sql_filter  = string
  }))
  default = null
}

variable "topic_authorization_rule" {
  type = map(object({
    name   = string
    listen = bool
    send   = bool
    manage = bool
    topic  = string
  }))
  default = null
}

variable "default_action" {
  type = string

  default = "Deny"
}

variable "public_network_access_enabled" {
  type = bool

  default = true
}

variable "trusted_services_allowed" {
  type = bool

  default = false
}

variable "ip_rules" {
  type = list(string)

  default = null
}

variable "network_rules" {
  type = list(object({
    subnet_id                            = string
    ignore_missing_vnet_service_endpoint = optional(bool)
  }))

  default = null
}