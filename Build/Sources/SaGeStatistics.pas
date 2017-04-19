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
	PSGStringList = ^ TSGStringList;
type
	TSGStaticticsItemType = (
		SGStaticticsItemTypeNull, 
		SGStaticticsItemTypeBool, 
		SGStaticticsItemTypeNumeric, 
		SGStaticticsItemTypeFloat, 
		SGStaticticsItemTypeText);

function SGStrStatItemType(const ItemType : TSGStaticticsItemType) : TSGString;

type
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
		function ToString() : TSGString;
		end;
type
	TSGStaticticsFeature = object
			private
		FName : TSGString;
			// Obj  : 'INCORRECT'
			// Attr : 'TYPE'
			//   Type:
			// Attr : 'COUNT_NULL'
			// Attr : 'COUNT_BOOL'
			// Attr : 'COUNT_NUMER'
			// Attr : 'COUNT_FLOAT'
			// Attr : 'COUNT_TEXT'
			//   Discrete
			// Attr : 'DISC_COUNT'
			// Attr : 'DISC_VALUES'
			//   Correlation:
			// Attr : 'SUM_LEN_{index}'
			// Attr : 'CORR_{index}
			//   Regression
			// Attr : 'REG_EXCESS_{index}'
		FProperties : TSGSettings;
			public
		property Name : TSGString read FName write FName;
			public
		function GetProperty(const PropertyName : TSGString):TSGOptionPointer;
		function ExistsProperty(const PropertyName : TSGString) : TSGBool;
		procedure SetProperty(const PropertyName : TSGString; const Value : TSGOptionPointer = nil);
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
	TSGStaticticsObjectData = packed array of TSGStaticticsItem;
	TSGStaticticsData = packed array of TSGStaticticsObjectData;
	
	TSGStatictics = class(TSGNamed)
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
		procedure Clear();
		procedure Import(const FileName : TSGString);
		procedure CalculationOfCorrelation();
		procedure CalculationOfTypes();
		procedure DetermineDiscreteValues(const Index : TSGMaxEnum);
		procedure ExportTypesInfo(const OutputFile : TSGString = '');
		procedure CorrelationExport(const FileName : TSGString);
		procedure RegainRegression(const RegressionVariable : TSGString;  const OutputFileName : TSGString);overload;
		procedure RegainRegression(const RegressionVariable : TSGMaxEnum; const OutputFileName : TSGString);overload;
		procedure MarkExcessAttributes(const RegressionVariable : TSGMaxEnum);
		procedure MarkExcessObjects(const RegressionVariable : TSGMaxEnum);
		end;

function SGStatisticsTDistribution(const x : TSGFloat64; const N : TSGMaxEnum) : TSGFloat64;
function SGStatisticsTCorr(const Corr : TSGFloat64; const N : TSGMaxEnum) : TSGFloat64;

implementation

uses
	 SaGeConsoleTools
	,SaGeLog
	,SaGeFileUtils
	,SaGeDateTime
	,SaGeStringUtils
	,SaGeBaseUtils
	,SaGeEncodingUtils
	,SaGeMathUtils
	,SaGeConsoleUtils
	
	,StrMan
	
	,SysUtils
	,Math
	;

procedure TSGStatictics.RegainRegression(const RegressionVariable : TSGMaxEnum; const OutputFileName : TSGString);overload;

function IterFunc(var Coef : TSGFloat64List; var Obj : TSGStaticticsObjectData) : TSGFloat64;
var
	i, ic : TSGMaxEnum;
begin
Result := Coef[0];
i := 0;
ic := 1;
while i < Length(FAttributes) do
	begin
	if i <> RegressionVariable then
		begin
		if not FAttributes[i].ExistsProperty('REG_EXCESS_' + SGStr(RegressionVariable)) then
			Result += Coef[ic] * Obj[i].Value;
		ic += 1;
		end;
	i += 1;
	end;
end;

function IterFuncSquaderError(var Coef : TSGFloat64List) : TSGFloat64; overload;
var
	i, m : TSGMaxEnum;
begin
Result := 0;
m := 0;
for i := 0 to High(FObjects) do
	begin
	Result += Sqr(IterFunc(Coef, FData[i]) - FData[i][RegressionVariable].Value);
	m += 1;
	end;
Result /= 2 * m;
// ads
end;

procedure MoveCoef(var CL1, CL2 : TSGFloat64List);
var
	i : TSGMaxEnum;
begin
for i := 0 to High(CL1) do
	CL1[i] := CL2[i];
end;

procedure StepAttributes(var Coef1 : TSGFloat64List; var Coef2 : TSGFloat64List);
var
	Coe : TSGFloat64List;
	ic, i, ii, m : TSGMaxEnum;
begin
SetLength(Coe, Length(Coef1));
i := 0;
ic := 1;
while i < Length(FAttributes) do
	begin
	if (i <> RegressionVariable) and (not FAttributes[i].ExistsProperty('REG_EXCESS_' + SGStr(RegressionVariable))) then
		begin
		Coe[ic] := 0;
		m := 0;
		for ii := 0 to High(FObjects) do
			begin
			Coe[ic] += (IterFunc(Coef1, FData[ii]) - FData[ii][RegressionVariable].Value) * FData[ii][i].Value;
			m += 1;
			end;
		Coe[ic] := - Coe[ic] / m * 0.1 + Coef1[ic];
		ic += 1;
		end;
	i += 1;
	end;
MoveCoef(Coef2, Coe);
SetLength(Coe, 0);
end;

var
	Coef1 : TSGFloat64List;
	Coef2 : TSGFloat64List;
	S1, S2 : TSGFloat64;

function IterFuncSquaderError() : TSGFloat64; overload;
begin
Result := IterFuncSquaderError(Coef2);
end;

procedure MoveCoefAndRes();
begin
MoveCoef(Coef1, Coef2);
S1 := S2;
end;

procedure OutFile();
var
	f : TextFile;
	i, ic : TSGMaxEnum;
begin
Assign(f, OutputFileName);
Rewrite(f);
WriteLn(f, '				', Coef2[0] :0:10);
i := 0;
ic := 1;
while i < Length(FAttributes) do
	begin
	if (i <> RegressionVariable) and (not FAttributes[i].ExistsProperty('REG_EXCESS_' + SGStr(RegressionVariable))) then
		begin
		WriteLn(f, FAttributes[i].Name, '		', Coef2[ic] :0:10);
		ic += 1;
		end;
	i += 1;
	end;
Close(f);
end;

var
	i : TSGMaxEnum;
begin
MarkExcessAttributes(RegressionVariable);
MarkExcessObjects(RegressionVariable);
SetLength(Coef1, Length(FAttributes));
SetLength(Coef2, Length(FAttributes));
Coef1[0] := 0;
for i := 1 to High(Coef1) do
	Coef1[i] := 1;
S1 := IterFuncSquaderError(Coef1);
StepAttributes(Coef1, Coef2);
S2 := IterFuncSquaderError();
while Abs(S2 - S1) >  0.05 do
	begin
	MoveCoefAndRes();
	StepAttributes(Coef1, Coef2);
	S2 := IterFuncSquaderError();
	end;
OutFile();
SetLength(Coef1, 0);
SetLength(Coef2, 0);
end;

procedure TSGStatictics.MarkExcessObjects(const RegressionVariable : TSGMaxEnum);
var
	i, ii, n : TSGMaxEnum;
begin
for i := 0 to High(FAttributes) do
	if (not FAttributes[i].ExistsProperty('REG_EXCESS_' + SGStr(RegressionVariable))) then
		begin
		n := 0;
		for ii := 0 to High(FObjects) do
			if FData[ii][i].ItemType <> SGStaticticsItemTypeNull then
				n += 1;
		if n / Length(FObjects) < 0.6 then
			begin
			FAttributes[i].SetProperty('REG_EXCESS_' + SGStr(RegressionVariable));
			SGHint(['Statistics : Attribute "', FAttributes[i].Name, '" marked as excess (', n / Length(FObjects) * 100,')!']);
			end;
		end;
n := 0;
for i := 0 to High(FObjects) do
	for ii := 0 to High(FAttributes) do
		if (not FAttributes[ii].ExistsProperty('REG_EXCESS_' + SGStr(RegressionVariable))) then
			if FData[i][ii].ItemType = SGStaticticsItemTypeNull then
				begin
				FObjects[i].SetProperty('REG_EXCESS_' + SGStr(RegressionVariable));
				n += 1;
				break;
				end;
SGHint(['Statistics : ', n,' objects marked as excess!']);
end;

procedure TSGStatictics.MarkExcessAttributes(const RegressionVariable : TSGMaxEnum);

function CorrelationStatisticallySignificant(const Corr : TSGFloat64; const N : TSGMaxEnum) : TSGBool;
begin
if Corr < 0.05 then
	Result := False
else
	Result := SGStatisticsTCorr(Corr, N) >= SGStatisticsTDistribution(0.95, N);
end;

var
	i, N : TSGMaxEnum;
	Corr : TSGFloat64;
begin
for i := 0 to High(FAttributes) do
	if i <> RegressionVariable then
		begin
		if  ((TSGStaticticsItemType(FAttributes[i].GetProperty('TYPE')) in [SGStaticticsItemTypeNull]) or 
			{(not CorrelationStatisticallySignificant(
				TSGFloat32(FAttributes[i].GetProperty('CORR_' + SGStr(RegressionVariable))), 
				TSGMaxEnum(FAttributes[i].GetProperty('SUM_LEN_' + SGStr(RegressionVariable)))))) and }
			(Abs(TSGFloat32(FAttributes[i].GetProperty('CORR_' + SGStr(RegressionVariable)))) < 0.05)) and 
			(TSGStaticticsItemType(FAttributes[i].GetProperty('TYPE')) <> SGStaticticsItemTypeText) then
				begin
				FAttributes[i].SetProperty('REG_EXCESS_' + SGStr(RegressionVariable));
				SGHint(['Statistics : Attribute "', FAttributes[i].Name, '" marked as excess!']);
				end;
		end;
end;

procedure TSGStatictics.RegainRegression(const RegressionVariable : TSGString; const OutputFileName : TSGString);overload;
var
	i : TSGMaxEnum;
	Index : TSGMaxEnum;
begin
Index := Length(FAttributes);
for i := 0 to High(FAttributes) do
	if FAttributes[i].Name = RegressionVariable then
		begin
		Index := i;
		break
		end;
if Index = Length(FAttributes) then
	SGHint(['Statistics : Variable "', RegressionVariable, '" is not exists!'])
else
	RegainRegression(Index, OutputFileName);
end;

procedure TSGStatictics.CorrelationExport(const FileName : TSGString);
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

function SGStatisticsTCorr(const Corr : TSGFloat64; const N : TSGMaxEnum) : TSGFloat64;
begin
Result := Corr * Sqrt(N - 2) / Sqrt(1 - Sqr(Corr));
end;

function SGStatisticsTDistribution(const x : TSGFloat64; const N : TSGMaxEnum) : TSGFloat64;

function gamma(const x : TSGFloat64) : TSGFloat64;
var
	tmp, ser : TSGFloat64;
begin
tmp := (x - 0.5) * Ln(x + 4.5) - (x + 4.5);
ser := 1.0 + 
	76.18009173   / (x + 0.0) -  86.50532033   / (x + 1.0) +
	24.01409822   / (x + 2.0) -  1.231739516   / (x + 3.0) +
	0.00120858003 / (x + 4.0) -  0.00000536382 / (x + 5.0);    
Result := Exp(tmp + Ln(ser * Sqrt(2 * PI)));
end;

function gammaRatio(const x, y : TSGFloat64) : TSGFloat64;
var
	m : TSGFloat64;
begin
m := Abs(Max(x, y));
if (m <= 100.0) then
	Result :=  gamma(x) / gamma(y)
else
	Result :=  (2.0 ** (x - y))  *  
				gammaRatio(x * 0.5, y * 0.5)  * 
				gammaRatio(x * 0.5 + 0.5, y * 0.5 + 0.5);
end;

function hyperGeom(const a, b, c, z : TSGFloat64; const deep : TSGMaxEnum) : TSGFloat64; overload;
var
	M, d : TSGFloat64;
	i, j : TSGMaxEnum;
begin
Result := 1;   
for i := 1 to deep do
	begin
	M := z ** TSGFloat64(i);
	for j := 0 to i - 1 do
		M *= (a + j) * (b + j) / ((1.0 + j) * (c + j));
	Result += M;      
	end;
end;

function hyperGeom(const a, b, c, z : TSGFloat64) : TSGFloat64; overload;
begin
Result := hyperGeom(a, b, c, z, 20);
end;

begin
Result := 0.5 + x * gammaRatio(0.5 * (N + 1.0), 0.5 * N) * hyperGeom(0.5, 0.5 * (N + 1.0), 1.5, -x*x / N) / Sqrt(PI * N);
end;

procedure TSGStatictics.CalculationOfCorrelation();

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

procedure TSGStatictics.DetermineDiscreteValues(const Index : TSGMaxEnum);
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

function TSGStatictics.CalculationOfAttributeType(const Index : TSGMaxEnum) : TSGStaticticsItemType;
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

procedure TSGStatictics.ExportTypesInfo(const OutputFile : TSGString = '');
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

procedure TSGStatictics.CalculationOfTypes();
var
	i : TSGMaxEnum;
begin
for i := 0 to High(FAttributes) do
	CalculationOfAttributeType(i);
end;

function SGStrStatItemType(const ItemType : TSGStaticticsItemType) : TSGString;
begin
case ItemType of
SGStaticticsItemTypeNull    : Result := 'Null';
SGStaticticsItemTypeBool    : Result := 'Bool';
SGStaticticsItemTypeNumeric : Result := 'Numer';
SGStaticticsItemTypeFloat   : Result := 'Float';
SGStaticticsItemTypeText    : Result := 'Text';
end;
end;

function TSGStaticticsFeature.GetProperty(const PropertyName : TSGString):TSGOptionPointer;
var
	i : TSGMaxEnum;
begin
Result := nil;
if (FProperties <> nil) and (Length(FProperties) > 0) then
	for i := 0 to High(FProperties) do
		if FProperties[i].FName = PropertyName then
			begin
			Result := FProperties[i].FOption;
			break;
			end;
end;

function TSGStaticticsFeature.ExistsProperty(const PropertyName : TSGString) : TSGBool;
begin
Result := PropertyName in FProperties;
end;

procedure TSGStaticticsFeature.SetProperty(const PropertyName : TSGString; const Value : TSGOptionPointer = nil);
var
	TempProperty : TSGOption;
	i : TSGMaxEnum;
begin
if ExistsProperty(PropertyName) then
	begin
	for i := 0 to High(FProperties) do
		if FProperties[i].FName = PropertyName then
			FProperties[i].FOption := Value;
	end
else
	begin
	TempProperty.Import(PropertyName, Value);
	FProperties += TempProperty;
	end;
end;

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

function TSGStaticticsItem.ToString() : TSGString;
begin
Result := '';
if FType <> SGStaticticsItemTypeNull then
	if FType = SGStaticticsItemTypeText then
		Result := FValueText
	else if FType = SGStaticticsItemTypeFloat then
		Result := SGStrReal(FValue, 8)
	else
		Result := SGStr(Round(FValue));
end;

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
	ImportFile          : TSGString = '';
	CorrelationFileName : TSGString = '';
	TypesFileName       : TSGString = '';
	RegressionVariable  : TSGString = '';
	RegressionFileName  : TSGString = '';

function ProccessRegressionExport(const Comand : TSGString):TSGBool;
var
	Value : TSGString;
begin
Value := SGParseValueFromComand(Comand, ['out_regression:']);
Result := Value <> '';
if Result then
	RegressionFileName := Value;
end;

function ProccessRegressionVariable(const Comand : TSGString):TSGBool;
var
	Value : TSGString;
begin
Value := SGParseValueFromComand(Comand, ['regression_variable:']);
Result := Value <> '';
if Result then
	RegressionVariable := SGConvertString(Value, SGEncodingWin1251);
end;

function ProccessTypesExport(const Comand : TSGString):TSGBool;
var
	Value : TSGString;
begin
Value := SGParseValueFromComand(Comand, ['out_types:']);
Result := Value <> '';
if Result then
	TypesFileName := Value;
end;

function ProccessCorrelationExport(const Comand : TSGString):TSGBool;
var
	Value : TSGString;
begin
Value := SGParseValueFromComand(Comand, ['out_correlation:']);
Result := Value <> '';
if Result then
	CorrelationFileName := Value;
end;

function ProccessImporting(const Comand : TSGString):TSGBool;
var
	Value : TSGString;
begin
Value := SGParseValueFromComand(Comand, ['input:']);
Result := Value <> '';
if Result then
	ImportFile := Value;
end;

var
	Success : TSGBool = True;
begin
with TSGConsoleCaller.Create(VParams) do
	begin
	AddComand(@ProccessImporting,          ['input:*'],               'Import data');
	AddComand(@ProccessTypesExport,        ['out_types:*'],           'Export types info');
	AddComand(@ProccessCorrelationExport,  ['out_correlation:*'],     'Export correlation');
	AddComand(@ProccessRegressionExport,   ['out_regression:*'],      'Export regression data');
	AddComand(@ProccessRegressionVariable, ['regression_variable:*'], 'Set regression variable');
	Success := Execute();
	Destroy();
	end;
if Success then
	begin
	with TSGStatictics.Create() do
		begin
		Import(ImportFile);
		CalculationOfTypes();
		if TypesFileName <> '' then
			ExportTypesInfo(TypesFileName);
		CalculationOfCorrelation();
		if CorrelationFileName <> '' then
			CorrelationExport(CorrelationFileName);
		if RegressionVariable <> '' then
			RegainRegression(RegressionVariable, RegressionFileName);
		Destroy();
		end;
	end
else
	SGHint('Statistics : Some errors!');
end;

initialization
begin
SGGeneralConsoleCaller().AddComand(@SGConcoleRunStatistics, ['statistics'], 'Statictics');
end;

end.
