{$IFDEF INC_PLACE_INTERFACE}
type
	DATATYPE_LIST = packed array of DATATYPE;

operator :=(const A : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator + (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator * (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
{$ENDIF INC_PLACE_INTERFACE}

{$IFDEF INC_PLACE_IMPLEMENTATION}
operator * (const A : DATATYPE_LIST;const B : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSGMaxEnum;
	Exists : TSGBoolean = False;
begin
Result := A;
if Result = nil then
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

operator :=(const A : DATATYPE) : DATATYPE_LIST;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SetLength(Result, 1);
Result[0] := A;
end;

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
