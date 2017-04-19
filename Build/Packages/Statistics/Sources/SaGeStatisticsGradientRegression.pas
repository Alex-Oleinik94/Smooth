{$INCLUDE SaGe.inc}

unit SaGeStatisticsGradientRegression;

interface

uses
	 SaGeBase
	,SaGeVersion
	
	,SaGeStatisticsStudentiz
	,SaGeStatisticsBase
	,SaGeStatisticsTable
	,SaGeStatisticsRegression
	;

type
	TSGStaticticsLinearCoeficients = TSGFloat64List;
	TSGStaticticsGradientRegression = class(TSGStaticticsRegression)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FDataPower : TSGMaxEnum;
		FFinalCoeficients : TSGStaticticsLinearCoeficients;
			private
		class procedure MoveCoeficients(const Source : TSGStaticticsLinearCoeficients; var Destination : TSGStaticticsLinearCoeficients);
		procedure OutCoeficientsToFile(const Coeficients : TSGStaticticsLinearCoeficients);
		function IterationFunction(var Coeficients : TSGFloat64List; var ObjectData : TSGStaticticsObjectData) : TSGFloat64;
		function IterationFunctionSquaderError(var Coeficients : TSGStaticticsLinearCoeficients) : TSGFloat64;
		procedure RegainGradientRegression();
			public
		procedure Clear(); override;
		procedure RegainRegression(); override;
		procedure OutToFile(); override;
		end;

implementation

uses
	 SaGeLog
	,SaGeDateTime
	;

class procedure TSGStaticticsGradientRegression.MoveCoeficients(const Source : TSGStaticticsLinearCoeficients; var Destination : TSGStaticticsLinearCoeficients);
var
	i : TSGMaxEnum;
begin
SetLength(Destination, Length(Source));
for i := 0 to High(Source) do
	Destination[i] := Source[i];
end;

function TSGStaticticsGradientRegression.IterationFunction(var Coeficients : TSGFloat64List; var ObjectData : TSGStaticticsObjectData) : TSGFloat64;
var
	i, ic : TSGMaxEnum;
begin
Result := Coeficients[0];
i := 0;
ic := 1;
while i < Length(Table.Attributes) do
	begin
	if i <> RegressionVariableIndex then
		begin
		if Table.Attributes[i].NotExcess(RegressionVariableIndex) then
			Result += Coeficients[ic] * ObjectData[i].Value;
		ic += 1;
		end;
	i += 1;
	end;
end;

function TSGStaticticsGradientRegression.IterationFunctionSquaderError(var Coeficients : TSGStaticticsLinearCoeficients) : TSGFloat64;
var
	i : TSGMaxEnum;
begin
Result := 0;
for i := 0 to High(Table.Objects) do
	if Table.Objects[i].NotExcess(RegressionVariableIndex) then
		Result += Sqr(IterationFunction(Coeficients, Table.Data[i]) - Table.Data[i][RegressionVariableIndex].Value) / (2 * FDataPower);
Write(Result :0:10);ReadLn();
end;

procedure TSGStaticticsGradientRegression.RegainGradientRegression();

procedure StepAttributes(var Coef1 : TSGFloat64List; var Coef2 : TSGFloat64List);
var
	Coe : TSGFloat64List;
	ic, i, ii : TSGMaxEnum;
	alpha : TSGFloat64 = -0.0001;
begin
SetLength(Coe, Length(Coef1));
i := 0;
ic := 1;
while i < Length(Table.Attributes) do
	begin
	if (i <> RegressionVariableIndex) then
		begin
		if Table.Attributes[i].NotExcess(RegressionVariableIndex) then
			begin
			Coe[ic] := 0;
			for ii := 0 to High(Table.Objects) do
				if Table.Objects[ii].NotExcess(RegressionVariableIndex) then
					Coe[ic] += (IterationFunction(Coef1, Table.Data[ii]) - Table.Data[ii][RegressionVariableIndex].Value) * alpha / FDataPower * Table.Data[ii][i].Value;
			Coe[ic] := Coef1[ic] - Coe[ic];
			end;
		ic += 1;
		end;
	i += 1;
	end;
MoveCoeficients(Coe, Coef2);
SetLength(Coe, 0);
OutCoeficientsToFile(Coef2);
end;

var
	Coef1 : TSGFloat64List;
	Coef2 : TSGFloat64List;
	S1, S2 : TSGFloat64;

function IterFuncSquaderError() : TSGFloat64; overload;
begin
Result := IterationFunctionSquaderError(Coef2);
end;

procedure MoveCoefAndRes();
begin
MoveCoeficients(Coef2, Coef1);
S1 := S2;
end;

var
	i : TSGMaxEnum;
begin
SetLength(Coef1, Length(Table.Attributes));
SetLength(Coef2, Length(Table.Attributes));
Coef1[0] := 0;
for i := 1 to High(Coef1) do
	Coef1[i] := 1;
S1 := IterationFunctionSquaderError(Coef1);
StepAttributes(Coef1, Coef2);
S2 := IterFuncSquaderError();
while Abs(S2 - S1) >  0.05 do
	begin
	MoveCoefAndRes();
	StepAttributes(Coef1, Coef2);
	S2 := IterFuncSquaderError();
	end;
OutCoeficientsToFile(Coef2);
SetLength(Coef1, 0);
SetLength(Coef2, 0);
end;

procedure TSGStaticticsGradientRegression.RegainRegression();
begin
MarkExcessAttributes();
MarkExcessObjects();
FDataPower := DataPower();
RegainGradientRegression();
end;

procedure TSGStaticticsGradientRegression.OutToFile();
begin
OutCoeficientsToFile(FFinalCoeficients);
end;

procedure TSGStaticticsGradientRegression.OutCoeficientsToFile(const Coeficients : TSGStaticticsLinearCoeficients);
var
	f : TextFile;
	i, ic : TSGMaxEnum;
begin
Assign(f, OutputFileName);
Rewrite(f);
WriteLn(f, '				', Coeficients[0] :0:10);
i := 0;
ic := 1;
while i < Length(Table.Attributes) do
	begin
	if (i <> RegressionVariableIndex) then
		begin
		if Table.Attributes[i].NotExcess(RegressionVariableIndex) then
			WriteLn(f, Table.Attributes[i].Name, '		', Coeficients[ic] :0:10);
		ic += 1;
		end;
	i += 1;
	end;
Close(f);
end;

constructor TSGStaticticsGradientRegression.Create();
begin
inherited;
end;

procedure TSGStaticticsGradientRegression.Clear();
begin

end;

destructor TSGStaticticsGradientRegression.Destroy();
begin
Clear();
inherited;
end;

class function TSGStaticticsGradientRegression.ClassName() : TSGString;
begin
Result := 'TSGStaticticsGradientRegression';
end;

end.
