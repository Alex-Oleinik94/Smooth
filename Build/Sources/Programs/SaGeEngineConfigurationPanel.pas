{$INCLUDE SaGe.inc}

//{$DEFINE CONFIGURATION_DEBUG}

unit SaGeEngineConfigurationPanel;

interface

uses
	 SaGeBase
	,SaGeCommon
	,SaGeContext
	,SaGeScreen
	,SaGeRender
	,SaGeFont
	,SaGeFPSViewer
	;

type
	TSGEngineConfigurationPanel = class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
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
		FFPS : TSGFPSViewer;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeVersion
	,SaGeRenderBase
	,SaGeScreenBase
	
	,Classes
	
	,SaGeRenderOpenGL
	{$IFDEF MSWINDOWS}
		,SaGeContextWinAPI
		,SaGeRenderDirectX12
		,SaGeRenderDirectX9
		,SaGeRenderDirectX8
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
	{$IFDEF WITH_GLUT}
		,SaGeContextGLUT
		{$ENDIF}
	;

procedure TSGEngineConfigurationPanel.InitRender(const VRenderClass : TSGRenderClass);
begin
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSGEngineConfigurationPanel__InitRender(const VRenderClass : TSGRenderClass = ',SGAddrStr(VRenderClass),') : Begining');
	{$ENDIF}
Context.SetRenderClass(VRenderClass);
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSGEngineConfigurationPanel__InitRender(const VRenderClass : TSGRenderClass) : End');
	{$ENDIF}
end;

procedure TSGEngineConfigurationPanel.InitContext(const VContextClass : TSGContextClass);
begin
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSGEngineConfigurationPanel__InitContext(const VContextClass : TSGContextClass = ',SGAddrStr(VContextClass),') : Begining');
	{$ENDIF}
Context.NewContext := VContextClass;
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSGEngineConfigurationPanel__InitContext(const VContextClass : TSGContextClass) : End');
	{$ENDIF}
end;

var
	Renders : packed array [0 .. 3] of
		packed record
			FClass : TSGRenderClass;
			FName : TSGString;
			end = (
			(FClass :                    TSGRenderOpenGL                      ; FName : 'OpenGL' ),
			(FClass : {$IFDEF MSWINDOWS} TSGRenderDirectX12{$ELSE} nil {$ENDIF}; FName : 'DirectX 12'),
			(FClass : {$IFDEF MSWINDOWS} TSGRenderDirectX9{$ELSE} nil {$ENDIF}; FName : 'DirectX 9'),
			(FClass : {$IFDEF MSWINDOWS} TSGRenderDirectX8{$ELSE} nil {$ENDIF}; FName : 'DirectX 8')
			);
	Contexts : packed array [0 .. 4] of
		packed record
			FClass : TSGContextClass;
			FName : TSGString;
			end = (
			(FClass : {$IFDEF MSWINDOWS}TSGContextWinAPI  {$ELSE}nil{$ENDIF}; FName : 'Windows (WinAPI)' ),
			(FClass : {$IFDEF ANDROID}  TSGContextAndroid {$ELSE}nil{$ENDIF}; FName : 'Android (Natieve Activity)'),
			(FClass : {$IFDEF LINUX}    TSGContextLinux   {$ELSE}nil{$ENDIF}; FName : 'Linux (X11)'  ),
			(FClass : {$IFDEF DARWIN}   TSGContextMacOSX  {$ELSE}nil{$ENDIF}; FName : 'Mac OS X (Carbon)' ),
			(FClass : {$IFDEF WITH_GLUT}TSGContextGLUT    {$ELSE}nil{$ENDIF}; FName : 'OpenGL Utility Toolkit (GLUT)' )
			);

const
	FontHeight = 20;
	HeightShift = 2;
	TotalHeight = FontHeight * 10 + HeightShift * 4;

class function TSGEngineConfigurationPanel.CanCreate(const VScreen : TSGScreen): TSGBoolean;
var
	Component : TSGComponent;
begin
Result := True;
if VScreen.HasChildren then
	for Component in VScreen do
		if Component is TSGEngineConfigurationPanel then
			begin
			Result := False;
			break;
			end;
end;

procedure TSGEngineConfigurationPanel_CloseButton_OnChange(VButton : TSGButton);
begin
VButton.Parent.MarkForDestroy();
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

procedure TSGEngineConfigurationPanel.DeleteDeviceResources();
begin
if FFPS <> nil then
	FFPS.DeleteDeviceResources();
end;

procedure TSGEngineConfigurationPanel.LoadDeviceResources();
begin
if FFPS <> nil then
	FFPS.LoadDeviceResources();
end;

constructor TSGEngineConfigurationPanel.Create();
var
	i : TSGLongWord;
	FCanUse: TSGBool;
begin
inherited;
SetBounds(0, 0, 500, TotalHeight);
BoundsToNeedBounds();
Visible := True;

FFPS := nil;

FCaptionLabel := TSGLabel.Create();
CreateChild(FCaptionLabel);
FCaptionLabel.Caption := 'SaGe Engine Configuration (' + SGVerCPU + ' bit)';
FCaptionLabel.Visible := True;

FVersionLabel := TSGLabel.Create();
CreateChild(FVersionLabel);
FVersionLabel.Caption := 'Version: ' + SGEngineVersion();
FVersionLabel.Visible := True;

FContextsComboBox := TSGComboBox.Create();
CreateChild(FContextsComboBox);
FContextsComboBox.Visible := True;
FContextsComboBox.UserPointer:=Self;
for i := Low(Contexts) to High(Contexts) do
	begin
	FCanUse := Contexts[i].FClass <> nil;
	if FCanUse then
		FCanUse := Contexts[i].FClass.Suppored();
	FContextsComboBox.CreateItem(Contexts[i].FName, nil, -1, FCanUse);
	end;
FContextsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGEngineConfigurationPanel_ContextsComboBox_OnChange);

FRendersComboBox := TSGComboBox.Create();
CreateChild(FRendersComboBox);
FRendersComboBox.UserPointer:=Self;
FRendersComboBox.Visible := True;
for i := Low(Renders) to High(Renders) do
	begin
	FCanUse := Renders[i].FClass <> nil;
	if FCanUse then
		FCanUse := Renders[i].FClass.Suppored();
	FRendersComboBox.CreateItem(Renders[i].FName, nil, -1, FCanUse);
	end;
FRendersComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGEngineConfigurationPanel_RendersComboBox_OnChange);

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
	ProcessValue(Skin.Font.StringLength(Renders[i].FName) + ShiftWidth, Result);
end;

function CalculateContextsComboBoxWidth() : TSGLongWord;
var
	i : TSGLongWord;
begin
Result := 0;
for i := Low(Contexts) to High(Contexts) do
	ProcessValue(Skin.Font.StringLength(Contexts[i].FName) + ShiftWidth, Result);
end;

function CalculateWidth() : TSGLongWord;
begin
Result := 0;
ProcessValue(Skin.Font.StringLength(FCloseButton.Caption) + ShiftWidth, Result);
ProcessValue(Skin.Font.StringLength(FVersionLabel.Caption) + ShiftWidth, Result);
ProcessValue(Skin.Font.StringLength(FCaptionLabel.Caption) + ShiftWidth, Result);
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
FCloseButton.SetMiddleBounds(Skin.Font.StringLength(FCloseButton.Caption) + ShiftWidth, FontHeight);
FCloseButton.Top := (FontHeight * 2 + HeightShift) * 4 + (FontHeight div 4);
FCloseButton.BoundsToNeedBounds();
inherited;
end;

destructor TSGEngineConfigurationPanel.Destroy();
begin
if FFPS <> nil then
	FFPS.Destroy();
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

procedure TSGEngineConfigurationPanel.FromUpDate(var FCanChange : TSGBoolean);
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
if (FRendersComboBox.SelectItem = -1) or ((FRendersComboBox.SelectItem <> -1) and (not(Render is Renders[FRendersComboBox.SelectItem].FClass))) then
	for i := Low(Renders) to High(Renders) do
		if Render is Renders[i].FClass then
			begin
			FRendersComboBox.SelectItem := i;
			break;
			end;
ToFront();
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

function PointToVert3f(const P : TSGPoint2int32):TSGVertex3f;
begin
Result.Import(P.x, P.y);
end;

procedure DrawFPC(const V1, V2 : TSGVertex3f; const Alpha : TSGFloat32);
begin
if Context = nil then
	Exit;
if (FFPS = nil) then
	FFPS := TSGFPSViewer.Create(Context);
FFPS.x := Trunc(V1.x + (V2.x - V1.x) / 2 - 25);
FFPS.y := Trunc(V1.y + (V2.y - V1.y) / 2 - 70);
FFPS.Alpha := Alpha * 2;
FFPS.Paint();
end;

var
	Vertex1, Vertex2 : TSGVertex3f;
	Alpha, Distanse : TSGFloat;
	Color : TSGColor4f;

begin
Color := FSkin.Colors.FNormal.FFirst.WithAlpha(0.8);
Vertex1 := PointToVert3f(GetVertex([SGS_LEFT, SGS_TOP], SG_VERTEX_FOR_PARENT));
Vertex2 := PointToVert3f(GetVertex([SGS_RIGHT, SGS_BOTTOM], SG_VERTEX_FOR_PARENT));
Distanse := DistanseToQuad(Vertex1, Vertex2, PointToVert3f(Context.CursorPosition())) / 3;
Alpha := DistanseToAlpha(Distanse);
Alpha *= VisibleTimer;

Render.BeginScene(SGR_QUADS);

Render.Color(Color.WithAlpha(Alpha));
Render.Vertex(Vertex1);
Render.Vertex2f(Vertex1.x, Vertex2.y);
Render.Vertex(Vertex2);
Render.Vertex2f(Vertex2.x, Vertex1.y);

Render.Color(Color.WithAlpha(Alpha));
Render.Vertex(Vertex1);
Render.Vertex2f(Vertex1.x, Vertex2.y);
Render.Color(Color.WithAlpha(DistanseToAlpha(Space) * Alpha));
Render.Vertex2f(Vertex1.x - Space, Vertex2.y + Space);
Render.Vertex2f(Vertex1.x - Space, Vertex1.y - Space);

Render.Color(Color.WithAlpha(Alpha));
Render.Vertex(Vertex1);
Render.Vertex2f(Vertex2.x, Vertex1.y);
Render.Color(Color.WithAlpha(DistanseToAlpha(Space) * Alpha));
Render.Vertex2f(Vertex2.x + Space, Vertex1.y - Space);
Render.Vertex2f(Vertex1.x - Space, Vertex1.y  - Space);

Render.Color(Color.WithAlpha(Alpha));
Render.Vertex(Vertex2);
Render.Vertex2f(Vertex1.x, Vertex2.y);
Render.Color(Color.WithAlpha(DistanseToAlpha(Space) * Alpha));
Render.Vertex2f(Vertex1.x - Space, Vertex2.y + Space);
Render.Vertex2f(Vertex2.x + Space, Vertex2.y  + Space);

Render.Color(Color.WithAlpha(Alpha));
Render.Vertex(Vertex2);
Render.Vertex2f(Vertex2.x, Vertex1.y);
Render.Color(Color.WithAlpha(DistanseToAlpha(Space) * Alpha));
Render.Vertex2f(Vertex2.x + Space, Vertex1.y - Space);
Render.Vertex2f(Vertex2.x + Space, Vertex2.y + Space);

Render.EndScene();

Alpha := DistanseToAlpha(Distanse);

if Visible and (VisibleTimer > Alpha) then
	begin
	VisibleTimer := Alpha;
	FCaptionLabel.VisibleTimer := Alpha;
	FVersionLabel.VisibleTimer := Alpha;
	FContextsComboBox.VisibleTimer := Alpha;
	FRendersComboBox.VisibleTimer := Alpha;
	FCloseButton.VisibleTimer := Alpha;
	end;

inherited;

DrawFPC(Vertex1, Vertex2, Alpha);
end;

end.
