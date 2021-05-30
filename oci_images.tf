#File used only if Stack is a Marketplace Stack
#Update based on Marketplace Listing - App Install Package - Image ocid
#Each element is a single image from Marketpalce Catalog. Elements' name in map is arbitrary 

variable "marketplace_source_images" {
  type = map(object({
    ocid = string
    is_pricing_associated = bool
    compatible_shapes = list(string)
  }))
  default = {
    ## Curriki App Image OCID Details
    main_mktpl_image = {
      ocid = "ocid1.image.oc1..aaaaaaaaltpvosxplkutnd4ulqauo5cvm25bs6bfxvddfa5fm6k4bkqv6voa"
      is_pricing_associated = false
     compatible_shapes = ["VM.Standard2.2", "VM.Standard2.4", "VM.Standard2.8", "VM.Standard2.16", "VM.Standard.E3.Flex", "VM.Standard.E4.Flex"]
    }
    
    ## Curriki DB Image OCID Details
    supporting_image = {
     ocid = "ocid1.image.oc1..aaaaaaaayj4cbyhgmgww4h55llswtt3mtgmzf7lhvsinio4grgvri3pcrkvq"
     is_pricing_associated = false
     compatible_shapes = ["VM.Standard2.2", "VM.Standard2.4", "VM.Standard2.8", "VM.Standard2.16", "VM.Standard.E3.Flex", "VM.Standard.E4.Flex"]
    }

    ## Curriki ElasticSearch Image OCID Details
    supporting_image = {
     ocid = "ocid1.image.oc1..aaaaaaaaxy6uy3oab2q5pc4fjhzineeesmgcyvba265xabmkx2tqou73x4dq"
     is_pricing_associated = false
     compatible_shapes = ["VM.Standard2.2", "VM.Standard2.4", "VM.Standard2.8", "VM.Standard2.16", "VM.Standard.E3.Flex", "VM.Standard.E4.Flex"]
    }
  }
}
