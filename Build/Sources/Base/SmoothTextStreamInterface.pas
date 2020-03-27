{$INCLUDE Smooth.inc}

unit SmoothTextStreamInterface;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	;

type
	ISTextStream = interface(ISInterface)
		['{9bf4a36d-9767-4a2e-8a97-6cb95bb1ecef}']
		procedure WriteLn();
		procedure Write(const StringToWrite : TSString);
		procedure TextColor(const Color : TSUInt8);
		end;

implementation

end.
