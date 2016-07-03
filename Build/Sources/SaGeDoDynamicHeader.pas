{$INCLUDE SaGe.inc}

unit SaGeDoDynamicHeader;

interface

uses
	 SaGeBased
	,SaGeBase
	,Classes
	;

type
	TSGDoDynamicHeader = class
			public
		constructor Create(const VFileName, VOutFileName : TSGString);
		destructor Destroy();override;
		procedure PrintErrors();
		procedure Execute();
			private
		FInFileName, FOutFileName : TSGString;
		FInStream, FOutStream : TMemoryStream;
		end;

implementation

constructor TSGDoDynamicHeader.Create(const VFileName, VOutFileName : TSGString);
begin
FInFileName := VFileName;
FOutFileName := VOutFileName;
end;

destructor TSGDoDynamicHeader.Destroy();
begin
inherited;
end;

procedure TSGDoDynamicHeader.PrintErrors();
begin

end;

procedure TSGDoDynamicHeader.Execute();
begin

end;

end.
