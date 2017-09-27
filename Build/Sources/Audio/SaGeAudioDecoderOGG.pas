{$INCLUDE SaGe.inc}

unit SaGeAudioDecoderOGG;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioDecoder
	
	,Classes
	
	,Ogg
	,Codec
	,CommentUtils
	,OSTypes
	,VCEdit
	,VorbisEnc
	,VorbisFile
	;

type
	TSGAudioDecoderOGG = class(TSGAudioDecoder)
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
		procedure AttachInput(const VStream : TStream);
		procedure LogFileInfo();
			private
		FDataPosition : TSGUInt64;
		FDataSize     : TSGUInt64;
		FPosition     : TSGUInt64;
			private
		FInputStream   : TStream;
		FFile          : OGGVorbis_File;
		FVorbisInfo    : Vorbis_Info;
		FVorbisComment : Vorbis_Comment;
			public
		class function ErrorString(Code : Integer) : String;
		end;

implementation

uses
	 SysUtils
	
	,SaGeStringUtils
	,SaGeDllManager
	,SaGeLog
	;

class function TSGAudioDecoderOGG.ErrorString(Code : Integer) : String;
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

class function TSGAudioDecoderOGG.SupporedFormats() : TSGStringList;
begin
Result := nil;
Result += 'OGG';
end;

class function TSGAudioDecoderOGG.Suppored() : TSGBool;
begin
Result := DllManager.Suppored('Ogg');
if Result then
	Result := DllManager.Suppored('Vorbis');
(*
if Result then Result := DllManager.Suppored('VorbisEnc'); // Vorbis Encoder
*)
if Result then
	Result := DllManager.Suppored('VorbisFile');
end;

procedure TSGAudioDecoderOGG.LogFileInfo();
begin
with FVorbisInfo do
	begin
	SGLog.Source('TSGAudioDecoderOGG.File Version         = '+SGStr(Version));
	SGLog.Source('TSGAudioDecoderOGG.File Channels        = '+SGStr(Channels));
	SGLog.Source('TSGAudioDecoderOGG.File Rate (hz)       = '+SGStr(Rate));
	SGLog.Source('TSGAudioDecoderOGG.File Bitrate upper   = '+SGStr(bitrate_upper));
	SGLog.Source('TSGAudioDecoderOGG.File Bitrate nominal = '+SGStr(bitrate_nominal));
	SGLog.Source('TSGAudioDecoderOGG.File Bitrate lower   = '+SGStr(bitrate_lower));
	SGLog.Source('TSGAudioDecoderOGG.File Bitrate window  = '+SGStr(bitrate_window));
	SGLog.Source('TSGAudioDecoderOGG.File Vendor          = '+SGPCharToString(FVorbisComment.Vendor));
	end;
end;

procedure TSGAudioDecoderOGG.AttachInput(const VStream : TStream);
begin
KillInput();
FInputStream := VStream;
end;

function TSGAudioDecoderOGG.SetInput(const VStream : TStream): TSGAudioDecoder; overload;
begin
AttachInput(VStream);
Result := Self;
end;

function TSGAudioDecoderOGG.SetInput(const VFileName : TSGString) : TSGAudioDecoder; overload;
begin
AttachInput(CreateInputStream(VFileName));
Result := Self;
end;

procedure TSGAudioDecoderOGG.ReadInfo();
var
	Res : integer;
begin
if FInfoReaded then
	exit;

Res := ov_open_callbacks(FInputStream, FFile, nil, 0, ops_callbacks);
if Res <> 0 then
	begin
	SGLog.Source('TSGAudioDecoderOGG.AttachInput : Could not open Ogg stream. ['+ErrorString(Res)+']');
	exit;
	end;
FVorbisInfo    := ov_info(FFile, -1)^;
FVorbisComment := ov_comment(FFile, -1)^;

with FVorbisInfo do
	begin
	FInfo.FBitsPerSample := 16;
	FInfo.FChannels      := Channels;
	FInfo.FFrequency     := Rate;
	end;

LogFileInfo();

FInfoReaded := True;
end;

function TSGAudioDecoderOGG.Read(var VData; const VBufferSize : TSGUInt64) : TSGUInt64;
var
	Section : Integer;
	Res     : Integer;
	ToExit  : TSGBool = False;
begin
Result := 0;
repeat
Res := ov_read(FFile, VData, Result, 0, 2, 1, @Section);
if Res > 0 then
	Result += Res
else if Res < 0 then
	begin
	SGLog.Source('TSGAudioDecoderOGG.Read : Error! [' + ErrorString(Res) + ']');
	Result := 0;
	end
else
	ToExit := True;
until (Result >= VBufferSize) or ToExit;

if (Result > VBufferSize) then
	SGLog.Source('TSGAudioDecoderOGG.Read : Hint Readed data > Buffer size!');
end;

function TSGAudioDecoderOGG.GetSize() : TSGUInt64;
begin
Result := FDataSize;
end;

procedure TSGAudioDecoderOGG.SetPosition(const VPosition : TSGUInt64);
begin
end;

function TSGAudioDecoderOGG.GetPosition() : TSGUInt64;
begin
Result := FDataPosition;
end;

constructor TSGAudioDecoderOGG.Create();
begin
inherited;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FInputStream := nil;
FillChar(FFile, SizeOf(FFile), 0);
FillChar(FVorbisComment, SizeOf(FVorbisComment), 0);
FillChar(FVorbisInfo, SizeOf(FVorbisInfo), 0);
end;

procedure TSGAudioDecoderOGG.KillInput();
begin
//ov_clear(FFile);
if FInputStream <> nil then
	begin
	FInputStream.Destroy();
	FInputStream := nil;
	end;
FDataPosition := 0;
FDataSize := 0;
FPosition := 0;
FillChar(FFile, SizeOf(FFile), 0);
FillChar(FVorbisComment, SizeOf(FVorbisComment), 0);
FillChar(FVorbisInfo, SizeOf(FVorbisInfo), 0);
end;

destructor TSGAudioDecoderOGG.Destroy();
begin
KillInput();
inherited;
end;

class function TSGAudioDecoderOGG.ClassName() : TSGString;
begin
Result := 'TSGAudioDecoderOGG';
end;

initialization
	SGAddDecoder(TSGAudioDecoderOGG);

end.
