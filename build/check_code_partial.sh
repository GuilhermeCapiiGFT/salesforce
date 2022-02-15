echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Executing test deploy and running test classes on Partial Org"
sfdx force:source:deploy -u circleci@creditas.com.partial --checkonly  --sourcepath force-app --testlevel RunLocalTests