{$INCLUDE SaGe.inc}

unit SaGeAdamsSystemExample;

interface

uses
	crt
	,SaGeBase
	{$IFDEF MSWINDOWS}
		,Windows
		,SaGeRenderDirectX
		,SaGeContextWinAPI
	{$ENDIF}
	{$IFDEF LINUX}
		,SaGeContextLinux
		{$ENDIF}
	,dos
	,SaGeBased
	,Classes
	,SysUtils
	,SaGeContext
	,SaGeCommon
	,SaGeFractals
	,SaGeUtils
	,SaGeScreen
	,SaGeTotal
	,SaGeMesh
	,SaGeMath
	,SaGeExamples
	,SaGeFPCToC
	,SaGeNet
	,SaGeGeneticalAlgoritm
	,SaGeRender
	,SaGeRenderOpenGL
	,SaGeModel
	,SaGeTron
	,SaGeLoading
	,SaGeImages
	;

type
	TSGExtenededArray = packed array of Extended;
	TSGExtenededArrayArray = packed array of TSGExtenededArray;
	TSGFunctionArray = packed array of TSGExpression;

function AdamsSystem(const a, b, Epsilon : Extended; const nsystem : LongWord; const npoints : LongWord; const Functions : TSGFunctionArray; const BeginPoints : TSGExtenededArray; const FileNameToOut : String = '') : TSGExtenededArrayArray;

implementation

function AdamsSystem(const a, b, Epsilon : Extended; const nsystem : LongWord; const npoints : LongWord; const Functions : TSGFunctionArray; const BeginPoints : TSGExtenededArray; const FileNameToOut : String = '') : TSGExtenededArrayArray;
var
	f : TextFile;
	Coords : array[0..2] of array of Extended;

function MyFunc(const index_of_function : LongWord; const index_of_array : LongWord):Extended;inline;
var
	i : LongWord;
begin
Functions[index_of_function].BeginCalculate();
if (LongInt(nsystem) - 1 >= 0) then 
	for i := 0 to nsystem - 1 do
		Functions[index_of_function].ChangeVariables(SGStringToPChar('y'+SGStr(i)),TSGExpressionChunkCreateReal(Coords[index_of_array][i]));
Functions[index_of_function].ChangeVariables('x',TSGExpressionChunkCreateReal(Coords[index_of_array][nsystem]));
Functions[index_of_function].Calculate();
if not (Functions[index_of_function].ErrorsQuantity = 0) then
	begin
	for i:=1 to Functions[index_of_function].ErrorsQuantity do
		begin
		TextColor(12);
		Write('Error:  ');
		TextColor(15);
		WriteLn(Functions[index_of_function].Errors(i));
		end;
	TextColor(7);
	Write('Press any key to continue...');
	ReadLn();
	end;
Result:=Functions[index_of_function].Resultat.FConst;
end;

function x(const i: LongWord):Extended;
begin
Result := a + abs(b-a)*(i/npoints)
end;

var
	max_eps : Extended;
	i, ii : LongWord;
	h : Extended;

procedure OutToFile();
var
	q : LongWord;
begin
for q := 0 to nsystem do
	Write(f,Coords[0][q]:0:5,' ');
WriteLn(f);
end;

begin
if (FileNameToOut <> '') then
	begin
	Assign(f,FileNameToOut);
	Rewrite(f);
	end;
h := abs(b-a)/npoints;
SetLength(Coords[0],nsystem+1);
SetLength(Coords[1],nsystem+1);
SetLength(Coords[2],nsystem+1);
for i := 0 to nsystem - 1 do
	Coords[0][i] := BeginPoints[i];
Coords[0][nsystem] := a;
SetLength(Result,npoints+1);
for i := 0 to npoints do
	SetLength(Result[i],nsystem);
if (FileNameToOut <> '') then
	OutToFile();
for i := 1 to npoints do
	begin
	Coords[0][nsystem] := x(i);
	for ii := 0 to nsystem - 1 do
		Coords[2][ii] := Coords[0][ii] + h * MyFunc(ii,0);
	Coords[2][nsystem] := x(i);
		repeat
		if (KeyPressed and (ReadKey = #13)) then begin for ii := 0 to nsystem do Write(Coords[2][ii]:0:5,' ');  WriteLn(); end;
		for ii := 0 to nsystem do
			Coords[1][ii] := Coords[2][ii];
		for ii := 0 to nsystem - 1 do
			Coords[2][ii] := Coords[0][ii] + h * MyFunc(ii,2);
		max_eps := 0;
		for ii := 0 to nsystem - 1 do
			if max_eps < abs(Coords[1][ii] - Coords[2][ii]) then
				max_eps := abs(Coords[1][ii] - Coords[2][ii]);
		until max_eps < Epsilon;
	for ii := 0 to nsystem do
		Coords[0][ii] := Coords[2][ii];
	if (FileNameToOut <> '') then
		OutToFile();
	for ii := 0 to nsystem - 1 do
		Result[i][ii] := Coords[0][ii];
	end;
if (FileNameToOut <> '') then
	Close(f);
end;


end.
