variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group location in Azure"
}

variable "service_plan_name" {
  type        = string
  description = "Service plan name in Azure"
}

variable "app_service_name" {
  type        = string
  description = "App service name in Azure"
}

variable "sql_server_name" {
  type        = string
  description = "SQL server name in Azure"
}

variable "sql_database_name" {
  type        = string
  description = "SQL DB name in Azure"
}

variable "sql_admin_login" {
  type        = string
  description = "SQL Admin name in Azure"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL Admin password in Azure"
}

variable "firewall_rule_name" {
  type        = string
  description = "SQL firewall rule name in Azure"
}
variable "repo_url" {
  type        = string
  description = "The address of the repo in github"

}