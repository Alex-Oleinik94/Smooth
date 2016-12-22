{$INCLUDE Includes\SaGe.inc}

unit SaGeHash;

interface

uses
	SaGeBase
	,SaGeBased
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
		SGHashTypeMD5,
		SGHashTypeMD4,
		SGHashTypeMD2,
		SGHashTypeSHA1,
		SGHashTypeSHA256,
		SGHashTypeSHA512
		);

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
procedure SGConsoleHashFile(const FileName : TSGString);

implementation

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

procedure SGConsoleHashFile(const FileName : TSGString);
var
	Stream : TMemoryStream = nil;
begin
SGHint('Hashing "' + FileName + '"...');
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FileName);
Stream.Position := 0;
SGHint('  MD2    : ' + SGHash(Stream, SGHashTypeMD2));
Stream.Position := 0;
SGHint('  MD4    : ' + SGHash(Stream, SGHashTypeMD4));
Stream.Position := 0;
SGHint('  MD5    : ' + SGHash(Stream, SGHashTypeMD5));
Stream.Position := 0;
SGHint('  SHA1   : ' + SGHash(Stream, SGHashTypeSHA1));
Stream.Position := 0;
SGHint('  SHA256 : ' + SGHash(Stream, SGHashTypeSHA256));
Stream.Position := 0;
SGHint('  SHA512 : ' + SGHash(Stream, SGHashTypeSHA512));
Stream.Destroy();
end;

function SGHashStrRawByte(const Raw : TSGByte):TSGString;

function CharFourBites(const Raw : TSGByte) : TSGChar;
begin
case Raw of
0 : Result := '0';
1 : Result := '1';
2 : Result := '2';
3 : Result := '3';
4 : Result := '4';
5 : Result := '5';
6 : Result := '6';
7 : Result := '7';
8 : Result := '8';
9 : Result := '9';
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
