echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Executing deploy to Test Org"
sfdx force:source:deploy -u circleci@creditas.com.test --sourcepath force-app --testlevel RunLocalTests