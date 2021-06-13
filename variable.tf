variable "location" {
  description = "(Optional) The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = string
  default     = "westus2"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where all the resources will be imported."
  type        = string
  default     = "jfrog"
}

variable "platform" {
  description = "The name of the platform where resources will be imported."
  type        = string
  default     = "az"
}

variable "environment" {
  description = "The name of the environment with resources will be created."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "The name of the owner (co. name)with resources will be created."
  type        = string
  default     = "microsoft"
}

##variables for virtual machines, not using now
#variable "vm01" {
#  description = "Name of the VM01"
#  type        = string
#  default     = "jfrogapp01"
#}
#
#variable "vm02" {
#  description = "Name of the VM02"
#  type        = string
#  default     = "jfrogapp02"
#}
##variables for load balancer
variable "lb_front_01" {
  description = "Portof the VM02"
  type        = string
  default     = "22"
}

variable "lb_front_02" {
  description = "port allow for LB"
  type        = string
  default     = "80"
}

variable "lb_backnd_03" {
  description = "port allow for LB"
  type        = string
  default     = "443"
}

variable "lb_front_03" {
  description = "port allow for LB"
  type        = string
  default     = "443"
}

variable "lb_backnd_02" {
  description = "port allow for LB"
  type        = string
  default     = "80"
}

variable "scfile" {
    type = string
    default = "yum.bash"
}

variable "scriptfile" {
    type = string
    default = "yum.bash"
}

variable "artifactory_version" {
  description = "Artifactory version to deploy"
  default     = "7.19.4"
}

variable "db_name" {
  description = "MySQL database name"
  default = "artdb"
}

variable "db_user" {
  description = "Database user name"
  default     = "artifactory"
}

variable "db_password" {
  description = "Database password"
  default     = "password"
}