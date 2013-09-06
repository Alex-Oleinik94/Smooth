{$i SaGe.inc}
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
	,SaGeMesh
	,SaGeGameLogic
	,SaGeNet
	;
var
	Model:TSGModel = nil;
	IdObj:SGIdentityObject;
	
procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
begin
SGMatrixMode(SG_3D);
IdObj.ChangeAndInit;
Model.Draw;
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin
SGScreen.Font:=TSGGLFont.Create('Times New Roman.bmp');
SGScreen.Font.Loading;

Model:=TSGModel.Create;
Model.LoadFromFile('1234554321.txt');
end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
IdObj.Clear;
end;

end.