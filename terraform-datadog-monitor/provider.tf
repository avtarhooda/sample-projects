terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "3.28.0"
    }
  }
  required_version = ">= 1.3.0"
}
