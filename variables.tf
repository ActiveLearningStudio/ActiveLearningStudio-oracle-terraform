#Variables declared in this file must be declared in the marketplace.yaml
#Provide a description to your variables.

############################
#  Hidden Variable Group   #
############################
variable "tenancy_ocid" {
}

variable "region" {
}

###############################################################################
#  Marketplace Image Listing - information available in the Partner portal    #
###############################################################################
variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  default     = false
}

variable "mp_listing_id" {
  // default = "ocid1.appcataloglisting.oc1.."
  default     = ""
  description = "Marketplace Listing OCID"
}

variable "mp_listing_resource_app_id" {
  // default = "ocid1.image.oc1.."
  default     = ""
  description = "Marketplace Listing Image APP OCID"
}

variable "mp_listing_resource_db_id" {
  // default = "ocid1.image.oc1.."
  default     = ""
  description = "Marketplace Listing Image DB OCID"
}
variable "mp_listing_resource_es_id" {
  // default = "ocid1.image.oc1.."
  default     = ""
  description = "Marketplace Listing Image ES OCID"
}

variable "mp_listing_resource_version" {
  // default = "1.0"
  default     = ""
  description = "Marketplace Listing Package/Resource Version"
}

############################
#  Custom Image           #
############################
variable "app_custom_image_id" {
  default     = "ocid1.image.oc1.iad.aaaaaaaapzm263v5jr5phsoxxmrzbjtm6jznariupib7wrrsp35jfjmuxnga"
  description = "APP Image OCID"
}
variable "db_custom_image_id" {
  default     = "ocid1.image.oc1.iad.aaaaaaaakmglx2ti2k2luvpaktd4hg3qtpezf3jvzxcaoaiauzpvie622twa"
  description = "DB Image OCID"
}
variable "es_custom_image_id" {
  default     = "ocid1.image.oc1.iad.aaaaaaaagyv764zjtiwzfke7mrrqtv73j2dpeq26ciknq44zq44tqtvwisca"
  description = "Elastic Search Image OCID"
}

############################
#  Compute Configuration   #
############################

variable "vm_display_name" {
  description = "Instance Name"
  default     = "simple-vm"
}

variable "vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard2.2" //2 cores
}

# only used for E3 Flex shape
variable "vm_flex_shape_ocpus" {
  description = "Flex Shape OCPUs"
  default = 1
}

variable "availability_domain_name" {
  default     = ""
  description = "Availability Domain name, if non-empty takes precedence over availability_domain_number"
}

variable "availability_domain_number" {
  default     = 1
  description = "OCI Availability Domains: 1,2,3  (subject to region availability)"
}

variable "ssh_public_key" {
  description = "SSH Public Key"
}

variable "hostname_label" {
  default     = "simple"
  description = "DNS Hostname Label. Must be unique across all VNICs in the subnet and comply with RFC 952 and RFC 1123."
}

############################
#  Network Configuration   #
############################

variable "network_strategy" {
  #default = "Use Existing VCN and Subnet"
  default = "Create New VCN and Subnet"
}

variable "vcn_id" {
  default = ""
}

variable "vcn_display_name" {
  description = "VCN Name"
  default     = "simple-vcn"
}

variable "vcn_cidr_block" {
  description = "VCN CIDR"
  default     = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  description = "VCN DNS Label"
  default     = "simplevcn"
}

variable "subnet_type" {
  description = "Choose between private and public subnets"
  default     = "Public Subnet"
  #or
  #default     = "Private Subnet"
}

variable "subnet_id" {
  default = ""
}
variable "db_subnet_id" {
  default = ""
}
variable "es_subnet_id" {
  default = ""
}


variable "subnet_display_name" {
  description = "Subnet Name"
  default     = "app-subnet"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR"
  default     = "10.0.0.0/24"
}

variable "db_subnet_cidr_block" {
  description = "DB Subnet CIDR"
  default     = "10.0.1.0/24"
}
variable "es_subnet_cidr_block" {
  description = "ES Subnet CIDR"
  default     = "10.0.2.0/24"
}

variable "subnet_dns_label" {
  description = "Subnet DNS Label"
  default     = "currikisubnet"
}

############################
# Security Configuration #
############################
variable "nsg_display_name" {
  description = "Network Security Group Name"
  default     = "simple-network-security-group"
}

variable "nsg_source_cidr" {
  description = "Allowed Ingress Traffic (CIDR Block)"
  default     = "0.0.0.0/0"
}

variable "nsg_ssh_port" {
  description = "SSH Port"
  default     = 22
}

variable "nsg_https_port" {
  description = "HTTPS Port"
  default     = 443
}

variable "nsg_http_port" {
  description = "HTTP Port"
  default     = 80
}

############################
# Additional Configuration #
############################

variable "compartment_ocid" {
  description = "Compartment where Compute and Marketplace subscription resources will be created"
}


variable "tag_key_name" {
  description = "Free-form tag key name"
  default     = "oracle-quickstart"
}

variable "tag_value" {
  description = "Free-form tag value"
  default     = "oci-quickstart-template"
}


######################
#    Enum Values     #
######################
variable "network_strategy_enum" {
  type = map
  default = {
    CREATE_NEW_VCN_SUBNET   = "Create New VCN and Subnet"
    USE_EXISTING_VCN_SUBNET = "Use Existing VCN and Subnet"
  }
}

variable "subnet_type_enum" {
  type = map
  default = {
    PRIVATE_SUBNET = "Private Subnet"
    PUBLIC_SUBNET  = "Public Subnet"
  }
}

variable "nsg_config_enum" {
  type = map
  default = {
    BLOCK_ALL_PORTS = "Block all ports"
    OPEN_ALL_PORTS  = "Open all ports"
    CUSTOMIZE       = "Customize ports - Post deployment"
  }
}
















variable "terraform_site" {
  description = "terraform_site"
  type = string
  default = "oracle.currikistudio.org"
}
variable "terraform_admin_site" {
  description = "terraform_admin_site"
  type = string
  default = "oracle-admin.currikistudio.org"
}
variable "terraform_tsugi_site" {
  description = "terraform_tsugi_site"
  type = string
  default = "oracle-tsugi.currikistudio.org"
}
variable "terraform_trax_site" {
  description = "terraform_trax_site"
  type = string
  default = "oracle-trax.currikistudio.org"
}
variable "instance_display_name" {
  description = "instance_display_name"
  type = string
  default = "Curriki App Instance"
}
variable "db_instance_display_name" {
  description = "db_instance_display_name"
  type = string
  default = "Curriki DB Instance"
}
variable "es_instance_display_name" {
  description = "es_instance_display_name"
  type = string
  default = "Curriki Elastic Instance"
}

variable "mysql_database" {
  description = "mysql_database"
  type = string
  default = "mysql_database"
}
variable "mysql_user" {
  description = "mysql_user"
  type = string
  default = "mysql_user"
}
variable "mysql_password" {
  description = "mysql_password"
  type = string
  default = "mysql_password"
}
variable "mysql_root_password" {
  description = "mysql_root_password"
  type = string
  default = "mysql_root_password"
}
variable "mysql_local_port" {
  description = "mysql_local_port"
  type = string
  default = "3307"
}
variable "phpmyadmin_exposed_port" {
  description = "phpmyadmin_exposed_port"
  type = string
  default = "7000"
}

variable "elastic_password" {
  description = "elastic_password"
  type = string
  default = "elastic_password"
}

variable "postgres_user" {
  description = "postgres_user"
  type = string
  default = "postgres_user"
}
variable "postgres_password" {
  description = "postgres_password"
  type = string
  default = "postgres_password"
}
variable "postgres_db" {
  description = "postgres_db"
  type = string
  default = "postgres_db"
}

variable "postges_exposed_port" {
  description = "postges_exposed_port"
  type = string
  default = "5434"
}

variable "pgadmin_default_email" {
  description = "pgadmin_default_email"
  type = string
  default = "admin@currikistudio.org"
}
variable "pgadmin_default_password" {
  description = "pgadmin_default_password"
  type = string
  default = "pgadmin_default_password"
}
variable "pgadmin_exposed_port" {
  description = "pgadmin_exposed_port"
  type = string
  default = "8080"
}


variable "react_app_pexel_api" {
  description = "react_app_pexel_api"
  type = string
  default = "563492ad6f91700001000001155d7b75f5424ea694b81ce9f867dddf"
}
# variable "react_app_google_captcha" {
#   description = "react_app_google_captcha"
#   type = string
#   default = ""
# }
# variable "react_app_gapi_client_id" {
#   description = "react_app_gapi_client_id"
#   type = string
#   default = ""
# }
# variable "react_app_hubpot" {
#   description = "react_app_hubpot"
#   type = string
#   default = ""
# }
variable "react_app_h5p_key" {
  description = "react_app_h5p_key"
  type = string
  default = "B6TFsmFD5TLZaWCAYZ91ly0D2We0xjLAtRmBJzQ"
}

variable "tsugi_admin_password" {
  description = "tsugi_admin_password"
  type = string
  default = "tsugi_admin_password"
}



# variable "mail_username" {
#   description = "mail_username"
#   type = string
#   default = "postmaster@currikistudio.org"
# }

# variable "mail_password" {
#   description = "mail_password"
#   type = string
#   default = "mail_password"
# }

# variable "mail_from_address" {
#   description = "mail_from_address"
#   type = string
#   default = "info@currikistudio.org"
# }


# variable "gapi_credentials" {
#   description = "gapi_credentials"
#   type = string
#   default = "gapi_credentials"
# }

# variable "lrs_username" {
#   description = "lrs_username"
#   type = string
#   default = "lrs_username"
# }

# variable "lrs_password" {
#   description = "lrs_password"
#   type = string
#   default = "lrs_password"
# }
variable "postgres_trax_db" {
  description = "postgres_trax_db"
  type = string
  default = "postgres_trax_db"
}

