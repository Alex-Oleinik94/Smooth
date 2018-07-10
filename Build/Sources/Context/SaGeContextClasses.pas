{$INCLUDE SaGe.inc}

unit SaGeContextClasses;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeCommonStructs
	,SaGeRenderInterface
	,SaGeAudioRenderInterface
	,SaGeCursor
	,SaGeBitMap
	,SaGeContextUtils
	,SaGeContextInterface
	,SaGeScreenCustomComponent
	;
type
	TSGContextObject = class(TSGOptionGetSeter, ISGContextObject, ISGRenderObject, ISGScreenObject)
			public
		constructor Create(); override; deprecated;
		destructor Destroy(); override;
		constructor Create(const _Context : ISGContext); virtual;
			protected
		FContext : PISGContext;
			public
		procedure SetContext(const _Context : ISGContext); virtual;
		function GetContext() : ISGContext; virtual;
		function GetRender() : ISGRender; virtual;
		function GetAudioRender() : ISGAudioRender; virtual;
		function GetScreen() : TSGScreenCustomComponent; virtual;
		
		function Suppored() : TSGBoolean; virtual;
		procedure DeleteRenderResources(); virtual;
		procedure LoadRenderResources(); virtual;
		
		function ContextAssigned() : TSGBoolean; virtual;
		function RenderAssigned() : TSGBoolean; virtual;
		function AudioRenderAssigned() : TSGBool; virtual;
		
		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		property AudioRender : ISGAudioRender read GetAudioRender;
		property Screen : TSGScreenCustomComponent read GetScreen;
		end;

	TSGPaintableObjectClass = class of TSGPaintableObject;
	TSGPaintableObject = class(TSGContextObject)
			public
		procedure Paint(); virtual;
		procedure Resize(); virtual;
		end;

procedure SGKill(var ContextObject : TSGContextObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SGKill(var PaintableObject : TSGPaintableObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

procedure SGKill(var ContextObject : TSGContextObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if ContextObject <> nil then
	begin
	ContextObject.Destroy();
	ContextObject := nil;
	end;
end;

procedure SGKill(var PaintableObject : TSGPaintableObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if PaintableObject <> nil then
	begin
	PaintableObject.Destroy();
	PaintableObject := nil;
	end;
end;

procedure TSGPaintableObject.Paint();
begin
end;

procedure TSGPaintableObject.Resize();
begin
end;

function TSGContextObject.Suppored() : TSGBoolean;
begin
Result := False;
end;

procedure TSGContextObject.DeleteRenderResources();
begin
end;

procedure TSGContextObject.LoadRenderResources();
begin
end;

function TSGContextObject.AudioRenderAssigned() : TSGBool;
begin
Result := False;
if ContextAssigned() then
	Result := Context.AudioRender <> nil;
end;

function TSGContextObject.GetAudioRender() : ISGAudioRender;
begin
Result := FContext^.AudioRender;
end;

constructor TSGContextObject.Create();
begin
inherited;
if (FContext <> nil) and (not (FContext^ is ISGContext)) then
	FContext := nil;
end;

destructor TSGContextObject.Destroy();
begin
FContext := nil;
inherited;
end;

constructor TSGContextObject.Create(const _Context : ISGContext);
begin
SetContext(_Context);
Create();
end;

procedure TSGContextObject.SetContext(const _Context : ISGContext);
begin
if _Context <> nil then
	FContext := _Context.InterfaceLink
else
	FContext := nil;
end;

function TSGContextObject.GetContext() : ISGContext;
begin
Result := FContext^;
end;

function TSGContextObject.GetRender() : ISGRender;
begin
Result := FContext^.Render;
end;

function TSGContextObject.GetScreen() : TSGScreenCustomComponent;
begin
Result := FContext^.Screen;
end;

function TSGContextObject.ContextAssigned() : TSGBoolean;
begin
Result := False;
if (FContext <> nil) then
	if (FContext^ <> nil) then
		Result := True;
end;

function TSGContextObject.RenderAssigned() : TSGBoolean;
begin
Result := False;
if ContextAssigned() then
	if FContext^.Render <> nil then
		Result := True;
end;

end.
