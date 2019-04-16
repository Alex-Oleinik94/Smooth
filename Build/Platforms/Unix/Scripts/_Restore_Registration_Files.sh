#echo off
./_Create_Output_Directoryes.sh
cd ./..
cp ./Sources/Includes/SaGeStandartFileRegistrationResources.inc ./Output/Resources/SaGeFileRegistrationResources.inc
cp ./Sources/Includes/SaGeStandartFileForRegistrationExtensions.inc ./Output/Resources/SaGeFileForRegistrationExtensions.inc
cd ./Scripts
