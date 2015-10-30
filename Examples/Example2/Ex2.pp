{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex2;
	interface
{$ELSE}
	program Example2;
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
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeRender
	;
type
	TSGExample2=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FAngle : TSGSingle;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample2.ClassName():TSGString;
begin
Result := 'Крутящиеся треугольники';
end;

constructor TSGExample2.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FAngle:=0;
end;

destructor TSGExample2.Destroy();
begin
inherited;
end;

procedure TSGExample2.Draw();
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

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample2;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
