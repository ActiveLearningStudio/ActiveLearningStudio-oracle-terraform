#Get APP Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "mp_app_image_agreement" {
  count = local.mp_app_subscription_enabled

  listing_id               = local.listing_app_id
  listing_resource_version = local.listing_app_resource_version
}

#Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "mp_app_image_subscription" {
  count = local.mp_app_subscription_enabled

  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.mp_app_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.mp_app_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.mp_app_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.mp_app_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.mp_app_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.mp_app_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

# Gets the partner image subscription
data "oci_core_app_catalog_subscriptions" "mp_app_image_subscription" {
  count = local.mp_app_subscription_enabled

  compartment_id = var.compartment_ocid
  listing_id     = local.listing_app_id

  filter {
    name   = "listing_resource_version"
    values = [local.listing_app_resource_version]
  }
}


#Get DB Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "mp_db_image_agreement" {
  count = local.mp_db_subscription_enabled

  listing_id               = local.listing_db_id
  listing_resource_version = local.listing_db_resource_version
}

#Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "mp_db_image_subscription" {
  count = local.mp_db_subscription_enabled

  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.mp_db_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.mp_db_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.mp_db_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.mp_db_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.mp_db_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.mp_db_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

# Gets the partner image subscription
data "oci_core_app_catalog_subscriptions" "mp_db_image_subscription" {
  count = local.mp_db_subscription_enabled

  compartment_id = var.compartment_ocid
  listing_id     = local.listing_db_id

  filter {
    name   = "listing_resource_version"
    values = [local.listing_db_resource_version]
  }
}


#Get Elastic Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "mp_es_image_agreement" {
  count = local.mp_es_subscription_enabled

  listing_id               = local.listing_es_id
  listing_resource_version = local.listing_es_resource_version
}

#Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "mp_es_image_subscription" {
  count = local.mp_es_subscription_enabled

  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.mp_es_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.mp_es_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.mp_es_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.mp_es_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.mp_es_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.mp_es_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

# Gets the partner image subscription
data "oci_core_app_catalog_subscriptions" "mp_es_image_subscription" {
  count = local.mp_es_subscription_enabled

  compartment_id = var.compartment_ocid
  listing_id     = local.listing_es_id

  filter {
    name   = "listing_resource_version"
    values = [local.listing_es_resource_version]
  }
}
