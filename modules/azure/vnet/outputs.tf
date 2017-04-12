output "vnet_name" {
  value = "${var.tectonic_azure_external_vnet_name == "" ? join(" ", azurerm_virtual_network.tectonic_vnet.name ) : var.tectonic_azure_external_vnet_name}"
}

# We have to do this join() & split() 'trick' because null_data_source and 
# the ternary operator can't output lists or maps
#

#output "master_subnet_id" {
#  value = "/subscriptions/${TF_VARS_ARM_SUBSCRIPTION_ID}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${output.vnet_name}/subnets/${azurerm_subnet.worker_subnet.name}"
#}

#output "worker_subnet_id" {
#  value = "/subscriptions/${TF_VARS_ARM_SUBSCRIPTION_ID}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${output.vnet_name}/subnets/${azurerm_subnet.master_subnet.name}"
#}
