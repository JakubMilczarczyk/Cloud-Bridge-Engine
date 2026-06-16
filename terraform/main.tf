terraform {
    required_providers {
        oci = {
            source = "oracle/oci"
            version = ">= 5.0.0"
            }
        }
}

provider "oci" {
    config_file_profile = "DEFAULT"
}

variable "tenancy_ocid" {
    type = string
    description = "ocid1.tenancy.oc1..aaaaaaaavmtzoci6k53lxqf6txf4dxdlked7zubvpikp6h2oltzbdjl7b2eq"
}

data "oci_identity_availability_domains" "ad" {
    compartment_id = var.tenancy_ocid
}
output "available_domains" {
    value = data.oci_identity_availability_domains.ad.availability_domains[*].name
    description = "List of free Data Centers in chosen region."
}