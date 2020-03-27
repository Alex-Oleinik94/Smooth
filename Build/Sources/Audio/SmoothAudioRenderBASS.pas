{$INCLUDE Smooth.inc}

//{$DEFINE BASS_RENDER_DEBUG}

unit SmoothAudioRenderBASS;

interface

uses
	// Engine
	 SmoothBase
	,SmoothBaseClasses
	,SmoothAudioRender
	,SmoothAudioDecoder
	,SmoothCommonStructs
	
	// System
	,Classes
	,SysUtils
	,SyncObjs
	
	// Audio Library
	,bass
	;

type
	TSBASSSource = byte;
	
	TSBASSCustomSource = class(TSAudioRenderObject, ISAudioSource)
			public
		constructor Create(const VAudioRender : TSAudioRender); override;
		destructor Destroy(); override;
			protected
		FSource : TSBASSSource;
			public
		property Source : TSBASSSource read FSource;
			public
		class function ClassName() : TSString; override;
			public
		procedure SetPosition(const VPosition : TSVector3f); virtual;
		function  GetPosition() : TSVector3f; virtual;
		procedure SetDirection(const VDirection : TSVector3f); virtual;
		function  GetDirection() : TSVector3f; virtual;
		procedure SetVelocity(const VVelocity : TSVector3f); virtual;
		function  GetVelocity() : TSVector3f; virtual;
		procedure SetLooping(const VLooping : TSBool); virtual;
		function  GetLooping() : TSBool; virtual;
		procedure SetRelative(const VRelative : TSBool); virtual;
		function GetRelative() : TSBool; virtual;
		procedure Play(); virtual;
		function Playing() : TSBool; virtual;
		procedure Pause(); virtual;
		function Paused() : TSBool; virtual;
		procedure Stop(); virtual;
		function Stoped : TSBool; virtual;
		end;

	TSBASSBufferedSource = class(TSAudioBufferedSource)
			public
		constructor Create(const VAudioRender : TSAudioRender); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			private
		FCustomSource : TSBASSCustomSource;
			protected
		function GetSource() : ISAudioSource; override;
		function CountProcessedBuffers() : TSUInt32; override;
		procedure DataProcessedBuffer(var Data; const VDataLength : TSUInt64); override;
		procedure PreBuffer(); override;
		end;

	TSAudioRenderBASS = class(TSAudioRender)
			public
		constructor Create(); override;
		class function Supported() : TSBool; override;
		class function ClassName() : TSString; override;
		class function AudioRenderName() : TSString; override;
			private
		
			public
		procedure Init(); override;
		function CreateDevice() : TSBool; override;
		procedure Kill(); override;
		function CreateBufferedSource() : TSAudioBufferedSource; override;
		end;

implementation

uses
	SmoothDllManager
	;

constructor TSBASSBufferedSource.Create(const VAudioRender : TSAudioRender);
begin
inherited Create(VAudioRender);
FCustomSource := TSBASSCustomSource.Create(VAudioRender);

end;

destructor TSBASSBufferedSource.Destroy();
begin
FCustomSource.Destroy();
inherited;
end;

class function TSBASSBufferedSource.ClassName() : TSString;
begin
Result := 'TSBASSBufferedSource';
end;

function TSBASSBufferedSource.GetSource() : ISAudioSource;
begin
Result := FCustomSource;
end;

function TSBASSBufferedSource.CountProcessedBuffers() : TSUInt32;
begin

end;

procedure TSBASSBufferedSource.DataProcessedBuffer(var Data; const VDataLength : TSUInt64);
begin

end;

procedure TSBASSBufferedSource.PreBuffer();
begin

end;

constructor TSBASSCustomSource.Create(const VAudioRender : TSAudioRender);
begin
inherited Create(VAudioRender);

end;

destructor TSBASSCustomSource.Destroy();
begin

inherited;
end;

class function TSBASSCustomSource.ClassName() : TSString;
begin
Result := 'TSBASSCustomSource';
end;

procedure TSBASSCustomSource.SetPosition(const VPosition : TSVector3f);
begin

end;

function  TSBASSCustomSource.GetPosition() : TSVector3f;
begin

end;

procedure TSBASSCustomSource.SetDirection(const VDirection : TSVector3f);
begin

end;

function  TSBASSCustomSource.GetDirection() : TSVector3f;
begin

end;

procedure TSBASSCustomSource.SetVelocity(const VVelocity : TSVector3f);
begin

end;

function  TSBASSCustomSource.GetVelocity() : TSVector3f;
begin

end;

procedure TSBASSCustomSource.SetLooping(const VLooping : TSBool);
begin

end;

function  TSBASSCustomSource.GetLooping() : TSBool;
begin

end;

procedure TSBASSCustomSource.SetRelative(const VRelative : TSBool);
begin

end;

function TSBASSCustomSource.GetRelative() : TSBool;
begin

end;

procedure TSBASSCustomSource.Play();
begin

end;

function TSBASSCustomSource.Playing() : TSBool;
begin

end;

procedure TSBASSCustomSource.Pause();
begin

end;

function TSBASSCustomSource.Paused() : TSBool;
begin

end;

procedure TSBASSCustomSource.Stop();
begin

end;

function TSBASSCustomSource.Stoped : TSBool;
begin

end;

function TSAudioRenderBASS.CreateBufferedSource() : TSAudioBufferedSource;
begin
Result := TSBASSBufferedSource.Create(Self);
end;

procedure TSAudioRenderBASS.Init();
begin

end;

function TSAudioRenderBASS.CreateDevice() : TSBool;
begin

end;

procedure TSAudioRenderBASS.Kill();
begin

inherited;
end;

constructor TSAudioRenderBASS.Create();
begin
inherited;

end;

class function TSAudioRenderBASS.AudioRenderName() : TSString;
begin
Result := 'Bass';
end;

class function TSAudioRenderBASS.ClassName() : TSString;
begin
Result := 'TSAudioRenderBASS';
end;

class function TSAudioRenderBASS.Supported() : TSBool;
begin
//Result := DllManager.Supported('BASS');
Result := False;
end;

end.
