terraform -chdir=terraform plan -out tfplan.tfplan
terraform -chdir=terraform show -json tfplan.tfplan > terraform/tfplan.json
jq '{"tfplan": .}' < terraform/tfplan.json > terraform/evaluation.json
opa exec --decision corp/policies --bundle policies terraform/evaluation.json
rm terraform/tfplan.tfplan terraform/tfplan.json terraform/evaluation.json