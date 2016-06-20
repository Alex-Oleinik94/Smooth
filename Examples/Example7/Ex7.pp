{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex7;
	interface
{$ELSE}
	program Example7;
	{$ENDIF}
uses
	{$IFNDEF ENGINE}
		{$IFDEF UNIX}
			{$IFNDEF ANDROID}
				cthreads,
				{$ENDIF}
			{$ENDIF}
		SaGeBaseExample,
		{$ENDIF}
	 SaGeContextInterface
	,SaGeBased
	,SaGeBase
	,SaGeScreen
	,SaGeUtils
	,SaGeMath
	,SaGeExamples
	,SaGeCommon
	,SaGeRenderConstants
	;
type
	TSGApprFunction = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			public
		FFont : TSGFont;
		FPanelStart : TSGPanel;
		FFunctionEdit,FNumberEdit,FNumberAEdit,FNumberBEdit : TSGEdit;
		FGoButton : TSGButton;
		FBackButton : TSGButton;
		
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

function mmmFNumberEditTextTupeFunction(const Self:TSGEdit):TSGBoolean;
begin
Result:=TSGEditTextTypeFunctionNumber(Self);
if Result and (SGVal(Self.Caption) = 0) then
	Result := False;
end;

function mmmFFunctionEditTextTupeFunction(const Self:TSGEdit):TSGBoolean;
var
	Ex:TSGExpression = nil;
begin
Result := Self.Caption = '';
if not Result then
	begin
	Ex:=TSGExpression.Create();
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

procedure mmmFGoButtonProcedure(Self : TSGButton);
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
	i, ii, iii : LongWord;
begin with TSGApprFunction(Self.FUserPointer1) do begin
Gauss := TSGLineSystem.Create(n);
for i:=0 to n-1 do
	Gauss.b[i] := FArPoints[i].y;
for i:=0 to n-1 do
	for ii:=0 to n-1 do
		Gauss.a[i,ii] := FArPoints[i].x**Single(ii);
Gauss.CalculateRotate();
Result := SGStrExtended(Gauss.x[0],tttt);
for i := 1 to n-1 do
	begin
	if Gauss.x[i]>0 then
		Result+='+';
	Result+=SGStrExtended(Gauss.x[i],tttt)+'*(x^'+SGStr(i)+')';
	end;
Gauss.Destroy();
WriteLn('Mn=',Result);
end;end;

procedure InitGraphicView();
var
	SrX,SrY,r : TSGSingle;
	i : TSGLongWord;
begin with TSGApprFunction(Self.FUserPointer1) do begin
r := abs(MaxAB-MinAB);
SrX:=(MaxAB+MinAB)/2;
SrY:=0;
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

procedure mmmFBackButtonProcedure(Self:TSGButton);
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
FGraphic:=nil;

FFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
FFont.SetContext(Context);
FFont.Loading();
FFont.ToTexture();

FBackButton := TSGButton.Create();
SGScreen.CreateChild(FBackButton);
FBackButton.SetBounds(Render.Width - 230,5 ,220,FFont.FontHeight+4);
FBackButton.BoundsToNeedBounds();
FBackButton.Caption := 'Назад';
FBackButton.Visible:=False;
FBackButton.Anchors:=[SGAnchRight];
FBackButton.Active:=True;
FBackButton.FUserPointer1:=Self;
FBackButton.OnChange:=TSGComponentProcedure(@mmmFBackButtonProcedure);

FPanelStart := TSGPanel.Create();
SGScreen.CreateChild(FPanelStart);
FPanelStart.SetMiddleBounds(400,(FFont.FontHeight+4)*8+5);
FPanelStart.BoundsToNeedBounds();
FPanelStart.Visible := True;
FPanelStart.Active := True;
FPanelStart.Font := FFont;

FPanelStart.CreateChild(TSGLabel.Create());
FPanelStart.LastChild.SetBounds(5,5+(FFont.FontHeight+4)*0,FPanelStart.Width - 12,FFont.FontHeight+2);
FPanelStart.LastChild.BoundsToNeedBounds();
FPanelStart.LastChild.Caption := 'Введите функцию f(x)';
FPanelStart.LastChild.Visible:=True;
FPanelStart.LastChild.Active:=True;

FFunctionEdit:=TSGEdit.Create();
FPanelStart.CreateChild(FFunctionEdit);
FFunctionEdit.SetBounds(5,5+(FFont.FontHeight+4)*1,FPanelStart.Width - 12,FFont.FontHeight+4);
FFunctionEdit.BoundsToNeedBounds();
FFunctionEdit.Visible:=True;
FFunctionEdit.Active:=True;
FFunctionEdit.Caption:='sin(x)';
FFunctionEdit.FUserPointer1:=Self;
FFunctionEdit.TextType:=SGEditTypeUser;
FFunctionEdit.TextTypeFunction:=TSGEditTextTypeFunction(@mmmFFunctionEditTextTupeFunction);
mmmFFunctionEditTextTupeFunction(FFunctionEdit);

FPanelStart.CreateChild(TSGLabel.Create());
FPanelStart.LastChild.SetBounds(5,5+(FFont.FontHeight+4)*2,FPanelStart.Width - 12,FFont.FontHeight+4);
FPanelStart.LastChild.BoundsToNeedBounds();
FPanelStart.LastChild.Caption := 'Введите количество точек';
FPanelStart.LastChild.Visible:=True;
FPanelStart.LastChild.Active:=True;

FNumberEdit:=TSGEdit.Create();
FPanelStart.CreateChild(FNumberEdit);
FNumberEdit.SetBounds(5,5+(FFont.FontHeight+4)*3,FPanelStart.Width - 12,FFont.FontHeight+4);
FNumberEdit.BoundsToNeedBounds();
FNumberEdit.Visible:=True;
FNumberEdit.Active:=True;
FNumberEdit.Caption:='20';
FNumberEdit.FUserPointer1:=Self;
FNumberEdit.TextType:=SGEditTypeUser;
FNumberEdit.TextTypeFunction:=TSGEditTextTypeFunction(@mmmFNumberEditTextTupeFunction);
mmmFNumberEditTextTupeFunction(FNumberEdit);

FPanelStart.CreateChild(TSGLabel.Create());
FPanelStart.LastChild.SetBounds(5,5+(FFont.FontHeight+4)*4,FPanelStart.Width - 12,FFont.FontHeight+4);
FPanelStart.LastChild.BoundsToNeedBounds();
FPanelStart.LastChild.Caption := 'Введите отрезок';
FPanelStart.LastChild.Visible:=True;
FPanelStart.LastChild.Active:=True;

FNumberAEdit:=TSGEdit.Create();
FPanelStart.CreateChild(FNumberAEdit);
FNumberAEdit.SetBounds(5,5+(FFont.FontHeight+4)*5,(FPanelStart.Width - 17) div 2,FFont.FontHeight+4);
FNumberAEdit.BoundsToNeedBounds();
FNumberAEdit.Visible:=True;
FNumberAEdit.Active:=True;
FNumberAEdit.Caption:='-7';
FNumberAEdit.FUserPointer1:=Self;
FNumberAEdit.TextType:=SGEditTypeInteger;

FNumberBEdit:=TSGEdit.Create();
FPanelStart.CreateChild(FNumberBEdit);
FNumberBEdit.SetBounds(5+((FPanelStart.Width - 12) div 2),5+(FFont.FontHeight+4)*5,(FPanelStart.Width - 17) div 2,FFont.FontHeight+4);
FNumberBEdit.BoundsToNeedBounds();
FNumberBEdit.Visible:=True;
FNumberBEdit.Active:=True;
FNumberBEdit.Caption:='7';
FNumberBEdit.FUserPointer1:=Self;
FNumberBEdit.TextType:=SGEditTypeInteger;

FGoButton := TSGButton.Create();
FPanelStart.CreateChild(FGoButton);
FGoButton.SetBounds(5,5+(FFont.FontHeight+4)*6 + 3,FPanelStart.Width - 12,FFont.FontHeight+4);
FGoButton.BoundsToNeedBounds();
FGoButton.Caption := 'Построить';
FGoButton.Visible:=True;
FGoButton.Active:=True;
FGoButton.FUserPointer1:=Self;
FGoButton.OnChange:=TSGComponentProcedure(@mmmFGoButtonProcedure);
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
	ExampleClass := TSGApprFunction;
	RunApplication();
	{$ENDIF}
end.
