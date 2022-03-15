###
# app.tf, db.tf, es.tf outputs
###

output "app_instance_ip" {
  value = oci_core_public_ip.ReservedAppPublicIP.ip_address
}
/**output "db_instance_ip" {
  value = oci_core_public_ip.ReservedDBPublicIP.ip_address
} */
/**output "es_instance_ip" {
  value = oci_core_public_ip.ReservedESPublicIP.ip_address
} */

###
# network.tf outputs
###

output "vcn_id" {
  value = ! local.use_existing_network ? join("", oci_core_vcn.curriki_vcn.*.id) : var.vcn_id
}

output "subnet_id" {
  value = ! local.use_existing_network ? join("", oci_core_subnet.curriki_subnet.*.id) : var.subnet_id
}

output "vcn_cidr_block" {
  value = ! local.use_existing_network ? join("", oci_core_vcn.curriki_vcn.*.cidr_block) : var.vcn_cidr_block
}

output "nsg_id" {
  value = join("", oci_core_network_security_group.app_nsg.*.id)
}

###
# image_subscription.tf outputs
###

output "app_subscription" {
  value = data.oci_core_app_catalog_subscriptions.mp_app_image_subscription.*.app_catalog_subscriptions
}

output "db_subscription" {
  value = data.oci_core_app_catalog_subscriptions.mp_db_image_subscription.*.app_catalog_subscriptions
}
output "es_subscription" {
  value = data.oci_core_app_catalog_subscriptions.mp_es_image_subscription.*.app_catalog_subscriptions
}
