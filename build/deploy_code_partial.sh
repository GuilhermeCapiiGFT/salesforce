echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Deploying code to Partial Org"
sfdx force:source:deploy -u circleci@creditas.com.partial --sourcepath force-app --testlevel RunLocalTests