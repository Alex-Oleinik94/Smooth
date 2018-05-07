{$INCLUDE SaGe.inc}

unit SaGeConsoleToolsBase;

interface

uses
	 SaGeBase
	;

const
	SGConsoleErrorString = 'Error of parameters, use ';
	SGConcoleCallerHelpParams = ' --help, --h, --?';
	SGConcoleCallerUnknownCategory = '--unknown--';

type
	TSGConcoleCallerParams = TSGStringList;
	TSGConcoleCallerProcedure = procedure (const VParams : TSGConcoleCallerParams = nil);
	TSGConcoleCallerNestedHelpFunction = function () : TSGString is nested;
	TSGConcoleCallerNestedProcedure = function (const VParam : TSGString) : TSGBool is nested;
	TSGConsoleCallerComand = object
			public
		FComand             : TSGConcoleCallerProcedure;
		FNestedComand       : TSGConcoleCallerNestedProcedure;
		FNestedHelpFunction : TSGConcoleCallerNestedHelpFunction;
		FSyntax             : TSGConcoleCallerParams;
		FHelpString         : TSGString;
		FCategory           : TSGString;
			public
		procedure Free();
		end;
	TSGConsoleCallerComands = packed array of TSGConsoleCallerComand;

	TSGConsoleCaller = class
			public
		constructor Create(const VParams : TSGConcoleCallerParams); overload;
		constructor Create(); overload;
		destructor Destroy();override;
		procedure AddComand(const VComand       : TSGConcoleCallerProcedure;       const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGConcoleCallerNestedHelpFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VCategory     : TSGString; const VComand       : TSGConcoleCallerProcedure;       const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure CheckForLastComand();
		procedure CheckForComand(var Comand : TSGConsoleCallerComand);
		function Execute() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Category(const VC : TSGString);
		function Execute(const VParams : TSGConcoleCallerParams; const ClearParams : TSGBool = False) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		FCurrentCategory : TSGString;
		FParams : TSGConcoleCallerParams;
		FComands : TSGConsoleCallerComands;
			private
		function AllNested() : TSGBool;
		function AllNormal() : TSGBool;
			public
		property Params : TSGConcoleCallerParams write FParams;
		end;

function SGConsoleCallerParamsToPChar(const VParams : TSGConcoleCallerParams = nil; const BeginPosition : TSGUInt32 = 0) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDecConsoleParams(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGCountConsoleParams(const Params : TSGConcoleCallerParams) : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsBoolConsoleParam(const Param : TSGString):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGParseStringToConsoleCallerParams(const VParams : TSGString) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGSystemParamsToConcoleCallerParams() : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGParseValueFromComand(const Comand : TSGString; const PredPart : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGParseValueFromComand(const Comand : TSGString; PredParts : TSGStringList; const FreeList : TSGBool = True) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGParseValueFromComand(const Comand : TSGString; const PredParts : array of const) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGParseValueFromComandAndReturn(const Comand : TSGString; const PredParts : array of const; out OutString : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGKill(var ConsoleCaller : TSGConsoleCaller); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	(* ============ System Includes ============ *)
	 Crt
	,StrMan

	(* ============ Engine Includes ============ *)
	,SaGeResourceManager
	,SaGeVersion
	,SaGeFileOpener
	,SaGeStringUtils
	;

procedure SGKill(var ConsoleCaller : TSGConsoleCaller); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if ConsoleCaller <> nil then
	begin
	ConsoleCaller.Destroy();
	ConsoleCaller := nil;
	end;
end;

function SGParseValueFromComandAndReturn(const Comand : TSGString; const PredParts : array of const; out OutString : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Value : TSGString;
begin
Value := SGParseValueFromComand(Comand, PredParts);
Result := Value <> '';
if Result then
	OutString := Value;
end;

function SGParseValueFromComand(const Comand : TSGString; const PredPart : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSGMaxEnum;
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

function SGParseValueFromComand(const Comand : TSGString; const PredParts : array of const) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGParseValueFromComand(Comand, SGConstArrayToStringList(PredParts), True);
end;

function SGParseValueFromComand(const Comand : TSGString; PredParts : TSGStringList; const FreeList : TSGBool = True) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PredPart : TSGString;
begin
Result := '';
if PredParts.Assigned() then
	begin
	for PredPart in PredParts do
		begin
		Result := SGParseValueFromComand(Comand, PredPart);
		if Result <> '' then
			break;
		end;
	PredParts.Free();
	end;
end;

function SGSystemParamsToConcoleCallerParams() : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
SetLength(Result, argc - 1);
if Length(Result) > 0 then
	for i := 0 to High(Result) do
		Result[i] := SGPCharToString(argv[i + 1]);
end;

function TSGConsoleCaller.Execute(const VParams : TSGConcoleCallerParams; const ClearParams : TSGBool = False) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FParams := VParams;
Result := Execute();
if ClearParams then
	SetLength(FParams, 0);
FParams := nil;
end;

function SGParseStringToConsoleCallerParams(const VParams : TSGString) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	FunctionResult : TSGConcoleCallerParams absolute Result;

function LastParamIsEmpty() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := False;
if FunctionResult <> nil then
	Result := FunctionResult[High(FunctionResult)] = '';
end;

procedure AddParam();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if LastParamIsEmpty() then
	Exit;
SetLength(Result, SGCountConsoleParams(Result) + 1);
Result[High(Result)] := '';
end;

procedure AddSimbol(const Simbol : TSGChar);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Result = nil then
	AddParam();
Result[High(Result)] += Simbol;
end;

var
	i : TSGUInt32;
	Quotes : TSGInt32 = 0;
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

function SGIsBoolConsoleParam(const Param : TSGString):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=   (SGUpCaseString(Param) = 'TRUE') or
			(SGUpCaseString(Param) = 'FALSE') or
			(Param = '0') or
			(Param = '1');
end;

function SGCountConsoleParams(const Params : TSGConcoleCallerParams) : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 0;
if (Params <> nil) then
	Result := Length(Params);
end;

function SGDecConsoleParams(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
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

function SGConsoleCallerParamsToPChar(const VParams : TSGConcoleCallerParams = nil; const BeginPosition : TSGUInt32 = 0) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	S : TSGString;
	i : TSGUInt32;
begin
Result := nil;
S := '';
if VParams <> nil then
	if Length(VParams) > 0 then
		for i := BeginPosition to High(VParams) do
			S += VParams[i] + ' ';
if S <> '' then
	Result := SGStringToPChar(S);
end;

procedure TSGConsoleCaller.Category(const VC : TSGString);
begin
FCurrentCategory := VC;
end;

constructor TSGConsoleCaller.Create(); overload;
begin
Create(nil);
end;

constructor TSGConsoleCaller.Create(const VParams : TSGConcoleCallerParams); overload;
begin
FParams := VParams;
FComands := nil;
FCurrentCategory := SGConcoleCallerUnknownCategory;
end;

function TSGConsoleCaller.AllNested() : TSGBool;
var
	i : TSGLongWord;
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

function TSGConsoleCaller.AllNormal() : TSGBool;
var
	i : TSGLongWord;
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

destructor TSGConsoleCaller.Destroy();
var
	i : TSGLongWord;
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

procedure TSGConsoleCallerComand.Free();
begin
FComand             := nil;
FNestedComand       := nil;
FNestedHelpFunction := nil;
FSyntax             := nil;
FHelpString         := '';
FCategory           := '';
end;

procedure TSGConsoleCaller.CheckForLastComand();
begin
CheckForComand(FComands[High(FComands)]);
end;

procedure TSGConsoleCaller.CheckForComand(var Comand : TSGConsoleCallerComand);
var
	i, iiii : TSGLongWord;
	ii : TSGInt32;
	iii : TSGBool;
begin
with Comand do
	if (FSyntax <> nil) and (Length(FSyntax)>0) then
		begin
		// Upcaseing
		for i := 0 to High(FSyntax) do
			FSyntax[i] := SGUpCaseString(FSyntax[i]);
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

procedure TSGConsoleCaller.AddComand(const VCategory     : TSGString; const VComand       : TSGConcoleCallerProcedure;       const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Index, i : TSGUInt32;
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
FComands[Index].FSyntax := SGConstArrayToStringList(VSyntax);
CheckForComand(FComands[Index]);
end;

procedure TSGConsoleCaller.AddComand(const VComand : TSGConcoleCallerProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FComand := VComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SGConstArrayToStringList(VSyntax);
CheckForLastComand();
end;

procedure TSGConsoleCaller.AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FNestedComand := VNestedComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SGConstArrayToStringList(VSyntax);
CheckForLastComand();
end;

procedure TSGConsoleCaller.AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGConcoleCallerNestedHelpFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FNestedComand := VNestedComand;
FComands[High(FComands)].FNestedHelpFunction := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SGConstArrayToStringList(VSyntax);
CheckForLastComand();
end;

function TSGConsoleCaller.Execute() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ErrorUnknownComand(const Comand : TSGString);
begin
SGPrintEngineVersion();
TextColor(12);
Write('Console caller : error : abstract comand "');
TextColor(15);
Write(SGDownCaseString(Comand));
TextColor(12);
WriteLn('"!');
TextColor(7);
end;

procedure ErrorUnknownSimbol(const Comand : TSGString);
begin
SGPrintEngineVersion();
TextColor(12);
Write('Console caller : error : unknown simbol "');
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

function OpenFileCheck() : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := (FParams <> nil) and (Length(FParams)>0);
if Result then
	begin
	for i := 0 to High(FParams) do
		if not SGResourceFiles.FileExists(FParams[i]) then
			begin
			Result := False;
			break;
			end;
	end;
end;

function IsComandHelp(const Comand : TSGString) : TSGBool;
begin
Result := (Comand = 'HELP') or (Comand = 'H') or (Comand = '?');
end;

procedure ExecuteHelp();
var
	FCategoriesSpaces : packed array of
		packed record
			FCategory : TSGString;
			FSpaces   : TSGUInt32;
			end = nil;

function CategorySpace(const C : TSGString):TSGUInt32;
var
	i : TSGUInt32;
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

function LastCatecory() : TSGString;
begin
if FCategoriesSpaces = nil then
	Result := SGConcoleCallerUnknownCategory
else if Length(FCategoriesSpaces) = 0 then
	Result := SGConcoleCallerUnknownCategory
else
	Result := FCategoriesSpaces[High(FCategoriesSpaces)].FCategory;
end;

function ComandSpace(const i : TSGLongWord) : TSGLongWord;
var
	ii : TSGUInt32;
begin
Result := 0;
for ii := 0 to High(FComands[i].FSyntax) do
	if FComands[i].FSyntax[ii] <> '' then
		begin
		if ii <> 0 then
			Result += 1;
		Result += 3 + Length(FComands[i].FSyntax[ii]);
		end;
if FComands[i].FCategory = SGConcoleCallerUnknownCategory then
	if Result < Length(SGConcoleCallerHelpParams) then
		Result := Length(SGConcoleCallerHelpParams);
end;

procedure AddNewCatSpase(const C : TSGString; const S : TSGUInt32);
begin
if FCategoriesSpaces = nil then
	SetLength(FCategoriesSpaces, 1)
else
	SetLength(FCategoriesSpaces, Length(FCategoriesSpaces) + 1);
FCategoriesSpaces[High(FCategoriesSpaces)].FCategory := C;
FCategoriesSpaces[High(FCategoriesSpaces)].FSpaces   := S;
end;

var
	i, ii : TSGLongWord;
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

function IsDefParam(const i : TSGLongWord):TSGBoolean;
var
	ii : TSGUInt32;
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
	i, ii, iii : TSGLongWord;
	LCat : TSGString;
	dp : TSGBool;
begin
if (FComands <> nil) and (Length(FComands)>0) then
	begin
	SGPrintEngineVersion();
	TextColor(CategoryColor);
	Write('Help');
	TextColor(StandartColor);
	WriteLn(':');
	WriteLn(SGConcoleCallerHelpParams, ' - Shows this');
	CalcCategorySpaces();
	LCat := SGConcoleCallerUnknownCategory;
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
					Write(' --',SGDownCaseString(FComands[i].FSyntax[ii]));
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

function ComandCheck():TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	TempString : TSGString;
begin
Result := '';
if (FParams <> nil) and (Length(FParams)>0) then
	begin
	TempString := StringTrimLeft(FParams[0],'-');
	if Length(TempString) <> Length(FParams[0]) then
		begin
		Result := SGUpCaseString(TempString);
		end
	else
		begin
		ErrorUnknownSimbol(FParams[0]);
		end;
	end;
end;

var
	i, ii, iii : TSGLongWord;
	Comand : TSGString;
	Params : TSGConcoleCallerParams;
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
					Params := SGDecConsoleParams(FParams);
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
else if (Comand = '') and (SGCountConsoleParams(FParams) = 0) then
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
					FComands[i].FComand();
					break;
					end;
				end;
			end;
		if iii <> 1 then
			begin
			SGPrintEngineVersion();
			TextColor(12);
			Write('Console caller : error : You must enter the comand!');
			TextColor(7);
			end;
		end;
	end
else
	begin
	SGPrintEngineVersion();
	TextColor(12);
	Write('Console caller : Unknown error!');
	TextColor(7);
	end;
end;

function ExecuteNested() : TSGBool;

function TestComand(const Comand : TSGString):TSGBool;
var
	ii, iii : TSGLongWord;
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
	Comand : TSGString;
	i, hi, e, ii, iii : TSGLongWord;
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
			Comand := SGUpCaseString(Comand);
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
		SGPrintEngineVersion();
		TextColor(12);
		WriteLn('Console caller : fatal : total ',e,' errors!');
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
			Comand := SGUpCaseString(Comand);
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
					SGPrintEngineVersion();
					TextColor(12);
					Write('Console caller : error : error while executing comand "');
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
			SGPrintEngineVersion();
			TextColor(12);
			WriteLn('Console caller : fatal : total ',e,' errors!');
			TextColor(7);
			end;
		end;
	end;
end;

begin
Result := True;
if OpenFileCheck() then
	begin
	SGPrintEngineVersion();
	SGTryOpenFiles(FParams);
	end
else if AllNormal() then
	begin
	ExecuteNormal();
	end
else if AllNested() then
	Result := ExecuteNested()
else
	begin
	SGPrintEngineVersion();
	TextColor(12);
	Write('Console caller : error : unknown configuration!');
	TextColor(7);
	Result := False;
	end;
end;

procedure SGPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSGConcoleCallerParams;
	i : TSGLongWord;
begin
Params := SGSystemParamsToConcoleCallerParams();
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
