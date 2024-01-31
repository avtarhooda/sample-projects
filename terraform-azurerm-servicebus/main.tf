
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_servicebus_namespace" "namespace" {
  name                = lookup(var.servicebus_namespaces, "name")
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.resource_group_name
  sku                 = lookup(var.servicebus_namespaces, "sku", "Basic")
  capacity            = lookup(var.servicebus_namespaces, "capacity")
  zone_redundant      = lookup(var.servicebus_namespaces, "zone_redundant", null)
  local_auth_enabled  = lookup(var.servicebus_namespaces, "local_auth_enabled", null)
  tags                = var.tags
}

resource "azurerm_servicebus_namespace_authorization_rule" "rule" {
  for_each     = var.namespace_authorization_rule == null ? {} : var.namespace_authorization_rule
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.namespace.id

  listen = lookup(each.value, "listen", false)
  send   = lookup(each.value, "send", false)
  manage = lookup(each.value, "manage", false)
}

resource "azurerm_servicebus_queue" "queue" {
  for_each                                = var.servicebus_namespaces_queue == null ? {} : var.servicebus_namespaces_queue
  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.namespace.id
  auto_delete_on_idle                     = lookup(each.value, "auto_delete_on_idle", null)
  default_message_ttl                     = lookup(each.value, "default_message_ttl", null)
  enable_batched_operations               = lookup(each.value, "enable_batched_operations", null)
  duplicate_detection_history_time_window = lookup(each.value, "duplicate_detection_history_time_window", null)
  enable_express                          = lookup(each.value, "enable_express", false)
  enable_partitioning                     = lookup(each.value, "enable_partitioning", false)
  lock_duration                           = lookup(each.value, "lock_duration", false)
  max_size_in_megabytes                   = lookup(each.value, "max_size_in_megabytes", null)
  requires_duplicate_detection            = lookup(each.value, "requires_duplicate_detection", false)
  requires_session                        = lookup(each.value, "requires_session", false)
  dead_lettering_on_message_expiration    = lookup(each.value, "dead_lettering_on_message_expiration", null)
  max_delivery_count                      = lookup(each.value, "max_delivery_count", null)
  max_message_size_in_kilobytes           = lookup(each.value, "max_message_size_in_kilobytes", null)
  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    read   = lookup(var.timeouts, "read", null)
    delete = lookup(var.timeouts, "delete", null)
  }
  depends_on = [
    azurerm_servicebus_namespace.namespace
  ]
}


resource "azurerm_servicebus_topic" "topic" {
  for_each                                = var.servicebus_topic == null ? {} : var.servicebus_topic
  auto_delete_on_idle                     = lookup(each.value, "auto_delete_on_idle")
  default_message_ttl                     = lookup(each.value, "default_message_ttl")
  duplicate_detection_history_time_window = lookup(each.value, "duplicate_detection_history_time_window")
  enable_batched_operations               = lookup(each.value, "enable_batched_operations")
  enable_express                          = lookup(each.value, "enable_express")
  enable_partitioning                     = lookup(each.value, "enable_partitioning")
  max_message_size_in_kilobytes           = lookup(each.value, "max_message_size_in_kilobytes")
  max_size_in_megabytes                   = lookup(each.value, "max_size_in_megabytes")
  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.namespace.id
  status                                  = lookup(each.value, "status")
  support_ordering                        = lookup(each.value, "support_ordering")
  depends_on = [
    azurerm_servicebus_namespace.namespace
  ]
}

resource "azurerm_servicebus_topic_authorization_rule" "rule" {
  for_each = var.topic_authorization_rule == null ? {} : var.topic_authorization_rule
  name     = lookup(each.value, "name")
  topic_id = azurerm_servicebus_topic.topic[each.value.topic].id
  listen   = lookup(each.value, "listen")
  send     = lookup(each.value, "send")
  manage   = lookup(each.value, "manage")
  depends_on = [
    azurerm_servicebus_namespace.namespace, azurerm_servicebus_topic.topic
  ]
}

resource "azurerm_servicebus_subscription" "sub" {
  for_each                                  = var.servicebus_subscription == null ? {} : var.servicebus_subscription
  auto_delete_on_idle                       = lookup(each.value, "auto_delete_on_idle")
  dead_lettering_on_filter_evaluation_error = lookup(each.value, "dead_lettering_on_filter_evaluation_error")
  dead_lettering_on_message_expiration      = lookup(each.value, "dead_lettering_on_message_expiration")
  default_message_ttl                       = lookup(each.value, "default_message_ttl")
  enable_batched_operations                 = lookup(each.value, "enable_batched_operations")
  lock_duration                             = lookup(each.value, "lock_duration")
  max_delivery_count                        = lookup(each.value, "max_delivery_count")
  name                                      = lookup(each.value, "name")
  requires_session                          = lookup(each.value, "requires_session")
  status                                    = lookup(each.value, "status")
  client_scoped_subscription_enabled        = lookup(each.value, "client_scoped_subscription_enabled", false)
  topic_id                                  = azurerm_servicebus_topic.topic[each.value.topic].id
  depends_on = [
    azurerm_servicebus_namespace.namespace, azurerm_servicebus_topic.topic
  ]
}

resource "azurerm_servicebus_subscription_rule" "rule" {
  for_each        = var.servicebus_subscription_rule == null ? {} : var.servicebus_subscription_rule
  name            = lookup(each.value, "name")
  subscription_id = azurerm_servicebus_subscription.sub[each.key].id
  filter_type     = lookup(each.value, "filter_type")
  sql_filter      = lookup(each.value, "sql_filter")
}

resource "azurerm_servicebus_namespace_network_rule_set" "rule" {
  namespace_id                  = azurerm_servicebus_namespace.namespace.id
  default_action                = var.default_action
  public_network_access_enabled = var.public_network_access_enabled
  trusted_services_allowed      = var.trusted_services_allowed
  ip_rules                      = var.ip_rules
  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : var.network_rules
    content {
      subnet_id                            = lookup(network_rules.value, "subnet_id")
      ignore_missing_vnet_service_endpoint = lookup(network_rules.value, "ignore_missing_vnet_service_endpoint")
    }
  }
}



