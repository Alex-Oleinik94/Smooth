{$include Includes\SaGe.inc}
unit SaGeRenderOpenGL;
interface
uses
	SaGeBase
	,SaGe
	,SaGeRender
	,gl
	,glu
	,glext
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,Dl
		,x
		,xlib
		,xutil
		,glx
		{$ENDIF}
	,DynLibs
	;
type
	TSGRenderOpenGL=class(TSGRender)
			protected
		FContext:
		{$IFDEF UNIX}
			 GLXContext;
		{$ELSE}
			{$IFDEF MSWINDOWS}
				HGLRC;
			{$ELSE}
				{$ENDIF}
			 {$ENDIF}
			public
		procedure CreateContext();override;
		procedure MakeCurrent();override;
			public
		procedure Vertex3f(const x,y,z:single);override;
		end;

implementation

procedure TSGRenderOpenGL.Vertex3f(const x,y,z:single);
begin
glVertex3f(x,y,z);
end;

procedure TSGRenderOpenGL.CreateContext();
{$IFDEF UNIX}
	var
		FDisplay:PDisplay;
	{$ENDIF}
begin
{$IFDEF UNIX}
	FDisplay:=XOpenDisplay(nil);
	
	{$ENDIF}
{$IFDEF MSWINDOWS}
	FContext:=wglCreateContext(FWindow);
	{$ENDIF}
MakeCurrent();
end;

procedure TSGRenderOpenGL.MakeCurrent();
begin
{$IFDEF UNIX}
	if (FWindow<>0) and (FContext<>nil) then 
		glXMakeCurrent(XOpenDisplay(nil),FWindow,FContext);
	{$ENDIF}
{$IFDEF MSWINDOWS}
	if (FWindow<>0) and (FContext<>0) then 
		wglMakeCurrent( FWindow, FContext );
	{$ENDIF}
end;

end.
