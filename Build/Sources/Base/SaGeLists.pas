{$INCLUDE SaGe.inc}

unit SaGeLists;

interface

uses
	 SaGeBase
	;

type
	TSGOptionPointer = TSGPointer;
	
	TSGOption = object
			public
		FName : TSGString;
		FOption : TSGOptionPointer;
			public
		procedure Import(const VName : TSGString; const VPointer : TSGOptionPointer);
		end;

operator = (const A, B : TSGOption) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

type
	TSGDoubleString = packed array[0..1] of TSGString;

operator = (const A, B : TSGDoubleString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$DEFINE  INC_PLACE_INTERFACE}
{$INCLUDE SaGeCommonLists.inc}
{$UNDEF   INC_PLACE_INTERFACE}

operator in(const S : TSGString; const A : TSGDoubleStrings) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGDoubleString(const FirstString, SecondString : TSGString) : TSGDoubleString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

type
	PSGStringList = ^ TSGStringList;
procedure SGStringListDeleteByIndex(var StringList : TSGStringList; const Index : TSGMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringListLength(const StringList : TSGStringList) : TSGMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator in(const S : TSGString; const A : TSGSettings) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : TSGSettings; const S : TSGString) : TSGSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

operator in(const S : TSGString; const A : TSGDoubleStrings) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Index : TSGMaxEnum;
begin
Result := '';
if (A <> nil) and (Length(A) > 0) then
	for Index := 0 to High(A) do
		if A[Index][0] = S then
			begin
			Result := A[Index][1];
			break;
			end;
end;

function SGDoubleString(const FirstString, SecondString : TSGString) : TSGDoubleString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0] := FirstString;
Result[1] := SecondString;
end;

function SGStringListLength(const StringList : TSGStringList): TSGMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if StringList = nil then
	Result := 0
else
	Result := Length(StringList);
end;

procedure SGStringListDeleteByIndex(var StringList : TSGStringList; const Index : TSGMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGMaxEnum;
begin
if (Index >= 0) and (Index < SGStringListLength(StringList)) then
	begin
	if Index <> SGStringListLength(StringList) - 1 then
		for i := Index to SGStringListLength(StringList) - 2 do
			StringList[Index] := StringList[Index + 1];
	SetLength(StringList, SGStringListLength(StringList) - 1);
	end;
end;

operator - (const A : TSGSettings; const S : TSGString):TSGSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
			if Result[i].FName = S then
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

operator in(const S : TSGString; const A : TSGSettings):TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	O : TSGOption;
begin
Result := False;
for O in A do
	begin
	if O.FName = S then
		begin
		Result := True;
		break;
		end;
	end;
end;

procedure TSGOption.Import(const VName : TSGString; const VPointer : TSGOptionPointer);
begin
FName := VName;
FOption := VPointer;
end;

operator = (const A, B : TSGDoubleString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A[0] = B[0]) and (A[1] = B[1]);
end;

operator = (const A, B : TSGOption) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A.FName = B.FName) and (A.FOption = B.FOption);
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$INCLUDE SaGeCommonLists.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
