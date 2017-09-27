#echo off
cd ./..
cd ./../Binaries
./Main -ic
errorlevel=$?
if [ $errorlevel -eq 1 ];  then
	cp ./Main ./Main_Console
	chmod +x ./Main_Console
fi
cd ./../Build
cd ./Scripts
