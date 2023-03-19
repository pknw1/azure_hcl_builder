
resource "null_resource" "format" {

 #triggers = {
 #   #always_run = "${timestamp()}"
 #   version    = var.shared_image_gallery_destination_target_version
 # }

  provisioner "local-exec" {
  command = "packer fmt -recursive manifests/ && for f in $(ls manifests/*.pkr.hcl); do outfile=$(echo $f | sed 's/.pkr/-final.pkr/g'); cat $f | sed '/^$/d' | tee $outfile; done && ls manifests/*hcl | grep -v final | xargs rm"
}

depends_on = [ local_file.manifests, local_file.packer_vars ]
}