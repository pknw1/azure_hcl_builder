```

██╗  ██╗ ██████╗██╗                                 
██║  ██║██╔════╝██║                                 
███████║██║     ██║                                 
██╔══██║██║     ██║                                 
██║  ██║╚██████╗███████╗                            
╚═╝  ╚═╝ ╚═════╝╚══════╝                            
                                                    
██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗ 
██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                    
```
# HCL Builder Module

a terraform module that generates a platform specific packer manifest in HCL
supports: aws, azure, docker

## Process Logic

### Build a best practice manifest exposing all features optionally

for each specified platform (currently supports docker or Azure)
  read variables from Module file
  - auth 
  - source
  - target
  - build_options

  and create a packer manifest containing 
  - only the required settings fot the selected option
  - only the corresponding variable declarations for selected options
  - ensuring each variable has a "common-denominator" default value set 

  This ensures that the user can specify as few parameters as possible to be passed into the module
  - defaults simplify usage by asking the user to set variables only where they have identified a deviation
  - defaults can be set as per best-practice 
  - every command set is available "out of the box" rather than reading and working with the over 150+ options

  in addition to the manifest, a pkvars template is produced with all of the required parameters specified 
  including their default setting to allow the user to adapt for multi-environments

### Create a cookie-cutter process for passing customization to the process  

Once the required packer source and build fields have been inserted, then dynamically populate the packer
provisioners (see here) to allow the same template to be re-used with different customization files

1. check for Ansible roles in custom/roles - add provisioners as required
2. check for Ansible playbooks in custom/playbooks - add provisioners as required
3. check for shell scripts in custom/scripts - add provisioners with suitable default parameters 

### Extra Files

included in this development release are also 
  `./reset.sh` to allow rapid reset for testing
  `./validate.sh` to allow packer validation outside the environment and folder structure expected in non-local usage 

# ToDo
## High Priority

- Add in all the available options and settings for the [Azure Packer Builder](https://developer.hashicorp.com/packer/plugins/builders/azure/arm)
- Add Post-Processors
- Peer Review

## Lower Priority

- Additional Docker Options
- AWS Provider
- Remote customization files
- Cleaner validation

# Breakdown

- Only pertinent variables are added - with best practice defaults
```
variable "location" { default = "uksouth" }
variable "subscription_id" { default = "" }
variable "client_id" { default = "" }
variable "shared_image_gallery_subscription_id" { default = "test" }
variable "shared_image_gallery_source_resource_group" { default = "test" }
variable "shared_image_gallery_source_gallery_name" { default = "test" }
variable "shared_image_gallery_source_image_name" { default = "test" }
variable "shared_image_gallery_source_image_version" { default = "test" }
variable "managed_image_name" { default = "test" }
variable "managed_image_resource_group_name" { default = "test" }
variable "os_type" { default = "Linux" }
variable "vm_size" { default = "StandardDs1V2" }
```

- the chosen platform and options for authentication 
```
source "azure-arm" "example" {
  location = var.location
  subscription_id = var.subscription_id
  client_id       = var.client_id
```

- the options for the source image
```
  shared_image_gallery {
    subscription   = var.shared_image_gallery_subscription_id
    resource_group = var.shared_image_gallery_source_resource_group
    gallery_name   = var.shared_image_gallery_source_gallery_name
    image_name     = var.shared_image_gallery_source_image_name
    image_version  = var.shared_image_gallery_source_image_version
  }
```

- the options for the destination/target image 
```
  managed_image_name                = var.managed_image_name
  managed_image_resource_group_name = var.managed_image_resource_group_name
```

- various build options and settings
```
  os_type = var.os_type
  vm_size = var.vm_size
```

- automatically prepare and transfer the files for customisation
```
build {
  sources = ["sources.azure-arm.example"]
  provisioner "file" {
    source      = "./custom/"
    destination = "/tmp/custom"
  }
  provisioner "shell" {
    remote_folder = "~/"
    inline        = ["cp -R /tmp/custom ~/", ]
  }
  ```
  
- setting OS defaults for executing specified provisioners using Shell
  ```
  provisioner "shell" {
    remote_folder = "~/"
    inline = ["chmod +x -R ~/custom/scripts/*sh",
      "~/custom/scripts/custom.sh",
      "~/custom/scripts/custom2.sh",
    ]
  }
  ```
  
- or installing Galaxy roles and locally executing Ansible playbooks on the build VM
  ```
  provisioner "ansible-local" {
    galaxy_file = "~/custom/roles/requirements.yml"
    playbook_files = [
      "~/custom/playbooks/custom.yml",
    ]
  }
  ```
  
<details>
<summary>Example Azure Manifest</summary>
  
```  
variable "location" { default = "uksouth" }
variable "subscription_id" { default = "" }
variable "client_id" { default = "" }
variable "shared_image_gallery_subscription_id" { default = "test" }
variable "shared_image_gallery_source_resource_group" { default = "test" }
variable "shared_image_gallery_source_gallery_name" { default = "test" }
variable "shared_image_gallery_source_image_name" { default = "test" }
variable "shared_image_gallery_source_image_version" { default = "test" }
variable "managed_image_name" { default = "test" }
variable "managed_image_resource_group_name" { default = "test" }
variable "os_type" { default = "Linux" }
variable "vm_size" { default = "StandardDs1V2" }

source "azure-arm" "example" {
  location = var.location
  subscription_id = var.subscription_id
  client_id       = var.client_id
  shared_image_gallery {
    subscription   = var.shared_image_gallery_subscription_id
    resource_group = var.shared_image_gallery_source_resource_group
    gallery_name   = var.shared_image_gallery_source_gallery_name
    image_name     = var.shared_image_gallery_source_image_name
    image_version  = var.shared_image_gallery_source_image_version
  }
  managed_image_name                = var.managed_image_name
  managed_image_resource_group_name = var.managed_image_resource_group_name
  os_type = var.os_type
  vm_size = var.vm_size
  
}
build {
  sources = ["sources.azure-arm.example"]
  provisioner "file" {
    source      = "./custom/"
    destination = "/tmp/custom"
  }
  provisioner "shell" {
    remote_folder = "~/"
    inline        = ["cp -R /tmp/custom ~/", ]
  }
  provisioner "shell" {
    remote_folder = "~/"
    inline = ["chmod +x -R ~/custom/scripts/*sh",
      "~/custom/scripts/custom.sh",
      "~/custom/scripts/custom2.sh",
    ]
  }
  provisioner "ansible-local" {
    galaxy_file = "~/custom/roles/requirements.yml"
    playbook_files = [
      "~/custom/playbooks/custom.yml",
    ]
  }
}
  
```
  
</details>
  
  

  <details>
  <summary>Example PKVARS settings template</summary>
  
  ```
 location = "uksouth"
subscription_id = ""
client_id       = ""
shared_image_gallery_subscription_id       = ""
shared_image_gallery_source_resource_group = ""
shared_image_gallery_source_gallery_name   = ""
shared_image_gallery_source_image_name     = ""
shared_image_gallery_source_image_version  = ""
os_type = "Linux"
vm_size = "StandardDs1V2"
# --------------------------------------------------------------------------------------------------

```
  
  </details>