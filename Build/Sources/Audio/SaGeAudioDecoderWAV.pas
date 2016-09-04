{$INCLUDE SaGe.inc}

unit SaGeAudioDecoderWAV;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioDecoder

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
	TSGAudioDecoderWAV = class(TSGAudioDecoder)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			public
		function SetInput(const VStream : TStream): TSGAudioDecoder; override; overload;
		function SetInput(const VFileName : TSGString) : TSGAudioDecoder; override; overload;
		procedure ReadInfo(); override;
		function Read(var VData; const VBufferSize : TSGUInt64) : TSGUInt64; override;
			protected
		procedure SetPosition(const VPosition : TSGUInt64); override;
		function GetSize() : TSGUInt64; override;
		function GetPosition() : TSGUInt64; override;
		procedure DetermineInfo(); override;
			private
		FInput        : TStream;
		FDataPosition : TSGUInt64;
		FDataSize     : TSGUInt64;
		FPosition     : TSGUInt64;
		FWAVHeader    : TWAVHeader;
			private
		procedure KillInput();
			public
		class function StrFormatCode(const VFormatCode : Word):TSGString;
		end;

implementation

uses
	Crt
	;

class function TSGAudioDecoderWAV.StrFormatCode(const VFormatCode : Word):TSGString;
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

function TSGAudioDecoderWAV.SetInput(const VStream : TStream): TSGAudioDecoder; overload;
begin
KillInput();
FInput := VStream;
FInput.Position := 0;
Result := Self;
end;

function TSGAudioDecoderWAV.SetInput(const VFileName : TSGString) : TSGAudioDecoder; overload;
begin
KillInput();
FInput := TFileStream.Create(VFileName, fmOpenRead);
FInput.Position := 0;
Result := Self;
end;

procedure TSGAudioDecoderWAV.DetermineInfo();
begin
FInfo.FBitsPerSample := FWAVHeader.BitsPerSample;
FInfo.FChannels      := FWAVHeader.ChannelNumber;
FInfo.FFrequency     := FWAVHeader.SampleRate;
end;

procedure TSGAudioDecoderWAV.ReadInfo();
var
	ChuckName : array[0..3]of char;
	ChuckSize : TSGInt32;
begin
if FInfoReaded then
	exit;
FInput.Read(FWAVHeader, SizeOf(FWAVHeader));
DetermineInfo();
if WAV_STANDARD <> FWavHeader.FormatCode then
	SGLog.Sourse('TSGAudioDecoderWAV.ReadInfo : Needs decode data! FormatCode = ''' + StrFormatCode(FWavHeader.FormatCode) + '''.');
FInput.Seek((8-44)+12+4+FWAVHeader.FormatHeaderSize+4, soFromCurrent);

repeat
FInput.Read(ChuckName, SizeOf(ChuckName));
FInput.Read(ChuckSize, SizeOf(ChuckSize));
if ChuckName = 'data' then
	begin
	FDataSize := ChuckSize;
	FDataPosition := FInput.Position;
	FPosition := FDataPosition;
	FInput.Position := FInput.Position + ChuckSize;
	end
else
	begin
	SGLog.Sourse('TSGAudioDecoderWAV.ReadInfo : Unknown chunk ''' + ChuckName + ''', Position=''' + SGStr(FInput.Position) + ''', Size=''' + SGStr(ChuckSize) + '''.');
	FInput.Position := FInput.Position + ChuckSize;
	end;
until FInput.Position >= FInput.Size;
FInput.Position := FPosition;
end;

function TSGAudioDecoderWAV.Read(var VData; const VBufferSize : TSGUInt64) : TSGUInt64;
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
		begin
		FInput.Position := FPosition;
		WriteLn(1);
		end;
	FInput.ReadBuffer(VData, Result);
	end;
end;

function TSGAudioDecoderWAV.GetSize() : TSGUInt64;
begin
Result := FDataSize;
end;

procedure TSGAudioDecoderWAV.SetPosition(const VPosition : TSGUInt64);
begin
FPosition := VPosition + FDataPosition;
end;

function TSGAudioDecoderWAV.GetPosition() : TSGUInt64;
begin
Result := FPosition - FDataPosition;
end;

constructor TSGAudioDecoderWAV.Create();
begin
inherited;
FInput := nil;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FWAVHeader.Clear();
end;

procedure TSGAudioDecoderWAV.KillInput();
begin
if FInput <> nil then
	begin
	FInput.Destroy();
	FInput := nil;
	end;
FInfo.Clear();
FWAVHeader.Clear();
FInfoReaded := False;
end;

destructor TSGAudioDecoderWAV.Destroy();
begin
inherited;
end;

class function TSGAudioDecoderWAV.ClassName() : TSGString;
begin
Result := 'TSGAudioDecoderWAV';
end;

end.
