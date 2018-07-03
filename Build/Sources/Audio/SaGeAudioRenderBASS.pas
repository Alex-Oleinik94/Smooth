{$INCLUDE SaGe.inc}

//{$DEFINE BASS_RENDER_DEBUG}

unit SaGeAudioRenderBASS;

interface

uses
	// Engine
	 SaGeBase
	,SaGeClasses
	,SaGeAudioRender
	,SaGeAudioDecoder
	,SaGeCommonStructs
	
	// System
	,Classes
	,SysUtils
	,SyncObjs
	
	// Audio Library
	,bass
	;

type
	TSGBASSSource = byte;
	
	TSGBASSCustomSource = class(TSGAudioRenderObject, ISGAudioSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		destructor Destroy(); override;
			protected
		FSource : TSGBASSSource;
			public
		property Source : TSGBASSSource read FSource;
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

	TSGBASSBufferedSource = class(TSGAudioBufferedSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FCustomSource : TSGBASSCustomSource;
			protected
		function GetSource() : ISGAudioSource; override;
		function CountProcessedBuffers() : TSGUInt32; override;
		procedure DataProcessedBuffer(var Data; const VDataLength : TSGUInt64); override;
		procedure PreBuffer(); override;
		end;

	TSGAudioRenderBASS = class(TSGAudioRender)
			public
		constructor Create(); override;
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
		class function AudioRenderName() : TSGString; override;
			private
		
			public
		procedure Init(); override;
		function CreateDevice() : TSGBool; override;
		procedure Kill(); override;
		function CreateBufferedSource() : TSGAudioBufferedSource; override;
		end;

implementation

uses
	SaGeDllManager
	;

constructor TSGBASSBufferedSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
FCustomSource := TSGBASSCustomSource.Create(VAudioRender);

end;

destructor TSGBASSBufferedSource.Destroy();
begin
FCustomSource.Destroy();
inherited;
end;

class function TSGBASSBufferedSource.ClassName() : TSGString;
begin
Result := 'TSGBASSBufferedSource';
end;

function TSGBASSBufferedSource.GetSource() : ISGAudioSource;
begin
Result := FCustomSource;
end;

function TSGBASSBufferedSource.CountProcessedBuffers() : TSGUInt32;
begin

end;

procedure TSGBASSBufferedSource.DataProcessedBuffer(var Data; const VDataLength : TSGUInt64);
begin

end;

procedure TSGBASSBufferedSource.PreBuffer();
begin

end;

constructor TSGBASSCustomSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);

end;

destructor TSGBASSCustomSource.Destroy();
begin

inherited;
end;

class function TSGBASSCustomSource.ClassName() : TSGString;
begin
Result := 'TSGBASSCustomSource';
end;

procedure TSGBASSCustomSource.SetPosition(const VPosition : TSGVector3f);
begin

end;

function  TSGBASSCustomSource.GetPosition() : TSGVector3f;
begin

end;

procedure TSGBASSCustomSource.SetDirection(const VDirection : TSGVector3f);
begin

end;

function  TSGBASSCustomSource.GetDirection() : TSGVector3f;
begin

end;

procedure TSGBASSCustomSource.SetVelocity(const VVelocity : TSGVector3f);
begin

end;

function  TSGBASSCustomSource.GetVelocity() : TSGVector3f;
begin

end;

procedure TSGBASSCustomSource.SetLooping(const VLooping : TSGBool);
begin

end;

function  TSGBASSCustomSource.GetLooping() : TSGBool;
begin

end;

procedure TSGBASSCustomSource.SetRelative(const VRelative : TSGBool);
begin

end;

function TSGBASSCustomSource.GetRelative() : TSGBool;
begin

end;

procedure TSGBASSCustomSource.Play();
begin

end;

function TSGBASSCustomSource.Playing() : TSGBool;
begin

end;

procedure TSGBASSCustomSource.Pause();
begin

end;

function TSGBASSCustomSource.Paused() : TSGBool;
begin

end;

procedure TSGBASSCustomSource.Stop();
begin

end;

function TSGBASSCustomSource.Stoped : TSGBool;
begin

end;

function TSGAudioRenderBASS.CreateBufferedSource() : TSGAudioBufferedSource;
begin
Result := TSGBASSBufferedSource.Create(Self);
end;

procedure TSGAudioRenderBASS.Init();
begin

end;

function TSGAudioRenderBASS.CreateDevice() : TSGBool;
begin

end;

procedure TSGAudioRenderBASS.Kill();
begin

inherited;
end;

constructor TSGAudioRenderBASS.Create();
begin
inherited;

end;

class function TSGAudioRenderBASS.AudioRenderName() : TSGString;
begin
Result := 'Bass';
end;

class function TSGAudioRenderBASS.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderBASS';
end;

class function TSGAudioRenderBASS.Suppored() : TSGBool;
begin
//Result := DllManager.Suppored('BASS');
Result := False;
end;

end.
