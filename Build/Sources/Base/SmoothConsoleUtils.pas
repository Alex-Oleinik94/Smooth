{$INCLUDE Smooth.inc}

unit SmoothConsoleUtils;

interface

uses
	 Crt
	,Dos
	,SysUtils
	,Classes
	
	,SmoothBase
	,SmoothEncodingUtils
	,SmoothLists
	;

type
	TSConsoleRecordIndex = TSUInt32;
	TSConsoleRecordProcedure = procedure (const Index : TSConsoleRecordIndex);
	TSConsoleRecordNestedProcedure = procedure (const Index : TSConsoleRecordIndex) is nested;
	TSConsoleRecord = object
			public
		procedure Clear();
		procedure Execute(const Index : TSConsoleRecordIndex);
			public
		FTitle : TSString;
		FProcedure : TSConsoleRecordProcedure;
		FNestedProcedure : TSConsoleRecordNestedProcedure;
		end;
	TSConsoleMenuList = packed array of TSConsoleRecord;
const
	SConsoleMenuDefaultBackGroundColor = 0;
	SConsoleMenuDefaultTextColor = 15;
	SConsoleMenuDefaultActiveBackGroundColor = 0;
	SConsoleMenuDefaultActiveTextColor = 10;
	SConsoleMenuDefaultKoima = False;
	SConsoleMenuDefaultExitAfterExecuting = False;

operator + (const a, b : TSConsoleRecord) : TSConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a : TSConsoleMenuList; b : TSConsoleRecord) : TSConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SConsoleRecord(const S : TSString; const P : TSConsoleRecordProcedure) : TSConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SConsoleRecord(const S : TSString; const P : TSConsoleRecordNestedProcedure) : TSConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

procedure SConsoleMenu(const Ar : TSConsoleMenuList;
	const VBackGround : TSByte = SConsoleMenuDefaultBackGroundColor;
	const VText : TSByte = SConsoleMenuDefaultTextColor;
	const VActiveBackGround : TSByte = SConsoleMenuDefaultActiveBackGroundColor;
	const VActiveText : TSByte = SConsoleMenuDefaultActiveTextColor;
	const Koima : TSBoolean = SConsoleMenuDefaultKoima;
	const ExitAfterExecuting : TSBool = SConsoleMenuDefaultExitAfterExecuting);

function SReadLnByte() : TSByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SCharRead() : TSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadLnString() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharRead() : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadFloat64() : TSFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadEnum() : TSMaxEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SIsConsole() : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SExtractComand(const Comand : TSString) : TSString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}

procedure SPrintParams(const S : TSString; const Title : TSString; const Separators : TSString; const SimbolsLength : TSUInt16 = 78);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SPrintParams(const ArS : TSStringList; const Title : TSString; const SimbolsLength : TSUInt16 = 78);overload;

procedure SPrintStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SWriteStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

function SConvertStringToConsoleEncoding(const VString : TSString) : TSString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SConsoleEncoding() : TSEncoding; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

implementation

uses
	 StrMan
	,SmoothStreamUtils
	,SmoothStringUtils
	;

function SReadFloat64() : TSFloat64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Read(Result);
end;

function SReadEnum() : TSMaxEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Read(Result);
end;

function SConsoleEncoding() : TSEncoding; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := SEncodingNull;
{$IF defined(MSWINDOWS)}
	Result := SEncodingCP866;
{$ELSE} {$IF defined(LINUX)}
	Result := SEncodingUTF8;
{$ENDIF} {$ENDIF}
end;

function SConvertStringToConsoleEncoding(const VString : TSString) : TSString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := SConvertString(VString, SConsoleEncoding());
end;

procedure TSConsoleRecord.Execute(const Index : TSConsoleRecordIndex);
begin
if FNestedProcedure <> nil then
	FNestedProcedure(Index)
else if FProcedure <> nil then
	FProcedure(Index);
end;

procedure TSConsoleRecord.Clear();
begin
FNestedProcedure := nil;
FProcedure := nil;
FTitle := '';
end;

function SExtractComand(const Comand : TSString) : TSString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	TrimedComand : TSString;
begin
TrimedComand := StringTrimLeft(Comand, '-');
if TrimedComand <> Comand then
	Result := TrimedComand
else
	Result := '';
end;

function SPCharRead() : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
GetMem(Result, 1);
Result[0] := #0;
while not eoln do
	SPCharAddSimbol(Result, SCharRead());
end;

procedure SWriteStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	Write(SReadLnStringFromStream(Stream));
end;

procedure SPrintStream(const Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	WriteLn(SReadLnStringFromStream(Stream));
end;

procedure SPrintParams(const ArS : TSStringList; const Title : TSString; const SimbolsLength : TSUInt16 = 78);overload;
var
	i, WordCount, MaxLength, n, ii: TSLongWord;
	TempS : TSString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	WriteLn(Title + ' (' + SStr(WordCount) + ')');
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

procedure SPrintParams(const S : TSString; const Title : TSString; const Separators : TSString; const SimbolsLength : TSUInt16 = 78);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ArS : TSStringList = nil;
begin
ArS := SStringListFromString(S, Separators);
SPrintParams(ArS, Title, SimbolsLength);
SetLength(ArS, 0);
end;

function SIsConsole() : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function SReadLnString() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ReadLn(Result);
end;

function SConsoleRecord(const S : TSString; const P : TSConsoleRecordProcedure) : TSConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Clear();
Result.FTitle := S;
Result.FProcedure := P;
end;

function SConsoleRecord(const S : TSString; const P : TSConsoleRecordNestedProcedure) : TSConsoleRecord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Clear();
Result.FTitle := S;
Result.FNestedProcedure := P;
end;

operator + (const a, b : TSConsoleRecord) : TSConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(Result, 2);
Result[0] := a;
Result[1] := b;
end;

operator + (const a : TSConsoleMenuList; b : TSConsoleRecord) : TSConsoleMenuList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := a;
SetLength(Result, Length(Result) + 1);
Result[High(Result)] := b;
end;

procedure SConsoleMenu(const Ar : TSConsoleMenuList;
	const VBackGround : TSByte = SConsoleMenuDefaultBackGroundColor;
	const VText : TSByte = SConsoleMenuDefaultTextColor;
	const VActiveBackGround : TSByte = SConsoleMenuDefaultActiveBackGroundColor;
	const VActiveText : TSByte = SConsoleMenuDefaultActiveTextColor;
	const Koima : TSBoolean = SConsoleMenuDefaultKoima;
	const ExitAfterExecuting : TSBool = SConsoleMenuDefaultExitAfterExecuting);
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

function SCharRead() : TSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Read(Result);
end;

function SReadLnByte() : TSByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Readln(Result);
end;

end.
