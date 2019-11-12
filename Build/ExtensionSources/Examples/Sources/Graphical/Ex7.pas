{$INCLUDE SaGe.inc}
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
	 SaGeContextInterface
	,SaGeContextClasses
	,SaGeBase
	,SaGeFont
	,SaGeMath
	,SaGeGraphicViewer
	,SaGeCommonStructs
	,SaGeRenderBase
	,SaGeScreenBase
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeMathUtils
	,SaGeScreenClasses
	,SaGeScreen_Edit
	{$IF not defined(ENGINE)}
		,SaGeConsolePaintableTools
		,SaGeConsoleCaller
		{$ENDIF}
	;
type
	TSGApprFunction = class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			public
		FFont : TSGFont;
		FPanelStart : TSGScreenPanel;
		FFunctionEdit, FNumberEdit, FNumberAEdit, FNumberBEdit : TSGScreenEdit;
		FGoButton : TSGScreenButton;
		FBackButton : TSGScreenButton;
		
		FGraphic : TSGGraphic;
		FArPoints : packed array of TSGVertex2f;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGApprFunction.ClassName():TSGString;
begin
Result := 'Аппроксимация функций методом Гаусса';
end;

function TSGApprFunction_NumberTextTypeFunction(const Self : TSGScreenEdit):TSGBoolean;
begin
Result := TSGEditTextTypeFunctionNumber(Self);
if (Result and (SGVal(Self.Caption) = 0)) then
	Result := False;
end;

function TSGApprFunction_FunctionTextTypeFunction(const Self : TSGScreenEdit):TSGBoolean;
var
	Ex:TSGExpression = nil;
begin
Result := Self.Caption = '';
if not Result then
	begin
	Ex := TSGExpression.Create();
	Ex.Expression:=SGStringToPChar(Self.Caption);
	Ex.CanculateExpression();
	if (Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1) then
		begin
		Ex.BeginCalculate();
		Ex.ChangeVariables(Ex.Variable,TSGExpressionChunkCreateReal(0));
		Ex.Calculate();
		end;
	if Length(Ex.Variables)=1 then
		TSGApprFunction(Self.FUserPointer1).FPanelStart.Children[1].Caption:='Введите функцию f('+SGPCharToString(Ex.Variable)+')'
	else
		TSGApprFunction(Self.FUserPointer1).FPanelStart.Children[1].Caption:='Введите функцию f(?)';
	Result:=(Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1);
	Ex.Destroy();
	end
else
	begin
	Result:=False;
	TSGApprFunction(Self.FUserPointer1).FPanelStart.Children[1].Caption:='Введите функцию f(?)';
	end;
end;

procedure TSGApprFunction_StartButtonProcedure(Self : TSGScreenButton);
var
	Ex : TSGExpression;
	A,B,MinAB,MaxAB:TSGSingle;
	n : TSGLongWord;

function MyFunction(const x : TSGSingle) : TSGSingle;
begin with TSGApprFunction(Self.FUserPointer1) do begin
Ex.BeginCalculate();
Ex.ChangeVariables(Ex.Variable,TSGExpressionChunkCreateReal(x));
Ex.Calculate();
Result := Ex.Resultat.FConst;
end;end;

function GetInterPaliasionMnogoclen():TSGString;
const
	tttt = 18;
var
	Gauss : TSGLineSystem = nil;
	i, ii : LongWord;
begin with TSGApprFunction(Self.FUserPointer1) do begin
Gauss := TSGLineSystem.Create(n);
for i:=0 to n-1 do
	Gauss.b[i] := FArPoints[i].y;
for i:=0 to n-1 do
	for ii:=0 to n-1 do
		Gauss.a[i,ii] := FArPoints[i].x**Single(ii);
Gauss.CalculateRotate();
Result := SGStrMathFloat(Gauss.x[0],tttt);
for i := 1 to n-1 do
	begin
	if Gauss.x[i]>0 then
		Result+='+';
	Result+=SGStrMathFloat(Gauss.x[i],tttt)+'*(x^'+SGStr(i)+')';
	end;
Gauss.Destroy();
WriteLn('Mn=',Result);
end;end;

procedure InitGraphicView();
var
	SrY,r : TSGSingle;
	i : TSGLongWord;
begin with TSGApprFunction(Self.FUserPointer1) do begin
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
	i: TSGLongWord;
begin with TSGApprFunction(Self.FUserPointer1) do begin
if FNumberEdit.TextComplite and FFunctionEdit.TextComplite and FNumberAEdit.TextComplite and FNumberBEdit.TextComplite  then
	begin
	FPanelStart.Visible := False;
	FBackButton.Visible:=True;
	
	A:=SGVal(FNumberAEdit.Caption);
	B:=SGVal(FNumberBEdit.Caption);
	n:=SGVal(FNumberEdit.Caption);
	if A > B then MinAB := B else MinAB := A;
	if A < B then MaxAB := B else MaxAB := A;
	SetLength(FArPoints,n);
	
	Ex:=TSGExpression.Create();
	Ex.Expression:=SGStringToPChar(FFunctionEdit.Caption);
	Ex.CanculateExpression();
	for i:= 0 to High(FArPoints) do
		begin
		FArPoints[i].x := MinAB + abs(MaxAB-MinAB)*i/High(FArPoints);
		FArPoints[i].y := MyFunction(FArPoints[i].x);
		end;
	
	FGraphic:=TSGGraphic.Create(Context);
	FGraphic.MathGraphics := 2;
	FGraphic.Colors[0].Import(0,1,1,1);
	FGraphic.ArMathGraphics[0].Expression := SGStringToPChar(FFunctionEdit.Caption);
	FGraphic.Colors[1].Import(1,1,0,1);
	FGraphic.ArMathGraphics[1].Expression := SGStringToPChar(GetInterPaliasionMnogoclen());
	FGraphic.Changet := True;
	InitGraphicView();
	
	Ex.Destroy();
	end;
end; end;

procedure TSGApprFunction_BackButtonProcedure(Self:TSGScreenButton);
begin  with TSGApprFunction(Self.FUserPointer1) do begin
FGraphic.Destroy();
FGraphic:=nil;
SetLength(FArPoints,0);
FArPoints:=nil;
FPanelStart.Visible:=True;
FBackButton.Visible:=False;
end; end;

constructor TSGApprFunction.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FGraphic := nil;
FFont := SGCreateFontFromFile(Context, SGFontDirectory + DirectorySeparator + {$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF}, True);

FBackButton := TSGScreenButton.Create();
Screen.CreateChild(FBackButton);
FBackButton.SetBounds(Render.Width - 230,5 ,220,FFont.FontHeight+4);
FBackButton.BoundsMakeReal();
FBackButton.Caption := 'Назад';
FBackButton.Visible:=False;
FBackButton.Anchors:=[SGAnchRight];
FBackButton.Active:=True;
FBackButton.FUserPointer1:=Self;
FBackButton.OnChange:=TSGScreenComponentProcedure(@TSGApprFunction_BackButtonProcedure);

FPanelStart := SGCreatePanel(Screen, 400,(FFont.FontHeight+4)*8+5, FFont, True, True);
SGCreateLabel(FPanelStart, 'Введите функцию f(x)', 5,5+(FFont.FontHeight+4)*0,FPanelStart.Width - 12,FFont.FontHeight+2, True, True);
FFunctionEdit := SGCreateEdit(FPanelStart, 'sin(x)', TSGScreenEditTextTypeFunction(@TSGApprFunction_FunctionTextTypeFunction), 
	5,5+(FFont.FontHeight+4)*1,FPanelStart.Width - 12,FFont.FontHeight+4, [], True, True, Self);
SGCreateLabel(FPanelStart, 'Введите количество точек', 5,5+(FFont.FontHeight+4)*2,FPanelStart.Width - 12,FFont.FontHeight+4, True, True);
FNumberEdit := SGCreateEdit(FPanelStart, '20', TSGScreenEditTextTypeFunction(@TSGApprFunction_NumberTextTypeFunction), 
	5,5+(FFont.FontHeight+4)*3,FPanelStart.Width - 12,FFont.FontHeight+4, [], True, True, Self);
SGCreateLabel(FPanelStart, 'Введите отрезок', 5,5+(FFont.FontHeight+4)*4,FPanelStart.Width - 12,FFont.FontHeight+4, True, True);
FNumberAEdit := SGCreateEdit(FPanelStart, '-7', SGScreenEditTypeInteger, 
	5,5+(FFont.FontHeight+4)*5,(FPanelStart.Width - 17) div 2,FFont.FontHeight+4, [], True, True, Self);
FNumberBEdit := SGCreateEdit(FPanelStart, '7', SGScreenEditTypeInteger, 
	5+((FPanelStart.Width - 12) div 2),5+(FFont.FontHeight+4)*5,(FPanelStart.Width - 17) div 2,FFont.FontHeight+4, [], True, True, Self);

FGoButton := TSGScreenButton.Create();
FPanelStart.CreateChild(FGoButton);
FGoButton.SetBounds(5,5+(FFont.FontHeight+4)*6 + 3,FPanelStart.Width - 12,FFont.FontHeight+4);
FGoButton.BoundsMakeReal();
FGoButton.Caption := 'Построить';
FGoButton.Visible:=True;
FGoButton.Active:=True;
FGoButton.FUserPointer1:=Self;
FGoButton.OnChange:=TSGScreenComponentProcedure(@TSGApprFunction_StartButtonProcedure);
end;

destructor TSGApprFunction.Destroy();
begin
FFont.Destroy();
FPanelStart.Destroy();
FBackButton.Destroy();
if FGraphic<>nil then
	FGraphic.Destroy();
inherited;
end;

procedure TSGApprFunction.Paint();
var
	i : TSGLongWord;
begin
if FGraphic<>nil then
	begin
	FGraphic.Paint();
	
	Render.PointSize(5);
	Render.Color3f(1,0,1);
	Render.BeginScene(SGR_POINTS);
	for i := 0 to High(FArPoints) do
		FGraphic.VertexOnScreen(FArPoints[i]);
	Render.EndScene();
	Render.PointSize(1);
	end;
end;

{$IFNDEF ENGINE}
	begin
	SGConsoleRunPaintable(TSGApprFunction, SGSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
