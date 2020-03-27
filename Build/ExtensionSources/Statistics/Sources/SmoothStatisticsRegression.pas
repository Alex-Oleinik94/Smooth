{$INCLUDE Smooth.inc}

unit SmoothStatisticsRegression;

interface

uses
	 SmoothBase
	,SmoothVersion
	,SmoothClasses
	
	,SmoothStatisticsStudentiz
	,SmoothStatisticsBase
	,SmoothStatisticsTable
	;

type
	TSStaticticsRegression = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			private
		FTable : TSStaticticsTable;
		FOutputFileName : TSString;
		FRegressionVariable : TSString;
		FRegressionVariableIndex : TSMaxEnum;
			private
		procedure SetRegressionVariable(const RegressionVariable : TSString);
			protected
		procedure MarkExcessAttributes();
		procedure MarkExcessObjects();
		function DataPower() : TSMaxEnum;
			protected
		property RegressionVariableIndex : TSMaxEnum read FRegressionVariableIndex;
			public
		procedure Clear();virtual;
		procedure RegainRegression();virtual;abstract;
		procedure OutToFile();virtual;abstract;
			public
		property Table : TSStaticticsTable read FTable;
		property RegressionVariable : TSString read FRegressionVariable write SetRegressionVariable;
		property OutputFileName : TSString read FOutputFileName write FOutputFileName;
		end;

implementation

uses
	 SmoothLog
	,SmoothStringUtils
	,SmoothBaseUtils
	;

procedure TSStaticticsRegression.SetRegressionVariable(const RegressionVariable : TSString);
var
	i : TSMaxEnum;
	Index : TSMaxEnum;
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
	SHint(['Statistics : Variable "', RegressionVariable, '" is not exists!'])
else
	FRegressionVariableIndex := Index;
end;

function TSStaticticsRegression.DataPower() : TSMaxEnum;
var
	i : TSMaxEnum;
begin
Result := 0;
for i := 0 to High(FTable.Objects) do
	if FTable.Objects[i].NotExcess(FRegressionVariableIndex) then
		Result += 1;
end;

procedure TSStaticticsRegression.MarkExcessObjects();
var
	i, ii, n : TSMaxEnum;
	excess : TSBool;
	extra  : TSBool;
begin
for i := 0 to High(FTable.Attributes) do
	if (not FTable.Attributes[i].ExistsProperty('REG_EXCESS_' + SStr(FRegressionVariableIndex))) then
		begin
		extra := False;
		excess := TSStaticticsItemType(FTable.Attributes[i].GetProperty('TYPE')) = SStaticticsItemTypeText;
		if not excess then
			begin
			n := 0;
			for ii := 0 to High(FTable.Objects) do
				if FTable.Data[ii][i].ItemType <> SStaticticsItemTypeNull then
					n += 1;
			excess := n / Length(FTable.Objects) < 0.6;
			extra := True;
			end;
		if excess then
			begin
			FTable.Attributes[i].SetProperty('REG_EXCESS_' + SStr(FRegressionVariableIndex));
			SHint(['Statistics : Attribute "', FTable.Attributes[i].Name, '" marked as excess (', 
				Iff(extra, SStrReal(n / Length(FTable.Objects) * 100, 3) + '% fullness', 'Is text referense'),')!']);
			end;
		end;
n := 0;
for i := 0 to High(FTable.Objects) do
	for ii := 0 to High(FTable.Attributes) do
		if (not FTable.Attributes[ii].ExistsProperty('REG_EXCESS_' + SStr(FRegressionVariableIndex))) then
			if FTable.Data[i][ii].ItemType = SStaticticsItemTypeNull then
				begin
				FTable.Objects[i].SetProperty('REG_EXCESS_' + SStr(FRegressionVariableIndex));
				n += 1;
				break;
				end;
SHint(['Statistics : ', n,' objects marked as excess!']);
end;

procedure TSStaticticsRegression.MarkExcessAttributes();

function CorrelationStatisticallySignificant(const Corr : TSFloat64; const N : TSMaxEnum) : TSBool;
begin
if Corr < 0.05 then
	Result := False
else
	Result := SStatisticsTCorr(Corr, N) >= SStatisticsTDistribution(0.95, N);
end;

var
	i, N : TSMaxEnum;
	Corr : TSFloat64;
begin
for i := 0 to High(FTable.Attributes) do
	if i <> FRegressionVariableIndex then
		begin
		if  ((TSStaticticsItemType(FTable.Attributes[i].GetProperty('TYPE')) in [SStaticticsItemTypeNull]) or 
			{(not CorrelationStatisticallySignificant(
				TSFloat32(FTable.Attributes[i].GetProperty('CORR_' + SStr(FRegressionVariableIndex))), 
				TSMaxEnum(FTable.Attributes[i].GetProperty('SUM_LEN_' + SStr(FRegressionVariableIndex)))))) and }
			(Abs(TSFloat32(FTable.Attributes[i].GetProperty('CORR_' + SStr(FRegressionVariableIndex)))) < 0.7)) and 
			(TSStaticticsItemType(FTable.Attributes[i].GetProperty('TYPE')) <> SStaticticsItemTypeText) then
				begin
				FTable.Attributes[i].SetProperty('REG_EXCESS_' + SStr(FRegressionVariableIndex));
				SHint(['Statistics : Attribute "', FTable.Attributes[i].Name, '" marked as excess (Correlation ',TSFloat32(FTable.Attributes[i].GetProperty('CORR_' + SStr(FRegressionVariableIndex))),')!']);
				end;
		end;
end;

constructor TSStaticticsRegression.Create();
begin
inherited;
FTable := TSStaticticsTable.Create();
FOutputFileName := '';
FRegressionVariable := '';
FRegressionVariableIndex := 0;
end;

procedure TSStaticticsRegression.Clear();
begin
if FTable <> nil then
	begin
	FTable.Destroy();
	FTable := nil;
	end;
inherited;
end;

destructor TSStaticticsRegression.Destroy();
begin
Clear();
inherited;
end;

class function TSStaticticsRegression.ClassName() : TSString;
begin
Result := 'TSStaticticsRegression';
end;

end.
