
{$IFDEF SGREADINTERFACE}
type
	TSGGraphic=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
			public
		function GetFP(const p1,p2:Extended;const st:LongInt):Single;inline;
		function GetMSD(const r:Extended):LongInt;inline;
		procedure Construct(const VB:Boolean = False);
		function GraphicAssigned:Boolean;
		procedure VertexOnScreen(const Vertex:TSGVertex2f);inline;
		procedure Messages(const VB123:Boolean = False);
			public
		MathGraphic:TSGMathGraphic;
		View:TSGScreenVertexes;
		Changet:boolean;
		NotUsedInGraphic:Boolean;
		end;
	
	//==============
	//TSGGraphViewer
	//==============
	TSGGraphViewer=class(TSGGraphic)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
			public
		SelectPoint,SelectSecondPoint:SGPoint;
		SelectPointEnabled:Boolean ;
		Image:TSGImage;
		
		EulatuonEdit:TSGEdit ;
		EulatuonLabel:TSGLabel ;
		Fb2:TSGButton;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}
function VertexFunction(Vertex:TSGVisibleVertex;const p:Pointer):TSGVisibleVertex;
begin
with TSGGraphViewer(p) do
	begin
	Result.Import(
		((Vertex.x-View.x1)/abs(View.x1-View.x2))*Context.Width,
		Context.Height-((Vertex.y-View.y1)/abs(View.y1-View.y2))*Context.Height);
	Result.Visible:=Vertex.Visible;
	end;
end;

procedure TSGGraphic.VertexOnScreen(const Vertex:TSGVertex2f);
begin
Render.Vertex2f(
		((Vertex.x-View.x1)/abs(View.x1-View.x2))*Context.Width,
		Context.Height-((Vertex.y-View.y1)/abs(View.y1-View.y2))*Context.Height);
end;

function TSGGraphic.GraphicAssigned:Boolean;
begin
Result:=(MathGraphic<>nil) and(MathGraphic.Assigned); 
end;

constructor TSGGraphic.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
MathGraphic:=nil;
NotUsedInGraphic:=True;
MathGraphic:=TSGMathGraphic.Create;
MathGraphic.SetContext(Context);
MathGraphic.Expression:='x*sinx';
MathGraphic.Complexity:=Context.Width;
MathGraphic.VertexFunction:=@VertexFunction;
MathGraphic.VertexFunctionPointer:=Self;
View.Import(-15,-15*(Context.Height/Context.Width),15,15*(Context.Height/Context.Width));
Changet:=False;
end;

destructor TSGGraphic.Destroy;
begin
MathGraphic.Destroy;
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
	View.SumX:= -Context.CursorPosition(SGDeferenseCursorPosition).x/Context.Width*abs(View.x1-View.x2);
	View.SumY:= Context.CursorPosition(SGDeferenseCursorPosition).y/Context.Height*abs(View.y1-View.y2);
	Changet:=True;
	end;
end;

procedure TSGGraphic.Construct(const VB:Boolean = False);
begin
if Changet or VB then
	begin
	MathGraphic.Construct(View.x1,View.x2);
	Changet:=False;
	end;
end;

procedure TSGGraphic.Draw;
var
	msd:LongInt;
	c,q,q1,q2:TSGExtended;
	i:LongWord;
	Absx,Absy,k1,k2,k3:TSGExtended;

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

msd:=SGMin(GetMSD(AbsX),GetMSD(AbsY));
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
				,Round(Context.Height-(q-View.y1)/AbsY*Context.Height));
			Render.Color4f(1,0,0,(2-i)/2);
			Render.Vertex2f(Round(Context.Width-View.x2/AbsX*Context.Width)
				,Round(Context.Height-(q-View.y1)/AbsY*Context.Height));
			end;
		if View.x2>0 then
			begin
			Render.Color4f(1,0,0,(2-i)/2);
			Render.Vertex2f(Round(Context.Width-View.x2/AbsX*Context.Width),Round(Context.Height-(q-View.y1)/AbsY*Context.Height));
			Render.Color4f(
				k3/(k2+k3),
				k2/(k2+k3),
				0,(2-i)/2);
			Render.Vertex2f( Context.Width,Round(Context.Height-(q-View.y1)/AbsY*Context.Height));
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
			Render.Vertex2f(Round((q-View.x1)/absx*Context.Width),0);
			Render.Color4f(0,1,0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/absx*Context.Width),
				Round(View.y2/absy*Context.Height));
			end;
		if View.y1<0 then
			begin
			Render.Color4f(0,1,0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/AbsX*Context.Width),
				Round(View.y2/AbsY*Context.Height));
			Render.Color4f(k2/(k2+k3),k3/(k2+k3),0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/AbsX*Context.Width),Round(Context.Height));
			end;
		q+=c;
		end;
	end;
c:=(10.0**(msd));

Render.Color4f(0,1,0,1);
Render.Vertex3f(0,			   Round(View.y2/absy*Context.Height),0);
Render.Vertex3f(Context.Width,Round(View.y2/absy*Context.Height),0);
Render.Color4f(1,0,0,1);
Render.Vertex3f(Context.Width-Round(View.x2/absx*Context.Width),0,0);
Render.Vertex3f(Context.Width-Round(View.x2/absx*Context.Width),Context.Height,0);
Render.EndScene();

Render.Color4f(1,1,1,1);
if MathGraphic<>nil then
	MathGraphic.Draw;

if Abs(q1-View.y1)<c*0.2 then
	q1+=c*0.5;
if Abs(q2-View.x1)<c*0.2 then
	q2+=c*0.1;

Render.Color4f(0.5,0.5,1,1);
Render.LineWidth(3);
Render.BeginScene(SGR_LINES);
Render.Vertex2f(		((q2-View.x1)/absx)*Context.Width,
				Context.Height-(q1-View.y1)/absy*Context.Height);
Render.Vertex2f(		(q2+c-View.x1)/absx*Context.Width,
				Context.Height-(q1-View.y1)/AbsY*Context.Height);
Render.EndScene();

SGScreen.Font.DrawFontFromTwoVertex2f(SGStTen(msd),
	SGVertex2fImport(1+(q2-View.x1)/absx*Context.Width,
				Context.Height-(q1-View.y1)/absy*Context.Height),
	SGVertex2fImport((q2+c*3-View.x1)/AbsX*Context.Width,
				SGScreen.Font.FontHeight+Context.Height-(q1-View.y1)/AbsY*Context.Height),
				False,False);

q:=GetFP(View.x1,View.x2,msd);
while q < View.x2 do
	begin
	SGScreen.Font.DrawFontFromTwoVertex2f((SGStrExtended(q,Abs(SGMin(0,msd)))),
		SGVertex2fImport((q-View.x1)/absx*Context.Width+2
			,View.y2/absy*Context.Height),
		SGVertex2fImport((q-View.x1)/absx*Context.Width+500
			,View.y2/absy*Context.Height+SGScreen.Font.FontHeight),
		False,False);
	q+=c;
	end;

q:=GetFP(View.y1,View.y2,msd);
while q < View.y2 do
	begin
	SGScreen.Font.DrawFontFromTwoVertex2f((SGStrExtended(q,Abs(SGMin(0,msd)))),
		SGVertex2fImport(Context.Width-View.x2/AbsX*Context.Width+2
			,Context.Height-(q-View.y1)/Absy*Context.Height),
		SGVertex2fImport(Context.Width-View.x2/absx*Context.Width+500
			,Context.Height-(q-View.y1)/absy*Context.Height+SGScreen.Font.FontHeight),
		False,False);
	q+=c;
	end;
end;

//======================================================================================
//======================================================================================
//====================================TSGGraphViewer====================================
//======================================================================================
//======================================================================================
procedure GoNewGrafic(Button:TSGComponent);
begin
with TSGGraphViewer(Button.FUserPointer1) do
	begin
	MathGraphic.Expression:=SGSTringToPChar(EulatuonEdit.Caption);
	View.Import(-15,-15*(Context.Height/Context.Width),15,15*(Context.Height/Context.Width));
	MathGraphic.Construct(View.x1,View.x2);
	EulatuonLabel.Caption:=EulatuonEdit.Caption;
	EulatuonEdit.Caption:='';
	end;
end;

constructor TSGGraphViewer.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
SelectPointEnabled:=False;
Image:=nil;
EulatuonEdit:=nil;
EulatuonLabel:=nil;

Image:=TSGImage.Create(SGTextureDirectory+Slash+'IconArea-hover.png');
Image.SetContext(Context);
Image.Loading;

Fb2:=TSGButton.Create;
SGScreen.CreateChild(Fb2);
SGScreen.LastChild.SetBounds(Context.Width-85,Context.Height-28,80,23);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Построить';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@GoNewGrafic);
SGScreen.LastChild.FUserPointer1:=Self;

EulatuonLabel:=TSGLabel.Create;
SGScreen.CreateChild(EulatuonLabel);
SGScreen.LastChild.SetBounds(Context.Width div 2 ,2,Context.Width div 2  -20,23);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:=SGStringToPChar(SGPCharToString(MathGraphic.Expression)) ;
EulatuonLabel.TextPosition:=True;
EulatuonLabel.TextColor.Import(0.7,0,0.7);
EulatuonLabel.Font:=TSGFont.Create(SGFontDirectory+Slash+'Times New Roman.sgf');
EulatuonLabel.Font.SetContext(Context);
EulatuonLabel.Font.Loading;
EulatuonLabel.AutoTopShift:=True;

EulatuonEdit:=TSGEdit.Create;
SGScreen.CreateChild(EulatuonEdit);
SGScreen.LastChild.SetBounds(Context.Width div 2,Context.Height-28,Context.Width div 2 -95,23);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='';
end;

destructor TSGGraphViewer.Destroy;
begin
EulatuonLabel.Font.Destroy;
EulatuonLabel.Font:=nil;
EulatuonEdit.Destroy;
EulatuonLabel.Destroy ;
Fb2.Destroy;
Image.Destroy;
inherited;
end;


class function TSGGraphViewer.ClassName:string;
begin
Result:='Graphic Viewer';
end;

procedure TSGGraphViewer.Draw;
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
		Image.DrawImageFromTwoPoint2f(SelectPoint,SelectSecondPoint,True,SG_2D)
		end
	else
		begin
		Render.Color4f(0,0.5,0.70,0.6);
		Render.BeginScene(SGR_QUADS);
		SelectPoint.Vertex(Render);
		Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
		SelectSecondPoint.Vertex(Render);
		Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
		Render.EndScene();
		end;
	end;
if SelectPointEnabled and (Context.CursorKeysPressed(SGLeftCursorButton)) then
	begin
	SelectPointEnabled:=False;
	if SelectPoint.x>SelectSecondPoint.x then
		SGQuickRePlaceLongInt(SelectPoint.x,SelectSecondPoint.x);
	if SelectPoint.y>SelectSecondPoint.y then
		SGQuickRePlaceLongInt(SelectPoint.y,SelectSecondPoint.y);
	View.Import(
		View.x1+abs(View.x1-View.x2)*SelectPoint.x/Context.Width,
		View.y1+abs(View.y1-View.y2)*(Context.Height-SelectSecondPoint.y)/Context.Height,
		View.x1+abs(View.x1-View.x2)*SelectSecondPoint.x/Context.Width,
		View.y1+abs(View.y1-View.y2)*(Context.Height-SelectPoint.y)/Context.Height);
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


{$ENDIF}


