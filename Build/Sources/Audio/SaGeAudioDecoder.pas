{$INCLUDE SaGe.inc}

{$IF defined(WIN32)}
	{$DEFINE USE_OGG}
	{$ENDIF}

{$IF defined(DESKTOP)}
		{$DEFINE USE_MPG123}
		{$ENDIF}

unit SaGeAudioDecoder;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeDllManager

	,Classes
	;

type
	TSGAudioDecoder = class;
	TSGAudioDecoderClass = class of TSGAudioDecoder;

{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST := TSGAudioDecoderClassList}
{$DEFINE DATATYPE      := TSGAudioDecoderClass}
{$INCLUDE SaGeCommonList.inc}
{$UNDEF DATATYPE_LIST}
{$UNDEF DATATYPE}
{$UNDEF INC_PLACE_INTERFACE}

const
	SGAudioDecoderBufferSize = 4096 * 8;
type
	TSGAudioInfo = object
			public
		FBitsPerSample : TSGByte; // 8, 16 or 32
		FChannels      : TSGByte; // 1, 2 and etc
		FFrequency     : TSGUInt32;
			public
		procedure Clear();
		end;

	TSGAudioDecoder = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		class function SupporedFormats() : TSGStringList; virtual;
		class function Suppored() : TSGBool; virtual;
			public
		function SetInput(const VStream : TStream): TSGAudioDecoder; virtual; abstract; overload;
		function SetInput(const VFileName : TSGString): TSGAudioDecoder; virtual; abstract; overload;
		procedure ReadInfo(); virtual; abstract;
		function Read(var VData; const VBufferSize : TSGUInt64) : TSGUInt64; virtual; abstract;
			protected
		FInfo : TSGAudioInfo;
		FInfoReaded : TSGBool;
			protected
		class function CreateInputStream(const VFileName : TSGString) : TStream; virtual;
		function GetSize() : TSGUInt64; virtual; abstract;
		function GetPosition() : TSGUInt64; virtual; abstract;
		procedure SetPosition(const VPosition : TSGUInt64); virtual; abstract;
			public
		property Size     : TSGUInt64 read GetSize;
		property Position : TSGUInt64 read GetPosition write SetPosition;
		property Info     : TSGAudioInfo read FInfo;
		end;

function TSGCompatibleAudioDecoder(const VExpansion : TSGString) : TSGAudioDecoderClass;
function TSGCompatibleAudioFormats() : TSGStringList;
procedure SGAddDecoder(const VDecoder : TSGAudioDecoderClass);

implementation

uses
	Crt

	//Decoders
	,SaGeAudioDecoderWAV
	{$IFDEF USE_MPG123}
	,SaGeAudioDecoderMPG123
	{$ENDIF}
	{$IFDEF USE_OGG}
	,SaGeAudioDecoderOGG
	{$ENDIF}
	;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST := TSGAudioDecoderClassList}
{$DEFINE DATATYPE      := TSGAudioDecoderClass}
{$INCLUDE SaGeCommonList.inc}
{$UNDEF DATATYPE_LIST}
{$UNDEF DATATYPE}
{$UNDEF INC_PLACE_IMPLEMENTATION}

var
	AudioDecoders : TSGAudioDecoderClassList = nil;

procedure SGAddDecoder(const VDecoder : TSGAudioDecoderClass);
begin
AudioDecoders *= VDecoder;
end;

function TSGCompatibleAudioFormats() : TSGStringList;
var
	C : TSGAudioDecoderClass;
begin
Result := nil;
for C in AudioDecoders do
	if C.Suppored then
		Result *= C.SupporedFormats();
end;

function TSGCompatibleAudioDecoder(const VExpansion : TSGString) : TSGAudioDecoderClass;
var
	C  : TSGAudioDecoderClass;
	SF : TSGStringList;
begin
Result := nil;
for C in AudioDecoders do
	begin
	SF := C.SupporedFormats();
	if VExpansion in SF then
		Result := C;
	SetLength(SF, 0);
	if (Result <> nil) and (not C.Suppored) then
		Result := nil;
	if Result <> nil then
		break;
	end;
end;

class function TSGAudioDecoder.CreateInputStream(const VFileName : TSGString) : TStream;

function CreateMemoryStream() : TStream;
begin
Result := TMemoryStream.Create();
(Result as TMemoryStream).LoadFromFile(VFileName);
end;

function CreateFileStream() : TStream;
begin
Result := TFileStream.Create(VFileName, fmOpenRead);
end;

begin
Result := CreateFileStream();
Result.Position := 0;
end;

class function TSGAudioDecoder.Suppored() : TSGBool;
begin
Result := False;
end;

class function TSGAudioDecoder.SupporedFormats() : TSGStringList;
begin
Result := nil;
end;

constructor TSGAudioDecoder.Create();
begin
inherited;
FInfo.Clear();
FInfoReaded := False;
end;

destructor TSGAudioDecoder.Destroy();
begin
FInfoReaded := False;
FInfo.Clear();
inherited;
end;

class function TSGAudioDecoder.ClassName() : TSGString;
begin
Result := 'TSGAudioDecoder';
end;

procedure TSGAudioInfo.Clear();
begin
FBitsPerSample := 0;
FChannels      := 0;
FFrequency     := 0;
end;

finalization
	SetLength(AudioDecoders, 0);

end.
