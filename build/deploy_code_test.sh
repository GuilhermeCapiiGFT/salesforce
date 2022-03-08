echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Test: Deploying code to Test Org..."
sfdx force:source:deploy -u circleci@creditas.com.test --sourcepath force-app --testlevel RunLocalTests