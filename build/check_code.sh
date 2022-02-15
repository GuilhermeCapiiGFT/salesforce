echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Production: Executing test deploy and running test classes..."
sfdx force:source:deploy -u circleci@creditas.com --checkonly --sourcepath force-app --testlevel RunLocalTests
echo "Production: Test deploy and test class execution complete."