{$MODE OBJFPC}
unit SGUser;
interface
uses 
	crt
	,SaGe
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	,SaGeFractals
	,SaGeImages
	;
var
	fogColor:SGColor4f = (r:0;g:0;b:0;a:1);
	Fractal:TSGFractal = nil;
	FLabel:TSGLabel = nil;
	Image : TSGGLImage = nil;
	Image2:TSGGLImage = nil;
	
procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure FromExit;
begin
Image.ImportFromDispley(False);
image.ToTexture;
end;

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
begin
//Fractal.Draw;
SGInitMatrixMode(SG_2D);
glColor3f(1,1,1);
if Image2.Ready and (not Image.Ready) then
	begin
	Image2.DrawImageFromTwoPoint2f(
		SGPointImport(50,50),
		SGPointImport(ContextWidth-100,ContextHeight-100));
	end;
if Image.Ready then
	begin
	Image.DrawImageFromTwoPoint2f(
		SGPointImport(50,50),
		SGPointImport(ContextWidth-100,ContextHeight-100));
	end;
if SGKeyPressed then
	FLabel.Caption:=SGStringToPChar(Char(SGKeyPressedChar)+' - '+SGStr(Byte(SGKeyPressedChar)));
if SGKeyPressedChar=' ' then
	FromExit;
end;



procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin

glEnable(GL_FOG);
glFogi(GL_FOG_MODE, GL_LINEAR);
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 0.2);
glFogf (GL_FOG_END, 30.0);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.55);

Image:=TSGGLImage.Create;
Image2:=TSGGLImage.Create('sshot001.bmp');
Image2.LoadIt;

SGScreen.Font:=TSGGLFont.Create('Times New Roman.bmp');
SGScreen.Font.LoadIt;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-120,40,95,40);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Exit';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@SGCloseContext);
//SGScreen.LastChild.Align:=SGAlignRight;

SGScreen.CreateChild(TSGLabel.Create);
FLabel:=SGScreen.LastChild.AsLabel;
SGScreen.LastChild.SetBounds(120,40,90,40);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Label';

SGScreen.CreateChild(TSGProgressBar.Create);
SGScreen.LastChild.SetBounds(120,240,190,40);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.AsProgressBar.Progress:=1;
SGScreen.LastChild.AsProgressBar.ViewProgress:=True;

SGScreen.CreateChild(TSGEdit.Create);
SGScreen.LastChild.SetBounds(120,350,190,40);
SGScreen.LastChild.Visible:=True;

{Fractal:=TSGFractalMandelbrod.Create;
Fractal.Depth:=5;
Delay(100);
Fractal.Calculate;}
end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
end;

end.
