{$INCLUDE SaGe.inc}

//{$DEFINE OPENAL_RENDER_DEBUG}

unit SaGeAudioRenderOpenAL;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioRender

	,OpenAL
	;

type
	TSGAudioRenderOpenAL = class(TSGAudioRender)
			public
		constructor Create(); override;
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
			private
		FALUTSuppored : TSGBool;
		FContext      : PALCcontext;
		FDevice       : PALCdevice;
			public
		procedure Init(); override;
		function CreateDevice() : TSGBool; override;
		procedure Kill(); override;
		end;

implementation

uses
	SaGeDllManager
	;

procedure TSGAudioRenderOpenAL.Init();
var
	ListenerPos: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerVel: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerOri: array [0..5] of TALfloat= ( 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
begin
if DllManager.Dll('OpenAL') <> nil then
	DllManager.Dll('OpenAL').ReadExtensions();

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
