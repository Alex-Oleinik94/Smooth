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
		function GetSize() : TSGUInt64; virtual; abstract;
		function GetPosition() : TSGUInt64; virtual; abstract;
		procedure SetPosition(const VPosition : TSGUInt64); virtual; abstract;
			public
		property Size : TSGUInt64 read GetSize;
		property Position : TSGUInt64 read GetPosition write SetPosition;
		property Info : TSGAudioInfo read FInfo;
		end;

function TSGCompatibleAudioDecoder(const VExpansion : TSGString) : TSGAudioDecoderClass;
function TSGCompatibleAudioDecoders_Formats() : TSGStringList;

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

function TSGCompatibleAudioDecoders_Formats() : TSGStringList;
begin
Result := nil;
Result += 'WAV';
Result += 'WAVE';
{$IFDEF USE_MPG123}
if TSGAudioDecoderMPG123.Suppored then
	Result += 'MP3';
{$ENDIF}
{$IFDEF USE_OGG}
if TSGAudioDecoderMPG123.Suppored then
	Result += 'OGG';
{$ENDIF}
end;

function TSGCompatibleAudioDecoder(const VExpansion : TSGString) : TSGAudioDecoderClass;
begin
Result := nil;
if (Result = nil) and ((VExpansion = 'WAV') or (VExpansion = 'WAVE')) then
	Result := TSGAudioDecoderWAV;
{$IFDEF USE_MPG123}
if (Result = nil) and (VExpansion = 'MP3') and TSGAudioDecoderMPG123.Suppored() then
	Result := TSGAudioDecoderMPG123;
{$ENDIF}
{$IFDEF USE_OGG}
if (Result = nil) and (VExpansion = 'OGG') and TSGAudioDecoderOGG.Suppored() then
	Result := TSGAudioDecoderOGG;
{$ENDIF}
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

end.
