{$INCLUDE Smooth.inc}

unit SmoothAudioDecoderWAV;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothCommon
	,SmoothAudioDecoder

	,Classes
	;

type
	TWAVHeader = object
			public
		RIFFHeader: array [1..4] of AnsiChar;
		FileSize: Integer;
		WAVEHeader: array [1..4] of AnsiChar;
		FormatHeader: array [1..4] of AnsiChar;
		FormatHeaderSize: Integer;
		FormatCode: Word;
		ChannelNumber: Word;
		SampleRate: Integer;
		BytesPerSecond: Integer;
		BytesPerSample: Word;
		BitsPerSample: Word;
			public
		procedure Clear();
		end;

const
	WAV_STANDARD  = $0001;
	WAV_IMA_ADPCM = $0011;
	WAV_MP3       = $0055;

type
	TSAudioDecoderWAV = class(TSAudioDecoder)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		class function SupportedFormats() : TSStringList; override;
		class function Supported() : TSBool; override;
			public
		function SetInput(const VStream : TStream): TSAudioDecoder; override; overload;
		function SetInput(const VFileName : TSString) : TSAudioDecoder; override; overload;
		procedure ReadInfo(); override;
		function Read(var VData; const VBufferSize : TSUInt64) : TSUInt64; override;
			protected
		procedure SetPosition(const VPosition : TSUInt64); override;
		function GetSize() : TSUInt64; override;
		function GetPosition() : TSUInt64; override;
			private
		FInput        : TStream;
		FDataPosition : TSUInt64;
		FDataSize     : TSUInt64;
		FPosition     : TSUInt64;
		FWAVHeader    : TWAVHeader;
			private
		procedure KillInput();
		procedure DetermineInfo();
			public
		class function StrFormatCode(const VFormatCode : Word):TSString;
		end;

implementation

uses
	 SysUtils
	
	,SmoothStringUtils
	,SmoothLog
	,SmoothSysUtils
	;

class function TSAudioDecoderWAV.SupportedFormats() : TSStringList;
begin
Result := nil;
Result += 'WAV';
Result += 'WAVE';
end;

class function TSAudioDecoderWAV.Supported() : TSBool;
begin
Result := True;
end;

class function TSAudioDecoderWAV.StrFormatCode(const VFormatCode : Word):TSString;
begin
case VFormatCode of
WAV_STANDARD :
	Result := 'WAV_STANDARD';
WAV_IMA_ADPCM :
	Result := 'WAV_IMA_ADPCM';
WAV_MP3 :
	Result := 'WAV_MP3';
else
	Result := 'unknown';
end;
end;

procedure TWAVHeader.Clear();
begin
FillChar(Self, SizeOf(Self), 0);
end;

function TSAudioDecoderWAV.SetInput(const VStream : TStream): TSAudioDecoder; overload;
begin
KillInput();
FInput := VStream;
FInput.Position := 0;
Result := Self;
end;

function TSAudioDecoderWAV.SetInput(const VFileName : TSString) : TSAudioDecoder; overload;
begin
KillInput();
FInput := CreateInputStream(VFileName);
Result := Self;
end;

procedure TSAudioDecoderWAV.DetermineInfo();
begin
FInfo.FBitsPerSample := FWAVHeader.BitsPerSample;
FInfo.FChannels      := FWAVHeader.ChannelNumber;
FInfo.FFrequency     := FWAVHeader.SampleRate;
end;

procedure TSAudioDecoderWAV.ReadInfo();
var
	ChuckName : array[0..3]of char;
	ChuckSize : TSInt32;
begin
if FInfoReaded then
	exit;
FInput.Read(FWAVHeader, SizeOf(FWAVHeader));
DetermineInfo();
if WAV_STANDARD <> FWavHeader.FormatCode then
	SLog.Source('TSAudioDecoderWAV.ReadInfo : Needs decode data! FormatCode = ''' + StrFormatCode(FWavHeader.FormatCode) + '''.');
FInput.Seek((8-44)+12+4+FWAVHeader.FormatHeaderSize+4, soFromCurrent);

repeat
FInput.Read(ChuckName, SizeOf(ChuckName));
FInput.Read(ChuckSize, SizeOf(ChuckSize));
if ChuckName = 'data' then
	begin
	FDataSize := ChuckSize;
	FDataPosition := FInput.Position;
	FPosition := FInput.Position;
	SLog.Source('TSAudioDecoderWAV : Data chunk determinded, Position=''' + SStr(FInput.Position) + ''', Size=''' + SStr(ChuckSize) + '''!');
	FInput.Position := FInput.Position + ChuckSize;
	end
else
	begin
	SLog.Source('TSAudioDecoderWAV.ReadInfo : Unknown chunk ''' + ChuckName + ''', Position=''' + SStr(FInput.Position) + ''', Size=''' + SStr(ChuckSize) + '''.');
	FInput.Position := FInput.Position + ChuckSize;
	end;
until (FInput.Position >= FInput.Size);

FInfoReaded := True;
end;

//{$DEFINE USE_READBUFFER}
{$DEFINE USE_READ}
{$IFDEF USE_READ}
	{$DEFINE USE_RESULT}
	{$ENDIF}

function TSAudioDecoderWAV.Read(var VData; const VBufferSize : TSUInt64) : TSUInt64;
var
	BytesRead : TSInt32 = 0;
begin
Result := 0;
if FPosition >= FDataPosition + FDataSize then
	exit;
if FPosition + VBufferSize > FDataPosition + FDataSize then
	Result := (FDataPosition + FDataSize) - FPosition
else
	Result := VBufferSize;
if Result <> 0 then
	begin
	if FInput.Position <> FPosition then
		FInput.Position := FPosition;
	try
	{$IFDEF USE_READ}
		BytesRead := FInput.Read(VData, Result);
		{$IFDEF USE_RESULT}Result := BytesRead;{$ENDIF}
	{$ELSE} {$IFDEF USE_READBUFFER}
		FInput.ReadBuffer(VData, Result);
		{$ENDIF} {$ENDIF}
	except on e : Exception do
		begin
		SLog.Source('TSAudioDecoderWAV.Read(''' + SAddrStr(@VData) + ''', ''' + SStr(VBufferSize) + ''') : Exception while reading from Stream!');
		SPrintExceptionStackTrace(e);
		end;
	end;
	{$IF defined(USE_READ) and (not defined(USE_RESULT))}
	//SLog.Source('TSAudioDecoderWAV.Read : Read ' + SStr(BytesRead) + ' of ' + SStr(Result) + ' bytes' + Iff(BytesRead = 0, '!', '.'));
	{$ENDIF}
	FPosition += Result;
	end;
end;

function TSAudioDecoderWAV.GetSize() : TSUInt64;
begin
Result := FDataSize;
end;

procedure TSAudioDecoderWAV.SetPosition(const VPosition : TSUInt64);
begin
FPosition := VPosition + FDataPosition;
end;

function TSAudioDecoderWAV.GetPosition() : TSUInt64;
begin
Result := FPosition - FDataPosition;
end;

constructor TSAudioDecoderWAV.Create();
begin
inherited;
FInput := nil;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FWAVHeader.Clear();
end;

procedure TSAudioDecoderWAV.KillInput();
begin
if FInput <> nil then
	begin
	FInput.Destroy();
	FInput := nil;
	end;
FInfo.Clear();
FWAVHeader.Clear();
FInfoReaded := False;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
end;

destructor TSAudioDecoderWAV.Destroy();
begin
KillInput();
inherited;
end;

class function TSAudioDecoderWAV.ClassName() : TSString;
begin
Result := 'TSAudioDecoderWAV';
end;

initialization
	SAddDecoder(TSAudioDecoderWAV);
end.
