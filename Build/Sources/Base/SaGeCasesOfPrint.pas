{$INCLUDE SaGe.inc}

unit SaGeCasesOfPrint;

interface

type
	// CasesOfPrint
	TSGCaseOfPrint = (
		SGCasePrint,
		SGCaseLog);
	TSGCasesOfPrint = set of TSGCaseOfPrint;
const
	SGCasesOfPrintFull  : TSGCasesOfPrint = [SGCasePrint, SGCaseLog];
	SGCasesOfPrintPrint : TSGCasesOfPrint = [SGCasePrint];
	SGCasesOfPrintLog   : TSGCasesOfPrint = [SGCaseLog];
	SGCasesOfPrintNULL  = [];
	SGCasesOfPrintEmpty = SGCasesOfPrintNULL;
implementation

end.
