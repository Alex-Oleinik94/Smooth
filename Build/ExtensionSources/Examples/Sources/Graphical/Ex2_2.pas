{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex2_2;
	interface
{$ELSE}
	program Example2_2;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothRenderBase
	,SmoothFont
	,SmoothCommonStructs
	,SmoothCamera
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	;
type
	TSExample2_2=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FCamera : TSCamera;
		FLightAngle : TSSingle;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample2_2.ClassName():TSString;
begin
Result := 'Куб и источник света';
end;

constructor TSExample2_2.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FCamera := TSCamera.Create();
FCamera.Context := VContext;
FLightAngle := 0;
end;

destructor TSExample2_2.Destroy();
begin
inherited;
end;

procedure TSExample2_2.Paint();
var
	Light : TSVertex3f;
begin
FCamera.CallAction();
Light.Import(cos(FLightAngle),sin(FLightAngle),sin(FLightAngle*2));
Light *= 7;
FLightAngle += Context.ElapsedTime * 0.01;

with Render do
	begin
	Color3f(0,1,0);
	BeginScene(SR_POINTS);
	Render.Vertex(Light);
	EndScene();
	
	Color3f(1,1,1);
	Enable(SR_LIGHTING);
	Enable(SR_LIGHT0);
	Lightfv(SR_LIGHT0,SR_POSITION,@Light);
	BeginScene(SR_QUADS);
	
	Normal3f(1,0,0);
	Vertex3f(1,1,1);
	Vertex3f(1,1,-1);
	Vertex3f(1,-1,-1);
	Vertex3f(1,-1,1);
	
	Normal3f(0,0,1);
	Vertex3f(-1,1,1);
	Vertex3f(-1,-1,1);
	Vertex3f(1,-1,1);
	Vertex3f(1,1,1);
	
	Normal3f(0,1,0);
	Vertex3f(-1,1,1);
	Vertex3f(-1,1,-1);
	Vertex3f(1,1,-1);
	Vertex3f(1,1,1);
	
	Normal3f(-1,0,0);
	Vertex3f(-1,1,1);
	Vertex3f(-1,1,-1);
	Vertex3f(-1,-1,-1);
	Vertex3f(-1,-1,1);

	Normal3f(0,0,-1);
	Vertex3f(-1,1,-1);
	Vertex3f(-1,-1,-1);
	Vertex3f(1,-1,-1);
	Vertex3f(1,1,-1);
	
	Normal3f(0,-1,0);
	Vertex3f(-1,-1,1);
	Vertex3f(-1,-1,-1);
	Vertex3f(1,-1,-1);
	Vertex3f(1,-1,1);
	
	EndScene();
	Disable(SR_LIGHTING);
	end;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample2_2, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
