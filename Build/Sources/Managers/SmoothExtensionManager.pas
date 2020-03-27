{$INCLUDE Smooth.inc}

unit SmoothExtensionManager;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothResourceManager
	,SmoothPaintableObjectContainer
	,SmoothMakefileReader
	,SmoothContextClasses
	
	,Classes
	,Dos
	,StrMan
	;

type
	TSExtensionInfo = object
		public
	FName : TSString;
	FNames : TSStringList;
	FSourcesPaths : TSStringList;
	FIncludesPaths : TSStringList;
	FUnits : TSStringList;
	FOpen : TSBool;
	FDependingExtensions : TSStringList;
	FUnsupportedTargets : TSStringList;
		public
	property Open : TSBool read FOpen;
		public
	procedure ZeroMemory();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	end;

function SGetExtensionInfo(const ExtensionPath : TSString) : TSExtensionInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SClearFileForRegistrationExtensions(const FileForRegistrationExtensions : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SRegisterDrawClass(const ClassType : TSPaintableObjectClass; const Drawable : TSBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGetRegisteredDrawClasses() : TSPaintableObjectContainerItemList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SExtensionsToMakefile(var Make : TSMakefileReader; const Target : TSString; const BuildFiles : TSBool = False):TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SExtensionsToMakefile(var Make : TSMakefileReader; const Target : TSString; const ExtensionsNames : TSStringList):TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SExtensionToMakefile(var Make : TSMakefileReader; const Target : TSString; const ExtensionName : TSString; const BuildFiles : TSBool = False):TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SExtensionAllreadyInMakefile(var Make : TSMakefileReader; const ExtensionName : TSString) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGetExtensionsList(var Make : TSMakefileReader) : TSStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SIsExtensionOpen(var Make : TSMakefileReader;const ExtensionName : TSString) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SIsExtensionOpen(const ExtensionPath : TSString) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SRegisterExtension(const ExtensionInfo : TSExtensionInfo;const FileRegistrationResources : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	
	,SmoothStringUtils
	,SmoothStreamUtils
	,SmoothFileUtils
	,SmoothLog
	
	{$INCLUDE SmoothFileForRegistrationExtensions.inc}
	;
var
	ExtensionsDrawClasses : TSPaintableObjectContainerItemList = nil;

procedure SRegisterExtension(const ExtensionInfo : TSExtensionInfo;const FileRegistrationResources : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	MemStream : TMemoryStream = nil;
	StartSize : TSUInt64;

procedure WriteName(const ExtensionName : TSString);
var
	Exists : TSBoolean = False;
begin
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SReadLnStringFromStream(MemStream),' 	/') = ExtensionName;
if not Exists then
	SWriteStringToStream('		// ' + ExtensionName + SWinEoln, MemStream, False);
end;

procedure RegisterUnit(const UnitName : TSString);
var
	Exists : TSBoolean = False;
begin
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SReadLnStringFromStream(MemStream),' 	,') = UnitName;
if not Exists then
	SWriteStringToStream('	,' + UnitName + SWinEoln, MemStream, False);
end;

var
	S : TSString;
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

function SExtensionAllreadyInMakefile(var Make : TSMakefileReader; const ExtensionName : TSString) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	AddedExtensions : TSString;
	ExtensionAppellative : TSString;
	UpCasedExtensionName : TSString;
	i : TSMaxEnum;
begin
Result := False;
AddedExtensions := Make.GetConstant('ADDEDEXTENSIONS', SMRIdentifierTypeDependent);
ExtensionAppellative := '';
UpCasedExtensionName := SUpCaseString(ExtensionName);
for i := 1 to Length(AddedExtensions) do
	begin
	if (AddedExtensions[i] = '"') and (ExtensionAppellative <> '') then
		begin
		if (SUpCaseString(ExtensionAppellative) = UpCasedExtensionName) then
			Result := True;
		ExtensionAppellative := '';
		end
	else if (AddedExtensions[i] <> '"') then
		ExtensionAppellative += AddedExtensions[i];
	end;
end;

function SExtensionToMakefile(var Make : TSMakefileReader; const Target : TSString; const ExtensionName : TSString; const BuildFiles : TSBool = False) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ExtensionInfo : TSExtensionInfo;
	Str : TSString;
begin
Result := False;
ExtensionInfo := SGetExtensionInfo(Make.GetConstant('SEXTENSIONSPATH') + DirectorySeparator + ExtensionName);
if (SUpCaseString(ExtensionInfo.FName) <> SUpCaseString(ExtensionName)) then
	TSLog.Source(['Extension "', ExtensionName, '" have other name "', ExtensionInfo.FName, '".'])
else if (SUpCaseString(Target) in ExtensionInfo.FUnsupportedTargets) then
	TSLog.Source(['Extension "', ExtensionName, '" unsupporting target "', Target, '".'])
else
	begin
	Result := SExtensionsToMakefile(Make, Target, ExtensionInfo.FDependingExtensions);
	if Result then
		if SExtensionAllreadyInMakefile(Make, ExtensionName) then
			TSLog.Source(['Extension "', ExtensionName, '" allready in makefile.'])
		else
			begin
			Make.SetConstant('ADDEDEXTENSIONS', Make.GetConstant('ADDEDEXTENSIONS', SMRIdentifierTypeDependent) + '"' + ExtensionName + '"');
			for Str in ExtensionInfo.FSourcesPaths do
				Make.SetConstant(
					'BASEARGS', 
					Make.GetConstant('BASEARGS', SMRIdentifierTypeDependent) + ' -Fu' + Make.GetConstant('SEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + Str + ' ');
			for Str in ExtensionInfo.FIncludesPaths do
				Make.SetConstant(
					'BASEARGS', 
					Make.GetConstant('BASEARGS', SMRIdentifierTypeDependent) + ' -Fi' + Make.GetConstant('SEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + Str + ' ');
			Make.RecombineIdentifiers();
			SRegisterExtension(ExtensionInfo, Make.GetConstant('SFILEFORREGISTRATIONEXTENSIONS'));
			TSLog.Source(['Extension "', ExtensionName, '" added.']);
			if BuildFiles and SFileExists(Make.GetConstant('SEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + 'BuildFiles.ini') then
				SBuildFiles(
					Make.GetConstant('SEXTENSIONSPATH') + DirectorySeparator + ExtensionInfo.FName + DirectorySeparator + 'BuildFiles.ini',
					Make.GetConstant('SRESOURCESPATH'),
					Make.GetConstant('SRESOURCESCACHEPATH'),
					Make.GetConstant('SFILEREGISTRATIONRESOURCES'),
					ExtensionInfo.FName);
			end;
	end;
ExtensionInfo.Clear();
end;

procedure TSExtensionInfo.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(FNames, 0);
SetLength(FSourcesPaths, 0);
SetLength(FIncludesPaths, 0);
SetLength(FUnits, 0);
SetLength(FDependingExtensions, 0);
SetLength(FUnsupportedTargets, 0);
ZeroMemory();
end;

procedure TSExtensionInfo.ZeroMemory();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function SGetExtensionInfo(const ExtensionPath : TSString) : TSExtensionInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ProcessParam(const Param, Value : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Param = 'NAMES' then
	begin
	Result.FNames := SStringListFromString(Value,',');
	SStringListTrimAll(Result.FNames, ' ');
	Result.FName := Result.FNames[0];
	end
else if Param = 'SOURCESPATHS' then
	begin
	Result.FSourcesPaths := SStringListFromString(Value,',');
	SStringListTrimAll(Result.FSourcesPaths, ' ');
	end
else if Param = 'INCLUDESPATHS' then
	begin
	Result.FIncludesPaths := SStringListFromString(Value,',');
	SStringListTrimAll(Result.FIncludesPaths, ' ');
	end
else if Param = 'UNITS' then
	begin
	Result.FUnits := SStringListFromString(Value,',');
	SStringListTrimAll(Result.FUnits, ' ');
	end
else if Param = SUpCaseString('DependingExtensions') then
	begin
	Result.FDependingExtensions := SStringListFromString(Value,',');
	SStringListTrimAll(Result.FDependingExtensions, ' ');
	end
else if Param = 'OPEN' then
	begin
	Result.FOpen := SUpCaseString(Value) = 'TRUE';
	end
else if Param = 'UNSUPPORTEDTARGETS' then
	begin
	Result.FUnsupportedTargets := SStringListFromString(Value,',');
	SStringListTrimAll(Result.FUnsupportedTargets, ' ');
	Result.FUnsupportedTargets := SUpCasedStringList(Result.FUnsupportedTargets, True);
	end
else
	begin
	SHint(['Unknown param name "',Param,'"']);
	end;
end;

var
	Stream : TMemoryStream = nil;
	S, P, V : TSString;
begin
Result.ZeroMemory();
Stream := TMemoryStream.Create();
Stream.LoadFromFile(ExtensionPath + DirectorySeparator + 'MakeInfo.ini');
Stream.Position := 0;
repeat
S := SReadLnStringFromStream(Stream);
until ('[extension]' = S) or (Stream.Position = Stream.Size);
while Stream.Position <> Stream.Size do
	begin
	S := SReadLnStringFromStream(Stream);
	P := StringWordGet(S,'=',1);
	V := StringWordGet(S,'=',2);
	ProcessParam(SUpCaseString(P), StringTrimAll(V,' '));
	end;
end;

function SGetExtensionsList(var Make : TSMakefileReader) : TSStringList; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	SR : Dos.SearchRec;
const
	PathPrefix : TSString = '';
begin
Result := nil;
PathPrefix := Make.GetConstant('SEXTENSIONSPATH') + '/';
Dos.FindFirst(PathPrefix + '*', $3F, SR);
while DosError <> 18 do
	begin
	if (SR.Name <> '.') and (SR.Name <> '..') and SExistsDirectory(PathPrefix + SR.Name) and SIsExtensionOpen(PathPrefix + SR.Name) then
		Result += SR.Name;
	Dos.FindNext(SR);
	end;
Dos.FindClose(SR);
end;

function SIsExtensionOpen(const ExtensionPath : TSString) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ExtensionInfo : TSExtensionInfo;
begin
ExtensionInfo := SGetExtensionInfo(ExtensionPath);
Result := ExtensionInfo.Open;
ExtensionInfo.Clear();
end;

function SIsExtensionOpen(var Make : TSMakefileReader;const ExtensionName : TSString) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ExtensionsList : TSStringList = nil;
begin
ExtensionsList := SGetExtensionsList(Make);
Result := ExtensionName in ExtensionsList;
SetLength(ExtensionsList, 0);
end;

function SExtensionsToMakefile(var Make : TSMakefileReader; const Target : TSString; const ExtensionsNames : TSStringList):TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	S : TSString;
begin
Result := True;
for S in ExtensionsNames do
	begin
	if not SExtensionToMakefile(Make, Target, S) then
		begin
		Result := False;
		break;
		end;
	end;
end;

function SExtensionsToMakefile(var Make : TSMakefileReader; const Target : TSString; const BuildFiles : TSBool = False) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ExtensionsList : TSStringList = nil;
	i : TSUInt32;
begin
Result := True;
ExtensionsList := SGetExtensionsList(Make);
if (ExtensionsList <> nil) and (Length(ExtensionsList) > 0) then
	for i := 0 to High(ExtensionsList) do
		if not SExtensionToMakefile(Make, Target, ExtensionsList[i], BuildFiles) then
			Result := False;
SetLength(ExtensionsList, 0);
end;

function SGetRegisteredDrawClasses() : TSPaintableObjectContainerItemList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := ExtensionsDrawClasses;
end;

procedure SRegisterDrawClass(const ClassType : TSPaintableObjectClass; const Drawable : TSBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	PaintableObjectContainerItem : TSPaintableObjectContainerItem;
begin
PaintableObjectContainerItem.PaintableObjectClass := ClassType;
PaintableObjectContainerItem.IsDrawable := Drawable;
ExtensionsDrawClasses += PaintableObjectContainerItem;
end;

procedure SClearFileForRegistrationExtensions(const FileForRegistrationExtensions : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TFileStream = nil;
begin
Stream := TFileStream.Create(FileForRegistrationExtensions, fmCreate);
SWriteStringToStream('(*This is part of Smooth Engine*)'+SWinEoln,Stream,False);
SWriteStringToStream('//File for registration extensions. Extensions:'+SWinEoln,Stream,False);
Stream.Destroy();
end;

initialization
begin

end;

end.
