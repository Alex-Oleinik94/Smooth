{$INCLUDE Smooth.inc}

//{$DEFINE CONFIGURATION_DEBUG}

unit SmoothEngineConfigurationPanel;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContext
	,SmoothRender
	,SmoothFont
	,SmoothFPSViewer
	,SmoothScreenClasses
	;

type
	TSEngineConfigurationPanel = class(TSScreenComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			public
		procedure UpDate();override;
		procedure Paint(); override;
		procedure Resize();override;
			public
		class function CanCreate(const VScreen : TSScreenComponent): TSBoolean;
		procedure InitRender(const VRenderClass : TSRenderClass);
		procedure InitContext(const VContextClass : TSContextClass);
			private
		FContextsComboBox,
			FRendersComboBox : TSScreenComboBox;
		FCaptionLabel,
			FVersionLabel : TSScreenLabel;
		FCloseButton : TSScreenButton;
		FFPS : TSFPSViewer;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothVersion
	,SmoothRenderBase
	,SmoothScreenBase
	,SmoothScreenCustomComponent
	
	,Classes
	
	,SmoothRenderOpenGL
	{$IFDEF MSWINDOWS}
		,SmoothContextWinAPI
		,SmoothRenderDirectX12
		,SmoothRenderDirectX9
		,SmoothRenderDirectX8
		{$ENDIF}
	{$IFDEF LINUX}
		,SmoothContextLinux
		{$ENDIF}
	{$IFDEF ANDROID}
		,SmoothContextAndroid
		{$ENDIF}
	{$IFDEF DARWIN}
		,SmoothContextMacOSX
		{$ENDIF}
	{$IFDEF WITH_GLUT}
		,SmoothContextGLUT
		{$ENDIF}
	;

procedure TSEngineConfigurationPanel.InitRender(const VRenderClass : TSRenderClass);
begin
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSEngineConfigurationPanel__InitRender(const VRenderClass : TSRenderClass = ',SAddrStr(VRenderClass),') : Begining');
	{$ENDIF}
Context.SetRenderClass(VRenderClass);
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSEngineConfigurationPanel__InitRender(const VRenderClass : TSRenderClass) : End');
	{$ENDIF}
end;

procedure TSEngineConfigurationPanel.InitContext(const VContextClass : TSContextClass);
begin
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSEngineConfigurationPanel__InitContext(const VContextClass : TSContextClass = ',SAddrStr(VContextClass),') : Begining');
	{$ENDIF}
Context.NewContext := VContextClass;
{$IFDEF CONFIGURATION_DEBUG}
	WriteLn('TSEngineConfigurationPanel__InitContext(const VContextClass : TSContextClass) : End');
	{$ENDIF}
end;

var
	Renders : packed array [0 .. 3] of
		packed record
			FClass : TSRenderClass;
			FName : TSString;
			end = (
			(FClass :                    TSRenderOpenGL                      ; FName : 'OpenGL' ),
			(FClass : {$IFDEF MSWINDOWS} TSRenderDirectX12{$ELSE} nil {$ENDIF}; FName : 'DirectX 12'),
			(FClass : {$IFDEF MSWINDOWS} TSRenderDirectX9{$ELSE} nil {$ENDIF}; FName : 'DirectX 9'),
			(FClass : {$IFDEF MSWINDOWS} TSRenderDirectX8{$ELSE} nil {$ENDIF}; FName : 'DirectX 8')
			);
	Contexts : packed array [0 .. 4] of
		packed record
			FClass : TSContextClass;
			FName : TSString;
			end = (
			(FClass : {$IFDEF MSWINDOWS}TSContextWinAPI  {$ELSE}nil{$ENDIF}; FName : 'Windows (WinAPI)' ),
			(FClass : {$IFDEF ANDROID}  TSContextAndroid {$ELSE}nil{$ENDIF}; FName : 'Android (Natieve Activity)'),
			(FClass : {$IFDEF LINUX}    TSContextLinux   {$ELSE}nil{$ENDIF}; FName : 'Linux (X11)'  ),
			(FClass : {$IFDEF DARWIN}   TSContextMacOSX  {$ELSE}nil{$ENDIF}; FName : 'Mac OS X (Carbon)' ),
			(FClass : {$IFDEF WITH_GLUT}TSContextGLUT    {$ELSE}nil{$ENDIF}; FName : 'OpenGL Utility Toolkit (GLUT)' )
			);

const
	FontHeight = 20;
	HeightShift = 2;
	TotalHeight = FontHeight * 10 + HeightShift * 4;

class function TSEngineConfigurationPanel.CanCreate(const VScreen : TSScreenComponent): TSBoolean;
var
	Component : TSScreenCustomComponent;
begin
Result := True;
if VScreen.HasChildren then
	for Component in VScreen do
		if Component is TSEngineConfigurationPanel then
			begin
			Result := False;
			break;
			end;
end;

procedure TSEngineConfigurationPanel_CloseButton_OnChange(VButton : TSScreenButton);
begin
VButton.Parent.MarkForDestroy();
end;

procedure TSEngineConfigurationPanel_ContextsComboBox_OnChange(VOldIndex, VNewIndex : TSLongInt; VComboBox : TSScreenComboBox);
begin
if VOldIndex <> VNewIndex then
	TSEngineConfigurationPanel(VComboBox.UserPointer).InitContext(Contexts[VNewIndex].FClass);
end;

procedure TSEngineConfigurationPanel_RendersComboBox_OnChange(VOldIndex, VNewIndex : TSLongInt; VComboBox : TSScreenComboBox);
begin
if VOldIndex <> VNewIndex then
	TSEngineConfigurationPanel(VComboBox.UserPointer).InitRender(Renders[VNewIndex].FClass);
end;

procedure TSEngineConfigurationPanel.DeleteRenderResources();
begin
if FFPS <> nil then
	FFPS.DeleteRenderResources();
end;

procedure TSEngineConfigurationPanel.LoadRenderResources();
begin
if FFPS <> nil then
	FFPS.LoadRenderResources();
end;

constructor TSEngineConfigurationPanel.Create();
var
	i : TSLongWord;
	FCanUse: TSBool;
begin
inherited;
SetBounds(0, 0, 500, TotalHeight);
BoundsMakeReal();
Visible := True;

FFPS := nil;

FCaptionLabel := SCreateLabel(Self, 'Smooth Engine Configuration (' + SVerCPU + ' bit)', True);
FVersionLabel := SCreateLabel(Self, 'Version: ' + SEngineVersion(), True);

FContextsComboBox := SCreateComboBox(Self, TSScreenComboBoxProcedure(@TSEngineConfigurationPanel_ContextsComboBox_OnChange), True, Self);
for i := Low(Contexts) to High(Contexts) do
	begin
	FCanUse := Contexts[i].FClass <> nil;
	if FCanUse then
		FCanUse := Contexts[i].FClass.Supported();
	FContextsComboBox.CreateItem(Contexts[i].FName, nil, -1, FCanUse);
	end;

FRendersComboBox := SCreateComboBox(Self, TSScreenComboBoxProcedure(@TSEngineConfigurationPanel_RendersComboBox_OnChange), True, Self);
for i := Low(Renders) to High(Renders) do
	begin
	FCanUse := Renders[i].FClass <> nil;
	if FCanUse then
		FCanUse := Renders[i].FClass.Supported();
	FRendersComboBox.CreateItem(Renders[i].FName, nil, -1, FCanUse);
	end;

FCloseButton := SCreateButton(Self, 'Close', TSScreenComponentProcedure(@TSEngineConfigurationPanel_CloseButton_OnChange), True, Self);
end;

procedure TSEngineConfigurationPanel.Resize();

const
	ShiftWidth = 40;

procedure ProcessValue(const Value : TSLongWord; var Max : TSLongWord);
begin
if Value > Max then
	Max := Value;
end;

function CalculateRendersComboBoxWidth() : TSLongWord;
var
	i : TSLongWord;
begin
Result := 0;
for i := Low(Renders) to High(Renders) do
	ProcessValue(Skin.Font.StringLength(Renders[i].FName) + ShiftWidth, Result);
end;

function CalculateContextsComboBoxWidth() : TSLongWord;
var
	i : TSLongWord;
begin
Result := 0;
for i := Low(Contexts) to High(Contexts) do
	ProcessValue(Skin.Font.StringLength(Contexts[i].FName) + ShiftWidth, Result);
end;

function CalculateWidth() : TSLongWord;
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
BoundsMakeReal();
FCaptionLabel.SetBounds(0, (FontHeight div 4), Width, FontHeight);
FCaptionLabel.BoundsMakeReal();
FVersionLabel.SetBounds(0, FontHeight * 2 + HeightShift + (FontHeight div 4), Width, FontHeight);
FVersionLabel.BoundsMakeReal();
FContextsComboBox.SetMiddleBounds(CalculateContextsComboBoxWidth(), FontHeight);
FContextsComboBox.Top := (FontHeight * 2 + HeightShift) * 2 + (FontHeight div 4);
FContextsComboBox.BoundsMakeReal();
FRendersComboBox.SetMiddleBounds(CalculateRendersComboBoxWidth(), FontHeight);
FRendersComboBox.Top := (FontHeight * 2 + HeightShift) * 3 + (FontHeight div 4);
FRendersComboBox.BoundsMakeReal();
FCloseButton.SetMiddleBounds(Skin.Font.StringLength(FCloseButton.Caption) + ShiftWidth, FontHeight);
FCloseButton.Top := (FontHeight * 2 + HeightShift) * 4 + (FontHeight div 4);
FCloseButton.BoundsMakeReal();
inherited;
end;

destructor TSEngineConfigurationPanel.Destroy();
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

procedure TSEngineConfigurationPanel.UpDate();
var
	i : TSMaxEnum;
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
inherited;
ToFront();
end;

procedure TSEngineConfigurationPanel.Paint();

function DistanseToQuad(const QuadVertex1, QuadVertex3, Point : TSVertex2f) : TSFloat;
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
	Result := Abs(Point - SVertex2fImport(QuadVertex1.x, QuadVertex3.y))
else if (Point.x > QuadVertex3.x) and (Point.y < QuadVertex1.y) then
	Result := Abs(Point - SVertex2fImport(QuadVertex3.x, QuadVertex1.y))
else
	Result := 0;
end;

const
	Space = 200;

function DistanseToAlpha(const VDistanse : TSFloat) : TSFloat;
begin
if VDistanse > Space then
	Result := 0
else
	Result := (Space - VDistanse) / Space;
end;

function PointToVert3f(const P : TSPoint2int32):TSVertex3f;
begin
Result.Import(P.x, P.y);
end;

procedure DrawFPC(const V1, V2 : TSVertex3f; const Alpha : TSFloat32);
begin
if Context = nil then
	Exit;
if (FFPS = nil) then
	FFPS := TSFPSViewer.Create(Context);
FFPS.x := Trunc(V1.x + (V2.x - V1.x) / 2 - 25);
FFPS.y := Trunc(V1.y + (V2.y - V1.y) / 2 - 70);
(*
FFPS.Alpha := Alpha * 2;
*)
FFPS.Paint();
end;

var
	Vertex1, Vertex2 : TSVertex3f;
	Alpha, Distanse : TSFloat;
	Color : TSColor4f;

begin
Color := FSkin.Colors.FNormal.FFirst.WithAlpha(0.8);
Vertex1 := PointToVert3f(GetVertex([SS_LEFT, SS_TOP], S_VERTEX_FOR_PARENT));
Vertex2 := PointToVert3f(GetVertex([SS_RIGHT, SS_BOTTOM], S_VERTEX_FOR_PARENT));
Distanse := DistanseToQuad(Vertex1, Vertex2, PointToVert3f(Context.CursorPosition())) / 3;
Alpha := DistanseToAlpha(Distanse);
Alpha *= VisibleTimer;

Render.BeginScene(SR_QUADS);

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

(*
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
*)

inherited;

DrawFPC(Vertex1, Vertex2, Alpha);
end;

end.
