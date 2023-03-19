

variable "target_platforms"  {}
variable "extra_vars" { default = null }

locals {
  custom_scripts = fileset(".", "custom/scripts/*sh")
  custom_roles = fileset(".", "custom/roles/*yml")
  custom_playbooks = fileset(".", "custom/playbooks/*yml")
  platforms = tomap({ for cloud in var.target_platforms: cloud => cloud })
}

resource "local_file" "manifests" {
  for_each = local.platforms

  filename = "manifests/${each.key}.pkr.hcl"
  content = <<-EOT


%{ if each.key == "azure" }

variable "location" { default = "uksouth" }
%{ if var.azure_auth == "sp" }
variable "subscription_id" { default = "" }
variable "client_id" { default = "" }
variable "client_secret" { default = "" }
variable "tenant_id " { default = "" }
%{ endif }

%{ if var.azure_auth == "managed_identity" }
variable "subscription_id" { default = "" }
variable "client_id" { default = "" }
%{ endif }

%{ if var.azure_auth == "interactive" }
use_interactive_auth" { default = "" }
%{ endif }

%{ if var.azure_auth == "sp_certs" }
variable "subscription_id" { default = "" }
variable "client_id" { default = "" }
variable "client_cert_token_timeout" { default = "" }
variable "client_jwt" { default = "" }
%{ endif }

%{ if var.azure_source == "azure_image" }

variable "azure_source_image_publisher" { default = "test" }
variable "azure_source_image_offer" { default = "test" }
variable "azure_source_image_sku" { default = "test" }

%{ endif }

%{ if var.azure_source == "image_url" }
variable "image_url" { default = "" }
%{ endif }

%{ if var.azure_source == "managed_image" }
variable "managed_image_name" { default = "test" }
variable "managed_image_resource_group_name" { default = "test" }
variable "managed_image_storage_account_type" { default = "StandardLRS" }
variable "managed_image_os_disk_snapshot_name" { default = "test" }
variable "managed_image_data_disk_snapshot_prefix" { default = "test" }
%{ endif }

%{ if var.azure_source == "shared_image_gallery" }
variable "shared_image_gallery_subscription_id" { default = "test" }
variable "shared_image_gallery_source_resource_group" { default = "test" }
variable "shared_image_gallery_source_gallery_name" { default = "test" }
variable "shared_image_gallery_source_image_name" { default = "test" }
variable "shared_image_gallery_source_image_version" { default = "test" }
%{ endif }


%{ if var.azure_target == "vhd" }
%{ endif }

%{ if var.azure_target == "managed_image" }
variable "managed_image_name" { default = "test" }
variable "managed_image_resource_group_name" { default = "test" } 
%{ endif }

%{ if var.azure_target == "shared_image_gallery" }
variable "shared_image_gallery_destination_subscription_id" { default = "" }
variable "shared_image_gallery_destination_resource_group" { default = "test" }
variable "shared_image_gallery_destination_gallery_name" { default = "test" }
variable "shared_image_gallery_destination_image_name" { default = "test" }
variable "shared_image_gallery_destination_image_version" { default = "test" }
variable "shared_image_gallery_destination_replication_regions" { default = "uksouth" }
variable "shared_image_gallery_destination_storage_account_type" { default = "StandardLRS" }


%{ endif }

variable "os_type" { default = "Linux" }
variable "vm_size" { default = "StandardDs1V2" }

%{ if var.build_resource_group == "true" }
variable "build_resource_group_name" { default = "test" }
%{ endif }


%{ if var.build_network == "true" }
variable "virtual_network_name" { default = "test" }
variable "virtual_network_subnet_name" { default = "test" }
variable "virtual_network_resource_group_name" { default = "test" }
%{ endif }

# --------------------------------------------------------------------------------------------------

%{ endif }


%{ if each.key == "azure" }
source "azure-arm" "example" {

  location = var.location

%{ if var.azure_auth == "sp" }
  subscription_id                         = var.subscription_id
  client_id                               = var.client_id
  client_secret                           = var.client_secret
  tenant_id                               = var.tenant_id 
%{ endif }

%{ if var.azure_auth == "managed_identity" }
subscription_id                           = var.subscription_id
client_id                                 = var.client_id
%{ endif }

%{ if var.azure_auth == "interactive" }
use_interactive_auth
%{ endif }

%{ if var.azure_auth == "sp_certs" }
subscription_id                           = var.subscription_id
client_id                                 = var.client_id
client_cert_token_timeout                 = var.client_cert_token_timeout
client_jwt                                = var.client_jwt
%{ endif }

%{ if var.azure_source == "azure_image" }

image_publisher                           = var.azure_source_image_publisher
image_offer                               = var.azure_source_image_offer
image_sku                                 = var.azure_source_image_sku

%{ endif }

%{ if var.azure_source == "image_url" }
image_url                                 = var.image_url
%{ endif }

%{ if var.azure_source == "managed_image" }
managed_image_name                        = var.managed_image_name
managed_image_resource_group_name         = var.managed_image_resource_group_name
managed_image_storage_account_type        = var.managed_image_storage_account_type
managed_image_os_disk_snapshot_name       = var.managed_image_os_disk_snapshot_name
managed_image_data_disk_snapshot_prefix   = var.managed_image_data_disk_snapshot_prefix
%{ endif }

%{ if var.azure_source == "shared_image_gallery" }
shared_image_gallery{
        subscription                      = var.shared_image_gallery_subscription_id
        resource_group                    = var.shared_image_gallery_source_resource_group
        gallery_name                      = var.shared_image_gallery_source_gallery_name
        image_name                        = var.shared_image_gallery_source_image_name
        image_version                     = var.shared_image_gallery_source_image_version

}
%{ endif }


%{ if var.azure_target == "vhd" }
%{ endif }

%{ if var.azure_target == "managed_image" }
managed_image_name                        = var.managed_image_name
managed_image_resource_group_name         = var.managed_image_resource_group_name 
%{ endif }

%{ if var.azure_target == "shared_image_gallery" }
shared_image_gallery_destination {
        subscription                      = var.shared_image_gallery_destination_subscription_id
        resource_group                    = var.shared_image_gallery_destination_resource_group
        gallery_name                      = var.shared_image_gallery_destination_gallery_name
        image_name                        = var.shared_image_gallery_destination_image_name
        image_version                     = var.shared_image_gallery_destination_image_version
        replication_regions               = [ var.shared_image_gallery_destination_replication_regions ]
        storage_account_type              = var.shared_image_gallery_destination_storage_account_type

}
%{ endif }

os_type                                   = var.os_type
vm_size                                   = var.vm_size

%{ if var.build_resource_group == "true" }
build_resource_group_name                 = var.build_resource_group_name
%{ endif }


%{ if var.build_network == "true" }
virtual_network_name                      = var.virtual_network_name
virtual_network_subnet_name 	            = var.virtual_network_subnet_name
virtual_network_resource_group_name       = var.virtual_network_resource_group_name
%{ endif }

# --------------------------------------------------------------------------------------------------

%{ endif }
}

%{ if each.key == "docker" }
source "docker" "example" {
  image = "ubuntu"
  export_path = "image.tar"
}
%{ endif }


build {
%{ if each.key == "azure" }
sources = ["sources.azure-arm.example"]
%{ endif }


%{ if each.key == "docker" }
sources = ["sources.docker.example"]
%{ endif }

  provisioner "file" {
      source = "./custom/"
      destination = "/tmp/custom"
  }

  provisioner "shell" {
    remote_folder = "~/"
    inline =  [ "cp -R /tmp/custom ~/", ]
  }

%{ if local.custom_scripts != [] }
  provisioner "shell" {
    remote_folder = "~/"
    inline =  [ "chmod +x -R ~/custom/scripts/*sh",
    %{ for script in local.custom_scripts ~}
      "~/${script}",
    %{ endfor ~}
      ]
  }
%{ endif }

%{ if local.custom_playbooks != [] }
  provisioner "ansible-local" {
  %{ if local.custom_roles != [] }
    %{ for role in local.custom_roles ~}
      galaxy_file = "~/${role}"
    %{ endfor ~}
  %{ endif }
    playbook_files =  [ 
%{ for playbook in local.custom_playbooks ~}
      "~/${playbook}",
%{ endfor ~}
    ]
%{ if var.extra_vars != null }
    extra_vars = [ 
  %{ for extra_var in var.extra_vars ~}
        "${extra_var}",
  %{ endfor ~}
    ]
%{ endif }
  }
%{ endif }
  } 
  
  EOT
}
