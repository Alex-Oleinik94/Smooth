{$include SaGe.inc}

unit SaGeRender;

interface

type
	TSGRender=class
			protected
		FWindow:LongWord;
			public
		procedure CreateContext();virtual;abstract;
		procedure Vertex3f(const x,y,z:single);virtual;abstract;
			public
		property Window:LongWord read FWindow write FWindow;
		end;
	
	TSGRenderOpenGL=class(TSGRender)
			public
		procedure Vertex3f(const x,y,z:single);override;
		end;

implementation

procedure TSGRenderOpenGL.Vertex3f(const x,y,z:single);
begin
glVertex3f(x,y,z);
end;

end.
