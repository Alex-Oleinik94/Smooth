{$i SaGe.inc}
unit SGUser;
interface
uses 
	crt
	,Classes
	,SaGe
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	,SaGeFractals
	,SaGeImages
	,SaGeBase
	,SaGeImagesBase
	,SaGeImagesPNG
	,SaGeOpenAL
	{$IFDEF MSWINDOWS}
		,Windows
		{$ENDIF}
	,SaGeMesh
	;

procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation
var
	IdentityObject:SGIdentityObject;
	Mesh:TSGMesh = nil;
	Image1:TSGGLImage = nil;
	Image2:TSGGLImage = nil;
procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
var
	i,ii,iii,iiii:LongInt;
	a:Boolean;
begin
SGInitMatrixMode(SG_3D);
IdentityObject.ChangeAndInit;

SGGetColor4fFromLongWord($93F1FF).WithAlpha(0.7).Color;
glBegin(GL_QUADS);
glVertex3f(-1*100,-1,-1*100);
glVertex3f(-1*100,-1,1*100);
glVertex3f(1*100,-1,1*100);
glVertex3f(1*100,-1,-1*100);
glEnd;

Image1.ImportFromDispley();
Image1.Way:='1.png';
Image1.Saveing;

glTranslatef(0,-1,0);
glColor3f(1,0,0);
Mesh.Draw;

Image2.ImportFromDispley();
Image2.Way:='2.png';
Image2.Saveing;
for ii:=0 to Image2.Width-1 do
	begin
	a:=False;
	for i:=0 to Image2.Height-1 do
	//for i:=Image2.Height-1 downto 0 do
		begin
		if PSGPixel(Image1.FImage.FBitMap)[i*Image2.Width+Image2.Width-ii]<>PSGPixel(Image2.FImage.FBitMap)[i*Image2.Width+Image2.Width-ii] then
			begin
			a:=True;
			{PSGPixel(Image1.FImage.FBitMap)[i*Image2.Width+ii].WriteLn;
			PSGPixel(Image2.FImage.FBitMap)[i*Image2.Width+ii].WriteLn;}
			Break;
			end;
		end;
	if a then
		begin
		iii:=i;
		iiii:=i-1;
		while (iii<=Image2.Height) and (iiii>=0) do
		//while (iii>=Image2.Height) and (iiii<=0) do
			begin
			PSGPixel(Image2.FImage.FBitMap)[iiii*Image2.Width+Image2.Width-i]:=
				PSGPixel(Image2.FImage.FBitMap)[iiii*Image2.Width+Image2.Width-i]+
				(PSGPixel(Image2.FImage.FBitMap)[iii*Image2.Width+Image2.Width-i]*0.7);
			iiii-=1;
			iii+=1;
			end;
		end;
	end;
Image2.Way:='3.png';
Image2.Saveing;
Halt;
end;


procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin
SGScreen.Font:=TSGGLFont.Create('Times New Roman.bmp');
SGScreen.Font.LoadIt;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-120,40,95,30);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Exit';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@SGCloseContext);

Image1:=TSGGLImage.Create;
Image2:=TSGGLImage.Create;
end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
IdentityObject.Clear;
Mesh:=TSGMesh.Create;
Mesh.LoadFromFile('11.wrl');
end;

end.
