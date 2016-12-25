{$INCLUDE SaGe.inc}

unit SaGePackages;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeResourceManager
	,SaGeCommonClasses
	,SaGeCommonUtils
	,SaGeMakefileReader
	
	,Classes
	;

procedure SGClearFileRegistrationPackages(const FileRegistrationPackages : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRegisterDrawClass(const ClassType : TSGDrawableClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetRegisteredDrawClasses() : TSGDrawClassesObjectList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPackagesToMakefile(var Make : TSGMakefileReader);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPackageToMakefile(var Make : TSGMakefileReader; const PackageName : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPackagesList(var Make : TSGMakefileReader) : TSGStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsPackageOpen(var Make : TSGMakefileReader;const PackageName : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	crt
	{$INCLUDE SaGeFileRegistrationPackages.inc}
	;
var
	PackagesDrawClasses : TSGDrawClassesObjectList = nil;

procedure SGPackageToMakefile(var Make : TSGMakefileReader; const PackageName : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin

end;

function SGGetPackagesList(var Make : TSGMakefileReader) : TSGStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	PathPrefix : TSGString = '';
begin
PathPrefix := Make.GetConstant('SGPACKAGESPATH') + '/';

end;

function SGIsPackageOpen(var Make : TSGMakefileReader;const PackageName : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	PackagesList : TSGStringList = nil;
begin
PackagesList := SGGetPackagesList(Make);
Result := PackageName in PackagesList;
SetLength(PackagesList, 0);
end;

procedure SGPackagesToMakefile(var Make : TSGMakefileReader);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	PackagesList : TSGStringList = nil;
	i : TSGUInt32;
begin
PackagesList := SGGetPackagesList(Make);
if PackagesList <> nil then
	if Length(PackagesList) > 0 then
		for i := 0 to High(PackagesList) do
			SGPackageToMakefile(Make, PackagesList[i]);
SetLength(PackagesList, 0);
end;

function SGGetRegisteredDrawClasses() : TSGDrawClassesObjectList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := PackagesDrawClasses;
end;

procedure SGRegisterDrawClass(const ClassType : TSGDrawableClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
