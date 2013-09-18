{$include Includes\SaGe.inc}

unit SaGeRender;

interface
uses 
	SaGeBase;
type
	TSGRender=class
			public
		constructor Create;virtual;
		destructor Destroy;override;
			protected
		FWindow:LongWord;
			public
		procedure MakeCurrent();virtual;abstract;
		procedure CreateContext();virtual;abstract;
			public
		procedure Vertex3f(const x,y,z:single);virtual;abstract;
			public
		property Window:LongWord read FWindow write FWindow;
		end;

implementation

constructor TSGRender.Create;
begin
FWindow:=0;
end;

destructor TSGRender.Destroy;
begin
inherited;
end;

end.
