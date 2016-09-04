{$INCLUDE SaGe.inc}

//{$DEFINE OPENAL_RENDER_DEBUG}

{$IF defined(WIN32)}
	{$DEFINE USE_OGG}
	{$ENDIF}

{$IF defined(DESKTOP)}
		{$DEFINE USE_MPG123}
		{$ENDIF}

unit SaGeAudioRenderOpenAL;

interface

uses
	// Engine
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioRender
	,SaGeAudioDecoder

	// System
	,Classes
	,SysUtils
	,SyncObjs

	// Audio Library
	,OpenAL
	,Alut

	// Codecs :
		(* ogg *)
	{$IFDEF USE_OGG}
	,Ogg
	,Codec
	,CommentUtils
	,OSTypes
	,VCEdit
	,VorbisEnc
	,VorbisFile
	{$ENDIF}

		(* mp3 and etc *)
	{$IFDEF USE_MPG123}
	,mpg123
	{$ENDIF}
	;

type
	TSGALSource = TALuint;
	TSGALBuffer = TALuint;
	TSGALFormat = TALenum;

	{$IFDEF USE_MPG123}
	TSGOpenALMP123FilePlayer = class(TSGThread)
			public
		constructor Create(const FilePath: TSGString);
		destructor Destroy(); override;
			protected
		FMaxBufferSize : TSGMaxEnum;
		FSource   : TSGALSource;
		FBuffers  : array[0..1] of TSGALBuffer;
		FFormat   : TALenum;
		FFileName : TSGString;
		FMPGHandle: PMPG123_Handle;
		FRate     : Integer;
		FChannels : Integer;
		FEncoding : Integer;
		FPlaying  : TSGBool;
			protected
		function UpdateBuffer() : TSGBool;
		function PreBuffer() : TSGUInt64;
		function Stream(const VBuffer : TSGALBuffer) : TSGUInt64;
			public
		procedure Execute(); override;
		procedure Play();
		procedure Stop();
			public
		property Playing : TSGBool read FPlaying;
		end;
	{$ENDIF}

	TSGOpenALCustomSource = class(TSGAudioRenderObject, ISGAudioSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		destructor Destroy(); override;
			protected
		FSource : TSGALSource;
			public
		property Source : TSGALSource read FSource;
			public
		class function ClassName() : TSGString; override;
			public
		procedure SetPosition(const VPosition : TSGVector3f); virtual;
		function  GetPosition() : TSGVector3f; virtual;
		procedure SetDirection(const VDirection : TSGVector3f); virtual;
		function  GetDirection() : TSGVector3f; virtual;
		procedure SetVelocity(const VVelocity : TSGVector3f); virtual;
		function  GetVelocity() : TSGVector3f; virtual;
		procedure SetLooping(const VLooping : TSGBool); virtual;
		function  GetLooping() : TSGBool; virtual;
		procedure SetRelative(const VRelative : TSGBool); virtual;
		function GetRelative() : TSGBool; virtual;
		procedure Play(); virtual;
		function Playing() : TSGBool; virtual;
		procedure Pause(); virtual;
		function Paused() : TSGBool; virtual;
		procedure Stop(); virtual;
		function Stoped : TSGBool; virtual;
		end;

	TSGOpenALBufferedSource = class(TSGAudioBufferedSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FOpenALSource : TSGOpenALCustomSource;
		FBuffers  : array[0..1] of TSGALBuffer;
		FFormat   : TALenum;
		FAudioInfo: TSGAudioInfo;
			protected
		function GetSource() : ISGAudioSource; override;
		function CountProcessedBuffers() : TSGUInt32; override;
		procedure DataProcessedBuffer(var Data; const VDataLength : TSGUInt64); override;
		procedure PreBuffer(); override;
			protected
		procedure BufferSource(const VBuffer : TSGALBuffer; var Data; const VDataLength : TSGUInt64);
		end;

	TSGAudioRenderOpenAL = class(TSGAudioRender)
			public
		constructor Create(); override;
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
		class function SupporedAudioFormats() : TSGStringList; override;
			private
		{$IFDEF USE_MPG123}
			FMPG123Suppored : TSGBool;
			FMPG123Initialized : TSGBool;
			{$ENDIF}
		FALUTSuppored : TSGBool;
			private
		FContext      : PALCcontext;
		FDevice       : PALCdevice;
			public
		procedure Init(); override;
		function CreateDevice() : TSGBool; override;
		procedure Kill(); override;
		function CreateBufferedSource() : TSGAudioBufferedSource; override;
			public
		{$IFDEF USE_MPG123}
		function SupporedMPG123() : TSGBool;
		{$ENDIF}
		end;

function SGOpenALFormatFromAudioInfo(const VInfo : TSGAudioInfo) : TSGALFormat;
function SGOpenALStrFormat(const VFormat : TSGALFormat) : TSGString;

implementation

uses
	SaGeDllManager
	;

function SGOpenALFormatFromAudioInfo(const VInfo : TSGAudioInfo) : TSGALFormat;
begin
Result := 0;
case VInfo.FBitsPerSample of
16:
	if VInfo.FChannels = 1 then
		Result := AL_FORMAT_MONO16
	else if VInfo.FChannels = 2 then
		Result := AL_FORMAT_STEREO16;
8:
	if VInfo.FChannels = 1 then
		Result := AL_FORMAT_MONO8
	else if VInfo.FChannels = 2 then
		Result := AL_FORMAT_STEREO8;
end;
end;

function SGOpenALStrFormat(const VFormat : TSGALFormat) : TSGString;
begin
case VFormat of
AL_FORMAT_MONO16 :
	Result := 'AL_FORMAT_MONO16';
AL_FORMAT_MONO8 :
	Result := 'AL_FORMAT_MONO8';
AL_FORMAT_STEREO16 :
	Result := 'AL_FORMAT_STEREO16';
AL_FORMAT_STEREO8 :
	Result := 'AL_FORMAT_STEREO8';
else
	Result := '?';
end;
end;

procedure TSGOpenALBufferedSource.BufferSource(const VBuffer : TSGALBuffer; var Data; const VDataLength : TSGUInt64);
begin
alBufferData(VBuffer, FFormat, @Data, VDataLength, FAudioInfo.FFrequency);
end;

constructor TSGOpenALBufferedSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
FOpenALSource := TSGOpenALCustomSource.Create(VAudioRender);
FillChar(FFormat, SizeOf(FFormat), 0);
FillChar(FAudioInfo, SizeOf(FAudioInfo), 0);
FillChar(FBuffers, SizeOf(FBuffers), 0);
end;

destructor TSGOpenALBufferedSource.Destroy();
begin
if FBuffers[0] + FBuffers[1] <> 0 then
	alDeleteBuffers(2, @FBuffers[0]);
FOpenALSource.Destroy();
inherited;
end;

class function TSGOpenALBufferedSource.ClassName() : TSGString;
begin
Result := 'TSGOpenALBufferedSource';
end;

function TSGOpenALBufferedSource.GetSource() : ISGAudioSource;
begin
Result := FOpenALSource;
end;

function TSGOpenALBufferedSource.CountProcessedBuffers() : TSGUInt32;
var
	Processed : TALint;
begin
alGetSourcei(FOpenALSource.Source, AL_BUFFERS_PROCESSED, @Processed);
Result := Processed;
end;

procedure TSGOpenALBufferedSource.DataProcessedBuffer(var Data; const VDataLength : TSGUInt64);
var
	Buffer : TSGALBuffer;
begin
if VDataLength > 0 then
	begin
	alSourceUnqueueBuffers(FOpenALSource.Source, 1, @Buffer);
	BufferSource(Buffer, Data, VDataLength);
	alSourceQueueBuffers(FOpenALSource.Source, 1, @Buffer);
	end;
end;

procedure TSGOpenALBufferedSource.PreBuffer();

function DecodeAndSendDataToBufferBuffer(const VBuffer : TSGALBuffer) : TSGUInt64;
var
	Data : Pointer;
begin
GetMem(Data, SGAudioDecoderBufferSize);
Result := FDecoder.Read(Data, SGAudioDecoderBufferSize);
if Result > 0 then
	BufferSource(VBuffer, Data^, Result);
FreeMem(Data);
end;

begin
FAudioInfo := FDecoder.Info;
FFormat := SGOpenALFormatFromAudioInfo(FAudioInfo);
SGLog.Sourse('TSGOpenALBufferedSource.PreBuffer : Determine format ''' + SGOpenALStrFormat(FFormat) + '''.');
alGenBuffers(2, @FBuffers[0]);
SGLog.Sourse(
	'TSGOpenALBufferedSource.PreBuffer : Decoded data size ''' +
	SGStr((DecodeAndSendDataToBufferBuffer(FBuffers[0]) + DecodeAndSendDataToBufferBuffer(FBuffers[1]))) +
	'''.');
alSourceQueueBuffers(FOpenALSource.Source, 2, @FBuffers[0]);
end;

constructor TSGOpenALCustomSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
alGenSources(1, @FSource);
alSourcef  (FSource, AL_PITCH,     1.0 );
alSourcef  (FSource, AL_GAIN,      1.0 );
alSource3f (FSource, AL_POSITION,  0, 0, 0);
alSource3f (FSource, AL_VELOCITY,  0, 0, 0);
alSource3f (FSource, AL_DIRECTION, 0, 0, 0);
alSourcei  (FSource, AL_LOOPING,   AL_FALSE);
alSourcei  (FSource, AL_SOURCE_RELATIVE, AL_FALSE);
end;

destructor TSGOpenALCustomSource.Destroy();
begin
alDeleteSources(1, @FSource);
inherited;
end;

class function TSGOpenALCustomSource.ClassName() : TSGString;
begin
Result := 'TSGOpenALCustomSource';
end;

procedure TSGOpenALCustomSource.SetPosition(const VPosition : TSGVector3f);
var
	Position : TSGVector3f;
begin
Position := VPosition;
alSourcefv(FSource, AL_POSITION, @Position);
end;

function  TSGOpenALCustomSource.GetPosition() : TSGVector3f;
begin
alGetSourcefv(FSource, AL_POSITION, @Result);
end;

procedure TSGOpenALCustomSource.SetDirection(const VDirection : TSGVector3f);
var
	Direction : TSGVector3f;
begin
Direction := VDirection;
alSourcefv(FSource, AL_DIRECTION, @Direction);
end;

function  TSGOpenALCustomSource.GetDirection() : TSGVector3f;
begin
alGetSourcefv(FSource, AL_DIRECTION, @Result);
end;

procedure TSGOpenALCustomSource.SetVelocity(const VVelocity : TSGVector3f);
var
	Velocity : TSGVector3f;
begin
Velocity := VVelocity;
alSourcefv(FSource, AL_VELOCITY, @Velocity);
end;

function  TSGOpenALCustomSource.GetVelocity() : TSGVector3f;
begin
alGetSourcefv(FSource, AL_VELOCITY, @Result);
end;

procedure TSGOpenALCustomSource.SetLooping(const VLooping : TSGBool);
var
	Looping : TALint;
begin
Looping := AL_TRUE * Byte(VLooping) + AL_FALSE * Byte(not VLooping);
alSourcei(FSource, AL_LOOPING, Looping);
end;

function  TSGOpenALCustomSource.GetLooping() : TSGBool;
var
	Looping : TALint;
begin
alGetSourcei(FSource, AL_LOOPING, @Looping);
Result := Looping = AL_TRUE;
end;

procedure TSGOpenALCustomSource.SetRelative(const VRelative : TSGBool);
var
	Relative : TALint;
begin
Relative := AL_TRUE * Byte(VRelative) + AL_FALSE * Byte(not VRelative);
alSourcei(FSource, AL_SOURCE_RELATIVE, Relative);
end;

function TSGOpenALCustomSource.GetRelative() : TSGBool;
var
	Relative : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_RELATIVE, @Relative);
Result := Relative = AL_TRUE;
end;

procedure TSGOpenALCustomSource.Play();
begin
alSourcePlay(FSource);
end;

function TSGOpenALCustomSource.Playing() : TSGBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_PLAYING = State;
end;

procedure TSGOpenALCustomSource.Pause();
begin
alSourcePause(FSource);
end;

function TSGOpenALCustomSource.Paused() : TSGBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_PAUSED = State;
end;

procedure TSGOpenALCustomSource.Stop();
begin
alSourceStop(FSource);
end;

function TSGOpenALCustomSource.Stoped : TSGBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_STOPPED = State;
end;

function TSGAudioRenderOpenAL.CreateBufferedSource() : TSGAudioBufferedSource;
begin
Result := TSGOpenALBufferedSource.Create(Self);
end;

{$IFDEF USE_MPG123}
function TSGAudioRenderOpenAL.SupporedMPG123() : TSGBool;
begin
Result := FMPG123Suppored and FMPG123Initialized;
end;

function GetMPG123AudioDecoder() : PChar;
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
{$ENDIF}

class function TSGAudioRenderOpenAL.SupporedAudioFormats() : TSGStringList;
begin
Result := nil;
Result += 'wav';
{$IFDEF USE_MPG123}
if DllManager.Suppored('mpg123') then
	Result += 'mp3';
{$ENDIF}
{$IFDEF USE_OGG}
if DllManager.Suppored('ogg') then
	Result += 'ogg';
{$ENDIF}
end;

{$IFDEF USE_MPG123}
destructor TSGOpenALMP123FilePlayer.Destroy();
begin
alSourceStop(FSource);
alDeleteSources(1, @FSource);
alDeleteBuffers(2, @FBuffers[0]);
mpg123_close(FMPGHandle);
mpg123_delete(FMPGHandle);
inherited;
end;

procedure TSGOpenALMP123FilePlayer.Execute();
var
	CriticalSection : TCriticalSection = nil;
	TrySusc : TSGBool;
begin
CriticalSection := TCriticalSection.Create();
while FPlaying do
	begin
	TrySusc := False;
	CriticalSection.Acquire();
	try
	if not UpdateBuffer() then
		FPlaying := False;
	TrySusc := True;
	finally
	if not TrySusc then
		FPlaying := False;
	CriticalSection.Release();
	end;
	if FPlaying then
		Sleep(50);
	end;
CriticalSection.Destroy();
end;

constructor TSGOpenALMP123FilePlayer.Create(const FilePath: TSGString);

function StrMPG123Encoding(const VEncoding : integer) : TSGString;
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

begin
inherited Create(nil, nil, False);
FFileName := FilePath;
FMaxBufferSize := 4096*8;

if GetMPG123AudioDecoder() = nil then
	begin
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Error while determine decoder!');
	Exit;
	end
else
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Decoder is ''' + SGPCharToString(GetMPG123AudioDecoder()) + '''.');

FMPGHandle := mpg123_new(GetMPG123AudioDecoder(), nil);
if FMPGHandle = nil then
	begin
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Error while creating MP3 handle!');
	Exit;
	end;

mpg123_open(FMPGHandle, PChar(FFileName));
mpg123_getformat(FMPGHandle, @FRate, @FChannels, @FEncoding);
mpg123_format_none(FMPGHandle);
mpg123_format(FMPGHandle, FRate, FChannels, FEncoding);
SGLog.Sourse('TSGOpenALMP123FilePlayer : File=''' + FilePath + ''', Encoding=''' + SGStr(FEncoding) + ''' is ''' + StrMPG123Encoding(FEncoding) + ''', Rate=''' + SGStr(FRate) + ''', Channels=''' + SGStr(FChannels) + '''.');

FFormat := 0;
case FEncoding of
MPG123_ENC_16, MPG123_ENC_SIGNED_16, MPG123_ENC_UNSIGNED_16 :
	if FChannels = MPG123_MONO then
		FFormat := AL_FORMAT_MONO16
	else if FChannels = MPG123_STEREO then
		FFormat := AL_FORMAT_STEREO16;
MPG123_ENC_8, MPG123_ENC_SIGNED_8, MPG123_ENC_UNSIGNED_8, MPG123_ENC_ULAW_8, MPG123_ENC_ALAW_8 :
	if FChannels = MPG123_MONO then
		FFormat := AL_FORMAT_MONO8
	else if FChannels = MPG123_STEREO then
		FFormat := AL_FORMAT_STEREO8;
end;
if FFormat = 0 then
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Unknown encoding - ''' + SGStr(FEncoding) + ''' is ''' + StrMPG123Encoding(FEncoding) + '''!')
else
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Format : ''' + StrMPG123Encoding(FEncoding) + ''' --> ''' + SGOpenALStrFormat(FFormat) + '''.');

alGenBuffers(2, @FBuffers[0]);
alGenSources(1, @FSource);
alSource3f(FSource, AL_POSITION, 0, 0, 0);
alSource3f(FSource, AL_VELOCITY, 0, 0, 0);
alSource3f(FSource, AL_DIRECTION, 0, 0, 0);
alSourcef (FSource, AL_ROLLOFF_FACTOR, 0);
alSourcei (FSource, AL_SOURCE_RELATIVE, AL_TRUE);

SGLog.Sourse('TSGOpenALMP123FilePlayer : Created.');
end;

function TSGOpenALMP123FilePlayer.UpdateBuffer() : TSGBool;
var
	Processed : TALint;
	Buffer    : TSGALBuffer;
	BufferLength : TSGUInt64;
begin
Result := False;
alGetSourcei(FSource, AL_BUFFERS_PROCESSED, @Processed);
if Processed > 0 then
	repeat
	alSourceUnqueueBuffers(FSource, 1, @Buffer);
	BufferLength := Stream(Buffer);
	if BufferLength <> 0 then
		begin
		alSourceQueueBuffers(FSource, 1, @Buffer);
		Result := True;
		end
	else
		break;
	dec(Processed);
	until Processed <= 0
else
	Result := True;
end;

function TSGOpenALMP123FilePlayer.PreBuffer() : TSGUInt64;
begin
Result := 0;
try
Result += Stream(FBuffers[0]);
Result += Stream(FBuffers[1]);
except
Result := 0;
FPlaying := False;
SGLog.Sourse('TSGOpenALMP123FilePlayer : Exception while prebuffering!');
end;
if Result > 0 then
	alSourceQueueBuffers(FSource, 2, @FBuffers[0]);
end;

function TSGOpenALMP123FilePlayer.Stream(const VBuffer : TSGALBuffer) : TSGUInt64;
var
	Data : PByte;
	DataLength : Cardinal;
	ExceptionBe : TSGBool = False;
begin
GetMem(data, FMaxBufferSize);
DataLength := FMaxBufferSize;
try
	mpg123_read(FMPGHandle, Data, FMaxBufferSize, @DataLength);
except
	ExceptionBe := True;
	DataLength := 0;
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Error while decoding! DataLength=''' + SGStr(DataLength) + '''.')
end;
if not ExceptionBe then
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Decoded data, Length=''' + SGStr(DataLength) + '''.');
if DataLength <> 0 then
	alBufferData(VBuffer, FFormat, Data, DataLength, FRate);
FreeMem(Data);
Result := DataLength;
end;

procedure TSGOpenALMP123FilePlayer.Play();
var
	DoneBufferingSize : TSGUInt64;
begin
FPlaying := True;
DoneBufferingSize := PreBuffer();
if FPlaying then
	Start();
if DoneBufferingSize > 0 then
	alSourcePlay(FSource);
end;

procedure TSGOpenALMP123FilePlayer.Stop();
begin
FPlaying := False;
alSourceStop(FSource);
end;
{$ENDIF}

procedure TSGAudioRenderOpenAL.Init();
var
	ListenerPos: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerVel: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerOri: array [0..5] of TALfloat= ( 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);

{$IFDEF USE_MPG123}
procedure _MPG123Initialize();
var
	SD : PPChar;
	i : TSGUInt32;
	Decoders : TSGString = '';
begin
if not FMPG123Initialized then
	begin
	FMPG123Initialized := mpg123_init() = 0;
	SGLog.Sourse('TSGAudioRenderOpenAL : MPG123 : ' + Iff(FMPG123Initialized, 'Initialized.', 'Initialization fail.'));
	if FMPG123Initialized then
		begin
		SD := mpg123_supported_decoders();
		i := 0;
		while SD[i] <> nil do
			begin
			if i <> 0 then
				Decoders += ', ';
			Decoders += SGPCharToString(SD[i]);
			i += 1;
			end;
		SGLog.Sourse('TSGAudioRenderOpenAL : MPG123 : Supored decoders - ' + Decoders + '.');
		end;
	end;
end;
{$ENDIF}

begin
if DllManager.Dll('OpenAL') <> nil then
	DllManager.Dll('OpenAL').ReadExtensions();

{$IFDEF USE_MPG123}
_MPG123Initialize();
{$ENDIF}

alListenerfv(AL_POSITION,    @ListenerPos);
alListenerfv(AL_VELOCITY,    @ListenerVel);
alListenerfv(AL_ORIENTATION, @ListenerOri);
end;

function TSGAudioRenderOpenAL.CreateDevice() : TSGBool;
begin
Result := False;
if not FALUTSuppored then
	int_alutInit()
else
	ext_alutInit(nil, nil);

FContext := alcGetCurrentContext();
if FContext <> nil then
	FDevice := alcGetContextsDevice(FContext);

Result := (FContext <> nil) and (FDevice <> nil);

SGLog.Sourse('TSGAudioRenderOpenAL : Context = ' + SGAddrStr(FContext) + ', Device = ' + SGAddrStr(FDevice) + '.');
end;

procedure TSGAudioRenderOpenAL.Kill();
begin
{$IFDEF USE_MPG123}
if FMPG123Initialized then
	begin
	mpg123_exit();
	FMPG123Initialized := False;
	end;
{$ENDIF}
if not FALUTSuppored then
	int_alutExit()
else
	ext_alutExit();
FContext := nil;
FDevice := nil;
inherited;
end;

constructor TSGAudioRenderOpenAL.Create();
begin
inherited;
FALUTSuppored := DllManager.Suppored('alut');
FContext := nil;
FDevice := nil;
{$IFDEF USE_MPG123}
FMPG123Suppored := DllManager.Suppored('mpg123');
FMPG123Initialized := False;
{$ENDIF}
end;

class function TSGAudioRenderOpenAL.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderOpenAL';
end;

class function TSGAudioRenderOpenAL.Suppored() : TSGBool;
begin
Result := DllManager.Suppored('OpenAL');
end;

end.
