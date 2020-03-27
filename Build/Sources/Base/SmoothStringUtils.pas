{$INCLUDE Smooth.inc}

unit SmoothStringUtils;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothLists
	;

(**********)
(** CHAR **)
(**********)

function SDownCase(const C : TSChar) : TSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(************)
(** STRING **)
(************)

type
	TSArStringEnumerator = class
			private
		FList : TSStringList;
		FIndex : TSLongInt;
			public
		constructor Create(const List : TSStringList);
		function GetCurrent(): TSString;
		function MoveNext(): TSBoolean;
		property Current : TSString read GetCurrent;
		end;
	
	TSStringHelper = type helper for TSString
		function Len() : TSMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Length() : TSMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

function SStringLength(const S : TSString) : TSMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SUpCaseString(const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SDownCaseString(const Str : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStringIf(const B : TSBoolean; const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SStr(const Number : TSInt64  ) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SStr(const B      : TSBoolean) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SStrReal(R : TSReal; const l : TSInt32) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFNDEF WITHOUT_EXTENDED}
function SStrExtended(R : TSExtended; const l : TSInt32):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF WITHOUT_EXTENDED}
function SFloatToString(const R : TSFloat64; const Zeros : TSInt32 = 0):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SCheckFloatString(const S : TSString; const Point : TSChar = '.') : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SVal(const Text : TSString) : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SValFloat(const Text : TSString) : TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
	//Проверяет, не образована ли строка AString как Part + [хз]
function SExistsFirstPartString(const AString : TSString; const Part : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	//Возвращает строку, которая содержит размер "файла"/"буфера", занимающего Size байт
function SGetSizeString(const Size : TSUInt64; const Language : TSString = 'RU') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	//Возвращаето часть строки, находящуюся между [a..b] включительно
function SStringGetPart(const S : TSString; const a, b : TSUInt32) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SConstArrayToString(const Ar: array of const) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SStr(const Ar: array of const) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SConstArrayToStringList(const Ar : array of const) : TSStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SDeleteExcessSpaces(const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStringReplace(const VString : TSString; const C1, C2 : TSChar):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SAddrStr(const Source : TSPointer; const RegisterType : TSBoolean = True; const Prefix : TSString = '$'):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStringListFromString(const S : TSString; const Separators : TSString) : TSStringList; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SStringFromStringList(const S : TSStringList; const Separator : TSString) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SUpCaseStringList(var SL : TSStringList);overload;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SUpCasedStringList(SL : TSStringList; const FreeList : TSBool = False):TSStringList; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SStringListTrimAll(var SL : TSStringList; const Garbage : TSChar = ' ');{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SStringDeleteEndOfLineDublicates(const VString : TSString) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

operator Enumerator(const List : TSStringList): TSArStringEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator in(const VString : TSString; const VList : TSStringList) : TSBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator in (const C : TSChar;const S : TSString):TSBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator +(const VList : TSStringList; const VString : TSString) : TSStringList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Hex
var
	SDefaultHexPrefix : TSString = '$'; // "0x"
function SStr2BytesHex(const Value : TSUInt16; const RegisterType : TSBoolean = True) : TSString; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SStr4BytesHex(const Value : TSUInt32; const RegisterType : TSBoolean = True) : TSString; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SStrByteHex(const Value : TSUInt8; const RegisterType : TSBoolean = True) : TSString; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SStr4BitsHex(const Bits : TSUInt8; const RegisterType : TSBoolean = True) : TSChar; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

// TextFile
function SReadStringInQuotesFromTextFile(const TextFile : PText) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadWordFromTextFile(const TextFile : PTextFile) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(***********)
(** PCHAR **)
(***********)

function SStringAsPChar(var Str : TSString) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStringToPChar(const S : TSString) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharNil() : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharIf(const Bool : TSBoolean; const VPChar : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SPCharFree(const PC : PSChar; const KillWithLenght : TSBool = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharLength(const PC : PSChar) : TSUInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharLength(const PC : PSChar) : TSUInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharToString(const VChar : PSChar) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharAddSimbol(var VPChar : PSChar; const VChar : TSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharsEqual(const PChar1, PChar2 : PSChar) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharHigh(const VPChar : PSChar) : TSInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharDecFromEnd(var VPChar : PSChar; const Number : TSUInt32 = 1) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharUpCase(const VPChar : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharDeleteSpaces(const VPChar : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPCharTotal(const VPChar1, VPChar2 : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
	//Возвращает часть строки С++, находящуюся между позициями включительно
function SPCharGetPart(const VPChar : PSChar; const Position1, Position2 : TSUInt32) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 StrMan
	
	,Variants
	
	,SmoothMathUtils
	,SmoothBaseUtils
	;

(************)
(** STRING **)
(************)

function SStr4BytesHex(const Value : TSUInt32; const RegisterType : TSBoolean = True) : TSString; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result :=
	SStrByteHex(PSByte(@Value)[3], RegisterType) +
	SStrByteHex(PSByte(@Value)[2], RegisterType) +
	SStrByteHex(PSByte(@Value)[1], RegisterType) +
	SStrByteHex(PSByte(@Value)[0], RegisterType);
end;

function SStr2BytesHex(const Value : TSUInt16; const RegisterType : TSBoolean = True) : TSString; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := SStrByteHex(PSByte(@Value)[1], RegisterType) + SStrByteHex(PSByte(@Value)[0], RegisterType);
end;

function SStrByteHex(const Value : TSUInt8; const RegisterType : TSBoolean = True) : TSString; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := SStr4BitsHex(Value shr 4, RegisterType) + SStr4BitsHex(Value and 15, RegisterType);
end;

function SStr4BitsHex(const Bits : TSUInt8; const RegisterType : TSBoolean = True) : TSChar; overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case Bits of
0  : Result := '0';
1  : Result := '1';
2  : Result := '2';
3  : Result := '3';
4  : Result := '4';
5  : Result := '5';
6  : Result := '6';
7  : Result := '7';
8  : Result := '8';
9  : Result := '9';
10 : if RegisterType then Result := 'A' else Result := 'a';
11 : if RegisterType then Result := 'B' else Result := 'b';
12 : if RegisterType then Result := 'C' else Result := 'c';
13 : if RegisterType then Result := 'D' else Result := 'd';
14 : if RegisterType then Result := 'E' else Result := 'e';
15 : if RegisterType then Result := 'F' else Result := 'f';
else Result := '?';
end;
end;

function SStringDeleteEndOfLineDublicates(const VString : TSString) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	C, lC : TSChar;
	i : TSUInt32;
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

function SStringLength(const S : TSString) : TSMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Length(S);
end;

function TSStringHelper.Len() : TSMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SStringLength(Self);
end;

function TSStringHelper.Length() : TSMaxEnum; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SStringLength(Self);
end;

procedure SStringListTrimAll(var SL : TSStringList; const Garbage : TSChar = ' ');{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSUInt32;
begin
if SL <> nil then
	if Length(SL) > 0 then
		for i := 0 to High(SL) do
			SL[i] := StringTrimAll(SL[i], Garbage);
end;

function SStringListFromString(const S : TSString; const Separators : TSString) : TSStringList; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	TempS : TSString;

procedure LoopIteration();
begin
if TempS <> '' then
	begin
	Result += TempS;
	TempS := '';
	end;
end;

var
	i : TSLongWord;
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

procedure SUpCaseStringList(var SL : TSStringList);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSUInt32;
begin
if (SL <> nil) and (Length(SL) > 0) then
	for i := 0 to High(SL) do
		SL[i] := SUpCaseString(SL[i]);
end;

function SUpCasedStringList(SL : TSStringList; const FreeList : TSBool = False):TSStringList;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSUInt32;
begin
Result := nil;
if (SL <> nil) and (Length(SL) > 0) then
	begin
	SetLength(Result, Length(SL));
	for i := 0 to High(SL) do
		Result[i] := SUpCaseString(SL[i]);
	end;
if FreeList then
	SetLength(SL, 0);
end;

function SStringFromStringList(const S : TSStringList; const Separator : TSString) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSLongWord;
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

function SAddrStr(const Source : TSPointer; const RegisterType : TSBoolean = True; const Prefix : TSString = '$'):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSByte;
begin
Result := Prefix;
for Index := SizeOf(TSPointer) - 1 downto 0 do
	Result += SStrByteHex(PSByte(@Source)[Index], RegisterType);
end;

operator in (const C : TSChar;const S : TSString):TSBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C1 : TSChar;
begin
Result := False;
for C1 in S do
	if C1 = C then
		begin
		Result := True;
		Break;
		end;
end;

operator +(const VList : TSStringList; const VString : TSString) : TSStringList;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := VList;
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
Result[High(Result)] := VString;
end;

operator in(const VString : TSString; const VList : TSStringList) : TSBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	S : TSString;
begin
Result := False;
for S in VList do
	if S = VString then
		begin
		Result := True;
		break;
		end;
end;

operator Enumerator(const List : TSStringList): TSArStringEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSArStringEnumerator.Create(List);
end;

constructor TSArStringEnumerator.Create(const List : TSStringList);
begin
FList := List;
FIndex := -1;
end;

function TSArStringEnumerator.GetCurrent(): TSString;
begin
Result := FList[FIndex];
end;

function TSArStringEnumerator.MoveNext(): TSBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

function SStringReplace(const VString : TSString; const C1, C2 : TSChar):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
begin
Result := VString;
for i := 1 to Length(Result) do
	if Result[i] = C1 then
		Result[i] := C2;
end;

function SDeleteExcessSpaces(const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function LastCharacter(const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
if (S <> '') and (S[Length(S)] = ' ') then
	Result := ' ';
end;

var
	i : TSLongWord;
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

function SDownCaseString(const Str : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSMaxEnum;
begin
Result := '';
for i := 1 to Length(str) do
	Result += SDownCase(str[i]);
end;

function SConstArrayToStringList(const Ar : array of const) : TSStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	TSExtended = Extended;
var
	Index : TSUInt32;
begin
SetLength(Result, Length(Ar));
if Length(Ar) > 0 then
	for Index := 0 to High(Ar) do
		with Ar[Index] do
			case vType of
			vtInteger    : Result[Index] := SStr(vInteger);
			vtBoolean    : Result[Index] := SStr(vBoolean);
			vtChar       : Result[Index] := vChar;
			vtWideChar   : Result[Index] := vWideChar;
			vtExtended   : Result[Index] := SStrReal(TSExtended(vExtended^), 5);
			vtString     : Result[Index] := vString^;
			vtPointer    : Result[Index] := SAddrStr(vPointer);
			vtPChar      : Result[Index] := SPCharToString(vPChar);
			vtObject     : Result[Index] := Iff(vObject <> nil, vObject.ClassName(), 'TObject') + '(' + SAddrStr(vObject) + ')';
			vtClass      : Result[Index] := Iff(vClass <> nil, vClass.ClassName(), 'TClass') + '(' + SAddrStr(vClass) + ')';
			vtPWideChar  : Result[Index] := WideCharLenToString(vPWideChar, Length(vPWideChar));
			vtAnsiString : Result[Index] := AnsiString(vPointer);
			vtCurrency   : Result[Index] := SStrReal(vCurrency^, 4);
			vtVariant    : Result[Index] := VarToStr(vVariant^);
			vtInterface  : Result[Index] := 'Interface(' + SAddrStr(vInterface) + ')';
			vtWideString : Result[Index] := AnsiString(vWideString);
			vtInt64      : Result[Index] := SStr(vInt64^);
			vtQWord      : Result[Index] := SStr(vQWord^);
			end;
end;

function SStr(const Ar: array of const) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := SConstArrayToString(Ar);
end;

function SConstArrayToString(const Ar: array of const) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	StringList : TSStringList = nil;
begin
Result := '';
StringList := SConstArrayToStringList(Ar);
Result := SStringFromStringList(StringList, '');
SetLength(StringList, 0);
end;

function SFloatToString(const R : TSDouble; const Zeros : TSInt32 = 0):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32;
begin
Result := '';
if Trunc(R)=0 then
	begin
	if R < 0 then
		Result += '-';
	Result += '0';
	end
else
	Result += SStr(Trunc(R));
if Zeros <> 0 then
	begin
	if Abs(R - Trunc(R)) * 10 ** Zeros <> 0 then
		begin
		i := Zeros - SCountSimbolsInNumber(Trunc(Abs(R - Trunc(R)) * (10 ** Zeros)));
		Result += '.';
		while i > 0 do
			begin
			i -= 1;
			Result += '0';
			end;
		Result += SStr(Trunc(Abs(R - Trunc(R)) * (10 ** Zeros)));
		while Result[Length(Result)] = '0' do
			SetLength(Result, Length(Result) - 1);
		if Result[Length(Result)] = '.' then
			SetLength(Result, Length(Result)-1);
		end;
	end;
end;

function SCheckFloatString(const S : TSString; const Point : TSChar = '.') : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ExistPoint(const S : TSString) : TSBool;
var
	i : TSUInt32;
begin
Result := False;
for i := 1 to Length(S) do
	if S[i] = Point then
		begin
		Result := True;
		break;
		end;
end;

function NeedDeletionZeros(const S : TSString) : TSBool;
begin
Result := ExistPoint(S) and (S[Length(S)] = '0');
end;

function DeleteZeros(const S : TSString) : TSString;
begin
Result := S;
while Result[Length(Result)] = '0' do
	SetLength(Result, Length(Result) - 1);
if Result[Length(Result)] = '.' then
	SetLength(Result, Length(Result) - 1);
if Result = '' then
	Result := '0';
end;

function TruncNines(var S : TSString; const CountNines : TSUInt16 = 4) : TSBool;

function AddOne(S2 : TSString) : TSString;
var
	S3 : TSString;
	P : TSBool;

function IfPoint() : TSString;
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
		if SStr(SVal(S3[Length(S3)]) + 1) = '10' then
			begin
			S2 := AddOne(S2) + IfPoint() + '0';
			end
		else
			S2 += IfPoint() + SStr(SVal(S3[Length(S3)]) + 1);
		end;
	end;
Result := S2;
end;

var
	Nines : TSUInt16;
	S2 : TSString;
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

function SStrReal(R : TSReal; const l : TSInt32) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32;
begin
if R < 0 then
	Result := '-'
else
	Result := '';
R := abs(R);
Result += SStr(Trunc(R));
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
		Result += SStr(trunc(R));
		R -= trunc(R);
		end;
	end;
if (Result = '') or (Result = '-') then
	Result += '0';
Result := SCheckFloatString(Result);
end;

{$IFNDEF WITHOUT_EXTENDED}
function SStrExtended(R : TSExtended; const l : TSInt32):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32;
begin
if R < 0 then
	Result := '-'
else
	Result := '';
if  ((SStr(Trunc(Abs(R)))    = '9223372036854775808') and
	((SStr(Trunc(Abs(R/100)))= '9223372036854775808'))) or
	((SStr(Trunc(Abs(R)))    ='-9223372036854775808') and
	((SStr(Trunc(Abs(R/100)))='-9223372036854775808'))) then
		begin
		Result += 'Inf';
		Exit();
		end;
R := abs(R);
Result += SStr(Trunc(R));
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
		Result += SStr(Trunc(R));
		R -= Trunc(R);
		end;
	end;
if (Result = '') or (Result = '-') then
	Result += '0';
Result := SCheckFloatString(Result);
end;
{$ENDIF WITHOUT_EXTENDED}

function SVal(const Text : TSString) : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Val(Text, Result);
end;

function SValFloat(const Text : TSString) : TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	i, iii : TSMaxEnum;
	ii : TSMaxEnum;
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
	Result += ii * SVal(Text[i]);
	ii *= 10;
	i -= 1;
	end;
i := iii;
i += 1;
ii := 10;
while i <= Length(Text) do
	begin
	Result += SVal(Text[i]) / ii;
	i += 1;
	ii := ii * 10;
	//WriteLn(ii);ReadLn();
	end;
for i := 1 to Length(Text) do
	if Text[i] = '-' then
		begin
		Result *= -1;
		break;
		end;
end;

function SStringGetPart(const S : TSString; const a, b : TSUInt32) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSUInt32;
begin
Result := '';
for i := a to b do
	Result += S[i];
end;

function SGetSizeString(const Size : TSUInt64; const Language : TSString = 'RU') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	e:extended;
	d:LongWord = 0;
begin
if Size<1024 then
	begin
	Result:=SStr(Size);
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
	Result:=SStrReal(e,2);
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

function SStr(const B : TSBoolean) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if b then
	Result := 'TRUE'
else
	Result := 'FALSE';
end;

function SExistsFirstPartString(const AString : TSString; const Part : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32;
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

function SStr(const Number : TSInt64) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Str(Number, Result);
end;

function SStringIf(const B : TSBoolean; const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if B then
	Result := S
else
	Result := '';
end;

function SUpCaseString(const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSUInt32;
begin
SetLength(Result, Length(S));
for i := 1 to Length(S) do
	Result[i] := UpCase(S[i]);
end;

// TextFile

function SReadWordFromTextFile(const TextFile : PTextFile) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar = #0;
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

function SReadStringInQuotesFromTextFile(const TextFile : PText) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar = #0;
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

function SPCharLength(const PC : PSChar) : TSUInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SPCharHigh(PC) + 1;
end;

function SPCharLength(const PC : PSChar) : TSUInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := StrLen(PC);
end;

function SStringAsPChar(var Str : TSString) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Length(Str) = 0) or ((Length(Str) > 0) and (Str[Length(Str)] <> #0)) then
	Str += #0;
Result := @Str[1];
end;

function SPCharNil() : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
GetMem(Result, 1);
Result[0] := #0;
end;

function SPCharIf(const Bool : TSBoolean; const VPChar : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Bool then
	Result := VPChar
else
	Result := nil;
end;

function SStringToPChar(const S : TSString) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32;
begin
GetMem(Result, Length(s) + 1);
for i := 1 to Length(s) do
	Result[i-1] := s[i];
Result[i] := #0;
end;

function SPCharToString(const VChar : PSChar) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32 = 0;
begin
Result := '';
try
	while TSByte(VChar[i]) <> 0 do
		begin
		Result += VChar[i];
		i += 1;
		end;
except
	Result := '';
end;
end;

function SPCharGetPart(const VPChar : PSChar; const Position1, Position2 : TSUInt32) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32;
begin
Result := '';
i := Position1;
while (VPChar[i] <> #0) and (i <> Position2 + 1) do
	begin
	SPCharAddSimbol(Result, VPChar[i]);
	i += 1;
	end;
end;

function SPCharTotal(const VPChar1, VPChar2 : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Length1 : TSInt32 = 0;
	Length2 : TSInt32 = 0;
	I : TSInt32 = 0;
begin
Length1 := SPCharLength(VPChar1);
Length2 := SPCharLength(VPChar2);
Result := nil;
GetMem(Result, Length1 + Length2 + 1);
Result[Length1+Length2] := #0;
for I := 0 to Length1 - 1 do
	Result[I] := VPChar1[i];
for i:=Length1 to Length1 + Length2 - 1 do
	Result[I] := VPChar2[I - Length1];
end;

function SPCharDeleteSpaces(const VPChar : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	I : TSInt32 = 0;
begin
GetMem(Result, 1);
Result^ := #0;
while VPChar[i] <> #0 do
	begin
	if VPChar[i] <> ' ' then
		SPCharAddSimbol(Result, VPChar[i]);
	I += 1;
	end;
end;

function SPCharUpCase(const VPChar : PSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32 = 0;
begin
Result := nil;
if (VPChar <> nil) then
	begin
	I := SPCharLength(VPChar);
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

function SPCharDecFromEnd(var VPChar : PSChar; const Number : TSUInt32 = 1) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	NewVPChar : PSChar = nil;
	LengthOld : TSInt32 = 0;
	I : TSInt32 = 0;
begin
LengthOld := SPCharLength(VPChar);
GetMem(NewVPChar, LengthOld - Number + 1);
for I := 0 to LengthOld - Number-1 do
	NewVPChar[i] := VPChar[i];
NewVPChar[LengthOld - Number] := #0;
VPChar := NewVPChar;
Result := NewVPChar;
end;

function SPCharHigh(const VPChar : PSChar) : TSInt32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function SPCharsEqual(const PChar1, PChar2 : PSChar) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	I : TSInt32 = 0;
	VExit : TSBoolean = False;
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

function SPCharAddSimbol(var VPChar : PSChar; const VChar : TSChar) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	NewVPChar : PSChar = nil;
	LengthOld : TSInt32 = 0;
	I : TSInt32 = 0;
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

procedure SPCharFree(const PC : PSChar; const KillWithLenght : TSBool = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if not KillWithLenght then
	FreeMem(PC)
else
	FreeMem(PC, SPCharLength(PC) + 1);
end;

(**********)
(** CHAR **)
(**********)

function SDownCase(const C : TSChar) : TSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if c in ['A'..'Z'] then
	Result := TSChar(TSByte(C) - (TSByte('A') - TSByte('a')))
else
	Result := C;
end;

end.
