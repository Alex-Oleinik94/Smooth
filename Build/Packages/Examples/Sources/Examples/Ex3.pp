{$INCLUDE SaGe.inc}
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
	 SaGeCommonClasses
	,SaGeBase
	,SaGeRenderBase
	,SaGeFont
	,SaGeScreen
	,SaGeCamera
	{$IF not defined(ENGINE)}
		,SaGeConsolePaintableTools
		,SaGeConsoleToolsBase
		{$ENDIF}
	;
type
	TSGExample3=class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample3.ClassName():TSGString;
begin
Result := 'Кубики и текстура шрифта вместе с камерой';
end;

constructor TSGExample3.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
end;

destructor TSGExample3.Destroy();
begin
inherited;
end;

procedure TSGExample3.Paint();

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
Screen.Skin.Font.BindTexture();
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
Screen.Skin.Font.DisableTexture();
end;

{$IFNDEF ENGINE}
	begin
	SGConsoleRunPaintable(TSGExample3, SGSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
