{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex3;
	interface
{$ELSE}
	program Example3;
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
	,SmoothCamera
	,SmoothScreenClasses
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleCaller
		{$ENDIF}
	;
type
	TSExample3=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FCamera : TSCamera;
		function Font() : TSFont;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample3.ClassName():TSString;
begin
Result := 'Кубики и текстура шрифта вместе с камерой';
end;

constructor TSExample3.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
end;

destructor TSExample3.Destroy();
begin
inherited;
end;

procedure TSExample3.Paint();

procedure DrawCube(const x,y,z,r,a: Single);
begin
with Render do
	begin
	BeginScene(SR_QUADS);
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
Font.BindTexture();
Render.BeginScene(SR_QUADS);
Render.TexCoord2f(0,1);
Render.Vertex3f(6,6,-3);
Render.TexCoord2f(0,0);
Render.Vertex3f(6,-6,-3);
Render.TexCoord2f(1,0);
Render.Vertex3f(-6,-6,-3);
Render.TexCoord2f(1,1);
Render.Vertex3f(-6,6,-3);
Render.EndScene();
Font.DisableTexture();
end;

function TSExample3.Font() : TSFont;
begin
Result := (Screen as TSScreenComponent).Skin.Font;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample3, SSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
