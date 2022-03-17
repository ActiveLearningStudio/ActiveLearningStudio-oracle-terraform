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
variable "mp_app_subscription_enabled" {
  description = "Subscribe to Marketplace listing APP?"
  type        = bool
  default     = true
}


variable "mp_app_listing_id" {
  // default = "ocid1.appcataloglisting.oc1.."
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaagwlhiykamroczsyg7rfmlbvooukzzktbuwjmrfhsvj4n6aicvi2a"
  description = "Marketplace Listing OCID APP"
}

variable "mp_listing_resource_app_id" {
  // default = "ocid1.image.oc1.."
  default     = "ocid1.image.oc1..aaaaaaaaltpvosxplkutnd4ulqauo5cvm25bs6bfxvddfa5fm6k4bkqv6voa"
  description = "Marketplace Listing Image APP OCID"
}


variable "mp_app_listing_resource_version" {
  // default = "1.0"
  default     = "v1.0.0"
  description = "Marketplace Listing Package/Resource Version APP"
}



############################
#  Custom Image           #
############################
variable "app_custom_image_id" {
  default     = "ocid1.image.oc1.iad.aaaaaaaa4lddjnybp32wzwsfukem5fnpfniszjbrww7vu6x7svevlcsejtnq"
  description = "APP Image OCID"
}


############################
#  Compute Configuration   #
############################

# variable "vm_display_name" {
#   description = "Instance Name"
#   default     = "simple-vm"
# }

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

# variable "hostname_label" {
#   default     = "simple"
#   description = "DNS Hostname Label. Must be unique across all VNICs in the subnet and comply with RFC 952 and RFC 1123."
# }

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
  default     = "curriki-vcn"
}

variable "vcn_cidr_block" {
  description = "VCN CIDR"
  default     = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  description = "VCN DNS Label"
  default     = "currikivcn"
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



variable "subnet_display_name" {
  description = "Subnet Name"
  default     = "app-subnet"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR"
  default     = "10.0.0.0/24"
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
  default     = "curriki-studio-network-security-group"
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
  default     = "curriki-studio"
}

variable "tag_value" {
  description = "Free-form tag value"
  default     = "curriki-studio-application"
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




variable "main_site" {
  description = "Main Site URL (Must not start with http or https)"
  type = string
  default = "oracle.curriki.org"
}
variable "tsugi_site" {
  description = "Tsugi Site URL (Must not start with http or https)"
  type = string
  default = "oracle-tsugi.curriki.org"
}
variable "lrs_site" {
  description = "LRS Site URL (Must not start with http or https)"
  type = string
  default = "oracle-trax.curriki.org"
}


variable "mysql_user" {
  description = "MySQL User Name"
  type = string
  default = "mysql_user"
}
variable "mysql_password" {
  description = "Password for MySQL User"
  type = string
  default = "mysql_password"
}
variable "mysql_root_password" {
  description = "MySQL Root User password"
  type = string
  default = "mysql_root_password"
}
variable "tsugi_database" {
  description = "Tsugi Database Name"
  type = string
  default = "tsugi_database"
}
variable "tsugi_admin_password" {
  description = "Admin Password for tsugi (Login with https://oracle-tsugi.curriki.org)"
  type = string
  default = "tsugi_admin_password"
}

variable "mysql_port" {
  description = "MySQL Port"
  type = string
  default = "3307"
}
variable "phpmyadmin_port" {
  description = "PhpMyAdmin Port (http://ip-of-database-instance:7000)"
  type = string
  default = "7000"
}

variable "elastic_password" {
  description = "ElasticSearch Password"
  type = string
  default = "elastic_password"
}

variable "postgres_user" {
  description = "Postgres User"
  type = string
  default = "postgres_user"
}
variable "postgres_password" {
  description = "Postgres Password"
  type = string
  default = "postgres_password"
}
variable "postgres_db" {
  description = "Postgres Database"
  type = string
  default = "postgres_db"
}

variable "postges_port" {
  description = "Postgres Database port"
  type = string
  default = "5434"
}

variable "postgres_lrs_db" {
  description = "Name of Trax Database"
  type = string
  default = "postgres_lrs_db"
}


variable "pgadmin_email" {
  description = "PGAdmin Email"
  type = string
  default = "admin@curriki.org"
}
variable "pgadmin_password" {
  description = "PGAdmin Password"
  type = string
  default = "pgadmin_password"
}
variable "pgadmin_port" {
  description = "Expose IP of pgadmin to http (http://ip-of-database-instance:8080)"
  type = string
  default = "8080"
}

variable "react_app_pexel_api" {
  description = "react_app_pexel_api"
  type = string
  default = "563492ad6f91700001000001155d7b75f5424ea694b81ce9f867dddf"
}

