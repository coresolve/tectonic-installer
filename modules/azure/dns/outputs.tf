output "ingress_external_fqdn" {
  value = "${var.cluster_name}.${azurerm_dns_zone.tectonic_azure_dns_zone.name}"
}

output "ingress_internal_fqdn" {
  value = "${var.cluster_name}.${azurerm_dns_zone.tectonic_azure_dns_zone.name}"
}

output "api_external_fqdn" {
  value = "kubeapserver.${azurerm_dns_zone.tectonic_azure_dns_zone.name}"
}

output "api_internal_fqdn" {
  value = "kubeapiserver.${azurerm_dns_zone.tectonic_azure_dns_zone.name}"
}
