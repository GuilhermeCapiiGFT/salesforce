echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Partial: Executing test deploy and running test classes..."
sfdx force:source:deploy -u circleci@creditas.com.partial --checkonly  --sourcepath force-app --testlevel RunLocalTests
echo "Partial: Test deploy and test class execution complete.