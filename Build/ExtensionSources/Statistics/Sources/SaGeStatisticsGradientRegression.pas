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
	//GradientRegressionEpsilon = 0.05;
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
		FNegativeDoubleDataPower : TSGFloat64;
		FNegativeDataPower : TSGFloat64;
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
		function IterationFunctionPartialOffset(var Coeficients : TSGStaticticsLinearCoeficients; var ObjectData : TSGStaticticsObjectData; const Coeficient : TSGMaxEnum; const Offset : TSGFloat64) : TSGFloat64;
		function IterationFunctionSquaderErrorPartialOffset(var Coeficients : TSGStaticticsLinearCoeficients; const Coeficient : TSGMaxEnum; const Offset : TSGFloat64) : TSGFloat64;
		procedure RegainGradientRegression();
		procedure CalculateExcessObjects();
			private
		function CalculateNextCoeficients(const CoeficientsList : TSGStaticticsLinearCoeficientsList; const ExternalCoeficientsLength : TSGMaxEnum = 0) : TSGStaticticsLinearCoeficients;
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
	,SaGeMathUtils
	,SaGeStringUtils
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

function TSGStaticticsGradientRegression.IterationFunctionPartialOffset(var Coeficients : TSGStaticticsLinearCoeficients; var ObjectData : TSGStaticticsObjectData; const Coeficient : TSGMaxEnum; const Offset : TSGFloat64) : TSGFloat64;
var
	i : TSGMaxEnum;
begin
Result := Coeficients[0];
for i := 0 to FCoeficientsLength - 2 do
	if i = Coeficient then
		Result += (Coeficients[i + 1] + Offset) * ObjectData[FCoeficientsAttributes[i]].Value
	else
		Result += Coeficients[i + 1] * ObjectData[FCoeficientsAttributes[i]].Value;
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

function TSGStaticticsGradientRegression.IterationFunctionSquaderErrorPartialOffset(var Coeficients : TSGStaticticsLinearCoeficients; const Coeficient : TSGMaxEnum; const Offset : TSGFloat64) : TSGFloat64;
var
	i : TSGMaxEnum;
begin
Result := 0;
for i := 0 to High(Table.Objects) do
	if not FExcessObjects[i] then
		Result += Sqr(IterationFunctionPartialOffset(Coeficients, Table.Data[i], Coeficient, Offset) - Table.Data[i][RegressionVariableIndex].Value) * FNegativeDoubleDataPower;
end;

function TSGStaticticsGradientRegression.IterationFunctionSquaderError(var Coeficients : TSGStaticticsLinearCoeficients) : TSGFloat64;
var
	i : TSGMaxEnum;
begin
Result := 0;
for i := 0 to High(Table.Objects) do
	if not FExcessObjects[i] then
		Result += Sqr(IterationFunction(Coeficients, Table.Data[i]) - Table.Data[i][RegressionVariableIndex].Value) * FNegativeDoubleDataPower;
end;

function TSGStaticticsGradientRegression.CalculateNextCoeficients(const CoeficientsList : TSGStaticticsLinearCoeficientsList; const ExternalCoeficientsLength : TSGMaxEnum = 0) : TSGStaticticsLinearCoeficients;
var
	i, ii, j : TSGMaxEnum;
	Offset, SquaredOffsetError: TSGFloat64;
	CoeficientShiftTrue : TSGBool;
begin
SetLength(Result, FCoeficientsLength);
fillchar(Result[0], SizeOf(Result[0]) * FCoeficientsLength, 0);
for i := 0 to Iff((ExternalCoeficientsLength = 0) or (FCoeficientsLength < ExternalCoeficientsLength), FCoeficientsLength - 1, ExternalCoeficientsLength - 1) do
	begin
	CoeficientShiftTrue := False;
	j := 0;
	repeat
	j += 1;
	Offset := Iff(Random(2) = 0, 1, -1) * ((15.0 ** TSGFloat64(j - 1)) / 15);
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

function TSGStaticticsGradientRegression.CalculateStartCoeficients() : TSGStaticticsLinearCoeficients;
var
	i : TSGMaxEnum;
	AllCorr : TSGFloat64 = 0;
	A, B, C : TSGFloat64;
begin
SetLength(Result, FCoeficientsLength);
fillchar(Result[0], FCoeficientsLength * SizeOf(Result[0]), 0);
for i := 0 to FCoeficientsLength - 2 do
	AllCorr += Abs(TSGFloat32(Table.Attributes[FCoeficientsAttributes[i]].GetProperty('CORR_' + SGStr(RegressionVariableIndex))));
for i := 0 to FCoeficientsLength - 2 do
	begin
	Table.CalculateLinearRegression(FCoeficientsAttributes[i], RegressionVariableIndex, A, B);
	C := Abs(TSGFloat32(Table.Attributes[FCoeficientsAttributes[i]].GetProperty('CORR_' + SGStr(RegressionVariableIndex)))) / AllCorr;
	Result[0] += B / C;
	Result[i + 1] += A / C;
	end;
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
	IterationCount : TSGMaxEnum = 1;
	
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
while Abs(CoeficientsList[High(CoeficientsList)][FCoeficientsLength]) < Abs(CoeficientsList[High(CoeficientsList) - 1][FCoeficientsLength]) do
	begin
	NewCoeficients := CalculateNextCoeficients(CoeficientsList);
	NewCoeficientsSquaderError := IterationFunctionSquaderError(NewCoeficients);
	InsertNewCoeficientsAndClear(CoeficientsList, NewCoeficients, NewCoeficientsSquaderError);
	IterationCount += 1;
	end;
MoveCoeficients(CoeficientsList[High(CoeficientsList)], FFinalCoeficients, FCoeficientsLength);
ClearCoeficientsData();
SGHint(['Statistica : Iteration count = ', IterationCount, '.']);
end;

procedure TSGStaticticsGradientRegression.RegainRegression();
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