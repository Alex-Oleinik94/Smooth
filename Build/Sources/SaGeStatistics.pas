{$INCLUDE SaGe.inc}

unit SaGeStatistics;

interface

uses
	 SaGeBase
	,SaGeVersion
	,SaGeClasses
	,SaGeConsoleToolsBase
	;
type
	TSGStaticticsItemType = (SGStaticticsItemTypeNull, SGStaticticsItemTypeBool, SGStaticticsItemTypeNumeric, SGStaticticsItemTypeFloat, SGStaticticsItemTypeText);
	TSGStaticticsItem = object
			private
		FType : TSGStaticticsItemType;
		FValue : TSGFloat64;
		FValueText : TSGString;
			public
		property ItemType : TSGStaticticsItemType read FType write FType;
		property Value : TSGFloat64 read FValue write FValue;
		property Text : TSGString read FValueText write FValueText;
			public
		procedure Clear();
		end;
type
	TSGStaticticsFeature = object
			private
		FName : TSGString;
		FProperties : TSGSettings;
			public
		property Name : TSGString read FName write FName;
			public
		procedure Nominate(const NewName : TSGString);
		procedure Kill();
		end;

function SGStaticticsFeatureCreate(const TextName : TSGString) : TSGStaticticsFeature;

{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGStaticticsFeaturesHelper}
{$DEFINE DATATYPE_LIST        := TSGStaticticsFeatures}
{$DEFINE DATATYPE             := TSGStaticticsFeature}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF INC_PLACE_INTERFACE}

operator = (const A, B : TSGStaticticsFeature) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

type
		// FData[Lines = Objects][Columns = Attribute]
	TSGStaticticsData = packed array of packed array of TSGStaticticsItem;
	
	TSGStatictics = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FData : TSGStaticticsData;
		FObjects : TSGStaticticsFeatures;
		FAttributes : TSGStaticticsFeatures;
			public
		procedure Clear();
		procedure Import(const FileName : TSGString);
		end;

implementation

uses
	 SaGeConsoleTools
	,SaGeLog
	,SaGeFileUtils
	,SaGeDateTime
	,SaGeStringUtils
	,SaGeBaseUtils
	
	,StrMan
	
	,SysUtils
	;

function SGStaticticsFeatureCreate(const TextName : TSGString) : TSGStaticticsFeature;
begin
Result.Nominate(TextName);
end;

operator = (const A, B : TSGStaticticsFeature) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := A.Name = B.Name;
end;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGStaticticsFeaturesHelper}
{$DEFINE DATATYPE_LIST        := TSGStaticticsFeatures}
{$DEFINE DATATYPE             := TSGStaticticsFeature}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

procedure TSGStaticticsItem.Clear();
begin
FType := SGStaticticsItemTypeNull;
FValue := 0;
FValueText := '';
end;

operator in (const A : TSGChar; const S : TSGString) : TSGBool; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGMaxEnum;
begin
Result := False;
for i := 1 to Length(S) do
	if S[i] = A then
		begin
		Result := True;
		break;
		end;
end;

procedure TSGStatictics.Import(const FileName : TSGString);

procedure Importing(var f : TextFile);

function ReadItem() : TSGString;
var
	C : TSGChar;
	Done : TSGBool = False;
begin
Result := '';
while (not (Eoln(f) or Eof(f) or Done))  do
	begin
	Read(f, C);
	Done := C = '	';
	if not Done then
		Result += C;
	end;
Result := StringTrimAll(Result, ' ');
end;

function DetermineItem(const Value : TSGString) : TSGStaticticsItem;
var
	i : TSGMaxEnum;
	Numeric : TSGBool = True;
	Float : TSGBool = True;
	Str : TSGString = '';
begin
Result.Clear();
if (Value <> '') and (Value <> '-') then
	begin
	for i := 1 to Length(Value) do
		begin
		if not (Value[i] in '1234567890 ') then
			Numeric := False;
		if not (Value[i] in '1234567890 ,.') then
			Float := False;
		end;
	if Numeric then
		begin
		for i := 1 to Length(Value) do
			if Value[i] <> ' ' then
				Str += Value[i];
		Result.ItemType := SGStaticticsItemTypeNumeric;
		Result.Value := SGVal(Str);
		end
	else if Float then
		begin
		Result.ItemType := SGStaticticsItemTypeFloat;
		Result.Value := StrToFloat(Value);
		end
	else
		begin
		Result.ItemType := SGStaticticsItemTypeText;
		Result.Text := Value;
		end;
	end;
end;

var
	CurrentIndex, i : TSGMaxEnum;
begin
ReadItem();
while not Eoln(f) do
	FAttributes += SGStaticticsFeatureCreate(ReadItem());
ReadLn(f);
CurrentIndex := 0;
while not Eof(f) do
	begin
	FObjects += SGStaticticsFeatureCreate(ReadItem());
	SetLength(FData, CurrentIndex + 1);
	SetLength(FData[CurrentIndex], Length(FAttributes));
	for i := 0 to High(FAttributes) do
		FData[CurrentIndex][i] := DetermineItem(ReadItem());
	ReadLn(f);
	CurrentIndex += 1;
	end;
end;

var
	D1, D2 : TSGDateTime;
	f : TextFile;
begin
if not SGFileExists(FileName) then
	begin
	SGHint(['Statictics : File "', FileName, '" not exists!']);
	exit;
	end;
Clear();
SGHint(['Statictics : Importing from "', FileName, '"...']);
D1.Get();
Assign(f, FileName);
Reset(f);
Importing(f);
Close(f);
D2.Get();
SGHint(['Statictics : Importing done (', SGTextTimeBetweenDates(D1, D2), ').']);
end;

constructor TSGStatictics.Create();
begin
inherited;
FData := nil;
FObjects := nil;
FAttributes := nil;
end;

procedure TSGStaticticsFeature.Nominate(const NewName : TSGString);
begin
FName := NewName;
FProperties := nil;
end;

procedure TSGStaticticsFeature.Kill();

procedure KillProperty(var FeatureProperty : TSGOption);
begin
// TODO
end;

var
	i : TSGMaxEnum;
begin
if (FProperties <> nil) and (Length(FProperties) > 0) then
	begin
	for i := 0 to High(FProperties) do
		KillProperty(FProperties[i]);
	SetLength(FProperties, 0);
	end;
FProperties := nil;
FName := '';
end;

procedure TSGStatictics.Clear();

procedure KillStaticticsFeature(var StaticticsFeatures : TSGStaticticsFeatures);
var
	i : TSGMaxEnum;
begin
if (StaticticsFeatures <> nil) and (Length(StaticticsFeatures) > 0) then
	begin
	for i := 0 to High(StaticticsFeatures) do
		StaticticsFeatures[i].Kill();
	SetLength(StaticticsFeatures, 0);
	end;
StaticticsFeatures := nil;
end;

var
	i : TSGMaxEnum;
begin
if FData <> nil then
	begin
	if Length(FData) > 0 then
		begin
		for i := 0 to High(FData) do
			if (FData[i] <> nil) and (Length(FData[i]) > 0) then
				SetLength(FData[i], 0);
		SetLength(FData, 0);
		end;
	FData := nil;
	end;
KillStaticticsFeature(FObjects);
KillStaticticsFeature(FAttributes);
end;

destructor TSGStatictics.Destroy();
begin
Clear();
inherited;
end;

class function TSGStatictics.ClassName() : TSGString;
begin
Result := 'TSGStatictics';
end;

// ====================

procedure SGConcoleRunStatistics(const VParams : TSGConcoleCallerParams = nil);

var
	ImportFile : TSGString = '';

function ProccessImporting(const Comand : TSGString):TSGBool;
var
	Value : TSGString;
begin
Value := SGParseValueFromComand(Comand, ['i:']);
Result := Value <> '';
if Result then
	ImportFile := Value;
end;

var
	Success : TSGBool = True;
begin
with TSGConsoleCaller.Create(VParams) do
	begin
	AddComand(@ProccessImporting,      ['i:*'], 'Import');
	Success := Execute();
	Destroy();
	end;
if Success then
	begin
	with TSGStatictics.Create() do
		begin
		Import(ImportFile);
		// TODO
		Destroy();
		end;
	end
else
	SGHint('Some errors!');
end;

initialization
begin
SGGeneralConsoleCaller().AddComand(@SGConcoleRunStatistics, ['stat'], 'Statictics');
end;

end.
