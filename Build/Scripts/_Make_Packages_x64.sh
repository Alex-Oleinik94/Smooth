#echo off
./_Create_Output_Directoryes.sh
cd ./..
if [ -e ./../Binaries/Main_Console ]; then
	echo "==================================="
	echo "| Compiling Packages for Windows  |"
	echo "==================================="
	target=$1
	if [$target -eq ""]; then
		target= "debug"
	fi
	./../Binaries/Main_Console --build -x86_64 -packages $target
	errorlevel=$?
	if [ $errorlevel -eq 0 ]; then
		cp ./../Binaries/Main ./../Binaries/Main_Packages
		chmod +x ./../Binaries/Main_Packages
	fi
else 
	echo "Compile debug executable first!"
fi
cd ./Scripts
