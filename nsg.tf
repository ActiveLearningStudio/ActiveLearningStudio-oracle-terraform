resource "oci_core_network_security_group" "app_nsg" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

  #Optional
  display_name = var.nsg_display_name

  freeform_tags = map(var.tag_key_name, var.tag_value)
}


# Allow Egress traffic to all networks
resource "oci_core_network_security_group_security_rule" "app_rule_egress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id

  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"

}

# Allow SSH (TCP port 22) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "app_rule_ssh_ingress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.nsg_ssh_port
      max = var.nsg_ssh_port
    }
  }
}

# Allow HTTPS (TCP port 443) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "app_rule_https_ingress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.nsg_https_port
      max = var.nsg_https_port
    }
  }
}

# Allow HTTP (TCP port 80) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "app_rule_http_ingress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.nsg_http_port
      max = var.nsg_http_port
    }
  }
}

# Allow (TCP port 4003) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "app_rule_4003_ingress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "4003"
      max = "4003"
    }
  }
}


# Allow ANY Ingress traffic from within simple vcn
resource "oci_core_network_security_group_security_rule" "app_rule_all_app_vcn_ingress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  protocol                  = "all"
  direction                 = "INGRESS"
  source                    = var.vcn_cidr_block
  stateless                 = false
}

resource "oci_core_network_security_group" "es_nsg" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

  #Optional
  display_name = "${var.nsg_display_name}-es"

  freeform_tags = map(var.tag_key_name, var.tag_value)
}



# Allow Egress traffic to all networks
resource "oci_core_network_security_group_security_rule" "es_rule_egress" {
  network_security_group_id = oci_core_network_security_group.es_nsg.id

  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"

}

# Allow SSH (TCP port 22) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "es_rule_ssh_ingress" {
  network_security_group_id = oci_core_network_security_group.es_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.nsg_ssh_port
      max = var.nsg_ssh_port
    }
  }
}


# Allow (TCP port 9200) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "es_rule_9200_ingress" {
  network_security_group_id = oci_core_network_security_group.es_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "9200"
      max = "9200"
    }
  }
}





resource "oci_core_network_security_group" "db_nsg" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

  #Optional
  display_name = "${var.nsg_display_name}-db"

  freeform_tags = map(var.tag_key_name, var.tag_value)
}



# Allow Egress traffic to all networks
resource "oci_core_network_security_group_security_rule" "db_rule_egress" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id

  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"

}

# Allow SSH (TCP port 22) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "db_rule_ssh_ingress" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.nsg_ssh_port
      max = var.nsg_ssh_port
    }
  }
}


# Allow (TCP port 9200) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "db_rule_postgres_ingress" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.postges_port
      max = var.postges_port
    }
  }
}


# Allow (TCP port 9200) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "db_rule_pgadmin_ingress" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.pgadmin_port
      max = var.pgadmin_port
    }
  }
}


# Allow (TCP port 9200) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "db_rule_phpmyadmin_ingress" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.phpmyadmin_port
      max = var.phpmyadmin_port
    }
  }
}

# Allow (TCP port 9200) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "db_rule_mysql_ingress" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.nsg_source_cidr
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.mysql_port
      max = var.mysql_port
    }
  }
}






