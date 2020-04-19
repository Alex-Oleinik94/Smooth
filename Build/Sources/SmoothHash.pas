{$INCLUDE Smooth.inc}

unit SmoothHash;

interface

uses
	 SmoothBase
	,SmoothDateTime
	
	,Classes
	,SysUtils
	
	// Stantart modules
	,md5
	,sha1
	
	// dcpcrypt
	,dcpcrypt
	,dcpcrypt2
	,DCPsha1
	,dcpmd5
	,dcpmd4
	,dcpsha256
	,dcpsha512
	,DCPripemd128
	,dcpripemd160
	,DCPhaval
	
	// crc
	,crc
	;

type
	TSHashType = (
		SHashTypeNone,
		SHashTypeMD5,
		SHashTypeMD4,
		SHashTypeMD2,
		SHashTypeSHA1,
		SHashTypeSHA256,
		SHashTypeSHA512,
		SHashTypeCRC32,
		SHashTypeCRC64,
		SHashTypeCRC128
		);
	TSHashParam = set of TSHashType;

const
	SHashTypeUUID = SHashTypeCRC128;
	SDefaultHashParam : TSHashParam = [];
	SFullHashParam : TSHashParam = [
		SHashTypeMD5, 
		SHashTypeMD4, 
		SHashTypeMD2, 
		SHashTypeSHA1, 
		SHashTypeSHA256, 
		SHashTypeSHA512,
		SHashTypeCRC32,
		SHashTypeCRC64,
		SHashTypeCRC128
		];

type
	TSHashTableChunck = object
			public
		FName : TSString;
		FType : TSHashType;
		end;
	TSHashTable = packed array[0..8] of TSHashTableChunck;

function SHash(var Buffer; const BufferSize : TSUInt64; const HashType : TSHashType = SHashTypeMD5) : TSString; overload;
function SHash(const Stream : TStream; const HashType : TSHashType = SHashTypeMD5) : TSString; overload;
function SHash(const FileName : TSString; const HashType : TSHashType = SHashTypeMD5) : TSString; overload;
function SHash_DCP(var Buffer; const BufferSize : TSUInt64; const HashClass : TDCP_hashclass) : TSString;

function SHashCRC32(var Buffer; const BufferSize : TSUInt64) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SHashCRC64(var Buffer; const BufferSize : TSUInt64) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SHashCRC128(var Buffer; const BufferSize : TSUInt64) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SHashMD2(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashMD5(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashMD4(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashSHA1(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashSHA256(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashSHA512(var Buffer; const BufferSize : TSUInt64) : TSString;

function SHashMD2_MD5(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashMD5_MD5(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashMD4_MD5(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashSHA1_SHA1(var Buffer; const BufferSize : TSUInt64) : TSString;

function SHashMD5_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashMD4_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashSHA1_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashSHA256_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
function SHashSHA512_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;

function SHashStrDiget(const Diget; const DigetLength : TSUInt32) : TSString;
function SHashStrRawByte(const Raw : TSByte):TSString;
procedure SConsoleHashFile(const FileName : TSString; const HashParam : TSHashParam = []);
procedure SConsoleHashDirectory(const DirectoryName : TSString; const HashParam : TSHashParam = []);
procedure SConsoleCheckEqualsDirectoryData(const Path1, Path2 : TSString);
procedure SConsoleHash(const Name : TSString; const HashParam : TSHashParam = []);
procedure SConsolePrintHashTypes();
function SHashStrType(VType : TSString):TSHashType;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SHashStrType(const VType : TSHashType):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SmoothResourceManager
	,SmoothVersion
	,SmoothStreamUtils
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	
	,Dos
	,Crt
	;

var
	HashTable : TSHashTable = (
		(
			FName : 'MD2';
			FType : SHashTypeMD2),
		(
			FName : 'MD4';
			FType : SHashTypeMD4),
		(
			FName : 'MD5';
			FType : SHashTypeMD5),
		(
			FName : 'SHA1';
			FType : SHashTypeSHA1),
		(
			FName : 'SHA256';
			FType : SHashTypeSHA256),
		(
			FName : 'SHA512';
			FType : SHashTypeSHA512),
		(
			FName : 'CRC32';
			FType : SHashTypeCRC32),
		(
			FName : 'CRC64';
			FType : SHashTypeCRC64),
		(
			FName : 'CRC128';
			FType : SHashTypeCRC128)
		);

function SHashCRC32(var Buffer; const BufferSize : TSUInt64) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SHashStrDiget(crc32(0, @Buffer, BufferSize), SizeOf(cardinal));
end;

function SHashCRC64(var Buffer; const BufferSize : TSUInt64) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SHashStrDiget(crc64(0, @Buffer, BufferSize), SizeOf(QWord));
end;

function SHashCRC128(var Buffer; const BufferSize : TSUInt64) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SHashStrDiget(crc128(0, @Buffer, BufferSize), SizeOf(u128));
end;

function SHashMD2(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashMD2_MD5(Buffer, BufferSize);
end;

function SHashMD5(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashMD5_MD5(Buffer, BufferSize);
end;

function SHashMD4(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashMD4_MD5(Buffer, BufferSize);
end;

function SHashSHA1(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashSHA1_SHA1(Buffer, BufferSize);
end;

function SHashMD2_MD5(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashStrDiget(MDBuffer(Buffer, BufferSize, MD_VERSION_2), SizeOf(TMDDigest));
end;

function SHashMD5_MD5(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashStrDiget(MDBuffer(Buffer, BufferSize, MD_VERSION_5), SizeOf(TMDDigest));
end;

function SHashMD4_MD5(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashStrDiget(MDBuffer(Buffer, BufferSize, MD_VERSION_4), SizeOf(TMDDigest));
end;

function SHashSHA1_SHA1(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashStrDiget(SHA1Buffer(Buffer, BufferSize), SizeOf(TSHA1Digest));
end;

function SHashMD5_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHash_DCP(Buffer, BufferSize, TDCP_md5);
end;

function SHashMD4_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHash_DCP(Buffer, BufferSize, TDCP_md4);
end;

function SHashSHA1_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHash_DCP(Buffer, BufferSize, TDCP_sha1);
end;

function SHashSHA256_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHash_DCP(Buffer, BufferSize, TDCP_sha256);
end;

function SHashSHA512_DCP(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHash_DCP(Buffer, BufferSize, TDCP_sha512);
end;

function SHashSHA256(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashSHA256_DCP(Buffer, BufferSize);
end;

function SHashSHA512(var Buffer; const BufferSize : TSUInt64) : TSString;
begin
Result := SHashSHA512_DCP(Buffer, BufferSize);
end;

function SHash_DCP(var Buffer; const BufferSize : TSUInt64; const HashClass : TDCP_hashclass) : TSString;
var
	DCP : TDCP_hash = nil;
	Diget : PByte;
begin
DCP := HashClass.Create(nil);
DCP.Init();
DCP.Update(Buffer, BufferSize);
GetMem(Diget, DCP.HashSize div 8);
DCP.Final(Diget^);
Result := SHashStrDiget(Diget^, DCP.HashSize div 8);
FreeMem(Diget);
DCP.Free();
end;

function SHashStrType(const VType : TSHashType):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSUInt16;
begin
Result := '';
for i := Low(HashTable) to High(HashTable) do
	if HashTable[i].FType = VType then
		begin
		Result := HashTable[i].FName;
		break;
		end;
end;

function SHashStrType(VType : TSString):TSHashType;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSUInt16;
begin
Result := SHashTypeNone;
VType := SUpCaseString(VType);
for i := Low(HashTable) to High(HashTable) do
	if HashTable[i].FName = VType then
		begin
		Result := HashTable[i].FType;
		break;
		end;
end;

procedure SConsolePrintHashTypes();
var
	i : TSUInt16;
begin
SPrintEngineVersion();
SHint('Suppored hashing:');
for i := Low(HashTable) to High(HashTable) do
	SHint('  ' + HashTable[i].FName);
end;

procedure SConsoleCheckEqualsDirectoryData(const Path1, Path2 : TSString);
type
	TEDHashData = record
		FName : TSString;
		FHash : TSString;
		end;
	TEDHashDataList = packed array of TEDHashData;
	TEDHashFileData = record
		FName : TSString;
		FSize : TSUInt64;
		FHashData : TEDHashDataList;
		end;
	TEDHashFileDataList = packed array of TEDHashFileData;

function GetData(const Path : TSString) : TEDHashFileDataList;

procedure AddData(const Stream : TStream);
var
	SS : TSUInt16;
	i : TSMaxEnum;
begin
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
with Result[High(Result)] do
	begin
	FName := SReadStringFromStream(Stream, [#0]);
	Stream.ReadBuffer(FSize, SizeOf(FSize));
	Stream.ReadBuffer(SS, SizeOf(SS));
	SetLength(FHashData, SS);
	if SS > 0 then
		for i := 0 to High(FHashData) do
			with FHashData[High(FHashData)] do
				begin
				FName := SReadStringFromStream(Stream, [#0]);
				FHash := SReadStringFromStream(Stream, [#0]);
				end;
	end;
end;

var
	Stream : TMemoryStream = nil;
begin
Result := nil;
Stream := TMemoryStream.Create();
Stream.LoadFromFile(Path);
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	AddData(Stream);
Stream.Destroy();
end;

procedure FreeData(var Data : TEDHashFileDataList);
var
	i : TSUInt32;
begin
if Data <> nil then
	if Length(Data) > 0 then
		for i := Low(Data) to High(Data) do
			SetLength(Data[i].FHashData, 0);
SetLength(Data, 0);
end;

procedure CheckData(var Data1, Data2 : TEDHashFileDataList);
var
	Files : packed array of
		packed record
			FName   : TSString;
			FIndex1, FIndex2 : TSInt32;
			FResult : TSByte;
			FSize   : TSUInt64;
			FSize2  : TSUInt64;
			end = nil;

procedure CalcResultData();

function CountEq() : TSUInt32;
var
	i, ii : TSUInt32;
begin
Result := 0;
for i := 0 to High(Data1) do
	for ii := 0 to High(Data2) do
		if Data1[i].FName = Data2[ii].FName then
			begin
			Result += 1;
			break;
			end;
end;

function CountEx1() : TSUInt32;
var
	i, ii, iii : TSUInt32;
begin
Result := 0;
for i := 0 to High(Data1) do
	begin
	iii := 0;
	for ii := 0 to High(Data2) do
		if Data1[i].FName = Data2[ii].FName then
			begin
			iii := 1;
			break;
			end;
	if iii = 0 then
		Result += 1;
	end;
end;

function CountEx2() : TSUInt32;
var
	i, ii, iii : TSUInt32;
begin
Result := 0;
for i := 0 to High(Data2) do
	begin
	iii := 0;
	for ii := 0 to High(Data1) do
		if Data2[i].FName = Data1[ii].FName then
			begin
			iii := 1;
			break;
			end;
	if iii = 0 then
		Result += 1;
	end;
end;

function EqHashList(const D1, D2 : TEDHashDataList) : TSByte;
var
	i, ii : TSUInt32;
begin
Result := 3;
for i := 0 to High(D1) do
	for ii := 0 to High(D2) do
		if (D1[i].FName = D2[ii].FName) and (D1[i].FHash <> D2[ii].FHash) then
			begin
			Result := 0;
			break;
			end
		else if (D1[i].FName = D2[ii].FName) and (D1[i].FHash = D2[ii].FHash) and (Result <> 0) then
			begin
			Result := 1;
			end;
if Result = 3 then
	Result := 2;
end;

var
	k, i, ii, iii : TSUInt32;
begin
SetLength(Files, CountEq() + CountEx1() + CountEx2());
k := 0;
for i := 0 to High(Data1) do
	for ii := 0 to High(Data2) do
		if Data1[i].FName = Data2[ii].FName then
			begin
			Files[k].FName   := Data1[i].FName;
			Files[k].FSize   := Data1[i].FSize;
			Files[k].FSize2  := Data2[i].FSize;
			Files[k].FIndex1 := i;
			Files[k].FIndex2 := ii;
			Files[k].FResult := EqHashList(Data1[i].FHashData, Data2[ii].FHashData);
			k += 1;
			end;
for i := 0 to High(Data1) do
	begin
	iii := 0;
	for ii := 0 to High(Data2) do
		if Data1[i].FName = Data2[ii].FName then
			begin
			iii := 1;
			break;
			end;
	if iii = 0 then
		begin
		Files[k].FName   := Data1[i].FName;
		Files[k].FSize   := Data1[i].FSize;
		Files[k].FSize2  := 0;
		Files[k].FIndex1 := i;
		Files[k].FIndex2 := -1;
		Files[k].FResult := 0;
		k += 1;
		end;
	end;
for i := 0 to High(Data2) do
	begin
	iii := 0;
	for ii := 0 to High(Data1) do
		if Data2[i].FName = Data1[ii].FName then
			begin
			iii := 1;
			break;
			end;
	if iii = 0 then
		begin
		Files[k].FName   := Data2[i].FName;
		Files[k].FSize   := Data2[i].FSize;
		Files[k].FSize2  := 0;
		Files[k].FIndex1 := -1;
		Files[k].FIndex2 := i;
		Files[k].FResult := 0;
		k += 1;
		end;
	end;
end;

procedure PrintResultData();
var
	i : TSUInt32;
	CountEqual : TSUInt32;
	CountUnknown : TSUInt32;
	CountNonEqual : TSUInt32;
	CountExist1 : TSUInt32;
	CountExist2 : TSUInt32;
	OutFIleName : TSString;
	OutStream : TStream;

procedure WriteLnString(const S : TSString);
begin
SWriteStringToStream(S + DefaultEndOfLine, OutStream, False);
end;

begin
CountEqual := 0;
CountUnknown := 0;
CountNonEqual := 0;
CountExist1 := 0;
CountExist2 := 0;
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			begin
			if Files[i].FResult = 2 then
				CountUnknown += 1
			else if Files[i].FResult = 1 then
				CountEqual += 1
			else if (Files[i].FIndex1 = -1) then
				CountExist2 += 1
			else if (Files[i].FIndex2 = -1) then
				CountExist1 += 1
			else
				CountNonEqual += 1;
			end;
SHint('Count equal : ' + SStr(CountEqual));
SHint('Count unknown : ' + SStr(CountUnknown));
SHint('Count non-equal : ' + SStr(CountNonEqual));
SHint('Count exist in first : ' + SStr(CountExist1));
SHint('Count exist in second : ' + SStr(CountExist2));
OutFileName := SFreeFileName('Hash check results.txt');
OutStream := TFileStream.Create(OutFIleName, fmCreate);
WriteLnString('Results:');
WriteLnString('	Equal('+SStr(CountEqual)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if Files[i].FResult = 1 then
				WriteLnString('		"' + Files[i].FName + '", ' + SMemorySizeToString(Files[i].FSize, 'EN'));
WriteLnString('	Not equal('+SStr(CountNonEqual)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FResult = 0) then
				WriteLnString('		"' + Files[i].FName + '", ' + SMemorySizeToString(Files[i].FSize, 'EN') + ', ' + SMemorySizeToString(Files[i].FSize2, 'EN'));
WriteLnString('	Unknown('+SStr(CountUnknown)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FResult = 2) then
				WriteLnString('		"' + Files[i].FName + '", ' + SMemorySizeToString(Files[i].FSize, 'EN'));
WriteLnString('	Exist in first('+SStr(CountExist1)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FIndex2 = -1) then
				WriteLnString('		"' + Files[i].FName + '", ' + SMemorySizeToString(Files[i].FSize, 'EN'));
WriteLnString('	Exist in second('+SStr(CountExist2)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FIndex1 = -1) then
				WriteLnString('		"' + Files[i].FName + '", ' + SMemorySizeToString(Files[i].FSize, 'EN'));
OutStream.Destroy();
SHint('Results saved "' + OutFIleName + '"');
end;

begin
CalcResultData();
PrintResultData();
end;

var
	Data1, Data2 : TEDHashFileDataList;
begin
Data1 := GetData(Path1);
Data2 := GetData(Path2);
CheckData(Data1, Data2);
FreeData(Data1);
FreeData(Data2);
end;

procedure SConsoleHashDirectory(const DirectoryName : TSString; const HashParam : TSHashParam = []);
var
	HashTypes : TSHashParam = [];
type
	THDFile = record
		FPath : TSString;
		FSize : TSUInt64;
		end;
	THDFileList = packed array of THDFile;

function GetFileListFromDir(const Directory : TSString) : THDFileList;

function FileSize(const FilePath : TSString) : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TFileStream = nil;
begin
Result := 0;
try
	Stream := TFileStream.Create(FilePath, fmOpenRead);
	Result := Stream.Size;
	Stream.Destroy();
except on e : EFOpenError do
	begin
	Result := -1;
	end;
end;
end;

var
	SR : Dos.SearchRec;
	DirFileList : THDFileList = nil;
	FS : TSInt64;
begin
Result := nil;
Dos.FindFirst(Directory + DirectorySeparator + '*', $3F, SR);
while DosError <> 18 do
	begin
	if (SR.Name <> '.') and (SR.Name <> '..') then
		begin
		if SExistsDirectory(Directory + DirectorySeparator + SR.Name) then
			begin
			DirFileList := GetFileListFromDir(Directory + DirectorySeparator + SR.Name);
			
			SetLength(DirFileList, 0);
			end
		else if SFileExists(Directory + DirectorySeparator + SR.Name) then
			begin
			FS := FileSize(Directory + DirectorySeparator + SR.Name);
			if FS <> -1 then
				begin
				if Result = nil then
					SetLength(Result, 1)
				else
					SetLength(Result, Length(Result) + 1);
				Result[High(Result)].FPath := Directory + DirectorySeparator + SR.Name;
				Result[High(Result)].FSize := FS;
				end;
			end;
		end;
	Dos.FindNext(SR);
	end;
Dos.FindClose(SR);
end;

procedure PutFile(const Stream : TStream; const FileName : TSString; const FileSize : TSUInt64);
var
	FS : TSUInt64;
	SS : TSUInt16;
	i : TSMaxEnum;
begin
SWriteStringToStream(FileName, Stream);
FS := FileSize;
Stream.WriteBuffer(FS, SizeOf(FS));
SS := 0;
for i := Low(HashTable) to High(HashTable) do
	SS += TSByte(HashTable[i].FType in HashTypes);
Stream.WriteBuffer(SS, SizeOf(SS));
for i := Low(HashTable) to High(HashTable) do
	begin
	if HashTable[i].FType in HashTypes then
		begin
		SWriteStringToStream(HashTable[i].FName, Stream);
		SWriteStringToStream(SHash(FileName, HashTable[i].FType), Stream);
		end;
	end;
end;

var
	OutStream : TStream = nil;
	FileList : THDFileList = nil;
	AllSize : TSUInt64 = 0;
	i : TSMaxEnum = 0;
	ResultFile : TSString = '';
	DT1, DT2 : TSDateTime;
begin
SPrintEngineVersion();
if HashParam = [] then
	HashTypes := SFullHashParam
else
	HashTypes := HashParam;
ResultFile := DirectoryName + DirectorySeparator + 'SmoothHashData.dat';
ResultFile := SFreeFileName(ResultFile, '#');
SHint('Finding files...');
DT1.Get();
FileList := GetFileListFromDir(DirectoryName);
DT2.Get();
i := 0;
if FileList <> nil then
	if Length(FileList) > 0 then
		begin
		for i := 0 to High(FileList) do
			AllSize += FileList[i].FSize;
		i := Length(FileList);
		end;
if i <> 0 then
	begin
	OutStream := TFileStream.Create(ResultFile, fmCreate);
	SHint('Finded ' + SStr(i) + ' files, ' + SMemorySizeToString(AllSize, 'EN') + ' size, ' + SMillisecondsToStringTime((DT2 - DT1).GetPastMilliseconds(), 'ENG') + '.');
	SHint('Hashing...');
	DT1.Get();
	if FileList <> nil then
		if Length(FileList) > 0 then
			begin
			for i := 0 to High(FileList) do
				begin
				SHint('Hashing "' + FileList[i].FPath + '", ' + SMemorySizeToString(FileList[i].FSize, 'EN') + '...');
				PutFile(OutStream, FileList[i].FPath, FileList[i].FSize);
				end;
			SetLength(FileList, 0);
			end;
	DT2.Get();
	SHint('Hashing done at ' + SMillisecondsToStringTime((DT2 - DT1).GetPastMilliseconds(), 'ENG') + '.');
	SHint('Results saved to "' + ResultFile + '".');
	OutStream.Destroy();
	end
else
	SHint('Nothing to hash!');
end;

procedure SConsoleHash(const Name : TSString; const HashParam : TSHashParam = []);
begin
SPrintEngineVersion();
if SResourceFiles.FileExists(Name) then
	SConsoleHashFile(Name, HashParam)
else if SExistsDirectory(Name) then
	SConsoleHashDirectory(Name, HashParam)
else
	SHint('Nothink to hash in path "'+Name+'"!');
end;

procedure SConsoleHashFile(const FileName : TSString; const HashParam : TSHashParam = []);

procedure Hash(const Stream : TStream; const VType : TSHashType;const SpaceCount : TSUInt16 = 6);
const
	DefSpaceString = '  ';
var
	OutString : TSString = '';
	i : TSUInt16;
	dt1, dt2 : TSDateTime;
begin
Stream.Position := 0;
OutString += DefSpaceString;
OutString += SHashStrType(VType);
for i := Length(OutString) + 1 to 6 do
	OutString += ' ';
OutString += DefSpaceString + ': ';
dt1.Get();
OutString += SHash(Stream, VType);
dt2.Get();
OutString += ' : ' + SMillisecondsToStringTime((dt2 - dt1).GetPastMilliseconds(), 'ENG');
SHint(OutString);
end;

var
	Stream : TMemoryStream = nil;
	HashTypes : TSHashParam;
	i : TSUInt16;
begin
SPrintEngineVersion();
if HashParam = [] then
	HashTypes := SFullHashParam
else
	HashTypes := HashParam;
SHint('Hashing "' + FileName + '"...');
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FileName);
for i := Low(HashTable) to High(HashTable) do
	if HashTable[i].FType in HashTypes then
		Hash(Stream, HashTable[i].FType);
Stream.Destroy();
end;

function SHashStrRawByte(const Raw : TSByte):TSString;

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

function SHashStrDiget(const Diget; const DigetLength : TSUInt32) : TSString;
var
	i : TSUInt32;
begin
Result := '';
for i := 0 to DigetLength - 1 do
	Result += SHashStrRawByte(PByte(@Diget)[i]);
end;

function SHash(var Buffer; const BufferSize : TSUInt64; const HashType : TSHashType = SHashTypeMD5) : TSString; overload;
begin
Result := '';
case HashType of
SHashTypeMD2 : Result := SHashMD2(Buffer, BufferSize);
SHashTypeMD5 : Result := SHashMD5(Buffer, BufferSize);
SHashTypeMD4 : Result := SHashMD4(Buffer, BufferSize);
SHashTypeSHA1 : Result := SHashSHA1(Buffer, BufferSize);
SHashTypeSHA256 : Result := SHashSHA256(Buffer, BufferSize);
SHashTypeSHA512 : Result := SHashSHA512(Buffer, BufferSize);
SHashTypeCRC32 : Result := SHashCRC32(Buffer, BufferSize);
SHashTypeCRC64 : Result := SHashCRC64(Buffer, BufferSize);
SHashTypeCRC128 : Result := SHashCRC128(Buffer, BufferSize);
end;
end;

function SHash(const Stream : TStream; const HashType : TSHashType = SHashTypeMD5) : TSString; overload;
var
	Buffer : PByte = nil;
	StartPosition : TSUInt64;
begin
StartPosition := Stream.Position;
GetMem(Buffer, Stream.Size - StartPosition);
Stream.ReadBuffer(Buffer^, Stream.Size - StartPosition);
Result := SHash(Buffer^, Stream.Size - StartPosition, HashType);
FreeMem(Buffer);
end;

function SHash(const FileName : TSString; const HashType : TSHashType = SHashTypeMD5) : TSString; overload;
var
	Stream : TFileStream = nil;
begin
Stream := TFileStream.Create(FileName, fmOpenRead);
Result := SHash(Stream, HashType);
Stream.Destroy();
end;

initialization
begin

end;

end.
