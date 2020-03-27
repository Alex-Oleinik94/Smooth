{$INCLUDE Smooth.inc}

unit SmoothPascalFileReader;

interface

uses
	 SmoothBase
	,SmoothCodeFileReader
	;

type
	TSPascalFileReader = class(TSCodeFileReader)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		end;

implementation

constructor TSPascalFileReader.Create();
begin
inherited;
end;

destructor TSPascalFileReader.Destroy();
begin
inherited;
end;

end.
