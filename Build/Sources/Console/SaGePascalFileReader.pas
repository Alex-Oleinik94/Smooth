{$INCLUDE SaGe.inc}

unit SaGePascalFileReader;

interface

uses
	 SaGeBase
	,SaGeCodeFileReader
	;

type
	TSGPascalFileReader = class(TSGCodeFileReader)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		end;

implementation

constructor TSGPascalFileReader.Create();
begin
inherited;
end;

destructor TSGPascalFileReader.Destroy();
begin
inherited;
end;

end.
