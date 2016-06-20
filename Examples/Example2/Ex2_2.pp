{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex2_2;
	interface
{$ELSE}
	program Example2_2;
	{$ENDIF}
uses
	{$IFNDEF ENGINE}
		{$IFDEF UNIX}
			{$IFNDEF ANDROID}
				cthreads,
				{$ENDIF}
			{$ENDIF}
		SaGeBaseExample,
		{$ENDIF}
	SaGeContextInterface
	,SaGeBased
	,SaGeBase
	,SaGeRenderConstants
	,SaGeUtils
	,SaGeCommon
	;
type
	TSGExample2_2=class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FLightAngle : TSGSingle;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample2_2.ClassName():TSGString;
begin
Result := 'Освещение';
end;

constructor TSGExample2_2.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FCamera := TSGCamera.Create();
FCamera.Context := VContext;
FLightAngle := 0;
end;

destructor TSGExample2_2.Destroy();
begin
inherited;
end;

procedure TSGExample2_2.Paint();
var
	Light : TSGVertex3f;
begin
FCamera.CallAction();
Light.Import(cos(FLightAngle),sin(FLightAngle),sin(FLightAngle*2));
Light *= 7;
FLightAngle += Context.ElapsedTime * 0.01;

with Render do
	begin
	Color3f(0,1,0);
	BeginScene(SGR_POINTS);
	Light.Vertex(Render);
	EndScene();
	
	Color3f(1,1,1);
	Enable(SGR_LIGHTING);
	Enable(SGR_LIGHT0);
	Lightfv(SGR_LIGHT0,SGR_POSITION,@Light);
	BeginScene(SGR_QUADS);
	
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
	Disable(SGR_LIGHTING);
	end;
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample2_2;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
