# resource "oci_core_vcn" "curriki_vcn" {
# 	compartment_id = var.compartment_ocid
# 	cidr_blocks = [ "10.0.0.0/16" ]
# }

# resource "oci_core_internet_gateway" "curriki_internet_gateway" {
#     #Required
#     compartment_id = var.compartment_ocid
#     vcn_id = oci_core_vcn.curriki_vcn.id

#     #Optional
#     display_name = "curriki-internet-gateway"
# }


# resource "oci_core_route_table" "curriki_route_table" {
#     #Required
#     compartment_id = var.compartment_ocid
#     vcn_id = oci_core_vcn.curriki_vcn.id

#     #Optional
    
#     route_rules {
#         #Required
#         network_entity_id = oci_core_internet_gateway.curriki_internet_gateway.id

#         #Optional
#         cidr_block = "0.0.0.0/0"
#         # description = var.route_table_route_rules_description
#         # destination = var.route_table_route_rules_destination
#         # destination_type = var.route_table_route_rules_destination_type
#     }
# }

# resource "oci_core_route_table_attachment" "curriki_route_table_attachment" {
#   #Required    
#   subnet_id = oci_core_subnet.curriki_subnet.id
#   route_table_id =oci_core_route_table.curriki_route_table.id
# }

# data "oci_identity_availability_domains" "curriki_availability_domains" {
#     #Required
#     compartment_id = var.tenancy_ocid
# }





resource "tls_private_key" "public_private_key_pair" {
  algorithm   = "RSA"
}
  
# resource "oci_core_instance" "TFInstance1" {
#   availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
#   compartment_id      = "${var.compartment_ocid}"
#   display_name        = "TFInstance"
#   # hostname_label      = "instance3"
#   shape               = "VM.Standard.E4.Flex"
#   subnet_id           = "${oci_core_subnet.curriki_subnet.id}"
  
#   source_details {
#     source_type = "image"
#     source_id   = "ocid1.image.oc1.iad.aaaaaaaamkzk5ldaouovz42drxqxjoiqu4i3hrnw6hlepp4yyhyjrjsitnza"
#   }
  
#   extended_metadata = {
#     ssh_authorized_keys = "${tls_private_key.public_private_key_pair.public_key_openssh}"
#   }
#   shape_config {
#         #Optional
#         memory_in_gbs = "8"
#         ocpus = "2"
#     }
# }
  
# resource "null_resource" "remote-exec" {
#   depends_on = ["oci_core_instance.TFInstance1"]
  
#   provisioner "remote-exec" {
#     connection {
#       agent       = false
#       timeout     = "30m"
#       host        = "${oci_core_instance.TFInstance1.public_ip}"
#       user        = "opc"
#       private_key = "${tls_private_key.public_private_key_pair.private_key_pem}"
#     }
  
#     inline = [
#       "touch ~/IMadeAFile.Right.Here"
#     ]
#   }
# }




resource "oci_core_security_list" "curriki_security_list" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

    #Optional
    display_name = "curriki-security-list"
    egress_security_rules {
        #Required
        destination = "0.0.0.0/0"
        protocol = "all"
    }
    ingress_security_rules {
        #Required
        protocol = "6"
        source = "0.0.0.0/0"

        tcp_options {
            max = "80"
            min = "80"
        }
    }
    ingress_security_rules {
        #Required
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = "22"
            min = "22"
        }
    }
    #Redis
    ingress_security_rules {
        #Required
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = "4003"
            min = "4003"
        }
    }
    ingress_security_rules {
        #Required
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = "443"
            min = "443"
        }
    }
}

# resource "oci_core_subnet" "curriki_subnet" {
#     cidr_block = "10.0.0.0/24"
#     compartment_id = var.compartment_ocid //ocid
#     vcn_id = oci_core_vcn.curriki_vcn.id
#     display_name = "currikisubnet"
#     security_list_ids = [ oci_core_security_list.curriki_security_list.id]
# }


resource "oci_core_instance" "oracle_instance" {
    # Required
    availability_domain = local.availability_domain
    # availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
    compartment_id = var.compartment_ocid
    shape = "VM.Standard.E4.Flex"
    source_details {
        source_id = "ocid1.image.oc1.iad.aaaaaaaagmhnohyvb2ipl4gv5b673wcw4qnoyssphvej4n2xbcsmp2okpslq" # CurrikiAPPwithoutHTTPS
        # source_id = "ocid1.image.oc1.iad.aaaaaaaamkzk5ldaouovz42drxqxjoiqu4i3hrnw6hlepp4yyhyjrjsitnza" # Old Image
        source_type = "image"
    }
    shape_config {

        #Optional
        memory_in_gbs = "16"
        ocpus = "4"
    }
    # public_ip = oci_core_public_ip.test_public_ip

    # Optional
    display_name = var.instance_display_name
    create_vnic_details {
        assign_public_ip = false
        display_name = "studiovnic"
        subnet_id = local.use_existing_network ? var.subnet_id : oci_core_subnet.curriki_subnet[0].id
    }
    extended_metadata = {
      ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
    }
    preserve_boot_volume = false
}

# Gets a list of VNIC attachments on the instance
data "oci_core_vnic_attachments" "AppInstanceVnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
  # availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
  instance_id         = oci_core_instance.oracle_instance.id
}

# Gets the primary VNIC from the list of attachments
data "oci_core_vnic" "AppInstanceVnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.AppInstanceVnics.vnic_attachments[0],"vnic_id")
}


# Use the primary VNIC's OCID to get a list of private IPs assigned to it
data "oci_core_private_ips" "TFPrivateIps" {
  vnic_id = data.oci_core_vnic.AppInstanceVnic.id
}

# Assign a reserved public IP to the private IP
resource "oci_core_public_ip" "ReservedAppPublicIP" {
  compartment_id = var.compartment_ocid
  display_name   = "TFReservedAppPublicIP"
  lifetime       = "RESERVED"
  private_ip_id  = lookup(data.oci_core_private_ips.TFPrivateIps.private_ips[0],"id")
}

resource "oci_core_volume" "app_volume" {
    #Required
    availability_domain = local.availability_domain
    # availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
    compartment_id = var.compartment_ocid
    size_in_gbs = 500
    display_name = "Studio-App-Storage-Vol-Latest"

    source_details {
        #Required
        id = "ocid1.volume.oc1.iad.abuwcljtl6logc3nrsd77sai2t2srfcgarh3kfdma2epbdxbxp5agsh6veea"
        type = "volume"
    }
}



# resource "time_sleep" "wait_10_minutes" {
#  depends_on = [oci_core_instance.oracle_instance]

#  create_duration = "10m"
# }


resource "oci_core_volume_attachment" "app_volume_attachment" {
    #depends_on = [time_sleep.wait_10_minutes]
    #Required
    attachment_type = "ISCSI"
    instance_id = oci_core_instance.oracle_instance.id
    volume_id = oci_core_volume.app_volume.id
    device = "/dev/oracleoci/oraclevdb"
    display_name = "curriki_app_volume_attachment"

     connection {
        type        = "ssh"
        host        = oci_core_public_ip.ReservedAppPublicIP.ip_address
        # host        = oci_core_instance.oracle_instance.public_ip
        user        = "opc"
        # private_key = file("~/.ssh/id_rsa")
        private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    # register and connect the iSCSI block volume
  provisioner "remote-exec" {
    inline = [
      "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
    ]
  }
  # initialize partition and file system
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-2",
      "export HAS_PARTITION=$(sudo partprobe -d -s /dev/disk/by-path/$${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -eq 0 ] ; then",
      "  (echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/disk/by-path/$${DEVICE_ID}",
      "  while [[ ! -e /dev/disk/by-path/$${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "  sudo mkfs.xfs /dev/disk/by-path/$${DEVICE_ID}-part1",
      "fi",
    ]
  }
  # mount the partition
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-2",
      "sudo mkdir -p /home/opc/curriki/api/storage",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /home/opc/curriki/api/storage xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
    #   "sudo unzip -o /home/opc/curriki/storage.zip -d /home/opc/curriki/api/storage/",
    #   "sudo chmod 777 -R /home/opc/curriki/api/storage/"
    ]
  }
  # unmount and disconnect on destroy
#   provisioner "remote-exec" {
#     when       = destroy
#     on_failure = continue
#     inline = [
#       "set -x",
#       "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
#       "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
#       "sudo umount /home/opc/curriki/api/storage",
#       "if [[ $UUID ]] ; then",
#       "  sudo sed -i.bak '\\@^UUID='$${UUID}'@d' /etc/fstab",
#       "fi",
#       "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -u",
#       "sudo iscsiadm -m node -o delete -T ${self.iqn} -p ${self.ipv4}:${self.port}",
#     ]
#   }
}

resource "null_resource" "studio-script" {
    #  depends_on = [ oci_core_instance.oracle_instance, oci_core_instance.db_instance, oci_core_volume_attachment.app_volume_attachment ]
     depends_on = [ oci_core_instance.oracle_instance, oci_core_volume_attachment.app_volume_attachment ]
     provisioner "remote-exec" {
         inline = [
             #Client
            "sed -i \"s/terraform_site/${var.terraform_site}/g\" ~/curriki/setup.sh",
            "sed -i \"s/terraform_admin_site/${var.terraform_admin_site}/g\" ~/curriki/setup.sh",
            "sed -i \"s/terraform_tsugi_site/${var.terraform_tsugi_site}/g\" ~/curriki/setup.sh",
            "sed -i \"s/terraform_trax_site/${var.terraform_trax_site}/g\" ~/curriki/setup.sh",
            "sed -i \"s/http_scheme/${var.http_scheme}/g\" ~/curriki/setup.sh",
            "sed -i \"s/react_app_pexel_api/${var.react_app_pexel_api}/g\" ~/curriki/setup.sh",
            "sed -i \"s/react_app_google_captcha/${var.react_app_google_captcha}/g\" ~/curriki/setup.sh",
            "sed -i \"s/react_app_gapi_client_id/${var.react_app_gapi_client_id}/g\" ~/curriki/setup.sh",
            "sed -i \"s/react_app_hubpot/${var.react_app_hubpot}/g\" ~/curriki/setup.sh",
            "sed -i \"s/react_app_h5p_key/${var.react_app_h5p_key}/g\" ~/curriki/setup.sh",

            "sed -i \"s/curriki_app_key/${var.curriki_app_key}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_postgres_db_host/${oci_core_public_ip.ReservedDBPublicIP.ip_address}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_postgres_db_port/${var.postges_exposed_port}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_postgres_db/${var.postgres_db}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_postgres_user/${var.postgres_user}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_postgres_password/${var.postgres_password}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_mail_username/${var.mail_username}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_mail_password/${var.mail_password}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_mail_from_address/${var.mail_from_address}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_gapi_credentials/${var.gapi_credentials}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_elastic_host/${oci_core_public_ip.ReservedESPublicIP.ip_address}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_elastic_user/${var.elastic_username}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_elastic_password/${var.elastic_password}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_lrs_username/${var.lrs_username}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_lrs_password/${var.lrs_password}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_lrs_db_database/${var.postgres_trax_db}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_mysql_db_host/${oci_core_public_ip.ReservedDBPublicIP.ip_address}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_mysql_db_port/${var.mysql_local_port}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_tsugi_db_dbname/${var.mysql_database}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_mysql_db_user/${var.mysql_user}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_mysql_db_password/${var.mysql_root_password}/g\" ~/curriki/setup.sh",
            "sed -i \"s/curriki_tsugi_admin_password/${var.tsugi_admin_password}/g\" ~/curriki/setup.sh",
            
            #Installing
            "cd ~/curriki",
            "sudo ./setup.sh",
            "sudo docker stack deploy --compose-file /home/opc/curriki/docker-compose.yml currikistack"
         ]
         connection {
             type = "ssh"
             user        = "opc"
             private_key = tls_private_key.public_private_key_pair.private_key_pem
             host = oci_core_public_ip.ReservedAppPublicIP.ip_address
         } 
     }
 }
 





