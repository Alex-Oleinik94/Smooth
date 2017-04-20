{$INCLUDE SaGe.inc}

unit SaGeStatisticsRegression;

interface

uses
	 SaGeBase
	,SaGeVersion
	,SaGeClasses
	
	,SaGeStatisticsStudentiz
	,SaGeStatisticsBase
	,SaGeStatisticsTable
	;

type
	TSGStaticticsRegression = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FTable : TSGStaticticsTable;
		FOutputFileName : TSGString;
		FRegressionVariable : TSGString;
		FRegressionVariableIndex : TSGMaxEnum;
			private
		procedure SetRegressionVariable(const RegressionVariable : TSGString);
			protected
		procedure MarkExcessAttributes();
		procedure MarkExcessObjects();
		function DataPower() : TSGMaxEnum;
			protected
		property RegressionVariableIndex : TSGMaxEnum read FRegressionVariableIndex;
			public
		procedure Clear();virtual;
		procedure RegainRegression();virtual;abstract;
		procedure OutToFile();virtual;abstract;
			public
		property Table : TSGStaticticsTable read FTable;
		property RegressionVariable : TSGString read FRegressionVariable write SetRegressionVariable;
		property OutputFileName : TSGString read FOutputFileName write FOutputFileName;
		end;

implementation

uses
	 SaGeLog
	,SaGeStringUtils
	,SaGeBaseUtils
	;

procedure TSGStaticticsRegression.SetRegressionVariable(const RegressionVariable : TSGString);
var
	i : TSGMaxEnum;
	Index : TSGMaxEnum;
begin
FRegressionVariable := RegressionVariable;
Index := Length(FTable.Attributes);
for i := 0 to High(FTable.Attributes) do
	if FTable.Attributes[i].Name = RegressionVariable then
		begin
		Index := i;
		break
		end;
if Index = Length(FTable.Attributes) then
	SGHint(['Statistics : Variable "', RegressionVariable, '" is not exists!'])
else
	FRegressionVariableIndex := Index;
end;

function TSGStaticticsRegression.DataPower() : TSGMaxEnum;
var
	i : TSGMaxEnum;
begin
Result := 0;
for i := 0 to High(FTable.Objects) do
	if FTable.Objects[i].NotExcess(FRegressionVariableIndex) then
		Result += 1;
end;

procedure TSGStaticticsRegression.MarkExcessObjects();
var
	i, ii, n : TSGMaxEnum;
	excess : TSGBool;
	extra  : TSGBool;
begin
for i := 0 to High(FTable.Attributes) do
	if (not FTable.Attributes[i].ExistsProperty('REG_EXCESS_' + SGStr(FRegressionVariableIndex))) then
		begin
		extra := False;
		excess := TSGStaticticsItemType(FTable.Attributes[i].GetProperty('TYPE')) = SGStaticticsItemTypeText;
		if not excess then
			begin
			n := 0;
			for ii := 0 to High(FTable.Objects) do
				if FTable.Data[ii][i].ItemType <> SGStaticticsItemTypeNull then
					n += 1;
			excess := n / Length(FTable.Objects) < 0.6;
			extra := True;
			end;
		if excess then
			begin
			FTable.Attributes[i].SetProperty('REG_EXCESS_' + SGStr(FRegressionVariableIndex));
			SGHint(['Statistics : Attribute "', FTable.Attributes[i].Name, '" marked as excess (', 
				Iff(extra, SGStrReal(n / Length(FTable.Objects) * 100, 3) + '% fullness', 'Is text referense'),')!']);
			end;
		end;
n := 0;
for i := 0 to High(FTable.Objects) do
	for ii := 0 to High(FTable.Attributes) do
		if (not FTable.Attributes[ii].ExistsProperty('REG_EXCESS_' + SGStr(FRegressionVariableIndex))) then
			if FTable.Data[i][ii].ItemType = SGStaticticsItemTypeNull then
				begin
				FTable.Objects[i].SetProperty('REG_EXCESS_' + SGStr(FRegressionVariableIndex));
				n += 1;
				break;
				end;
SGHint(['Statistics : ', n,' objects marked as excess!']);
end;

procedure TSGStaticticsRegression.MarkExcessAttributes();

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
for i := 0 to High(FTable.Attributes) do
	if i <> FRegressionVariableIndex then
		begin
		if  ((TSGStaticticsItemType(FTable.Attributes[i].GetProperty('TYPE')) in [SGStaticticsItemTypeNull]) or 
			{(not CorrelationStatisticallySignificant(
				TSGFloat32(FTable.Attributes[i].GetProperty('CORR_' + SGStr(FRegressionVariableIndex))), 
				TSGMaxEnum(FTable.Attributes[i].GetProperty('SUM_LEN_' + SGStr(FRegressionVariableIndex)))))) and }
			(Abs(TSGFloat32(FTable.Attributes[i].GetProperty('CORR_' + SGStr(FRegressionVariableIndex)))) < 0.05)) and 
			(TSGStaticticsItemType(FTable.Attributes[i].GetProperty('TYPE')) <> SGStaticticsItemTypeText) then
				begin
				FTable.Attributes[i].SetProperty('REG_EXCESS_' + SGStr(FRegressionVariableIndex));
				SGHint(['Statistics : Attribute "', FTable.Attributes[i].Name, '" marked as excess!']);
				end;
		end;
end;

constructor TSGStaticticsRegression.Create();
begin
inherited;
FTable := TSGStaticticsTable.Create();
FOutputFileName := '';
FRegressionVariable := '';
FRegressionVariableIndex := 0;
end;

procedure TSGStaticticsRegression.Clear();
begin
if FTable <> nil then
	begin
	FTable.Destroy();
	FTable := nil;
	end;
inherited;
end;

destructor TSGStaticticsRegression.Destroy();
begin
Clear();
inherited;
end;

class function TSGStaticticsRegression.ClassName() : TSGString;
begin
Result := 'TSGStaticticsRegression';
end;

end.
