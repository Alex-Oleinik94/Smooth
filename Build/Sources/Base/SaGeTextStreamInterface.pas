{$INCLUDE SaGe.inc}

unit SaGeTextStreamInterface;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	;

type
	ISGTextStream = interface(ISGInterface)
		['{9bf4a36d-9767-4a2e-8a97-6cb95bb1ecef}']
		procedure WriteLn();
		procedure Write(const StringToWrite : TSGString);
		procedure TextColor(const Color : TSGUInt8);
		end;

implementation

end.
