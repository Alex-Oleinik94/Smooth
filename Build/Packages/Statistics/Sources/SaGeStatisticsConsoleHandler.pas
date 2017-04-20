{$INCLUDE SaGe.inc}

unit SaGeStatisticsConsoleHandler;

interface

implementation

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	,SaGeConsoleTools
	,SaGeLog
	,SaGeEncodingUtils
	
	,SaGeStatisticsTable
	,SaGeStatisticsRegression
	,SaGeStatisticsGradientRegression
	;

procedure SGConcoleRunStatistics(const VParams : TSGConcoleCallerParams = nil);
var
	ImportFile          : TSGString = '';
	CorrelationFileName : TSGString = '';
	TypesFileName       : TSGString = '';
	RegressionVariableName  : TSGString = '';
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
	RegressionVariableName := SGConvertString(Value, SGEncodingWin1251);
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
	with TSGStaticticsGradientRegression.Create() do
		begin
		Table.Import(ImportFile);
		Table.CalculationOfTypes();
		if TypesFileName <> '' then
			Table.ExportTypesInfo(TypesFileName);
		Table.CalculationOfCorrelation();
		if CorrelationFileName <> '' then
			Table.CorrelationExport(CorrelationFileName);
		if RegressionVariableName <> '' then
			begin
			RegressionVariable := RegressionVariableName;
			OutputFileName := RegressionFileName;
			RegainRegression();
			end;
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
