echo "Changing to SFDX Project Directory"
cd creditas-sf

#echo "Coverting source to metadata format"
#sfdx force:source:convert -d deploy_code -r force-app

#sfdx force:mdapi:deploy -u DevHub -d deploy_code/ -w -1 -l RunLocalTests
#sfdx force:source:deploy -u circleci@creditas.com --checkonly --sourcepath force-app --testlevel RunLocalTests

# Grab and store the enuqueued job ID using sed
echo "Executing test deploy and running test classes"
ID=$(sfdx force:source:deploy -u circleci@creditas.com --checkonly --sourcepath force-app --testlevel RunLocalTests --json 2> /dev/null | jq -r .result.id)
echo "JOB ID: $ID"
echo "Running deploy with job id..."
sfdx force:source:deploy -u circleci@creditas.com --validateddeployrequestid $ID