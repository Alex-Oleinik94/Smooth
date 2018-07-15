{$INCLUDE SaGe.inc}

unit SaGeGraphicViewer;

interface

uses 
	 SaGeBase
	,SaGeContextClasses
	,SaGeScreenClasses
	,SaGeContextInterface
	,SaGeCommon
	,SaGeCommonStructs
	,SaGeMath
	,SaGeFont
	,SaGeImage
	,SaGeRenderBase
	;

type
	TSGGraphic=class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint();override;
			public
		function GetFP(const p1,p2:Extended;const st:LongInt):Single;inline;
		function GetMSD(const r:Extended):LongInt;inline;
		procedure Construct(const VB:Boolean = False);
		function GraphicAssigned:Boolean;
		procedure VertexOnScreen(const Vertex:TSGVertex2f);inline;
		procedure Messages(const VB123:Boolean = False);
			private
		FArMathGraphic : packed array of 
			TSGMathGraphic;
		function Font() : TSGFont;
			public
		View:TSGScreenVertexes;
		Changet:boolean;
		NotUsedInGraphic:Boolean;
		Colors: packed array of
			TSGColor4f;
			private
		function GetMathGraphic():TSGMathGraphic;
		function GetArMathGraphic(Index : TSGLongWord):TSGMathGraphic;
		procedure SetLengthGraphics(Index : TSGLongWord);
		function GetLengthGraphics():TSGLongWord;
		procedure SetArMathGraphic(Index : TSGLongWord;Gr : TSGMathGraphic);
		procedure SetMathGraphic(Gr : TSGMathGraphic);
			public
		property MathGraphic : TSGMathGraphic read GetMathGraphic write SetMathGraphic;
		property ArMathGraphics [ Index : TSGLongWord ] : TSGMathGraphic read GetArMathGraphic write SetArMathGraphic;
		property MathGraphics : TSGLongWord read GetLengthGraphics write SetLengthGraphics;
		end;
	
	//==============
	//TSGGraphViewer
	//==============
	TSGGraphViewer=class(TSGGraphic)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint();override;
			public
		SelectPoint,SelectSecondPoint:TSGPoint2int32;
		SelectPointEnabled:Boolean ;
		Image:TSGImage;
		
		FNewFunctionButton : TSGScreenButton;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeMathUtils
	,SaGeBaseUtils
	,SaGeContextUtils
	;

function VertexFunction(Vertex:TSGVisibleVector;const p:Pointer):TSGVisibleVector;
begin
with TSGGraphViewer(p) do
	begin
	Result.Import(
		((Vertex.x-View.x1)/abs(View.x1-View.x2))*Render.Width,
		Render.Height-((Vertex.y-View.y1)/abs(View.y1-View.y2))*Render.Height);
	Result.Visible:=Vertex.Visible;
	end;
end;

procedure TSGGraphic.VertexOnScreen(const Vertex:TSGVertex2f);
begin
Render.Vertex2f(
		((Vertex.x-View.x1)/abs(View.x1-View.x2))*Render.Width,
		Render.Height-((Vertex.y-View.y1)/abs(View.y1-View.y2))*Render.Height);
end;

function TSGGraphic.GraphicAssigned:Boolean;
begin
Result:=(MathGraphic<>nil) and(MathGraphic.Assigned); 
end;

function TSGGraphic.GetMathGraphic():TSGMathGraphic;
begin
Result:=FArMathGraphic[0];
end;

function TSGGraphic.GetArMathGraphic(Index : TSGLongWord):TSGMathGraphic;
begin
Result:=FArMathGraphic[Index];
end;

procedure TSGGraphic.SetLengthGraphics(Index : TSGLongWord);
var
	i,ii : TSGLongWord;
begin
ii := MathGraphics;
SetLength(FArMathGraphic,Index);
SetLength(Colors,Index);
if ii<MathGraphics then
	for i:=ii to MathGraphics-1 do
		begin
		Colors[i].Import(random,random,random,1);
		FArMathGraphic[i] := TSGMathGraphic.Create();
		FArMathGraphic[i].SetContext(Context);
		FArMathGraphic[i].Expression := 'x*sin(x)';
		FArMathGraphic[i].Complexity:= Render.Width;
		FArMathGraphic[i].VertexFunction:=@VertexFunction;
		FArMathGraphic[i].VertexFunctionPointer:=Self;
		end;
end;

function TSGGraphic.GetLengthGraphics():TSGLongWord;
begin
if FArMathGraphic = nil then
	Result:=0
else
	Result := Length(FArMathGraphic);
end;

procedure TSGGraphic.SetArMathGraphic(Index : TSGLongWord;Gr : TSGMathGraphic);
begin
FArMathGraphic[Index]:=Gr;
end;

procedure TSGGraphic.SetMathGraphic(Gr : TSGMathGraphic);
begin
FArMathGraphic[0]:=Gr;
end;

constructor TSGGraphic.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FArMathGraphic:=nil;
NotUsedInGraphic:=True;

MathGraphics:=1;

View.Import(-15,-15*(Render.Height/Render.Width),15,15*(Render.Height/Render.Width));

Changet:=False;
end;

destructor TSGGraphic.Destroy();
var
	i  : TSGLongWord;
begin
for i:=0 to MathGraphics-1 do
	if ArMathGraphics[i] <> nil then
		ArMathGraphics[i].Destroy;
SetLength(Colors,0);
MathGraphics := 0;
inherited;
end;

class function TSGGraphic.ClassName:string;
begin
Result:='Graphic';
end;

function TSGGraphic.GetMSD(const r:Extended):LongInt;inline;
begin
Result:=1;
if r > 10 then
	begin
	while (10.0**Result)*2.4 <r do
		Result+=1;
	Result-=1;
	end
else
	begin
	while (10.0**Result)*2.4 > r do
		Result-=1;
	end;
end;

function TSGGraphic.GetFP(const p1,p2:Extended;const st:LongInt):Single;inline;
var
	c:Extended;
begin
c:=(10.0**st);
Result:=Trunc(p1 / c)*(c);
if p1>0 then 
	Result+=c;
end;

procedure TSGGraphic.Messages(const VB123:Boolean = False);
begin
if (VB123=False) and NotUsedInGraphic then
	NotUsedInGraphic:=False;
case Context.CursorWheel of
SGDownCursorWheel:
	begin
	View*=0.9;
	Changet:=True;
	end;
SGUpCursorWheel:
	begin
	View*=1.1;
	Changet:=True;
	end;
end;
if Context.CursorKeysPressed(SGLeftCursorButton) then
	begin
	View.SumX:= -Context.CursorPosition(SGDeferenseCursorPosition).x/Render.Width*abs(View.x1-View.x2);
	View.SumY:= Context.CursorPosition(SGDeferenseCursorPosition).y/Render.Height*abs(View.y1-View.y2);
	Changet:=True;
	end;
end;

procedure TSGGraphic.Construct(const VB:Boolean = False);
var
	i : TSGLongWord;
begin
if Changet or VB then
	begin
	if MathGraphics<>0 then
		for i:=0 to MathGraphics-1 do
			if ArMathGraphics[i]<>nil then
				ArMathGraphics[i].Construct(View.x1,View.x2);
	Changet:=False;
	end;
end;

procedure TSGGraphic.Paint();
var
	msd:LongInt;
	c,q,q1,q2:TSGMathFloat;
	i:LongWord;
	Absx,Absy,k1,k2,k3:TSGMathFloat;

function SGStTen(const a:Int64):String;
var
	i:longint;
begin
if a=0 then
	Result:='1'
else if a>0 then
	begin
	Result:='1';
	for i:=1 to a do
		Result+='0';
	end
else
	begin
	Result:='0.';
	for i:=-2 downto a do
		Result+='0';
	Result+='1';
	end;
end;

begin
if NotUsedInGraphic then
	Messages(True);
if NotUsedInGraphic then
	Construct(not GraphicAssigned);

Render.InitMatrixMode(SG_2D);
Render.BeginScene(SGR_LINES);

AbsX:=abs(View.x1-View.x2);
AbsY:=abs(View.y1-View.y2);

msd:=Min(GetMSD(AbsX),GetMSD(AbsY));
k1:=Abs((View.x2/AbsX-1));
k2:=Abs(((View.x2-View.x1)/AbsX-1+View.x2/AbsX));
for i:=0 to 1 do
	begin
	q:=GetFP(View.y1,View.y2,msd-i);
	if i=1 then
		q1:=q;
	c:=(10.0**Real((msd-i)));
	while q < View.y2 do
		begin
		k3:=Abs(1-(q-View.y1)/AbsY-View.y2/AbsY);
		if View.x1<0 then
			begin
			Render.Color4f(
				k3/(k1+k3),
				k1/(k1+k3),
				0,(2-i)/2);
			Render.Vertex2f(0
				,Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			Render.Color4f(1,0,0,(2-i)/2);
			Render.Vertex2f(Round(Render.Width-View.x2/AbsX*Render.Width)
				,Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			end;
		if View.x2>0 then
			begin
			Render.Color4f(1,0,0,(2-i)/2);
			Render.Vertex2f(Round(Render.Width-View.x2/AbsX*Render.Width),Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			Render.Color4f(
				k3/(k2+k3),
				k2/(k2+k3),
				0,(2-i)/2);
			Render.Vertex2f( Render.Width,Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			end;
		q+=c;
		end;
	end;

k1:=Abs(1-(View.y2-View.y1)/AbsY-View.y2/AbsY);
k2:=Abs(1-View.y2/AbsY);
for i:=0 to 1 do
	begin
	q:=GetFP(View.x1,View.x2,msd-i);
	c:=(10.0**Real((msd-i)));
	if i=1 then
		q2:=q;
	while q < View.x2 do
		begin
		k3:=Abs((q-View.x1)/AbsX-1+View.x2/AbsX);
		if View.y2>0 then
			begin
			Render.Color4f(
				k1/(k1+k3),
				k3/(k1+k3),
				0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/absx*Render.Width),0);
			Render.Color4f(0,1,0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/absx*Render.Width),
				Round(View.y2/absy*Render.Height));
			end;
		if View.y1<0 then
			begin
			Render.Color4f(0,1,0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/AbsX*Render.Width),
				Round(View.y2/AbsY*Render.Height));
			Render.Color4f(k2/(k2+k3),k3/(k2+k3),0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/AbsX*Render.Width),Round(Render.Height));
			end;
		q+=c;
		end;
	end;
c:=(10.0**(msd));

Render.Color4f(0,1,0,1);
Render.Vertex3f(0,			   Round(View.y2/absy*Render.Height),0);
Render.Vertex3f(Render.Width,Round(View.y2/absy*Render.Height),0);
Render.Color4f(1,0,0,1);
Render.Vertex3f(Render.Width-Round(View.x2/absx*Render.Width),0,0);
Render.Vertex3f(Render.Width-Round(View.x2/absx*Render.Width),Render.Height,0);
Render.EndScene();

if MathGraphics<>0 then
	for i:=0 to MathGraphics-1 do
		if ArMathGraphics[i]<>nil then
			begin
			Render.Color(Colors[i]);
			ArMathGraphics[i].Paint();
			end;

if Abs(q1-View.y1)<c*0.2 then
	q1+=c*0.5;
if Abs(q2-View.x1)<c*0.2 then
	q2+=c*0.1;

Render.Color4f(0.5,0.5,1,1);
Render.LineWidth(3);
Render.BeginScene(SGR_LINES);
Render.Vertex2f(		((q2-View.x1)/absx)*Render.Width,
				Render.Height-(q1-View.y1)/absy*Render.Height);
Render.Vertex2f(		(q2+c-View.x1)/absx*Render.Width,
				Render.Height-(q1-View.y1)/AbsY*Render.Height);
Render.EndScene();

Font.DrawFontFromTwoVertex2f(SGStTen(msd),
	SGVertex2fImport(1+(q2-View.x1)/absx*Render.Width,
				Render.Height-(q1-View.y1)/absy*Render.Height),
	SGVertex2fImport((q2+c*3-View.x1)/AbsX*Render.Width,
				Font.FontHeight+Render.Height-(q1-View.y1)/AbsY*Render.Height),
				False,False);

q:=GetFP(View.x1,View.x2,msd);
while q < View.x2 do
	begin
	Font.DrawFontFromTwoVertex2f((SGStrMathFloat(q, Abs(Min(0,msd)))),
		SGVertex2fImport((q-View.x1)/absx*Render.Width+2
			,View.y2/absy*Render.Height),
		SGVertex2fImport((q-View.x1)/absx*Render.Width+500
			,View.y2/absy*Render.Height+Font.FontHeight),
		False,False);
	q+=c;
	end;

q:=GetFP(View.y1,View.y2,msd);
while q < View.y2 do
	begin
	Font.DrawFontFromTwoVertex2f((SGStrMathFloat(q, Abs(Min(0,msd)))),
		SGVertex2fImport(Render.Width-View.x2/AbsX*Render.Width+2
			,Render.Height-(q-View.y1)/Absy*Render.Height),
		SGVertex2fImport(Render.Width-View.x2/absx*Render.Width+500
			,Render.Height-(q-View.y1)/absy*Render.Height+Font.FontHeight),
		False,False);
	q+=c;
	end;
end;

function TSGGraphic.Font() : TSGFont;
begin
Result := (Screen as TSGScreenComponent).Skin.Font
end;

//======================================================================================
//======================================================================================
//====================================TSGGraphViewer====================================
//======================================================================================
//======================================================================================

procedure TSGGraphViewer_FormClose(Button:TSGScreenComponent);
begin
TSGGraphViewer(Button.FUserPointer1).FNewFunctionButton.Active := True;
Button.Parent.MarkForDestroy();
end;

procedure GoNewGrafic2(Button:TSGScreenComponent);
var
	EulatuonEdit2 : TSGScreenEdit = nil;
begin
with TSGGraphViewer(Button.FUserPointer1) do
	begin
	EulatuonEdit2 := (Button.Parent.Children[1] as TSGScreenEdit);
	MathGraphics := MathGraphics + 1;
	ArMathGraphics[MathGraphics - 1].Expression := SGStringToPChar(EulatuonEdit2.Caption);
	View.Import(-15,-15*(Render.Height/Render.Width),15,15*(Render.Height/Render.Width));
	MathGraphic.Construct(View.x1,View.x2);
	Changet := True;
	
	FNewFunctionButton.Active := True;
	end;
end;

procedure mmmComboBoxProcedure1234567(a,b:LongInt;VComboBox:TSGScreenComboBox);
begin with TSGGraphViewer(VComboBox.FUserPointer1) do begin
	(VComboBox.Parent.Children[3] as TSGScreenEdit).Active := Boolean(b);
end; end;


procedure GoNewFunction(Button:TSGScreenComponent);
var
	Form : TSGScreenForm = nil;
begin
with TSGGraphViewer(Button.FUserPointer1) do
	begin
	Button.Active := False;
	
	Form := TSGScreenForm.Create();
	Screen.CreateChild(Form);
	Form.SetMiddleBounds(400,133);
	Form.BoundsMakeReal();
	Form.Visible := True;
	Form.Active := True;
	Form.Caption := 'Добавление функции';
	Form.FUserPointer1 := Button.FUserPointer1;
	
	SGCreateEdit(Form, 'x*sin(x)', 5,5,380,25, True, True);
	
	Form.CreateChild(TSGScreenComboBox.Create());
	Form.LastChild.SetBounds(5,35,300,25);
	Form.LastChild.Visible:=True;
	Form.LastChild.Active:=True;
	(Form.LastChild as TSGScreenComboBox).CreateItem('Функция');
	(Form.LastChild as TSGScreenComboBox).CreateItem('Производная функции');
	(Form.LastChild as TSGScreenComboBox).SelectItem := 0;
	(Form.LastChild as TSGScreenComboBox).CallBackProcedure:=TSGScreenComboBoxProcedure(@mmmComboBoxProcedure1234567);
	Form.LastChild.FUserPointer1 := Button.FUserPointer1;
	
	SGCreateEdit(Form, '0', SGScreenEditTypeNumber, 310,35,75,25, [], True, True);
	Form.LastChild.Active:=False;
	
	Form.CreateChild(TSGScreenButton.Create());
	Form.LastChild.SetBounds(5,65,188,25);
	Form.LastChild.Visible := True;
	Form.LastChild.Active  := True;
	Form.LastChild.Caption := 'Добавить';
	(Form.LastChild as TSGScreenButton).OnChange := TSGScreenComponentProcedure(@GoNewGrafic2);
	Form.LastChild.FUserPointer1 := Button.FUserPointer1;
	
	Form.CreateChild(TSGScreenButton.Create());
	Form.LastChild.SetBounds(195,65,190,25);
	Form.LastChild.Visible := True;
	Form.LastChild.Active  := True;
	Form.LastChild.Caption := 'Отмена';
	Form.LastChild.FUserPointer1 := Button.FUserPointer1;
	(Form.LastChild as TSGScreenButton).OnChange := TSGScreenComponentProcedure(@TSGGraphViewer_FormClose);
	end;
end;

constructor TSGGraphViewer.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
SelectPointEnabled:=False;
Image:=nil;

Image:=TSGImage.Create(SGTextureDirectory + DirectorySeparator + 'IconArea-hover.png');
Image.SetContext(Context);
Image.Loading;

FNewFunctionButton:=TSGScreenButton.Create;
Screen.CreateChild(FNewFunctionButton);
Screen.LastChild.SetBounds(Render.Width-140,Render.Height-28,130,23);
Screen.LastChild.Visible:=True;
Screen.LastChild.Caption:='Добавить функцию';
Screen.LastChild.OnChange:=TSGScreenComponentProcedure(@GoNewFunction);
Screen.LastChild.FUserPointer1:=Self;
end;

destructor TSGGraphViewer.Destroy;
begin
FNewFunctionButton.Destroy();
Image.Destroy;
inherited;
end;


class function TSGGraphViewer.ClassName():TSGString;
begin
Result:='Graphic Viewer';
end;

procedure TSGGraphViewer.Paint();
var
	Changet2:boolean = False;
begin
inherited;

if Context.CursorKeysPressed(SGRightCursorButton)  then
	begin
	SelectPointEnabled:=True;
	SelectPoint:=Context.CursorPosition;
	end;
if SelectPointEnabled then
	begin
	SelectSecondPoint:=Context.CursorPosition;
	if Image.ReadyTexture then
		begin
		Render.Color4f(0,0.5,0.70,0.6);
		Image.DrawImageFromTwoPoint2int32(SelectPoint,SelectSecondPoint,True,SG_2D)
		end
	else
		begin
		Render.Color4f(0,0.5,0.70,0.6);
		Render.BeginScene(SGR_QUADS);
		Render.Vertex(SelectPoint);
		Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
		Render.Vertex(SelectSecondPoint);
		Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
		Render.EndScene();
		end;
	end;
if SelectPointEnabled and (Context.CursorKeysPressed(SGLeftCursorButton)) then
	begin
	SelectPointEnabled:=False;
	if SelectPoint.x>SelectSecondPoint.x then
		Swap(SelectPoint.x,SelectSecondPoint.x);
	if SelectPoint.y>SelectSecondPoint.y then
		Swap(SelectPoint.y,SelectSecondPoint.y);
	View.Import(
		View.x1+abs(View.x1-View.x2)*SelectPoint.x/Render.Width,
		View.y1+abs(View.y1-View.y2)*(Render.Height-SelectSecondPoint.y)/Render.Height,
		View.x1+abs(View.x1-View.x2)*SelectSecondPoint.x/Render.Width,
		View.y1+abs(View.y1-View.y2)*(Render.Height-SelectPoint.y)/Render.Height);
	Changet2:=True;
	end;

if Changet2 then
	begin
	MathGraphic.Construct(View.x1,View.x2);
	end;

if (Context.KeyPressedChar=#27) and (Context.KeyPressedType=SGDownKey) then
	if SelectPointEnabled then 
		SelectPointEnabled:=False;
end;

end.
