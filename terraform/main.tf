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

# --- 1.VCN ---
resource "oci_core_vcn" "cloud_bridge_vcn" {
    compartment_id = var.tenancy_ocid
    cidr_block     = "10.0.0.0/16"
    display_name   = "cloud-bridge-vcn"
}

# --- 2.Internet Getaway ---
resource "oci_core_internet_gateway" "igw" {
    compartment_id = var.tenancy_ocid
    vcn_id         = oci_core_vcn.cloud_bridge_vcn.id
    enabled        = true
    display_name   = "cloud-bridge-igw"
}

# --- 3. Routing Table ---
resource "oci_core_default_route_table" "public_routing" {
    manage_default_resource_id = oci_core_vcn.cloud_bridge_vcn.default_route_table_id

    route_rules {
        network_entity_id = oci_core_internet_gateway.igw.id
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
    }
}

# --- 4. Security List (Firewall) ---
resource "oci_core_security_list" "public_sl" {
    compartment_id = var.tenancy_ocid
    vcn_id         = oci_core_vcn.cloud_bridge_vcn.id
    display_name   = "cloud-bridge-security-list"

    egress_security_rules {
        destination = "0.0.0.0/0"
        protocol    = "all"
    }

    # SSH (Port 22)
    ingress_security_rules {
        source = "0.0.0.0/0"    # For Tests
        protocol = "6"
        tcp_options {
            min = 22
            max = 22
        }
    }

    # HTTP (Port 80)
    ingress_security_rules {
        source = "0.0.0.0/0"
        protocol = "6"
        tcp_options {
            min = 80
            max = 80
        }
    }

    # HTTPS (Port 443)
    ingress_security_rules {
        source = "0.0.0.0/0"
        protocol = "6"
        tcp_options {
            min = 443
            max = 443
        }
    }
}

# --- 5. Subnet ---
resource "oci_core_subnet" "public_subnet" {
    compartment_id = var.tenancy_ocid
    vcn_id         = oci_core_vcn.cloud_bridge_vcn.id
    cidr_block     = "10.0.1.0/24"
    display_name   = "cloud-bridge-public-subnet"
    security_list_ids = [oci_core_security_list.public_sl.id]
    route_table_id = oci_core_vcn.cloud_bridge_vcn.default_route_table_id
}

# --- 6. Auto generate SSH KEYS ---
resource "tls_private_key" "compute_ssh_key" {
    algorithm = "RSA"
    rsa_bits = 2048
}

resource "local_file" "private_key" {
    content         = tls_private_key.compute_ssh_key.private_key_pem
    filename        = "${path.module}/cloud_bridge_key.pem"
    file_permission = "0600"
}

# --- 7. Oracle Linux 8 ---
data "oci_core_images" "ubuntu_image" {
    compartment_id           = var.tenancy_ocid
    operating_system         = "Oracle Linux"
    operating_system_version = "8"
    shape                    = "VM.Standard.E2.1.Micro"
    #sort_by                  = "TIMECREATED"
    #sort_order               = "DESC"
}

# --- 8. Compute Instance ---
resource "oci_core_instance" "app_server" {
    availability_domain = data.oci_identity_availability_domains.ad.availability_domains[1].name
    compartment_id      = var.tenancy_ocid
    display_name        = "cloud-bridge-server"
    shape               = "VM.Standard.E2.1.Micro"

    create_vnic_details {
        subnet_id        = oci_core_subnet.public_subnet.id
        display_name     = "primary-vnic"
        assign_public_ip = true
    }

    source_details {
        source_type = "image"
        source_id   = data.oci_core_images.ubuntu_image.images[1].id
    }

    metadata = {
        ssh_authorized_keys = tls_private_key.compute_ssh_key.public_key_openssh
    }
}

# --- 9. Print public IP ---
output "server_public_ip" {
    value       = oci_core_instance.app_server.public_ip
    description = "Our public IP adress. Note it!"
}