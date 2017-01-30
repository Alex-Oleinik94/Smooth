{$INCLUDE SaGe.inc}

unit SaGeBaseUtils;

interface

uses
	 SaGeBased
	;

// Sort
type
	TSGQuickSortFunction = function (var a, b) : TSGBoolean;
procedure SGQuickSort(var Arr; const ArrLength, SizeOfElement : TSGUInt64; const SortFunction : TSGQuickSortFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// If
function Iff(const b : TSGBoolean; const s1 : TSGString;  const s2 : TSGString  = ''   ) : TSGString ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGBoolean; const s2 : TSGBoolean = False) : TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGPointer; const s2 : TSGPointer = nil  ) : TSGPointer;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGInt8;    const s2 : TSGInt8    = 0    ) : TSGInt8   ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGUInt8;   const s2 : TSGUInt8   = 0    ) : TSGUInt8  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGUInt16;  const s2 : TSGUInt16  = 0    ) : TSGUInt16 ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGInt16;   const s2 : TSGInt16   = 0    ) : TSGInt16  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGUInt32;  const s2 : TSGUInt32  = 0    ) : TSGUInt32 ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGInt32;   const s2 : TSGInt32   = 0    ) : TSGInt32  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGUInt64;  const s2 : TSGUInt64  = 0    ) : TSGUInt64 ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGInt64;   const s2 : TSGInt64   = 0    ) : TSGInt64  ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : PSGChar;    const s2 : PSGChar    = nil  ) : PSGChar   ;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGFloat32; const s2 : TSGFloat32 = 0    ) : TSGFloat32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function Iff(const b : TSGBoolean; const s1 : TSGFloat64; const s2 : TSGFloat64 = 0    ) : TSGFloat64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFNDEF WITHOUT_EXTENDED}
function Iff(const b : TSGBoolean; const s1 : TSGFloat80; const s2 : TSGFloat80 = 0    ) : TSGFloat80;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF WITHOUT_EXTENDED}

// Swap
procedure Swap(var x, y : TSGInt32); {$IFDEF WITHASMINC} assembler; register; {$ENDIF} overload;
procedure Swap(var a, b; const Size : TSGUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

procedure Swap(var a, b : TSGInt64  ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGUInt64 ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGUInt32 ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGInt16  ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGUInt16 ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGInt8   ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGUInt8  ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGFloat32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGFloat64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGString ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGBoolean); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : PSGChar   ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure Swap(var a, b : TSGPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IFNDEF WITHOUT_EXTENDED}
procedure Swap(var a, b : TSGFloat80); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF WITHOUT_EXTENDED}

implementation

procedure Swap(var a, b : TSGInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGInt64;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGUInt64;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGUInt32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGUInt32;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGInt16); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGInt16;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGUInt16); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGUInt16;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGInt8); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGInt8;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGUInt8); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGUInt8;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGFloat32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGFloat32;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGFloat64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGFloat64;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGString;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGBoolean); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGBoolean;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : PSGChar); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : PSGChar;
begin
c := b;
b := a;
a := c;
end;

procedure Swap(var a, b : TSGPointer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGPointer;
begin
c := b;
b := a;
a := c;
end;

{$IFNDEF WITHOUT_EXTENDED}
procedure Swap(var a, b : TSGFloat80); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var c : TSGFloat80;
begin
c := b;
b := a;
a := c;
end;
{$ENDIF WITHOUT_EXTENDED}

procedure Swap(var a, b; const Size : TSGUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Temp : TSGPointer = nil;
begin
GetMem(Temp, Size);
Move(a, Temp^, Size);
Move(b, a, Size);
Move(Temp^, b, Size);
FreeMem(Temp);
end;

procedure Swap(var x, y : TSGInt32); {$IFDEF WITHASMINC} assembler; register; {$ENDIF} overload;
{$IFDEF WITHASMINC}
	asm
	xchg [edx], ecx
	xchg [eax], ecx
	xchg [edx], ecx
	end;
{$ELSE}
	var
		z : TSGInt32;
	begin
	z := x;
	x := y;
	y := z;
	end;
	{$ENDIF}

function Iff(const b : TSGBoolean; const s1 : TSGBoolean; const s2 : TSGBoolean = False) : TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGInt8;   const s2 : TSGInt8 = 0) : TSGInt8;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGUInt8; const s2 : TSGUInt8 = 0) : TSGUInt8;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGUInt16; const s2 : TSGUInt16 = 0) : TSGUInt16;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGInt16; const s2 : TSGInt16 = 0) : TSGInt16;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGPointer; const s2 : TSGPointer = nil  ) : TSGPointer;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGUInt32; const s2 : TSGUInt32 = 0) : TSGUInt32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGInt32; const s2 : TSGInt32 = 0) : TSGInt32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGUInt64; const s2 : TSGUInt64 = 0) : TSGUInt64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGInt64; const s2 : TSGInt64 = 0) : TSGInt64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : PSGChar; const s2 : PSGChar = nil) : PSGChar;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

{$IFNDEF WITHOUT_EXTENDED}
function Iff(const b : TSGBoolean; const s1 : TSGFloat80; const s2 : TSGFloat80 = 0) : TSGFloat80;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;
{$ENDIF WITHOUT_EXTENDED}

function Iff(const b : TSGBoolean; const s1 : TSGFloat64; const s2 : TSGFloat64 = 0) : TSGFloat64;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGFloat32; const s2 : TSGFloat32 = 0) : TSGFloat32;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

function Iff(const b : TSGBoolean; const s1 : TSGString;  const s2 : TSGString = '') : TSGString;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if b then
	Result := s1
else
	Result := s2;
end;

procedure SGQuickSort(var Arr; const ArrLength, SizeOfElement : TSGUInt64;const SortFunction : TSGQuickSortFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure Sort(const L, R : TSGUInt64);
var
	i, j : TSGUInt64;
	Key, Temp : PSGByte;
begin
i := L;
j := R;
GetMem(Key, SizeOfElement);
GetMem(Temp, SizeOfElement);
Move(PSGByte(TSGMaxEnum(@Arr) + ((L + R) div 2) * SizeOfElement)^, Key^, SizeOfElement);
repeat
while SortFunction(PSGByte(TSGMaxEnum(@Arr) + i * SizeOfElement)^, Key^) do i += 1;
while SortFunction(Key^, PSGByte(TSGMaxEnum(@Arr) + j * SizeOfElement)^) do j -= 1;
if i <= j then
	begin
	Move(PSGByte(TSGMaxEnum(@Arr) + i * SizeOfElement)^, Temp^, SizeOfElement);
	Move(PSGByte(TSGMaxEnum(@Arr) + j * SizeOfElement)^,
		 PSGByte(TSGMaxEnum(@Arr) + i * SizeOfElement)^, SizeOfElement);
	Move(Temp^, PSGByte(TSGMaxEnum(@Arr) + j * SizeOfElement)^, SizeOfElement);
	i += 1;
	j -= 1;
	end;
until i > j;
FreeMem(Key);
FreeMem(Temp);
if L < j Then Sort(L, j);
if i < R Then Sort(i, R);
end;

begin
Sort(0, ArrLength - 1);
end;

end.
