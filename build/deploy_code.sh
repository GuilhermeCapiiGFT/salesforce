echo "Changing to SFDX Project Directory"
cd creditas-sf

# Grab and store the enuqueued job ID using sed
echo "Production: Executing test deploy and running test classes"
ID=$(sfdx force:source:deploy -u circleci@creditas.com --checkonly --sourcepath force-app --testlevel RunLocalTests --json 2> /dev/null | jq -r .result.id)
echo "Test Deploy Job Id: $ID"
echo "Production: Deploying package with job id $ID"
sfdx force:source:deploy -u circleci@creditas.com --validateddeployrequestid $ID