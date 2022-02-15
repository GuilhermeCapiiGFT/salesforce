echo "Changing to SFDX Project Directory"
cd creditas-sf

echo "Test: Executing test deploy..."
sfdx force:source:deploy -u circleci@creditas.com.test --checkonly --sourcepath force-app
echo "Partial: Test deploy complete."