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
	
	SelectPoint,SelectSecondPoint,SelectSecondNormalPoint:SGPoint;
	
	SelectPointEnabled:Boolean = False;
	Manda:TSGFractalMandelbrod = nil;
	CID:Byte;
	QuantityThreads:LongInt = 1;
	
	NowSave:Boolean = False;
	NowSaveLastView:TSGScreenVertexes;
	
	SecondImage:TSGGLImage = nil;
	
	LabelProcent:TSGLabel = nil;
	LabelCoord:TSGLabel = nil;
	ScreenshotPanel:TSGPanel = nil;
	
	StartDepth:LongInt = 128;
	ColorComboBox:TSGComboBox  =nil;
	TypeComboBox:TSGComboBox  =nil;
	ZumButton:TSGButton = nil;
	StepenComboBox:TSGComboBox = nil;
	QuantityRecComboBox:TSGComboBox = nil;
	
	SelectZNimberFlag:Boolean = False;
	
	ButtonSelectZNumber:TSGButton = nil;
	
	MandaInitialized:Boolean = False;
	
	VideoPanel:TSGPanel = nil;
procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

procedure OffComponents;inline;
procedure OnComponents;inline;
procedure InitManda;inline;

implementation

var
	Changet:boolean = False;

procedure OffComponents;inline;
begin
ScreenshotPanel.Visible:=False;
ScreenshotPanel.Active:=False;
ColorComboBox.Visible:=False;
ColorComboBox.Active:=False;
TypeComboBox.Visible:=False;
TypeComboBox.Active:=False;
ZumButton.Visible:=False;
ZumButton.Active:=False;
ButtonSelectZNumber.Visible:=False;
ButtonSelectZNumber.Active:=False;
{VideoPanel.Visible:=False;
VideoPanel.Active:=False;}
StepenComboBox.Visible:=False;
StepenComboBox.Active:=False;
QuantityRecComboBox.Visible:=False;
QuantityRecComboBox.Active:=False;
end;

procedure OnComponents;inline;
begin
ScreenshotPanel.Visible:=True;
ScreenshotPanel.Active:=True;
ColorComboBox.Visible:=True;
ColorComboBox.Active:=True;
TypeComboBox.Visible:=True;
TypeComboBox.Active:=True;
ZumButton.Visible:=True;
ZumButton.Active:=True;
ButtonSelectZNumber.Visible:=True;
ButtonSelectZNumber.Active:=True;
{VideoPanel.Visible:=True;
VideoPanel.Active:=True;}
StepenComboBox.Visible:=True;
StepenComboBox.Active:=True;
QuantityRecComboBox.Visible:=True;
QuantityRecComboBox.Active:=True;
end;

function GetPointOnPosOnMand(const Point:SGPoint):TSGComplexNumber;inline;
begin
Result.Import(
	Manda.FView.x1+(Point.x/(ContextWidth)*abs(Manda.FView.x1-Manda.FView.x2)),
	-Manda.FView.y1-(Point.y/(ContextHeight)*abs(Manda.FView.y1-Manda.FView.y2)));
end;

procedure UpDateLabelCoordCaption;inline;
var
	Point:SGPoint;
begin
Point:=SGGetCursorPositionForWindows;
LabelCoord.Caption:=SGStringToPChar('( '+SGFloatToString(Manda.FZNumber.x,3)+' ; '+SGFloatToString(Manda.FZNumber.y,3)+' ) , ( '+
	SGFloatToString(Manda.FView.x1+(Point.x/(ContextWidth)*abs(Manda.FView.x1-Manda.FView.x2)),7)+' ; '
	+SGFloatToString(-Manda.FView.y1-(Point.y/(ContextHeight)*abs(Manda.FView.y1-Manda.FView.y2)),7)+' )');
end;


procedure SaveImage(Button:TSGButton);
begin
Manda.Depth:=SGVal(SGPCharToString(Button.Parent.LastChild.Caption));
Changet:=True;
NowSave:=true;
SelectPoint.Import;
SelectSecondPoint.Import;
end;

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
var
	i:LongInt;
	Procent:real = 0;
	ComplexNumber:TSGComplexNumber;
begin
if MandaInitialized then
	begin
	SGInitMatrixMode(SG_2D);

	if Manda.ThreadsReady then
		begin
		Manda.AfterCalculate;
		
		for i:=0 to QuantityThreads-1 do
			begin
			SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.Visible:=False;
			end;
		LabelProcent.Visible:=False;
		LabelProcent.Caption:='100%';
		
		if not NowSave then
			begin
			Manda.ToTexture;
			OnComponents;
			if SecondImage<>nil then
				begin
				SecondImage.Destroy;
				SecondImage:=nil;
				end;
			end
		else
			begin
			Manda.FImage.Saveing(SGI_PNG);
			Manda.Depth:=StartDepth;
			Manda.FImage.Destroy;
			Manda.FImage:=SecondImage;
			SecondImage:=nil;
			NowSave:=False;
			end;
		end;

	UpDateLabelCoordCaption;

	if LabelProcent.Visible then
		begin
		Procent:=0;
		for i:=0 to QuantityThreads-1 do
			begin
			Procent+=SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FNeedProgress;
			end;
		Procent/=QuantityThreads;
		Procent*=100;
		LabelProcent.Caption:=SGStringToPChar(SGFloatToString(Procent,2)+'%');
		LabelCoord.Caption:=SGPCharNil;
		end;


	if Manda.FImage.Ready then
		begin
		glColor3f(1,1,1);
		Manda.Draw;
		if Manda.FView.VertexInView(Manda.FZNumber) then
			begin
			glColor3f(1,1,1);
			glBegin(GL_TRIANGLES);
			glVertex2f(abs(Manda.FZNumber.x-SGMin(Manda.FView.X1,Manda.FView.X2))/Manda.FView.AbsX*ContextWidth+5,
				abs(Manda.FZNumber.Y-SGMax(Manda.FView.Y1,Manda.FView.Y2))/Manda.FView.AbsY*ContextHeight);
			glVertex2f(abs(Manda.FZNumber.x-SGMin(Manda.FView.X1,Manda.FView.X2))/Manda.FView.AbsX*ContextWidth-2,
				abs(Manda.FZNumber.Y-SGMax(Manda.FView.Y1,Manda.FView.Y2))/Manda.FView.AbsY*ContextHeight-4);
			glVertex2f(abs(Manda.FZNumber.x-SGMin(Manda.FView.X1,Manda.FView.X2))/Manda.FView.AbsX*ContextWidth-2,
				abs(Manda.FZNumber.Y-SGMax(Manda.FView.Y1,Manda.FView.Y2))/Manda.FView.AbsY*ContextHeight+4);
			glEnd();
			end
		else
			;//Manda.FZNumber.WriteLn;
		if (SelectZNimberFlag and (SGIsMouseKeyDown(1))) or SGIsMouseKeyDown(3) then
			begin
			ComplexNumber:=GetPointOnPosOnMand(SGGetCursorPositionForWindows);
			if Manda.FZNumber <> ComplexNumber then
				begin
				Manda.FZNumber:=ComplexNumber;
				SelectZNimberFlag:=False;
				SGSetMouseKeyUp(1);
				if not Manda.FZMand then
					Changet:=True;
				SelectPoint.Import;
				SelectSecondPoint.Import;
				end;
			end;
		if SGIsMouseKeyDown(2)  then
			begin
			SelectPointEnabled:=True;
			SelectPoint:=SGGetCursorPositionForWindows;
			end;
		if SelectPointEnabled then
			begin
			if SGKeyPressedChar=#27 then
				SelectPointEnabled:=False;
			
			SelectSecondPoint:=SGGetCursorPositionForWindows;
			if abs(SelectPoint.x-SelectSecondPoint.x)/abs(SelectPoint.y-SelectSecondPoint.y)>ContextWidth/ContextHeight then
				begin
				SelectSecondNormalPoint.y:=SelectSecondPoint.y;
				if (SelectPoint.x<SelectSecondPoint.x)then
					SelectSecondNormalPoint.x:=SelectPoint.x+Round(abs(SelectSecondPoint.y-SelectPoint.y)/ContextHeight*ContextWidth)
				else
					SelectSecondNormalPoint.x:=SelectPoint.x-Round(abs(SelectSecondPoint.y-SelectPoint.y)/ContextHeight*ContextWidth);
				end
			else
				begin
				SelectSecondNormalPoint.x:=SelectSecondPoint.x;
				if SelectPoint.y<SelectSecondPoint.y then
					SelectSecondNormalPoint.y:=SelectPoint.y+Round(abs(SelectSecondPoint.x-SelectPoint.x)/ContextWidth*ContextHeight)
				else
					SelectSecondNormalPoint.y:=SelectPoint.y-Round(abs(SelectSecondPoint.x-SelectPoint.x)/ContextWidth*ContextHeight);
				end;
			
			glColor4f(0,0.5,0.70,0.6);
			glBegin(GL_QUADS);
			SelectPoint.Vertex;
			glVertex2f(SelectPoint.x,SelectSecondPoint.y);
			SelectSecondPoint.Vertex;
			glVertex2f(SelectSecondPoint.x,SelectPoint.y);
			glEnd();
			glColor4f(0,0.7,0.70,0.8);
			glBegin(GL_LINE_LOOP);
			SelectPoint.Vertex;
			glVertex2f(SelectPoint.x,SelectSecondPoint.y);
			SelectSecondPoint.Vertex;
			glVertex2f(SelectSecondPoint.x,SelectPoint.y);
			glEnd();
			
			glColor4f(0.6,0.5,0.30,0.6);
			glBegin(GL_QUADS);
			SelectPoint.Vertex;
			glVertex2f(SelectPoint.x,SelectSecondNormalPoint.y);
			SelectSecondNormalPoint.Vertex;
			glVertex2f(SelectSecondNormalPoint.x,SelectPoint.y);
			glEnd();
			glColor4f(1,0.9,0.20,0.8);
			glBegin(GL_LINE_LOOP);
			SelectPoint.Vertex;
			glVertex2f(SelectPoint.x,SelectSecondNormalPoint.y);
			SelectSecondNormalPoint.Vertex;
			glVertex2f(SelectSecondNormalPoint.x,SelectPoint.y);
			glEnd();
			end;
		if SelectPointEnabled and (SGIsMouseKeyDown(1)) then
			begin
			SelectSecondPoint:=SelectSecondNormalPoint;
			
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
			
			glColor4f(0.1,0.7,0.20,0.6);
			glBegin(GL_QUADS);
			SelectPoint.Vertex;
			glVertex2f(SelectPoint.x,SelectSecondPoint.y);
			SelectSecondPoint.Vertex;
			glVertex2f(SelectSecondPoint.x,SelectPoint.y);
			glEnd();
			
			glColor4f(0.05,0.9,0.10,0.8);
			glBegin(GL_LINE_LOOP);
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

	if Changet then
		begin
		OffComponents;
		if SecondImage<>nil then
			SecondImage.Destroy;
		SecondImage:=Manda.FImage;
		Manda.FImage:=nil;
		Manda.BeginCalculate;
		Manda.FImage.Way:=SGGetFreeFileName('Images'+Slash+'Mand New.png');
		LabelProcent.Visible:=True;
		for i:=0 to QuantityThreads-1 do
			begin
			SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FNeedProgress:=0;
			SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FProgress:=0;
			SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.Visible:=true;
			Manda.BeginThread(i,@SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.FNeedProgress);
			end;
		end;
	Changet:=False;
	end;
end;

procedure FromExit;
begin
SGCloseContext;
end;

procedure ColorComboBoxProcedure(a,b:LongInt);
begin
Manda.FColorScheme:=b;
if a<>b then
	begin
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

procedure TypeComboBoxProcedure(a,b:LongInt);
begin
Manda.FZMand:=Boolean(b);
if a<>b then
	begin
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

procedure ZumButtonOnChange(Button:TSGButton);
begin
Manda.FView.Import(-2.5,-2.5*(ContextHeight/ContextWidth),2.5,2.5*(ContextHeight/ContextWidth));
Changet:=True;
SelectPoint.Import;
SelectSecondPoint.Import;
end;

procedure ButtonSelectZNumberOnChange(Button:TSGButton);
begin
SelectZNimberFlag:=True;
end;

procedure QuantityRecComboBoxProcedure(a,b:LongInt);
BEGIN
Manda.FZQuantityRec:=QuantityRecComboBox.FItems[b].FId;
Changet:=True;
SelectPoint.Import;
SelectSecondPoint.Import;
END;

procedure StepenComboBoxProcedure(a,b:LongInt);
begin
Manda.FZDegree:=StepenComboBox.FItems[b].FId;
Changet:=True;
SelectPoint.Import;
SelectSecondPoint.Import;
end;

procedure InitManda;inline;
var
	i:LongInt;
	ii:LongInt = 5;
begin
Manda:=TSGFractalMandelbrod.Create;
Manda.Depth:=StartDepth;
Manda.FZNumber.Import(-0.181,0.66);
Manda.FZMand:=False;
Manda.FZDegree:=2;
Manda.FView.Import(-2.5,-2.5*(ContextHeight/ContextWidth),2.5,2.5*(ContextHeight/ContextWidth));
Manda.CreateThreads(QuantityThreads);
Manda.BeginCalculate;
Manda.FImage.Way:='Images'+Slash+'Mand New.png';
ii+=SGGetTopShiftOnWinAPIMethod;
for i:=0 to QuantityThreads-1 do
	begin
	SGScreen.CreateChild(TSGProgressBar.Create);
	SGScreen.LastChild.SetBounds(10,ii,300,20);
	ii+=25;
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.AsProgressBar.ViewProgress:=True;
	Manda.BeginThread(i,@SGScreen.LastChild.AsProgressBar.FNeedProgress);
	end;
CID:=High(SGScreen.FChildren);

LabelProcent:=TSGLabel.Create;
SGScreen.CreateChild(LabelProcent);
LabelProcent.SetBounds(10,ii,300,20);
LabelProcent.Caption:='';
LabelProcent.Visible:=True;

LabelCoord:=TSGLabel.Create;
SGScreen.CreateChild(LabelCoord);
SGScreen.LastChild.SetBounds(10,ContextHeight-25,ContextWidth div 2,20);
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.AsLabel.FTextPosition:=0;

ScreenshotPanel:=TSGPanel.Create;
SGScreen.CreateChild(ScreenshotPanel);
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.SetBounds(ContextWidth-10-(130+140+10),ContextHeight-30,130+140+10,25);
SGScreen.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(130,5,140,20);
SGScreen.LastChild.LastChild.Caption:='Сохранить';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.AsButton.OnChange:=TSGComponentProcedure(@SaveImage);

SGScreen.LastChild.CreateChild(TSGEdit.Create);
SGScreen.LastChild.LastChild.SetBounds(5,5,120,20);
SGScreen.LastChild.LastChild.Caption:='4096';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.CreateChild(TSGComboBox.Create);
SGScreen.LastChild.SetBounds(ContextWidth-50-125,5+SGGetTopShiftOnWinAPIMethod,120,20);
SGScreen.LastChild.AsComboBox.CreateItem('Цвет №1');
SGScreen.LastChild.AsComboBox.CreateItem('Цвет №2');
SGScreen.LastChild.AsComboBox.CreateItem('Цвет №3');
SGScreen.LastChild.AsComboBox.CreateItem('Монохромный');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@ColorComboBoxProcedure);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
ColorComboBox:=SGScreen.LastChild.AsComboBox;

TypeComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(TypeComboBox);
SGScreen.LastChild.SetBounds(ContextWidth-50-125-185,5+SGGetTopShiftOnWinAPIMethod,180,20);
SGScreen.LastChild.AsComboBox.CreateItem('Множество Жюлиа');
SGScreen.LastChild.AsComboBox.CreateItem('Модель Мандельброта');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@TypeComboBoxProcedure);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-50-125-185-105,5+SGGetTopShiftOnWinAPIMethod,100,20);
SGScreen.LastChild.Caption:='Сброс зума';
ZumButton:=SGScreen.LastChild.AsButton;
ZumButton.OnChange:=TSGComponentProcedure(@ZumButtonOnChange);

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-50-125-185-105-125,5+SGGetTopShiftOnWinAPIMethod,120,20);
SGScreen.LastChild.Caption:='Установ. тчк.';
ButtonSelectZNumber:=SGScreen.LastChild.AsButton;
ButtonSelectZNumber.OnChange:=TSGComponentProcedure(@ButtonSelectZNumberOnChange);

StepenComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(StepenComboBox);
SGScreen.LastChild.SetBounds(ContextWidth-50-125-185-105-125-105,5+SGGetTopShiftOnWinAPIMethod,100,20);
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AsComboBox.FSelectItem:=1;
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@StepenComboBoxProcedure);
i:=1;
while i<=20 do
	begin
	SGScreen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(i)),nil,i);
	i+=1;
	end;

QuantityRecComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(QuantityRecComboBox);
SGScreen.LastChild.SetBounds(ContextWidth-50-125-185-105-125-105-105,5+SGGetTopShiftOnWinAPIMethod,100,20);
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@QuantityRecComboBoxProcedure);
i:=6;
while i<=13 do
	begin
	SGScreen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(2**i)),nil,2**i);
	if i=8 then
		begin
		SGScreen.LastChild.AsComboBox.FSelectItem:=High(QuantityRecComboBox.FItems);
		end;
	i+=1;
	end;


VideoPanel:=TSGPanel.Create;
SGScreen.CreateChild(VideoPanel);
SGScreen.LastChild.Caption:=' ';
SGScreen.LastChild.SetBounds(ContextWidth-500,ContextHeight-30-30,400,25);
SGScreen.LastChild.BoundsToNeedBounds;

VideoPanel.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.Caption:='Видео';
SGScreen.LastChild.LastChild.SetBounds(5,5,60,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

end;

procedure BeginInitMand(Button:TSGButton);
begin
Button.Parent.Visible:=(False);
QuantityThreads:=SGVal(SGPCharToString(Button.Parent.FChildren[4].AsComboBox.FItems[Button.Parent.FChildren[4].AsComboBox.FSelectItem].FCaption));
StartDepth:=SGVal(SGPCharToString(Button.Parent.FChildren[3].AsComboBox.FItems[Button.Parent.FChildren[3].AsComboBox.FSelectItem].FCaption));
InitManda;
MandaInitialized:=True;
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin
SGScreen.Font:=TSGGLFont.Create('Tahoma.bmp');
SGScreen.Font.Loading;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-50,5+SGGetTopShiftOnWinAPIMethod,40,20);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Exit';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@FromExit);
//SGScreen.LastChild.Align:=SGAlignRight;

SGScreen.CreateChild(TSGPanel.Create);
SGScreen.LastChild.SetMiddleBounds(300,ContextHeight-200);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.AsPanel.FViewLines:=False;
SGScreen.LastChild.AsPanel.FViewQuad:=False;
SGScreen.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Количество потоков';
SGScreen.LastChild.LastChild.SetBounds(5,5,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Разрешение текстуры';
SGScreen.LastChild.LastChild.SetBounds(5,55,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(75,115,140,20);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Запуск';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@BeginInitMand);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGComboBox.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.SetBounds(5,80,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.AsComboBox.FSelectItem:=4;
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('64');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('128');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('256');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('512');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('1024');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('2048');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('4096');
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGComboBox.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.SetBounds(5,30,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.AsComboBox.FSelectItem:=0;
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('1');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('2');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('3');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('4');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('6');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('8');
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
if not DirectoryExists('Images') then
	MkDir('Images');
end;

end.
