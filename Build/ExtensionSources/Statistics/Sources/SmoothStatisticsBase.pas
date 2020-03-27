{$INCLUDE Smooth.inc}

unit SmoothStatisticsBase;

interface

uses
	 SmoothBase
	;
type
	TSStaticticsItemType = (
		SStaticticsItemTypeNull, 
		SStaticticsItemTypeBool, 
		SStaticticsItemTypeNumeric, 
		SStaticticsItemTypeFloat, 
		SStaticticsItemTypeText);

function SStrStatItemType(const ItemType : TSStaticticsItemType) : TSString;

type
	TSStaticticsItem = object
			private
		FType : TSStaticticsItemType;
		FValue : TSFloat64;
		FValueText : TSString;
			public
		property ItemType : TSStaticticsItemType read FType write FType;
		property Value : TSFloat64 read FValue write FValue;
		property Text : TSString read FValueText write FValueText;
			public
		procedure Clear();
		function ToString() : TSString;
		end;
type
	TSStaticticsFeature = object
			private
		FName : TSString;
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
			// Attr : 'CORR_{index}'
			// Attr : 'CORR_SUM_{index}'
			// Attr : 'CORR_SQUAR_SUM_{index}'
			// Attr : 'CORR_COMB_{index}'
			//   Regression
			// Attr/Obj : 'REG_EXCESS_{index}'
		FProperties : TSSettings;
			public
		property Name : TSString read FName write FName;
			public
		function GetProperty(const PropertyName : TSString):TSOptionPointer;
		function ExistsProperty(const PropertyName : TSString) : TSBool;
		procedure SetProperty(const PropertyName : TSString; const Value : TSOptionPointer = nil);
		procedure Nominate(const NewName : TSString);
		procedure Kill();
		function NotExcess(const RegressionVariable : TSMaxEnum) : TSBool;
		end;

function SStaticticsFeatureCreate(const TextName : TSString) : TSStaticticsFeature;

{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSStaticticsFeaturesHelper}
{$DEFINE DATATYPE_LIST        := TSStaticticsFeatures}
{$DEFINE DATATYPE             := TSStaticticsFeature}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_INTERFACE}

operator = (const A, B : TSStaticticsFeature) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

type
		// FData[Lines = Objects][Columns = Attribute]
	TSStaticticsObjectData = packed array of TSStaticticsItem;
	TSStaticticsData = packed array of TSStaticticsObjectData;

implementation

uses
	 SmoothStringUtils
	;

function SStrStatItemType(const ItemType : TSStaticticsItemType) : TSString;
begin
case ItemType of
SStaticticsItemTypeNull    : Result := 'Null';
SStaticticsItemTypeBool    : Result := 'Bool';
SStaticticsItemTypeNumeric : Result := 'Numer';
SStaticticsItemTypeFloat   : Result := 'Float';
SStaticticsItemTypeText    : Result := 'Text';
end;
end;

function TSStaticticsFeature.NotExcess(const RegressionVariable : TSMaxEnum) : TSBool;
begin
Result := (not ExistsProperty('REG_EXCESS_' + SStr(RegressionVariable)));
end;

function TSStaticticsFeature.GetProperty(const PropertyName : TSString):TSOptionPointer;
var
	i : TSMaxEnum;
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

function TSStaticticsFeature.ExistsProperty(const PropertyName : TSString) : TSBool;
begin
Result := PropertyName in FProperties;
end;

procedure TSStaticticsFeature.SetProperty(const PropertyName : TSString; const Value : TSOptionPointer = nil);
var
	TempProperty : TSOption;
	i : TSMaxEnum;
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

function SStaticticsFeatureCreate(const TextName : TSString) : TSStaticticsFeature;
begin
Result.Nominate(TextName);
end;

operator = (const A, B : TSStaticticsFeature) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := A.Name = B.Name;
end;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSStaticticsFeaturesHelper}
{$DEFINE DATATYPE_LIST        := TSStaticticsFeatures}
{$DEFINE DATATYPE             := TSStaticticsFeature}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

function TSStaticticsItem.ToString() : TSString;
begin
Result := '';
if FType <> SStaticticsItemTypeNull then
	if FType = SStaticticsItemTypeText then
		Result := FValueText
	else if FType = SStaticticsItemTypeFloat then
		Result := SStrReal(FValue, 8)
	else
		Result := SStr(Round(FValue));
end;

procedure TSStaticticsItem.Clear();
begin
FType := SStaticticsItemTypeNull;
FValue := 0;
FValueText := '';
end;

operator in (const A : TSChar; const S : TSString) : TSBool; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSMaxEnum;
begin
Result := False;
for i := 1 to Length(S) do
	if S[i] = A then
		begin
		Result := True;
		break;
		end;
end;


procedure TSStaticticsFeature.Nominate(const NewName : TSString);
begin
FName := NewName;
FProperties := nil;
end;

procedure TSStaticticsFeature.Kill();

procedure KillProperty(var FeatureProperty : TSOption);
begin
// TODO
end;

var
	i : TSMaxEnum;
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

end.
