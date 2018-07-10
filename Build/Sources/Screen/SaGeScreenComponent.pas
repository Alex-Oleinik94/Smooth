{$INCLUDE SaGe.inc}

unit SaGeScreenComponent;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeBaseClasses
	,SaGeScreenSkin
	,SaGeCommonStructs
	,SaGeBaseContextInterface
	,SaGeScreenCustomComponent
	,SaGeRenderInterface
	,SaGeContextInterface
	,SaGeContextClasses
	;
type
	TSGComponent          = class(TSGScreenCustomComponent, ISGComponent, ISGContextObject, ISGRenderObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			protected
		FContext : PISGContext;
			public
		function ContextAssigned() : TSGBoolean; virtual;
		function RenderAssigned() : TSGBoolean; virtual;
		procedure SetContext(const _Context : ISGContext); virtual;
		function GetContext() : ISGContext; virtual;
		function GetRender() : ISGRender; virtual;
			public
		property Context : ISGContext read GetContext write SetContext;
		property Render : ISGRender read GetRender;
			public
		procedure DeleteRenderResources(); override;
		procedure LoadRenderResources(); override;
			protected
		FSkin    : TSGScreenSkin;
		procedure UpDateSkin();virtual;
			public
		procedure DestroySkin();
			public
		property Skin : TSGScreenSkin read FSkin write FSkin;
			protected
		procedure UpDateObjects(); override;
		procedure UpDate(); override;
			public
		function CursorOverComponent():TSGBoolean;virtual;
			public
		procedure CompleteChild(const VChild : TSGScreenCustomComponent); override;
			public
		FDrawClass:TSGPaintableObject;
			public
		property DrawClass : TSGPaintableObject read FDrawClass write FDrawClass;
			public
		procedure DrawDrawClasses();virtual;
		end;


implementation

uses
	 SaGeCommon
	,SaGeMathUtils
	,SaGeContextUtils
	;

function TSGComponent.ContextAssigned() : TSGBoolean;
begin
Result := (FContext <> nil) and (FContext^ <> nil);
end;

function TSGComponent.RenderAssigned() : TSGBoolean;
begin
Result := ContextAssigned() and (FContext^.Render <> nil)
end;

procedure TSGComponent.SetContext(const _Context : ISGContext);
begin
FContext := _Context.InterfaceLink;
end;

function TSGComponent.GetContext() : ISGContext;
begin
Result := FContext^;
end;

function TSGComponent.GetRender() : ISGRender;
begin
Result := FContext^.Render;
end;

class function TSGComponent.ClassName() : TSGString;
begin
Result := 'TSGComponent';
end;

procedure TSGComponent.UpDateSkin();
begin
if (FSkin <> nil) and ((FParent = nil) or ((FParent <> nil) and (FParent is TSGComponent) and ((FParent as TSGComponent).Skin <> FSkin))) then
	Skin.UpDate();
end;

procedure TSGComponent.DrawDrawClasses();
var
	Component : TSGScreenCustomComponent;
begin
if FDrawClass <> nil then
	FDrawClass.Paint();
for Component in Self do
	if (Component is TSGComponent) then
		(Component as TSGComponent).DrawDrawClasses();
end;

procedure TSGComponent.DestroySkin();
begin
if (FSkin <> nil) and ((FParent = nil) or ((FParent <> nil) and (FParent is TSGComponent) and ((FParent as TSGComponent).Skin <> FSkin))) then
	SGKill(FSkin);
end;

destructor TSGComponent.Destroy();
begin
inherited;
SGKill(FDrawClass);
DestroySkin();
end;

procedure TSGComponent.CompleteChild(const VChild : TSGScreenCustomComponent);
var
	Component : TSGComponent;
begin
Component := VChild as TSGComponent;
if (Component <> nil) then
	begin
	if ContextAssigned() then
		Component.Context := Context;
	if (Component.Skin = nil) then
		Component.Skin := Skin;
	end;
inherited;
end;

function TSGComponent.CursorOverComponent() : TSGBoolean;
var
	CursorPosition : TSGVector2int32;
begin
CursorPosition := Context.CursorPosition(SGNowCursorPosition);
Result:=
	(CursorPosition.x >= FRealPosition.x)and
	(CursorPosition.x <= FRealPosition.x + FRealLocation.Width)and
	(CursorPosition.y >= FRealPosition.y)and
	(CursorPosition.y <= FRealPosition.y + FRealLocation.Height);
end;

procedure TSGComponent.UpDate();
begin
UpgradeTimers(Context.ElapsedTime);
UpDateSkin();
inherited;
end;

procedure TSGComponent.DeleteRenderResources();
begin
if FSkin <> nil then
	FSkin.DeleteRenderResources();
if FDrawClass <> nil then
	FDrawClass.DeleteRenderResources();
inherited;
end;

procedure TSGComponent.LoadRenderResources();
begin
if FSkin <> nil then
	FSkin.LoadRenderResources();
if FDrawClass <> nil then
	FDrawClass.LoadRenderResources();
inherited;
end;

constructor TSGComponent.Create();
begin
inherited;
FDrawClass := nil;
FSkin := nil;
end;

procedure TSGComponent.UpDateObjects();
var
	Component : TSGScreenCustomComponent;
begin
UpDateLocation(Context.ElapsedTime);
TestCoords();
inherited;
end;

end.
