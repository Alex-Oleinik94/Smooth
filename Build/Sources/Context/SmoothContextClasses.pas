{$INCLUDE Smooth.inc}

unit SmoothContextClasses;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothCommonStructs
	,SmoothRenderInterface
	,SmoothAudioRenderInterface
	,SmoothCursor
	,SmoothBitMap
	,SmoothContextUtils
	,SmoothContextInterface
	,SmoothScreenCustomComponent
	;
type
	TSContextObject = class(TSOptionGetSeter, ISContextObject, ISRenderObject, ISScreenObject)
			public
		constructor Create(); override; deprecated;
		destructor Destroy(); override;
		constructor Create(const _Context : ISContext); virtual;
			protected
		FContext : PISContext;
			public
		procedure SetContext(const _Context : ISContext); virtual;
		function GetContext() : ISContext; virtual;
		function GetRender() : ISRender; virtual;
		function GetAudioRender() : ISAudioRender; virtual;
		function GetScreen() : TSScreenCustomComponent; virtual;
		
		class function Supported(const _Context : ISContext) : TSBoolean; virtual;
		procedure DeleteRenderResources(); virtual;
		procedure LoadRenderResources(); virtual;
		
		function ContextAssigned() : TSBoolean; virtual;
		function RenderAssigned() : TSBoolean; virtual;
		function AudioRenderAssigned() : TSBool; virtual;
		
		property Context : ISContext read GetContext write SetContext;
		property Render  : ISRender  read GetRender;
		property AudioRender : ISAudioRender read GetAudioRender;
		property Screen : TSScreenCustomComponent read GetScreen;
		end;

	TSPaintableObjectClass = class of TSPaintableObject;
	TSPaintableObject = class(TSContextObject)
			public
		procedure Paint(); virtual;
		procedure Resize(); virtual;
		end;

procedure SKill(var ContextObject : TSContextObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SKill(var PaintableObject : TSPaintableObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

procedure SKill(var ContextObject : TSContextObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if ContextObject <> nil then
	begin
	ContextObject.Destroy();
	ContextObject := nil;
	end;
end;

procedure SKill(var PaintableObject : TSPaintableObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if PaintableObject <> nil then
	begin
	PaintableObject.Destroy();
	PaintableObject := nil;
	end;
end;

procedure TSPaintableObject.Paint();
begin
end;

procedure TSPaintableObject.Resize();
begin
end;

class function TSContextObject.Supported(const _Context : ISContext) : TSBoolean;
begin
Result := True;
end;

procedure TSContextObject.DeleteRenderResources();
begin
end;

procedure TSContextObject.LoadRenderResources();
begin
end;

function TSContextObject.AudioRenderAssigned() : TSBool;
begin
Result := False;
if ContextAssigned() then
	Result := Context.AudioRender <> nil;
end;

function TSContextObject.GetAudioRender() : ISAudioRender;
begin
Result := FContext^.AudioRender;
end;

constructor TSContextObject.Create();
begin
inherited;
if (FContext <> nil) and (not (FContext^ is ISContext)) then
	FContext := nil;
end;

destructor TSContextObject.Destroy();
begin
FContext := nil;
inherited;
end;

constructor TSContextObject.Create(const _Context : ISContext);
begin
SetContext(_Context);
Create();
end;

procedure TSContextObject.SetContext(const _Context : ISContext);
begin
if _Context <> nil then
	FContext := _Context.InterfaceLink
else
	FContext := nil;
end;

function TSContextObject.GetContext() : ISContext;
begin
Result := FContext^;
end;

function TSContextObject.GetRender() : ISRender;
begin
Result := FContext^.Render;
end;

function TSContextObject.GetScreen() : TSScreenCustomComponent;
begin
Result := FContext^.Screen;
end;

function TSContextObject.ContextAssigned() : TSBoolean;
begin
Result := False;
if (FContext <> nil) then
	if (FContext^ <> nil) then
		Result := True;
end;

function TSContextObject.RenderAssigned() : TSBoolean;
begin
Result := False;
if ContextAssigned() then
	if FContext^.Render <> nil then
		Result := True;
end;

end.
