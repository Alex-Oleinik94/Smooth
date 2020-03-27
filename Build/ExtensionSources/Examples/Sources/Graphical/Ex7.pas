{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex7;
	interface
{$ELSE}
	program Example7;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothFont
	,SmoothMath
	,SmoothGraphicViewer
	,SmoothCommonStructs
	,SmoothRenderBase
	,SmoothScreenBase
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothMathUtils
	,SmoothScreenClasses
	,SmoothScreen_Edit
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleCaller
		{$ENDIF}
	;
type
	TSApprFunction = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			public
		FFont : TSFont;
		FPanelStart : TSScreenPanel;
		FFunctionEdit, FNumberEdit, FNumberAEdit, FNumberBEdit : TSScreenEdit;
		FGoButton : TSScreenButton;
		FBackButton : TSScreenButton;
		
		FGraphic : TSGraphic;
		FArPoints : packed array of TSVertex2f;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSApprFunction.ClassName():TSString;
begin
Result := 'Аппроксимация функций методом Гаусса';
end;

function TSApprFunction_NumberTextTypeFunction(const Self : TSScreenEdit):TSBoolean;
begin
Result := TSEditTextTypeFunctionNumber(Self);
if (Result and (SVal(Self.Caption) = 0)) then
	Result := False;
end;

function TSApprFunction_FunctionTextTypeFunction(const Self : TSScreenEdit):TSBoolean;
var
	Ex:TSExpression = nil;
begin
Result := Self.Caption = '';
if not Result then
	begin
	Ex := TSExpression.Create();
	Ex.Expression:=SStringToPChar(Self.Caption);
	Ex.CanculateExpression();
	if (Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1) then
		begin
		Ex.BeginCalculate();
		Ex.ChangeVariables(Ex.Variable,TSExpressionChunkCreateReal(0));
		Ex.Calculate();
		end;
	if Length(Ex.Variables)=1 then
		TSApprFunction(Self.FUserPointer1).FPanelStart.Children[1].Caption:='Введите функцию f('+SPCharToString(Ex.Variable)+')'
	else
		TSApprFunction(Self.FUserPointer1).FPanelStart.Children[1].Caption:='Введите функцию f(?)';
	Result:=(Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1);
	Ex.Destroy();
	end
else
	begin
	Result:=False;
	TSApprFunction(Self.FUserPointer1).FPanelStart.Children[1].Caption:='Введите функцию f(?)';
	end;
end;

procedure TSApprFunction_StartButtonProcedure(Self : TSScreenButton);
var
	Ex : TSExpression;
	A,B,MinAB,MaxAB:TSSingle;
	n : TSLongWord;

function MyFunction(const x : TSSingle) : TSSingle;
begin with TSApprFunction(Self.FUserPointer1) do begin
Ex.BeginCalculate();
Ex.ChangeVariables(Ex.Variable,TSExpressionChunkCreateReal(x));
Ex.Calculate();
Result := Ex.Resultat.FConst;
end;end;

function GetInterPaliasionMnogoclen():TSString;
const
	tttt = 18;
var
	Gauss : TSLineSystem = nil;
	i, ii : LongWord;
begin with TSApprFunction(Self.FUserPointer1) do begin
Gauss := TSLineSystem.Create(n);
for i:=0 to n-1 do
	Gauss.b[i] := FArPoints[i].y;
for i:=0 to n-1 do
	for ii:=0 to n-1 do
		Gauss.a[i,ii] := FArPoints[i].x**Single(ii);
Gauss.CalculateRotate();
Result := SStrMathFloat(Gauss.x[0],tttt);
for i := 1 to n-1 do
	begin
	if Gauss.x[i]>0 then
		Result+='+';
	Result+=SStrMathFloat(Gauss.x[i],tttt)+'*(x^'+SStr(i)+')';
	end;
Gauss.Destroy();
WriteLn('Mn=',Result);
end;end;

procedure InitGraphicView();
var
	SrY,r : TSSingle;
	i : TSLongWord;
begin with TSApprFunction(Self.FUserPointer1) do begin
r := abs(MaxAB-MinAB);
for i := 0 to High(FArPoints) do
	SrY += FArPoints[i].y;
SrY /= Length(FArPoints);
FGraphic.View.Import(
	MinAB - r/3, SrY-0.5*r ,
	MaxAB + r/3, SrY+0.5*r
	);
end; end;
var
	i: TSLongWord;
begin with TSApprFunction(Self.FUserPointer1) do begin
if FNumberEdit.TextComplite and FFunctionEdit.TextComplite and FNumberAEdit.TextComplite and FNumberBEdit.TextComplite  then
	begin
	FPanelStart.Visible := False;
	FBackButton.Visible:=True;
	
	A:=SVal(FNumberAEdit.Caption);
	B:=SVal(FNumberBEdit.Caption);
	n:=SVal(FNumberEdit.Caption);
	if A > B then MinAB := B else MinAB := A;
	if A < B then MaxAB := B else MaxAB := A;
	SetLength(FArPoints,n);
	
	Ex:=TSExpression.Create();
	Ex.Expression:=SStringToPChar(FFunctionEdit.Caption);
	Ex.CanculateExpression();
	for i:= 0 to High(FArPoints) do
		begin
		FArPoints[i].x := MinAB + abs(MaxAB-MinAB)*i/High(FArPoints);
		FArPoints[i].y := MyFunction(FArPoints[i].x);
		end;
	
	FGraphic:=TSGraphic.Create(Context);
	FGraphic.MathGraphics := 2;
	FGraphic.Colors[0].Import(0,1,1,1);
	FGraphic.ArMathGraphics[0].Expression := SStringToPChar(FFunctionEdit.Caption);
	FGraphic.Colors[1].Import(1,1,0,1);
	FGraphic.ArMathGraphics[1].Expression := SStringToPChar(GetInterPaliasionMnogoclen());
	FGraphic.Changet := True;
	InitGraphicView();
	
	Ex.Destroy();
	end;
end; end;

procedure TSApprFunction_BackButtonProcedure(Self:TSScreenButton);
begin  with TSApprFunction(Self.FUserPointer1) do begin
FGraphic.Destroy();
FGraphic:=nil;
SetLength(FArPoints,0);
FArPoints:=nil;
FPanelStart.Visible:=True;
FBackButton.Visible:=False;
end; end;

constructor TSApprFunction.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FGraphic := nil;
FFont := SCreateFontFromFile(Context, SDefaultFontFileName, True);

FBackButton := TSScreenButton.Create();
Screen.CreateChild(FBackButton);
FBackButton.SetBounds(Render.Width - 230,5 ,220,FFont.FontHeight+4);
FBackButton.BoundsMakeReal();
FBackButton.Caption := 'Назад';
FBackButton.Visible:=False;
FBackButton.Anchors:=[SAnchRight];
FBackButton.Active:=True;
FBackButton.FUserPointer1:=Self;
FBackButton.OnChange:=TSScreenComponentProcedure(@TSApprFunction_BackButtonProcedure);

FPanelStart := SCreatePanel(Screen, 400,(FFont.FontHeight+4)*8+5, FFont, True, True);
SCreateLabel(FPanelStart, 'Введите функцию f(x)', 5,5+(FFont.FontHeight+4)*0,FPanelStart.Width - 12,FFont.FontHeight+2, True, True);
FFunctionEdit := SCreateEdit(FPanelStart, 'sin(x)', TSScreenEditTextTypeFunction(@TSApprFunction_FunctionTextTypeFunction), 
	5,5+(FFont.FontHeight+4)*1,FPanelStart.Width - 12,FFont.FontHeight+4, [], True, True, Self);
SCreateLabel(FPanelStart, 'Введите количество точек', 5,5+(FFont.FontHeight+4)*2,FPanelStart.Width - 12,FFont.FontHeight+4, True, True);
FNumberEdit := SCreateEdit(FPanelStart, '20', TSScreenEditTextTypeFunction(@TSApprFunction_NumberTextTypeFunction), 
	5,5+(FFont.FontHeight+4)*3,FPanelStart.Width - 12,FFont.FontHeight+4, [], True, True, Self);
SCreateLabel(FPanelStart, 'Введите отрезок', 5,5+(FFont.FontHeight+4)*4,FPanelStart.Width - 12,FFont.FontHeight+4, True, True);
FNumberAEdit := SCreateEdit(FPanelStart, '-7', SScreenEditTypeInteger, 
	5,5+(FFont.FontHeight+4)*5,(FPanelStart.Width - 17) div 2,FFont.FontHeight+4, [], True, True, Self);
FNumberBEdit := SCreateEdit(FPanelStart, '7', SScreenEditTypeInteger, 
	5+((FPanelStart.Width - 12) div 2),5+(FFont.FontHeight+4)*5,(FPanelStart.Width - 17) div 2,FFont.FontHeight+4, [], True, True, Self);

FGoButton := TSScreenButton.Create();
FPanelStart.CreateChild(FGoButton);
FGoButton.SetBounds(5,5+(FFont.FontHeight+4)*6 + 3,FPanelStart.Width - 12,FFont.FontHeight+4);
FGoButton.BoundsMakeReal();
FGoButton.Caption := 'Построить';
FGoButton.Visible:=True;
FGoButton.Active:=True;
FGoButton.FUserPointer1:=Self;
FGoButton.OnChange:=TSScreenComponentProcedure(@TSApprFunction_StartButtonProcedure);
end;

destructor TSApprFunction.Destroy();
begin
FFont.Destroy();
FPanelStart.Destroy();
FBackButton.Destroy();
if FGraphic<>nil then
	FGraphic.Destroy();
inherited;
end;

procedure TSApprFunction.Paint();
var
	i : TSLongWord;
begin
if FGraphic<>nil then
	begin
	FGraphic.Paint();
	
	Render.PointSize(5);
	Render.Color3f(1,0,1);
	Render.BeginScene(SR_POINTS);
	for i := 0 to High(FArPoints) do
		FGraphic.VertexOnScreen(FArPoints[i]);
	Render.EndScene();
	Render.PointSize(1);
	end;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSApprFunction, SSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
