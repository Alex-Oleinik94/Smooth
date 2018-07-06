{$INCLUDE SaGe.inc}

unit SaGePackages;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeResourceManager
	,SaGeDrawClasses
	,SaGeMakefileReader
	,SaGeContextClasses
	
	,Classes
	,Dos
	,StrMan
	;

type
	TSGPackageInfo = object
		public
	FName : TSGString;
	FNames : TSGStringList;
	FSourcesPaths : TSGStringList;
	FIncludesPaths : TSGStringList;
	FUnits : TSGStringList;
	FOpen : TSGBool;
	FDependingPackages : TSGStringList;
	FUnsupportedTargets : TSGStringList;
		public
	property Open : TSGBool read FOpen;
		public
	procedure ZeroMemory();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	end;

function SGGetPackageInfo(const PackagePath : TSGString) : TSGPackageInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGClearFileRegistrationPackages(const FileRegistrationPackages : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRegisterDrawClass(const ClassType : TSGPaintableObjectClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetRegisteredDrawClasses() : TSGDrawClassesObjectList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPackagesToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const BuildFiles : TSGBool = False):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGPackagesToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const PackagesNames : TSGStringList):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGPackageToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const PackageName : TSGString; const BuildFiles : TSGBool = False):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPackageAllreadyInMakefile(var Make : TSGMakefileReader; const PackageName : TSGString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPackagesList(var Make : TSGMakefileReader) : TSGStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsPackageOpen(var Make : TSGMakefileReader;const PackageName : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsPackageOpen(const PackagePath : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGRegisterPackage(const PackageInfo : TSGPackageInfo;const FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	
	,SaGeStringUtils
	,SaGeStreamUtils
	,SaGeFileUtils
	,SaGeLog
	
	{$INCLUDE SaGeFileRegistrationPackages.inc}
	;
var
	PackagesDrawClasses : TSGDrawClassesObjectList = nil;

procedure SGRegisterPackage(const PackageInfo : TSGPackageInfo;const FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	MemStream : TMemoryStream = nil;
	StartSize : TSGUInt64;

procedure WriteName(const PackageName : TSGString);
var
	Exists : TSGBoolean = False;
begin
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SGReadLnStringFromStream(MemStream),' 	/') = PackageName;
if not Exists then
	SGWriteStringToStream('		// ' + PackageName + SGWinEoln, MemStream, False);
end;

procedure RegisterUnit(const UnitName : TSGString);
var
	Exists : TSGBoolean = False;
begin
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SGReadLnStringFromStream(MemStream),' 	,') = UnitName;
if not Exists then
	SGWriteStringToStream('	,' + UnitName + SGWinEoln, MemStream, False);
end;

var
	S : TSGString;
begin
MemStream := TMemoryStream.Create();
MemStream.LoadFromFile(FileRegistrationResources);
StartSize := MemStream.Size;
WriteName(PackageInfo.FName);
for S in PackageInfo.FUnits do
	RegisterUnit(S);
if StartSize <> MemStream.Size then
	MemStream.SaveToFile(FileRegistrationResources);
MemStream.Destroy();
end;

function SGPackageAllreadyInMakefile(var Make : TSGMakefileReader; const PackageName : TSGString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	AddedPackages : TSGString;
	PackageAppellative : TSGString;
	UpCasedPackageName : TSGString;
	i : TSGMaxEnum;
begin
Result := False;
AddedPackages := Make.GetConstant('ADDEDPACKAGES', SGMRIdentifierTypeDependent);
PackageAppellative := '';
UpCasedPackageName := SGUpCaseString(PackageName);
for i := 1 to Length(AddedPackages) do
	begin
	if (AddedPackages[i] = '"') and (PackageAppellative <> '') then
		begin
		if (SGUpCaseString(PackageAppellative) = UpCasedPackageName) then
			Result := True;
		PackageAppellative := '';
		end
	else if (AddedPackages[i] <> '"') then
		PackageAppellative += AddedPackages[i];
	end;
end;

function SGPackageToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const PackageName : TSGString; const BuildFiles : TSGBool = False) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	PackageInfo : TSGPackageInfo;
	Str : TSGString;
begin
Result := False;
PackageInfo := SGGetPackageInfo(Make.GetConstant('SGPACKAGESPATH') + DirectorySeparator + PackageName);
if (SGUpCaseString(PackageInfo.FName) <> SGUpCaseString(PackageName)) then
	TSGLog.Source(['Package "', PackageName, '" have other name "', PackageInfo.FName, '".'])
else if (SGUpCaseString(Target) in PackageInfo.FUnsupportedTargets) then
	TSGLog.Source(['Package "', PackageName, '" unsupporting target "', Target, '".'])
else
	begin
	Result := SGPackagesToMakefile(Make, Target, PackageInfo.FDependingPackages);
	if Result then
		if SGPackageAllreadyInMakefile(Make, PackageName) then
			TSGLog.Source(['Package "', PackageName, '" allready in makefile.'])
		else
			begin
			Make.SetConstant('ADDEDPACKAGES', Make.GetConstant('ADDEDPACKAGES', SGMRIdentifierTypeDependent) + '"' + PackageName + '"');
			for Str in PackageInfo.FSourcesPaths do
				Make.SetConstant(
					'BASEARGS', 
					Make.GetConstant('BASEARGS', SGMRIdentifierTypeDependent) + ' -Fu' + Make.GetConstant('SGPACKAGESPATH') + DirectorySeparator + PackageInfo.FName + DirectorySeparator + Str + ' ');
			for Str in PackageInfo.FIncludesPaths do
				Make.SetConstant(
					'BASEARGS', 
					Make.GetConstant('BASEARGS', SGMRIdentifierTypeDependent) + ' -Fi' + Make.GetConstant('SGPACKAGESPATH') + DirectorySeparator + PackageInfo.FName + DirectorySeparator + Str + ' ');
			Make.RecombineIdentifiers();
			SGRegisterPackage(PackageInfo, Make.GetConstant('SGFILEREGISTRATIONPACKAGES'));
			TSGLog.Source(['Package "', PackageName, '" added.']);
			if BuildFiles and SGFileExists(Make.GetConstant('SGPACKAGESPATH') + DirectorySeparator + PackageInfo.FName + DirectorySeparator + 'BuildFiles.ini') then
				SGBuildFiles(
					Make.GetConstant('SGPACKAGESPATH') + DirectorySeparator + PackageInfo.FName + DirectorySeparator + 'BuildFiles.ini',
					Make.GetConstant('SGRESOURCESPATH'),
					Make.GetConstant('SGRESOURCESCACHEPATH'),
					Make.GetConstant('SGFILEREGISTRATIONRESOURCES'),
					PackageInfo.FName);
			end;
	end;
PackageInfo.Clear();
end;

procedure TSGPackageInfo.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(FNames, 0);
SetLength(FSourcesPaths, 0);
SetLength(FIncludesPaths, 0);
SetLength(FUnits, 0);
SetLength(FDependingPackages, 0);
SetLength(FUnsupportedTargets, 0);
ZeroMemory();
end;

procedure TSGPackageInfo.ZeroMemory();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FName := '';
FNames := nil;
FSourcesPaths := nil;
FIncludesPaths := nil;
FUnits := nil;
FDependingPackages := nil;
FOpen := False;
FUnsupportedTargets := nil;
end;

function SGGetPackageInfo(const PackagePath : TSGString) : TSGPackageInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ProcessParam(const Param, Value : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Param = 'NAMES' then
	begin
	Result.FNames := SGStringListFromString(Value,',');
	SGStringListTrimAll(Result.FNames, ' ');
	Result.FName := Result.FNames[0];
	end
else if Param = 'SOURCESPATHS' then
	begin
	Result.FSourcesPaths := SGStringListFromString(Value,',');
	SGStringListTrimAll(Result.FSourcesPaths, ' ');
	end
else if Param = 'INCLUDESPATHS' then
	begin
	Result.FIncludesPaths := SGStringListFromString(Value,',');
	SGStringListTrimAll(Result.FIncludesPaths, ' ');
	end
else if Param = 'UNITS' then
	begin
	Result.FUnits := SGStringListFromString(Value,',');
	SGStringListTrimAll(Result.FUnits, ' ');
	end
else if Param = SGUpCaseString('DependingPackages') then
	begin
	Result.FDependingPackages := SGStringListFromString(Value,',');
	SGStringListTrimAll(Result.FDependingPackages, ' ');
	end
else if Param = 'OPEN' then
	begin
	Result.FOpen := SGUpCaseString(Value) = 'TRUE';
	end
else if Param = 'UNSUPPORTEDTARGETS' then
	begin
	Result.FUnsupportedTargets := SGStringListFromString(Value,',');
	SGStringListTrimAll(Result.FUnsupportedTargets, ' ');
	Result.FUnsupportedTargets := SGUpCasedStringList(Result.FUnsupportedTargets, True);
	end
else
	begin
	SGHint(['Unknown param name "',Param,'"']);
	end;
end;

var
	Stream : TMemoryStream = nil;
	S, P, V : TSGString;
begin
Result.ZeroMemory();
Stream := TMemoryStream.Create();
Stream.LoadFromFile(PackagePath + DirectorySeparator + 'MakeInfo.ini');
Stream.Position := 0;
repeat
S := SGReadLnStringFromStream(Stream);
until ('[' + StringTrimLeft(StringTrimRight(S,']'),'[') + ']' = S) or (Stream.Position = Stream.Size);
while Stream.Position <> Stream.Size do
	begin
	S := SGReadLnStringFromStream(Stream);
	P := StringWordGet(S,'=',1);
	V := StringWordGet(S,'=',2);
	ProcessParam(SGUpCaseString(P), StringTrimAll(V,' '));
	end;
end;

function SGGetPackagesList(var Make : TSGMakefileReader) : TSGStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	SR : Dos.SearchRec;
const
	PathPrefix : TSGString = '';
begin
Result := nil;
PathPrefix := Make.GetConstant('SGPACKAGESPATH') + '/';
Dos.FindFirst(PathPrefix + '*', $3F, SR);
while DosError <> 18 do
	begin
	if (SR.Name <> '.') and (SR.Name <> '..') and SGExistsDirectory(PathPrefix + SR.Name) and SGIsPackageOpen(PathPrefix + SR.Name) then
		Result += SR.Name;
	Dos.FindNext(SR);
	end;
Dos.FindClose(SR);
end;

function SGIsPackageOpen(const PackagePath : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PackageInfo : TSGPackageInfo;
begin
PackageInfo := SGGetPackageInfo(PackagePath);
Result := PackageInfo.Open;
PackageInfo.Clear();
end;

function SGIsPackageOpen(var Make : TSGMakefileReader;const PackageName : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PackagesList : TSGStringList = nil;
begin
PackagesList := SGGetPackagesList(Make);
Result := PackageName in PackagesList;
SetLength(PackagesList, 0);
end;

function SGPackagesToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const PackagesNames : TSGStringList):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	S : TSGString;
begin
Result := True;
for S in PackagesNames do
	begin
	if not SGPackageToMakefile(Make, Target, S) then
		begin
		Result := False;
		break;
		end;
	end;
end;

function SGPackagesToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const BuildFiles : TSGBool = False) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PackagesList : TSGStringList = nil;
	i : TSGUInt32;
begin
Result := True;
PackagesList := SGGetPackagesList(Make);
if PackagesList <> nil then
	if Length(PackagesList) > 0 then
		for i := 0 to High(PackagesList) do
			if not SGPackageToMakefile(Make, Target, PackagesList[i], BuildFiles) then
				Result := False;
SetLength(PackagesList, 0);
end;

function SGGetRegisteredDrawClasses() : TSGDrawClassesObjectList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := PackagesDrawClasses;
end;

procedure SGRegisterDrawClass(const ClassType : TSGPaintableObjectClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if PackagesDrawClasses = nil then
	SetLength(PackagesDrawClasses, 1)
else
	SetLength(PackagesDrawClasses, Length(PackagesDrawClasses) + 1);
PackagesDrawClasses[High(PackagesDrawClasses)].FClass := ClassType;
PackagesDrawClasses[High(PackagesDrawClasses)].FDrawable := Drawable;
end;

procedure SGClearFileRegistrationPackages(const FileRegistrationPackages : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TFileStream = nil;
begin
Stream := TFileStream.Create(FileRegistrationPackages, fmCreate);
SGWriteStringToStream('(*This is part of SaGe Engine*)'+SGWinEoln,Stream,False);
SGWriteStringToStream('//File registration packages. Packages:'+SGWinEoln,Stream,False);
Stream.Destroy();
end;

initialization
begin

end;

end.
