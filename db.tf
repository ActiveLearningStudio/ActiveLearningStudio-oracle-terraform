

# data "oci_identity_availability_domains" "curriki_db_availability_domains" {
#     #Required
#     compartment_id = var.tenancy_ocid
# }


resource "oci_core_security_list" "curriki_db_security_list" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

    #Optional
    display_name = "curriki-db-security-list"
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
            max = var.postges_exposed_port
            min = var.postges_exposed_port
        }
    }
    ingress_security_rules {
        #Required
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = var.pgadmin_exposed_port
            min = var.pgadmin_exposed_port
        }
    }
    ingress_security_rules {
        #Required
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = var.phpmyadmin_exposed_port
            min = var.phpmyadmin_exposed_port
        }
    }
    ingress_security_rules {
        #Required
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = var.mysql_local_port
            min = var.mysql_local_port
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
}



resource "oci_core_instance" "db_instance" {
    # Required
    availability_domain = local.availability_domain
    # availability_domain = data.oci_identity_availability_domains.curriki_db_availability_domains.availability_domains[0].name
    compartment_id = var.compartment_ocid
    shape = "VM.Standard.E4.Flex"
    source_details {
        source_id = "ocid1.image.oc1.iad.aaaaaaaaafrrzzpy7p4rmp2a76dwqqletqdq753rgypbiqdzd4r6c5f2staq" #DB Custom Image
        # source_id = "ocid1.image.oc1.iad.aaaaaaaamkzk5ldaouovz42drxqxjoiqu4i3hrnw6hlepp4yyhyjrjsitnza"
        source_type = "image"
    }

    shape_config {
        #Optional
        memory_in_gbs = "8"
        ocpus = "1"
    }
    # Optional
    display_name = var.db_instance_display_name
    create_vnic_details {
        assign_public_ip = false
        subnet_id = local.use_existing_network ? var.db_subnet_id : oci_core_subnet.curriki_db_subnet[0].id
    }
    extended_metadata = {
      ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
    }
    preserve_boot_volume = false
}


# Gets a list of VNIC attachments on the instance
data "oci_core_vnic_attachments" "DBInstanceVnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
  # availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
  instance_id         = oci_core_instance.db_instance.id
}

# Gets the primary VNIC from the list of attachments
data "oci_core_vnic" "DBInstanceVnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.DBInstanceVnics.vnic_attachments[0],"vnic_id")
}


# Use the primary VNIC's OCID to get a list of private IPs assigned to it
data "oci_core_private_ips" "TFPrivateIps2" {
  vnic_id = data.oci_core_vnic.DBInstanceVnic.id
}

# Assign a reserved public IP to the private IP
resource "oci_core_public_ip" "ReservedDBPublicIP" {
  compartment_id = var.compartment_ocid
  display_name   = "TFReservedDBPublicIP"
  lifetime       = "RESERVED"
  private_ip_id  = lookup(data.oci_core_private_ips.TFPrivateIps2.private_ips[0],"id")
}

resource "oci_core_volume" "db_volume" {
    #Required
    availability_domain = local.availability_domain
    # availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
    compartment_id = var.compartment_ocid
    size_in_gbs = 500
    display_name = "Studio-DB-Vol-Latest"

    # source_details {
    #     #Required
    #     id = "ocid1.volume.oc1.iad.abuwcljtl6logc3nrsd77sai2t2srfcgarh3kfdma2epbdxbxp5agsh6veea"
    #     type = "volume"
    # }
}

resource "oci_core_volume_attachment" "db_volume_attachment" {
    #Required
    attachment_type = "ISCSI"
    instance_id = oci_core_instance.db_instance.id
    volume_id = oci_core_volume.db_volume.id
    device = "/dev/oracleoci/oraclevdb"
    display_name = "curriki_db_volume_attachment"

     connection {
        type        = "ssh"
        host        = oci_core_public_ip.ReservedDBPublicIP.ip_address
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
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /mnt/DBData xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      # "sudo unzip -o /home/opc/curriki-db/DBData.zip -d /mnt/DBData/",
      # "sudo chmod 777 -R /mnt/DBData/"
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
#       "sudo umount /mnt/DBData",
#       "if [[ $UUID ]] ; then",
#       "  sudo sed -i.bak '\\@^UUID='$${UUID}'@d' /etc/fstab",
#       "fi",
#       "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -u",
#       "sudo iscsiadm -m node -o delete -T ${self.iqn} -p ${self.ipv4}:${self.port}",
#     ]
#   }
}

resource "null_resource" "db-scripts" {
     depends_on = [oci_core_instance.db_instance, oci_core_volume_attachment.db_volume_attachment  ]
     provisioner "remote-exec" {
         inline = [
           "sudo mkdir -p /mnt/DBData/currikiprod1-postgresdata",
          "sudo mkdir -p /mnt/DBData/currikiprod1-mysqldata",
          "sudo mkdir -p /mnt/DBData/pgadmin1-data",
           "sed -i 's/substitute-mysql-database/${var.mysql_database}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-mysql-user/${var.mysql_user}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-mysql-password/${var.mysql_password}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-mysql-root-password/${var.mysql_root_password}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-mysql-local-port/${var.mysql_local_port}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-local-db-ip-address/${oci_core_public_ip.ReservedDBPublicIP.ip_address}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-pgadmin-default-email/${var.pgadmin_default_email}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-pgadmin-default-password/${var.pgadmin_default_password}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-postgres-user/${var.postgres_user}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-postgres-password/${var.postgres_password}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-postgres-db/${var.postgres_db}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-postgres-exposed-port/${var.postges_exposed_port}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-pgadmin-exposed-port/${var.pgadmin_exposed_port}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-phpmyadmin-exposed-port/${var.phpmyadmin_exposed_port}/g' ~/curriki-db/.env.example",
           "sed -i 's/substitute-postgres-database/${var.postgres_trax_db}/g' ~/curriki-db/postgresscripts/traxdb.sql",
            "sed -i 's/substitute-postgres-password/${var.postgres_password}/g' ~/curriki-db/postgresscripts/db-update-creds.sql",
            "sed -i 's/substitute-postgres-user/${var.postgres_user}/g' ~/curriki-db/postgresscripts/db-update-creds.sql",
            "sed -i 's/substitute-postgres-db/${var.postgres_db}/g' ~/curriki-db/db-update-creds.sh",
            "sed -i 's/substitute-postgres-user/${var.postgres_user}/g' ~/curriki-db/db-update-creds.sh",
            "cp ~/curriki-db/.env.example ~/curriki-db/.env",
            "sudo chmod +x ~/curriki-db/db-update-creds.sh",
            "sudo chown -R 5050:5050 /mnt/DBData/pgadmin1-data/",
            "cd ~/curriki-db && sudo docker-compose up --force-recreate -d",
            "sleep 60",
            "sudo sh ~/curriki-db/db-update-creds.sh",
         ]
         connection {
             type = "ssh"
             user        = "opc"
             private_key = tls_private_key.public_private_key_pair.private_key_pem
             host = oci_core_public_ip.ReservedDBPublicIP.ip_address
         } 
     }
 }

