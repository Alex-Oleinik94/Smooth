{$INCLUDE SaGe.inc}

unit SaGeConsoleUtils;

interface

uses
	 Crt
	,Dos
	,Classes
	,SysUtils
	
	,SaGeBase
	,SaGeBased
	;

type
	TSGConsoleRecord = packed record
			FTitle : TSGString;
			FProcedure : TSGProcedure;
			end;
	TSGConsoleMenuArray = packed array of TSGConsoleRecord;

operator + (const a, b : TSGConsoleRecord) : TSGConsoleMenuArray;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a : TSGConsoleMenuArray; b : TSGConsoleRecord) : TSGConsoleMenuArray;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGConsoleRecord(const S : TSGString; const P : TSGPointer) : TSGConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGConsoleMenu(const Ar : TSGConsoleMenuArray;
	const VBackGround : TSGByte = 0;
	const VText : TSGByte = 15;
	const VActiveBackGround : TSGByte = 0;
	const VActiveText : TSGByte = 10;
	const Koima : TSGBoolean = True);

function SGReadLnByte() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGCharRead() : TSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadLnString() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

function SGReadLnString() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ReadLn(Result);
end;

function SGConsoleRecord(const S : TSGString; const P : TSGPointer) : TSGConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FTitle := S;
Result.FProcedure := TSGProcedure(P);
end;

operator + (const a, b : TSGConsoleRecord) : TSGConsoleMenuArray;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(Result, 2);
Result[0] := a;
Result[1] := b;
end;

operator + (const a : TSGConsoleMenuArray; b : TSGConsoleRecord) : TSGConsoleMenuArray;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := a;
SetLength(Result, Length(Result) + 1);
Result[High(Result)] := b;
end;

procedure SGConsoleMenu(const Ar : TSGConsoleMenuArray;
	const VBackGround : TSGByte = 0;
	const VText : TSGByte = 15;
	const VActiveBackGround : TSGByte = 0;
	const VActiveText : TSGByte = 10;
	const Koima : TSGBoolean = True);
var
	NowActive:LongWord;
	OldActive:LongWord = 0;
	c:char = #0;
	GoExit:Boolean = False;
	DAll:Boolean = True;
	MaxLength:LongWord = 0;
procedure DS;
var
	iiii,iii,ii,i:LongWord;
begin
Crt.TextBackGround(VBackGround);
if DAll then
	Crt.ClrScr;
i:=2;
for ii:=0 to High(Ar) do
	begin
	iiii:=3+((MaxLength - Length(Ar[ii].FTitle))div 2);
	Crt.GoToXY(iiii,i);
	Crt.TextColor(VActiveText*Byte(NowActive=ii)+VText*Byte((NowActive<>ii)));
	Crt.TextBackGround(VActiveBackGround*Byte(NowActive=ii)+VBackGround*Byte((NowActive<>ii)));
	if DAll or ((not DAll) and ((ii=NowActive) or (ii=OldActive))) then
		if Koima then
			begin
			if ii=NowActive then
				begin
				Write(#218);for iii:=1 to Length(Ar[ii].FTitle) do Write(#196);Write(#191);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#179);Write(Ar[ii].FTitle);Write(#179);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#192);for iii:=1 to Length(Ar[ii].FTitle) do Write(#196);Write(#217);
				end
			else
				begin
				Write(#201);for iii:=1 to Length(Ar[ii].FTitle) do Write(#205);Write(#187);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#186);Write(Ar[ii].FTitle);Write(#186);
				i+=1;Crt.GoToXY(iiii,i);
				Write(#200);for iii:=1 to Length(Ar[ii].FTitle) do Write(#205);Write(#188);
				end;
			i+=1;
			end
		else
			begin
			Write(Ar[ii].FTitle);
			i+=1;
			end
	else
		if Koima then
			i+=3
		else
			i+=1;
	end;
Crt.GoToXY(80,25);
DAll:=False;
end;

begin
for OldActive:=0  to High(Ar) do
	if MaxLength<Length(Ar[OldActive].FTitle) then
		MaxLength:=Length(Ar[OldActive].FTitle);
OldActive:=0;
NowActive:=Random(Length(Ar));
DS;
while not GoExit do
	begin
	c:=Crt.ReadKey;
	case c of
	#27:GoExit:=True;
	#80:if NowActive<High(Ar) then
		begin
		OldActive:=NowActive;
		NowActive+=1;
		DS;
		end;
	#72:if NowActive>0 then
		begin
		OldActive:=NowActive;
		NowActive-=1;
		DS;
		end;
	#13:if Ar[NowActive].FProcedure=nil then
		GoExit:=True
	else
		begin
		Ar[NowActive].FProcedure();
		DAll:=true;
		DS;
		end;
	end;
	end;
end;

function SGCharRead() : TSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Read(Result);
end;

function SGReadLnByte() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Readln(Result);
end;

end.
