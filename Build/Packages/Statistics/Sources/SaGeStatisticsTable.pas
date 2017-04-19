{$INCLUDE SaGe.inc}

unit SaGeStatisticsTable;

interface

uses
	 SaGeBase
	,SaGeVersion
	,SaGeClasses
	
	,SaGeStatisticsStudentiz
	,SaGeStatisticsBase
	;

type
	TSGStaticticsTable = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FData : TSGStaticticsData;
		FObjects : TSGStaticticsFeatures;
		FAttributes : TSGStaticticsFeatures;
			private
		function CalculationOfAttributeType(const Index : TSGMaxEnum) : TSGStaticticsItemType;
			public
		procedure Clear();virtual;
		procedure Import(const FileName : TSGString);
		procedure CalculationOfCorrelation();
		procedure CalculationOfTypes();
		procedure DetermineDiscreteValues(const Index : TSGMaxEnum);
		procedure ExportTypesInfo(const OutputFile : TSGString = '');
		procedure CorrelationExport(const FileName : TSGString);
			public
		property Data : TSGStaticticsData read FData;
		property Objects : TSGStaticticsFeatures read FObjects;
		property Attributes : TSGStaticticsFeatures read FAttributes;
		end;

implementation

uses
	 SaGeLog
	,SaGeFileUtils
	,SaGeDateTime
	,SaGeStringUtils
	,SaGeEncodingUtils
	
	,StrMan
	
	,SysUtils
	;

procedure TSGStaticticsTable.CorrelationExport(const FileName : TSGString);
var
	f : TextFile;
	i, ii : TSGMaxEnum;
	MaxNameLength : TSGMaxEnum = 0;
	CharCount : TSGMaxEnum = 0;
	Str : TSGString;
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
	if not (TSGStaticticsItemType(FAttributes[i].GetProperty('TYPE')) in [SGStaticticsItemTypeNull, SGStaticticsItemTypeText]) then
		Write(f, StringJustifyRight(FAttributes[i].Name, CharCount, ' '));
WriteLn(f);
for i := 0 to High(FAttributes) do
	if not (TSGStaticticsItemType(FAttributes[i].GetProperty('TYPE')) in [SGStaticticsItemTypeNull, SGStaticticsItemTypeText]) then
		begin
		Write(f, StringJustifyLeft(FAttributes[i].Name, CharCount, ' '));
		for ii := 0 to High(FAttributes) do
			if not (TSGStaticticsItemType(FAttributes[ii].GetProperty('TYPE')) in [SGStaticticsItemTypeNull, SGStaticticsItemTypeText]) then
				begin
				if FAttributes[i].ExistsProperty('CORR_' + SGStr(ii)) then
					Str := SGStrReal(TSGFloat32(FAttributes[i].GetProperty('CORR_' + SGStr(ii))), 6)
				else if FAttributes[ii].ExistsProperty('CORR_' + SGStr(i)) then
					Str := SGStrReal(TSGFloat32(FAttributes[i].GetProperty('CORR_' + SGStr(i))), 6)
				else if i = ii then
					Str := SGStrReal(1.000, 6)
				else
					Str := '-';
				Str := StringJustifyRight(Str, CharCount, ' ');
				Write(f, Str);
				end;
		WriteLn(f);
		end;
Close(f);
end;

procedure TSGStaticticsTable.CalculationOfCorrelation();

procedure Calculation(const Index0, Index1 : TSGMaxEnum);
var
	i : TSGMaxEnum;
	Num : TSGMaxEnum = 0;
	Sum_0 : TSGFloat64 = 0;
	Sum_Squared_0 : TSGFloat64 = 0;
	Sum_1 : TSGFloat64 = 0;
	Sum_Squared_1 : TSGFloat64 = 0;
	Sum_Comp : TSGFloat64 = 0;
	Correlation : TSGFloat64;
begin
if FAttributes[Index0].ExistsProperty('CORR_' + SGStr(Index1)) then
	Exit;
for i := 0 to High(FObjects) do
	if  (FData[i][Index0].ItemType <> SGStaticticsItemTypeNull)
	and (FData[i][Index1].ItemType <> SGStaticticsItemTypeNull) then
		begin
		Num += 1;
		Sum_0 += FData[i][Index0].Value;
		Sum_1 += FData[i][Index1].Value;
		Sum_Squared_0 += Sqr(FData[i][Index0].Value);
		Sum_Squared_1 += Sqr(FData[i][Index1].Value);
		Sum_Comp += FData[i][Index0].Value * FData[i][Index1].Value;
		end;
Correlation := (Num * Sum_Comp - Sum_0 * Sum_1) / Sqrt((Num * Sum_Squared_0 - Sqr(Sum_0)) * (Num * Sum_Squared_1 - Sqr(Sum_1)));
FAttributes[Index0].SetProperty('SUM_LEN_' + SGStr(Index1), TSGOptionPointer(Num));
FAttributes[Index1].SetProperty('SUM_LEN_' + SGStr(Index0), TSGOptionPointer(Num));
FAttributes[Index0].SetProperty('CORR_' + SGStr(Index1), TSGOptionPointer(TSGFloat32(Correlation)));
FAttributes[Index1].SetProperty('CORR_' + SGStr(Index0), TSGOptionPointer(TSGFloat32(Correlation)));
end;

var
	D1, D2 : TSGDateTime;
	i, ii : TSGMaxEnum;
begin
D1.Get();
for i := 0 to High(FAttributes) do
	if not (TSGStaticticsItemType(FAttributes[i].GetProperty('TYPE')) in [SGStaticticsItemTypeNull, SGStaticticsItemTypeText]) then
		for ii := 0 to High(FAttributes) do
			if i > ii then
				if not (TSGStaticticsItemType(FAttributes[ii].GetProperty('TYPE')) in [SGStaticticsItemTypeNull, SGStaticticsItemTypeText]) then
					Calculation(i, ii);
D2.Get();
SGHint(['Statistics : Calculation of correlation done at ', SGTextTimeBetweenDates(D1, D2), '.']);
end;

procedure TSGStaticticsTable.DetermineDiscreteValues(const Index : TSGMaxEnum);
var
	i : TSGMaxEnum;
	Values : TSGStringList = nil;
	TempString : TSGString;
	StringPointer : PSGString;
begin
for i := 0 to High(FObjects) do
	begin
	TempString := FData[i][Index].ToString();
	if TempString = '0' then
		TempString := '';
	if TempString <> '' then
		Values *= TempString;
	end;
FAttributes[Index].SetProperty('DISC_COUNT',  TSGOptionPointer(Length(Values)));
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
FAttributes[Index].SetProperty('DISC_VALUES', TSGOptionPointer(StringPointer));
StringPointer := nil;
end;

function TSGStaticticsTable.CalculationOfAttributeType(const Index : TSGMaxEnum) : TSGStaticticsItemType;
var
	CountNull  : TSGMaxEnum = 0;
	CountBool  : TSGMaxEnum = 0;
	CountNumer : TSGMaxEnum = 0;
	CountFloat : TSGMaxEnum = 0;
	CountText  : TSGMaxEnum = 0;
	i : TSGMaxEnum;
begin
for i := 0 to High(FObjects) do
	case FData[i][Index].ItemType of
	SGStaticticsItemTypeNull    : CountNull  += 1;
	SGStaticticsItemTypeBool    : CountBool  += 1;
	SGStaticticsItemTypeNumeric : CountNumer += 1;
	SGStaticticsItemTypeFloat   : CountFloat += 1;
	SGStaticticsItemTypeText    : CountText  += 1;
	end;
FAttributes[Index].SetProperty('COUNT_NULL', TSGOptionPointer(CountNull));
FAttributes[Index].SetProperty('COUNT_BOOL', TSGOptionPointer(CountBool));
FAttributes[Index].SetProperty('COUNT_NUMER', TSGOptionPointer(CountNumer));
FAttributes[Index].SetProperty('COUNT_FLOAT', TSGOptionPointer(CountFloat));
FAttributes[Index].SetProperty('COUNT_TEXT', TSGOptionPointer(CountText));
if CountText <> 0 then
	Result := SGStaticticsItemTypeText
else if CountFloat <> 0 then
	Result := SGStaticticsItemTypeFloat
else if CountNumer <> 0 then
	Result := SGStaticticsItemTypeNumeric
else if CountBool <> 0 then
	Result := SGStaticticsItemTypeBool
else
	Result := SGStaticticsItemTypeNull;
FAttributes[Index].SetProperty('TYPE', TSGOptionPointer(Result));
if Result = SGStaticticsItemTypeText then
	DetermineDiscreteValues(Index);
end;

procedure TSGStaticticsTable.ExportTypesInfo(const OutputFile : TSGString = '');
var
	f : TextFile;
	i, ii : TSGMaxEnum;
	MaxNameLength : TSGMaxEnum = 0;
begin
for i := 0 to High(FAttributes) do
	if Length(FAttributes[i].Name) > MaxNameLength then
		MaxNameLength := Length(FAttributes[i].Name);
Assign(f, OutputFile);
Rewrite(f);
for i := 0 to High(FAttributes) do
	begin
	Write(f, StringJustifyLeft(FAttributes[i].Name, MaxNameLength, ' ') + ' : ');
	Write(f, 'Type = ', StringJustifyRight(SGStrStatItemType(TSGStaticticsItemType(FAttributes[i].GetProperty('TYPE'))) + ';', 7, ' ') + ' ');
	Write(f, 'Count Null = ',  StringJustifyRight(SGStr(TSGMaxEnum(FAttributes[i].GetProperty('COUNT_NULL'))) + ';',  7, ' ') + ' ');
	Write(f, 'Count Bool = ',  StringJustifyRight(SGStr(TSGMaxEnum(FAttributes[i].GetProperty('COUNT_BOOL'))) + ';',  7, ' ') + ' ');
	Write(f, 'Count Numer = ', StringJustifyRight(SGStr(TSGMaxEnum(FAttributes[i].GetProperty('COUNT_NUMER'))) + ';', 7, ' ') + ' ');
	Write(f, 'Count Float = ', StringJustifyRight(SGStr(TSGMaxEnum(FAttributes[i].GetProperty('COUNT_FLOAT'))) + ';', 7, ' ') + ' ');
	Write(f, 'Count Text = ',  StringJustifyRight(SGStr(TSGMaxEnum(FAttributes[i].GetProperty('COUNT_TEXT'))) + '.',  7, ' '));
	WriteLn(f);
	end;
for i := 0 to High(FAttributes) do
	if FAttributes[i].ExistsProperty('DISC_COUNT') then
		begin
		Write(f, 'The attribute "', FAttributes[i].Name, '" is discrete and takes the values (', TSGMaxEnum(FAttributes[i].GetProperty('DISC_COUNT')), ') : ');
		for ii := 0 to TSGMaxEnum(FAttributes[i].GetProperty('DISC_COUNT')) - 1 do
			begin
			Write(f, StringWordGet(PSGString(FAttributes[i].GetProperty('DISC_VALUES'))^, #0, ii + 1));
			if ii = TSGMaxEnum(FAttributes[i].GetProperty('DISC_COUNT')) - 1 then
				WriteLn(f, '.')
			else
				Write(f, ', ');
			end;
		end;
CLose(f);
end;

procedure TSGStaticticsTable.CalculationOfTypes();
var
	i : TSGMaxEnum;
begin
for i := 0 to High(FAttributes) do
	CalculationOfAttributeType(i);
end;

procedure TSGStaticticsTable.Import(const FileName : TSGString);

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
	Bool : TSGBool = True;
	Str : TSGString = '';
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
			Result.ItemType := SGStaticticsItemTypeBool
		else
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
		Result.Text := SGConvertString(Value, SGEncodingWin1251);
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
D1.Get();
Assign(f, FileName);
Reset(f);
Importing(f);
Close(f);
D2.Get();
SGHint(['Statictics : Importing from "', FileName, '" done at ', SGTextTimeBetweenDates(D1, D2), '.']);
end;

constructor TSGStaticticsTable.Create();
begin
inherited;
FData := nil;
FObjects := nil;
FAttributes := nil;
end;

procedure TSGStaticticsTable.Clear();

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

destructor TSGStaticticsTable.Destroy();
begin
Clear();
inherited;
end;

class function TSGStaticticsTable.ClassName() : TSGString;
begin
Result := 'TSGStaticticsTable';
end;

end.
