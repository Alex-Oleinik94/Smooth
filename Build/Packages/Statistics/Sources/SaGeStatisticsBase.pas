{$INCLUDE SaGe.inc}

unit SaGeStatisticsBase;

interface

uses
	 SaGeBase
	;
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
			// Attr : 'CORR_{index}'
			// Attr : 'CORR_SUM_{index}'
			// Attr : 'CORR_SQUAR_SUM_{index}'
			// Attr : 'CORR_COMB_{index}'
			//   Regression
			// Attr/Obj : 'REG_EXCESS_{index}'
		FProperties : TSGSettings;
			public
		property Name : TSGString read FName write FName;
			public
		function GetProperty(const PropertyName : TSGString):TSGOptionPointer;
		function ExistsProperty(const PropertyName : TSGString) : TSGBool;
		procedure SetProperty(const PropertyName : TSGString; const Value : TSGOptionPointer = nil);
		procedure Nominate(const NewName : TSGString);
		procedure Kill();
		function NotExcess(const RegressionVariable : TSGMaxEnum) : TSGBool;
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

implementation

uses
	 SaGeStringUtils
	;

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

function TSGStaticticsFeature.NotExcess(const RegressionVariable : TSGMaxEnum) : TSGBool;
begin
Result := (not ExistsProperty('REG_EXCESS_' + SGStr(RegressionVariable)));
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

end.
