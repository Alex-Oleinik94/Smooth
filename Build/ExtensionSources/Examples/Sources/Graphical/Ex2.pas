{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex2;
	interface
{$ELSE}
	program Example2;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothBase
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothRenderBase
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	;
type
	TSExample2=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FAngle : TSSingle;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample2.ClassName():TSString;
begin
Result := 'Два разноцветных треугольника';
end;

constructor TSExample2.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FAngle:=0;
end;

destructor TSExample2.Destroy();
begin
inherited;
end;

procedure TSExample2.Paint();
begin
Render.InitMatrixMode(S_3D);
Render.Translatef(2,0,-6);
Render.Rotatef(FAngle,0,0,1);
Render.BeginScene(SR_TRIANGLES);
Render.Color3f(1,0,0);
Render.Vertex2f(1,0);
Render.Color3f(0,1,0);
Render.Vertex2f(0,-1);
Render.Color3f(0,0,1);
Render.Vertex2f(0,1);
Render.EndScene();

Render.InitMatrixMode(S_2D);
Render.Translatef(Context.Width/2-Context.Width/4,Context.Height/2,0);
Render.Rotatef(FAngle,0,0,1);
Render.BeginScene(SR_TRIANGLES);
Render.Color3f(0,1,1);
Render.Vertex2f(Context.Height/3,0);
Render.Color3f(1,0,1);
Render.Vertex2f(0,-Context.Height/3);
Render.Color3f(1,1,0);
Render.Vertex2f(0,Context.Height/3);
Render.EndScene();

FAngle += Context.ElapsedTime ;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample2, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
