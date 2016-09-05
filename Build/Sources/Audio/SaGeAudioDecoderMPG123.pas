{$INCLUDE SaGe.inc}

unit SaGeAudioDecoderMPG123;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioDecoder

	,Classes

	,mpg123
	;

type
	TSGAudioDecoderMPG123 = class(TSGAudioDecoder)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		class function SupporedFormats() : TSGStringList; override;
		class function Suppored() : TSGBool; override;
			public
		function SetInput(const VStream : TStream): TSGAudioDecoder; override; overload;
		function SetInput(const VFileName : TSGString) : TSGAudioDecoder; override; overload;
		procedure ReadInfo(); override;
		function Read(var VData; const VBufferSize : TSGUInt64) : TSGUInt64; override;
			protected
		procedure SetPosition(const VPosition : TSGUInt64); override;
		function GetSize() : TSGUInt64; override;
		function GetPosition() : TSGUInt64; override;
			private
		procedure KillInput();
			private
		FDataPosition : TSGUInt64;
		FDataSize     : TSGUInt64;
		FPosition     : TSGUInt64;
			private
		FMPGHandle: PMPG123_Handle;
		FRate     : Integer;
		FChannels : Integer;
		FEncoding : Integer;
		end;

function mpg123_AudioDecoder() : PChar;
function mpg123_StrEncoding(const VEncoding : integer) : TSGString;

implementation

uses
	SysUtils
	,SaGeDllManager
	;

class function TSGAudioDecoderMPG123.SupporedFormats() : TSGStringList;
begin
Result := nil;
Result += 'MP3';
end;

class function TSGAudioDecoderMPG123.Suppored() : TSGBool;
begin
Result := False;
if DllManager.Suppored('mpg123') then
	if mpg123_inited() then
		Result := True;
end;

function mpg123_StrEncoding(const VEncoding : integer) : TSGString;
begin
case VEncoding of
MPG123_ENC_16 :
	Result := 'MPG123_ENC_16';
MPG123_ENC_SIGNED_16 :
	Result := 'MPG123_ENC_SIGNED_16';
MPG123_ENC_UNSIGNED_16 :
	Result := 'MPG123_ENC_UNSIGNED_16';
MPG123_ENC_8 :
	Result := 'MPG123_ENC_8';
MPG123_ENC_SIGNED_8 :
	Result := 'MPG123_ENC_SIGNED_8';
MPG123_ENC_UNSIGNED_8 :
	Result := 'MPG123_ENC_UNSIGNED_8';
MPG123_ENC_ULAW_8 :
	Result := 'MPG123_ENC_ULAW_8';
MPG123_ENC_ALAW_8 :
	Result := 'MPG123_ENC_ALAW_8';
else
	Result := '?';
end;
end;

function mpg123_AudioDecoder() : PChar;
var
	Decoders : PPChar;
	i : TSGUInt32;
	DFirst, DLast : TSGString;
	DecoderList : TSGStringList = nil;

procedure SetDecoder(const VDecoder : TSGString);
var
	i : TSGUInt32;
begin
if Decoders <> nil then
	begin
	i :=0;
	while Decoders[i] <> nil do
		begin
		if SGPCharToString(Decoders[i]) = VDecoder then
			begin
			Result := Decoders[i];
			break;
			end;
		i += 1;
		end;
	end;
end;

const
	GeneralDecoder =
{$IFDEF LINUX}
		'default'
{$ELSE}
		''
{$ENDIF}
		;
begin
Decoders := mpg123_supported_decoders();
Result := nil;
DFirst := '';
DLast  := '';
if Decoders <> nil then
	begin
	i := 0;
	while Decoders[i] <> nil do
		begin
		if i = 0 then
			DLast := SGPCharToString(Decoders[i]);
		DecoderList += SGPCharToString(Decoders[i]);
		i += 1;
		if Decoders[i] = nil then
			DLast := SGPCharToString(Decoders[i]);
		end;
	end;
if (GeneralDecoder <> '') and (GeneralDecoder in DecoderList) then
	SetDecoder(GeneralDecoder)
else if 'x86-64' in DecoderList then
	SetDecoder('x86-64')
else if 'i586' in DecoderList then
	SetDecoder('i586')
else if 'i386' in DecoderList then
	SetDecoder('i386')
else if 'MMX' in DecoderList then
	SetDecoder('MMX')
else if 'generic' in DecoderList then
	SetDecoder('generic')
else if 'AVX' in DecoderList then
	SetDecoder('AVX')
else if DLast <> '' then
	SetDecoder(DLast)
else if DFirst <> '' then
	SetDecoder(DFirst);
SetLength(DecoderList, 0);
end;

function TSGAudioDecoderMPG123.SetInput(const VStream : TStream): TSGAudioDecoder; overload;
begin
KillInput();
raise Exception.Create('TSGAudioDecoderMPG123.SetInput from Stream not emplemented!');
Result := Self;
end;

function TSGAudioDecoderMPG123.SetInput(const VFileName : TSGString) : TSGAudioDecoder; overload;
begin
KillInput();

FMPGHandle := mpg123_new(mpg123_AudioDecoder(), nil);
if FMPGHandle = nil then
	begin
	SGLog.Sourse('TSGAudioDecoderMPG123.SetInput : Error while creating MPG123 handle!');
	Exit;
	end
else
	SGLog.Sourse('TSGAudioDecoderMPG123.SetInput : MPG123 handle created as ''' + SGPCharToString(mpg123_AudioDecoder()) + '''.');

mpg123_open(FMPGHandle, PChar(VFileName));
Result := Self;
end;

procedure TSGAudioDecoderMPG123.ReadInfo();
begin
if FInfoReaded then
	exit;

mpg123_getformat(FMPGHandle, @FRate, @FChannels, @FEncoding);
mpg123_format_none(FMPGHandle);
mpg123_format(FMPGHandle, FRate, FChannels, FEncoding);

FInfo.Clear();

case FEncoding of
MPG123_ENC_16, MPG123_ENC_SIGNED_16, MPG123_ENC_UNSIGNED_16 :
	FInfo.FBitsPerSample := 16;
MPG123_ENC_8, MPG123_ENC_SIGNED_8, MPG123_ENC_UNSIGNED_8, MPG123_ENC_ULAW_8, MPG123_ENC_ALAW_8 :
	FInfo.FBitsPerSample := 8;
end;
FInfo.FChannels := FChannels;
FInfo.FFrequency := FRate;

SGLog.Sourse('TSGAudioDecoderMPG123.ReadInfo : Encoding=''' + SGStr(FEncoding) + ''' is ''' + mpg123_StrEncoding(FEncoding) + ''', Rate=''' + SGStr(FRate) + ''', Channels=''' + SGStr(FChannels) + '''!');
FInfoReaded := True;
end;

function TSGAudioDecoderMPG123.Read(var VData; const VBufferSize : TSGUInt64) : TSGUInt64;
var
	DataLength : Cardinal;
begin
Result := VBufferSize;
DataLength := VBufferSize;
try
mpg123_read(FMPGHandle, @VData, Result, @DataLength);
except on e : Exception do
	begin
	SGLog.Sourse('TSGAudioDecoderMPG123.Read(''' + SGAddrStr(@VData) + ''', ''' + SGStr(VBufferSize) + ''') : Exception while decoding!');
	SGPrintExceptionStackTrace(e);
	end;
end;
//SGLog.Sourse('TSGAudioDecoderMPG123.Read(''' + SGAddrStr(@VData) + ''', ''' + SGStr(VBufferSize) + ''') : Reads ' + SGStr(DataLength) + ' of ' + SGStr(Result) + ' bytes' + Iff(DataLength = 0, '!', '.'));
Result := DataLength;
end;

function TSGAudioDecoderMPG123.GetSize() : TSGUInt64;
begin
Result := 0;
end;

procedure TSGAudioDecoderMPG123.SetPosition(const VPosition : TSGUInt64);
begin
end;

function TSGAudioDecoderMPG123.GetPosition() : TSGUInt64;
begin
Result := 0;
end;

constructor TSGAudioDecoderMPG123.Create();
begin
inherited;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FMPGHandle := nil;
FRate := 0;
FChannels := 0;
FEncoding := 0;
if not DllManager.Suppored('mpg123') then
	raise Exception.Create('MPG123 is not suppored!');
if not mpg123_inited() then
	raise Exception.Create('MPG123 is not inited!');
end;

procedure TSGAudioDecoderMPG123.KillInput();
begin
if FMPGHandle <> nil then
	begin
	mpg123_close(FMPGHandle);
	mpg123_delete(FMPGHandle);
	FMPGHandle := nil;
	end;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FRate := 0;
FChannels := 0;
FEncoding := 0;
FInfoReaded := False;
end;

destructor TSGAudioDecoderMPG123.Destroy();
begin
KillInput();
inherited;
end;

class function TSGAudioDecoderMPG123.ClassName() : TSGString;
begin
Result := 'TSGAudioDecoderMPG123';
end;

initialization
	SGAddDecoder(TSGAudioDecoderMPG123);

end.
