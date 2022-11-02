opa build -b policies
INSTANCE_ID=$(ibmcloud resource service-instance CloudObjectStorage --id | awk -F ' ' '$2 ~ /^[0-9]/ {print $2}')
ibmcloud cos config crn $INSTANCE_ID
ibmcloud cos object-put --bucket policyascodejm --key bundle.tar.gz --body bundle.tar.gz
rm bundle.tar.gz