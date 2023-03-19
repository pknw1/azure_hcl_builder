module "generate_manifests" {
  source = "./src/"
  target_platforms = ["azure"]
  azure_auth= "managed_identity" 
  azure_target= "managed_image"
  azure_source= "shared_image_gallery" 
}