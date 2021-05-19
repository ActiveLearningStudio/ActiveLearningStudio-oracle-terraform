
# resource "oci_core_security_list" "curriki_es_security_list" {
#     #Required
#     compartment_id = var.compartment_ocid
#     vcn_id = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

#     #Optional
#     display_name = "curriki-es-security-list"
#     egress_security_rules {
#         #Required
#         destination = "0.0.0.0/0"
#         protocol = "all"
#     }
#     ingress_security_rules {
#         #Required
#         protocol = "6"
#         source = "0.0.0.0/0"
#         tcp_options {
#             max = "9200"
#             min = "9200"
#         }
#     }
#     ingress_security_rules {
#         #Required
#         protocol = "6"
#         source = "0.0.0.0/0"
#         tcp_options {
#             max = "22"
#             min = "22"
#         }
#     }
# }



resource "oci_core_instance" "es_instance" {
    # Required
    availability_domain = local.availability_domain
    # availability_domain = data.oci_identity_availability_domains.curriki_es_availability_domains.availability_domains[0].name
    compartment_id = var.compartment_ocid
    shape = var.vm_compute_shape
    source_details {
        source_id = "ocid1.image.oc1.iad.aaaaaaaagyv764zjtiwzfke7mrrqtv73j2dpeq26ciknq44zq44tqtvwisca" #es Custom Image
        #source_id = "ocid1.image.oc1.iad.aaaaaaaamkzk5ldaouovz42drxqxjoiqu4i3hrnw6hlepp4yyhyjrjsitnza"
        source_type = "image"
    }

    dynamic "shape_config" {
        for_each = local.is_flex_shape
        content {
            ocpus = shape_config.value
        }
    }
    # Optional
    display_name = var.es_instance_display_name
    create_vnic_details {
        assign_public_ip = false
        display_name = "esvnic"
        subnet_id = local.use_existing_network ? var.es_subnet_id : oci_core_subnet.curriki_es_subnet[0].id
        nsg_ids                = [oci_core_network_security_group.es_nsg.id]
    }
    extended_metadata = {
      ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
    }
    preserve_boot_volume = false
}


# Gets a list of VNIC attachments on the instance
data "oci_core_vnic_attachments" "ESInstanceVnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
#   availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
  instance_id         = oci_core_instance.es_instance.id
}

# Gets the primary VNIC from the list of attachments
data "oci_core_vnic" "ESInstanceVnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.ESInstanceVnics.vnic_attachments[0],"vnic_id")
}


# Use the primary VNIC's OCID to get a list of private IPs assigned to it
data "oci_core_private_ips" "TFPrivateIps3" {
  vnic_id = data.oci_core_vnic.ESInstanceVnic.id
}

# Assign a reserved public IP to the private IP
resource "oci_core_public_ip" "ReservedESPublicIP" {
  compartment_id = var.compartment_ocid
  display_name   = "TFReservedESPublicIP"
  lifetime       = "RESERVED"
  private_ip_id  = lookup(data.oci_core_private_ips.TFPrivateIps3.private_ips[0],"id")
}

resource "null_resource" "es-scripts" {
     depends_on = [oci_core_instance.es_instance]
     provisioner "remote-exec" {
         inline = [
            "cd /usr/share/elasticsearch",
            "sudo sed -i \"s/substitute-elastic-password/${var.elastic_password}/g\" setup.sh",
            "sudo sh setup.sh",
            "sudo service elasticsearch restart"
            

         ]
         connection {
             type = "ssh"
             user        = "opc"
            private_key = tls_private_key.public_private_key_pair.private_key_pem
             host = oci_core_public_ip.ReservedESPublicIP.ip_address
         } 
     }
 }














