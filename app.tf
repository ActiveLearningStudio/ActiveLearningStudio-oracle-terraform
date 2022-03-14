resource "tls_private_key" "public_private_key_pair" {
  algorithm   = "RSA"
}

resource "oci_core_instance" "oracle_instance" {
    # Required
    availability_domain = local.availability_domain
    # availability_domain = data.oci_identity_availability_domains.curriki_availability_domains.availability_domains[0].name
    compartment_id = var.compartment_ocid
    shape = var.vm_compute_shape
    source_details {
        source_id = local.app_custom_image_id
        source_type = "image"
    }
    dynamic "shape_config" {
      for_each = local.is_flex_shape
        content {
          ocpus = shape_config.value
        }
    }
    # public_ip = oci_core_public_ip.test_public_ip

    # Optional
    display_name = "Market Test App"
    create_vnic_details {
        assign_public_ip = false
        display_name = "studiovnic"
        subnet_id = local.use_existing_network ? var.subnet_id : oci_core_subnet.curriki_subnet[0].id
        nsg_ids                = [oci_core_network_security_group.app_nsg.id]
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

    # source_details {
    #     #Required
    #     id = "ocid1.volume.oc1.iad.abuwcljtl6logc3nrsd77sai2t2srfcgarh3kfdma2epbdxbxp5agsh6veea"
    #     type = "volume"
    # }
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
        timeout = "30m"
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
      "sudo mkdir -p /curriki/api/storage",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /curriki/api/storage xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "sudo unzip -o /curriki/storage.zip -d /curriki/api/storage/",
      "sudo chmod 777 -R /curriki/api/storage/"
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
#       "sudo umount /curriki/api/storage",
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
             # Lets Encrypt
            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/init-letsencrypt.sh",
            "sed -i 's/substitute-terraform-admin-domain.com/${var.admin_site}/g' /curriki/init-letsencrypt.sh",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/init-letsencrypt.sh",
            "sed -i 's/substitute-terraform-trax-domain.com/${var.lrs_site}/g' /curriki/init-letsencrypt.sh",
            
             # Lets Encrypt
            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/init-generate-ssl.sh",
            "sed -i 's/substitute-terraform-admin-domain.com/${var.admin_site}/g' /curriki/init-generate-ssl.sh",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/init-generate-ssl.sh",
            "sed -i 's/substitute-terraform-trax-domain.com/${var.lrs_site}/g' /curriki/init-generate-ssl.sh",
            
            # nginx

            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/data/nginx/certbot-conf/app.conf",
            "sed -i 's/substitute-terraform-admin-domain.com/${var.admin_site}/g' /curriki/data/nginx/certbot-conf/app.conf",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/data/nginx/certbot-conf/app.conf",
            "sed -i 's/substitute-terraform-trax-domain.com/${var.lrs_site}/g' /curriki/data/nginx/certbot-conf/app.conf",

            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/data/nginx/prod-conf/app.conf",
            "sed -i 's/substitute-terraform-admin-domain.com/${var.admin_site}/g' /curriki/data/nginx/prod-conf/app.conf",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/data/nginx/prod-conf/app.conf",
            "sed -i 's/substitute-terraform-trax-domain.com/${var.lrs_site}/g' /curriki/data/nginx/prod-conf/app.conf",

            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/ssl.conf",
            "sed -i 's/substitute-terraform-admin-domain.com/${var.admin_site}/g' /curriki/ssl.conf",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/ssl.conf",
            "sed -i 's/substitute-terraform-trax-domain.com/${var.lrs_site}/g' /curriki/ssl.conf",

            # API
            "cp /curriki/api/.env.example /curriki/api/.env",
            "cp /curriki/api/laravel-echo-server-https-example.json /curriki/api/laravel-echo-server.json",
            "echo $(tr -dc A-Za-z0-9 </dev/urandom | head -c 32 ; echo '' ) > /curriki/.appkey",
            "sed -i \"s/substitute-app-key/$(cat /curriki/.appkey)/g\" /curriki/api/.env",
            
            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/api/.env",
            "sed -i 's/substitute-postgres-db-host/${oci_core_public_ip.ReservedDBPublicIP.ip_address}/g' /curriki/api/.env",
            "sed -i 's/substitute-postgres-user/${var.postgres_user}/g' /curriki/api/.env",
            "sed -i 's/substitute-postgres-password/${var.postgres_password}/g' /curriki/api/.env",
            "sed -i 's/substitute-postgres-port/${var.postges_port}/g' /curriki/api/.env",
            "sed -i 's/substitute-postgres-db/${var.postgres_db}/g' /curriki/api/.env",
            "sed -i 's/substitute-lrs-db-database/${var.postgres_lrs_db}/g' /curriki/api/.env",
            "sed -i 's/substitute-elastic-host/${oci_core_public_ip.ReservedESPublicIP.ip_address}/g' /curriki/api/.env",
            
            "sed -i 's/substitute-elastic-user/elastic/g' /curriki/api/.env",
            "sed -i 's/substitute-elastic-password/${var.elastic_password}/g' /curriki/api/.env",
            "sed -i 's/substitute-terraform-trax-domain.com/${var.lrs_site}/g' /curriki/api/.env",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/api/.env",

            "sed -i 's/substitute-lrs-username/testsuite/g' /curriki/api/.env",
            "sed -i 's/substitute-lrs-password/password/g' /curriki/api/.env",
            
            

            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/api/laravel-echo-server.json",
            

            
            # Client
            "cp /curriki/client/.env.example /curriki/client/.env.local",
            "sed -i \"s/substitute-react-app-pexel-api/${var.react_app_pexel_api}/g\" /curriki/client/.env.local",
            "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/client/.env.local",
            "sed -i 's/substitute-react-app-resource-url/${var.main_site}/g' /curriki/client/.env.local",
            "sed -i \"s/substitute-react-app-h5p-key/B6TFsmFD5TLZaWCAYZ91ly0D2We0xjLAtRmBJzQ/g\" /curriki/client/.env.local",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/client/.env.local",

            # Admin
            "cp /curriki/admin/.env.example /curriki/admin/.env",
            "sed -i \"s/substitute-app-key/$(cat /curriki/.appkey)/g\" /curriki/admin/.env",
            "sed -i \"s/substitute-terraform-admin-domain.com/${var.admin_site}/g\" /curriki/admin/.env",
            "sed -i \"s/substitute-terraform-domain.com/${var.main_site}/g\" /curriki/admin/.env",
            
            

            # Trax

            "cp /curriki/trax-lrs/.env.example /curriki/trax-lrs/.env",
            "sed -i \"s/substitute-app-key/$(cat /curriki/.appkey)/g\" /curriki/trax-lrs/.env",
            "sed -i \"s/substitute-terraform-trax-domain.com/${var.lrs_site}/g\" /curriki/trax-lrs/.env",
            "sed -i 's/substitute-postgres-db-host/${oci_core_public_ip.ReservedDBPublicIP.ip_address}/g' /curriki/trax-lrs/.env",
            "sed -i 's/substitute-postgres-user/${var.postgres_user}/g' /curriki/trax-lrs/.env",
            "sed -i 's/substitute-postgres-password/${var.postgres_password}/g' /curriki/trax-lrs/.env",
            "sed -i 's/substitute-postgres-db/${var.postgres_db}/g' /curriki/trax-lrs/.env",
            "sed -i 's/substitute-lrs-db-database/${var.postgres_lrs_db}/g' /curriki/trax-lrs/.env",
            "sed -i 's/substitute-postgres-port/${var.postges_port}/g' /curriki/trax-lrs/.env",
            

            # Tsugi

            "cp /curriki/tsugi/tsugi-main-config.example.php /curriki/tsugi/config.php",
            "cp /curriki/tsugi/mod/curriki/tsugi-curriki-config.php /curriki/tsugi/mod/curriki/config.php",
            "sed -i 's/substitute-terraform-tsugi-domain.com/${var.tsugi_site}/g' /curriki/tsugi/config.php",
            "sed -i 's/substitute-mysql-db-host/${oci_core_public_ip.ReservedDBPublicIP.ip_address}/g' /curriki/tsugi/config.php",
           "sed -i 's/substitute-mysql-db-port/${var.mysql_port}/g' /curriki/tsugi/config.php",
           "sed -i 's/substitute-tsugi-db-dbname/${var.tsugi_database}/g' /curriki/tsugi/config.php",
           "sed -i 's/substitute-mysql-db-user/${var.mysql_user}/g' /curriki/tsugi/config.php",
           "sed -i 's/substitute-mysql-db-password/${var.mysql_password}/g' /curriki/tsugi/config.php",
           "sed -i 's/substitute-tsugi-admin-password/${var.tsugi_admin_password}/g' /curriki/tsugi/config.php",           
           "sed -i 's/substitute-terraform-domain.com/${var.main_site}/g' /curriki/tsugi/mod/curriki/config.php",


            #Installing
            "sudo docker swarm init",
            "sudo docker stack deploy --compose-file /curriki/docker-compose.yml currikistack",
            " up=$(sudo docker service ls | grep currikiprod-nginx | awk ' { print $4 } ')",
            " while [ \"$up\" != \"1/1\" ] ",
            " do ",
            " echo $up ...",
              " echo 'Please wait while we are installing the CurrikiStudio...' ",
              " sleep 10 ",
              " up=$(sudo docker service ls | grep currikiprod-nginx | awk ' { print $4 } ') ",
            " done ",

            #Removing temporary public key
            # "KEYWORD=${tls_private_key.public_private_key_pair.public_key_openssh}",
            # "ESCAPED_KEYWORD=$(printf '%s\n' \"$KEYWORD\" | sed -e 's/[]\\/$*.^[]/\\&/g');",
            # "sed -i \"s/$ESCAPED_KEYWORD//g\" /home/opc/.ssh/authorized_keys"
         ]
         connection {
             type = "ssh"
             user        = "opc"
             private_key = tls_private_key.public_private_key_pair.private_key_pem
             host = oci_core_public_ip.ReservedAppPublicIP.ip_address
             timeout = "30m"
         } 
     }
 }
 

