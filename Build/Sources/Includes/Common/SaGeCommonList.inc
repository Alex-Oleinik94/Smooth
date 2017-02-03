{$IFDEF INC_PLACE_INTERFACE}
type
	DATATYPE_LIST = packed array of DATATYPE;
{$IF    defined(DATATYPE_LIST_HELPER)}
	DATATYPE_LIST_HELPER = type helper for DATATYPE_LIST
		function Copy() : DATATYPE_LIST; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure Free(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure ZeroMemory(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure ReAllocate(const NewLength : TSGUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function Length() : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function Assigned() : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		end;
{$ENDIF defined(DATATYPE_LIST_HELPER)}
{$IFNDEF INC_WITHOUT_FORWARD}
function Len(const List : DATATYPE_LIST) : TSGUInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$IFNDEF WITHOUT_ASSIGNMENT}
operator :=(const A : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF WITHOUT_ASSIGNMENT}
operator + (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator in(const B : DATATYPE; const A : DATATYPE_LIST) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator in(const A, B : DATATYPE_LIST) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator + (A, B : DATATYPE_LIST) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (A, B : DATATYPE_LIST) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF INC_WITHOUT_FORWARD}
{$ENDIF INC_PLACE_INTERFACE}

{$IFDEF INC_PLACE_IMPLEMENTATION}
function Len(const List : DATATYPE_LIST) : TSGUInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 0;
if List <> nil then
	Result := Length(List);
end;

{$IF    defined(DATATYPE_LIST_HELPER)}
function DATATYPE_LIST_HELPER.Assigned() : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := (Self <> nil) and (Self.Length() > 0);
end;

function DATATYPE_LIST_HELPER.Length() : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := Len(Self);
end;

procedure DATATYPE_LIST_HELPER.ReAllocate(const NewLength : TSGUInt64); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SetLength(Self, NewLength);
end;

procedure DATATYPE_LIST_HELPER.ZeroMemory(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Self.Assigned() then
	fillchar(Self[0], Self.Length() * SizeOf(DATATYPE), 0);
end;

procedure DATATYPE_LIST_HELPER.Free(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Self.Assigned() then
	SetLength(Self, 0);
Self := nil;
end;

function DATATYPE_LIST_HELPER.Copy() : DATATYPE_LIST; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := nil;
if Self.Assigned() then
	begin
	SetLength(Result, Self.Length());
	Move(Self[0], Result[0], Self.Length() * SizeOf(DATATYPE));
	end;
end;
{$ENDIF defined(DATATYPE_LIST_HELPER)}

operator + (A, B : DATATYPE_LIST) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	C : DATATYPE;
begin
Result := nil;
for C in A do
	Result += C;
for C in B do
	Result += C;
if Len(A) > 0 then
	SetLength(A, 0);
if Len(B) > 0 then
	SetLength(B, 0);
end;

operator * (A, B : DATATYPE_LIST) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	C : DATATYPE;
begin
Result := nil;
for C in A do
	Result *= C;
for C in B do
	Result *= C;
if Len(A) > 0 then
	SetLength(A, 0);
if Len(B) > 0 then
	SetLength(B, 0);
end;

operator in(const A, B : DATATYPE_LIST) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	C : DATATYPE;
begin
Result := True;
for C in A do
	begin
	if not (C in B) then
		begin
		Result := False;
		break;
		end;
	end;
end;

operator in(const B : DATATYPE; const A : DATATYPE_LIST) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	C : DATATYPE;
begin
Result := False;
for C in A do
	if C = B then
		begin
		Result := True;
		break;
		end;
end;

operator * (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSGMaxEnum;
	Exists : TSGBoolean = False;
begin
Result := A;
if (Result = nil) or (Length(Result) = 0) then
	begin
	SetLength(Result, 1);
	Result[High(Result)] := B;
	end
else
	begin
	for i := 0 to High(Result) do
		if Result[i] = B then
			begin
			Exists := True;
			break;
			end;
	if not Exists then
		begin
		SetLength(Result, Length(Result) + 1);
		Result[High(Result)] := B;
		end;
	end;
end;

{$IFNDEF WITHOUT_ASSIGNMENT}
operator :=(const A : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SetLength(Result, 1);
Result[0] := A;
end;
{$ENDIF WITHOUT_ASSIGNMENT}

operator + (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := A;
if Result = nil then
	SetLength(Result, 1)
else
	SetLength(Result, Length(Result) + 1);
Result[High(Result)] := B;
end;

operator - (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i, ii : TSGMaxEnum;
begin
Result := A;
if Result <> nil then
	begin
	ii := Length(Result);
	if ii > 0 then
		begin
		i := 0;
		while (i < Length(Result)) do
			begin
			if Result[i] = B then
				begin
				if High(Result) <> i then
					begin
					for ii := i to High(Result) - 1 do
						Result[ii] := Result[ii + 1];
					end;
				SetLength(Result, Length(Result) - 1);
				end
			else
				i += 1;
			end;
		end;
	end;
end;
{$ENDIF INC_PLACE_IMPLEMENTATION}
