{$INCLUDE Includes\SaGe.inc}

unit SaGeHash;

interface

uses
	 SaGeBase
	,SaGeDateTime
	,SaGeStringUtils
	
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
	;

type
	TSGHashType = (
		SGHashTypeNone,
		SGHashTypeMD5,
		SGHashTypeMD4,
		SGHashTypeMD2,
		SGHashTypeSHA1,
		SGHashTypeSHA256,
		SGHashTypeSHA512
		);
	TSGHashParam = set of TSGHashType;

const
	SGDefaultHashParam : TSGHashParam = [];
	SGFullHashParam : TSGHashParam = [SGHashTypeMD5, SGHashTypeMD4, SGHashTypeMD2, SGHashTypeSHA1, SGHashTypeSHA256, SGHashTypeSHA512];

type
	TSGHashTableChunck = object
			public
		FName : TSGString;
		FType : TSGHashType;
		end;
	TSGHashTable = packed array[0..5] of TSGHashTableChunck;

function SGHash(var Buffer; const BufferSize : TSGUInt64; const HashType : TSGHashType = SGHashTypeMD5) : TSGString; overload;
function SGHash(const Stream : TStream; const HashType : TSGHashType = SGHashTypeMD5) : TSGString; overload;
function SGHash(const FileName : TSGString; const HashType : TSGHashType = SGHashTypeMD5) : TSGString; overload;
function SGHash_DCP(var Buffer; const BufferSize : TSGUInt64; const HashClass : TDCP_hashclass) : TSGString;

function SGHashMD2(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashMD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashMD4(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashSHA1(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashSHA256(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashSHA512(var Buffer; const BufferSize : TSGUInt64) : TSGString;

function SGHashMD2_MD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashMD5_MD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashMD4_MD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashSHA1_SHA1(var Buffer; const BufferSize : TSGUInt64) : TSGString;

function SGHashMD5_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashMD4_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashSHA1_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashSHA256_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
function SGHashSHA512_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;

function SGHashStrDiget(const Diget; const DigetLength : TSGUInt32) : TSGString;
function SGHashStrRawByte(const Raw : TSGByte):TSGString;
procedure SGConsoleHashFile(const FileName : TSGString; const HashParam : TSGHashParam = []);
procedure SGConsoleHashDirectory(const DirectoryName : TSGString; const HashParam : TSGHashParam = []);
procedure SGConsoleCheckEqualsDirectoryData(const Path1, Path2 : TSGString);
procedure SGConsoleHash(const Name : TSGString; const HashParam : TSGHashParam = []);
procedure SGConsolePrintHashTypes();
function SGHashStrType(VType : TSGString):TSGHashType;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGHashStrType(const VType : TSGHashType):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeResourceManager
	,SaGeVersion
	,SaGeFileUtils
	,SaGeLog
	
	,Dos
	,Crt
	;

var
	HashTable : TSGHashTable = (
		(
			FName : 'MD2';
			FType : SGHashTypeMD2),
		(
			FName : 'MD4';
			FType : SGHashTypeMD4),
		(
			FName : 'MD5';
			FType : SGHashTypeMD5),
		(
			FName : 'SHA1';
			FType : SGHashTypeSHA1),
		(
			FName : 'SHA256';
			FType : SGHashTypeSHA256),
		(
			FName : 'SHA512';
			FType : SGHashTypeSHA512)
		);

function SGHashMD2(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashMD2_MD5(Buffer, BufferSize);
end;

function SGHashMD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashMD5_MD5(Buffer, BufferSize);
end;

function SGHashMD4(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashMD4_MD5(Buffer, BufferSize);
end;

function SGHashSHA1(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashSHA1_SHA1(Buffer, BufferSize);
end;

function SGHashMD2_MD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashStrDiget(MDBuffer(Buffer, BufferSize, MD_VERSION_2), SizeOf(TMDDigest));
end;

function SGHashMD5_MD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashStrDiget(MDBuffer(Buffer, BufferSize, MD_VERSION_5), SizeOf(TMDDigest));
end;

function SGHashMD4_MD5(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashStrDiget(MDBuffer(Buffer, BufferSize, MD_VERSION_4), SizeOf(TMDDigest));
end;

function SGHashSHA1_SHA1(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashStrDiget(SHA1Buffer(Buffer, BufferSize), SizeOf(TSHA1Digest));
end;

function SGHashMD5_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHash_DCP(Buffer, BufferSize, TDCP_md5);
end;

function SGHashMD4_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHash_DCP(Buffer, BufferSize, TDCP_md4);
end;

function SGHashSHA1_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHash_DCP(Buffer, BufferSize, TDCP_sha1);
end;

function SGHashSHA256_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHash_DCP(Buffer, BufferSize, TDCP_sha256);
end;

function SGHashSHA512_DCP(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHash_DCP(Buffer, BufferSize, TDCP_sha512);
end;

function SGHashSHA256(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashSHA256_DCP(Buffer, BufferSize);
end;

function SGHashSHA512(var Buffer; const BufferSize : TSGUInt64) : TSGString;
begin
Result := SGHashSHA512_DCP(Buffer, BufferSize);
end;

function SGHash_DCP(var Buffer; const BufferSize : TSGUInt64; const HashClass : TDCP_hashclass) : TSGString;
var
	DCP : TDCP_hash = nil;
	Diget : PByte;
begin
DCP := HashClass.Create(nil);
DCP.Init();
DCP.Update(Buffer, BufferSize);
GetMem(Diget, DCP.HashSize div 8);
DCP.Final(Diget^);
Result := SGHashStrDiget(Diget^, DCP.HashSize div 8);
FreeMem(Diget);
DCP.Free();
end;

function SGHashStrType(const VType : TSGHashType):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSGUInt16;
begin
Result := '';
for i := Low(HashTable) to High(HashTable) do
	if HashTable[i].FType = VType then
		begin
		Result := HashTable[i].FName;
		break;
		end;
end;

function SGHashStrType(VType : TSGString):TSGHashType;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSGUInt16;
begin
Result := SGHashTypeNone;
VType := SGUpCaseString(VType);
for i := Low(HashTable) to High(HashTable) do
	if HashTable[i].FName = VType then
		begin
		Result := HashTable[i].FType;
		break;
		end;
end;

procedure SGConsolePrintHashTypes();
var
	i : TSGUInt16;
begin
SGPrintEngineVersion();
SGHint('Suppored hashing:');
for i := Low(HashTable) to High(HashTable) do
	SGHint('  ' + HashTable[i].FName);
end;

procedure SGConsoleCheckEqualsDirectoryData(const Path1, Path2 : TSGString);
type
	TEDHashData = record
		FName : TSGString;
		FHash : TSGString;
		end;
	TEDHashDataList = packed array of TEDHashData;
	TEDHashFileData = record
		FName : TSGString;
		FSize : TSGUInt64;
		FHashData : TEDHashDataList;
		end;
	TEDHashFileDataList = packed array of TEDHashFileData;

function GetData(const Path : TSGString) : TEDHashFileDataList;

procedure AddData(const Stream : TStream);
var
	SS : TSGUInt16;
	i : TSGMaxEnum;
begin
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
with Result[High(Result)] do
	begin
	FName := SGReadStringFromStream(Stream, [#0]);
	Stream.ReadBuffer(FSize, SizeOf(FSize));
	Stream.ReadBuffer(SS, SizeOf(SS));
	SetLength(FHashData, SS);
	if SS > 0 then
		for i := 0 to High(FHashData) do
			with FHashData[High(FHashData)] do
				begin
				FName := SGReadStringFromStream(Stream, [#0]);
				FHash := SGReadStringFromStream(Stream, [#0]);
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
	i : TSGUInt32;
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
			FName   : TSGString;
			FIndex1, FIndex2 : TSGInt32;
			FResult : TSGByte;
			FSize   : TSGUInt64;
			FSize2  : TSGUInt64;
			end = nil;

procedure CalcResultData();

function CountEq() : TSGUInt32;
var
	i, ii : TSGUInt32;
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

function CountEx1() : TSGUInt32;
var
	i, ii, iii : TSGUInt32;
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

function CountEx2() : TSGUInt32;
var
	i, ii, iii : TSGUInt32;
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

function EqHashList(const D1, D2 : TEDHashDataList) : TSGByte;
var
	i, ii : TSGUInt32;
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
	k, i, ii, iii : TSGUInt32;
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
	i : TSGUInt32;
	CountEqual : TSGUInt32;
	CountUnknown : TSGUInt32;
	CountNonEqual : TSGUInt32;
	CountExist1 : TSGUInt32;
	CountExist2 : TSGUInt32;
	OutFIleName : TSGString;
	OutStream : TStream;

procedure WriteLnString(const S : TSGString);
begin
SGWriteStringToStream(S + SGWinEoln, OutStream, False);
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
SGHint('Count equal : ' + SGStr(CountEqual));
SGHint('Count unknown : ' + SGStr(CountUnknown));
SGHint('Count non-equal : ' + SGStr(CountNonEqual));
SGHint('Count exist in first : ' + SGStr(CountExist1));
SGHint('Count exist in second : ' + SGStr(CountExist2));
OutFileName := SGFreeFileName('Hash check results.txt');
OutStream := TFileStream.Create(OutFIleName, fmCreate);
WriteLnString('Results:');
WriteLnString('	Equal('+SGStr(CountEqual)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if Files[i].FResult = 1 then
				WriteLnString('		"' + Files[i].FName + '", ' + SGGetSizeString(Files[i].FSize, 'EN'));
WriteLnString('	Not equal('+SGStr(CountNonEqual)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FResult = 0) then
				WriteLnString('		"' + Files[i].FName + '", ' + SGGetSizeString(Files[i].FSize, 'EN') + ', ' + SGGetSizeString(Files[i].FSize2, 'EN'));
WriteLnString('	Unknown('+SGStr(CountUnknown)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FResult = 2) then
				WriteLnString('		"' + Files[i].FName + '", ' + SGGetSizeString(Files[i].FSize, 'EN'));
WriteLnString('	Exist in first('+SGStr(CountExist1)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FIndex2 = -1) then
				WriteLnString('		"' + Files[i].FName + '", ' + SGGetSizeString(Files[i].FSize, 'EN'));
WriteLnString('	Exist in second('+SGStr(CountExist2)+'):');
if Files <> nil then
	if Length(FIles) > 0 then
		for i := 0 to High(Files) do
			if (Files[i].FIndex1 = -1) then
				WriteLnString('		"' + Files[i].FName + '", ' + SGGetSizeString(Files[i].FSize, 'EN'));
OutStream.Destroy();
SGHint('Results saved "' + OutFIleName + '"');
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

procedure SGConsoleHashDirectory(const DirectoryName : TSGString; const HashParam : TSGHashParam = []);
var
	HashTypes : TSGHashParam = [];
type
	THDFile = record
		FPath : TSGString;
		FSize : TSGUInt64;
		end;
	THDFileList = packed array of THDFile;

function GetFileListFromDir(const Directory : TSGString) : THDFileList;

function FileSize(const FilePath : TSGString) : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	FS : TSGInt64;
begin
Result := nil;
Dos.FindFirst(Directory + DirectorySeparator + '*', $3F, SR);
while DosError <> 18 do
	begin
	if (SR.Name <> '.') and (SR.Name <> '..') then
		begin
		if SGExistsDirectory(Directory + DirectorySeparator + SR.Name) then
			begin
			DirFileList := GetFileListFromDir(Directory + DirectorySeparator + SR.Name);
			
			SetLength(DirFileList, 0);
			end
		else if SGFileExists(Directory + DirectorySeparator + SR.Name) then
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

procedure PutFile(const Stream : TStream; const FileName : TSGString; const FileSize : TSGUInt64);
var
	FS : TSGUInt64;
	SS : TSGUInt16;
	i : TSGMaxEnum;
begin
SGWriteStringToStream(FileName, Stream);
FS := FileSize;
Stream.WriteBuffer(FS, SizeOf(FS));
SS := 0;
for i := Low(HashTable) to High(HashTable) do
	SS += TSGByte(HashTable[i].FType in HashTypes);
Stream.WriteBuffer(SS, SizeOf(SS));
for i := Low(HashTable) to High(HashTable) do
	begin
	if HashTable[i].FType in HashTypes then
		begin
		SGWriteStringToStream(HashTable[i].FName, Stream);
		SGWriteStringToStream(SGHash(FileName, HashTable[i].FType), Stream);
		end;
	end;
end;

var
	OutStream : TStream = nil;
	FileList : THDFileList = nil;
	AllSize : TSGUInt64 = 0;
	i : TSGMaxEnum = 0;
	ResultFile : TSGString = '';
	DT1, DT2 : TSGDateTime;
begin
SGPrintEngineVersion();
if HashParam = [] then
	HashTypes := SGFullHashParam
else
	HashTypes := HashParam;
ResultFile := DirectoryName + DirectorySeparator + 'SaGeHashData.dat';
ResultFile := SGFreeFileName(ResultFile, '#');
SGHint('Finding files...');
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
	SGHint('Finded ' + SGStr(i) + ' files, ' + SGGetSizeString(AllSize, 'EN') + ' size, ' + SGMiliSecondsToStringTime((DT2 - DT1).GetPastMiliSeconds(), 'ENG') + '.');
	SGHint('Hashing...');
	DT1.Get();
	if FileList <> nil then
		if Length(FileList) > 0 then
			begin
			for i := 0 to High(FileList) do
				begin
				SGHint('Hashing "' + FileList[i].FPath + '", ' + SGGetSizeString(FileList[i].FSize, 'EN') + '...');
				PutFile(OutStream, FileList[i].FPath, FileList[i].FSize);
				end;
			SetLength(FileList, 0);
			end;
	DT2.Get();
	SGHint('Hashing done at ' + SGMiliSecondsToStringTime((DT2 - DT1).GetPastMiliSeconds(), 'ENG') + '.');
	SGHint('Results saved to "' + ResultFile + '".');
	OutStream.Destroy();
	end
else
	SGHint('Nothing to hash!');
end;

procedure SGConsoleHash(const Name : TSGString; const HashParam : TSGHashParam = []);
begin
SGPrintEngineVersion();
if SGResourceFiles.FileExists(Name) then
	SGConsoleHashFile(Name, HashParam)
else if SGExistsDirectory(Name) then
	SGConsoleHashDirectory(Name, HashParam)
else
	SGHint('Nothink to hash in path "'+Name+'"!');
end;

procedure SGConsoleHashFile(const FileName : TSGString; const HashParam : TSGHashParam = []);

procedure Hash(const Stream : TStream; const VType : TSGHashType;const SpaceCount : TSGUInt16 = 6);
const
	DefSpaceString = '  ';
var
	OutString : TSGString = '';
	i : TSGUInt16;
	dt1, dt2 : TSGDateTime;
begin
Stream.Position := 0;
OutString += DefSpaceString;
OutString += SGHashStrType(VType);
for i := Length(OutString) + 1 to 6 do
	OutString += ' ';
OutString += DefSpaceString + ': ';
dt1.Get();
OutString += SGHash(Stream, VType);
dt2.Get();
OutString += ' : ' + SGMiliSecondsToStringTime((dt2 - dt1).GetPastMiliSeconds(), 'ENG');
SGHint(OutString);
end;

var
	Stream : TMemoryStream = nil;
	HashTypes : TSGHashParam;
	i : TSGUInt16;
begin
SGPrintEngineVersion();
if HashParam = [] then
	HashTypes := SGFullHashParam
else
	HashTypes := HashParam;
SGHint('Hashing "' + FileName + '"...');
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FileName);
for i := Low(HashTable) to High(HashTable) do
	if HashTable[i].FType in HashTypes then
		Hash(Stream, HashTable[i].FType);
Stream.Destroy();
end;

function SGHashStrRawByte(const Raw : TSGByte):TSGString;

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

function SGHashStrDiget(const Diget; const DigetLength : TSGUInt32) : TSGString;
var
	i : TSGUInt32;
begin
Result := '';
for i := 0 to DigetLength - 1 do
	Result += SGHashStrRawByte(PByte(@Diget)[i]);
end;

function SGHash(var Buffer; const BufferSize : TSGUInt64; const HashType : TSGHashType = SGHashTypeMD5) : TSGString; overload;
begin
Result := '';
case HashType of
SGHashTypeMD2 : Result := SGHashMD2(Buffer, BufferSize);
SGHashTypeMD5 : Result := SGHashMD5(Buffer, BufferSize);
SGHashTypeMD4 : Result := SGHashMD4(Buffer, BufferSize);
SGHashTypeSHA1 : Result := SGHashSHA1(Buffer, BufferSize);
SGHashTypeSHA256 : Result := SGHashSHA256(Buffer, BufferSize);
SGHashTypeSHA512 : Result := SGHashSHA512(Buffer, BufferSize);
end;
end;

function SGHash(const Stream : TStream; const HashType : TSGHashType = SGHashTypeMD5) : TSGString; overload;
var
	Buffer : PByte = nil;
	StartPosition : TSGUInt64;
begin
StartPosition := Stream.Position;
GetMem(Buffer, Stream.Size - StartPosition);
Stream.ReadBuffer(Buffer^, Stream.Size - StartPosition);
Result := SGHash(Buffer^, Stream.Size - StartPosition, HashType);
FreeMem(Buffer);
end;

function SGHash(const FileName : TSGString; const HashType : TSGHashType = SGHashTypeMD5) : TSGString; overload;
var
	Stream : TFileStream = nil;
begin
Stream := TFileStream.Create(FileName, fmOpenRead);
Result := SGHash(Stream, HashType);
Stream.Destroy();
end;

initialization
begin

end;

end.
