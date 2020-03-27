{$INCLUDE Smooth.inc}

unit SmoothCasesOfPrint;

interface

type
	// CasesOfPrint
	TSCaseOfPrint = (
		SCasePrint,
		SCaseLog);
	TSCasesOfPrint = set of TSCaseOfPrint;
const
	SCasesOfPrintFull  : TSCasesOfPrint = [SCasePrint, SCaseLog];
	SCasesOfPrintPrint : TSCasesOfPrint = [SCasePrint];
	SCasesOfPrintLog   : TSCasesOfPrint = [SCaseLog];
	SCasesOfPrintNULL  = [];
	SCasesOfPrintEmpty = SCasesOfPrintNULL;
implementation

end.
