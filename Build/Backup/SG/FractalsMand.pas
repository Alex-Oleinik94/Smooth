{$MODE OBJFPC}
unit SGUser;
interface
uses 
	crt
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		{$ENDIF}
	,SaGe
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	,SaGeBase
	,SaGeImagesBase
	,SysUtils
	,Classes
	,SaGeImagesPng
	,SaGeImagesBmp
	,SaGeFractals
	;
var
	MathGraphic:TSGMathGraphic = nil;
	SelectPoint,SelectSecondPoint:SGPoint;
	SelectPointEnabled:Boolean = False;
	Manda:TSGFractalMandelbrod = nil;
	CID:Byte;
	QuantityThreads:LongInt = 4;
	MandaDepth:LongInt;
	MaxDepth:LongInt = 4096;
	SecondImage:TSGGLImage = nil;
	IsMand:Boolean = False;
	LabelProcent:TSGLabel = nil;

procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure _1(Data:TSGFractalMandelbrodThreadData);
begin
with data do
	begin
	FFractal.CalculateFromThread(h1,h2,FPoint);
	FFractal.FThreadsFinished[FNumber]:=True;
	end;
end;

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
var
	Changet:boolean = False;
	i:LongInt;
	Procent:real = 0;
begin
SGInitMatrixMode(SG_2D);

if Manda.ThreadsReady then
	begin
	Manda.ToTexture;
	for i:=0 to QuantityThreads-1 do
		begin
		SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.Visible:=False;
		end;
	LabelProcent.Visible:=False;
	LabelProcent.Caption:='100%';
	if Manda.Depth=MaxDepth then
		begin
		Manda.FImage.Saveing(SGI_PNG);
		Manda.Depth:=MandaDepth;
		end;
	if SecondImage<>nil then
		begin
		SecondImage.Destroy;
		SecondImage:=nil
		end;
	end;

if LabelProcent.Visible then
	begin
	Procent:=0;
	for i:=0 to QuantityThreads-1 do
		begin
		Procent+=SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FNeedProgress;
		end;
	Procent/=QuantityThreads;
	Procent*=100;
	LabelProcent.Caption:=SGStringToPChar(SGFloatToString(Procent,2)+'%')
	end;

if Manda.FImage.Ready then
	begin
	glColor3f(1,1,1);
	Manda.Draw;
	if SGIsMouseKeyDown(2)  then
		begin
		SelectPointEnabled:=True;
		SelectPoint:=SGGetCursorPositionForWindows;
		end;
	if SelectPointEnabled then
		begin
		SelectSecondPoint:=SGGetCursorPositionForWindows;
		glColor4f(0,0.5,0.70,0.6);
		glBegin(GL_QUADS);
		SelectPoint.Vertex;
		glVertex2f(SelectPoint.x,SelectSecondPoint.y);
		SelectSecondPoint.Vertex;
		glVertex2f(SelectSecondPoint.x,SelectPoint.y);
		glEnd();
		end;
	if SelectPointEnabled and (SGIsMouseKeyDown(1)) then
		begin
		SelectPointEnabled:=False;
		if SelectPoint.x>SelectSecondPoint.x then
			SGQuickRePlaceLongInt(SelectPoint.x,SelectSecondPoint.x);
		if SelectPoint.y>SelectSecondPoint.y then
			SGQuickRePlaceLongInt(SelectPoint.y,SelectSecondPoint.y);
		Manda.FView.Import(
			Manda.FView.x1+abs(Manda.FView.x1-Manda.FView.x2)*SelectPoint.x/ContextWidth,
			Manda.FView.y1+abs(Manda.FView.y1-Manda.FView.y2)*(SelectPoint.y)/ContextHeight,
			Manda.FView.x1+abs(Manda.FView.x1-Manda.FView.x2)*SelectSecondPoint.x/ContextWidth,
			Manda.FView.y1+abs(Manda.FView.y1-Manda.FView.y2)*(SelectSecondPoint.y)/ContextHeight);
		Changet:=True;
		end;
	end
else
	begin
	if SecondImage<>nil then
		begin
		glColor3f(1,1,1);
		if SecondImage.Ready then
			SecondImage.DrawImageFromTwoPoint2f(
				SGPointImport(1,1),
				SGPointImport(ContextWidth,ContextHeight),
				True,SG_2D);
		glColor4f(0,0.5,0.70,0.6);
		glBegin(GL_QUADS);
		SelectPoint.Vertex;
		glVertex2f(SelectPoint.x,SelectSecondPoint.y);
		SelectSecondPoint.Vertex;
		glVertex2f(SelectSecondPoint.x,SelectPoint.y);
		glEnd();
		end;
	end;

if crt.keypressed and (crt.readkey=#13) then
	begin
	ReadLn(Manda.FZNumber.x,Manda.FZNumber.y,Manda.FZDegree);
	Changet:=true;
	end;

if SGKeyPressedChar=#13 then
	begin
	if Manda.Depth<>MaxDepth then
		begin
		Manda.Depth:=MaxDepth;
		Changet:=true;
		end
	else
		Manda.Depth:=MandaDepth;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;

if Changet then
	begin
	if SecondImage<>nil then
		SecondImage.Destroy;
	SecondImage:=Manda.FImage;
	Manda.FImage:=nil;
	Manda.BeginCalculate;
	Manda.FImage.Way:=SGGetFreeFileName('Mand New.png');
	LabelProcent.Visible:=True;
	for i:=0 to QuantityThreads-1 do
		begin
		SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FNeedProgress:=0;
		SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FProgress:=0;
		SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.Visible:=true;
		TSGThread.Create(TSGPointerProcedure(@_1),TSGFractalMandelbrodThreadData.Create(Manda,
			Trunc( (i)*(Manda.Depth div QuantityThreads)),
			Trunc( (i+1)*(Manda.Depth div QuantityThreads))-1,
			@SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FNeedProgress,i));
		end;
	end;
if SGKeyPressed then
	writeln(Byte(SGKeyPressedChar));
end;

procedure FromExit;
begin
SGCloseContext;
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
var
	i:LongInt;
	ii:LongInt = 50;
begin
SGScreen.Font:=TSGGLFont.Create('Times New Roman.bmp');
SGScreen.Font.Loading;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-120,40,95,40);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Exit';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@FromExit);
//SGScreen.LastChild.Align:=SGAlignRight;

Manda:=TSGFractalMandelbrod.Create;
Manda.Depth:=MandaDepth;
Manda.FZNumber.Import(-0.181,0.66);
Manda.FZMand:=IsMand;
Manda.FZDegree:=2;
Manda.FView.Import(-2.5,-2.5*(ContextHeight/ContextWidth),2.5,2.5*(ContextHeight/ContextWidth));
Manda.CreateThreads(QuantityThreads);
Manda.BeginCalculate;
Manda.FImage.Way:='Mand New.png';
for i:=0 to QuantityThreads-1 do
	begin
	SGScreen.CreateChild(TSGProgressBar.Create);
	SGScreen.LastChild.SetBounds(10,ii,300,30);
	ii+=35;
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.AsProgressBar.ViewProgress:=True;
	TSGThread.Create(TSGPointerProcedure(@_1),TSGFractalMandelbrodThreadData.Create(Manda,
			Trunc( (i)*(Manda.Depth div QuantityThreads)),
			Trunc( (i+1)*(Manda.Depth div QuantityThreads))-1,
		@SGScreen.LastChild.AsProgressBar.FNeedProgress,i));
	end;
CID:=High(SGScreen.FChildren);

LabelProcent:=TSGLabel.Create;
SGScreen.CreateChild(LabelProcent);
LabelProcent.SetBounds(10,ii,300,30);
LabelProcent.Caption:='';
LabelProcent.Visible:=True;

SGScreen.CreateChild(TSGEdit.Create);
SGScreen.LastChild.SetBounds(400,300,400,50);
SGScreen.LastChild.Visible:=True;

end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
{
MandaDepth:=2048;
IsMand:=False;
}
readLn(MandaDepth,Byte(IsMand));
end;

end.
