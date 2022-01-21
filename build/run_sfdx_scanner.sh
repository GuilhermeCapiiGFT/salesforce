echo "Retrieve Package List from Repository"
sudo apt-get update

echo "Installing JDK"
sudo apt-get install openjdk-11-jre

echo "Install SFDX Scanner"
echo -e 'y/n' | sfdx plugins:install @salesforce/sfdx-scanner

echo "Running SFDX Scanner"
npx sfdx scanner:run --target "**/default/**" --format "csv" --outfile "sfdxScannerAnalysis.csv"