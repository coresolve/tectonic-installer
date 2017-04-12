variable "tectonic_cluster_name" {
  type = "string"
}

variable "tectonic_azure_vnet_cidr_block" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "tectonic_azure_external_vnet_id" {
  type    = "string"
  default = ""
}


variable "tectonic_azure_external_master_subnet" {
  type    = "string"
  default = ""
}

variable "tectonic_azure_external_worker_subnet" {
  type    = "string"
  default = ""
}

variable "resource_group_name" {
  type = "string"
}

variable "vnet_cidr_block" {
  type = "string"
}

variable "master_subnet_id" {
  type = "string"
}

variable "worker_subnet_id" {
  type = "string"
}

variable "location" {
  type = "string"
}
