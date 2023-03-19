resource "local_file" "packer_vars" {
  for_each = local.platforms

  filename = "manifests/${each.key}_pkvars.pkr.hcl"
  content = <<-EOT


%{ if each.key == "azure" }

location="uksouth"
%{ if var.azure_auth == "sp" }
subscription_id                                         =""
client_id                                               =""
client_secret                                           =""
tenant_id                                               =""
%{ endif }

%{ if var.azure_auth == "managed_identity" }
subscription_id                                         =""
client_id                                               =""
%{ endif }

%{ if var.azure_auth == "interactive" }
use_interactive_auth                                    =""
%{ endif }

%{ if var.azure_auth == "sp_certs" }
subscription_id                                         =""
client_id                                               =""
client_cert_token_timeout                               =""
client_jwt                                              =""
%{ endif }

%{ if var.azure_source == "azure_image" }

azure_source_image_publisher                            =""
azure_source_image_offer                                =""
azure_source_image_sku                                  =""

%{ endif }

%{ if var.azure_source == "image_url" }
image_url                                               =""
%{ endif }

%{ if var.azure_source == "managed_image" }
managed_image_name                                      =""
managed_image_resource_group_name                       =""
managed_image_storage_account_type                      =""
managed_image_os_disk_snapshot_name                     =""
managed_image_data_disk_snapshot_prefix                 =""
%{ endif }

%{ if var.azure_source == "shared_image_gallery" }
shared_image_gallery_subscription_id                    =""
shared_image_gallery_source_resource_group              =""
shared_image_gallery_source_gallery_name                =""
shared_image_gallery_source_image_name                  =""
shared_image_gallery_source_image_version               =""
%{ endif }


%{ if var.azure_target == "vhd" }
%{ endif }

%{ if var.azure_target == "manage_image" }
managed_image_name                                      =""
managed_image_resource_group_name                       ="" 
%{ endif }

%{ if var.azure_target == "shared_image_gallery" }
shared_image_gallery_destination_subscription_id        =""
shared_image_gallery_destination_resource_group         =""
shared_image_gallery_destination_gallery_name           =""
shared_image_gallery_destination_image_name             =""
shared_image_gallery_destination_image_version          =""
shared_image_gallery_destination_replication_regions    =""
shared_image_gallery_destination_storage_account_type   =""


%{ endif }

os_type                                                 ="Linux"
vm_size                                                 ="StandardDs1V2"

%{ if var.build_resource_group == "true" }
build_resource_group_name                               =""
%{ endif }


%{ if var.build_network == "true" }
virtual_network_name                                    =""
virtual_network_subnet_name                             =""
virtual_network_resource_group_name                     =""
%{ endif }

# --------------------------------------------------------------------------------------------------

%{ endif }

  EOT
}
