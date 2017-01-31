{$INCLUDE Includes\SaGe.inc}
unit SaGeResourceManager;

interface

uses
	 SaGeBase
	,SaGeHash
	,SaGeDateTime
	
	,Dos
	,Crt
	,StrMan
	,Classes
	,SysUtils
	;

type
	TSGResource=class(TSGClass)
		end;
type
	TSGResourceManipulatorExpansions = packed array of
		packed record
			RExpansion : TSGString;
			RLoadIsSupported : TSGBoolean;
			RSaveIsSupported : TSGBoolean;
			end;
type
	TSGResourceManipulator = class;
	TSGResourceManipulatorClass = class of TSGResourceManipulator;
	TSGResourceManipulator = class(TSGClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FQuantityExpansions : TSGLongWord;
		FArExpansions : TSGResourceManipulatorExpansions;
			protected
		procedure AddExpansion(const VExpansion:TSGString;const VLoadIsSupported, VSaveIsSupported : TSGBoolean);
			public
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function LoadResource(const VFileName,VExpansion : TSGString):TSGResource;
		function SaveResource(const VFileName,VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;
		function LoadResourceFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResource;virtual;
		function SaveResourceToStream(const VStream : TStream;const VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;virtual;
		end;
type
	TSGResourceManager = class(TSGClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FQuantityManipulators : TSGLongWord;
		FArManipulators : packed array of TSGResourceManipulator;
			public
		procedure AddManipulator(const VManipulatorClass : TSGResourceManipulatorClass);
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function LoadResource(const VFileName,VExpansion : TSGString):TSGResource;
		function SaveResource(const VFileName,VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;
		function LoadResourceFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResource;
		function SaveResourceToStream(const VStream : TStream;const VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;
		end;
var
	SGResourceManager : TSGResourceManager = nil;
type
	TSGResourceFilesProcedure = procedure (const Stream:TStream);
	TSGResourceFiles = class(TSGClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure AddFile(const FileWay:TSGString;const Proc : TSGPointer);
		function LoadMemoryStreamFromFile(const Stream:TMemoryStream;const FileName:TSGString):TSGBoolean;
		function ExistsInFile(const Name:TSGString):TSGBoolean;
		function WaysEqual(w1,w2:TSGString):TSGBoolean;
		function FileExists(const FileName : TSGString):TSGBoolean;inline;
		procedure ExtractFiles(const Dir : TSGString; const WithDirs : TSGBoolean);
		procedure WriteFiles();
			private
		FArFiles:packed array of
			packed record
				FWay:TSGString;
				FSelf:TSGResourceFilesProcedure;
				end;
		end;
var
	SGResourceFiles : TSGResourceFiles = nil;

const
	SGConvertFileToPascalUnitDefaultInc = True;

type
	TSGConvertedFileInfo = object
			public
		FName : TSGString;
		FPath : TSGString;
		FSize : TSGUInt64;
		FOutSize : TSGUInt64;
		FPastMiliseconds : TSGUInt64;
		FConvertationNotNeed : TSGBoolean;
			public
		procedure Clear();
		procedure Print();
		end;
	
	TSGConvertedFilesInfo = object
			public
		FCount : TSGUInt32;
		FSize : TSGUInt64;
		FOutSize : TSGUInt64;
		FPastMiliseconds : TSGUInt64;
		FCountCopyedFromCache : TSGUInt32;
			public
		procedure Clear();
		procedure Print();
		end;
type
	PSGBuildResource = ^ TSGBuildResource;
	TSGBuildResource = object
			public
		FType : TSGChar;
		FPath : TSGString;
		FName : TSGString;
			public
		procedure Free();
		end;
	
	TSGBuildResources = object
			public
		FResources : packed array of TSGBuildResource;
		FCacheDirectory : TSGString;
		FTempDirectory : TSGString;
			public
		procedure Free();
		procedure Clear();
		function Process(const FileForRegistration : TSGString) : TSGConvertedFilesInfo;
		procedure AddResource(const VType : TSGChar);
		function LastResource():PSGBuildResource;
		end;

type
	TSGRMArrayType = (
		SGRMArrayTypeUInt8,
		//SGRMArrayTypeUInt16,
		//SGRMArrayTypeUInt32,
		SGRMArrayTypeUInt64);
const
	SGRMArrayDefaultType = SGRMArrayTypeUInt64;

function SGConvertFileToPascalUnit(const FileName, UnitWay, NameUnit : TSGString; const IsInc : TSGBoolean = SGConvertFileToPascalUnitDefaultInc; const ArrayType : TSGRMArrayType = SGRMArrayDefaultType) : TSGConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGConvertFileToPascalUnit(const FileName, TempUnitPath, CacheUnitPath, UnitName : TSGString; const IsInc : TSGBoolean = SGConvertFileToPascalUnitDefaultInc) : TSGConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGConvertDirectoryFilesToPascalUnits(const DirName, UnitsWay, CacheUnitPath, FileRegistrationResources : TSGString) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRegisterUnit(const UnitName, FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGClearFileRegistrationResources(const FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGBuildFiles(const DataFile, TempUnitDir, CacheUnitDir, FileRegistrationResources : TSGString; const Name : TSGString = '');{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGWriteHexStringToStream(const S : TSGString; const Stream : TStream);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGDestroyResources();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGInitResources();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGAddResourceFile(const FileWay:TSGString;const Proc : TSGPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator + (const A : TSGConvertedFilesInfo; const B : TSGConvertedFileInfo) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const A, B : TSGConvertedFilesInfo) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeVersion
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	{$INCLUDE SaGeFileRegistrationResources.inc}
	;

procedure SGAddResourceFile(const FileWay:TSGString;const Proc : TSGPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGInitResources();
SGResourceFiles.AddFile(FileWay, Proc);
end;

procedure TSGConvertedFileInfo.Print();

function StrBool(const B : TSGBoolean) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if B then
	Result := 'True'
else
	Result := 'False';
end;

begin
Write('Converted');
TextColor(14);
Write('"',SGFileName(FName) + '.' + SGDownCaseString(SGFileExpansion(FName)), '"');
TextColor(7);
Write(':in ');
TextColor(10);
Write(SGGetSizeString(FSize, 'EN'));
TextColor(7);
Write(';out ');
TextColor(12);
Write(SGGetSizeString(FOutSize, 'EN'));
TextColor(7);
Write(';time ');
TextColor(11);
Write(StringTrimAll(SGMiliSecondsToStringTime(FPastMiliseconds, 'ENG'), ' '));
TextColor(7);
Write(';cache ');
TextColor(13);
Write(StrBool(FConvertationNotNeed));
TextColor(7);
WriteLn('.');
end;

operator + (const A, B : TSGConvertedFilesInfo) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := A;
Result.FCount += B.FCount;
Result.FSize += B.FSize;
Result.FOutSize += B.FOutSize;
Result.FPastMiliseconds += B.FPastMiliseconds;
Result.FCountCopyedFromCache += B.FCountCopyedFromCache;
end;

operator + (const A : TSGConvertedFilesInfo; const B : TSGConvertedFileInfo) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := A;
Result.FCount += 1;
Result.FSize += B.FSize;
Result.FOutSize += B.FOutSize;
Result.FPastMiliseconds += B.FPastMiliseconds;
Result.FCountCopyedFromCache += Byte(B.FConvertationNotNeed);
end;

procedure TSGConvertedFileInfo.Clear();
begin
FSize := 0;
FOutSize := 0;
FPastMiliseconds := 0;
FName := '';
FPath := '';
FConvertationNotNeed := False;
end;


procedure TSGConvertedFilesInfo.Clear();
begin
FCount := 0;
FSize := 0;
FOutSize := 0;
FPastMiliseconds := 0;
FCountCopyedFromCache := 0;
end;

function SGConvertFileToPascalUnit(const FileName, TempUnitPath, CacheUnitPath, UnitName : TSGString; const IsInc : TSGBoolean = SGConvertFileToPascalUnitDefaultInc) : TSGConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

procedure FileCopy(const Source, Destination : TSGString);
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
Stream.LoadFromFile(Source);
Stream.Position := 0;
Stream.SaveToFile(Destination);
Stream.Destroy();
Stream := nil;
end;

var
	Postfix : TSGString;
begin
Result := SGConvertFileToPascalUnit(FileName, CacheUnitPath, UnitName, IsInc);
Postfix := DirectorySeparator + UnitName + '.pas';
FileCopy(CacheUnitPath + Postfix, TempUnitPath + Postfix);
end;

function SGGetBuildResourcesFromFile(const FileName : TSGString) : TSGBuildResources;

function GetHeader(const S : TSGString):TSGString;
var
	i : TSGUInt32;
begin
Result := '';
if Length(S) > 2 then
	begin
	if (S[1] = '[') and (S[Length(S)] = ']') then
		for i := 2 to Length(S) - 1 do
			Result += S[i];
	end;
end;

var
	Stream : TMemoryStream = nil;
	S, H, ParamName, Param : TSGString;

begin
Result.Free();
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FileName);
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	S := SGReadLnStringFromStream(Stream);
	if S <> '' then
		begin
		H := GetHeader(S);
		if H <> '' then
			begin
			if H = 'file' then
				Result.AddResource('F')
			else if H = 'directory' then
				Result.AddResource('D')
			else
				Result.AddResource(' ');
			end
		else
			begin
			ParamName := StringWordGet(S, '=', 1);
			Param := StringWordGet(S, '=', 2);
			if ParamName = 'Path' then
				Result.LastResource()^.FPath := Param
			else if ParamName = 'Name' then
				Result.LastResource()^.FName := Param;
			end;
		end;
	end;
Stream.Destroy();
end;

procedure TSGBuildResource.Free();
begin
FType := ' ';
FPath := '';
FName := '';
end;

procedure TSGBuildResources.Free();
begin
FResources := nil;
FCacheDirectory := '';
FTempDirectory := '';
end;

procedure TSGBuildResources.Clear();
begin
SetLength(FResources, 0);
Free();
end;

procedure TSGBuildResources.AddResource(const VType : TSGChar);
begin
if FResources = nil then
	SetLength(FResources, 1)
else
	SetLength(FResources, Length(FResources) + 1);
FResources[High(FResources)].Free();
FResources[High(FResources)].FType := VType;
end;

function TSGBuildResources.LastResource():PSGBuildResource;
begin
Result := nil;
if FResources <> nil then
	if Length(FResources) > 0 then
		Result := @FResources[High(FResources)];
end;

procedure TSGConvertedFilesInfo.Print();
begin
TextColor(7);
Write('Converted files:count ');
TextColor(14);
Write(FCount);
TextColor(7);
Write(';cached ');
TextColor(13);
Write(FCountCopyedFromCache);
TextColor(7);
Write(';in size ');
TextColor(10);
Write(SGGetSizeString(FSize,'EN'));
TextColor(7);
Write(';out size ');
TextColor(12);
Write(SGGetSizeString(FOutSize,'EN'));
TextColor(7);
Write(';time ');
TextColor(11);
Write(StringTrimAll(SGMiliSecondsToStringTime(FPastMiliseconds,'ENG'),' '));
TextColor(7);
WriteLn('.');
end;

function TSGBuildResources.Process(const FileForRegistration : TSGString) : TSGConvertedFilesInfo;

procedure ProcessResource(const Resource : TSGBuildResource);
begin
if Resource.FType = 'F' then
	begin
	Result += SGConvertFileToPascalUnit(Resource.FPath, FTempDirectory, FCacheDirectory, Resource.FName);
	SGRegisterUnit(Resource.FName, FileForRegistration);
	end
else if Resource.FType = 'D' then
	Result += SGConvertDirectoryFilesToPascalUnits(Resource.FPath, FTempDirectory, FCacheDirectory, FileForRegistration);
end;

var
	i : TSGUInt32;
begin
Result.Clear();
SGMakeDirectory(FTempDirectory);
SGMakeDirectory(FCacheDirectory);
for i := 0 to High(FResources) do
	ProcessResource(FResources[i]);
end;

procedure SGBuildFiles(const DataFile, TempUnitDir, CacheUnitDir, FileRegistrationResources : TSGString; const Name : TSGString = '');{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Resources : TSGBuildResources;
	Info : TSGConvertedFilesInfo;
begin
Resources := SGGetBuildResourcesFromFile(DataFile);
if Resources.FTempDirectory = '' then
	Resources.FTempDirectory := TempUnitDir;
if Resources.FCacheDirectory = '' then
	Resources.FCacheDirectory := CacheUnitDir;
Info := Resources.Process(FileRegistrationResources);
Resources.Clear();
TextColor(15);
Write('Build');
if (Name <> '') then
	begin
	Write('(');
	TextColor(14);
	Write(Name);
	TextColor(15);
	Write(')');
	end;
Write(':');
TextColor(7);
Info.Print();
end;

function SGConvertDirectoryFilesToPascalUnits(const DirName, UnitsWay, CacheUnitPath, FileRegistrationResources : TSGString) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function IsBagSinbol(const Simbol : TSGChar):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Simbol = WinDirectorySeparator) or (Simbol = UnixDirectorySeparator) or (Simbol = '.') or (Simbol = ' ') or (Simbol = '	');
end;

function CalcUnitName(const FileName : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := 'AutomaticUnit_';
for i := Length(DirName)+2 to Length(FileName) do
	if IsBagSinbol(FileName[i]) then
		Result += '_'
	else
		Result += FileName[i];
end;

procedure ProcessFile(const FileName : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	UnitName : TSGString;
begin
UnitName := CalcUnitName(FileName);
if CacheUnitPath = '' then
	Result += SGConvertFileToPascalUnit(FileName, UnitsWay, UnitName)
else
	Result += SGConvertFileToPascalUnit(FileName, UnitsWay, CacheUnitPath, UnitName);
SGRegisterUnit(UnitName, FileRegistrationResources);
end;

procedure ProcessDirectoryFiles(const VDir : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	sr:dos.searchrec;
begin
dos.findfirst(VDir + '*',$3F,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and SGFileExists(VDir + sr.name) and (not SGExistsDirectory(VDir + sr.name)) then
		begin
		ProcessFile(VDir + sr.name);
		end;
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

procedure ProcessDirectory(const VDir : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	sr:dos.searchrec;
begin
ProcessDirectoryFiles(VDir+DirectorySeparator);
dos.findfirst(VDir+DirectorySeparator+'*',$10,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and (SGExistsDirectory(VDir+DirectorySeparator+sr.name)) then
		begin
		ProcessDirectory(VDir+DirectorySeparator+sr.name);
		end;
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

begin
Result.Clear();
ProcessDirectory(DirName);
end;

procedure SGClearFileRegistrationResources(const FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream:TFileStream = nil;
begin
Stream := TFileStream.Create(FileRegistrationResources, fmCreate);
SGWriteStringToStream('(*This is part of SaGe Engine*)'+SGWinEoln,Stream,False);
SGWriteStringToStream('//File registration resources. Files:'+SGWinEoln,Stream,False);
Stream.Destroy();
end;

procedure SGRegisterUnit(const UnitName, FileRegistrationResources : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	MemStream:TMemoryStream = nil;
	Exists : TSGBoolean = False;
begin
MemStream:=TMemoryStream.Create();
MemStream.LoadFromFile(FileRegistrationResources);
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SGReadLnStringFromStream(MemStream),' 	,') = UnitName;
if not Exists then
	begin
	SGWriteStringToStream('	,' + UnitName + SGWinEoln, MemStream, False);
	MemStream.SaveToFile(FileRegistrationResources);
	end;
MemStream.Destroy();
end;

procedure SGWriteHexStringToStream(const S : TSGString; const Stream : TStream);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ValHex(const S : TSGString) : TSGByte;

function ValHexChar(const C : TSGChar) : TSGByte;
begin
case C of
'0'..'9' : Result := SGVal(C);
'A' : Result := 10;
'B' : Result := 11;
'C' : Result := 12;
'D' : Result := 13;
'E' : Result := 14;
'F' : Result := 15;
end;
end;

begin
Result := 
	(ValHexChar(S[1]) shl 4) +
	(ValHexChar(S[2])) ; 
end;

var
	B : TSGByte;
	i : TSGUInt16;
begin
for i := 1 to Length(S) div 2 do
	begin
	B := ValHex(S[(i - 1) * 2 + 1] + S[(i - 1) * 2 + 2]);
	Stream.WriteBuffer(B, 1);
	end;
end;

function SGConvertFileToPascalUnit(const FileName, UnitWay, NameUnit : TSGString; const IsInc : TSGBoolean = SGConvertFileToPascalUnitDefaultInc; const ArrayType : TSGRMArrayType = SGRMArrayDefaultType) : TSGConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
const
	Hash_MD5_Prefix = ' MD5 : ';
	Hash_SHA256_Prefix = ' SHA256 : ';
var
	Hash_MD5    : TSGString;
	Hash_SHA256 : TSGString;
	OutputFileName : TSGString;

procedure ReadWriteFile();
var
	Step : TSGLongWord = 1048576;
var
	OutStream : TStream = nil;
	InStream  : TStream = nil;
	A: packed array of TSGByte = nil;
	I, iiii, i5 : TSGLongWord;

procedure OutString(const S : TSGString);
begin
SGWriteStringToStream(S, OutStream, False);
end;

procedure WriteProc(const ThisStep:LongWord);

function Str8Bit(const Raw : TSGByte):TSGString;

function CharFourBites(const Raw : TSGByte) : TSGString;
begin
case Raw of
0..9 : Result := SGStr(Raw);
10: Result := 'A';
11: Result := 'B';
12: Result := 'C';
13: Result := 'D';
14: Result := 'E';
15: Result := 'F';
end;
end;

begin
Result := '';
Result += CharFourBites(Raw and $F0 shr 4);
Result += CharFourBites(Raw and $0F);
end;

procedure Write8Bit();
var
	III, II:LongWord;
begin
OutString('	A:array [1..'+SGStr(ThisStep)+'] of TSGUInt8 = ('+SGWinEoln+'	');
II:=0;
for iii:=0 to ThisStep-1 do
	begin
	if II=10 then
		begin
		OutString(SGWinEoln+'	');
		II:=0;
		end;
	OutString(SGStr(A[iIi]));
	if III<>ThisStep-1 then
		OutString(', ');
	II+=1;
	end;
OutString(');'+SGWinEoln);
OutString('begin'+SGWinEoln);
OutString('Stream.WriteBuffer(A,'+SGStr(ThisStep)+');'+SGWinEoln);
OutString('end;'+SGWinEoln);
end;

procedure Write64Bit();
const
	LineSize = 5;
var
	ArraySize : TSGUInt64;
	ArrayLength : TSGUInt64;
	OtherLength : TSGUInt64;
	i, ii, iii : TSGUInt32;
	j : TSGUInt32;
	S : TSGString;
begin
ArrayLength := ThisStep div 8;
ArraySize := ArrayLength * 8;
OtherLength := ThisStep - ArraySize;
OutString('	A : array [1..'+SGStr(ArrayLength)+'] of TSGUInt64 = ('+SGWinEoln+'	');
i := 0;
ii := 0;
iii := 0;
while ii <> ArraySize do
	begin
	if (iii = LineSize) then
		begin
		OutString(SGWinEoln+'	');
		iii := 0;
		end;
	S := '$';
	for j := 0 to 7 do
		S += Str8Bit(A[ii + 7 - j]);
	OutString(S);
	iii += 1;
	i += 1;
	ii += 8;
	if i <> ArrayLength then
		OutString(', ');
	if (i = ArrayLength) then
		begin
		OutString(SGWinEoln+'	');
		iii := 0;
		end;
	end;
OutString('	);'+SGWinEoln);
if OtherLength <> 0 then
	begin
	OutString('	B : TSGString = ''');
	while ii <> ThisStep do
		begin
		OutString(Str8Bit(A[ii]));
		ii += 1;
		end;
	OutString(''';'+SGWinEoln);
	end;
OutString('begin'+SGWinEoln);
OutString('Stream.WriteBuffer(A, '+SGStr(ArraySize)+');'+SGWinEoln);
if OtherLength <> 0 then
	OutString('SGWriteHexStringToStream(B, Stream);'+SGWinEoln);
OutString('end;'+SGWinEoln);
end;

begin
InStream.ReadBuffer(A[0], ThisStep);
OutString('procedure '+'LoadToStream_'+NameUnit+'_'+SGStr(I)+'(const Stream:TStream);'+SGWinEoln);
I+=1;
OutString('var'+SGWinEoln);
case ArrayType of
SGRMArrayTypeUInt8 :
	Write8Bit();
{SGRMArrayTypeUInt16:
	begin
	
	end;
SGRMArrayTypeUInt32:
	begin
	
	end;}
SGRMArrayTypeUInt64:
	Write64Bit();
end;
end;

begin
I:=0;
SetLength(A, Step);
OutStream := TFileStream.Create(OutputFileName, fmCreate);
InStream  := TMemoryStream.Create();
(InStream as TMemoryStream).LoadFromFile(FileName);
InStream.Position := 0;
if IsInc then
	OutString('{$INCLUDE SaGe.inc}'+SGWinEoln)
else
	OutString('{$MODE OBJFPC}'+SGWinEoln);
OutString('// Engine''s path : "' + FileName + '"'+SGWinEoln);
OutString('// Path : "' + OutputFileName + '"'+SGWinEoln);
OutString('//' + Hash_MD5_Prefix + Hash_MD5 + SGWinEoln);
OutString('//' + Hash_SHA256_Prefix+ Hash_SHA256 + SGWinEoln);
OutString('unit '+NameUnit+';'+SGWinEoln);
OutString('interface'+SGWinEoln);
if IsInc then
	OutString('implementation'+SGWinEoln);
OutString('uses'+SGWinEoln);
OutString('	 Classes'+SGWinEoln);
OutString('	,SaGeBase'+SGWinEoln);
if IsInc then
	OutString('	,SaGeResourceManager'+SGWinEoln);
OutString('	;'+SGWinEoln);
if not IsInc then
	begin
	OutString('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+SGWinEoln);
	OutString('implementation'+SGWinEoln);
	end;
while InStream.Position<=InStream.Size-Step do
	WriteProc(Step);
if InStream.Position<>InStream.Size then
	begin
	IIii:=InStream.Size-InStream.Position;
	WriteProc(IIii);
	end;
OutString('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+SGWinEoln);
OutString('begin'+SGWinEoln);
for i5:=0 to i-1 do
	OutString('LoadToStream_'+NameUnit+'_'+SGStr(i5)+'(Stream);'+SGWinEoln);
OutString('end;'+SGWinEoln);
if IsInc then
	begin
	OutString('initialization'+SGWinEoln);
	OutString('begin'+SGWinEoln);
	OutString('SGAddResourceFile('''+FileName+''',@LoadToStream_'+NameUnit+');'+SGWinEoln);
	OutString('end;'+SGWinEoln);
	end;
OutString('end.'+SGWinEoln);
SetLength(A,0);
InStream.Destroy();
OutStream.Destroy();
end;

procedure CalculateHash(const FileName : TSGString);
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FileName);
Stream.Position := 0;
Hash_MD5 := SGHash(Stream, SGHashTypeMD5);
Stream.Position := 0;
Hash_SHA256 := SGHash(Stream, SGHashTypeSHA256);
Stream.Destroy();
end;

function CheckForEqualFileHashes(const Hash_MD5, Hash_SHA256, OutputFileName : TSGString) : TSGBoolean;
var
	Stream : TStream;
	i : TSGUInt16;
begin
Result := False;
Stream := TFileStream.Create(OutputFileName, fmOpenRead);
for i := 1 to 3 do
	SGReadLnStringFromStream(Stream);
Result := 
	(SGReadLnStringFromStream(Stream) = '//' + Hash_MD5_Prefix + Hash_MD5) and 
	(SGReadLnStringFromStream(Stream) = '//' + Hash_SHA256_Prefix + Hash_SHA256);
Stream.Destroy();
end;

procedure GetFilesSize();
var
	Stream : TStream;
begin
Stream := TFileStream.Create(FileName, fmOpenRead);
Result.FSize := Stream.Size;
Stream.Destroy;
Stream := TFileStream.Create(OutputFileName, fmOpenRead);
Result.FOutSize := Stream.Size;
Stream.Destroy;
end;

var
	DateTime1, DateTime2 : TSGDateTime;
begin
Result.Clear();
DateTime1.Get();
OutputFileName := UnitWay + DirectorySeparator + NameUnit + '.pas';
CalculateHash(FileName);
if not (SGFileExists(OutputFileName) and CheckForEqualFileHashes(Hash_MD5, Hash_SHA256, OutputFileName)) then
	ReadWriteFile()
else
	Result.FConvertationNotNeed := True;
DateTime2.Get();
Result.FPastMiliseconds := (DateTime2 - DateTime1).GetPastMiliSeconds();
Result.FName := FileName;
Result.FPath := OutputFileName;
GetFilesSize();
end;

(*===========TSGResourceFiles===========*)

procedure TSGResourceFiles.WriteFiles();
var
	TotalSize : TSGQuadWord = 0;
	Size : TSGQuadWord = 0;
	TotalFilesCount : TSGLongWord = 0;
	i : TSGLongWord;
	Stream : TMemoryStream;
begin
SGPrintEngineVersion();
SGHint('Files:');
if FArFiles <> nil then if Length(FArFiles) > 0 then
	for i:= 0 to High(FArFiles) do
		begin
		Stream := TMemoryStream.Create();
		FArFiles[i].FSelf(Stream);
		Size := Stream.Size;
		Stream.Destroy();
		SGHint('    ' + FArFiles[i].FWay + ' (' + SGGetSizeString(Size,'EN') + ')');
		TotalFilesCount += 1;
		TotalSize += Size;
		end;
SGHint('Total files: ' + SGStr(TotalFilesCount) + ', total size: ' + SGGetSizeString(TotalSize,'EN'));
end;

procedure TSGResourceFiles.ExtractFiles(const Dir : TSGString; const WithDirs : TSGBoolean);

function ConvertFileName( const FileName : TSGString):TSGString;
var
	i : TSGLongWord;
begin
Result := '';
for i := 1 to Length(FileName) do
	if (FileName[i] = WinDirectorySeparator) or (FileName[i] = UnixDirectorySeparator) then
		Result += '{DS}'
	else
		Result += FileName[i];
end;

var
	i : TSGLongWord;
	Stream : TMemoryStream;
begin
if WithDirs then
	begin
	// TODO
	end
else
	begin
	for i:=0 to High(FArFiles) do
		begin
		Stream := TMemoryStream.Create();
		FArFiles[i].FSelf(Stream);
		Stream.Position := 0;
		Stream.SaveToFile(Dir + DirectorySeparator + ConvertFileName(FArFiles[i].FWay));
		Stream.Destroy();
		end;
	WriteLn('Total files : ',Length(FArFiles));
	end;
end;

function TSGResourceFiles.WaysEqual(w1,w2:TSGString):TSGBoolean;
var
	i:TSGMaxEnum;
function SimbolsEqual(const s1,s2:TSGChar):TSGBoolean;
begin
if ((s1=UnixDirectorySeparator) or (s1=WinDirectorySeparator)) and ((s2=UnixDirectorySeparator) or (s2=WinDirectorySeparator)) then
	Result:=True
else
	Result:=s1=s2;
end;
begin
if Length(w1)=Length(w2) then
	begin
	w1:=SGUpCaseString(w1);
	w2:=SGUpCaseString(w2);
	Result:=True;
	for i:=1 to Length(w1) do
		if not SimbolsEqual(w1[i],w2[i]) then
			begin
			Result:=False;
			Break;
			end;
	end
else
	Result:=False;
end;

function TSGResourceFiles.FileExists(const FileName : TSGString):TSGBoolean;inline;
begin
Result:=ExistsInFile(FileName) or SGFileExists(FileName);
end;

function TSGResourceFiles.ExistsInFile(const Name:TSGString):TSGBoolean;
var
	i:TSGMaxEnum;
begin
Result:=False;
if FArFiles=nil then
	Exit;
for i:=0 to High(FArFiles) do
	begin
	if WaysEqual(FArFiles[i].FWay,Name) then
		begin
		Result:=True;
		Break;
		end;
	end;
end;

function TSGResourceFiles.LoadMemoryStreamFromFile(const Stream:TMemoryStream;const FileName:TSGString):TSGBoolean;
var
	i : TSGMaxEnum;
	CD : TSGString;
begin
CD := SGCurrentDirectory();
Result:=False;
if Stream=nil then
	Exit;
if ExistsInFile(FileName) then
	begin
	for i:=0 to High(FArFiles) do
		if WaysEqual(FileName,FArFiles[i].FWay) then
			begin
			FArFiles[i].FSelf(Stream);
			Break;
			end;
	Result:=True;
	end
else if SGFileExists(FileName) then
	begin
	Stream.LoadFromFile(FileName);
	Result:=True;
	end
else if SGFileExists(CD + FileName) then
	begin
	Stream.LoadFromFile(CD + FileName);
	Result:=True;
	end;
if Result then
	Stream.Position := 0;
end;

constructor TSGResourceFiles.Create();
begin
inherited;
FArFiles:=nil;
end;

destructor TSGResourceFiles.Destroy();
begin
SetLength(FArFiles,0);
inherited;
end;

procedure TSGResourceFiles.AddFile(const FileWay:TSGString;const Proc : TSGPointer);
begin
if FArFiles = nil then
	SetLength(FArFiles,1)
else
	SetLength(FArFiles,Length(FArFiles)+1);
FArFiles[High(FArFiles)].FWay:=FileWay;
FArFiles[High(FArFiles)].FSelf:=TSGResourceFilesProcedure(Proc);
end;

(*===========TSGResourceManipulator===========*)

destructor TSGResourceManipulator.Destroy();
begin
SetLength(FArExpansions,0);
inherited;
end;

function TSGResourceManipulator.LoadResourceFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResource;
begin
Result:=nil;
end;

function TSGResourceManipulator.SaveResourceToStream(const VStream : TStream;const VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;
begin
Result:=False;
end;

function TSGResourceManipulator.SaveResource(const VFileName,VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;
var
	Stream : TStream = nil;
begin
Result:=False;
Stream := TFileStream.Create(VFileName,fmCreate);
if Stream<>nil then
	begin
	Result:=SaveResourceToStream(Stream,VExpansion,VResource);
	Stream.Destroy();
	if not Result then
		if SGFileExists(VFileName) then
			DeleteFile(VFileName);
	end;
end;

function TSGResourceManipulator.LoadResource(const VFileName,VExpansion : TSGString):TSGResource;
var
	Stream : TStream = nil;
begin
Result:=nil;
if SGFileExists(VFileName) then
	begin
	Stream := TFileStream.Create(VFileName,fmOpenRead);
	if Stream<>nil then
		begin
		Result:=LoadResourceFromStream(Stream,VExpansion);
		Stream.Destroy();
		end;
	end;
end;

constructor TSGResourceManipulator.Create();
begin
inherited;
FQuantityExpansions:=0;
FArExpansions :=  nil;
end;

procedure TSGResourceManipulator.AddExpansion(const VExpansion:TSGString;const VLoadIsSupported, VSaveIsSupported : TSGBoolean);
begin
FQuantityExpansions+=1;
SetLength(FArExpansions,FQuantityExpansions);
FArExpansions[FQuantityExpansions-1].RExpansion:=SGUpCaseString(VExpansion);
FArExpansions[FQuantityExpansions-1].RLoadIsSupported:=VLoadIsSupported;
FArExpansions[FQuantityExpansions-1].RSaveIsSupported:=VSaveIsSupported;
end;

function TSGResourceManipulator.SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityExpansions<>0 then
	for Index := 0 to FQuantityExpansions-1 do
		if (SGUpCaseString(VExpansion) = FArExpansions[Index].RExpansion) and (FArExpansions[Index].RSaveIsSupported) then
			begin
			Result:=True;
			Break;
			end;
end;

function TSGResourceManipulator.LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityExpansions<>0 then
	for Index := 0 to FQuantityExpansions-1 do
		if (SGUpCaseString(VExpansion) = FArExpansions[Index].RExpansion) and (FArExpansions[Index].RLoadIsSupported) then
			begin
			Result:=True;
			Break;
			end;
end;

(*===========TSGResourceManager===========*)

destructor TSGResourceManager.Destroy();
begin
SetLength(FArManipulators,0);
inherited;
end;

function TSGResourceManager.LoadResource(const VFileName,VExpansion : TSGString):TSGResource;
var
	Index : TSGLongWord;
begin
Result:=nil;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].LoadResource(VFileName,SGUpCaseString(VExpansion));
			if Result <> nil then
				Break;
			end;
end;

function TSGResourceManager.SaveResource(const VFileName,VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].SaveingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].SaveResource(VFileName,SGUpCaseString(VExpansion),VResource);
			if Result then
				Break;
			end;
end;

function TSGResourceManager.LoadResourceFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResource;
var
	Index : TSGLongWord;
	StreamPosition : TSGQuadWord;
begin
Result:=nil;
StreamPosition := VStream.Position;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].LoadResourceFromStream(VStream,SGUpCaseString(VExpansion));
			if Result <> nil then
				Break
			else
				VStream.Position := StreamPosition;
			end;
end;

function TSGResourceManager.SaveResourceToStream(const VStream : TStream;const VExpansion : TSGString;const VResource : TSGResource):TSGBoolean;
var
	Index : TSGLongWord;
	StreamPosition : TSGQuadWord;
begin
Result:=False;
StreamPosition := VStream.Position;
if FQuantityManipulators<>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].SaveingIsSuppored(SGUpCaseString(VExpansion)) then
			begin
			Result:=FArManipulators[Index].SaveResourceToStream(VStream,SGUpCaseString(VExpansion),VResource);
			if Result  then
				begin
				Break;
				end
			else
				begin
				VStream.Position := StreamPosition;
				VStream.Size := StreamPosition;
				end;
			end;
end;

procedure TSGResourceManager.AddManipulator(const VManipulatorClass : TSGResourceManipulatorClass);
begin
FQuantityManipulators+=1;
SetLength(FArManipulators,FQuantityManipulators);
FArManipulators[FQuantityManipulators-1]:=VManipulatorClass.Create();
end;

function TSGResourceManager.SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
for Index := 0 to FQuantityManipulators - 1 do
	if FArManipulators[Index].SaveingIsSuppored(VExpansion) then
		begin
		Result:=True;
		Break;
		end;
end;

function TSGResourceManager.LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityManipulators <> 0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSuppored(VExpansion) then
			begin
			Result:=True;
			Break;
			end;
end;


constructor TSGResourceManager.Create();
begin
inherited;
FArManipulators :=nil;
FQuantityManipulators:=0;
end;

procedure SGInitResources(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SGResourceManager = nil then
	SGResourceManager := TSGResourceManager.Create();
if SGResourceFiles = nil then
	SGResourceFiles := TSGResourceFiles.Create();
end;

procedure SGDestroyResources(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SGResourceManager <> nil then
	begin
	SGResourceManager.Destroy();
	SGResourceManager := nil;
	end;
if SGResourceFiles <> nil then
	begin
	SGResourceFiles.Destroy();
	SGResourceFiles := nil;
	end;
end;

initialization
begin
SGInitResources();
end;

finalization
begin
SGDestroyResources();
end;

end.
