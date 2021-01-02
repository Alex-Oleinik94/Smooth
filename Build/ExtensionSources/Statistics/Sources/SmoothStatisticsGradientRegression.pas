//DEPRECATED

{$INCLUDE Smooth.inc}

unit SmoothStatisticsGradientRegression;

interface

uses
	 SmoothBase
	,SmoothVersion
	
	,SmoothStatisticsStudentiz
	,SmoothStatisticsBase
	,SmoothStatisticsTable
	,SmoothStatisticsRegression
	;

const
	MaxCoeficientsListLength = 2; // >= 2
	//GradientRegressionEpsilon = 0.05;
	GradientRegressionAlpha = 0.01;
type
	TSStaticticsLinearCoeficients = TSFloat64List;
	TSStaticticsLinearCoeficientsList = packed array of TSStaticticsLinearCoeficients;
	
	TSStaticticsGradientRegression = class(TSStaticticsRegression)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			private
		FDataPower : TSMaxEnum;
		FNegativeDoubleDataPower : TSFloat64;
		FNegativeDataPower : TSFloat64;
		FFinalCoeficients : TSStaticticsLinearCoeficients;
		FCoeficientsLength : TSMaxEnum;
		FCoeficientsAttributes : TSUInt32List;
		FExcessObjects : TSBooleanList;
			private
		function CalculateCoeficientsLength() : TSMaxEnum;
		procedure CalculatateCoeficientsAttributes();
		class procedure MoveCoeficients(const Source : TSStaticticsLinearCoeficients; var Destination : TSStaticticsLinearCoeficients);overload;
		class procedure MoveCoeficients(const Source : TSStaticticsLinearCoeficients; var Destination : TSStaticticsLinearCoeficients; const DestinationLength : TSMaxEnum); overload;
		procedure OutCoeficientsToFile(const Coeficients : TSStaticticsLinearCoeficients);
		function IterationFunction(var Coeficients : TSFloat64List; var ObjectData : TSStaticticsObjectData) : TSFloat64;
		function IterationFunctionSquaderError(var Coeficients : TSStaticticsLinearCoeficients) : TSFloat64;
		function IterationFunctionPartialOffset(var Coeficients : TSStaticticsLinearCoeficients; var ObjectData : TSStaticticsObjectData; const Coeficient : TSMaxEnum; const Offset : TSFloat64) : TSFloat64;
		function IterationFunctionSquaderErrorPartialOffset(var Coeficients : TSStaticticsLinearCoeficients; const Coeficient : TSMaxEnum; const Offset : TSFloat64) : TSFloat64;
		procedure RegainGradientRegression();
		procedure CalculateExcessObjects();
			private
		function CalculateNextCoeficients(const CoeficientsList : TSStaticticsLinearCoeficientsList; const ExternalCoeficientsLength : TSMaxEnum = 0) : TSStaticticsLinearCoeficients;
		function CalculateStartCoeficients() : TSStaticticsLinearCoeficients;
		procedure InsertNewCoeficients(var CoeficientsList : TSStaticticsLinearCoeficientsList; const Coeficients : TSStaticticsLinearCoeficients);
		procedure InsertNewCoeficientsAndClear(var CoeficientsList : TSStaticticsLinearCoeficientsList; var Coeficients : TSStaticticsLinearCoeficients; var Error : TSFloat64);
			public
		procedure Clear(); override;
		procedure RegainRegression(); override;
		procedure OutToFile(); override;
		end;

implementation

uses
	 SmoothLog
	,SmoothDateTime
	,SmoothBaseUtils
	,SmoothMathUtils
	,SmoothStringUtils
	;

class procedure TSStaticticsGradientRegression.MoveCoeficients(const Source : TSStaticticsLinearCoeficients; var Destination : TSStaticticsLinearCoeficients; const DestinationLength : TSMaxEnum); overload;
var
	i : TSMaxEnum;
begin
SetLength(Destination, DestinationLength);
for i := 0 to DestinationLength - 1 do
	Destination[i] := Source[i];
end;

class procedure TSStaticticsGradientRegression.MoveCoeficients(const Source : TSStaticticsLinearCoeficients; var Destination : TSStaticticsLinearCoeficients); overload;
begin
MoveCoeficients(Source, Destination, Length(Source));
end;

function TSStaticticsGradientRegression.IterationFunctionPartialOffset(var Coeficients : TSStaticticsLinearCoeficients; var ObjectData : TSStaticticsObjectData; const Coeficient : TSMaxEnum; const Offset : TSFloat64) : TSFloat64;
var
	i : TSMaxEnum;
begin
Result := Coeficients[0];
for i := 0 to FCoeficientsLength - 2 do
	if i = Coeficient then
		Result += (Coeficients[i + 1] + Offset) * ObjectData[FCoeficientsAttributes[i]].Value
	else
		Result += Coeficients[i + 1] * ObjectData[FCoeficientsAttributes[i]].Value;
end;

function TSStaticticsGradientRegression.IterationFunction(var Coeficients : TSStaticticsLinearCoeficients; var ObjectData : TSStaticticsObjectData) : TSFloat64;
var
	i : TSMaxEnum;
begin
Result := Coeficients[0];
for i := 0 to FCoeficientsLength - 2 do
	Result += Coeficients[i + 1] * ObjectData[FCoeficientsAttributes[i]].Value;
end;

procedure TSStaticticsGradientRegression.CalculateExcessObjects();
var
	i : TSMaxEnum;
begin
SetLength(FExcessObjects, Length(Table.Objects));
for i := 0 to High(FExcessObjects) do
	FExcessObjects[i] := not Table.Objects[i].NotExcess(RegressionVariableIndex);
end;

function TSStaticticsGradientRegression.IterationFunctionSquaderErrorPartialOffset(var Coeficients : TSStaticticsLinearCoeficients; const Coeficient : TSMaxEnum; const Offset : TSFloat64) : TSFloat64;
var
	i : TSMaxEnum;
begin
Result := 0;
for i := 0 to High(Table.Objects) do
	if not FExcessObjects[i] then
		Result += Sqr(IterationFunctionPartialOffset(Coeficients, Table.Data[i], Coeficient, Offset) - Table.Data[i][RegressionVariableIndex].Value) * FNegativeDoubleDataPower;
end;

function TSStaticticsGradientRegression.IterationFunctionSquaderError(var Coeficients : TSStaticticsLinearCoeficients) : TSFloat64;
var
	i : TSMaxEnum;
begin
Result := 0;
for i := 0 to High(Table.Objects) do
	if not FExcessObjects[i] then
		Result += Sqr(IterationFunction(Coeficients, Table.Data[i]) - Table.Data[i][RegressionVariableIndex].Value) * FNegativeDoubleDataPower;
end;

function TSStaticticsGradientRegression.CalculateNextCoeficients(const CoeficientsList : TSStaticticsLinearCoeficientsList; const ExternalCoeficientsLength : TSMaxEnum = 0) : TSStaticticsLinearCoeficients;
var
	i, ii, j : TSMaxEnum;
	Offset, SquaredOffsetError: TSFloat64;
	CoeficientShiftTrue : TSBool;
begin
SetLength(Result, FCoeficientsLength);
fillchar(Result[0], SizeOf(Result[0]) * FCoeficientsLength, 0);
for i := 0 to Iff((ExternalCoeficientsLength = 0) or (FCoeficientsLength < ExternalCoeficientsLength), FCoeficientsLength - 1, ExternalCoeficientsLength - 1) do
	begin
	CoeficientShiftTrue := False;
	j := 0;
	repeat
	j += 1;
	Offset := Iff(Random(2) = 0, 1, -1) * ((15.0 ** TSFloat64(j - 1)) / 15);
	SquaredOffsetError := IterationFunctionSquaderErrorPartialOffset(CoeficientsList[High(CoeficientsList)], i, Offset);
	CoeficientShiftTrue := SquaredOffsetError <> CoeficientsList[High(CoeficientsList)][FCoeficientsLength];
	until CoeficientShiftTrue or (j > 4);
	
	{WriteLn(i);
	WriteLn(CoeficientShiftTrue);
	Writeln(SquaredOffsetError:0:10);
	Writeln(CoeficientsList[High(CoeficientsList)][FCoeficientsLength]:0:10);
	WriteLn(Offset:0:10);
	WriteLn(CoeficientsList[High(CoeficientsList)][i]:0:10);}
	
	if CoeficientShiftTrue then
		Result[i] := 
			Iff(
				SquaredOffsetError < CoeficientsList[High(CoeficientsList)][FCoeficientsLength],
				Offset, -Offset) +
			CoeficientsList[High(CoeficientsList)][i]
	else
		Result[i] := CoeficientsList[High(CoeficientsList)][i];
	
	{Offset := Result[i];
	WriteLn(Result[i]:0:10);
	ReadLn();}
	end;
end;

function TSStaticticsGradientRegression.CalculateStartCoeficients() : TSStaticticsLinearCoeficients;
var
	i : TSMaxEnum;
	AllCorr : TSFloat64 = 0;
	A, B, C : TSFloat64;
begin
SetLength(Result, FCoeficientsLength);
fillchar(Result[0], FCoeficientsLength * SizeOf(Result[0]), 0);
for i := 0 to FCoeficientsLength - 2 do
	AllCorr += Abs(TSFloat32(Table.Attributes[FCoeficientsAttributes[i]].GetProperty('CORR_' + SStr(RegressionVariableIndex))));
for i := 0 to FCoeficientsLength - 2 do
	begin
	Table.CalculateLinearRegression(FCoeficientsAttributes[i], RegressionVariableIndex, A, B);
	C := Abs(TSFloat32(Table.Attributes[FCoeficientsAttributes[i]].GetProperty('CORR_' + SStr(RegressionVariableIndex)))) / AllCorr;
	Result[0] += B / C;
	Result[i + 1] += A / C;
	end;
end;

procedure TSStaticticsGradientRegression.InsertNewCoeficients(var CoeficientsList : TSStaticticsLinearCoeficientsList; const Coeficients : TSStaticticsLinearCoeficients);

procedure ReplaceOld();
var
	i : TSMaxEnum;
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

procedure TSStaticticsGradientRegression.InsertNewCoeficientsAndClear(var CoeficientsList : TSStaticticsLinearCoeficientsList; var Coeficients : TSStaticticsLinearCoeficients; var Error : TSFloat64);
begin
SetLength(Coeficients, FCoeficientsLength + 1);
Coeficients[FCoeficientsLength] := Error;
InsertNewCoeficients(CoeficientsList, Coeficients);
SetLength(Coeficients, 0);
Error := 0;
end;

procedure TSStaticticsGradientRegression.RegainGradientRegression();
var
	CoeficientsList : TSStaticticsLinearCoeficientsList = nil;
	NewCoeficients : TSStaticticsLinearCoeficients = nil;
	NewCoeficientsSquaderError : TSFloat64;
	IterationCount : TSMaxEnum = 1;
	
procedure ClearCoeficientsData();
var
	i : TSMaxEnum;
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
while Abs(CoeficientsList[High(CoeficientsList)][FCoeficientsLength]) < Abs(CoeficientsList[High(CoeficientsList) - 1][FCoeficientsLength]) do
	begin
	NewCoeficients := CalculateNextCoeficients(CoeficientsList);
	NewCoeficientsSquaderError := IterationFunctionSquaderError(NewCoeficients);
	InsertNewCoeficientsAndClear(CoeficientsList, NewCoeficients, NewCoeficientsSquaderError);
	IterationCount += 1;
	end;
MoveCoeficients(CoeficientsList[High(CoeficientsList)], FFinalCoeficients, FCoeficientsLength);
ClearCoeficientsData();
SHint(['Statistica : Iteration count = ', IterationCount, '.']);
end;

procedure TSStaticticsGradientRegression.RegainRegression();
begin
MarkExcessAttributes();
MarkExcessObjects();
FDataPower := DataPower();
FNegativeDoubleDataPower := 1 / (2 * FDataPower);
FNegativeDataPower := 1 / FDataPower;
FCoeficientsLength := CalculateCoeficientsLength();
CalculatateCoeficientsAttributes();
CalculateExcessObjects();
RegainGradientRegression();
end;

procedure TSStaticticsGradientRegression.OutToFile();
begin
OutCoeficientsToFile(FFinalCoeficients);
end;

procedure TSStaticticsGradientRegression.CalculatateCoeficientsAttributes();
var
	i, ic : TSMaxEnum;
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

function TSStaticticsGradientRegression.CalculateCoeficientsLength() : TSMaxEnum;
var
	i : TSMaxEnum;
begin
Result := 1;
for i := 0 to High(Table.Attributes) do
	if (i <> RegressionVariableIndex) and Table.Attributes[i].NotExcess(RegressionVariableIndex) then
		Result += 1;
end;

procedure TSStaticticsGradientRegression.OutCoeficientsToFile(const Coeficients : TSStaticticsLinearCoeficients);
var
	f : TextFile;
	i : TSMaxEnum;
begin
Assign(f, OutputFileName);
Rewrite(f);
WriteLn(f, '"', Table.Attributes[RegressionVariableIndex].Name, '" =');
WriteLn(f, '	', Coeficients[0] :0:10, ' +');
for i := 0 to FCoeficientsLength - 2 do
	WriteLn(f, '	', Coeficients[i + 1] :0:10, ' * "', Table.Attributes[FCoeficientsAttributes[i]].Name, '"', Iff(i <> FCoeficientsLength - 2, ' +'));
Close(f);
end;

constructor TSStaticticsGradientRegression.Create();
begin
inherited;
end;

procedure TSStaticticsGradientRegression.Clear();
begin

end;

destructor TSStaticticsGradientRegression.Destroy();
begin
Clear();
inherited;
end;

class function TSStaticticsGradientRegression.ClassName() : TSString;
begin
Result := 'TSStaticticsGradientRegression';
end;

end.
