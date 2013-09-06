{$I SaGe.inc}
//{$APPTYPE GUI}
program ProjectWinAPI;
uses 
	crt
	,Classes
	,SysUtils
	,GLu
	,SaGe
	,SaGeBase
	,SGUser
	,SaGeMath
	,SaGeImages
	,Gl
	;
var
	a:TArString = nil;
	i:LongInt;
begin
a:=SGGetFileNames('','*.png');
for i:=0 to High(a) do
	begin
	with TSGImage . Create (a[i]) do
		begin
		LoadToMemory;
		LoadToBitMap;
		Image.SetBounds(1440,900);
		Saveing;
		Destroy;
		end;
	end;
end.
