{$INCLUDE SaGe.inc}

unit SaGeStringUtils;

interface

uses
	 Classes
	
	,SaGeBase
	;

(**********)
(** CHAR **)
(**********)

function SGDownCase(const C : TSGChar) : TSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(************)
(** STRING **)
(************)

type
	TSGArStringEnumerator = class
			private
		FList : TSGStringList;
		FIndex : TSGLongInt;
			public
		constructor Create(const List : TSGStringList);
		function GetCurrent(): TSGString;
		function MoveNext(): TSGBoolean;
		property Current : TSGString read GetCurrent;
		end;
	
	TSGStringHelper = type helper for TSGString
		function Len() : TSGMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Length() : TSGMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

function SGStringLength(const S : TSGString) : TSGMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGUpCaseString(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDownCaseString(const Str : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringIf(const B : TSGBoolean; const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGStr(const Number : TSGInt64  ) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGStr(const B      : TSGBoolean) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGStrReal(R : TSGReal; const l : TSGInt32) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFNDEF WITHOUT_EXTENDED}
function SGStrExtended(R : TSGExtended; const l : TSGInt32):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF WITHOUT_EXTENDED}
function SGFloatToString(const R : TSGFloat64; const Zeros : TSGInt32 = 0):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGCheckFloatString(const S : TSGString; const Point : TSGChar = '.') : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGVal(const Text : TSGString) : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGValFloat(const Text : TSGString) : TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
	//Проверяет, не образована ли строка AString как Part + [хз]
function SGExistsFirstPartString(const AString : TSGString; const Part : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	//Возвращает строку, которая содержит размер файла, занимающего Size байт
function SGGetSizeString(const Size : TSGUInt64; const Language : TSGString = 'RU') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	//Возвращаето часть строки, находящуюся между [a..b] включительно
function SGStringGetPart(const S : TSGString; const a, b : TSGUInt32) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetStringFromConstArray(const Ar: array of const) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGArConstToArString(const Ar : array of const) : TSGStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDeleteExcessSpaces(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringReplace(const VString : TSGString; const C1, C2 : TSGChar):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator Enumerator(const List : TSGStringList): TSGArStringEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator in(const VString : TSGString; const VList : TSGStringList) : TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator +(const VList : TSGStringList; const VString : TSGString) : TSGStringList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator in (const C : TSGChar;const S : TSGString):TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGAddrStr(const Source : TSGPointer):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringListFromString(const S : TSGString; const Separators : TSGString) : TSGStringList; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGStringFromStringList(const S : TSGStringList; const Separator : TSGString) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGUpCaseStringList(SL : TSGStringList; const FreeList : TSGBool = False):TSGStringList;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SGStringListTrimAll(var SL : TSGStringList; const Garbage : TSGChar = ' ');{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGStringDeleteEndOfLineDublicates(const VString : TSGString) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

// TStream
function SGReadStringInQuotesFromStream(const Stream : TStream; const Quote: TSGChar = #39) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadLnStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGWriteStringToStream(const String1 : TSGString; const Stream : TStream; const Stavit0 : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringToStream(const Str : TSGString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGMatchingStreamString(const Stream : TStream; const Str : TSGString; const DestroyingStream : TSGBoolean = False) : TSGBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

// TextFile
function SGReadStringInQuotesFromTextFile(const TextFile : PText) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadWordFromTextFile(const TextFile : PTextFile) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(***********)
(** PCHAR **)
(***********)

function SGStringAsPChar(var Str : TSGString) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringToPChar(const S : TSGString) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharNil() : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharIf(const Bool : TSGBoolean; const VPChar : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGPCharFree(const PC : PSGChar; const KillWithLenght : TSGBool = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharLength(const PC : PSGChar) : TSGUInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharLength(const PC : PSGChar) : TSGUInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharToString(const VChar : PSGChar) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharAddSimbol(var VPChar : PSGChar; const VChar : TSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharsEqual(const PChar1, PChar2 : PSGChar) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharHigh(const VPChar : PSGChar) : TSGInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharDecFromEnd(var VPChar : PSGChar; const Number : TSGUInt32 = 1) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharUpCase(const VPChar : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharDeleteSpaces(const VPChar : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGPCharTotal(const VPChar1, VPChar2 : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	//Возвращает часть строки С++, находящуюся между позициями включительно
function SGPCharGetPart(const VPChar : PSGChar; const Position1, Position2 : TSGUInt32) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 StrMan
	,SaGeMathUtils
	;

(************)
(** STRING **)
(************)

function SGStringDeleteEndOfLineDublicates(const VString : TSGString) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	C, lC : TSGChar;
	i : TSGUInt32;
begin
Result := '';
lC  := ' ';
C   := ' ';
if Length(VString) > 0 then
	for i := 1 to Length(VString) do
		if  ( not (
				(VString[i]  in [#13,#10]) and
				(C           in [#13,#10]) and
				(lC          in [#13,#10])
			) ) then
			begin
			lC := C;
			C := VString[i];
			Result += C;
			end;
end;

function SGStringLength(const S : TSGString) : TSGMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Length(S);
end;

function TSGStringHelper.Len() : TSGMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGStringLength(Self);
end;

function TSGStringHelper.Length() : TSGMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGStringLength(Self);
end;

procedure SGStringListTrimAll(var SL : TSGStringList; const Garbage : TSGChar = ' ');{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSGUInt32;
begin
if SL <> nil then
	if Length(SL) > 0 then
		for i := 0 to High(SL) do
			SL[i] := StringTrimAll(SL[i], Garbage);
end;

function SGStringListFromString(const S : TSGString; const Separators : TSGString) : TSGStringList; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	TempS : TSGString;

procedure LoopIteration();
begin
if TempS <> '' then
	begin
	Result += TempS;
	TempS := '';
	end;
end;

var
	i : TSGLongWord;
begin
Result := nil;
i := 1;
TempS := '';
for i := 1 to Length(S) do
	begin
	if S[i] in Separators then
		LoopIteration()
	else
		TempS += S[i];
	end;
LoopIteration();
end;

function SGUpCaseStringList(SL : TSGStringList; const FreeList : TSGBool = False):TSGStringList;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSGUInt32;
begin
Result := nil;
if (SL <> nil) and (Length(SL) > 0) then
	begin
	SetLength(Result, Length(SL));
	for i := 0 to High(SL) do
		Result[i] := SGUpCaseString(SL[i]);
	end;
if FreeList then
	SetLength(SL, 0);
end;

function SGStringFromStringList(const S : TSGStringList; const Separator : TSGString) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSGLongWord;
begin
Result := '';
if S <> nil then
	if Length(S) > 0 then
		begin
		for i := 0 to High(S) do
			begin
			Result += S[i];
			if i <> High(S) then
				Result += Separator;
			end;
		end;
end;

function SGAddrStr(const Source : TSGPointer):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function HexStr(const b : TSGByte):TSGChar;
begin
Result := ' ';
case b of
0:Result := '0';
1:Result := '1';
2:Result := '2';
3:Result := '3';
4:Result := '4';
5:Result := '5';
6:Result := '6';
7:Result := '7';
8:Result := '8';
9:Result := '9';
10:Result := 'A';
11:Result := 'B';
12:Result := 'C';
13:Result := 'D';
14:Result := 'E';
15:Result := 'F';
end;
end;

function ByteStr(const B : TSGByte):TSGString;
begin
Result := HexStr(b shr 4) + HexStr(b and 15);
end;

var
	i : TSGByte;
begin
Result := '$';
for i := {$IFDEF CPU64} 7 {$ELSE} {$IFDEF CPU32} 3 {$ELSE} 1 {$ENDIF} {$ENDIF} downto 0 do
	Result += ByteStr(PSGByte(@Source)[i]);
end;

operator in (const C : TSGChar;const S : TSGString):TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C1 : TSGChar;
begin
Result := False;
for C1 in S do
	if C1 = C then
		begin
		Result := True;
		Break;
		end;
end;

operator +(const VList : TSGStringList; const VString : TSGString) : TSGStringList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := VList;
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
Result[High(Result)] := VString;
end;

operator in(const VString : TSGString; const VList : TSGStringList) : TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	S : TSGString;
begin
Result := False;
for S in VList do
	if S = VString then
		begin
		Result := True;
		break;
		end;
end;

operator Enumerator(const List : TSGStringList): TSGArStringEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSGArStringEnumerator.Create(List);
end;

constructor TSGArStringEnumerator.Create(const List : TSGStringList);
begin
FList := List;
FIndex := -1;
end;

function TSGArStringEnumerator.GetCurrent(): TSGString;
begin
Result := FList[FIndex];
end;

function TSGArStringEnumerator.MoveNext(): TSGBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

function SGStringReplace(const VString : TSGString; const C1, C2 : TSGChar):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := VString;
for i := 1 to Length(Result) do
	if Result[i] = C1 then
		Result[i] := C2;
end;

function SGDeleteExcessSpaces(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function LastCharacter(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
if (S <> '') and (S[Length(S)] = ' ') then
	Result := ' ';
end;

var
	i : TSGLongWord;
begin
Result := '';
if Length(S) > 0 then
	for i := 1 to Length(S) do
		begin
		if S[i] = ' ' then
			begin
			if LastCharacter(Result) <> ' ' then
				Result += S[i];
			end
		else
			begin
			Result += S[i];
			end;
		end;
end;

function SGDownCaseString(const Str : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGMaxEnum;
begin
Result := '';
for i := 1 to Length(str) do
	Result += SGDownCase(str[i]);
end;

function SGArConstToArString(const Ar : array of const) : TSGStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	TSGExtended = Extended;
var
	i : TSGUInt32;
begin
SetLength(Result, Length(Ar));
if High(Ar)>=0 then
	begin
	for i := 0 to High(Ar) do
		case Ar[i].vtype of
		vtInteger:
			Result[i] := SGStr(Ar[i].vInteger);
		vtString:
			Result[i] := Ar[i].vString^;
		vtAnsiString:
			Result[i] := AnsiString(Ar[i].vPointer);
		vtBoolean:
			Result[i] := SGStr(Ar[i].vBoolean);
		vtChar:
			Result[i] := Ar[i].vChar;
		vtExtended:
			Result[i] := SGStrReal(TSGExtended(Ar[i].vPointer^), 5);
		end;
	end;
end;

function SGGetStringFromConstArray(const Ar: array of const) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	TSGExtended = Extended;
var
	i : TSGUInt32;
begin
Result := '';
if High(Ar) >= 0 then
	begin
	for i := 0 to High(Ar) do
		case Ar[i].vtype of
		vtInteger:
			Result += SGStr(Ar[i].vInteger);
		vtString:
			Result += Ar[i].vString^;
		vtAnsiString:
			Result += AnsiString(ar[i].vPointer);
		vtBoolean:
			Result += SGStr(Ar[i].vBoolean);
		vtChar:
			Result += Ar[i].vChar;
		vtExtended:
			Result += SGStrReal(TSGExtended(Ar[i].vPointer^), 5);
		end;
	end;
end;

function SGFloatToString(const R : TSGDouble; const Zeros : TSGInt32 = 0):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
begin
Result := '';
if Trunc(R)=0 then
	begin
	if R < 0 then
		Result += '-';
	Result += '0';
	end
else
	Result += SGStr(Trunc(R));
if Zeros <> 0 then
	begin
	if Abs(R - Trunc(R)) * 10 ** Zeros <> 0 then
		begin
		i := Zeros - SGCountSimbolsInNumber(Trunc(Abs(R - Trunc(R)) * (10 ** Zeros)));
		Result += '.';
		while i > 0 do
			begin
			i -= 1;
			Result += '0';
			end;
		Result += SGStr(Trunc(Abs(R - Trunc(R)) * (10 ** Zeros)));
		while Result[Length(Result)] = '0' do
			SetLength(Result, Length(Result) - 1);
		if Result[Length(Result)] = '.' then
			SetLength(Result, Length(Result)-1);
		end;
	end;
end;

function SGCheckFloatString(const S : TSGString; const Point : TSGChar = '.') : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ExistPoint(const S : TSGString) : TSGBool;
var
	i : TSGUInt32;
begin
Result := False;
for i := 1 to Length(S) do
	if S[i] = Point then
		begin
		Result := True;
		break;
		end;
end;

function NeedDeletionZeros(const S : TSGString) : TSGBool;
begin
Result := ExistPoint(S) and (S[Length(S)] = '0');
end;

function DeleteZeros(const S : TSGString) : TSGString;
begin
Result := S;
while Result[Length(Result)] = '0' do
	SetLength(Result, Length(Result) - 1);
if Result[Length(Result)] = '.' then
	SetLength(Result, Length(Result) - 1);
if Result = '' then
	Result := '0';
end;

function TruncNines(var S : TSGString; const CountNines : TSGUInt16 = 4) : TSGBool;

function AddOne(S2 : TSGString) : TSGString;
var
	S3 : TSGString;
	P : TSGBool;

function IfPoint() : TSGString;
begin
Result := '';
if P then
	Result := Point;
end;

begin
P := False;
if (S2 = '0') or (S2 = '') then
	S2 := '1' 
else
	begin
	if (Length(S2) > 0) then
		begin
		if S2[Length(S2)] = Point then
			begin
			SetLength(S2, Length(S2) - 1);
			P := True;
			end;
		S3 := S2;
		SetLength(S2, Length(S2) - 1);
		if SGStr(SGVal(S3[Length(S3)]) + 1) = '10' then
			begin
			S2 := AddOne(S2) + IfPoint() + '0';
			end
		else
			S2 += IfPoint() + SGStr(SGVal(S3[Length(S3)]) + 1);
		end;
	end;
Result := S2;
end;

var
	Nines : TSGUInt16;
	S2 : TSGString;
begin
S2 := S;
Nines := 0;
Result := False;
if ExistPoint(S) then
	while (Length(S2) > 0) and (S2[Length(S2)] = '9') do
		begin
		SetLength(S2, Length(S2) - 1);
		Nines += 1;
		end;
if Nines >= CountNines then
	begin
	if (Length(S2) > 0) and (S2[Length(S2)] = '.') then
		SetLength(S2, Length(S2) - 1);
	S2 := AddOne(S2);
	Result := S <> S2;
	S := S2;
	end;
end;

begin
Result := S;
if NeedDeletionZeros(Result) then
	Result := DeleteZeros(Result);
if TruncNines(Result) then
	if NeedDeletionZeros(Result) then
		Result := DeleteZeros(Result);
end;

function SGStrReal(R : TSGReal; const l : TSGInt32) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
begin
if R < 0 then
	Result := '-'
else
	Result := '';
R := abs(R);
Result += SGStr(Trunc(R));
R -= trunc(R);
R := abs(R);
if R > 1 / (10 ** l) then
	begin
	Result += '.';
	for i := 1 to l do
		begin
		if R = 0 then
			Break;
		R *= 10;
		Result += SGStr(trunc(R));
		R -= trunc(R);
		end;
	end;
if (Result = '') or (Result = '-') then
	Result += '0';
Result := SGCheckFloatString(Result);
end;

{$IFNDEF WITHOUT_EXTENDED}
function SGStrExtended(R : TSGExtended; const l : TSGInt32):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
begin
if R < 0 then
	Result := '-'
else
	Result := '';
if  ((SGStr(Trunc(Abs(R)))    = '9223372036854775808') and
	((SGStr(Trunc(Abs(R/100)))= '9223372036854775808'))) or
	((SGStr(Trunc(Abs(R)))    ='-9223372036854775808') and
	((SGStr(Trunc(Abs(R/100)))='-9223372036854775808'))) then
		begin
		Result += 'Inf';
		Exit();
		end;
R := abs(R);
Result += SGStr(Trunc(R));
R -= Trunc(R);
R := abs(R);
if R > 1 / (10 ** l) then
	begin
	Result += '.';
	for i := 1 to l do
		begin
		if R = 0 then
			Break;
		R *= 10;
		Result += SGStr(Trunc(R));
		R -= Trunc(R);
		end;
	end;
if (Result = '') or (Result = '-') then
	Result += '0';
Result := SGCheckFloatString(Result);
end;
{$ENDIF WITHOUT_EXTENDED}

function SGVal(const Text : TSGString) : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Val(Text, Result);
end;

function SGValFloat(const Text : TSGString) : TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	i, iii : TSGInt32;
	ii : TSGUInt32;
begin
Result := 0;
if Length(Text) = 0 then Exit;
for i := 1 to Length(Text) do
	if (Text[i] = ',') or (Text[i] = '.') then
		break;
iii := i;
if (Text[i] = ',') or (Text[i] = '.') then
	i -= 1;
ii := 1;
while i >= 1 do
	begin
	Result += ii * SGVal(Text[i]);
	ii *= 10;
	i -= 1;
	end;
i := iii;
i += 1;
ii := 10;
while i <= Length(Text) do
	begin
	Result += SGVal(Text[i]) / ii;
	i += 1;
	ii *= 10;
	end;
for i := 1 to Length(Text) do
	if Text[i] = '-' then
		begin
		Result *= -1;
		break;
		end;
end;

function SGStringGetPart(const S : TSGString; const a, b : TSGUInt32) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
Result := '';
for i := a to b do
	Result += S[i];
end;

function SGGetSizeString(const Size : TSGUInt64; const Language : TSGString = 'RU') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	e:extended;
	d:LongWord = 0;
begin
if Size<1024 then
	begin
	Result:=SGStr(Size);
	if Language='RU' then
		Result+=' байт'
	else
		Result+=' byte';
	end
else
	begin
	e:=Size;
	repeat
	e:=e/1024;
	d+=1;
	until e<1024;
	Result:=SGStrReal(e,2);
	case d of
	1:
		if Language='RU' then
			Result+=' КБайт'
		else
			Result+=' KByte';
	2:
		if Language='RU' then
			Result+=' MБайт'
		else
			Result+=' MByte';
	3:
		if Language='RU' then
			Result+=' ГБайт'
		else
			Result+=' GByte';
	4:
		if Language='RU' then
			Result+=' ТБайт'
		else
			Result+=' TByte';
	end;
	end;
end;

function SGStr(const B : TSGBoolean) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if b then
	Result := 'TRUE'
else
	Result := 'FALSE';
end;

function SGExistsFirstPartString(const AString : TSGString; const Part : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
begin
if Length(Part) > Length(AString) then
	Result := False
else
	if Part = AString then
		Result := False
	else
		begin
		Result := True;
		for i := 1 to Length(Part) do
			begin
			if Part[i] <> AString[i] then
				Result := False;
			if Result = False then
				Break;
			end;
		end;
end;

function SGStr(const Number : TSGInt64) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Str(Number, Result);
end;

function SGStringIf(const B : TSGBoolean; const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if B then
	Result := S
else
	Result := '';
end;

function SGUpCaseString(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
SetLength(Result, Length(S));
for i := 1 to Length(S) do
	Result[i] := UpCase(S[i]);
end;

// TStream

function SGMatchingStreamString(const Stream : TStream; const Str : TSGString; const DestroyingStream : TSGBoolean = False) : TSGBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Str2 : TSGString = '';
	C : TSGChar;
begin
Result := False;
while (Stream.Size <> Stream.Position) and (Length(Str2) < Length(Str)) do
	begin
	Stream.Read(C, 1);
	Str2 += C;
	end;
Result := Str2 = Str;
if DestroyingStream then
	Stream.Destroy();
end;

function SGStringToStream(const Str : TSGString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := TMemoryStream.Create();
SGWriteStringToStream(Str, Result, False);
end;

function SGReadStringInQuotesFromStream(const Stream : TStream; const Quote: TSGChar = #39) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar;
begin
Result := '';
Stream.ReadBuffer(C, SizeOf(C));
repeat
Stream.ReadBuffer(C, SizeOf(C));
if C <> Quote then
	Result += C;
until C = Quote;
end;

procedure SGWriteStringToStream(const String1 : TSGString; const Stream : TStream; const Stavit0 : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #0;
begin
Stream.WriteBuffer(String1[1], Length(String1));
if Stavit0 then
	Stream.WriteBuffer(C, SizeOf(TSGChar));
end;

function SGReadLnStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #1;
	ToOut : TSGBoolean = False;
begin
Result:='';
while (Stream.Position < Stream.Size) and ((not ToOut) or (C in Eolns))  do
	begin
	Stream.ReadBuffer(c, 1);
	if (C in Eolns) then
		ToOut := True
	else if (not ToOut) then
		Result += c;
	end;
if Stream.Position <> Stream.Size then
	Stream.Position := Stream.Position - 1;
end;

function SGReadStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #1;
	First : TSGBool = True;
begin
Result:='';
while ((not (C in Eolns)) or First) and (Stream.Position <> Stream.Size) do
	begin
	Stream.ReadBuffer(C, 1);
	if not (C in Eolns) then
		Result += C;
	First := False;
	end;
end;

// TextFile

function SGReadWordFromTextFile(const TextFile : PTextFile) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #0;
begin
Result := '';
Read(TextFile^, C);
while c = ' ' do
	Read(TextFile^, C);
while (c <> ' ') and (not Eoln(TextFile^)) do
	begin
	Result += C;
	Read(TextFile^, C);
	end;
end;

function SGReadStringInQuotesFromTextFile(const TextFile : PText) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #0;
begin
Result := '';
Read(TextFile^, C);
while (c in [' ','	']) do
	Read(TextFile^, C);
if c='"' then
	begin
	Read(TextFile^, C);
	while (c <> '"') do
		begin
		Result += C;
		Read(TextFile^, C);
		end;
	end
else
	Result := '';
end;

(***********)
(** PCHAR **)
(***********)

function SGPCharLength(const PC : PSGChar) : TSGUInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGPCharHigh(PC) + 1;
end;

function SGPCharLength(const PC : PSGChar) : TSGUInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := StrLen(PC);
end;

function SGStringAsPChar(var Str : TSGString) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Length(Str) = 0) or ((Length(Str) > 0) and (Str[Length(Str)] <> #0)) then
	Str += #0;
Result := @Str[1];
end;

function SGPCharNil() : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
GetMem(Result, 1);
Result[0] := #0;
end;

function SGPCharIf(const Bool : TSGBoolean; const VPChar : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Bool then
	Result := VPChar
else
	Result := nil;
end;

function SGStringToPChar(const S : TSGString) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
begin
GetMem(Result, Length(s) + 1);
for i := 1 to Length(s) do
	Result[i-1] := s[i];
Result[i] := #0;
end;

function SGPCharToString(const VChar : PSGChar) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32 = 0;
begin
Result := '';
try
	while TSGByte(VChar[i]) <> 0 do
		begin
		Result += VChar[i];
		i += 1;
		end;
except
	Result := '';
end;
end;

function SGPCharGetPart(const VPChar : PSGChar; const Position1, Position2 : TSGUInt32) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
begin
Result := '';
i := Position1;
while (VPChar[i] <> #0) and (i <> Position2 + 1) do
	begin
	SGPCharAddSimbol(Result, VPChar[i]);
	i += 1;
	end;
end;

function SGPCharTotal(const VPChar1, VPChar2 : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Length1 : TSGInt32 = 0;
	Length2 : TSGInt32 = 0;
	I : TSGInt32 = 0;
begin
Length1 := SGPCharLength(VPChar1);
Length2 := SGPCharLength(VPChar2);
Result := nil;
GetMem(Result, Length1 + Length2 + 1);
Result[Length1+Length2] := #0;
for I := 0 to Length1 - 1 do
	Result[I] := VPChar1[i];
for i:=Length1 to Length1 + Length2 - 1 do
	Result[I] := VPChar2[I - Length1];
end;

function SGPCharDeleteSpaces(const VPChar : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	I : TSGInt32 = 0;
begin
GetMem(Result, 1);
Result^ := #0;
while VPChar[i] <> #0 do
	begin
	if VPChar[i] <> ' ' then
		SGPCharAddSimbol(Result, VPChar[i]);
	I += 1;
	end;
end;

function SGPCharUpCase(const VPChar : PSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32 = 0;
begin
Result := nil;
if (VPChar <> nil) then
	begin
	I := SGPCharLength(VPChar);
	GetMem(Result, I + 1);
	Result[I] := #0;
	I := 0;
	while VPChar[i] <> #0 do
		begin
		Result[i] := UpCase(VPChar[i]);
		I += 1;
		end;
	end;
end;

function SGPCharDecFromEnd(var VPChar : PSGChar; const Number : TSGUInt32 = 1) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	NewVPChar : PSGChar = nil;
	LengthOld : TSGInt32 = 0;
	I : TSGInt32 = 0;
begin
LengthOld := SGPCharLength(VPChar);
GetMem(NewVPChar, LengthOld - Number + 1);
for I := 0 to LengthOld - Number-1 do
	NewVPChar[i] := VPChar[i];
NewVPChar[LengthOld - Number] := #0;
VPChar := NewVPChar;
Result := NewVPChar;
end;

function SGPCharHigh(const VPChar : PSGChar) : TSGInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (VPChar = nil) or (VPChar[0] = #0) then
	Result := -1
else
	begin
	Result := 0;
	while VPChar[Result] <> #0 do
		Result += 1;
	Result -= 1;
	end;
end;

function SGPCharsEqual(const PChar1, PChar2 : PSGChar) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	I : TSGInt32 = 0;
	VExit : TSGBoolean = False;
begin
Result := True;
if not ((PChar1 = nil) and (PChar2 = nil)) then
	while Result and (not VExit) do
		begin
		if (PChar1 = nil) or (PChar2 = nil) or (PChar1[i] = #0) or (PChar2[i] = #0) then
			VExit := True;
		if  ((PChar1 = nil) and (PChar2 <> nil) and (PChar2[i] <> #0)) or
			((PChar2 = nil) and (PChar1 <> nil) and (PChar1[i] <> #0)) then
				Result := False
		else
			if (PChar1 <> nil) and (PChar2 <> nil) and
				(((PChar1[i] = #0) and (PChar2[i] <> #0)) or
				 ((PChar2[i] = #0) and (PChar1[i] <> #0))) then
					Result := False
			else
				if (PChar1 <> nil) and (PChar2 <> nil) and
					(PChar1[i] <> #0) and (PChar2[i] <> #0) and
					(PChar1[i] <> PChar2[i]) then
						Result := False;
		I += 1;
		end;
end;

function SGPCharAddSimbol(var VPChar : PSGChar; const VChar : TSGChar) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	NewVPChar : PSGChar = nil;
	LengthOld : TSGInt32 = 0;
	I : TSGInt32 = 0;
begin
if VPChar <> nil then
	begin
	while (VPChar[LengthOld] <> #0) do
		LengthOld += 1;
	end;
GetMem(NewVPChar, LengthOld + 2);
for I := 0 to LengthOld - 1 do
	NewVPChar[i] := VPChar[i];
NewVPChar[LengthOld] := VChar;
NewVPChar[LengthOld + 1] := #0;
VPChar := NewVPChar;
Result := NewVPChar;
end;

procedure SGPCharFree(const PC : PSGChar; const KillWithLenght : TSGBool = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if not KillWithLenght then
	FreeMem(PC)
else
	FreeMem(PC, SGPCharLength(PC) + 1);
end;

(**********)
(** CHAR **)
(**********)

function SGDownCase(const C : TSGChar) : TSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if c in ['A'..'Z'] then
	Result := TSGChar(TSGByte(C) - (TSGByte('A') - TSGByte('a')))
else
	Result := C;
end;

end.
