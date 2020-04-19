{$INCLUDE Smooth.inc}

unit SmoothConsoleHandler;

interface

uses
	 SmoothBase
	,SmoothLists
	;

const
	SConsoleErrorString = 'Parameters error. Use ';
	SConsoleHandlerHelpParams = ' --help, --h, --?';
	SConsoleHandlerUnknownCategory = '--unknown--';

type
	TSConsoleHandlerParams = TSStringList;
	TSConsoleHandlerProcedure = procedure (const VParams : TSConsoleHandlerParams = nil);
	TSConsoleHandlerNestedHelpFunction = function () : TSString is nested;
	TSConsoleHandlerNestedProcedure = function (const VParam : TSString) : TSBool is nested;
	TSConsoleHandlerComand = object
			public
		FComand             : TSConsoleHandlerProcedure;
		FNestedComand       : TSConsoleHandlerNestedProcedure;
		FNestedHelpFunction : TSConsoleHandlerNestedHelpFunction;
		FSyntax             : TSConsoleHandlerParams;
		FHelpString         : TSString;
		FCategory           : TSString;
			public
		procedure Free();
		function HelpString() : TSString;
		end;
	TSConsoleHandlerComands = packed array of TSConsoleHandlerComand;

	TSConsoleHandler = class
			public
		constructor Create(const VParams : TSConsoleHandlerParams); overload;
		constructor Create(); overload;
		destructor Destroy();override;
		procedure AddComand(const VComand       : TSConsoleHandlerProcedure;       const VSyntax : packed array of const; const VHelp : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VNestedComand : TSConsoleHandlerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VNestedComand : TSConsoleHandlerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSConsoleHandlerNestedHelpFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VCategory     : TSString; const VComand       : TSConsoleHandlerProcedure;       const VSyntax : packed array of const; const VHelp : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure CheckForLastComand();
		procedure CheckForComand(var Comand : TSConsoleHandlerComand);
		function Execute() : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Category(const VC : TSString);
		function Execute(const VParams : TSConsoleHandlerParams; const ClearParams : TSBool = False) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		FCurrentCategory : TSString;
		FParams : TSConsoleHandlerParams;
		FComands : TSConsoleHandlerComands;
			private
		function AllNested() : TSBool;
		function AllNormal() : TSBool;
			public
		property Params : TSConsoleHandlerParams write FParams;
		end;

function SConsoleHandlerParamsToPChar(const VParams : TSConsoleHandlerParams = nil; const BeginPosition : TSUInt32 = 0) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SDecConsoleParams(const Params : TSConsoleHandlerParams) : TSConsoleHandlerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SCountConsoleParams(const Params : TSConsoleHandlerParams) : TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SIsBoolConsoleParam(const Param : TSString):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SParseStringToConsoleHandlerParams(const VParams : TSString) : TSConsoleHandlerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SSystemParamsToConsoleHandlerParams() : TSConsoleHandlerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SParseValueFromComand(const Comand : TSString; const PredPart : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SParseValueFromComand(const Comand : TSString; PredParts : TSStringList; const FreeList : TSBool = True) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SParseValueFromComand(const Comand : TSString; const PredParts : array of const) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SParseValueFromComandAndReturn(const Comand : TSString; const PredParts : array of const; out OutString : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SKill(var ConsoleHandler : TSConsoleHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	(* ============ System Includes ============ *)
	 Crt
	,StrMan

	(* ============ Engine Includes ============ *)
	,SmoothResourceManager
	,SmoothVersion
	,SmoothFileOpener
	,SmoothStringUtils
	,SmoothLog
	;

procedure SKill(var ConsoleHandler : TSConsoleHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if ConsoleHandler <> nil then
	begin
	ConsoleHandler.Destroy();
	ConsoleHandler := nil;
	end;
end;

function SParseValueFromComandAndReturn(const Comand : TSString; const PredParts : array of const; out OutString : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Value : TSString;
begin
Value := SParseValueFromComand(Comand, PredParts);
Result := Value <> '';
if Result then
	OutString := Value;
end;

function SParseValueFromComand(const Comand : TSString; const PredPart : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSMaxEnum;
begin
Result := '';
if Length(Comand) > Length(PredPart) then
	begin
	for i := 1 to Length(Comand) do
		begin
		if (i >= 1) and (i <= Length(PredPart)) then
			begin
			if UpCase(Comand[i]) <> UpCase(PredPart[i]) then
				break;
			end
		else
			Result += Comand[i];
		end;
	end;
end;

function SParseValueFromComand(const Comand : TSString; const PredParts : array of const) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SParseValueFromComand(Comand, SConstArrayToStringList(PredParts), True);
end;

function SParseValueFromComand(const Comand : TSString; PredParts : TSStringList; const FreeList : TSBool = True) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PredPart : TSString;
begin
Result := '';
if PredParts.Assigned() then
	begin
	for PredPart in PredParts do
		begin
		Result := SParseValueFromComand(Comand, PredPart);
		if Result <> '' then
			break;
		end;
	PredParts.Free();
	end;
end;

function SSystemParamsToConsoleHandlerParams() : TSConsoleHandlerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSUInt32;
begin
SetLength(Result, argc - 1);
if Length(Result) > 0 then
	for i := 0 to High(Result) do
		Result[i] := SPCharToString(argv[i + 1]);
end;

function TSConsoleHandler.Execute(const VParams : TSConsoleHandlerParams; const ClearParams : TSBool = False) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FParams := VParams;
Result := Execute();
if ClearParams then
	SetLength(FParams, 0);
FParams := nil;
end;

function SParseStringToConsoleHandlerParams(const VParams : TSString) : TSConsoleHandlerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	FunctionResult : TSConsoleHandlerParams absolute Result;

function LastParamIsEmpty() : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := False;
if FunctionResult <> nil then
	Result := FunctionResult[High(FunctionResult)] = '';
end;

procedure AddParam();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if LastParamIsEmpty() then
	Exit;
SetLength(Result, SCountConsoleParams(Result) + 1);
Result[High(Result)] := '';
end;

procedure AddSimbol(const Simbol : TSChar);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Result = nil then
	AddParam();
Result[High(Result)] += Simbol;
end;

var
	i : TSUInt32;
	Quotes : TSInt32 = 0;
begin
Result := nil;
Quotes := 0;
i := 1;
while i <= Length(VParams) do
	begin
	if VParams[i] = '"' then
		if Quotes > 0 then
			Quotes -= 1
		else
			Quotes += 1
	else if VParams[i] = ' ' then
		if Quotes > 0 then
			AddSimbol(VParams[i])
		else
			AddParam()
	else
		AddSimbol(VParams[i]);
	i += 1;
	end;
end;

function SIsBoolConsoleParam(const Param : TSString):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=   (SUpCaseString(Param) = 'TRUE') or
			(SUpCaseString(Param) = 'FALSE') or
			(Param = '0') or
			(Param = '1');
end;

function SCountConsoleParams(const Params : TSConsoleHandlerParams) : TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 0;
if (Params <> nil) then
	Result := Length(Params);
end;

function SDecConsoleParams(const Params : TSConsoleHandlerParams) : TSConsoleHandlerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
begin
if (Params = nil) or (Length(Params)<=1) then
	Result := nil
else
	begin
	SetLength(Result,Length(Params)-1);
	for i := 1 to High(Params) do
		Result[i-1] := Params[i];
	end;
end;

function SConsoleHandlerParamsToPChar(const VParams : TSConsoleHandlerParams = nil; const BeginPosition : TSUInt32 = 0) : PSChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	S : TSString;
	i : TSUInt32;
begin
Result := nil;
S := '';
if VParams <> nil then
	if Length(VParams) > 0 then
		for i := BeginPosition to High(VParams) do
			S += VParams[i] + ' ';
if S <> '' then
	Result := SStringToPChar(S);
end;

procedure TSConsoleHandler.Category(const VC : TSString);
begin
FCurrentCategory := VC;
end;

constructor TSConsoleHandler.Create(); overload;
begin
Create(nil);
end;

constructor TSConsoleHandler.Create(const VParams : TSConsoleHandlerParams); overload;
begin
FParams := VParams;
FComands := nil;
FCurrentCategory := SConsoleHandlerUnknownCategory;
end;

function TSConsoleHandler.AllNested() : TSBool;
var
	i : TSLongWord;
begin
Result := False;
if FComands <> nil then
	if Length(FComands) > 0 then
		begin
		Result := True;
		for i := 0 to High(FComands) do
			if (FComands[i].FNestedComand = nil) or (FComands[i].FComand <> nil) then
				begin
				Result := False;
				break;
				end;
		end;
end;

function TSConsoleHandler.AllNormal() : TSBool;
var
	i : TSLongWord;
begin
Result := False;
if FComands <> nil then
	if Length(FComands) > 0 then
		begin
		Result := True;
		for i := 0 to High(FComands) do
			if (FComands[i].FNestedComand <> nil) or (FComands[i].FComand = nil) then
				begin
				Result := False;
				break;
				end;
		end;
end;

destructor TSConsoleHandler.Destroy();
var
	i : TSLongWord;
begin
SetLength(FParams,0);
if (FComands <> nil) and (Length(FComands)>0) then
	begin
	for i := 0 to High(FComands) do
		SetLength(FComands[i].FSyntax,0);
	SetLength(FComands,0);
	end;
inherited;
end;


function TSConsoleHandlerComand.HelpString() : TSString;
begin
Result := FHelpString;
if (Result = '') and (FNestedHelpFunction <> nil) then
	Result := FNestedHelpFunction();
end;

procedure TSConsoleHandlerComand.Free();
begin
FComand             := nil;
FNestedComand       := nil;
FNestedHelpFunction := nil;
FSyntax             := nil;
FHelpString         := '';
FCategory           := '';
end;

procedure TSConsoleHandler.CheckForLastComand();
begin
CheckForComand(FComands[High(FComands)]);
end;

procedure TSConsoleHandler.CheckForComand(var Comand : TSConsoleHandlerComand);
var
	i, iiii : TSLongWord;
	ii : TSInt32;
	iii : TSBool;
begin
with Comand do
	if (FSyntax <> nil) and (Length(FSyntax)>0) then
		begin
		// Upcaseing
		for i := 0 to High(FSyntax) do
			FSyntax[i] := SUpCaseString(FSyntax[i]);
		// Deleting dublicates of syntax for this comand
		ii := 0;
		i := 0;
		while i < Length(FSyntax) do
			begin
			ii := i - 1;
			iii := False;
			while ii > -1 do
				begin
				if FSyntax[i] = FSyntax[ii] then
					begin
					iii := True;
					break;
					end;
				ii -= 1;
				end;
			if iii then
				begin
				if ii < High(FSyntax) then
					for iiii := ii to High(FSyntax) - 1 do
						FSyntax[ii] := FSyntax[ii + 1];
				SetLength(FSyntax,Length(FSyntax) - 1);
				end
			else
				i += 1;
			end;
		// Deleting dublicates of all comands if this comand is general
		// General comand started if no comands is in params
		ii := 0;
		for i := 0 to High(FSyntax) do
			if FSyntax[i] = '' then
				begin
				ii := 1;
				break;
				end;
		if ii = 1 then
			begin
			if Length(FComands) > 1 then
				for i := 0 to High(FComands) do
					if @FComands[i] <> @Comand then
						begin
						ii := 0;
						while ii < Length(FComands[i].FSyntax) do
							if FComands[i].FSyntax[ii] = '' then
								begin
								if ii <> High(FComands[i].FSyntax) then
									for iiii := ii to High(FComands[i].FSyntax) - 1 do
										FComands[i].FSyntax[ii] := FComands[i].FSyntax[ii + 1];
								SetLength(FComands[i].FSyntax,Length(FComands[i].FSyntax) - 1);
								end
							else
								ii += 1;
						end;
			end;
		end;
end;

procedure TSConsoleHandler.AddComand(const VCategory     : TSString; const VComand       : TSConsoleHandlerProcedure;       const VSyntax : packed array of const; const VHelp : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Index, i : TSUInt32;
begin
if (FComands = nil) or (Length(FComands) = 0) then
	begin
	SetLength(FComands, 1);
	Index := 0;
	end
else
	begin
	Index := Length(FComands);
	for i := 0 to High(FComands) do
		if (FComands[i].FCategory = VCategory) then
			if (i = High(FComands)) or ((i < High(FComands)) and (FComands[i+1].FCategory <> VCategory)) then
				begin
				Index := i;
				break;
				end;
	if Index = Length(FComands) then
		begin
		SetLength(FComands, Length(FComands) + 1);
		Index := High(FComands);
		end
	else
		begin
		Index := Index + 1;
		SetLength(FComands, Length(FComands) + 1);
		if Index <> High(FComands) then
			for i := High(FComands) - 1 downto Index do
				FComands[i+1] := FComands[i];
		end;
	end;
FComands[Index].Free();
FComands[Index].FComand := VComand;
FComands[Index].FHelpString := VHelp;
FComands[Index].FCategory := VCategory;
FComands[Index].FSyntax := SConstArrayToStringList(VSyntax);
CheckForComand(FComands[Index]);
end;

procedure TSConsoleHandler.AddComand(const VComand : TSConsoleHandlerProcedure; const VSyntax : packed array of const; const VHelp : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FComand := VComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SConstArrayToStringList(VSyntax);
CheckForLastComand();
end;

procedure TSConsoleHandler.AddComand(const VNestedComand : TSConsoleHandlerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FNestedComand := VNestedComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SConstArrayToStringList(VSyntax);
CheckForLastComand();
end;

procedure TSConsoleHandler.AddComand(const VNestedComand : TSConsoleHandlerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSConsoleHandlerNestedHelpFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FNestedComand := VNestedComand;
FComands[High(FComands)].FNestedHelpFunction := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SConstArrayToStringList(VSyntax);
CheckForLastComand();
end;

function TSConsoleHandler.Execute() : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ErrorUnknownComand(const Comand : TSString);
begin
SPrintEngineVersion();
TextColor(12);
Write('Console handler: error: abstract comand "');
TextColor(15);
Write(SDownCaseString(Comand));
TextColor(12);
WriteLn('"!');
TextColor(7);
end;

procedure ErrorUnknownSimbol(const Comand : TSString);
begin
SPrintEngineVersion();
TextColor(12);
Write('Console handler : error : unknown simbol "');
TextColor(15);
Write(Comand);
TextColor(12);
Write('", use "');
TextColor(15);
Write('--help');
TextColor(12);
WriteLn('"');
TextColor(7);
end;

function OpenFileCheck() : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
begin
Result := (FParams <> nil) and (Length(FParams)>0);
if Result then
	begin
	for i := 0 to High(FParams) do
		if not SResourceFiles.FileExists(FParams[i]) then
			begin
			Result := False;
			break;
			end;
	end;
end;

function IsComandHelp(const Comand : TSString) : TSBool;
begin
Result := (Comand = 'HELP') or (Comand = 'H') or (Comand = '?');
end;

procedure ExecuteHelp();
var
	FCategoriesSpaces : packed array of
		packed record
			FCategory : TSString;
			FSpaces   : TSUInt32;
			end = nil;

function CategorySpace(const C : TSString):TSUInt32;
var
	i : TSUInt32;
begin
Result := 0;
if FCategoriesSpaces <> nil then if Length(FCategoriesSpaces) > 0 then
	for i := 0 to High(FCategoriesSpaces) do
		if FCategoriesSpaces[i].FCategory = C then
			begin
			Result := FCategoriesSpaces[i].FSpaces;
			break;
			end;
end;

procedure CalcCategorySpaces();

function LastCatecory() : TSString;
begin
if FCategoriesSpaces = nil then
	Result := SConsoleHandlerUnknownCategory
else if Length(FCategoriesSpaces) = 0 then
	Result := SConsoleHandlerUnknownCategory
else
	Result := FCategoriesSpaces[High(FCategoriesSpaces)].FCategory;
end;

function ComandSpace(const i : TSLongWord) : TSLongWord;
var
	ii : TSUInt32;
begin
Result := 0;
for ii := 0 to High(FComands[i].FSyntax) do
	if FComands[i].FSyntax[ii] <> '' then
		begin
		if ii <> 0 then
			Result += 1;
		Result += 3 + Length(FComands[i].FSyntax[ii]);
		end;
if FComands[i].FCategory = SConsoleHandlerUnknownCategory then
	if Result < Length(SConsoleHandlerHelpParams) then
		Result := Length(SConsoleHandlerHelpParams);
end;

procedure AddNewCatSpase(const C : TSString; const S : TSUInt32);
begin
if FCategoriesSpaces = nil then
	SetLength(FCategoriesSpaces, 1)
else
	SetLength(FCategoriesSpaces, Length(FCategoriesSpaces) + 1);
FCategoriesSpaces[High(FCategoriesSpaces)].FCategory := C;
FCategoriesSpaces[High(FCategoriesSpaces)].FSpaces   := S;
end;

var
	i, ii : TSLongWord;
begin
if FComands <> nil then if Length(FComands) > 0 then
	for i := 0 to High(FComands) do
		begin
		if (LastCatecory() <> FComands[i].FCategory) or (FCategoriesSpaces = nil) or (Length(FCategoriesSpaces) = 0) then
			AddNewCatSpase(FComands[i].FCategory, ComandSpace(i))
		else
			begin
			ii := ComandSpace(i);
			if ii > FCategoriesSpaces[High(FCategoriesSpaces)].FSpaces then
				FCategoriesSpaces[High(FCategoriesSpaces)].FSpaces := ii;
			end;
		end;
end;

function IsDefParam(const i : TSLongWord):TSBoolean;
var
	ii : TSUInt32;
begin
Result := False;
if FComands[i].FSyntax <> nil then
	if Length(FComands[i].FSyntax) <> 0 then
		for ii := 0 to High(FComands[i].FSyntax) do
			if FComands[i].FSyntax[ii] = '' then
				begin
				Result := True;
				break;
				end;
end;

const
	CategoryColor = 15;
	StandartColor = 7;
	DefParamColor = 11;
	CommaColor = 14;
var
	i, ii, iii : TSLongWord;
	LCat : TSString;
	dp : TSBool;
begin
if (FComands <> nil) and (Length(FComands)>0) then
	begin
	SPrintEngineVersion();
	TextColor(CategoryColor);
	Write('Help');
	TextColor(StandartColor);
	WriteLn(':');
	WriteLn(SConsoleHandlerHelpParams, ' - Shows this');
	CalcCategorySpaces();
	LCat := SConsoleHandlerUnknownCategory;
	for i := 0 to High(FComands) do
		begin
		if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
			begin
			if LCat <> FComands[i].FCategory then
				begin
				LCat := FComands[i].FCategory;
				TextColor(CategoryColor);
				Write(LCat);
				TextColor(CommaColor);
				WriteLn(':');
				TextColor(StandartColor);
				end;
			dp := IsDefParam(i);
			if DP then
				TextColor(DefParamColor);
			iii := 0;
			for ii := 0 to High(FComands[i].FSyntax) do
				if FComands[i].FSyntax[ii] <> '' then
					begin
					if ii <> 0 then
						begin
						TextColor(CommaColor);
						Write(',');
						iii += 1;
						if DP then
							TextColor(DefParamColor)
						else
							TextColor(StandartColor);
						end;
					Write(' --',SDownCaseString(FComands[i].FSyntax[ii]));
					iii += 3 + Length(FComands[i].FSyntax[ii]);
					end;
			ii := CategorySpace(FComands[i].FCategory);
			while iii < ii do
				begin
				Write(' ');
				iii += 1;
				end;
			if FComands[i].FNestedHelpFunction <> nil then
				FComands[i].FHelpString := FComands[i].FNestedHelpFunction();
			WriteLn(' - ',FComands[i].FHelpString);
			TextColor(StandartColor);
			end;
		end;
	SetLength(FCategoriesSpaces, 0);
	end;
end;

procedure ExecuteNormal();

function ComandCheck():TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	TempString : TSString;
begin
Result := '';
if (FParams <> nil) and (Length(FParams)>0) then
	begin
	TempString := StringTrimLeft(FParams[0],'-');
	if Length(TempString) <> Length(FParams[0]) then
		begin
		Result := SUpCaseString(TempString);
		end
	else
		begin
		ErrorUnknownSimbol(FParams[0]);
		end;
	end;
end;

var
	i, ii, iii : TSLongWord;
	Comand : TSString;
	Params : TSConsoleHandlerParams;
begin
Comand := ComandCheck();
if IsComandHelp(Comand) then
	begin
	ExecuteHelp();
	end
else if Comand <> '' then
	begin
	iii := 0;
	if (FComands <> nil) and (Length(FComands)>0) then
		begin
		for i := 0 to High(FComands) do
			begin
			iii := 0;
			if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
				begin
				for ii := 0 to High(FComands[i].FSyntax) do
					if FComands[i].FSyntax[ii] = Comand then
						begin
						iii := 1;
						break;
						end;
				end;
			if iii = 1 then
				begin
				if FComands[i].FComand = nil then
					begin
					ErrorUnknownComand(Comand);
					iii := 0;
					end
				else
					begin
					Params := SDecConsoleParams(FParams);
					TSLog.Source(['Console handler: Enter "', FComands[i].HelpString(), '".']);
					FComands[i].FComand(Params);
					SetLength(Params,0);
					break;
					end;
				end;
			end;
		end;
	if iii = 0 then
		begin
		ErrorUnknownComand(Comand);
		end;
	end
else if (Comand = '') and (SCountConsoleParams(FParams) = 0) then
	begin
	iii := 0;
	if (FComands <> nil) and (Length(FComands)>0) then
		begin
		for i := 0 to High(FComands) do
			begin
			iii := 0;
			if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
				begin
				for ii := 0 to High(FComands[i].FSyntax) do
					if FComands[i].FSyntax[ii] = '' then
						begin
						iii := 1;
						break;
						end;
				if (iii = 1) then
					begin
					TSLog.Source(['Console handler: Enter "', FComands[i].HelpString(), '".']);
					FComands[i].FComand();
					break;
					end;
				end;
			end;
		if iii <> 1 then
			begin
			SPrintEngineVersion();
			TextColor(12);
			Write('Console handler: error: command not entered.');
			TextColor(7);
			end;
		end;
	end
else
	begin
	SPrintEngineVersion();
	TextColor(12);
	Write('Console handler: Unknown error!');
	TextColor(7);
	end;
end;

function ExecuteNested() : TSBool;

function TestComand(const Comand : TSString):TSBool;
var
	ii, iii : TSLongWord;
begin
Result := False;
for ii := 0 to High(FComands) do
	begin
	for iii := 0 to High(FComands[ii].FSyntax) do
		begin
		if StringMatching(Comand, FComands[ii].FSyntax[iii]) then
			begin
			Result := True;
			break;
			end;
		end;
	if Result then
		break;
	end;
end;

var
	Comand : TSString;
	i, hi, e, ii, iii : TSLongWord;
begin
Result := False;
if (FParams <> nil) and (Length(FParams) > 0) then
	begin
	hi := Length(FParams);
	e := 0;
	for i := 0 to High(FParams) do
		begin
		Comand := StringTrimLeft(FParams[i],'-');
		if Length(Comand) <> Length(FParams[i]) then
			begin
			Comand := SUpCaseString(Comand);
			if IsComandHelp(Comand) then
				hi := i
			else if not TestComand(Comand) then
				begin
				ErrorUnknownComand(Comand);
				e += 1;
				end
			end
		else
			begin
			e += 1;
			ErrorUnknownSimbol(Comand);
			end;
		end;
	if e <> 0 then
		begin
		SPrintEngineVersion();
		TextColor(12);
		WriteLn('Console handler: fatal: total ', e ,' errors.');
		TextColor(7);
		end;
	if hi <> Length(FParams) then
		begin
		ExecuteHelp();
		end
	else if e = 0 then
		begin
		for i := 0 to High(FParams) do
			begin
			Comand := StringTrimLeft(FParams[i],'-');
			Comand := SUpCaseString(Comand);
			hi := Length(FComands);
			for ii := 0 to High(FComands) do
				begin
				for iii := 0 to High(FComands[ii].FSyntax) do
					begin
					if StringMatching(Comand, FComands[ii].FSyntax[iii]) then
						begin
						hi := ii;
						break;
						end;
					end;
				if hi <> Length(FComands) then
					break;
				end;
			if hi = Length(FComands) then
				begin
				ErrorUnknownComand(Comand);
				e += 1;
				end
			else
				begin
				if not FComands[hi].FNestedComand(StringTrimLeft(FParams[i],'-')) then
					begin
					SPrintEngineVersion();
					TextColor(12);
					Write('Console handler: error: error while executing comand "');
					TextColor(15);
					Write(StringTrimLeft(FParams[i],'-'));
					TextColor(12);
					Write('", use "');
					TextColor(15);
					Write('--help');
					TextColor(12);
					WriteLn('"');
					TextColor(7);
					e += 1;
					end;
				end;
			end;
		Result := e = 0;
		if not Result then
			begin
			SPrintEngineVersion();
			TextColor(12);
			WriteLn('Console handler: fatal: total ', e, ' errors.');
			TextColor(7);
			end;
		end;
	end;
end;

begin
Result := True;
if OpenFileCheck() then
	begin
	SPrintEngineVersion();
	STryOpenFiles(FParams);
	end
else if AllNormal() then
	begin
	ExecuteNormal();
	end
else if AllNested() then
	Result := ExecuteNested()
else
	begin
	SPrintEngineVersion();
	TextColor(12);
	Write('Console handler: error: unknown configuration.');
	TextColor(7);
	Result := False;
	end;
end;

procedure SPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSConsoleHandlerParams;
	i : TSLongWord;
begin
Params := SSystemParamsToConsoleHandlerParams();
if Params <> nil then
	if Length(Params) <> 0 then
		begin
		for i := 0 to High(Params) do
			begin
			WriteLn(i+1,' - "',Params[i],'"');
			end;
		end;
end;

initialization
begin

end;

finalization
begin

end;

end.
