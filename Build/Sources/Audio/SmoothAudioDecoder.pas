{$INCLUDE Smooth.inc}

{$IF defined(WIN32)}
	{$DEFINE USE_OGG}
	{$ENDIF}

{$IF defined(DESKTOP)}
	{$DEFINE USE_MPG123}
	{$ENDIF}

unit SmoothAudioDecoder;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothCommon
	,SmoothDllManager

	,Classes
	;

type
	TSAudioDecoder = class;
	TSAudioDecoderClass = class of TSAudioDecoder;

{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSAudioDecoderClassListHelper}
{$DEFINE DATATYPE_LIST := TSAudioDecoderClassList}
{$DEFINE DATATYPE      := TSAudioDecoderClass}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_INTERFACE}

const
	SAudioDecoderBufferSize = 4096 * 8;
type
	TSAudioInfo = object
			public
		FBitsPerSample : TSByte; // 8, 16 or 32
		FChannels      : TSByte; // 1, 2 and etc
		FFrequency     : TSUInt32;
			public
		procedure Clear();
		end;

	TSAudioDecoder = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		class function SupportedFormats() : TSStringList; virtual;
		class function Supported() : TSBool; virtual;
			public
		function SetInput(const VStream : TStream): TSAudioDecoder; virtual; abstract; overload;
		function SetInput(const VFileName : TSString): TSAudioDecoder; virtual; abstract; overload;
		procedure ReadInfo(); virtual; abstract;
		function Read(var VData; const VBufferSize : TSUInt64) : TSUInt64; virtual; abstract;
			protected
		FInfo : TSAudioInfo;
		FInfoReaded : TSBool;
			protected
		class function CreateInputStream(const VFileName : TSString) : TStream; virtual;
		class function CreateInputMemoryStream(const VFileName : TSString) : TMemoryStream; virtual;
		function GetSize() : TSUInt64; virtual; abstract;
		function GetPosition() : TSUInt64; virtual; abstract;
		procedure SetPosition(const VPosition : TSUInt64); virtual; abstract;
			public
		property Size     : TSUInt64 read GetSize;
		property Position : TSUInt64 read GetPosition write SetPosition;
		property Info     : TSAudioInfo read FInfo;
		end;

function TSCompatibleAudioDecoder(const VExtension : TSString) : TSAudioDecoderClass;
function TSCompatibleAudioFormats() : TSStringList;
procedure SAddDecoder(const VDecoder : TSAudioDecoderClass);

implementation

uses
	Crt

	//Decoders
	,SmoothAudioDecoderWAV
	{$IFDEF USE_MPG123}
	,SmoothAudioDecoderMPG123
	{$ENDIF}
	{$IFDEF USE_OGG}
	,SmoothAudioDecoderOGG
	{$ENDIF}
	;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSAudioDecoderClassListHelper}
{$DEFINE DATATYPE_LIST := TSAudioDecoderClassList}
{$DEFINE DATATYPE      := TSAudioDecoderClass}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

var
	AudioDecoders : TSAudioDecoderClassList = nil;

procedure SAddDecoder(const VDecoder : TSAudioDecoderClass);
begin
AudioDecoders *= VDecoder;
end;

function TSCompatibleAudioFormats() : TSStringList;
var
	C : TSAudioDecoderClass;
begin
Result := nil;
for C in AudioDecoders do
	if C.Supported then
		Result *= C.SupportedFormats();
end;

function TSCompatibleAudioDecoder(const VExtension : TSString) : TSAudioDecoderClass;
var
	C  : TSAudioDecoderClass;
	SF : TSStringList;
begin
Result := nil;
for C in AudioDecoders do
	begin
	SF := C.SupportedFormats();
	if VExtension in SF then
		Result := C;
	SetLength(SF, 0);
	if (Result <> nil) and (not C.Supported) then
		Result := nil;
	if Result <> nil then
		break;
	end;
end;

class function TSAudioDecoder.CreateInputMemoryStream(const VFileName : TSString) : TMemoryStream;
begin
Result := TMemoryStream.Create();
Result.LoadFromFile(VFileName);
Result.Position := 0;
end;

class function TSAudioDecoder.CreateInputStream(const VFileName : TSString) : TStream;
begin
Result := TFileStream.Create(VFileName, fmOpenRead);
Result.Position := 0;
end;

class function TSAudioDecoder.Supported() : TSBool;
begin
Result := False;
end;

class function TSAudioDecoder.SupportedFormats() : TSStringList;
begin
Result := nil;
end;

constructor TSAudioDecoder.Create();
begin
inherited;
FInfo.Clear();
FInfoReaded := False;
end;

destructor TSAudioDecoder.Destroy();
begin
FInfoReaded := False;
FInfo.Clear();
inherited;
end;

class function TSAudioDecoder.ClassName() : TSString;
begin
Result := 'TSAudioDecoder';
end;

procedure TSAudioInfo.Clear();
begin
FBitsPerSample := 0;
FChannels      := 0;
FFrequency     := 0;
end;

finalization
	SetLength(AudioDecoders, 0);

end.
