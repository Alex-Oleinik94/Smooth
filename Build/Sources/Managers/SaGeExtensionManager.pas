{$INCLUDE SaGe.inc}

unit SaGeExtensionManager;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeResourceManager
	,SaGePaintableObjectContainer
	,SaGeMakefileReader
	,SaGeContextClasses
	
	,Classes
	,Dos
	,StrMan
	;

type
	TSGExtensionInfo = object
		public
	FName : TSGString;
	FNames : TSGStringList;
	FSourcesPaths : TSGStringList;
	FIncludesPaths : TSGStringList;
	FUnits : TSGStringList;
	FOpen : TSGBool;
	FDependingExtensions : TSGStringList;
	FUnsupportedTargets : TSGStringList;
		public
	property Open : TSGBool read FOpen;
		public
	procedure ZeroMemory();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	end;

function SGGetExtensionInfo(const ExtensionPath : TSGString) : TSGExtensionInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGClearFileForRegistrationExtensions(const FileForRegistrationExtensions : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRegisterDrawClass(const ClassType : TSGPaintableObjectClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetRegisteredDrawClasses() : TSGPaintableObjectContainerItemList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGExtensionsToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const BuildFiles : TSGBool = False):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGExtensionsToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const ExtensionsNames : TSGStringList):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGExtensionToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const ExtensionName : TSGString; const BuildFiles : TSGBool = False):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGExtensionAllreadyInMakefile(var Make : TSGMakefileReader; const ExtensionName : TSGString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetExtensionsList(var Make : TSGMakefileReader) : TSGStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsExtensionOpen(var Make : TSGMakefileReader;const ExtensionName : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsExtensionOpen(const ExtensionPath : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGRegisterExtension(const ExtensionInfo : TSGExtensionInfo;const FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	
	,SaGeStringUtils
	,SaGeStreamUtils
	,SaGeFileUtils
	,SaGeLog
	
	{$INCLUDE SaGeFileForRegistrationExtensions.inc}
	;
var
	ExtensionsDrawClasses : TSGPaintableObjectContainerItemList = nil;

procedure SGRegisterExtension(const ExtensionInfo : TSGExtensionInfo;const FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	MemStream : TMemoryStream = nil;
	StartSize : TSGUInt64;

procedure WriteName(const ExtensionName : TSGString);
var
	Exists : TSGBoolean = False;
begin
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SGReadLnStringFromStream(MemStream),' 	/') = ExtensionName;
if not Exists then
	SGWriteStringToStream('		// ' + ExtensionName + SGWinEoln, MemStream, False);
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
WriteName(ExtensionInfo.FName);
for S in ExtensionInfo.FUnits do
	RegisterUnit(S);
if StartSize <> MemStream.Size then
	MemStream.SaveToFile(FileRegistrationResources);
MemStream.Destroy();
end;

function SGExtensionAllreadyInMakefile(var Make : TSGMakefileReader; const ExtensionName : TSGString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	AddedExtensions : TSGString;
	ExtensionAppellative : TSGString;
	UpCasedExtensionName : TSGString;
	i : TSGMaxEnum;
begin
Result := False;
AddedExtensions := Make.GetConstant('ADDEDEXTENSIONS', SGMRIdentifierTypeDependent);
ExtensionAppellative := '';
UpCasedExtensionName := SGUpCaseString(ExtensionName);
for i := 1 to Length(AddedExtensions) do
	begin
	if (AddedExtensions[i] = '"') and (ExtensionAppellative <> '') then
		begin
		if (SGUpCaseString(ExtensionAppellative) = UpCasedExtensionName) then
			Result := True;
		ExtensionAppellative := '';
		end
	else if (AddedExtensions[i] <> '"') then
		ExtensionAppellative += AddedExtensions[i];
	end;
end;

function SGExtensionToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const ExtensionName : TSGString; const BuildFiles : TSGBool = False) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ExtensionInfo : TSGExtensionInfo;
	Str : TSGString;
begin
Result := False;
ExtensionInfo := SGGetExtensionInfo(Make.GetConstant('SGEXTENSIONSPATH') + DirectorySeparator + ExtensionName);
if (SGUpCaseString(ExtensionInfo.FName) <> SGUpCaseString(ExtensionName)) then
	TSGLog.Source(['Extension "', ExtensionName, '" have other name "', ExtensionInfo.FName, '".'])
else if (SGUpCaseString(Target) in ExtensionInfo.FUnsupportedTargets) then
	TSGLog.Source(['Extension "', ExtensionName, '" unsupporting target "', Target, '".'])
else
	begin
	Result := SGExtensionsToMakefile(Make, Target, ExtensionInfo.FDependingExtensions);
	if Result then
		if SGExtensionAllreadyInMakefile(Make, ExtensionName) then
			TSGLog.Source(['Extension "', ExtensionName, '" allready in makefile.'])
		else
			begin
			Make.SetConstant('ADDEDEXTENSIONS', Make.GetConstant('ADDEDEXTENSIONS', SGMRIdentifierTypeDependent) + '"' + ExtensionName + '"');
			for Str in ExtensionInfo.FSourcesPaths do
				Make.SetConstant(
					'BASEARGS', 
					Make.GetConstant('BASEARGS', SGMRIdentifierTypeDependent) + ' -Fu' + Make.GetConstant('SGEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + Str + ' ');
			for Str in ExtensionInfo.FIncludesPaths do
				Make.SetConstant(
					'BASEARGS', 
					Make.GetConstant('BASEARGS', SGMRIdentifierTypeDependent) + ' -Fi' + Make.GetConstant('SGEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + Str + ' ');
			Make.RecombineIdentifiers();
			SGRegisterExtension(ExtensionInfo, Make.GetConstant('SGFILEFORREGISTRATIONEXTENSIONS'));
			TSGLog.Source(['Extension "', ExtensionName, '" added.']);
			if BuildFiles and SGFileExists(Make.GetConstant('SGEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + 'BuildFiles.ini') then
				SGBuildFiles(
					Make.GetConstant('SGEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + 'BuildFiles.ini',
					Make.GetConstant('SGRESOURCESPATH'),
					Make.GetConstant('SGRESOURCESCACHEPATH'),
					Make.GetConstant('SGFILEREGISTRATIONRESOURCES'),
					ExtensionInfo.FName);
			end;
	end;
ExtensionInfo.Clear();
end;

procedure TSGExtensionInfo.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(FNames, 0);
SetLength(FSourcesPaths, 0);
SetLength(FIncludesPaths, 0);
SetLength(FUnits, 0);
SetLength(FDependingExtensions, 0);
SetLength(FUnsupportedTargets, 0);
ZeroMemory();
end;

procedure TSGExtensionInfo.ZeroMemory();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FName := '';
FNames := nil;
FSourcesPaths := nil;
FIncludesPaths := nil;
FUnits := nil;
FDependingExtensions := nil;
FOpen := False;
FUnsupportedTargets := nil;
end;

function SGGetExtensionInfo(const ExtensionPath : TSGString) : TSGExtensionInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

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
else if Param = SGUpCaseString('DependingExtensions') then
	begin
	Result.FDependingExtensions := SGStringListFromString(Value,',');
	SGStringListTrimAll(Result.FDependingExtensions, ' ');
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
Stream.LoadFromFile(ExtensionPath + DirectorySeparator + 'MakeInfo.ini');
Stream.Position := 0;
repeat
S := SGReadLnStringFromStream(Stream);
until ('[extension]' = S) or (Stream.Position = Stream.Size);
while Stream.Position <> Stream.Size do
	begin
	S := SGReadLnStringFromStream(Stream);
	P := StringWordGet(S,'=',1);
	V := StringWordGet(S,'=',2);
	ProcessParam(SGUpCaseString(P), StringTrimAll(V,' '));
	end;
end;

function SGGetExtensionsList(var Make : TSGMakefileReader) : TSGStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	SR : Dos.SearchRec;
const
	PathPrefix : TSGString = '';
begin
Result := nil;
PathPrefix := Make.GetConstant('SGEXTENSIONSPATH') + '/';
Dos.FindFirst(PathPrefix + '*', $3F, SR);
while DosError <> 18 do
	begin
	if (SR.Name <> '.') and (SR.Name <> '..') and SGExistsDirectory(PathPrefix + SR.Name) and SGIsExtensionOpen(PathPrefix + SR.Name) then
		Result += SR.Name;
	Dos.FindNext(SR);
	end;
Dos.FindClose(SR);
end;

function SGIsExtensionOpen(const ExtensionPath : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ExtensionInfo : TSGExtensionInfo;
begin
ExtensionInfo := SGGetExtensionInfo(ExtensionPath);
Result := ExtensionInfo.Open;
ExtensionInfo.Clear();
end;

function SGIsExtensionOpen(var Make : TSGMakefileReader;const ExtensionName : TSGString) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ExtensionsList : TSGStringList = nil;
begin
ExtensionsList := SGGetExtensionsList(Make);
Result := ExtensionName in ExtensionsList;
SetLength(ExtensionsList, 0);
end;

function SGExtensionsToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const ExtensionsNames : TSGStringList):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	S : TSGString;
begin
Result := True;
for S in ExtensionsNames do
	begin
	if not SGExtensionToMakefile(Make, Target, S) then
		begin
		Result := False;
		break;
		end;
	end;
end;

function SGExtensionsToMakefile(var Make : TSGMakefileReader; const Target : TSGString; const BuildFiles : TSGBool = False) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ExtensionsList : TSGStringList = nil;
	i : TSGUInt32;
begin
Result := True;
ExtensionsList := SGGetExtensionsList(Make);
if (ExtensionsList <> nil) and (Length(ExtensionsList) > 0) then
	for i := 0 to High(ExtensionsList) do
		if not SGExtensionToMakefile(Make, Target, ExtensionsList[i], BuildFiles) then
			Result := False;
SetLength(ExtensionsList, 0);
end;

function SGGetRegisteredDrawClasses() : TSGPaintableObjectContainerItemList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := ExtensionsDrawClasses;
end;

procedure SGRegisterDrawClass(const ClassType : TSGPaintableObjectClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	PaintableObjectContainerItem : TSGPaintableObjectContainerItem;
begin
PaintableObjectContainerItem.PaintableObjectClass := ClassType;
PaintableObjectContainerItem.IsDrawable := Drawable;
ExtensionsDrawClasses += PaintableObjectContainerItem;
end;

procedure SGClearFileForRegistrationExtensions(const FileForRegistrationExtensions : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TFileStream = nil;
begin
Stream := TFileStream.Create(FileForRegistrationExtensions, fmCreate);
SGWriteStringToStream('(*This is part of SaGe Engine*)'+SGWinEoln,Stream,False);
SGWriteStringToStream('//File for registration extensions. Extensions:'+SGWinEoln,Stream,False);
Stream.Destroy();
end;

initialization
begin

end;

end.
