#!/bin/bash
cd manifests
cp azure-final.pkr.hcl azure-final-tmp.pkr.hcl
cat azure-final.pkr.hcl | sed  's/~/./g' | tee azure-final-tmp.pkr.hcl
packer validate azure-final-tmp.pkr.hcl && rm azure-final-tmp.pkr.hcl || echo "errors found"
