{$INCLUDE SaGe.inc}
program Example3;
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
	,SaGeScreen
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
		end;

class function TSGExample.ClassName():TSGString;
begin
Result := 'Кубики и текстура шрифта вместе с камерой';
end;

constructor TSGExample.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
end;

destructor TSGExample.Destroy();
begin
inherited;
end;

procedure TSGExample.Draw();

procedure DrawCube(const x,y,z,r,a: Single);
begin
with Render do
	begin
	BeginScene(SGR_QUADS);
	Color4f(1,0,0,a);
	Vertex3f(x-r,y-r,z-r);
	Vertex3f(x+r,y-r,z-r);
	Vertex3f(x+r,y+r,z-r);
	Vertex3f(x-r,y+r,z-r);
	Color4f(0,1,0,a);
	Vertex3f(x-r,y-r,z-r);
	Vertex3f(x+r,y-r,z-r);
	Vertex3f(x+r,y-r,z+r);
	Vertex3f(x-r,y-r,z+r);
	Color4f(0,0,1,a);
	Vertex3f(x+r,y+r,z+r);
	Vertex3f(x+r,y+r,z-r);
	Vertex3f(x+r,y-r,z-r);
	Vertex3f(x+r,y-r,z+r);
	
	Color4f(0,1,1,a);
	Vertex3f(x-r,y+r,z+r);
	Vertex3f(x-r,y+r,z-r);
	Vertex3f(x+r,y+r,z-r);
	Vertex3f(x+r,y+r,z+r);
	
	Color4f(1,1,0,a);
	Vertex3f(x-r,y+r,z+r);
	Vertex3f(x-r,y+r,z-r);
	Vertex3f(x-r,y-r,z-r);
	Vertex3f(x-r,y-r,z+r);
	
	Color4f(1,0,1,a);
	Vertex3f(x-r,y+r,z+r);
	Vertex3f(x-r,y-r,z+r);
	Vertex3f(x+r,y-r,z+r);
	Vertex3f(x+r,y+r,z+r);
	EndScene();
	end;
end;

begin
FCamera.CallAction();

DrawCube(0,0,0,1,0.7);
DrawCube(2,0,0,0.5,0.2);
DrawCube(2,-6,0,2,0.5);

Render.Color3f(1,1,1);
SGScreen.Font.BindTexture();
Render.BeginScene(SGR_QUADS);
Render.TexCoord2f(0,1);
Render.Vertex3f(6,6,-3);
Render.TexCoord2f(0,0);
Render.Vertex3f(6,-6,-3);
Render.TexCoord2f(1,0);
Render.Vertex3f(-6,-6,-3);
Render.TexCoord2f(1,1);
Render.Vertex3f(-6,6,-3);
Render.EndScene();
SGScreen.Font.DisableTexture();
end;

begin
ExampleClass := TSGExample;
RunApplication();
end.
