{$INCLUDE Smooth.inc}

// =====================================
// PCap Next Generation Dump File Format
// =====================================
// Utils for SmoothPCapNGFile

unit SmoothPCapNGUtils;

interface

uses
	 SmoothBase
	;

function SDescriptPCapNGFile(const FileName : TSString) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothPCapNGFile
	,SmoothInternetPacketDeterminer
	,SmoothFileUtils
	,SmoothTextFileStream
	,SmoothStringUtils
	,SmoothLog
	
	,Classes
	;

function SDescriptPCapNGFile(const FileName : TSString) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function FileSystemFileName(const FileName : TSString) : TSString;
var
	Index : TSMaxEnum;
	BadSimbols : set of TSChar = ['/', '\'];
begin
Result := FileName;
if Length(Result) > 0 then
	for Index := 1 to Length(Result) do
		if Result[Index] in BadSimbols then
			Result[Index] := '_';
end;

var
	PCapNGFile : TSPCapNGFile = nil;
	DirectoryName : TSString = '';

function DescriptNextPacket(const PacketNumber : TSUInt32) : TSBoolean;
var
	PacketStream : TStream;
	TextFile : TSTextFileStream;
begin
PacketStream := PCapNGFile.FindNextPacketData();
Result := PacketStream <> nil;
if not Result then
	exit;
TextFile := TSTextFileStream.Create(DirectoryName + DirectorySeparator + SStr(PacketNumber) + '.ini');
SWritePacketInfo(
	TextFile,
	PacketStream,
	False);
TextFile.Destroy();
PacketStream.Destroy();
end;

begin
Result := 0;
PCapNGFile := TSPCapNGFile.Create();
PCapNGFile.FileName := FileName;
DirectoryName := SFreeDirectoryName('Description of the ' + FileSystemFileName(FileName) + ' file', '');
//SHint(DirectoryName);
SMakeDirectory(DirectoryName);
if PCapNGFile.CreateInput() then
	begin
	while DescriptNextPacket(Result + 1) do
		Result += 1;
	end;
PCapNGFile.Destroy();
end;

end.
