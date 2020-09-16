{$INCLUDE Smooth.inc}

unit SmoothLists;

interface

uses
	 SmoothBase
	;

type
	TSOptionPointer = TSPointer;
	
	TSOption = object
			public
		FName : TSString;
		FOption : TSOptionPointer;
			public
		procedure Import(const VName : TSString; const VPointer : TSOptionPointer);
		end;
operator = (const A, B : TSOption) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

type
	TSDoubleString = packed array[0..1] of TSString;
operator = (const A, B : TSDoubleString) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

{$DEFINE  INC_PLACE_INTERFACE}
{$INCLUDE SmoothCommonLists.inc}
{$UNDEF   INC_PLACE_INTERFACE}

operator in(const S : TSString; const A : TSDoubleStrings) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SDoubleString(const FirstString, SecondString : TSString) : TSDoubleString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

type
	PSStringList = ^ TSStringList;
procedure SStringListDeleteByIndex(var StringList : TSStringList; const Index : TSMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStringListLength(const StringList : TSStringList) : TSMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SAddStringToStringList(var SL : TSStringList; const S : TSString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

operator in(const S : TSString; const A : TSSettings) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const A : TSSettings; const S : TSString) : TSSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

procedure SAddStringToStringList(var SL : TSStringList; const S : TSString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
SL := SL + S;
end;

operator in(const S : TSString; const A : TSDoubleStrings) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Index : TSMaxEnum;
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

function SDoubleString(const FirstString, SecondString : TSString) : TSDoubleString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0] := FirstString;
Result[1] := SecondString;
end;

function SStringListLength(const StringList : TSStringList): TSMaxEnum;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if StringList = nil then
	Result := 0
else
	Result := Length(StringList);
end;

procedure SStringListDeleteByIndex(var StringList : TSStringList; const Index : TSMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSMaxEnum;
begin
if (Index >= 0) and (Index < SStringListLength(StringList)) then
	begin
	if Index <> SStringListLength(StringList) - 1 then
		for i := Index to SStringListLength(StringList) - 2 do
			StringList[Index] := StringList[Index + 1];
	SetLength(StringList, SStringListLength(StringList) - 1);
	end;
end;

operator - (const A : TSSettings; const S : TSString):TSSettings;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i, ii : TSMaxEnum;
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

operator in(const S : TSString; const A : TSSettings):TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	O : TSOption;
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

procedure TSOption.Import(const VName : TSString; const VPointer : TSOptionPointer);
begin
FName := VName;
FOption := VPointer;
end;

operator = (const A, B : TSDoubleString) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A[0] = B[0]) and (A[1] = B[1]);
end;

operator = (const A, B : TSOption) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (A.FName = B.FName) and (A.FOption = B.FOption);
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$INCLUDE SmoothCommonLists.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
