{$INCLUDE Smooth.inc}

unit SmoothScreenComponent;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothBaseClasses
	,SmoothScreenSkin
	,SmoothCommonStructs
	,SmoothBaseContextInterface
	,SmoothScreenCustomComponent
	,SmoothRenderInterface
	,SmoothContextInterface
	,SmoothContextClasses
	;
type
	TSComponent = class(TSScreenCustomComponent, ISComponent, ISContextObject, ISRenderObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FContext : PISContext;
			public
		function ContextAssigned() : TSBoolean; virtual;
		function RenderAssigned() : TSBoolean; virtual;
		procedure SetContext(const _Context : ISContext); virtual;
		function GetContext() : ISContext; virtual;
		function GetRender() : ISRender; virtual;
			public
		property Context : ISContext read GetContext write SetContext;
		property Render : ISRender read GetRender;
			public
		procedure DeleteRenderResources(); override;
		procedure LoadRenderResources(); override;
			protected
		FSkin    : TSScreenSkin;
		procedure UpDateSkin();virtual;
			public
		procedure DestroySkin();
			public
		property Skin : TSScreenSkin read FSkin write FSkin;
			protected
		procedure UpDateObjects(); override;
		procedure UpDate(); override;
			public
		function CursorOverComponent():TSBoolean;virtual;
			public
		procedure CompleteInternalComponent(const VInternalComponent : TSScreenCustomComponent); override;
			public
		FDrawClass:TSPaintableObject;
			public
		property DrawClass : TSPaintableObject read FDrawClass write FDrawClass;
			public
		procedure DrawDrawClasses();virtual;
		end;


implementation

uses
	 SmoothCommon
	,SmoothMathUtils
	,SmoothContextUtils
	;

function TSComponent.ContextAssigned() : TSBoolean;
begin
Result := (FContext <> nil) and (FContext^ <> nil);
end;

function TSComponent.RenderAssigned() : TSBoolean;
begin
Result := ContextAssigned() and (FContext^.Render <> nil)
end;

procedure TSComponent.SetContext(const _Context : ISContext);
begin
FContext := _Context.InterfaceLink;
end;

function TSComponent.GetContext() : ISContext;
begin
Result := FContext^;
end;

function TSComponent.GetRender() : ISRender;
begin
Result := FContext^.Render;
end;

class function TSComponent.ClassName() : TSString;
begin
Result := 'TSComponent';
end;

procedure TSComponent.UpDateSkin();
begin
if (FSkin <> nil) and ((FComponentOwner = nil) or ((FComponentOwner <> nil) and (FComponentOwner is TSComponent) and ((FComponentOwner as TSComponent).Skin <> FSkin))) then
	Skin.UpDate();
end;

procedure TSComponent.DrawDrawClasses();
var
	Component : TSScreenCustomComponent;
begin
if FDrawClass <> nil then
	FDrawClass.Paint();
for Component in Self do
	if (Component is TSComponent) then
		(Component as TSComponent).DrawDrawClasses();
end;

procedure TSComponent.DestroySkin();
begin
if (FSkin <> nil) and ((FComponentOwner = nil) or ((FComponentOwner <> nil) and (FComponentOwner is TSComponent) and ((FComponentOwner as TSComponent).Skin <> FSkin))) then
	SKill(FSkin);
end;

destructor TSComponent.Destroy();
begin
inherited;
SKill(FDrawClass);
DestroySkin();
end;

procedure TSComponent.CompleteInternalComponent(const VInternalComponent : TSScreenCustomComponent);
var
	Component : TSComponent;
begin
Component := VInternalComponent as TSComponent;
if (Component <> nil) then
	begin
	if ContextAssigned() then
		Component.Context := Context;
	if (Component.Skin = nil) then
		Component.Skin := Skin;
	end;
inherited;
end;

function TSComponent.CursorOverComponent() : TSBoolean;
var
	CursorPosition : TSVector2int32;
begin
CursorPosition := Context.CursorPosition(SNowCursorPosition);
Result:=
	(CursorPosition.x >= FRealPosition.x)and
	(CursorPosition.x <= FRealPosition.x + FRealLocation.Width)and
	(CursorPosition.y >= FRealPosition.y)and
	(CursorPosition.y <= FRealPosition.y + FRealLocation.Height);
end;

procedure TSComponent.UpDate();
begin
UpdateTimers(Context.ElapsedTime);
UpDateSkin();
inherited;
end;

procedure TSComponent.DeleteRenderResources();
begin
if FSkin <> nil then
	FSkin.DeleteRenderResources();
if FDrawClass <> nil then
	FDrawClass.DeleteRenderResources();
inherited;
end;

procedure TSComponent.LoadRenderResources();
begin
if FSkin <> nil then
	FSkin.LoadRenderResources();
if FDrawClass <> nil then
	FDrawClass.LoadRenderResources();
inherited;
end;

constructor TSComponent.Create();
begin
inherited;
FDrawClass := nil;
FSkin := nil;
end;

procedure TSComponent.UpDateObjects();
var
	Component : TSScreenCustomComponent;
begin
UpDateLocation(Context.ElapsedTime);
TestCoords();
inherited;
end;

end.
