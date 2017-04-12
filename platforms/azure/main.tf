resource "azurerm_resource_group" "tectonic_cluster" {
  count    = "${var.external_resource_group_name == "" ? 1 : 0}"
  location = "${var.tectonic_azure_location}"
  name     = "tectonic-cluster-${var.tectonic_cluster_name}"
}

data "azurerm_resource_group" "tectonic_group" {
  # The join() hack is required because currently the ternary operator
  # evaluates the expressions on both branches of the condition before
  # returning a value. When providing and external VPC, the template VPC
  # resource gets a count of zero which triggers an evaluation error.
  #
  # This is tracked upstream: https://github.com/hashicorp/hil/issues/50
  #
  name = "${var.tectonic_azure_external_resource_group == "" ? join(" ", azurerm_resource_group.tectonic_cluster.name ) : var.tectonic_azure_external_resource_group }"
}

module "vnet" {
  source = "../../modules/azure/vnet"

  location                = "${var.tectonic_azure_location}"
  resource_group_name     = "${data.azurerm_resource_group.tectonic_group.name}"
  tectonic_cluster_name   = "${var.tectonic_cluster_name}"
  vnet_cidr_block         = "${var.tectonic_azure_vnet_cidr_block}"
  vnet_name               = "${data.azurerm_virtual_network.tectonic_vnet.name}"
  vnet_worker_subnet      = "${data.azurerm_subnet.worker_subnet.name}"
  external_vnet_name      = "${var.tectonic_azure_external_vnet_name}"
  external_master_subnet  = "${var.tectonic_azure_external_master_subnet}"
  external_worker_subnet  = "${var.tectonic_azure_external_worker_subnet}"

}

module "etcd" {
  source = "../../modules/azure/etcd"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${data.azurerm_resource_group.tectonic_group.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_etcd_vm_size}"

  etcd_count          = "${var.tectonic_etcd_count}"
  base_domain         = "${var.tectonic_base_domain}"
  cluster_name        = "${var.tectonic_cluster_name}"
  ssh_key             = "${var.tectonic_azure_ssh_key}"
  virtual_network     = "${module.vnet.vnet_name}"
  subnet              = "${module.vnet.master_subnet_name}"
}

module "masters" {
  source = "../../modules/azure/master"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${data.azurerm_resource_group.tectonic_group.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_master_vm_size}"

  master_count                 = "${var.tectonic_master_count}"
  base_domain                  = "${var.tectonic_base_domain}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_name}"
  subnet                       = "${module.vnet.master_subnet_name}"
  kube_image_url               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  etcd_endpoints               = ["${module.etcd.ip_address}"]
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/master"
}

module "workers" {
  source = "../../modules/azure/worker"

  location                     = "${var.tectonic_azure_location}"
  resource_group_name          = "${data.azurerm_resource_group.tectonic_group.name}"
  image_reference              = "${var.tectonic_azure_image_reference}"
  vm_size                      = "${var.tectonic_azure_worker_vm_size}"

  worker_count                 = "${var.tectonic_worker_count}"
  base_domain                  = "${var.tectonic_base_domain}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_name}"
  subnet                       = "${module.vnet.worker_subnet_name}"
  kube_image_url               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  etcd_endpoints               = ["${module.etcd.ip_address}"]
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/node"
}

module "dns" {
  source = "../../modules/azure/dns"

  master_ip_addresses = "${module.masters.ip_address}"
  console_ip_address  = "${module.masters.console_ip_address}"
  etcd_ip_addresses   = "${module.etcd.ip_address}"

  base_domain         = "${var.tectonic_base_domain}"
  cluster_name        = "${var.tectonic_cluster_name}"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${data.azurerm_resource_group.tectonic_group.name}"

  // TODO etcd list
  // TODO worker list
}
