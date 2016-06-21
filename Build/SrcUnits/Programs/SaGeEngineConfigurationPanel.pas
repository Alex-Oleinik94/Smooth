{$INCLUDE SaGe.inc}

{$DEFINE CONFIGURATION_DEBUG}

unit SaGeEngineConfigurationPanel;

interface

uses
	 SaGeCommon
	,Classes
	,SaGeUtils
	,SaGeContext
	,SaGeScreen
	,SaGeBase
	,SaGeBased
	,SaGeRender
	,SaGeVersion
	,SaGeRenderConstants
	;

type
	TSGEngineConfigurationPanel = class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw();override;
		procedure FromResize();override;
			public
		class function CanCreate(const VScreen : TSGScreen): TSGBoolean;
		procedure InitRender(const VRenderClass : TSGRenderClass);
		procedure InitContext(const VContextClass : TSGContextClass);
			private
		FContextsComboBox,
			FRendersComboBox : TSGComboBox;
		FCaptionLabel,
			FVersionLabel : TSGLabel;
		FCloseButton : TSGButton;
		end;

implementation

uses
	SaGeRenderOpenGL
	{$IFDEF MSWINDOWS}
		,SaGeContextWinApi
		,SaGeRenderDirectx
		{$ENDIF}
	{$IFDEF LINUX}
		,SaGeContextLinux
		{$ENDIF}
	{$IFDEF ANDROID}
		,SaGeContextAndroid
		{$ENDIF}
	{$IFDEF DARWIN}
		,SaGeContextMacOSX
		{$ENDIF}
	;

procedure TSGEngineConfigurationPanel.InitRender(const VRenderClass : TSGRenderClass);
begin
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSGEngineConfigurationPanel.InitRender(const VRenderClass : TSGRenderClass = ',TSGMaxEnum(VRenderClass),') : Begining');
	{$ENDIF}
Context.SetRenderClass(VRenderClass);
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSGEngineConfigurationPanel.InitRender(const VRenderClass : TSGRenderClass) : Begining');
	{$ENDIF}
end;

procedure TSGEngineConfigurationPanel.InitContext(const VContextClass : TSGContextClass);
begin

end;

var
	Renders : packed array [0 .. 1] of
		packed record
			FClass : TSGRenderClass;
			FName : TSGString;
			end = (
			(FClass :                    TSGRenderOpenGL                      ; FName : 'TSGRenderOpenGL' ),
			(FClass : {$IFDEF MSWINDOWS} TSGRenderDirectX {$ELSE} nil {$ENDIF}; FName : 'TSGRenderDirectX')
			);
	Contexts : packed array [0 .. 3] of
		packed record
			FClass : TSGContextClass;
			FName : TSGString;
			end = (
			(FClass : {$IFDEF MSWINDOWS}TSGContextWinAPI  {$ELSE}nil{$ENDIF}; FName : 'TSGContextWinAPI' ),
			(FClass : {$IFDEF ANDROID}  TSGContextAndroid {$ELSE}nil{$ENDIF}; FName : 'TSGContextAndroid'),
			(FClass : {$IFDEF LINUX}    TSGContextLinux   {$ELSE}nil{$ENDIF}; FName : 'TSGContextLinux'  ),
			(FClass : {$IFDEF DARWIN}   TSGContextMacOSX  {$ELSE}nil{$ENDIF}; FName : 'TSGContextMacOSX' )
			);

const
	FontHeight = 20;
	HeightShift = 2;
	TotalHeight = FontHeight * 10 + HeightShift * 4;

class function TSGEngineConfigurationPanel.CanCreate(const VScreen : TSGScreen): TSGBoolean;
var
	i : TSGLongWord;
begin
Result := True;
if VScreen.FChildren <> nil then
	if Length(VScreen.FChildren) > 0 then
		for i := 0 to High(VScreen.FChildren) do
			if VScreen.FChildren[i] is TSGEngineConfigurationPanel then
				begin
				Result := False;
				break;
				end;
end;

procedure TSGEngineConfigurationPanel_CloseButton_OnChange(VButton : TSGButton);
begin
VButton.Parent.Visible := False;
end;

procedure TSGEngineConfigurationPanel_ContextsComboBox_OnChange(VOldIndex, VNewIndex : TSGLongInt; VComboBox : TSGComboBox);
begin
if VOldIndex <> VNewIndex then
	TSGEngineConfigurationPanel(VComboBox.UserPointer).InitContext(Contexts[VNewIndex].FClass);
end;

procedure TSGEngineConfigurationPanel_RendersComboBox_OnChange(VOldIndex, VNewIndex : TSGLongInt; VComboBox : TSGComboBox);
begin
if VOldIndex <> VNewIndex then
	TSGEngineConfigurationPanel(VComboBox.UserPointer).InitRender(Renders[VNewIndex].FClass);
end;

constructor TSGEngineConfigurationPanel.Create();
var
	i : TSGLongWord;
begin
inherited;
SetBounds(0, 0, 500, TotalHeight);
BoundsToNeedBounds();
Visible := True;

FCaptionLabel := TSGLabel.Create();
CreateChild(FCaptionLabel);
FCaptionLabel.Caption := 'SaGe Engine Configuration';
FCaptionLabel.Visible := True;

FVersionLabel := TSGLabel.Create();
CreateChild(FVersionLabel);
FVersionLabel.Caption := 'Version: ' + SGGetEngineVersion();
FVersionLabel.Visible := True;

FContextsComboBox := TSGComboBox.Create();
CreateChild(FContextsComboBox);
FContextsComboBox.Visible := True;
FContextsComboBox.UserPointer:=Self;
for i := Low(Contexts) to High(Contexts) do
	FContextsComboBox.CreateItem(Contexts[i].FName, nil, -1, Contexts[i].FClass <> nil);
FContextsComboBox.FProcedure:=TSGComboBoxProcedure(@TSGEngineConfigurationPanel_ContextsComboBox_OnChange);

FRendersComboBox := TSGComboBox.Create();
CreateChild(FRendersComboBox);
FRendersComboBox.UserPointer:=Self;
FRendersComboBox.Visible := True;
for i := Low(Renders) to High(Renders) do
	FRendersComboBox.CreateItem(Renders[i].FName, nil, -1, Renders[i].FClass <> nil);
FRendersComboBox.FProcedure:=TSGComboBoxProcedure(@TSGEngineConfigurationPanel_RendersComboBox_OnChange);

FCloseButton := TSGButton.Create();
CreateChild(FCloseButton);
FCloseButton.UserPointer:=Self;
FCloseButton.Visible := True;
FCloseButton.Caption := 'Close';
FCloseButton.OnChange := TSGComponentProcedure(@TSGEngineConfigurationPanel_CloseButton_OnChange);
end;

procedure TSGEngineConfigurationPanel.FromResize();

const
	ShiftWidth = 40;

procedure ProcessValue(const Value : TSGLongWord; var Max : TSGLongWord);
begin
if Value > Max then
	Max := Value;
end;

function CalculateRendersComboBoxWidth() : TSGLongWord;
var
	i : TSGLongWord;
begin
Result := 0;
for i := Low(Renders) to High(Renders) do
	ProcessValue(Font.StringLength(Renders[i].FName) + ShiftWidth, Result);
end;

function CalculateContextsComboBoxWidth() : TSGLongWord;
var
	i : TSGLongWord;
begin
Result := 0;
for i := Low(Contexts) to High(Contexts) do
	ProcessValue(Font.StringLength(Contexts[i].FName) + ShiftWidth, Result);
end;

function CalculateWidth() : TSGLongWord;
begin
Result := 0;
ProcessValue(Font.StringLength(FCloseButton.Caption) + ShiftWidth, Result);
ProcessValue(Font.StringLength(FVersionLabel.Caption) + ShiftWidth, Result);
ProcessValue(Font.StringLength(FCaptionLabel.Caption) + ShiftWidth, Result);
ProcessValue(CalculateContextsComboBoxWidth(), Result);
ProcessValue(CalculateRendersComboBoxWidth(), Result);
end;

begin
if Parent <> nil then
	SetMiddleBounds(CalculateWidth(), TotalHeight)
else
	SetBounds(0, 0, CalculateWidth(), TotalHeight);
BoundsToNeedBounds();
FCaptionLabel.SetBounds(0, (FontHeight div 4), Width, FontHeight);
FCaptionLabel.BoundsToNeedBounds();
FVersionLabel.SetBounds(0, FontHeight * 2 + HeightShift + (FontHeight div 4), Width, FontHeight);
FVersionLabel.BoundsToNeedBounds();
FContextsComboBox.SetMiddleBounds(CalculateContextsComboBoxWidth(), FontHeight);
FContextsComboBox.Top := (FontHeight * 2 + HeightShift) * 2 + (FontHeight div 4);
FContextsComboBox.BoundsToNeedBounds();
FRendersComboBox.SetMiddleBounds(CalculateRendersComboBoxWidth(), FontHeight);
FRendersComboBox.Top := (FontHeight * 2 + HeightShift) * 3 + (FontHeight div 4);
FRendersComboBox.BoundsToNeedBounds();
FCloseButton.SetMiddleBounds(Font.StringLength(FCloseButton.Caption) + ShiftWidth, FontHeight);
FCloseButton.Top := (FontHeight * 2 + HeightShift) * 4 + (FontHeight div 4);
FCloseButton.BoundsToNeedBounds();
inherited;
end;

destructor TSGEngineConfigurationPanel.Destroy();
begin
if FContextsComboBox <> nil then
	FContextsComboBox.Destroy();
if FRendersComboBox <> nil then
	FRendersComboBox.Destroy();
if FCaptionLabel <> nil then
	FCaptionLabel.Destroy();
if FCloseButton <> nil then
	FCloseButton.Destroy();
if FVersionLabel <> nil then
	FVersionLabel.Destroy();
inherited;
end;

procedure TSGEngineConfigurationPanel.FromUpDate(var FCanChange:Boolean);
var
	i : TSGLongWord;
begin
if FContextsComboBox.SelectItem = -1 then
	for i := Low(Contexts) to High(Contexts) do
		if Context is Contexts[i].FClass then
			begin
			FContextsComboBox.SelectItem := i;
			break;
			end;
if FRendersComboBox.SelectItem = -1 then
	for i := Low(Renders) to High(Renders) do
		if Render is Renders[i].FClass then
			begin
			FRendersComboBox.SelectItem := i;
			break;
			end;
inherited;
end;

procedure TSGEngineConfigurationPanel.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited;
end;

procedure TSGEngineConfigurationPanel.FromDraw();

function DistanseToQuad(const QuadVertex1, QuadVertex3, Point : TSGVertex2f) : TSGFloat;
begin
if (Point.x <= QuadVertex3.x) and (Point.x >= QuadVertex1.x) and (Point.y >= QuadVertex3.y) then
	Result := Point.y - QuadVertex3.y
else if (Point.x <= QuadVertex3.x) and (Point.x >= QuadVertex1.x) and (Point.y <= QuadVertex1.y) then
	Result := QuadVertex1.y - Point.y
else if (Point.y <= QuadVertex3.y) and (Point.y >= QuadVertex1.y) and (Point.x <= QuadVertex1.x) then
	Result := QuadVertex1.x - Point.x
else if (Point.y <= QuadVertex3.y) and (Point.y >= QuadVertex1.y) and (Point.x >= QuadVertex3.x) then
	Result := Point.x - QuadVertex3.x
else if (Point.x > QuadVertex3.x) and (Point.y > QuadVertex3.y) then
	Result := Abs(Point - QuadVertex3)
else if (Point.x < QuadVertex1.x) and (Point.y < QuadVertex1.y) then
	Result := Abs(Point - QuadVertex1)
else if (Point.x < QuadVertex1.x) and (Point.y > QuadVertex3.y) then
	Result := Abs(Point - SGVertex2fImport(QuadVertex1.x, QuadVertex3.y))
else if (Point.x > QuadVertex3.x) and (Point.y < QuadVertex1.y) then
	Result := Abs(Point - SGVertex2fImport(QuadVertex3.x, QuadVertex1.y))
else
	Result := 0;
end;

const
	Space = 200;

function DistanseToAlpha(const VDistanse : TSGFloat) : TSGFloat;
begin
if VDistanse > Space then
	Result := 0
else
	Result := (Space - VDistanse) / Space;
end;

var
	Vertex1, Vertex2 : TSGVertex3f;
	Alpha, Distanse : TSGFloat;
	Color : TSGColor4f = (r:0;g:0.2;b:0.7;a:0.6);
begin
Vertex1 := SGPoint2fToVertex3f(GetVertex([SGS_LEFT, SGS_TOP], SG_VERTEX_FOR_PARENT));
Vertex2 := SGPoint2fToVertex3f(GetVertex([SGS_RIGHT, SGS_BOTTOM], SG_VERTEX_FOR_PARENT));
Distanse := DistanseToQuad(Vertex1, Vertex2, SGPoint2fToVertex2f(Context.CursorPosition())) / 3;
Alpha := DistanseToAlpha(Distanse);
Alpha *= FVisibleTimer;

Render.BeginScene(SGR_QUADS);

Color.WithAlpha(Alpha).Color(Render);
Vertex1.Vertex(Render);
Render.Vertex2f(Vertex1.x, Vertex2.y);
Vertex2.Vertex(Render);
Render.Vertex2f(Vertex2.x, Vertex1.y);

Color.WithAlpha(Alpha).Color(Render);
Vertex1.Vertex(Render);
Render.Vertex2f(Vertex1.x, Vertex2.y);
Color.WithAlpha(DistanseToAlpha(Space) * Alpha).Color(Render);
Render.Vertex2f(Vertex1.x - Space, Vertex2.y + Space);
Render.Vertex2f(Vertex1.x - Space, Vertex1.y - Space);

Color.WithAlpha(Alpha).Color(Render);
Vertex1.Vertex(Render);
Render.Vertex2f(Vertex2.x, Vertex1.y);
Color.WithAlpha(DistanseToAlpha(Space) * Alpha).Color(Render);
Render.Vertex2f(Vertex2.x + Space, Vertex1.y - Space);
Render.Vertex2f(Vertex1.x - Space, Vertex1.y  - Space);

Color.WithAlpha(Alpha).Color(Render);
Vertex2.Vertex(Render);
Render.Vertex2f(Vertex1.x, Vertex2.y);
Color.WithAlpha(DistanseToAlpha(Space) * Alpha).Color(Render);
Render.Vertex2f(Vertex1.x - Space, Vertex2.y + Space);
Render.Vertex2f(Vertex2.x + Space, Vertex2.y  + Space);

Color.WithAlpha(Alpha).Color(Render);
Vertex2.Vertex(Render);
Render.Vertex2f(Vertex2.x, Vertex1.y);
Color.WithAlpha(DistanseToAlpha(Space) * Alpha).Color(Render);
Render.Vertex2f(Vertex2.x + Space, Vertex1.y - Space);
Render.Vertex2f(Vertex2.x + Space, Vertex2.y + Space);

Render.EndScene();

Alpha := DistanseToAlpha(Distanse);

if Visible and (FVisibleTimer > Alpha) then
	begin
	FVisibleTimer := Alpha;
	FCaptionLabel.FVisibleTimer := Alpha;
	FVersionLabel.FVisibleTimer := Alpha;
	FContextsComboBox.FVisibleTimer := Alpha;
	FRendersComboBox.FVisibleTimer := Alpha;
	FCloseButton.FVisibleTimer := Alpha;
	end;

inherited;
end;

end.
