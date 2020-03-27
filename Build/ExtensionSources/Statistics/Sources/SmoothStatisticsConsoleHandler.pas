{$INCLUDE Smooth.inc}

unit SmoothStatisticsConsoleHandler;

interface

implementation

uses
	 SmoothBase
	,SmoothConsoleToolsBase
	,SmoothConsoleTools
	,SmoothLog
	,SmoothEncodingUtils
	
	,SmoothStatisticsTable
	,SmoothStatisticsRegression
	,SmoothStatisticsGradientRegression
	;

procedure SConcoleRunStatistics(const VParams : TSConcoleCallerParams = nil);
var
	ImportFile          : TSString = '';
	CorrelationFileName : TSString = '';
	TypesFileName       : TSString = '';
	RegressionVariableName  : TSString = '';
	RegressionFileName  : TSString = '';

function ProccessRegressionExport(const Comand : TSString):TSBool;
begin
Result := SParseValueFromComandAndReturn(Comand, ['out_regression:'], RegressionFileName);
end;

function ProccessRegressionVariable(const Comand : TSString):TSBool;
begin
Result := SParseValueFromComandAndReturn(Comand, ['regression_variable:'], RegressionVariableName);
if Result then
	RegressionVariableName := SConvertString(RegressionVariableName, SEncodingWin1251);
end;

function ProccessTypesExport(const Comand : TSString):TSBool;
begin
Result := SParseValueFromComandAndReturn(Comand, ['out_types:'], TypesFileName);
end;

function ProccessCorrelationExport(const Comand : TSString):TSBool;
begin
Result := SParseValueFromComandAndReturn(Comand, ['out_correlation:'], CorrelationFileName);
end;

function ProccessImporting(const Comand : TSString):TSBool;
begin
Result := SParseValueFromComandAndReturn(Comand, ['input:'], ImportFile);
end;

var
	Success : TSBool = True;
begin
with TSConsoleCaller.Create(VParams) do
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
	with TSStaticticsGradientRegression.Create() do
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
SGeneralConsoleCaller().AddComand(@SConcoleRunStatistics, ['statistics'], 'Statictics');
end;

end.
