{$INCLUDE SaGe.inc}

// =====================================
// PCap Next Generation Dump File Format
// =====================================
// CaptureFileFormat
unit SaGePCapNG;

interface

uses
	 SaGeBase
	,SaGeClasses
	
	,Classes
	;
type
	TSGPCapNGDefaultNumber    = TSGUInt32;
	TSGPCapNGBlockType        = TSGPCapNGDefaultNumber;
	TSGPCapNGBlockTotalLength = TSGPCapNGDefaultNumber;
	
	TSGPCapNGFile = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FFileName : TSGString;
			public
		property FileName : TSGString read FFileName write FFileName;
			public
		
		end;

implementation

constructor TSGPCapNGFile.Create();
begin
inherited;
end;

destructor TSGPCapNGFile.Destroy();
begin
inherited;
end;

end.
