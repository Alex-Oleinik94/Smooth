{$INCLUDE SaGe.inc}

// =====================================
// PCap Next Generation Dump File Format
// =====================================
// Utils for SaGePCapNGFile

unit SaGePCapNGUtils;

interface

uses
	 SaGeBase
	;

function SGDescriptPCapNGFile(const FileName : TSGString) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGePCapNGFile
	,SaGeInternetPacketDeterminer
	,SaGeFileUtils
	,SaGeTextFileStream
	,SaGeStringUtils
	,SaGeLog
	
	,Classes
	;

function SGDescriptPCapNGFile(const FileName : TSGString) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function FileSystemFileName(const FileName : TSGString) : TSGString;
var
	Index : TSGMaxEnum;
	BadSimbols : set of TSGChar = ['/', '\'];
begin
Result := FileName;
if Length(Result) > 0 then
	for Index := 1 to Length(Result) do
		if Result[Index] in BadSimbols then
			Result[Index] := '_';
end;

var
	PCapNGFile : TSGPCapNGFile = nil;
	DirectoryName : TSGString = '';

function DescriptNextPacket(const PacketNumber : TSGUInt32) : TSGBoolean;
var
	PacketStream : TStream;
	TextFile : TSGTextFileStream;
begin
PacketStream := PCapNGFile.FindNextPacketData();
Result := PacketStream <> nil;
if not Result then
	exit;
TextFile := TSGTextFileStream.Create(DirectoryName + DirectorySeparator + SGStr(PacketNumber) + '.ini');
SGWritePacketInfo(
	TextFile,
	PacketStream,
	False);
TextFile.Destroy();
PacketStream.Destroy();
end;

begin
Result := 0;
PCapNGFile := TSGPCapNGFile.Create();
PCapNGFile.FileName := FileName;
DirectoryName := SGFreeDirectoryName('Description of the ' + FileSystemFileName(FileName) + ' file', '');
//SGHint(DirectoryName);
SGMakeDirectory(DirectoryName);
if PCapNGFile.CreateInput() then
	begin
	while DescriptNextPacket(Result + 1) do
		Result += 1;
	end;
PCapNGFile.Destroy();
end;

end.
