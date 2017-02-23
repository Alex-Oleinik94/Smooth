{$INCLUDE SaGe.inc}

unit SaGeConsoleUtils;

interface

uses
	 Crt
	,Dos
	,SysUtils
	,Classes
	
	,SaGeBase
	;

type
	TSGConsoleRecordIndex = TSGUInt32;
	TSGConsoleRecordProcedure = procedure (const Index : TSGConsoleRecordIndex);
	TSGConsoleRecordNestedProcedure = procedure (const Index : TSGConsoleRecordIndex) is nested;
	TSGConsoleRecord = object
			public
		procedure Clear();
		procedure Execute(const Index : TSGConsoleRecordIndex);
			public
		FTitle : TSGString;
		FProcedure : TSGConsoleRecordProcedure;
		FNestedProcedure : TSGConsoleRecordNestedProcedure;
		end;
	TSGConsoleMenuList = packed array of TSGConsoleRecord;
const
	SGConsoleMenuDefaultBackGroundColor = 0;
	SGConsoleMenuDefaultTextColor = 15;
	SGConsoleMenuDefaultActiveBackGroundColor = 0;
	SGConsoleMenuDefaultActiveTextColor = 10;
	SGConsoleMenuDefaultKoima = False;
	SGConsoleMenuDefaultExitAfterExecuting = False;

operator + (const a, b : TSGConsoleRecord) : TSGConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a : TSGConsoleMenuList; b : TSGConsoleRecord) : TSGConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGConsoleRecord(const S : TSGString; const P : TSGConsoleRecordProcedure) : TSGConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGConsoleRecord(const S : TSGString; const P : TSGConsoleRecordNestedProcedure) : TSGConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

procedure SGConsoleMenu(const Ar : TSGConsoleMenuList;
	const VBackGround : TSGByte = SGConsoleMenuDefaultBackGroundColor;
	const VText : TSGByte = SGConsoleMenuDefaultTextColor;
	const VActiveBackGround : TSGByte = SGConsoleMenuDefaultActiveBackGroundColor;
	const VActiveText : TSGByte = SGConsoleMenuDefaultActiveTextColor;
	const Koima : TSGBoolean = SGConsoleMenuDefaultKoima;
	const ExitAfterExecuting : TSGBool = SGConsoleMenuDefaultExitAfterExecuting);

function SGReadLnByte() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGCharRead() : TSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadLnString() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharRead() : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGIsConsole() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGExtractComand(const Comand : TSGString) : TSGString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

procedure SGPrintParams(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 78);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPrintParams(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 78);overload;

procedure SGPrintStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SGWriteStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

implementation

uses
	 StrMan
	,SaGeStringUtils
	;

procedure TSGConsoleRecord.Execute(const Index : TSGConsoleRecordIndex);
begin
if FNestedProcedure <> nil then
	FNestedProcedure(Index)
else if FProcedure <> nil then
	FProcedure(Index);
end;

procedure TSGConsoleRecord.Clear();
begin
FNestedProcedure := nil;
FProcedure := nil;
FTitle := '';
end;

function SGExtractComand(const Comand : TSGString) : TSGString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	TrimedComand : TSGString;
begin
TrimedComand := StringTrimLeft(Comand, '-');
if TrimedComand <> Comand then
	Result := TrimedComand
else
	Result := '';
end;

function SGPCharRead() : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
GetMem(Result, 1);
Result[0] := #0;
while not eoln do
	SGPCharAddSimbol(Result, SGCharRead());
end;

procedure SGWriteStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	Write(SGReadLnStringFromStream(Stream));
end;

procedure SGPrintStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	WriteLn(SGReadLnStringFromStream(Stream));
end;

procedure SGPrintParams(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 78);overload;
var
	i, WordCount, MaxLength, n, ii: TSGLongWord;
	TempS : TSGString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	WriteLn(Title + ' (' + SGStr(WordCount) + ')');
	MaxLength := Length(ArS[0]);
	if Length(ArS) > 1 then
		begin
		for i := 1 to High(ArS) do
			if Length(ArS[i]) > MaxLength then
				MaxLength := Length(ArS[i]);
		end;
	MaxLength += 2;
	n := SimbolsLength div MaxLength;
	MaxLength += (SimbolsLength mod MaxLength) div n;
	ii := 0;
	TempS := '  ';
	for i := 0 to High(ArS) do
		begin
		if (ii = n - 1) or (i = High(ArS)) then
			TempS += ArS[i]
		else
			TempS += StringJustifyLeft(ArS[i], MaxLength, ' ');
		ii +=1;
		if ii = n then
			begin
			ii := 0;
			WriteLn(TempS);
			TempS := '  ';
			end;
		end;
	if TempS <> '  ' then
		WriteLn(TempS);
	end;
end;

procedure SGPrintParams(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 78);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ArS : TSGStringList = nil;
begin
ArS := SGStringListFromString(S, Separators);
SGPrintParams(ArS, Title, SimbolsLength);
SetLength(ArS, 0);
end;

function SGIsConsole() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IF defined(MSWINDOWS)}
	Result := IsConsole;
{$ELSEIF defined(LINUX)}
	Result := True;
{$ELSEIF defined(ANDROID)}
	Result := False;
{$ELSE}
	Result := False;
{$ENDIF}
end;

function SGReadLnString() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ReadLn(Result);
end;

function SGConsoleRecord(const S : TSGString; const P : TSGConsoleRecordProcedure) : TSGConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Clear();
Result.FTitle := S;
Result.FProcedure := P;
end;

function SGConsoleRecord(const S : TSGString; const P : TSGConsoleRecordNestedProcedure) : TSGConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Clear();
Result.FTitle := S;
Result.FNestedProcedure := P;
end;

operator + (const a, b : TSGConsoleRecord) : TSGConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(Result, 2);
Result[0] := a;
Result[1] := b;
end;

operator + (const a : TSGConsoleMenuList; b : TSGConsoleRecord) : TSGConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := a;
SetLength(Result, Length(Result) + 1);
Result[High(Result)] := b;
end;

procedure SGConsoleMenu(const Ar : TSGConsoleMenuList;
	const VBackGround : TSGByte = SGConsoleMenuDefaultBackGroundColor;
	const VText : TSGByte = SGConsoleMenuDefaultTextColor;
	const VActiveBackGround : TSGByte = SGConsoleMenuDefaultActiveBackGroundColor;
	const VActiveText : TSGByte = SGConsoleMenuDefaultActiveTextColor;
	const Koima : TSGBoolean = SGConsoleMenuDefaultKoima;
	const ExitAfterExecuting : TSGBool = SGConsoleMenuDefaultExitAfterExecuting);
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
	Crt.ClrScr();
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
	if Crt.KeyPressed() then
		begin
		C := Crt.ReadKey();
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
		#13:begin
			Crt.ClrScr();
			Crt.TextColor(7);
			Crt.TextBackGround(0);
			Ar[NowActive].Execute(NowActive);
			if ExitAfterExecuting then
				GoExit := True
			else
				begin
				DAll:=true;
				DS;
				end;
			end;
		end;
		end
	else
		Sleep(10);
	end;
Crt.ClrScr();
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
