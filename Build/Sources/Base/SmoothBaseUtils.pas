{$INCLUDE Smooth.inc}

unit SmoothBaseUtils;

interface

uses
	 SmoothBase
	;

// Sort
type
	TSQuickSortFunction = function (var a, b) : TSBoolean;
	TSQuickSortInt = TSInt64;
procedure SQuickSort(var Arr; const ArrLength, SizeOfElement : TSQuickSortInt; const SortFunction : TSQuickSortFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// If
function Iff(const b : TSBoolean; const s1 : TSString;  const s2 : TSString  = ''   ) : TSString ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSBoolean; const s2 : TSBoolean = False) : TSBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSPointer; const s2 : TSPointer = nil  ) : TSPointer;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSInt8;    const s2 : TSInt8    = 0    ) : TSInt8   ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSUInt8;   const s2 : TSUInt8   = 0    ) : TSUInt8  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSUInt16;  const s2 : TSUInt16  = 0    ) : TSUInt16 ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSInt16;   const s2 : TSInt16   = 0    ) : TSInt16  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSUInt32;  const s2 : TSUInt32  = 0    ) : TSUInt32 ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSInt32;   const s2 : TSInt32   = 0    ) : TSInt32  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSUInt64;  const s2 : TSUInt64  = 0    ) : TSUInt64 ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSInt64;   const s2 : TSInt64   = 0    ) : TSInt64  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : PSChar;    const s2 : PSChar    = nil  ) : PSChar   ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSFloat32; const s2 : TSFloat32 = 0    ) : TSFloat32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSBoolean; const s1 : TSFloat64; const s2 : TSFloat64 = 0    ) : TSFloat64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFNDEF WITHOUT_EXTENDED}
function Iff(const b : TSBoolean; const s1 : TSFloat80; const s2 : TSFloat80 = 0    ) : TSFloat80;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF WITHOUT_EXTENDED}

// Swap
procedure Swap(var x, y : TSInt32); {$IFDEF WITHASMINC} assembler; register; {$ENDIF} overload;
procedure Swap(var a, b; const Size : TSUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

procedure Swap(var a, b : TSInt64  ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSUInt64 ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSUInt32 ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSInt16  ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSUInt16 ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSInt8   ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSUInt8  ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSFloat32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSFloat64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSString ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSBoolean); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : PSChar   ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure Swap(var a, b : TSPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$IFNDEF WITHOUT_EXTENDED}
procedure Swap(var a, b : TSFloat80); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
{$ENDIF WITHOUT_EXTENDED}

// Max
function Max(const A, B : TSUInt32) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Modified numbers
procedure SwapBytes(var a : TSUInt16); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure ReverseBytes(var a : TSUInt32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Indexes
function SNextCircularDynamicIndex(const Index, HighOfArray : TSMaxEnum): TSMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

function Max(const A, B : TSUInt32) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (A > B) then
	Result := A
else
	Result := B;
end;

procedure ReverseBytes(var a : TSUInt32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Swap(PSUInt8(@a)[0], PSUInt8(@a)[3]);
Swap(PSUInt8(@a)[1], PSUInt8(@a)[2]);
end;

procedure SwapBytes(var a : TSUInt16); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Swap(PSUInt8(@a)[0], PSUInt8(@a)[1]);
end;

function SNextCircularDynamicIndex(const Index, HighOfArray : TSMaxEnum): TSMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Index + 1) * TSByte(Index <> HighOfArray);
end;

procedure Swap(var a, b : TSInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSInt64;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSUInt64;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSUInt32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSUInt32;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSInt16); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSInt16;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSUInt16); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSUInt16;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSInt8); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSInt8;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSUInt8); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSUInt8;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSFloat32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSFloat32;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSFloat64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSFloat64;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSString;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSBoolean); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSBoolean;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : PSChar); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : PSChar;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSPointer;
begin
c := b;
b := a;
a := c;
end;

{$IFNDEF WITHOUT_EXTENDED}
procedure Swap(var a, b : TSFloat80); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSFloat80;
begin
c := b;
b := a;
a := c;
end;
{$ENDIF WITHOUT_EXTENDED}

procedure Swap(var a, b; const Size : TSUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Temp : TSPointer = nil;
begin
GetMem(Temp, Size);
Move(a, Temp^, Size);
Move(b, a, Size);
Move(Temp^, b, Size);
FreeMem(Temp);
end;

procedure Swap(var x, y : TSInt32); {$IFDEF WITHASMINC} assembler; register; {$ENDIF} overload;
{$IFDEF WITHASMINC}
	asm
	xchg [edx], ecx
	xchg [eax], ecx
	xchg [edx], ecx
	end;
{$ELSE}
	var
		z : TSInt32;
	begin
	z := x;
	x := y;
	y := z;
	end;
	{$ENDIF}

function Iff(const b : TSBoolean; const s1 : TSBoolean; const s2 : TSBoolean = False) : TSBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSInt8;   const s2 : TSInt8 = 0) : TSInt8;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSUInt8; const s2 : TSUInt8 = 0) : TSUInt8;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSUInt16; const s2 : TSUInt16 = 0) : TSUInt16;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSInt16; const s2 : TSInt16 = 0) : TSInt16;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSPointer; const s2 : TSPointer = nil  ) : TSPointer;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSUInt32; const s2 : TSUInt32 = 0) : TSUInt32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSInt32; const s2 : TSInt32 = 0) : TSInt32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSUInt64; const s2 : TSUInt64 = 0) : TSUInt64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSInt64; const s2 : TSInt64 = 0) : TSInt64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : PSChar; const s2 : PSChar = nil) : PSChar;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

{$IFNDEF WITHOUT_EXTENDED}
function Iff(const b : TSBoolean; const s1 : TSFloat80; const s2 : TSFloat80 = 0) : TSFloat80;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;
{$ENDIF WITHOUT_EXTENDED}

function Iff(const b : TSBoolean; const s1 : TSFloat64; const s2 : TSFloat64 = 0) : TSFloat64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSFloat32; const s2 : TSFloat32 = 0) : TSFloat32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSBoolean; const s1 : TSString;  const s2 : TSString = '') : TSString;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

procedure SQuickSort(var Arr; const ArrLength, SizeOfElement : TSQuickSortInt; const SortFunction : TSQuickSortFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure Sort(const L, R : TSQuickSortInt);
var
	i, j : TSQuickSortInt;
	Key : PSByte;
begin
i := L;
j := R;
GetMem(Key, SizeOfElement);
Move(PSByte(TSMaxEnum(@Arr) + ((L + R) div 2) * SizeOfElement)^, Key^, SizeOfElement);
repeat
while SortFunction(PSByte(TSMaxEnum(@Arr) + i * SizeOfElement)^, Key^) do i += 1;
while SortFunction(Key^, PSByte(TSMaxEnum(@Arr) + j * SizeOfElement)^) do j -= 1;
if i <= j then
	begin
	Swap(PSByte(TSMaxEnum(@Arr) + i * SizeOfElement)^, PSByte(TSMaxEnum(@Arr) + j * SizeOfElement)^, SizeOfElement);
	i += 1;
	j -= 1;
	end;
until i > j;
FreeMem(Key);
if L < j Then Sort(L, j);
if i < R Then Sort(i, R);
end;

begin
Sort(0, ArrLength - 1);
end;

end.
