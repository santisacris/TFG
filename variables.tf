variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "IaC-Developers"
}
