{$INCLUDE Smooth.inc}

unit SmoothAudioDecoderOGG;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothCommon
	,SmoothAudioDecoder
	,SmoothLists
	
	,Classes
	
	,Ogg
	,Codec
	,CommentUtils
	,OSTypes
	,VCEdit
	,VorbisEnc
	,VorbisFile
	//,OggStatic
	;

type
	TSAudioDecoderOGG = class(TSAudioDecoder)
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
		procedure AttachInput(const VStream : TStream);
		procedure LogFileInfo();
			private
		FDataPosition : TSUInt64;
		FDataSize     : TSUInt64;
		FPosition     : TSUInt64;
		FError        : TSBool;
			private
		FInputStream   : TStream;
		FInputMemoryStream : TMemoryStream;
		FFile          : OGGVorbis_File;
		FVorbisInfo    : Vorbis_Info;
		FVorbisComment : Vorbis_Comment;
			public
		class function ErrorString(Code : Integer) : String;
		end;

implementation

uses
	 SysUtils
	
	,SmoothStringUtils
	,SmoothDllManager
	,SmoothLog
	,SmoothAudioDecoderOGGCommon
	;

class function TSAudioDecoderOGG.ErrorString(Code : Integer) : String;
begin
case Code of
 OV_EREAD      : Result := 'Read from Media.';
 OV_ENOTVORBIS : Result := 'Not Vorbis data.';
 OV_EVERSION   : Result := 'Vorbis version mismatch.';
 OV_EBADHEADER : Result := 'Invalid Vorbis header.';
 OV_EFAULT     : Result := 'nternal logic fault (bug or heap/stack corruption.';
else
 Result := 'Unknown Ogg error.';
end;
end;

class function TSAudioDecoderOGG.SupportedFormats() : TSStringList;
begin
Result := nil;
Result += 'OGG';
end;

class function TSAudioDecoderOGG.Supported() : TSBool;
begin
Result := DllManager.Supported('Ogg');
if Result then
	Result := DllManager.Supported('Vorbis');
(*
if Result then Result := DllManager.Supported('VorbisEnc'); // Vorbis Encoder
*)
if Result then
	Result := DllManager.Supported('VorbisFile');
end;

procedure TSAudioDecoderOGG.LogFileInfo();
begin
with FVorbisInfo do
	begin
	SLog.Source('TSAudioDecoderOGG.File Version         = '+SStr(Version));
	SLog.Source('TSAudioDecoderOGG.File Channels        = '+SStr(Channels));
	SLog.Source('TSAudioDecoderOGG.File Rate (hz)       = '+SStr(Rate));
	SLog.Source('TSAudioDecoderOGG.File Bitrate upper   = '+SStr(bitrate_upper));
	SLog.Source('TSAudioDecoderOGG.File Bitrate nominal = '+SStr(bitrate_nominal));
	SLog.Source('TSAudioDecoderOGG.File Bitrate lower   = '+SStr(bitrate_lower));
	SLog.Source('TSAudioDecoderOGG.File Bitrate window  = '+SStr(bitrate_window));
	SLog.Source('TSAudioDecoderOGG.File Vendor          = '+SPCharToString(FVorbisComment.Vendor));
	end;
end;

procedure TSAudioDecoderOGG.AttachInput(const VStream : TStream);
begin
KillInput();
FInputStream := VStream;
FInputMemoryStream := VStream as TMemoryStream;
end;

function TSAudioDecoderOGG.SetInput(const VStream : TStream): TSAudioDecoder; overload;
begin
AttachInput(VStream);
Result := Self;
end;

function TSAudioDecoderOGG.SetInput(const VFileName : TSString) : TSAudioDecoder; overload;
begin
AttachInput(CreateInputMemoryStream(VFileName));
Result := Self;
end;

procedure TSAudioDecoderOGG.ReadInfo();
var
	Res : integer;
begin
if FInfoReaded then
	exit;

ov_clear(FFile);

FInputStream.Position := 0;
Res := ov_test_callbacks(FInputStream, FFile, nil, 0, ops_callbacks);
if Res <> 0 then
	begin
	SLog.Source('TSAudioDecoderOGG__ReadInfo : Test callbacks finded error : "'+ErrorString(Res)+'".');
	FError := True;
	end;

FInputStream.Position := 0;
Res := ov_test_open(FFile);
if Res <> 0 then
	begin
	SLog.Source('TSAudioDecoderOGG__ReadInfo : Test open finded error : "'+ErrorString(Res)+'".');
	FError := True;
	end;

FInputStream.Position := 0;
Res := ov_open_callbacks(FInputStream, FFile, nil, 0, ops_callbacks);//ops_callbacks
if Res <> 0 then
	begin
	SLog.Source('TSAudioDecoderOGG__ReadInfo : Could not open Ogg stream : "'+ErrorString(Res)+'".');
	FError := True;
	end;

if not FError then
	begin
	FVorbisInfo    := ov_info(FFile, -1)^;
	FVorbisComment := ov_comment(FFile, -1)^;
	
	FInfo.FBitsPerSample := 16;
	FInfo.FChannels      := FVorbisInfo.Channels;
	FInfo.FFrequency     := FVorbisInfo.Rate;
	
	LogFileInfo();
	end;

FError      := FError or (FVorbisInfo.Channels = 0) or (FVorbisInfo.Rate = 0);
FInfoReaded := not FError;
end;

function TSAudioDecoderOGG.Read(var VData; const VBufferSize : TSUInt64) : TSUInt64;
var
	Section : Integer;
	Res     : Integer;
	ToExit  : TSBool = False;
begin
Result := 0;
if FError then
	exit;
repeat
Res := ov_read(FFile, VData, Result, 0, 2, 1, @Section);
if Res > 0 then
	Result += Res
else if Res < 0 then
	begin
	SLog.Source('TSAudioDecoderOGG__Read : Error! [' + ErrorString(Res) + ']');
	Result := 0;
	end
else
	ToExit := True;
until (Result >= VBufferSize) or ToExit;

if (Result > VBufferSize) then
	SLog.Source('TSAudioDecoderOGG__Read : Hint Readed data > Buffer size!');
end;

function TSAudioDecoderOGG.GetSize() : TSUInt64;
begin
Result := FDataSize;
end;

procedure TSAudioDecoderOGG.SetPosition(const VPosition : TSUInt64);
begin
end;

function TSAudioDecoderOGG.GetPosition() : TSUInt64;
begin
Result := FDataPosition;
end;

constructor TSAudioDecoderOGG.Create();
begin
inherited;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FError := False;
FInputStream := nil;
FillChar(FFile, SizeOf(FFile), 0);
FillChar(FVorbisComment, SizeOf(FVorbisComment), 0);
FillChar(FVorbisInfo, SizeOf(FVorbisInfo), 0);
end;

procedure TSAudioDecoderOGG.KillInput();
begin
//ov_clear(FFile);
SLog.SOurce([TSPointer(FInputStream)]);
try
if FInputStream <> nil then
	begin
	FInputStream.Destroy();
	FInputStream := nil;
	end;
except
end;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FillChar(FFile, SizeOf(FFile), 0);
FillChar(FVorbisComment, SizeOf(FVorbisComment), 0);
FillChar(FVorbisInfo, SizeOf(FVorbisInfo), 0);
end;

destructor TSAudioDecoderOGG.Destroy();
begin
KillInput();
inherited;
end;

class function TSAudioDecoderOGG.ClassName() : TSString;
begin
Result := 'TSAudioDecoderOGG';
end;

initialization
	SAddDecoder(TSAudioDecoderOGG);

end.
