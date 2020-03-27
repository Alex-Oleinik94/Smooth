unit Alut;

{$IFDEF FPC}
	{$MODE Delphi}
	{$ENDIF}

interface

uses
	Classes
	,SysUtils
	{$IFDEF MSWINDOWS}
		,Windows
		{$ENDIF}
	,OpenAL
	,SmoothAudioDecoderWAV
	;

var
  //External Alut functions (from dll or so)
  ext_alutInit: procedure(argc: PALint; argv: PPALbyte); cdecl;
  ext_alutExit: procedure; cdecl;

  ext_alutLoadWAVFile: procedure(fname: string; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint); cdecl;
  ext_alutLoadWAVMemory: procedure(memory: PALbyte; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint); cdecl;
  ext_alutUnloadWAV: procedure(format: TALenum; data: TALvoid; size: TALsizei; freq: TALsizei); cdecl;

  //Internal Alut functions
  procedure int_alutInit();
  procedure int_alutExit;

  procedure int_alutLoadWAVFile(fname: string; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint);
  procedure int_alutLoadWAVMemory(memory: PALbyte; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint);
  procedure int_alutUnloadWAV(format: TALenum; data: TALvoid; size: TALsizei; freq: TALsizei);
  function int_LoadWavStream(Stream: Tstream; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint): Boolean; //Unofficial

implementation

uses
	 SmoothBase
	,SmoothLists
	,SmoothDllManager
	,SmoothStringUtils
	,SmoothSysUtils
	;

//Internal Alut replacement procedures

procedure int_alutInit();
var
  Context: PALCcontext;
  Device: PALCdevice;
begin
  //Open device
  Device := alcOpenDevice(nil); // this is supposed to select the "preferred device"
  //Create context(s)
  Context := alcCreateContext(Device, nil);
  //Set active context
  alcMakeContextCurrent(Context);
end;

procedure int_alutExit;
var
  Context: PALCcontext;
  Device: PALCdevice;
begin
  //Get active context
  Context := alcGetCurrentContext;
  //Get device for active context
  Device := alcGetContextsDevice(Context);
  //Release context(s)
  alcDestroyContext(Context);
  //Close device
  alcCloseDevice(Device);
end;

function int_LoadWavStream(Stream: Tstream; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint): Boolean;
var
  WavHeader: TWavHeader;
  readname: pansichar;
  name: ansistring;
  readint: integer;
begin
    Result:=False;

    //Read wav header
    stream.Read(WavHeader, sizeof(TWavHeader));

    //Determine SampleRate
    freq:=WavHeader.SampleRate;

    //Detemine waveformat
    if WavHeader.ChannelNumber = 1 then
    case WavHeader.BitsPerSample of
    8: format := AL_FORMAT_MONO8;
    16: format := AL_FORMAT_MONO16;
    end;

    if WavHeader.ChannelNumber = 2 then
    case WavHeader.BitsPerSample of
    8: format := AL_FORMAT_STEREO8;
    16: format := AL_FORMAT_STEREO16;
    end;

    //go to end of wavheader
    stream.seek((8-44)+12+4+WavHeader.FormatHeaderSize+4,soFromCurrent); //hmm crappy...

    //loop to rest of wave file data chunks
    repeat
      //read chunk name
      getmem(readname,4);
      stream.Read(readname^, 4);
      name:=readname[0]+readname[1]+readname[2]+readname[3];
      if name='data' then
      begin
        //Get the size of the wave data
        stream.Read(readint,4);
        size:=readint;
        //if WavHeader.BitsPerSample = 8 then size:=size+1; //fix for 8bit???
        //Read the actual wave data
        getmem(data,size);
        stream.Read(Data^, size);

        //Decode wave data if needed
        if WavHeader.FormatCode=WAV_IMA_ADPCM then
        begin
          //TODO: add code to decompress IMA ADPCM data
        end;
        if WavHeader.FormatCode=WAV_MP3 then
        begin
          //TODO: add code to decompress MP3 data
        end;
        Result:=True;
      end
      else
      begin
        //Skip unknown chunk(s)
        stream.Read(readint,4);
        stream.Position:=stream.Position+readint;
      end;
    until stream.Position>=stream.size;

end;

procedure int_alutLoadWAVFile(fname: string; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint);
var
  Stream : TFileStream;
begin
  Stream:=TFileStream.Create(fname,$0000);
  int_LoadWavStream(Stream, format, data, size, freq, loop);
  Stream.Free;
end;

procedure int_alutLoadWAVMemory(memory: PALbyte; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint);
var Stream: TMemoryStream;
begin
  Stream:=TMemoryStream.Create;
  Stream.Write(memory,sizeof(memory^));
  int_LoadWavStream(Stream, format, data, size, freq, loop);
  Stream.Free;
end;

procedure int_alutUnloadWAV(format: TALenum; data: TALvoid; size: TALsizei; freq: TALsizei);
begin
  //Clean up
  if data<>nil then freemem(data);
end;

// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= Smooth DLL IMPLEMENTATION =*=*=
// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSDllAlut = class(TSDll)
			public
		class function SystemNames() : TSStringList; override;
		class function DllNames() : TSStringList; override;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;
		class procedure Free(); override;
		end;

class function TSDllAlut.SystemNames() : TSStringList;
begin
Result := 'ALUT';
Result += 'LibAlut';
end;

class function TSDllAlut.DllNames() : TSStringList;
begin
Result := nil;
{$IFDEF MSWINDOWS}
Result += 'Alut.dll';
Result += 'Alut32.dll';
{$ELSE}
Result += 'libalut.so.3';
Result += 'libalut.so.2';
Result += 'libalut.so.1';
Result += 'libalut.so.0';
Result += 'libalut.so';
{$ENDIF}
end;

class function TSDllAlut.Load(const VDll : TSLibHandle) : TSDllLoadObject;
var
	LoadResult : PSDllLoadObject = nil;

function LoadProcedure(const Name : PChar) : Pointer;
begin
Result := GetProcAddress(VDll, Name);
if Result = nil then
	LoadResult^.FFunctionErrors += SPCharToString(Name)
else
	LoadResult^.FFunctionLoaded += 1;
LoadResult^.FFunctionCount += 1;
end;

begin
Result.Clear();
LoadResult := @Result;
ext_alutInit:= LoadProcedure('alutInit');
ext_alutExit:= LoadProcedure('alutExit');
ext_alutLoadWAVFile:= LoadProcedure('alutLoadWAVFile');
ext_alutLoadWAVMemory:= LoadProcedure('alutLoadWAVMemory');
ext_alutUnloadWAV:= LoadProcedure('alutUnloadWAV');
end;

class procedure TSDllAlut.Free();
begin
ext_alutInit := nil;
ext_alutExit := nil;
ext_alutLoadWAVFile := nil;
ext_alutLoadWAVMemory := nil;
ext_alutUnloadWAV := nil;
end;

initialization
begin
TSDllAlut.Create();
end;

end.
