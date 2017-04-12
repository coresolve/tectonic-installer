resource "azurerm_subnet" "new_master_subnet" {
  count                = "${var.tectonic_azure_external_master_subnet == ? 1 : 0 }"
  name                 = "${var.tectonic_cluster_name}_master_subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${tectonic_azure_external_vnet_name}"
  address_prefix       = "${cidrsubnet(azurerm_virtual_network.tectonic_vnet.address_space[0], 4, 0)}"
}

data "azurerm_subnet" "master_subnet" {
  # The join() hack is required because currently the ternary operator
  # evaluates the expressions on both branches of the condition before
  # returning a value. When providing and external VPC, the template VPC
  # resource gets a count of zero which triggers an evaluation error.
  #
  # This is tracked upstream: https://github.com/hashicorp/hil/issues/50
  #
  id = "${var.tectonic_azure_external_master_subnet == "" ? join(" ", azurerm_subnet.new_master_subnet.id) : "/subscriptions/" + ${TF_VARS_ARM_SUBSCRIPTION_ID} + "/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/" + ${vnet_name} + "/subnets/${azurerm_subnet.master_subnet.name" }"
}
