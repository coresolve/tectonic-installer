resource "azurerm_virtual_network" "cluster_vnet" {
  count               = "${var.external_vnet_name == "" ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.vnet_cidr_block}"]
  location            = "${var.location}"

  tags {
    KubernetesCluster = "${var.tectonic_cluster_name}"
  }
}

data "azurerm_virtual_network" "tectonic_vnet" {
  # The join() hack is required because currently the ternary operator
  # evaluates the expressions on both branches of the condition before
  # returning a value. When providing and external VPC, the template VPC
  # resource gets a count of zero which triggers an evaluation error.
  #
  # This is tracked upstream: https://github.com/hashicorp/hil/issues/50
  #
  name = "${var.external_vnet_name == "" ? join(" ", azurerm_virtual_network.cluster_vnet.*.id) : var.external_vnet_name }"
}
