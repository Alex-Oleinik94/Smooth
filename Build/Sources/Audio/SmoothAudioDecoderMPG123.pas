{$INCLUDE Smooth.inc}

unit SmoothAudioDecoderMPG123;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothCommon
	,SmoothAudioDecoder
	
	,Classes
	
	,mpg123
	;

type
	TSAudioDecoderMPG123 = class(TSAudioDecoder)
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
		procedure KillInput();
			private
		FDataPosition : TSUInt64;
		FDataSize     : TSUInt64;
		FPosition     : TSUInt64;
			private
		FMPGHandle: PMPG123_Handle;
		FRate     : Integer;
		FChannels : Integer;
		FEncoding : Integer;
		end;

function mpg123_AudioDecoder() : PChar;
function mpg123_StrEncoding(const VEncoding : integer) : TSString;

implementation

uses
	 SysUtils
	
	,SmoothStringUtils
	,SmoothDllManager
	,SmoothLog
	,SmoothSysUtils
	;

class function TSAudioDecoderMPG123.SupportedFormats() : TSStringList;
begin
Result := nil;
Result += 'MP3';
end;

class function TSAudioDecoderMPG123.Supported() : TSBool;
begin
Result := False;
if DllManager.Supported('mpg123') then
	if mpg123_inited() then
		Result := True;
end;

function mpg123_StrEncoding(const VEncoding : integer) : TSString;
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
	i : TSUInt32;
	DFirst, DLast : TSString;
	DecoderList : TSStringList = nil;

procedure SetDecoder(const VDecoder : TSString);
var
	i : TSUInt32;
begin
if Decoders <> nil then
	begin
	i :=0;
	while Decoders[i] <> nil do
		begin
		if SPCharToString(Decoders[i]) = VDecoder then
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
			DLast := SPCharToString(Decoders[i]);
		DecoderList += SPCharToString(Decoders[i]);
		i += 1;
		if Decoders[i] = nil then
			DLast := SPCharToString(Decoders[i]);
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

function TSAudioDecoderMPG123.SetInput(const VStream : TStream): TSAudioDecoder; overload;
begin
KillInput();
raise Exception.Create('TSAudioDecoderMPG123.SetInput from Stream not emplemented!');
Result := Self;
end;

function TSAudioDecoderMPG123.SetInput(const VFileName : TSString) : TSAudioDecoder; overload;
begin
KillInput();

FMPGHandle := mpg123_new(mpg123_AudioDecoder(), nil);
if FMPGHandle = nil then
	begin
	SLog.Source('TSAudioDecoderMPG123.SetInput : Error while creating MPG123 handle!');
	Exit;
	end
else
	SLog.Source('TSAudioDecoderMPG123.SetInput : MPG123 handle created as ''' + SPCharToString(mpg123_AudioDecoder()) + '''.');

mpg123_open(FMPGHandle, PChar(VFileName));
Result := Self;
end;

procedure TSAudioDecoderMPG123.ReadInfo();
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

SLog.Source('TSAudioDecoderMPG123.ReadInfo : Encoding=''' + SStr(FEncoding) + ''' is ''' + mpg123_StrEncoding(FEncoding) + ''', Rate=''' + SStr(FRate) + ''', Channels=''' + SStr(FChannels) + '''!');
FInfoReaded := True;
end;

function TSAudioDecoderMPG123.Read(var VData; const VBufferSize : TSUInt64) : TSUInt64;
var
	DataLength : Cardinal;
begin
Result := VBufferSize;
DataLength := VBufferSize;
try
mpg123_read(FMPGHandle, @VData, Result, @DataLength);
except on e : Exception do
	begin
	SLog.Source('TSAudioDecoderMPG123.Read(''' + SAddrStr(@VData) + ''', ''' + SStr(VBufferSize) + ''') : Exception while decoding!');
	SPrintExceptionStackTrace(e);
	end;
end;
//SLog.Source('TSAudioDecoderMPG123.Read(''' + SAddrStr(@VData) + ''', ''' + SStr(VBufferSize) + ''') : Reads ' + SStr(DataLength) + ' of ' + SStr(Result) + ' bytes' + Iff(DataLength = 0, '!', '.'));
Result := DataLength;
end;

function TSAudioDecoderMPG123.GetSize() : TSUInt64;
begin
Result := 0;
end;

procedure TSAudioDecoderMPG123.SetPosition(const VPosition : TSUInt64);
begin
end;

function TSAudioDecoderMPG123.GetPosition() : TSUInt64;
begin
Result := 0;
end;

constructor TSAudioDecoderMPG123.Create();
begin
inherited;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FMPGHandle := nil;
FRate := 0;
FChannels := 0;
FEncoding := 0;
if not DllManager.Supported('mpg123') then
	raise Exception.Create('MPG123 is not suppored!');
if not mpg123_inited() then
	raise Exception.Create('MPG123 is not inited!');
end;

procedure TSAudioDecoderMPG123.KillInput();
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

destructor TSAudioDecoderMPG123.Destroy();
begin
KillInput();
inherited;
end;

class function TSAudioDecoderMPG123.ClassName() : TSString;
begin
Result := 'TSAudioDecoderMPG123';
end;

initialization
	SAddDecoder(TSAudioDecoderMPG123);

end.
