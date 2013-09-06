{$IFDEF SGREADINTERFACE}
const 
	GLFW = 'glfw32.dll';
type
	TSGContextGLFW=class(TSGContext)
			public
		constructor Create;
		destructor Destroy;override;
			public
		procedure Initialize;override;
		procedure Run;override;
		procedure Messages;override;
		procedure SwapBuffers;override;
		function TopShift:LongWord;override;
		function GetCursorPosition:TSGPoint2f;override;
		function GetWindowRect:TSGPoint2f;override;
		function GetScreenResolution:TSGPoint2f;override;
		procedure Resize;override;
		function MouseShift:TSGPoint2f;override;
		class function RectInCoords:Boolean;override;
		procedure InitFullscreen(const b:boolean); override;
			public
		FCursorMoution:TSGPoint2f;
			public
		function GetRC:LongWord;override;
		procedure SetRC(const NewRC:LongWord);override;
		end;


procedure glfwInit();cdecl;external GLFW;

{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

procedure TSGContextGLFW.InitFullscreen(const b:boolean); 
begin

inherited;
end;

function TSGContextGLFW.GetRC:LongWord;
begin

end;

procedure TSGContextGLFW.SetRC(const NewRC:LongWord);
begin

end;

function TSGContextGLFW.MouseShift:TSGPoint2f;
begin
Result.Import(
{$IFDEF MSWINDOWS}
	0,0
{$ELSE}
	0,0
	{$ENDIF}
	);
end;

procedure TSGContextGLFW.Resize;
begin
inherited;
end;

class function TSGContextGLFW.RectInCoords:Boolean;
begin
Result:=False;
end;

constructor TSGContextGLFW.Create;
begin
inherited;
FCursorMoution.Import();
end;

destructor TSGContextGLFW.Destroy;
begin

inherited;
end;

procedure TSGContextGLFW.Initialize;
begin

end;

procedure TSGContextGLFW.Run;
begin

end;

procedure TSGContextGLFW.Messages;
begin
inherited;
end;

procedure TSGContextGLFW.SwapBuffers;
begin

end;

function TSGContextGLFW.TopShift:LongWord;
begin
Result:=0;
end;

function TSGContextGLFW.GetCursorPosition:TSGPoint2f;
begin
Result:=FCursorMoution;
end;

function TSGContextGLFW.GetWindowRect:TSGPoint2f;
begin

end;

function TSGContextGLFW.GetScreenResolution:TSGPoint2f;
begin

end;

{$ENDIF}
