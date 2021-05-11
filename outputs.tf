###
# compute.tf outputs
###

output "instance_id" {
  value = oci_core_instance.oracle_instance.id
}

output "private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}

# output "instance_public_ip" {
#   value = oci_core_instance.simple-vm.public_ip
# }

# output "instance_private_ip" {
#   value = oci_core_instance.simple-vm.private_ip
# }

# output "instance_https_url" {
#   value = (local.is_public_subnet ? "https://${oci_core_instance.simple-vm.public_ip}" : "https://${oci_core_instance.simple-vm.private_ip}")
# }

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
  value = join("", oci_core_network_security_group.simple_nsg.*.id)
}

###
# image_subscription.tf outputs
###

output "subscription" {
  value = data.oci_core_app_catalog_subscriptions.mp_image_subscription.*.app_catalog_subscriptions
}
