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
begin
Result := SGParseValueFromComandAndReturn(Comand, ['out_regression:'], RegressionFileName);
end;

function ProccessRegressionVariable(const Comand : TSGString):TSGBool;
begin
Result := SGParseValueFromComandAndReturn(Comand, ['regression_variable:'], RegressionVariableName);
if Result then
	RegressionVariableName := SGConvertString(RegressionVariableName, SGEncodingWin1251);
end;

function ProccessTypesExport(const Comand : TSGString):TSGBool;
begin
Result := SGParseValueFromComandAndReturn(Comand, ['out_types:'], TypesFileName);
end;

function ProccessCorrelationExport(const Comand : TSGString):TSGBool;
begin
Result := SGParseValueFromComandAndReturn(Comand, ['out_correlation:'], CorrelationFileName);
end;

function ProccessImporting(const Comand : TSGString):TSGBool;
begin
Result := SGParseValueFromComandAndReturn(Comand, ['input:'], ImportFile);
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
			OutToFile();
			end;
		Destroy();
		end;
	end;
end;

initialization
begin
SGGeneralConsoleCaller().AddComand(@SGConcoleRunStatistics, ['statistics'], 'Statictics');
end;

end.
