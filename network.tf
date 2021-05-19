resource "oci_core_vcn" "curriki_vcn" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.vcn_cidr_block
  dns_label      = substr(var.vcn_dns_label, 0, 15)
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name

  freeform_tags = map(var.tag_key_name, var.tag_value)
}

#IGW
resource "oci_core_internet_gateway" "curriki_internet_gateway" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.curriki_vcn[count.index].id
  enabled        = "true"
  display_name   = "${var.vcn_display_name}-igw"

  freeform_tags = map(var.tag_key_name, var.tag_value)
}

#simple subnet
resource "oci_core_subnet" "curriki_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  cidr_block                 = var.subnet_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.curriki_vcn[count.index].id
  display_name               = var.subnet_display_name
  dns_label                  = substr(var.subnet_dns_label, 0, 15)
  prohibit_public_ip_on_vnic = ! local.is_public_subnet
  # security_list_ids = [ oci_core_security_list.curriki_security_list.id]

  freeform_tags = map(var.tag_key_name, var.tag_value)
}

resource "oci_core_route_table" "curriki_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.curriki_vcn[count.index].id
  display_name   = "${var.subnet_display_name}-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.curriki_internet_gateway[count.index].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = map(var.tag_key_name, var.tag_value)
}

resource "oci_core_route_table_attachment" "curriki_route_table_attachment" {
  count          = local.use_existing_network ? 0 : 1
  subnet_id      = oci_core_subnet.curriki_subnet[count.index].id
  route_table_id = oci_core_route_table.curriki_route_table[count.index].id
}



resource "oci_core_subnet" "curriki_db_subnet" {
    count                      = local.use_existing_network ? 0 : 1
    cidr_block                 = var.db_subnet_cidr_block
    compartment_id             = var.compartment_ocid
    vcn_id                     = oci_core_vcn.curriki_vcn[count.index].id
    display_name               = "${var.subnet_display_name}-db"
    dns_label                  = "${substr(var.subnet_dns_label, 0, 13)}db"
    prohibit_public_ip_on_vnic = ! local.is_public_subnet
    # security_list_ids = [ oci_core_security_list.curriki_db_security_list.id]

    freeform_tags = map(var.tag_key_name, var.tag_value)
}



resource "oci_core_route_table" "curriki_db_route_table" {
  # count          = local.use_existing_network ? 0 : 1
  #Required
  # compartment_id = var.compartment_ocid
  # vcn_id = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

  # #Optional
  
  # route_rules {
  #     #Required
  #     network_entity_id = oci_core_internet_gateway.curriki_internet_gateway[count.index].id

  #     #Optional
  #     cidr_block = "0.0.0.0/0"
  #     # description = var.route_table_route_rules_description
  #     # destination = var.route_table_route_rules_destination
  #     # destination_type = var.route_table_route_rules_destination_type
  # }


    count          = local.use_existing_network ? 0 : 1
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.curriki_vcn[count.index].id
    display_name   = "${var.subnet_display_name}-db-rt"

    route_rules {
      network_entity_id = oci_core_internet_gateway.curriki_internet_gateway[count.index].id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }

    freeform_tags = map(var.tag_key_name, var.tag_value)
  }





resource "oci_core_route_table_attachment" "curriki_db_route_table_attachment" {
  # count          = local.use_existing_network ? 0 : 1
  # #Required    
  # subnet_id = local.use_existing_network ? var.db_subnet_id : oci_core_subnet.curriki_db_subnet[0].id
  # route_table_id = oci_core_route_table.curriki_db_route_table[count.index].id

  count          = local.use_existing_network ? 0 : 1
  subnet_id      = oci_core_subnet.curriki_db_subnet[count.index].id
  route_table_id = oci_core_route_table.curriki_db_route_table[count.index].id
}




resource "oci_core_subnet" "curriki_es_subnet" {
    # cidr_block = "10.0.2.0/24"
    # compartment_id = var.compartment_ocid //ocid
    # vcn_id = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id
    # security_list_ids = [ oci_core_security_list.curriki_es_security_list.id]
    # display_name               = "Curriki ES Subnet"



    count                      = local.use_existing_network ? 0 : 1
    cidr_block                 = var.es_subnet_cidr_block
    compartment_id             = var.compartment_ocid
    vcn_id                     = oci_core_vcn.curriki_vcn[count.index].id
    display_name               = "${var.subnet_display_name}-es"
    dns_label                  = "${substr(var.subnet_dns_label, 0, 13)}es"
    prohibit_public_ip_on_vnic = ! local.is_public_subnet
    # security_list_ids = [ oci_core_security_list.curriki_db_security_list.id]

    freeform_tags = map(var.tag_key_name, var.tag_value)
}


resource "oci_core_route_table" "curriki_es_route_table" {
    # count          = local.use_existing_network ? 0 : 1
    # #Required
    # compartment_id = var.compartment_ocid
    # vcn_id = local.use_existing_network ? var.vcn_id : oci_core_vcn.curriki_vcn.0.id

    # #Optional
    
    # route_rules {
    #     #Required
    #     network_entity_id = oci_core_internet_gateway.curriki_internet_gateway[count.index].id

    #     #Optional
    #     cidr_block = "0.0.0.0/0"
    #     # description = var.route_table_route_rules_description
    #     # destination = var.route_table_route_rules_destination
    #     # destination_type = var.route_table_route_rules_destination_type
    # }




    count          = local.use_existing_network ? 0 : 1
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.curriki_vcn[count.index].id
    display_name   = "${var.subnet_display_name}-es-rt"

    route_rules {
      network_entity_id = oci_core_internet_gateway.curriki_internet_gateway[count.index].id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }

    freeform_tags = map(var.tag_key_name, var.tag_value)
}

resource "oci_core_route_table_attachment" "curriki_es_route_table_attachment" {
  #Required    
  # count          = local.use_existing_network ? 0 : 1
  # subnet_id = oci_core_subnet.curriki_es_subnet.id
  # route_table_id = oci_core_route_table.curriki_db_route_table[count.index].id

  count          = local.use_existing_network ? 0 : 1
  subnet_id      = oci_core_subnet.curriki_es_subnet[count.index].id
  route_table_id = oci_core_route_table.curriki_es_route_table[count.index].id
}