echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Executing test deploy to Test Org"
sfdx force:source:deploy -u circleci@creditas.com.test --checkonly --sourcepath force-app