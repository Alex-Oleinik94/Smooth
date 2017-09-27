#echo off
./_Create_Output_Directoryes.sh
cd ./..
cp ./Sources/Includes/SaGeStandartFileRegistrationResources.inc ./Output/Resources/SaGeFileRegistrationResources.inc
cp ./Sources/Includes/SaGeStandartFileRegistrationPackages.inc ./Output/Resources/SaGeFileRegistrationPackages.inc
cd ./Scripts
