{$INCLUDE Smooth.inc}

unit SmoothResourceManager;

interface

uses
	 SmoothBase
	,SmoothHash
	,SmoothDateTime
	
	,Dos
	,Crt
	,StrMan
	,Classes
	,SysUtils
	;

type
	TSResource = class(TSClass)
		end;
type
	TSResourceManipulatorFileExtensions = packed array of
		packed record
			RExtension : TSString;
			RLoadIsSupported : TSBoolean;
			RSaveIsSupported : TSBoolean;
			end;
type
	TSResourceManipulator = class;
	TSResourceManipulatorClass = class of TSResourceManipulator;
	TSResourceManipulator = class(TSClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FQuantityExtensions : TSLongWord;
		FArExtensions : TSResourceManipulatorFileExtensions;
			protected
		procedure AddFileExtension(const VExtension:TSString;const VLoadIsSupported, VSaveIsSupported : TSBoolean);
			public
		function LoadingIsSupported(const VExtension : TSString):TSBoolean;
		function SaveingIsSupported(const VExtension : TSString):TSBoolean;
		function LoadResource(const VFileName,VExtension : TSString):TSResource;
		function SaveResource(const VFileName,VExtension : TSString;const VResource : TSResource):TSBoolean;
		function LoadResourceFromStream(const VStream : TStream;const VExtension : TSString):TSResource;virtual;
		function SaveResourceToStream(const VStream : TStream;const VExtension : TSString;const VResource : TSResource):TSBoolean;virtual;
		end;
type
	TSResourceManager = class(TSClass)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FQuantityManipulators : TSLongWord;
		FArManipulators : packed array of TSResourceManipulator;
			public
		procedure AddManipulator(const VManipulatorClass : TSResourceManipulatorClass);
		function LoadingIsSupported(const VExtension : TSString):TSBoolean;
		function SaveingIsSupported(const VExtension : TSString):TSBoolean;
		function LoadResource(const VFileName, VExtension : TSString):TSResource;
		function SaveResource(const VFileName, VExtension : TSString; const VResource : TSResource):TSBoolean;
		function LoadResourceFromStream(const VStream : TStream; const VExtension : TSString):TSResource;
		function SaveResourceToStream(const VStream : TStream; const VExtension : TSString; const VResource : TSResource):TSBoolean;
		end;
var
	SResourceManager : TSResourceManager = nil;
type
	TSResourceFilesProcedure = procedure (const Stream:TStream);
	TSResourceFiles = class(TSClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure AddFile(const FileWay:TSString;const Proc : TSPointer);
		function LoadMemoryStreamFromFile(const Stream:TMemoryStream;const FileName:TSString):TSBoolean;
		function ExistsInFile(const Name:TSString):TSBoolean;
		function WaysEqual(w1,w2:TSString):TSBoolean;
		function FileExists(const FileName : TSString):TSBoolean;inline;
		procedure ExtractFiles(const Dir : TSString; const WithDirs : TSBoolean);
		procedure WriteFiles();
			private
		FArFiles:packed array of
			packed record
				FWay:TSString;
				FSelf:TSResourceFilesProcedure;
				end;
		end;
var
	SResourceFiles : TSResourceFiles = nil;

const
	SConvertFileToPascalUnitDefaultInc = True;

type
	TSConvertedFileInfo = object
			public
		FName : TSString;
		FPath : TSString;
		FSize : TSUInt64;
		FOutSize : TSUInt64;
		FPastMilliseconds : TSUInt64;
		FConvertationNotNeed : TSBoolean;
			public
		procedure Clear();
		procedure Print();
		procedure Hint();
		function GetString() : TSString;
		end;
	
	TSConvertedFilesInfo = object
			public
		FCount : TSUInt32;
		FSize : TSUInt64;
		FOutSize : TSUInt64;
		FPastMilliseconds : TSUInt64;
		FCountCopyedFromCache : TSUInt32;
			public
		procedure Clear();
		procedure Print();
		function GetString() : TSString;
		end;
type
	PSBuildResource = ^ TSBuildResource;
	TSBuildResource = object
			public
		FType : TSChar;
		FPath : TSString;
		FName : TSString;
			public
		procedure Free();
		end;
	
	TSBuildResources = object
			public
		FResources : packed array of TSBuildResource;
		FCacheDirectory : TSString;
		FTempDirectory : TSString;
			public
		procedure Free();
		procedure Clear();
		function Process(const FileForRegistration : TSString) : TSConvertedFilesInfo;
		procedure AddResource(const VType : TSChar);
		function LastResource():PSBuildResource;
		end;

type
	TSRMArrayType = (
		SRMArrayTypeUInt8,
		//SRMArrayTypeUInt16,
		//SRMArrayTypeUInt32,
		SRMArrayTypeUInt64);
const
	SRMArrayDefaultType = SRMArrayTypeUInt64;

function SConvertFileToPascalUnit(const FileName, UnitWay, NameUnit : TSString; const IsInc : TSBoolean = SConvertFileToPascalUnitDefaultInc; const ArrayType : TSRMArrayType = SRMArrayDefaultType) : TSConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SConvertFileToPascalUnit(const FileName, TempUnitPath, CacheUnitPath, UnitName : TSString; const IsInc : TSBoolean = SConvertFileToPascalUnitDefaultInc) : TSConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SConvertDirectoryFilesToPascalUnits(const DirName, UnitsWay, CacheUnitPath, FileRegistrationResources : TSString) : TSConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SRegisterUnit(const UnitName, FileRegistrationResources : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SClearFileRegistrationResources(const FileRegistrationResources : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SBuildFiles(const DataFile, TempUnitDir, CacheUnitDir, FileRegistrationResources : TSString; const Name : TSString = '');{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SWriteHexStringToStream(const S : TSString; const Stream : TStream);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SDestroyResources();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SInitResources();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SAddResourceFile(const FileWay:TSString;const Proc : TSPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator + (const A : TSConvertedFilesInfo; const B : TSConvertedFileInfo) : TSConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const A, B : TSConvertedFilesInfo) : TSConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothVersion
	,SmoothStreamUtils
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	,SmoothBaseUtils
	,SmoothCasesOfPrint
	,SmoothTextMultiStream
	{$INCLUDE SmoothFileRegistrationResources.inc}
	;

procedure SAddResourceFile(const FileWay:TSString;const Proc : TSPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SInitResources();
SResourceFiles.AddFile(FileWay, Proc);
end;

procedure TSConvertedFileInfo.Hint();
begin
Print();
SLog.Source(GetString());
end;

function TSConvertedFileInfo.GetString() : TSString;
begin
Result += 
	'Converted' + '"' + SFileName(FName) + '.' + SDownCaseString(SFileExtension(FName)) + '"' +
	':in ' + SMemorySizeToString(FSize, 'EN') + ';out ' + SMemorySizeToString(FOutSize, 'EN') + ';time ' +
	StringTrimAll(SMillisecondsToStringTime(FPastMilliseconds, 'ENG'), ' ') + ';cache ' + 
	Iff(FConvertationNotNeed, 'True', 'False') + '.';
end;

procedure TSConvertedFileInfo.Print();
begin
with TSTextMultiStream.Create([SCaseLog, SCasePrint]) do
	begin
	Write('Converted');
	TextColor(14);
	Write(['"',SFileName(FName) + '.' + SDownCaseString(SFileExtension(FName)), '"']);
	TextColor(7);
	Write(':in ');
	TextColor(10);
	Write(SMemorySizeToString(FSize, 'EN'));
	TextColor(7);
	Write(';out ');
	TextColor(12);
	Write(SMemorySizeToString(FOutSize, 'EN'));
	TextColor(7);
	Write(';time ');
	TextColor(11);
	Write(StringTrimAll(SMillisecondsToStringTime(FPastMilliseconds, 'ENG'), ' '));
	TextColor(7);
	Write(';cache ');
	TextColor(13);
	Write(Iff(FConvertationNotNeed, 'True', 'False'));
	TextColor(7);
	WriteLn('.');
	
	Destroy();
	end;
end;

operator + (const A, B : TSConvertedFilesInfo) : TSConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := A;
Result.FCount += B.FCount;
Result.FSize += B.FSize;
Result.FOutSize += B.FOutSize;
Result.FPastMilliseconds += B.FPastMilliseconds;
Result.FCountCopyedFromCache += B.FCountCopyedFromCache;
end;

operator + (const A : TSConvertedFilesInfo; const B : TSConvertedFileInfo) : TSConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := A;
Result.FCount += 1;
Result.FSize += B.FSize;
Result.FOutSize += B.FOutSize;
Result.FPastMilliseconds += B.FPastMilliseconds;
Result.FCountCopyedFromCache += Byte(B.FConvertationNotNeed);
end;

procedure TSConvertedFileInfo.Clear();
begin
FSize := 0;
FOutSize := 0;
FPastMilliseconds := 0;
FName := '';
FPath := '';
FConvertationNotNeed := False;
end;


procedure TSConvertedFilesInfo.Clear();
begin
FCount := 0;
FSize := 0;
FOutSize := 0;
FPastMilliseconds := 0;
FCountCopyedFromCache := 0;
end;

function SConvertFileToPascalUnit(const FileName, TempUnitPath, CacheUnitPath, UnitName : TSString; const IsInc : TSBoolean = SConvertFileToPascalUnitDefaultInc) : TSConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

procedure FileCopy(const Source, Destination : TSString);
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
	Postfix : TSString;
begin
Result := SConvertFileToPascalUnit(FileName, CacheUnitPath, UnitName, IsInc);
Postfix := DirectorySeparator + UnitName + '.pas';
FileCopy(CacheUnitPath + Postfix, TempUnitPath + Postfix);
end;

function SGetBuildResourcesFromFile(const FileName : TSString) : TSBuildResources;

function GetHeader(const S : TSString):TSString;
var
	i : TSUInt32;
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
	S, H, ParamName, Param : TSString;

begin
Result.Free();
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FileName);
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	S := SReadLnStringFromStream(Stream);
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

procedure TSBuildResource.Free();
begin
FType := ' ';
FPath := '';
FName := '';
end;

procedure TSBuildResources.Free();
begin
FResources := nil;
FCacheDirectory := '';
FTempDirectory := '';
end;

procedure TSBuildResources.Clear();
begin
SetLength(FResources, 0);
Free();
end;

procedure TSBuildResources.AddResource(const VType : TSChar);
begin
if FResources = nil then
	SetLength(FResources, 1)
else
	SetLength(FResources, Length(FResources) + 1);
FResources[High(FResources)].Free();
FResources[High(FResources)].FType := VType;
end;

function TSBuildResources.LastResource():PSBuildResource;
begin
Result := nil;
if FResources <> nil then
	if Length(FResources) > 0 then
		Result := @FResources[High(FResources)];
end;

function TSConvertedFilesInfo.GetString() : TSString;
begin
Result := 
	'Converted files:count ' +
	SStr(FCount) +
	';cached ' +
	SStr(FCountCopyedFromCache) +
	';in size ' +
	SMemorySizeToString(FSize,'EN') +
	';out size ' +
	SMemorySizeToString(FOutSize,'EN') +
	';time ' +
	StringTrimAll(SMillisecondsToStringTime(FPastMilliseconds,'ENG'), ' ') +
	'.';
end;

procedure TSConvertedFilesInfo.Print();
begin
with TSTextMultiStream.Create([SCaseLog, SCasePrint]) do
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
	Write(SMemorySizeToString(FSize,'EN'));
	TextColor(7);
	Write(';out size ');
	TextColor(12);
	Write(SMemorySizeToString(FOutSize,'EN'));
	TextColor(7);
	Write(';time ');
	TextColor(11);
	Write(StringTrimAll(SMillisecondsToStringTime(FPastMilliseconds,'ENG'),' '));
	TextColor(7);
	WriteLn('.');
	
	Destroy();
	end;
end;

function TSBuildResources.Process(const FileForRegistration : TSString) : TSConvertedFilesInfo;

procedure ProcessResource(const Resource : TSBuildResource);
begin
if Resource.FType = 'F' then
	begin
	Result += SConvertFileToPascalUnit(Resource.FPath, FTempDirectory, FCacheDirectory, Resource.FName);
	SRegisterUnit(Resource.FName, FileForRegistration);
	end
else if Resource.FType = 'D' then
	Result += SConvertDirectoryFilesToPascalUnits(Resource.FPath, FTempDirectory, FCacheDirectory, FileForRegistration);
end;

var
	i : TSUInt32;
begin
Result.Clear();
SMakeDirectory(FTempDirectory);
SMakeDirectory(FCacheDirectory);
for i := 0 to High(FResources) do
	ProcessResource(FResources[i]);
end;

procedure SBuildFiles(const DataFile, TempUnitDir, CacheUnitDir, FileRegistrationResources : TSString; const Name : TSString = '');{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Resources : TSBuildResources;
	Info : TSConvertedFilesInfo;
begin
Resources := SGetBuildResourcesFromFile(DataFile);
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
SLog.Source(['Build', Iff(Name <> '','(' + Name + ')'), ':', Info.GetString()]);
end;

function SConvertDirectoryFilesToPascalUnits(const DirName, UnitsWay, CacheUnitPath, FileRegistrationResources : TSString) : TSConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function IsBagSinbol(const Simbol : TSChar):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Simbol = WinDirectorySeparator) or (Simbol = UnixDirectorySeparator) or (Simbol = '.') or (Simbol = ' ') or (Simbol = '	');
end;

function CalcUnitName(const FileName : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
begin
Result := 'AutomaticUnit_';
for i := Length(DirName)+2 to Length(FileName) do
	if IsBagSinbol(FileName[i]) then
		Result += '_'
	else
		Result += FileName[i];
end;

procedure ProcessFile(const FileName : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	UnitName : TSString;
begin
UnitName := CalcUnitName(FileName);
if CacheUnitPath = '' then
	Result += SConvertFileToPascalUnit(FileName, UnitsWay, UnitName)
else
	Result += SConvertFileToPascalUnit(FileName, UnitsWay, CacheUnitPath, UnitName);
SRegisterUnit(UnitName, FileRegistrationResources);
end;

procedure ProcessDirectoryFiles(const VDir : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	sr:dos.searchrec;
begin
dos.findfirst(VDir + '*',$3F,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and SFileExists(VDir + sr.name) and (not SExistsDirectory(VDir + sr.name)) then
		begin
		ProcessFile(VDir + sr.name);
		end;
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

procedure ProcessDirectory(const VDir : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	sr:dos.searchrec;
begin
ProcessDirectoryFiles(VDir+DirectorySeparator);
dos.findfirst(VDir+DirectorySeparator+'*',$10,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and (SExistsDirectory(VDir+DirectorySeparator+sr.name)) then
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

procedure SClearFileRegistrationResources(const FileRegistrationResources : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream:TFileStream = nil;
begin
Stream := TFileStream.Create(FileRegistrationResources, fmCreate);
SWriteStringToStream('(*This is part of Smooth Engine*)'+DefaultEndOfLine,Stream,False);
SWriteStringToStream('//File registration resources. Files:'+DefaultEndOfLine,Stream,False);
Stream.Destroy();
end;

procedure SRegisterUnit(const UnitName, FileRegistrationResources : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	MemStream:TMemoryStream = nil;
	Exists : TSBoolean = False;
begin
MemStream:=TMemoryStream.Create();
MemStream.LoadFromFile(FileRegistrationResources);
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SReadLnStringFromStream(MemStream),' 	,') = UnitName;
if not Exists then
	begin
	SWriteStringToStream('	,' + UnitName + DefaultEndOfLine, MemStream, False);
	MemStream.SaveToFile(FileRegistrationResources);
	end;
MemStream.Destroy();
end;

procedure SWriteHexStringToStream(const S : TSString; const Stream : TStream);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ValHex(const S : TSString) : TSByte;

function ValHexChar(const C : TSChar) : TSByte;
begin
case C of
'0'..'9' : Result := SVal(C);
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
	B : TSByte;
	i : TSUInt16;
begin
for i := 1 to Length(S) div 2 do
	begin
	B := ValHex(S[(i - 1) * 2 + 1] + S[(i - 1) * 2 + 2]);
	Stream.WriteBuffer(B, 1);
	end;
end;

function SConvertFileToPascalUnit(const FileName, UnitWay, NameUnit : TSString; const IsInc : TSBoolean = SConvertFileToPascalUnitDefaultInc; const ArrayType : TSRMArrayType = SRMArrayDefaultType) : TSConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
const
	Hash_MD5_Prefix = ' MD5 : ';
	Hash_SHA256_Prefix = ' SHA256 : ';
var
	Hash_MD5    : TSString;
	Hash_SHA256 : TSString;
	OutputFileName : TSString;

procedure ReadWriteFile();
var
	Step : TSLongWord = 1048576;
var
	OutStream : TStream = nil;
	InStream  : TStream = nil;
	A: packed array of TSByte = nil;
	I, iiii, i5 : TSLongWord;

procedure OutString(const S : TSString);
begin
SWriteStringToStream(S, OutStream, False);
end;

procedure WriteProc(const ThisStep:LongWord);

function Str8Bit(const Raw : TSByte):TSString;

function CharFourBites(const Raw : TSByte) : TSString;
begin
case Raw of
0..9 : Result := SStr(Raw);
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
OutString('	A:array [1..'+SStr(ThisStep)+'] of TSUInt8 = ('+DefaultEndOfLine+'	');
II:=0;
for iii:=0 to ThisStep-1 do
	begin
	if II=10 then
		begin
		OutString(DefaultEndOfLine+'	');
		II:=0;
		end;
	OutString(SStr(A[iIi]));
	if III<>ThisStep-1 then
		OutString(', ');
	II+=1;
	end;
OutString(');'+DefaultEndOfLine);
OutString('begin'+DefaultEndOfLine);
OutString('Stream.WriteBuffer(A,'+SStr(ThisStep)+');'+DefaultEndOfLine);
OutString('end;'+DefaultEndOfLine);
end;

procedure Write64Bit();
const
	LineSize = 5;
var
	ArraySize : TSUInt64;
	ArrayLength : TSUInt64;
	OtherLength : TSUInt64;
	i, ii, iii : TSUInt32;
	j : TSUInt32;
	S : TSString;
begin
ArrayLength := ThisStep div 8;
ArraySize := ArrayLength * 8;
OtherLength := ThisStep - ArraySize;
OutString('	A : array [1..'+SStr(ArrayLength)+'] of TSUInt64 = ('+DefaultEndOfLine+'	');
i := 0;
ii := 0;
iii := 0;
while ii <> ArraySize do
	begin
	if (iii = LineSize) then
		begin
		OutString(DefaultEndOfLine+'	');
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
		OutString(DefaultEndOfLine+'	');
		iii := 0;
		end;
	end;
OutString('	);'+DefaultEndOfLine);
if OtherLength <> 0 then
	begin
	OutString('	B : TSString = ''');
	while ii <> ThisStep do
		begin
		OutString(Str8Bit(A[ii]));
		ii += 1;
		end;
	OutString(''';'+DefaultEndOfLine);
	end;
OutString('begin'+DefaultEndOfLine);
OutString('Stream.WriteBuffer(A, '+SStr(ArraySize)+');'+DefaultEndOfLine);
if OtherLength <> 0 then
	OutString('SWriteHexStringToStream(B, Stream);'+DefaultEndOfLine);
OutString('end;'+DefaultEndOfLine);
end;

begin
InStream.ReadBuffer(A[0], ThisStep);
OutString('procedure '+'LoadToStream_'+NameUnit+'_'+SStr(I)+'(const Stream:TStream);'+DefaultEndOfLine);
I+=1;
OutString('var'+DefaultEndOfLine);
case ArrayType of
SRMArrayTypeUInt8 :
	Write8Bit();
{SRMArrayTypeUInt16:
	begin
	
	end;
SRMArrayTypeUInt32:
	begin
	
	end;}
SRMArrayTypeUInt64:
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
	OutString('{$INCLUDE Smooth.inc}'+DefaultEndOfLine)
else
	OutString('{$MODE OBJFPC}'+DefaultEndOfLine);
OutString('// Engine''s path : "' + FileName + '"'+DefaultEndOfLine);
OutString('// Path : "' + OutputFileName + '"'+DefaultEndOfLine);
OutString('//' + Hash_MD5_Prefix + Hash_MD5 + DefaultEndOfLine);
OutString('//' + Hash_SHA256_Prefix+ Hash_SHA256 + DefaultEndOfLine);
OutString('unit '+NameUnit+';'+DefaultEndOfLine);
OutString('interface'+DefaultEndOfLine);
if IsInc then
	OutString('implementation'+DefaultEndOfLine);
OutString('uses'+DefaultEndOfLine);
OutString('	 Classes'+DefaultEndOfLine);
OutString('	,SmoothBase'+DefaultEndOfLine);
if IsInc then
	OutString('	,SmoothResourceManager'+DefaultEndOfLine);
OutString('	;'+DefaultEndOfLine);
if not IsInc then
	begin
	OutString('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+DefaultEndOfLine);
	OutString('implementation'+DefaultEndOfLine);
	end;
while InStream.Position<=InStream.Size-Step do
	WriteProc(Step);
if InStream.Position<>InStream.Size then
	begin
	IIii:=InStream.Size-InStream.Position;
	WriteProc(IIii);
	end;
OutString('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+DefaultEndOfLine);
OutString('begin'+DefaultEndOfLine);
for i5:=0 to i-1 do
	OutString('LoadToStream_'+NameUnit+'_'+SStr(i5)+'(Stream);'+DefaultEndOfLine);
OutString('end;'+DefaultEndOfLine);
if IsInc then
	begin
	OutString('initialization'+DefaultEndOfLine);
	OutString('begin'+DefaultEndOfLine);
	OutString('SAddResourceFile('''+FileName+''',@LoadToStream_'+NameUnit+');'+DefaultEndOfLine);
	OutString('end;'+DefaultEndOfLine);
	end;
OutString('end.'+DefaultEndOfLine);
SetLength(A,0);
InStream.Destroy();
OutStream.Destroy();
end;

procedure CalculateHash(const FileName : TSString);
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FileName);
Stream.Position := 0;
Hash_MD5 := SHash(Stream, SHashTypeMD5);
Stream.Position := 0;
Hash_SHA256 := SHash(Stream, SHashTypeSHA256);
Stream.Destroy();
end;

function CheckForEqualFileHashes(const Hash_MD5, Hash_SHA256, OutputFileName : TSString) : TSBoolean;
var
	Stream : TStream;
	i : TSUInt16;
begin
Result := False;
Stream := TFileStream.Create(OutputFileName, fmOpenRead);
for i := 1 to 3 do
	SReadLnStringFromStream(Stream);
Result := 
	(SReadLnStringFromStream(Stream) = '//' + Hash_MD5_Prefix + Hash_MD5) and 
	(SReadLnStringFromStream(Stream) = '//' + Hash_SHA256_Prefix + Hash_SHA256);
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
	DateTime1, DateTime2 : TSDateTime;
begin
Result.Clear();
DateTime1.Get();
OutputFileName := UnitWay + DirectorySeparator + NameUnit + '.pas';
CalculateHash(FileName);
if not (SFileExists(OutputFileName) and CheckForEqualFileHashes(Hash_MD5, Hash_SHA256, OutputFileName)) then
	ReadWriteFile()
else
	Result.FConvertationNotNeed := True;
DateTime2.Get();
Result.FPastMilliseconds := (DateTime2 - DateTime1).GetPastMilliseconds();
Result.FName := FileName;
Result.FPath := OutputFileName;
GetFilesSize();
end;

(*===========TSResourceFiles===========*)

procedure TSResourceFiles.WriteFiles();
var
	TotalSize : TSQuadWord = 0;
	Size : TSQuadWord = 0;
	TotalFilesCount : TSLongWord = 0;
	i : TSLongWord;
	Stream : TMemoryStream;
begin
SPrintEngineVersion();
SHint('Files:');
if FArFiles <> nil then if Length(FArFiles) > 0 then
	for i:= 0 to High(FArFiles) do
		begin
		Stream := TMemoryStream.Create();
		FArFiles[i].FSelf(Stream);
		Size := Stream.Size;
		Stream.Destroy();
		SHint('    ' + FArFiles[i].FWay + ' (' + SMemorySizeToString(Size,'EN') + ')');
		TotalFilesCount += 1;
		TotalSize += Size;
		end;
SHint('Total files: ' + SStr(TotalFilesCount) + ', total size: ' + SMemorySizeToString(TotalSize,'EN'));
end;

procedure TSResourceFiles.ExtractFiles(const Dir : TSString; const WithDirs : TSBoolean);

function ConvertFileName( const FileName : TSString):TSString;
var
	i : TSLongWord;
begin
Result := '';
for i := 1 to Length(FileName) do
	if (FileName[i] = WinDirectorySeparator) or (FileName[i] = UnixDirectorySeparator) then
		Result += '{DS}'
	else
		Result += FileName[i];
end;

var
	i : TSLongWord;
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

function TSResourceFiles.WaysEqual(w1,w2:TSString):TSBoolean;
var
	i:TSMaxEnum;
function SimbolsEqual(const s1,s2:TSChar):TSBoolean;
begin
if ((s1=UnixDirectorySeparator) or (s1=WinDirectorySeparator)) and ((s2=UnixDirectorySeparator) or (s2=WinDirectorySeparator)) then
	Result:=True
else
	Result:=s1=s2;
end;
begin
if Length(w1)=Length(w2) then
	begin
	w1:=SUpCaseString(w1);
	w2:=SUpCaseString(w2);
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

function TSResourceFiles.FileExists(const FileName : TSString):TSBoolean;inline;
begin
Result:=ExistsInFile(FileName) or SFileExists(FileName);
end;

function TSResourceFiles.ExistsInFile(const Name:TSString):TSBoolean;
var
	i:TSMaxEnum;
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

function TSResourceFiles.LoadMemoryStreamFromFile(const Stream:TMemoryStream;const FileName:TSString):TSBoolean;
var
	i : TSMaxEnum;
	CD : TSString;
begin
CD := SAplicationFileDirectory();
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
else if SFileExists(FileName) then
	begin
	Stream.LoadFromFile(FileName);
	Result:=True;
	end
else if SFileExists(CD + FileName) then
	begin
	Stream.LoadFromFile(CD + FileName);
	Result:=True;
	end;
if Result then
	Stream.Position := 0;
end;

constructor TSResourceFiles.Create();
begin
inherited;
FArFiles:=nil;
end;

destructor TSResourceFiles.Destroy();
begin
SetLength(FArFiles,0);
inherited;
end;

procedure TSResourceFiles.AddFile(const FileWay:TSString;const Proc : TSPointer);
begin
if FArFiles = nil then
	SetLength(FArFiles,1)
else
	SetLength(FArFiles,Length(FArFiles)+1);
FArFiles[High(FArFiles)].FWay:=FileWay;
FArFiles[High(FArFiles)].FSelf:=TSResourceFilesProcedure(Proc);
end;

(*===========TSResourceManipulator===========*)

destructor TSResourceManipulator.Destroy();
begin
SetLength(FArExtensions,0);
inherited;
end;

function TSResourceManipulator.LoadResourceFromStream(const VStream : TStream;const VExtension : TSString):TSResource;
begin
Result:=nil;
end;

function TSResourceManipulator.SaveResourceToStream(const VStream : TStream;const VExtension : TSString;const VResource : TSResource):TSBoolean;
begin
Result:=False;
end;

function TSResourceManipulator.SaveResource(const VFileName,VExtension : TSString;const VResource : TSResource):TSBoolean;
var
	Stream : TStream = nil;
begin
Result:=False;
Stream := TFileStream.Create(VFileName,fmCreate);
if Stream<>nil then
	begin
	Result:=SaveResourceToStream(Stream,VExtension,VResource);
	Stream.Destroy();
	if not Result then
		if SFileExists(VFileName) then
			DeleteFile(VFileName);
	end;
end;

function TSResourceManipulator.LoadResource(const VFileName,VExtension : TSString):TSResource;
var
	Stream : TStream = nil;
begin
Result:=nil;
if SFileExists(VFileName) then
	begin
	Stream := TFileStream.Create(VFileName,fmOpenRead);
	if Stream<>nil then
		begin
		Result:=LoadResourceFromStream(Stream,VExtension);
		Stream.Destroy();
		end;
	end;
end;

constructor TSResourceManipulator.Create();
begin
inherited;
FQuantityExtensions:=0;
FArExtensions :=  nil;
end;

procedure TSResourceManipulator.AddFileExtension(const VExtension:TSString;const VLoadIsSupported, VSaveIsSupported : TSBoolean);
begin
FQuantityExtensions+=1;
SetLength(FArExtensions,FQuantityExtensions);
FArExtensions[FQuantityExtensions-1].RExtension:=SUpCaseString(VExtension);
FArExtensions[FQuantityExtensions-1].RLoadIsSupported:=VLoadIsSupported;
FArExtensions[FQuantityExtensions-1].RSaveIsSupported:=VSaveIsSupported;
end;

function TSResourceManipulator.SaveingIsSupported(const VExtension : TSString):TSBoolean;
var
	Index : TSLongWord;
begin
Result:=False;
if FQuantityExtensions<>0 then
	for Index := 0 to FQuantityExtensions-1 do
		if (SUpCaseString(VExtension) = FArExtensions[Index].RExtension) and (FArExtensions[Index].RSaveIsSupported) then
			begin
			Result:=True;
			Break;
			end;
end;

function TSResourceManipulator.LoadingIsSupported(const VExtension : TSString):TSBoolean;
var
	Index : TSLongWord;
begin
Result:=False;
if FQuantityExtensions<>0 then
	for Index := 0 to FQuantityExtensions-1 do
		if (SUpCaseString(VExtension) = FArExtensions[Index].RExtension) and (FArExtensions[Index].RLoadIsSupported) then
			begin
			Result:=True;
			Break;
			end;
end;

(*===========TSResourceManager===========*)

destructor TSResourceManager.Destroy();
begin
SetLength(FArManipulators,0);
inherited;
end;

function TSResourceManager.LoadResource(const VFileName,VExtension : TSString):TSResource;
var
	Index : TSLongWord;
begin
Result:=nil;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSupported(VExtension) then
			begin
			Result:=FArManipulators[Index].LoadResource(VFileName,SUpCaseString(VExtension));
			if Result <> nil then
				Break;
			end;
end;

function TSResourceManager.SaveResource(const VFileName,VExtension : TSString;const VResource : TSResource):TSBoolean;
var
	Index : TSLongWord;
begin
Result:=False;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].SaveingIsSupported(VExtension) then
			begin
			Result:=FArManipulators[Index].SaveResource(VFileName,SUpCaseString(VExtension),VResource);
			if Result then
				Break;
			end;
end;

function TSResourceManager.LoadResourceFromStream(const VStream : TStream;const VExtension : TSString):TSResource;
var
	Index : TSLongWord;
	StreamPosition : TSQuadWord;
begin
Result:=nil;
StreamPosition := VStream.Position;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSupported(VExtension) then
			begin
			Result:=FArManipulators[Index].LoadResourceFromStream(VStream,SUpCaseString(VExtension));
			if Result <> nil then
				Break
			else
				VStream.Position := StreamPosition;
			end;
end;

function TSResourceManager.SaveResourceToStream(const VStream : TStream;const VExtension : TSString;const VResource : TSResource):TSBoolean;
var
	Index : TSLongWord;
	StreamPosition : TSQuadWord;
begin
Result:=False;
StreamPosition := VStream.Position;
if FQuantityManipulators<>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].SaveingIsSupported(SUpCaseString(VExtension)) then
			begin
			Result:=FArManipulators[Index].SaveResourceToStream(VStream,SUpCaseString(VExtension),VResource);
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

procedure TSResourceManager.AddManipulator(const VManipulatorClass : TSResourceManipulatorClass);
begin
FQuantityManipulators+=1;
SetLength(FArManipulators,FQuantityManipulators);
FArManipulators[FQuantityManipulators-1]:=VManipulatorClass.Create();
end;

function TSResourceManager.SaveingIsSupported(const VExtension : TSString):TSBoolean;
var
	Index : TSLongWord;
begin
Result:=False;
for Index := 0 to FQuantityManipulators - 1 do
	if FArManipulators[Index].SaveingIsSupported(VExtension) then
		begin
		Result:=True;
		Break;
		end;
end;

function TSResourceManager.LoadingIsSupported(const VExtension : TSString):TSBoolean;
var
	Index : TSLongWord;
begin
Result:=False;
if FQuantityManipulators <> 0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSupported(VExtension) then
			begin
			Result:=True;
			Break;
			end;
end;


constructor TSResourceManager.Create();
begin
inherited;
FArManipulators :=nil;
FQuantityManipulators:=0;
end;

procedure SInitResources(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SResourceManager = nil then
	SResourceManager := TSResourceManager.Create();
if SResourceFiles = nil then
	SResourceFiles := TSResourceFiles.Create();
end;

procedure SDestroyResources(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SResourceManager <> nil then
	begin
	SResourceManager.Destroy();
	SResourceManager := nil;
	end;
if SResourceFiles <> nil then
	begin
	SResourceFiles.Destroy();
	SResourceFiles := nil;
	end;
end;

initialization
begin
SInitResources();
end;

finalization
begin
SDestroyResources();
end;

end.
