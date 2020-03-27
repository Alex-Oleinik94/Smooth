#echo off
./_Create_Output_Directoryes.sh
cd ./..
cp ./Sources/Includes/SmoothStandartFileRegistrationResources.inc ./Output/Resources/SmoothFileRegistrationResources.inc
cp ./Sources/Includes/SmoothStandartFileForRegistrationExtensions.inc ./Output/Resources/SmoothFileForRegistrationExtensions.inc
cd ./Scripts
