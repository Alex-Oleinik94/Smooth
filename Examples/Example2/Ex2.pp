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
	;
type
	TSGExample=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FAngle : TSGSingle;
		end;

class function TSGExample.ClassName():TSGString;
begin
Result := 'Крутящиеся треугольники';
end;

constructor TSGExample.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FAngle:=0;
end;

destructor TSGExample.Destroy();
begin
inherited;
end;

procedure TSGExample.Draw();
begin
Render.InitMatrixMode(SG_3D);
Render.Translatef(2,0,-6);
Render.Rotatef(FAngle,0,0,1);
Render.BeginScene(SGR_TRIANGLES);
Render.Color3f(1,0,0);
Render.Vertex2f(1,0);
Render.Color3f(0,1,0);
Render.Vertex2f(0,-1);
Render.Color3f(0,0,1);
Render.Vertex2f(0,1);
Render.EndScene();

Render.InitMatrixMode(SG_2D);
Render.Translatef(Context.Width/2-Context.Width/4,Context.Height/2,0);
Render.Rotatef(FAngle,0,0,1);
Render.BeginScene(SGR_TRIANGLES);
Render.Color3f(0,1,1);
Render.Vertex2f(Context.Height/3,0);
Render.Color3f(1,0,1);
Render.Vertex2f(0,-Context.Height/3);
Render.Color3f(1,1,0);
Render.Vertex2f(0,Context.Height/3);
Render.EndScene();

FAngle += Context.ElapsedTime ;
end;

begin
ExampleClass := TSGExample;
RunApplication();
end.
