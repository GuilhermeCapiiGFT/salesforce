echo "Changing to SFDX Project Directory"
cd creditas-sf

#echo "Coverting source to metadata format"
#sfdx force:source:convert -d deploy_code -r force-app

echo "Executing deploy checkonly mode with tests"
#sfdx force:mdapi:deploy -u DevHub -d deploy_code/ -w -1 -l RunLocalTests
#sfdx force:source:deploy -u circleci@creditas.com --checkonly --sourcepath force-app --testlevel RunLocalTests

sfdx force:source:deploy -u circleci@creditas.com --checkonly --sourcepath force-app