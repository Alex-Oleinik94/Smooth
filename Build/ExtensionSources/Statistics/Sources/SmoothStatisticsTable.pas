//DEPRECATED

{$INCLUDE Smooth.inc}

unit SmoothStatisticsTable;

interface

uses
	 SmoothBase
	,SmoothVersion
	,SmoothClasses
	
	,SmoothStatisticsStudentiz
	,SmoothStatisticsBase
	;

type
	TSStaticticsTable = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			private
		FData : TSStaticticsData;
		FObjects : TSStaticticsFeatures;
		FAttributes : TSStaticticsFeatures;
			private
		function CalculationOfAttributeType(const Index : TSMaxEnum) : TSStaticticsItemType;
			public
		procedure Clear();virtual;
		procedure Import(const FileName : TSString);
		procedure CalculationOfCorrelation();
		procedure CalculationOfTypes();
		procedure DetermineDiscreteValues(const Index : TSMaxEnum);
		procedure ExportTypesInfo(const OutputFile : TSString = '');
		procedure CorrelationExport(const FileName : TSString);
		procedure CalculateLinearRegression(const VariableIndex, RegressionVariableIndex : TSMaxEnum; var A, B :  TSFloat64);
			public
		property Data : TSStaticticsData read FData;
		property Objects : TSStaticticsFeatures read FObjects;
		property Attributes : TSStaticticsFeatures read FAttributes;
		end;

implementation

uses
	 SmoothLog
	,SmoothFileUtils
	,SmoothDateTime
	,SmoothStringUtils
	,SmoothEncodingUtils
	
	,StrMan
	
	,SysUtils
	;

procedure TSStaticticsTable.CorrelationExport(const FileName : TSString);
var
	f : TextFile;
	i, ii : TSMaxEnum;
	MaxNameLength : TSMaxEnum = 0;
	CharCount : TSMaxEnum = 0;
	Str : TSString;
begin
for i := 0 to High(FAttributes) do
	if Length(FAttributes[i].Name) > MaxNameLength then
		MaxNameLength := Length(FAttributes[i].Name);
CharCount := MaxNameLength + 2;
if CharCount < 8 then
	CharCount := 8;
Assign(f, FileName);
Rewrite(f);
Write(f, StringJustifyRight('', CharCount, ' '));
for i := 0 to High(FAttributes) do
	if not (TSStaticticsItemType(FAttributes[i].GetProperty('TYPE')) in [SStaticticsItemTypeNull, SStaticticsItemTypeText]) then
		Write(f, StringJustifyRight(FAttributes[i].Name, CharCount, ' '));
WriteLn(f);
for i := 0 to High(FAttributes) do
	if not (TSStaticticsItemType(FAttributes[i].GetProperty('TYPE')) in [SStaticticsItemTypeNull, SStaticticsItemTypeText]) then
		begin
		Write(f, StringJustifyLeft(FAttributes[i].Name, CharCount, ' '));
		for ii := 0 to High(FAttributes) do
			if not (TSStaticticsItemType(FAttributes[ii].GetProperty('TYPE')) in [SStaticticsItemTypeNull, SStaticticsItemTypeText]) then
				begin
				if FAttributes[i].ExistsProperty('CORR_' + SStr(ii)) then
					Str := SStrReal(TSFloat32(FAttributes[i].GetProperty('CORR_' + SStr(ii))), 6)
				else if FAttributes[ii].ExistsProperty('CORR_' + SStr(i)) then
					Str := SStrReal(TSFloat32(FAttributes[i].GetProperty('CORR_' + SStr(i))), 6)
				else if i = ii then
					Str := SStrReal(1.000, 6)
				else
					Str := '-';
				Str := StringJustifyRight(Str, CharCount, ' ');
				Write(f, Str);
				end;
		WriteLn(f);
		end;
Close(f);
end;

procedure TSStaticticsTable.CalculationOfCorrelation();

procedure Calculation(const Index0, Index1 : TSMaxEnum);

procedure SetCorrelationProperty(const PropertyName : TSString; const PropertyValue : TSOptionPointer);
begin
FAttributes[Index0].SetProperty(PropertyName + SStr(Index1), PropertyValue);
FAttributes[Index1].SetProperty(PropertyName + SStr(Index0), PropertyValue);
end;

var
	i : TSMaxEnum;
	Num : TSMaxEnum = 0;
	Sum_0 : TSFloat64 = 0;
	Sum_Squared_0 : TSFloat64 = 0;
	Sum_1 : TSFloat64 = 0;
	Sum_Squared_1 : TSFloat64 = 0;
	Sum_Comp : TSFloat64 = 0;
	Correlation : TSFloat64;
begin
if FAttributes[Index0].ExistsProperty('CORR_' + SStr(Index1)) then
	Exit;
for i := 0 to High(FObjects) do
	if  (FData[i][Index0].ItemType <> SStaticticsItemTypeNull)
	and (FData[i][Index1].ItemType <> SStaticticsItemTypeNull) then
		begin
		Num += 1;
		Sum_0 += FData[i][Index0].Value;
		Sum_1 += FData[i][Index1].Value;
		Sum_Squared_0 += Sqr(FData[i][Index0].Value);
		Sum_Squared_1 += Sqr(FData[i][Index1].Value);
		Sum_Comp += FData[i][Index0].Value * FData[i][Index1].Value;
		end;
Correlation := (Num * Sum_Comp - Sum_0 * Sum_1) / Sqrt((Num * Sum_Squared_0 - Sqr(Sum_0)) * (Num * Sum_Squared_1 - Sqr(Sum_1)));
FAttributes[Index0].SetProperty('CORR_SUM_'       + SStr(Index1), TSOptionPointer(TSFloat32(Sum_0)));
FAttributes[Index0].SetProperty('CORR_SQUAR_SUM_' + SStr(Index1), TSOptionPointer(TSFloat32(Sum_Squared_0)));
FAttributes[Index1].SetProperty('CORR_SUM_'       + SStr(Index0), TSOptionPointer(TSFloat32(Sum_1)));
FAttributes[Index1].SetProperty('CORR_SQUAR_SUM_' + SStr(Index0), TSOptionPointer(TSFloat32(Sum_Squared_1)));
SetCorrelationProperty('CORR_COMB_', TSOptionPointer(TSFloat32(Sum_Comp)));
SetCorrelationProperty('SUM_LEN_',   TSOptionPointer(Num));
SetCorrelationProperty('CORR_',      TSOptionPointer(TSFloat32(Correlation)));
end;

var
	D1, D2 : TSDateTime;
	i, ii : TSMaxEnum;
begin
D1.Get();
for i := 0 to High(FAttributes) do
	if not (TSStaticticsItemType(FAttributes[i].GetProperty('TYPE')) in [SStaticticsItemTypeNull, SStaticticsItemTypeText]) then
		for ii := 0 to High(FAttributes) do
			if i > ii then
				if not (TSStaticticsItemType(FAttributes[ii].GetProperty('TYPE')) in [SStaticticsItemTypeNull, SStaticticsItemTypeText]) then
					Calculation(i, ii);
D2.Get();
SHint(['Statistics : Calculation of correlation done at ', STextTimeBetweenDates(D1, D2), '.']);
end;


procedure TSStaticticsTable.CalculateLinearRegression(const VariableIndex, RegressionVariableIndex : TSMaxEnum; var A, B :  TSFloat64);
var
	SC, SQ0, S0, S1 : TSFloat64;
	N : TSMaxEnum;
begin
N   := TSMaxEnum(Attributes[VariableIndex]          .GetProperty('SUM_LEN_'        + SStr(RegressionVariableIndex)));
SC  := TSFloat32(Attributes[VariableIndex]          .GetProperty('CORR_COMB_'      + SStr(RegressionVariableIndex)));
S0  := TSFloat32(Attributes[VariableIndex]          .GetProperty('CORR_SUM_'       + SStr(RegressionVariableIndex)));
SQ0 := TSFloat32(Attributes[VariableIndex]          .GetProperty('CORR_SQUAR_SUM_' + SStr(RegressionVariableIndex)));
S1  := TSFloat32(Attributes[RegressionVariableIndex].GetProperty('CORR_SUM_'       + SStr(VariableIndex)));
A := (SC - S0 * S1 / N) / (SQ0 - Sqr(S0) / N);
B := S1 / N - S0 / N * (SC - S0 * S1 / N) / (SQ0 - - Sqr(S0) / N);
end;

procedure TSStaticticsTable.DetermineDiscreteValues(const Index : TSMaxEnum);
var
	i : TSMaxEnum;
	Values : TSStringList = nil;
	TempString : TSString;
	StringPointer : PSString;
begin
for i := 0 to High(FObjects) do
	begin
	TempString := FData[i][Index].ToString();
	if TempString = '0' then
		TempString := '';
	if TempString <> '' then
		Values *= TempString;
	end;
FAttributes[Index].SetProperty('DISC_COUNT',  TSOptionPointer(Length(Values)));
TempString := '';
for i := 0 to High(Values) do
	begin
	TempString += Values[i];
	if i <> High(Values) then
		TempString += #0;
	end;
SetLength(Values, 0);
New(StringPointer);
StringPointer^ := TempString;
FAttributes[Index].SetProperty('DISC_VALUES', TSOptionPointer(StringPointer));
StringPointer := nil;
end;

function TSStaticticsTable.CalculationOfAttributeType(const Index : TSMaxEnum) : TSStaticticsItemType;
var
	CountNull  : TSMaxEnum = 0;
	CountBool  : TSMaxEnum = 0;
	CountNumer : TSMaxEnum = 0;
	CountFloat : TSMaxEnum = 0;
	CountText  : TSMaxEnum = 0;
	i : TSMaxEnum;
begin
for i := 0 to High(FObjects) do
	case FData[i][Index].ItemType of
	SStaticticsItemTypeNull    : CountNull  += 1;
	SStaticticsItemTypeBool    : CountBool  += 1;
	SStaticticsItemTypeNumeric : CountNumer += 1;
	SStaticticsItemTypeFloat   : CountFloat += 1;
	SStaticticsItemTypeText    : CountText  += 1;
	end;
FAttributes[Index].SetProperty('COUNT_NULL', TSOptionPointer(CountNull));
FAttributes[Index].SetProperty('COUNT_BOOL', TSOptionPointer(CountBool));
FAttributes[Index].SetProperty('COUNT_NUMER', TSOptionPointer(CountNumer));
FAttributes[Index].SetProperty('COUNT_FLOAT', TSOptionPointer(CountFloat));
FAttributes[Index].SetProperty('COUNT_TEXT', TSOptionPointer(CountText));
if CountText <> 0 then
	Result := SStaticticsItemTypeText
else if CountFloat <> 0 then
	Result := SStaticticsItemTypeFloat
else if CountNumer <> 0 then
	Result := SStaticticsItemTypeNumeric
else if CountBool <> 0 then
	Result := SStaticticsItemTypeBool
else
	Result := SStaticticsItemTypeNull;
FAttributes[Index].SetProperty('TYPE', TSOptionPointer(Result));
if Result = SStaticticsItemTypeText then
	DetermineDiscreteValues(Index);
end;

procedure TSStaticticsTable.ExportTypesInfo(const OutputFile : TSString = '');
var
	f : TextFile;
	i, ii : TSMaxEnum;
	MaxNameLength : TSMaxEnum = 0;
begin
for i := 0 to High(FAttributes) do
	if Length(FAttributes[i].Name) > MaxNameLength then
		MaxNameLength := Length(FAttributes[i].Name);
Assign(f, OutputFile);
Rewrite(f);
for i := 0 to High(FAttributes) do
	begin
	Write(f, StringJustifyLeft(FAttributes[i].Name, MaxNameLength, ' ') + ' : ');
	Write(f, 'Type = ', StringJustifyRight(SStrStatItemType(TSStaticticsItemType(FAttributes[i].GetProperty('TYPE'))) + ';', 7, ' ') + ' ');
	Write(f, 'Count Null = ',  StringJustifyRight(SStr(TSMaxEnum(FAttributes[i].GetProperty('COUNT_NULL'))) + ';',  7, ' ') + ' ');
	Write(f, 'Count Bool = ',  StringJustifyRight(SStr(TSMaxEnum(FAttributes[i].GetProperty('COUNT_BOOL'))) + ';',  7, ' ') + ' ');
	Write(f, 'Count Numer = ', StringJustifyRight(SStr(TSMaxEnum(FAttributes[i].GetProperty('COUNT_NUMER'))) + ';', 7, ' ') + ' ');
	Write(f, 'Count Float = ', StringJustifyRight(SStr(TSMaxEnum(FAttributes[i].GetProperty('COUNT_FLOAT'))) + ';', 7, ' ') + ' ');
	Write(f, 'Count Text = ',  StringJustifyRight(SStr(TSMaxEnum(FAttributes[i].GetProperty('COUNT_TEXT'))) + '.',  7, ' '));
	WriteLn(f);
	end;
for i := 0 to High(FAttributes) do
	if FAttributes[i].ExistsProperty('DISC_COUNT') then
		begin
		Write(f, 'The attribute "', FAttributes[i].Name, '" is discrete and takes the values (', TSMaxEnum(FAttributes[i].GetProperty('DISC_COUNT')), ') : ');
		for ii := 0 to TSMaxEnum(FAttributes[i].GetProperty('DISC_COUNT')) - 1 do
			begin
			Write(f, StringWordGet(PSString(FAttributes[i].GetProperty('DISC_VALUES'))^, #0, ii + 1));
			if ii = TSMaxEnum(FAttributes[i].GetProperty('DISC_COUNT')) - 1 then
				WriteLn(f, '.')
			else
				Write(f, ', ');
			end;
		end;
CLose(f);
end;

procedure TSStaticticsTable.CalculationOfTypes();
var
	i : TSMaxEnum;
begin
for i := 0 to High(FAttributes) do
	CalculationOfAttributeType(i);
end;

procedure TSStaticticsTable.Import(const FileName : TSString);

procedure Importing(var f : TextFile);

function ReadItem() : TSString;
var
	C : TSChar;
	Done : TSBool = False;
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

function DetermineItem(const Value : TSString) : TSStaticticsItem;
var
	i : TSMaxEnum;
	Numeric : TSBool = True;
	Float : TSBool = True;
	Bool : TSBool = True;
	Str : TSString = '';
begin
Result.Clear();
if (Value <> '') and (Value <> '-') then
	begin
	for i := 1 to Length(Value) do
		begin
		if not (Value[i] in '10 ') then
			Bool := False;
		if not (Value[i] in '-1234567890 ') then
			Numeric := False;
		if not (Value[i] in '-1234567890 ,.') then
			Float := False;
		end;
	if Numeric or Bool then
		begin
		for i := 1 to Length(Value) do
			if Value[i] <> ' ' then
				Str += Value[i];
		if Bool then
			Result.ItemType := SStaticticsItemTypeBool
		else
			Result.ItemType := SStaticticsItemTypeNumeric;
		Result.Value := SVal(Str);
		end
	else if Float then
		begin
		Result.ItemType := SStaticticsItemTypeFloat;
		Result.Value := StrToFloat(Value);
		end
	else
		begin
		Result.ItemType := SStaticticsItemTypeText;
		Result.Text := SConvertString(Value, SEncodingWin1251);
		end;
	end;
end;

var
	CurrentIndex, i : TSMaxEnum;
begin
ReadItem();
while not Eoln(f) do
	FAttributes += SStaticticsFeatureCreate(ReadItem());
ReadLn(f);
CurrentIndex := 0;
while not Eof(f) do
	begin
	FObjects += SStaticticsFeatureCreate(ReadItem());
	SetLength(FData, CurrentIndex + 1);
	SetLength(FData[CurrentIndex], Length(FAttributes));
	for i := 0 to High(FAttributes) do
		FData[CurrentIndex][i] := DetermineItem(ReadItem());
	ReadLn(f);
	CurrentIndex += 1;
	end;
end;

var
	D1, D2 : TSDateTime;
	f : TextFile;
begin
if not SFileExists(FileName) then
	begin
	SHint(['Statictics : File "', FileName, '" not exists!']);
	exit;
	end;
Clear();
D1.Get();
Assign(f, FileName);
Reset(f);
Importing(f);
Close(f);
D2.Get();
SHint(['Statictics : Importing from "', FileName, '" done at ', STextTimeBetweenDates(D1, D2), '.']);
end;

constructor TSStaticticsTable.Create();
begin
inherited;
FData := nil;
FObjects := nil;
FAttributes := nil;
end;

procedure TSStaticticsTable.Clear();

procedure KillStaticticsFeature(var StaticticsFeatures : TSStaticticsFeatures);
var
	i : TSMaxEnum;
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
	i : TSMaxEnum;
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

destructor TSStaticticsTable.Destroy();
begin
Clear();
inherited;
end;

class function TSStaticticsTable.ClassName() : TSString;
begin
Result := 'TSStaticticsTable';
end;

end.
