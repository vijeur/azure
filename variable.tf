variable "location" {
  description = "(Optional) The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = string
  default     = "westus2"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where the load balancer resources will be imported."
  type        = string
  default     = "jfrog"
}

variable "vm01" {
  description = "Name of the VM01"
  type        = string
  default     = "jfrogapp01"
}

variable "vm02" {
  description = "Name of the VM02"
  type        = string
  default     = "jfrogapp02"
}

variable "application_port_01" {
  description = "Portof the VM02"
  type        = string
  default     = "22"
}

variable "application_port_02" {
  description = "Name of the VM02"
  type        = string
  default     = "80"
}