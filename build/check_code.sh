echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Executing test deploy and running test classes"
sfdx force:source:deploy -u circleci@creditas.com --checkonly --sourcepath force-app --testlevel RunLocalTests