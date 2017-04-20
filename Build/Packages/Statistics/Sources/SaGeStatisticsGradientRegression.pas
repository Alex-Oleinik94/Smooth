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

const
	MaxCoeficientsListLength = 2; // >= 2
	GradientRegressionEpsilon = 0.05;
	GradientRegressionAlpha = 0.01;
type
	TSGStaticticsLinearCoeficients = TSGFloat64List;
	TSGStaticticsLinearCoeficientsList = packed array of TSGStaticticsLinearCoeficients;
	
	TSGStaticticsGradientRegression = class(TSGStaticticsRegression)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FDataPower : TSGMaxEnum;
		FFinalCoeficients : TSGStaticticsLinearCoeficients;
		FCoeficientsLength : TSGMaxEnum;
		FCoeficientsAttributes : TSGUInt32List;
		FExcessObjects : TSGBooleanList;
			private
		function CalculateCoeficientsLength() : TSGMaxEnum;
		procedure CalculatateCoeficientsAttributes();
		class procedure MoveCoeficients(const Source : TSGStaticticsLinearCoeficients; var Destination : TSGStaticticsLinearCoeficients);overload;
		class procedure MoveCoeficients(const Source : TSGStaticticsLinearCoeficients; var Destination : TSGStaticticsLinearCoeficients; const DestinationLength : TSGMaxEnum); overload;
		procedure OutCoeficientsToFile(const Coeficients : TSGStaticticsLinearCoeficients);
		function IterationFunction(var Coeficients : TSGFloat64List; var ObjectData : TSGStaticticsObjectData) : TSGFloat64;
		function IterationFunctionSquaderError(var Coeficients : TSGStaticticsLinearCoeficients) : TSGFloat64;
		procedure RegainGradientRegression();
		procedure CalculateExcessObjects();
			private
		function CalculateNextCoeficients(const CoeficientsList : TSGStaticticsLinearCoeficientsList) : TSGStaticticsLinearCoeficients;
		function CalculateStartCoeficients() : TSGStaticticsLinearCoeficients;
		procedure InsertNewCoeficients(var CoeficientsList : TSGStaticticsLinearCoeficientsList; const Coeficients : TSGStaticticsLinearCoeficients);
		procedure InsertNewCoeficientsAndClear(var CoeficientsList : TSGStaticticsLinearCoeficientsList; var Coeficients : TSGStaticticsLinearCoeficients; var Error : TSGFloat64);
			public
		procedure Clear(); override;
		procedure RegainRegression(); override;
		procedure OutToFile(); override;
		end;

implementation

uses
	 SaGeLog
	,SaGeDateTime
	,SaGeBaseUtils
	;

class procedure TSGStaticticsGradientRegression.MoveCoeficients(const Source : TSGStaticticsLinearCoeficients; var Destination : TSGStaticticsLinearCoeficients; const DestinationLength : TSGMaxEnum); overload;
var
	i : TSGMaxEnum;
begin
SetLength(Destination, DestinationLength);
for i := 0 to DestinationLength - 1 do
	Destination[i] := Source[i];
end;

class procedure TSGStaticticsGradientRegression.MoveCoeficients(const Source : TSGStaticticsLinearCoeficients; var Destination : TSGStaticticsLinearCoeficients); overload;
begin
MoveCoeficients(Source, Destination, Length(Source));
end;

function TSGStaticticsGradientRegression.IterationFunction(var Coeficients : TSGStaticticsLinearCoeficients; var ObjectData : TSGStaticticsObjectData) : TSGFloat64;
var
	i : TSGMaxEnum;
begin
Result := Coeficients[0];
for i := 0 to FCoeficientsLength - 2 do
	Result += Coeficients[i + 1] * ObjectData[FCoeficientsAttributes[i]].Value;
end;

procedure TSGStaticticsGradientRegression.CalculateExcessObjects();
var
	i : TSGMaxEnum;
begin
SetLength(FExcessObjects, Length(Table.Objects));
for i := 0 to High(FExcessObjects) do
	FExcessObjects[i] := not Table.Objects[i].NotExcess(RegressionVariableIndex);
end;

function TSGStaticticsGradientRegression.IterationFunctionSquaderError(var Coeficients : TSGStaticticsLinearCoeficients) : TSGFloat64;
var
	i : TSGMaxEnum;
begin
Result := 0;
for i := 0 to High(Table.Objects) do
	if not FExcessObjects[i] then
		Result += Sqr(IterationFunction(Coeficients, Table.Data[i]) - Table.Data[i][RegressionVariableIndex].Value) / (2 * FDataPower);
Write(Result :0:10);ReadLn();
end;

function TSGStaticticsGradientRegression.CalculateNextCoeficients(const CoeficientsList : TSGStaticticsLinearCoeficientsList) : TSGStaticticsLinearCoeficients;
var
	i, ii : TSGMaxEnum;
begin
SetLength(Result, FCoeficientsLength);
fillchar(Result[0], SizeOf(Result[0]) * FCoeficientsLength, 0);
for i := 0 to FCoeficientsLength - 2 do
	begin
	Result[i + 1] := 0;
	for ii := 0 to High(Table.Objects) do
		if not FExcessObjects[i] then
			Result[i + 1] += (IterationFunction(CoeficientsList[High(CoeficientsList)], Table.Data[ii]) - Table.Data[ii][RegressionVariableIndex].Value) * GradientRegressionAlpha / FDataPower * Table.Data[ii][FCoeficientsAttributes[i]].Value;
	Result[i + 1] := CoeficientsList[High(CoeficientsList)][i + 1] - Result[i + 1];
	end;
OutCoeficientsToFile(Result);
end;

function TSGStaticticsGradientRegression.CalculateStartCoeficients() : TSGStaticticsLinearCoeficients;
var
	i : TSGMaxEnum;
begin
SetLength(Result, FCoeficientsLength);
Result[0] := 0;
for i := 1 to FCoeficientsLength - 1 do
	Result[i] := 1;
end;

procedure TSGStaticticsGradientRegression.InsertNewCoeficients(var CoeficientsList : TSGStaticticsLinearCoeficientsList; const Coeficients : TSGStaticticsLinearCoeficients);

procedure ReplaceOld();
var
	i : TSGMaxEnum;
begin
SetLength(CoeficientsList[0], 0);
for i := 1 to MaxCoeficientsListLength - 1 do
	CoeficientsList[i - 1] := CoeficientsList[i];
CoeficientsList[MaxCoeficientsListLength - 1] := nil;
end;

begin
if Length(CoeficientsList) < MaxCoeficientsListLength then
	SetLength(CoeficientsList, Length(CoeficientsList) + 1)
else
	ReplaceOld();
SetLength(CoeficientsList[High(CoeficientsList)], FCoeficientsLength + 1);
Move(Coeficients[0], CoeficientsList[High(CoeficientsList)][0], (FCoeficientsLength + 1) * SizeOf(CoeficientsList[High(CoeficientsList)][0]));
end;

procedure TSGStaticticsGradientRegression.InsertNewCoeficientsAndClear(var CoeficientsList : TSGStaticticsLinearCoeficientsList; var Coeficients : TSGStaticticsLinearCoeficients; var Error : TSGFloat64);
begin
SetLength(Coeficients, FCoeficientsLength + 1);
Coeficients[FCoeficientsLength] := Error;
InsertNewCoeficients(CoeficientsList, Coeficients);
SetLength(Coeficients, 0);
Error := 0;
end;

procedure TSGStaticticsGradientRegression.RegainGradientRegression();
var
	CoeficientsList : TSGStaticticsLinearCoeficientsList = nil;
	NewCoeficients : TSGStaticticsLinearCoeficients = nil;
	NewCoeficientsSquaderError : TSGFloat64;

procedure ClearCoeficientsData();
var
	i : TSGMaxEnum;
begin
for i := 0 to High(CoeficientsList) do
	SetLength(CoeficientsList[i], 0);
SetLength(CoeficientsList, 0);
SetLength(NewCoeficients, 0);
end;

begin
NewCoeficients := CalculateStartCoeficients();
NewCoeficientsSquaderError := IterationFunctionSquaderError(NewCoeficients);
InsertNewCoeficientsAndClear(CoeficientsList, NewCoeficients, NewCoeficientsSquaderError);
NewCoeficients := CalculateNextCoeficients(CoeficientsList);
NewCoeficientsSquaderError := IterationFunctionSquaderError(NewCoeficients);
InsertNewCoeficientsAndClear(CoeficientsList, NewCoeficients, NewCoeficientsSquaderError);
while Abs(CoeficientsList[High(CoeficientsList)][FCoeficientsLength] - CoeficientsList[High(CoeficientsList) - 1][FCoeficientsLength]) >  GradientRegressionEpsilon do
	begin
	NewCoeficients := CalculateNextCoeficients(CoeficientsList);
	NewCoeficientsSquaderError := IterationFunctionSquaderError(NewCoeficients);
	InsertNewCoeficientsAndClear(CoeficientsList, NewCoeficients, NewCoeficientsSquaderError);
	end;
MoveCoeficients(CoeficientsList[High(CoeficientsList)], FFinalCoeficients, FCoeficientsLength);
ClearCoeficientsData();
end;

procedure TSGStaticticsGradientRegression.RegainRegression();
begin
MarkExcessAttributes();
MarkExcessObjects();
FDataPower := DataPower();
FCoeficientsLength := CalculateCoeficientsLength();
CalculatateCoeficientsAttributes();
CalculateExcessObjects();
RegainGradientRegression();
end;

procedure TSGStaticticsGradientRegression.OutToFile();
begin
OutCoeficientsToFile(FFinalCoeficients);
end;

procedure TSGStaticticsGradientRegression.CalculatateCoeficientsAttributes();
var
	i, ic : TSGMaxEnum;
begin
SetLength(FCoeficientsAttributes, CalculateCoeficientsLength() - 1);
ic := 0;
for i := 0 to High(Table.Attributes) do
	if (i <> RegressionVariableIndex) and Table.Attributes[i].NotExcess(RegressionVariableIndex) then
		begin
		FCoeficientsAttributes[ic] := i;
		ic += 1;
		end;
end;

function TSGStaticticsGradientRegression.CalculateCoeficientsLength() : TSGMaxEnum;
var
	i : TSGMaxEnum;
begin
Result := 1;
for i := 0 to High(Table.Attributes) do
	if (i <> RegressionVariableIndex) and Table.Attributes[i].NotExcess(RegressionVariableIndex) then
		Result += 1;
end;

procedure TSGStaticticsGradientRegression.OutCoeficientsToFile(const Coeficients : TSGStaticticsLinearCoeficients);
var
	f : TextFile;
	i : TSGMaxEnum;
begin
Assign(f, OutputFileName);
Rewrite(f);
WriteLn(f, '"', Table.Attributes[RegressionVariableIndex].Name, '" =');
WriteLn(f, '	', Coeficients[0] :0:10, ' +');
for i := 0 to FCoeficientsLength - 2 do
	WriteLn(f, '	', Coeficients[i + 1] :0:10, ' * "', Table.Attributes[FCoeficientsAttributes[i]].Name, '"', Iff(i <> FCoeficientsLength - 2, ' +'));
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
