{$INCLUDE SaGe.inc}
program Example2;
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeRender
	,SaGeBaseExample
	,SaGeUtils
	,SaGeCommon
	;
type
	TSGExample=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FLightAngle : TSGSingle;
		end;

class function TSGExample.ClassName():TSGString;
begin
Result := '';
end;

constructor TSGExample.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FCamera := TSGCamera.Create();
FCamera.Context := VContext;
FLightAngle := 0;
end;

destructor TSGExample.Destroy();
begin
inherited;
end;

procedure TSGExample.Draw();
var
	Light : TSGVertex3f;
begin
FCamera.CallAction();
Light.Import(cos(FLightAngle),sin(FLightAngle),sin(FLightAngle*2));
Light *= 7;
FLightAngle += Context.ElapsedTime * 0.01;
with Render do
	begin
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

begin
ExampleClass := TSGExample;
RunApplication();
end.
