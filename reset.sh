#!/bin/bash
rm terraform.tfstate*
rm manifests/*hcl*
rm .terraform.lock.hcl
terraform init
terrsform plan
