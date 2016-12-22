{$INCLUDE Includes\SaGe.inc}
unit SaGeResourseManager;

interface

uses
	 SaGeBase
	 ,SaGeBased
	 ,Classes
	 ,Crt
	 ,SysUtils
	 ,Dos
	 ,StrMan
	 ,SaGeHash
	 ;

type
	TSGResourse=class(TSGClass)
		end;
type
	TSGResourseManipulatorExpansions = packed array of
		packed record
			RExpansion : TSGString;
			RLoadIsSupported : TSGBoolean;
			RSaveIsSupported : TSGBoolean;
			end;
type
	TSGResourseManipulator = class;
	TSGResourseManipulatorClass = class of TSGResourseManipulator;
	TSGResourseManipulator = class(TSGClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FQuantityExpansions : TSGLongWord;
		FArExpansions : TSGResourseManipulatorExpansions;
			protected
		procedure AddExpansion(const VExpansion:TSGString;const VLoadIsSupported, VSaveIsSupported : TSGBoolean);
			public
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
		function SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
		function LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;virtual;
		function SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;virtual;
		end;
type
	TSGResourseManager = class(TSGClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FQuantityManipulators : TSGLongWord;
		FArManipulators : packed array of TSGResourseManipulator;
			public
		procedure AddManipulator(const VManipulatorClass : TSGResourseManipulatorClass);
		function LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
		function LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
		function SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
		function LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;
		function SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
		end;
var
	SGResourseManager : TSGResourseManager = nil;
type
	TSGResourseFilesProcedure = procedure (const Stream:TStream);
	TSGResourseFiles = class(TSGClass)
			public
		constructor Create();
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
				FSelf:TSGResourseFilesProcedure;
				end;
		end;
var
	SGResourseFiles:TSGResourseFiles = nil;

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
		procedure Print(const Prefix : TSGString = '');
		end;
type
	PSGBuildResourse = ^ TSGBuildResourse;
	TSGBuildResourse = object
			public
		FType : TSGChar;
		FPath : TSGString;
		FName : TSGString;
			public
		procedure Free();
		end;
	
	TSGBuildResourses = object
			public
		FResourses : packed array of TSGBuildResourse;
		FCacheDirectory : TSGString;
		FTempDirectory : TSGString;
			public
		procedure Free();
		procedure Clear();
		function Process(const FileForRegistration : TSGString) : TSGConvertedFilesInfo;
		procedure AddResourse(const VType : TSGChar);
		function LastResourse():PSGBuildResourse;
		end;

function SGConvertFileToPascalUnit(const FileName, UnitWay, NameUnit : TSGString; const IsInc : TSGBoolean = SGConvertFileToPascalUnitDefaultInc) : TSGConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGConvertFileToPascalUnit(const FileName, TempUnitPath, CacheUnitPath, UnitName : TSGString; const IsInc : TSGBoolean = SGConvertFileToPascalUnitDefaultInc) : TSGConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGConvertDirectoryFilesToPascalUnits(const DirName, UnitsWay, CacheUnitPath, RegistrationFile : TSGString) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRegisterUnit(const UnitName, RegistrationFile : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGClearRegistrationFile(const RegistrationFile : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGBuildFiles(const DataFile, TempUnitDir, CacheUnitDir, RegistrationFile : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator + (const A : TSGConvertedFilesInfo; const B : TSGConvertedFileInfo) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const A, B : TSGConvertedFilesInfo) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	SaGeVersion;

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
Postfix := Slash + UnitName + '.pas';
FileCopy(CacheUnitPath + Postfix, TempUnitPath + Postfix);
end;

function SGGetBuildResoursesFromFile(const FileName : TSGString) : TSGBuildResourses;

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
				Result.AddResourse('F')
			else if H = 'directory' then
				Result.AddResourse('D')
			else
				Result.AddResourse(' ');
			end
		else
			begin
			ParamName := StringWordGet(S, '=', 1);
			Param := StringWordGet(S, '=', 2);
			if ParamName = 'Path' then
				Result.LastResourse()^.FPath := Param
			else if ParamName = 'Name' then
				Result.LastResourse()^.FName := Param;
			end;
		end;
	end;
Stream.Destroy();
end;

procedure TSGBuildResourse.Free();
begin
FType := ' ';
FPath := '';
FName := '';
end;

procedure TSGBuildResourses.Free();
begin
FResourses := nil;
FCacheDirectory := '';
FTempDirectory := '';
end;

procedure TSGBuildResourses.Clear();
begin
SetLength(FResourses, 0);
Free();
end;

procedure TSGBuildResourses.AddResourse(const VType : TSGChar);
begin
if FResourses = nil then
	SetLength(FResourses, 1)
else
	SetLength(FResourses, Length(FResourses) + 1);
FResourses[High(FResourses)].Free();
FResourses[High(FResourses)].FType := VType;
end;

function TSGBuildResourses.LastResourse():PSGBuildResourse;
begin
Result := nil;
if FResourses <> nil then
	if Length(FResourses) > 0 then
		Result := @FResourses[High(FResourses)];
end;

procedure TSGConvertedFilesInfo.Print(const Prefix : TSGString = '');
begin
SGHint(Prefix + 'Converted ' + SGStr(FCount) + ' files, ' + SGStr(FCountCopyedFromCache) + ' copyed from cache.');
SGHint(Prefix + 'Files size ' + SGGetSizeString(FSize,'EN') + ', output size ' + SGGetSizeString(FOutSize,'EN') + '.');
SGHint(Prefix + 'Past miliseconds ' + SGStr(FPastMiliseconds) + '.');
end;

function TSGBuildResourses.Process(const FileForRegistration : TSGString) : TSGConvertedFilesInfo;

procedure ProcessResourse(const Resourse : TSGBuildResourse);
begin
if Resourse.FType = 'F' then
	begin
	Result += SGConvertFileToPascalUnit(Resourse.FPath, FTempDirectory, FCacheDirectory, Resourse.FName);
	SGRegisterUnit(Resourse.FName, FileForRegistration);
	end
else if Resourse.FType = 'D' then
	Result += SGConvertDirectoryFilesToPascalUnits(Resourse.FPath, FTempDirectory, FCacheDirectory, FileForRegistration);
end;

var
	i : TSGUInt32;
begin
Result.Clear();
SGMakeDirectory(FTempDirectory);
SGMakeDirectory(FCacheDirectory);
for i := 0 to High(FResourses) do
	ProcessResourse(FResourses[i]);
end;

procedure SGBuildFiles(const DataFile, TempUnitDir, CacheUnitDir, RegistrationFile : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Resourses : TSGBuildResourses;
	Info : TSGConvertedFilesInfo;
begin
Resourses := SGGetBuildResoursesFromFile(DataFile);
if Resourses.FTempDirectory = '' then
	Resourses.FTempDirectory := TempUnitDir;
if Resourses.FCacheDirectory = '' then
	Resourses.FCacheDirectory := CacheUnitDir;
Info := Resourses.Process(RegistrationFile);
Resourses.Clear();
SGHint('Builded files:');
Info.Print('  ');
end;

function SGConvertDirectoryFilesToPascalUnits(const DirName, UnitsWay, CacheUnitPath, RegistrationFile : TSGString) : TSGConvertedFilesInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function IsBagSinbol(const Simbol : TSGChar):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Simbol = WinSlash) or (Simbol = UnixSlash) or (Simbol = '.') or (Simbol = ' ') or (Simbol = '	');
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
SGRegisterUnit(UnitName, RegistrationFile);
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
ProcessDirectoryFiles(VDir+Slash);
dos.findfirst(VDir+Slash+'*',$10,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and (SGExistsDirectory(VDir+Slash+sr.name)) then
		begin
		ProcessDirectory(VDir+Slash+sr.name);
		end;
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

begin
Result.Clear();
ProcessDirectory(DirName);
end;

procedure SGClearRegistrationFile(const RegistrationFile:TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream:TFileStream = nil;
begin
Stream := TFileStream.Create(RegistrationFile,fmCreate);
SGWriteStringToStream('(*This is part of SaGe Engine*)'+SGWinEoln,Stream,False);
SGWriteStringToStream('//Registration file. Files:'+SGWinEoln,Stream,False);
Stream.Destroy();
end;

procedure SGRegisterUnit(const UnitName, RegistrationFile:TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream:TFileStream = nil;
	MemStream:TMemoryStream = nil;
	Exists : TSGBoolean = False;
begin
MemStream:=TMemoryStream.Create();
MemStream.LoadFromFile(RegistrationFile);
MemStream.Position := 0;
while (MemStream.Position <> MemStream.Size) and (not Exists) do
	Exists := StringTrimAll(SGReadLnStringFromStream(MemStream),' 	,') = UnitName;
if not Exists then
	begin
	SGWriteStringToStream('	,' + UnitName + SGWinEoln, MemStream, False);
	MemStream.SaveToFile(RegistrationFile);
	end;
MemStream.Destroy();
end;

function SGConvertFileToPascalUnit(const FileName, UnitWay, NameUnit : TSGString; const IsInc : TSGBoolean = SGConvertFileToPascalUnitDefaultInc) : TSGConvertedFileInfo;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
const
	Hash_MD5_Prefix = ' MD5 : ';
	Hash_SHA256_Prefix = ' SHA256 : ';
var
	Hash_MD5    : TSGString;
	Hash_SHA256 : TSGString;
	OutputFileName : TSGString;

procedure ReadWriteFile();
var
	Step : TSGLongWord = 1000000;
var
	OutStream : TStream = nil;
	InStream  : TStream = nil;
	A: packed array of Byte;
	I, iiii, i5 : TSGLongWord;

procedure WriteProc(const ThisStep:LongWord);
var
	III,II:LongWord;
begin
InStream.ReadBuffer(A[0],ThisStep);
SGWriteStringToStream('procedure '+'LoadToStream_'+NameUnit+'_'+SGStr(I)+'(const Stream:TStream);'+SGWinEoln,OutStream,False);
I+=1;
SGWriteStringToStream('var'+SGWinEoln,OutStream,False);
SGWriteStringToStream('	A:array ['+'1..'+SGStr(ThisStep)+'] of byte = ('+SGWinEoln+'	',OutStream,False);
II:=0;
for iii:=0 to ThisStep-1 do
	begin
	if II=10 then
		begin
		SGWriteStringToStream(''+SGWinEoln+'	',OutStream,False);
		II:=0;
		end;
	SGWriteStringToStream(SGStr(A[iIi]),OutStream,False);
	if III<>ThisStep-1 then
		SGWriteStringToStream(', ',OutStream,False);
	II+=1;
	end;
SGWriteStringToStream(');'+SGWinEoln,OutStream,False);
SGWriteStringToStream('begin'+SGWinEoln,OutStream,False);
SGWriteStringToStream('Stream.WriteBuffer(A,'+SGStr(ThisStep)+');'+SGWinEoln,OutStream,False);
SGWriteStringToStream('end;'+SGWinEoln,OutStream,False);
end;

begin
I:=0;
SetLength(A, Step);
OutStream := TFileStream.Create(OutputFileName, fmCreate);
InStream  := TMemoryStream.Create();
(InStream as TMemoryStream).LoadFromFile(FileName);
InStream.Position := 0;
if IsInc then
	SGWriteStringToStream('{$INCLUDE SaGe.inc}'+SGWinEoln,OutStream,False)
else
	SGWriteStringToStream('{$MODE OBJFPC}'+SGWinEoln,OutStream,False);
SGWriteStringToStream('// Engine''s path : "' + FileName + '"'+SGWinEoln,OutStream,False);
SGWriteStringToStream('// Path : "' + OutputFileName + '"'+SGWinEoln,OutStream,False);
SGWriteStringToStream('//' + Hash_MD5_Prefix + Hash_MD5 + SGWinEoln, OutStream, False);
SGWriteStringToStream('//' + Hash_SHA256_Prefix+ Hash_SHA256 + SGWinEoln, OutStream, False);
SGWriteStringToStream('unit '+NameUnit+';'+SGWinEoln,OutStream,False);
SGWriteStringToStream('interface'+SGWinEoln,OutStream,False);
if IsInc then
	SGWriteStringToStream('implementation'+SGWinEoln,OutStream,False);
SGWriteStringToStream('uses'+SGWinEoln,OutStream,False);
if IsInc then
	SGWriteStringToStream('	SaGeResourseManager,'+SGWinEoln,OutStream,False);
SGWriteStringToStream('	Classes;'+SGWinEoln,OutStream,False);
if not IsInc then
	begin
	SGWriteStringToStream('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('implementation'+SGWinEoln,OutStream,False);
	end;
while InStream.Position<=InStream.Size-Step do
	WriteProc(Step);
if InStream.Position<>InStream.Size then
	begin
	IIii:=InStream.Size-InStream.Position;
	WriteProc(IIii);
	end;
SGWriteStringToStream('procedure LoadToStream_'+NameUnit+'(const Stream:TStream);'+SGWinEoln,OutStream,False);
SGWriteStringToStream('begin'+SGWinEoln,OutStream,False);
for i5:=0 to i-1 do
	SGWriteStringToStream('LoadToStream_'+NameUnit+'_'+SGStr(i5)+'(Stream);'+SGWinEoln,OutStream,False);
SGWriteStringToStream('end;'+SGWinEoln,OutStream,False);
if IsInc then
	begin
	SGWriteStringToStream('initialization'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('begin'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('SGResourseFiles.AddFile('''+FileName+''',@LoadToStream_'+NameUnit+');'+SGWinEoln,OutStream,False);
	SGWriteStringToStream('end;'+SGWinEoln,OutStream,False);
	end;
SGWriteStringToStream('end.'+SGWinEoln,OutStream,False);
SetLength(A,0);
Write('Converted');
TextColor(14);
Write('"',SGGetFileName(FileName)+'.'+SGDownCaseString(SGGetFileExpansion(FileName)),'"');
TextColor(7);
Write(':in:');
TextColor(10);
Write(SGGetSizeString(InStream.Size,'EN'));
TextColor(7);
Write(',out:');
TextColor(12);
Write(SGGetSizeString(OutStream.Size,'EN'));
TextColor(7);
WriteLn('.');
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
	MD5, SHA256 : TSGString;
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
OutputFileName := UnitWay + Slash + NameUnit + '.pas';
CalculateHash(FileName);
if not (SGFileExists(OutputFileName) and CheckForEqualFileHashes(Hash_MD5, Hash_SHA256, OutputFileName)) then
	ReadWriteFile()
else
	Result.FConvertationNotNeed := True;
DateTime2.Get();
Result.FPastMiliseconds := (DateTime2 - DateTime1).GetPastMiliSeconds();
Result.FName := SGGetFileName(FileName);
Result.FPath := OutputFileName;
GetFilesSize();
end;

(*===========TSGResourseFiles===========*)

procedure TSGResourseFiles.WriteFiles();
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

procedure TSGResourseFiles.ExtractFiles(const Dir : TSGString; const WithDirs : TSGBoolean);

function ConvertFileName( const FileName : TSGString):TSGString;
var
	i : TSGLongWord;
begin
Result := '';
for i := 1 to Length(FileName) do
	if (FileName[i] = WinSlash) or (FileName[i] = UnixSlash) then
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
		Stream.SaveToFile(Dir + Slash + ConvertFileName(FArFiles[i].FWay));
		Stream.Destroy();
		end;
	WriteLn('Total files : ',Length(FArFiles));
	end;
end;

function TSGResourseFiles.WaysEqual(w1,w2:TSGString):TSGBoolean;
var
	i:TSGMaxEnum;
function SimbolsEqual(const s1,s2:TSGChar):TSGBoolean;
begin
if ((s1=UnixSlash) or (s1=WinSlash)) and ((s2=UnixSlash) or (s2=WinSlash)) then
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

function TSGResourseFiles.FileExists(const FileName : TSGString):TSGBoolean;inline;
begin
Result:=ExistsInFile(FileName) or SGFileExists(FileName);
end;

function TSGResourseFiles.ExistsInFile(const Name:TSGString):TSGBoolean;
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

function TSGResourseFiles.LoadMemoryStreamFromFile(const Stream:TMemoryStream;const FileName:TSGString):TSGBoolean;
var
	i : TSGMaxEnum;
	CD : TSGString;
begin
CD := SGGetCurrentDirectory();
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

constructor TSGResourseFiles.Create();
begin
inherited;
FArFiles:=nil;
end;

destructor TSGResourseFiles.Destroy();
begin
SetLength(FArFiles,0);
inherited;
end;

procedure TSGResourseFiles.AddFile(const FileWay:TSGString;const Proc : TSGPointer);
begin
if FArFiles=nil then
	SetLength(FArFiles,1)
else
	SetLength(FArFiles,Length(FArFiles)+1);
FArFiles[High(FArFiles)].FWay:=FileWay;
FArFiles[High(FArFiles)].FSelf:=TSGResourseFilesProcedure(Proc);
end;

(*===========TSGResourseManipulator===========*)

destructor TSGResourseManipulator.Destroy();
begin
SetLength(FArExpansions,0);
inherited;
end;

function TSGResourseManipulator.LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;
begin
Result:=nil;
end;

function TSGResourseManipulator.SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
begin
Result:=False;
end;

function TSGResourseManipulator.SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
var
	Stream : TStream = nil;
begin
Result:=False;
Stream := TFileStream.Create(VFileName,fmCreate);
if Stream<>nil then
	begin
	Result:=SaveResourseToStream(Stream,VExpansion,VResourse);
	Stream.Destroy();
	if not Result then
		if SGFileExists(VFileName) then
			DeleteFile(VFileName);
	end;
end;

function TSGResourseManipulator.LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
var
	Stream : TStream = nil;
begin
Result:=nil;
if SGFileExists(VFileName) then
	begin
	Stream := TFileStream.Create(VFileName,fmOpenRead);
	if Stream<>nil then
		begin
		Result:=LoadResourseFromStream(Stream,VExpansion);
		Stream.Destroy();
		end;
	end;
end;

constructor TSGResourseManipulator.Create();
begin
inherited;
FQuantityExpansions:=0;
FArExpansions :=  nil;
end;

procedure TSGResourseManipulator.AddExpansion(const VExpansion:TSGString;const VLoadIsSupported, VSaveIsSupported : TSGBoolean);
begin
FQuantityExpansions+=1;
SetLength(FArExpansions,FQuantityExpansions);
FArExpansions[FQuantityExpansions-1].RExpansion:=SGUpCaseString(VExpansion);
FArExpansions[FQuantityExpansions-1].RLoadIsSupported:=VLoadIsSupported;
FArExpansions[FQuantityExpansions-1].RSaveIsSupported:=VSaveIsSupported;
end;

function TSGResourseManipulator.SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
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

function TSGResourseManipulator.LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
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

(*===========TSGResourseManager===========*)

destructor TSGResourseManager.Destroy();
begin
SetLength(FArManipulators,0);
inherited;
end;

function TSGResourseManager.LoadResourse(const VFileName,VExpansion : TSGString):TSGResourse;
var
	Index : TSGLongWord;
begin
Result:=nil;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].LoadingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].LoadResourse(VFileName,SGUpCaseString(VExpansion));
			if Result <> nil then
				Break;
			end;
end;

function TSGResourseManager.SaveResourse(const VFileName,VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
var
	Index : TSGLongWord;
begin
Result:=False;
if FQuantityManipulators <>0 then
	for Index := 0 to FQuantityManipulators - 1 do
		if FArManipulators[Index].SaveingIsSuppored(VExpansion) then
			begin
			Result:=FArManipulators[Index].SaveResourse(VFileName,SGUpCaseString(VExpansion),VResourse);
			if Result then
				Break;
			end;
end;

function TSGResourseManager.LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;
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
			Result:=FArManipulators[Index].LoadResourseFromStream(VStream,SGUpCaseString(VExpansion));
			if Result <> nil then
				Break
			else
				VStream.Position := StreamPosition;
			end;
end;

function TSGResourseManager.SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
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
			Result:=FArManipulators[Index].SaveResourseToStream(VStream,SGUpCaseString(VExpansion),VResourse);
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

procedure TSGResourseManager.AddManipulator(const VManipulatorClass : TSGResourseManipulatorClass);
begin
FQuantityManipulators+=1;
SetLength(FArManipulators,FQuantityManipulators);
FArManipulators[FQuantityManipulators-1]:=VManipulatorClass.Create();
end;

function TSGResourseManager.SaveingIsSuppored(const VExpansion : TSGString):TSGBoolean;
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

function TSGResourseManager.LoadingIsSuppored(const VExpansion : TSGString):TSGBoolean;
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


constructor TSGResourseManager.Create();
begin
inherited;
FArManipulators :=nil;
FQuantityManipulators:=0;
end;

(*=======variable realization=====*)

initialization
begin
SGResourseManager := TSGResourseManager.Create();
SGResourseFiles:=TSGResourseFiles.Create();
end;

finalization
begin
SGResourseManager.Destroy();
SGResourseFiles.Destroy();
end;

end.
