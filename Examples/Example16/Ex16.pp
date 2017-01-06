{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex16;
	interface
{$ELSE}
	program Example16;
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
	crt
	,Math
	
	,SaGeCommonClasses
	,SaGeBased
	,SaGeBase
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeCommon
	,SaGeScreen
	,SaGeMesh
	,SaGeShaders
	,SaGePhysics
	,SaGeImages
	,SaGeFractalTerrain
	;

type
	TSGExample16 = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
		procedure LoadDeviceResources();override;
		procedure DeleteDeviceResources();override;
			protected
		FCamera : TSGCamera;
		FFont : TSGFont;
		FMesh : TSG3DObject;
		FSize : TSGLongWord;
		FLightAngle : TSGSingle;
			protected
		procedure Generate();
		procedure DrawDebugCube();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}


procedure TSGExample16.LoadDeviceResources();
begin
Generate();
end;

procedure TSGExample16.DeleteDeviceResources();
begin
if FMesh <> nil then
	begin
	FMesh.Destroy();
	FMesh := nil;
	end;
end;

class function TSGExample16.ClassName():TSGString;
begin
Result := 'Фрактальный ландшафт';
end;

constructor TSGExample16.Create(const VContext : ISGContext);
begin
FFont := nil;
FCamera := nil;
FMesh := nil;
FSize := 9;
FLightAngle := 0;

inherited Create(VContext);

FFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
FFont.SetContext(Context);
FFont.Loading();
FFont.ToTexture();

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.Zum := 15.47;
FCamera.RotateY := -42.66;
FCamera.RotateX := 37.66;
Generate();
end;

function TSGExample16CorrectFloat(const A, S : TSGFloat):TSGFloat;
begin
Result := ((A / S) - 0.5) * 100;
end;

function TSGExample16VertexFunction(const VX, VY, VSize : TSGLongWord; const VAltitude : TSGFloat) : TSGVector3f;

begin
Result.Import(
	TSGExample16CorrectFloat(VX, VSize),
	((VAltitude + 0.41) / 0.82) * ((VAltitude + 0.41) / 0.82) * 40, 
	TSGExample16CorrectFloat(VY, VSize));
end;

function TSGExample16ColorShiftFunction(const P, P1, P2 : TSGFloat;const C1, C2 : TSGColor4f):TSGColor4f;
begin
Result.Import(0,0,0,0);
if (P >= P1 - SGZero) and (P <= P2 + SGZero) then
	begin
	Result := 
		C1 * ((P2 - P) / Abs(P2 - P1)) +
		C2 * ((P - P1) / Abs(P2 - P1));
	end;
end;

function TSGExample16ColorFunction(const VAltitude : TSGFloat) : TSGColor4f;
var
	A : TSGFloat;
begin
A := (VAltitude + 0.41) / 0.82;
Result := TSGExample16ColorShiftFunction(A, 0,    0.33, SGVertex4fImport(0,0,1,1), SGVertex4fImport(0.3,0.3,0.3,1))
	    + TSGExample16ColorShiftFunction(A, 0.33, 0.66, SGVertex4fImport(0.3,0.3,0.3,1), SGVertex4fImport(0.545,0.411,0.007,1))
        + TSGExample16ColorShiftFunction(A, 0.66,    1, SGVertex4fImport(0.545,0.411,0.007,1), SGVertex4fImport(0,1,0,1));
if A > 1 then
	Result.Import(1,1,1,1)
else if A < 0 then
	Result.Import(0, 0, 1/4, 1);
end;

procedure TSGExample16.Generate();
var
	TerrainGenerator : TSGFractalTerrainGenerator;
begin
if FMesh <> nil then
	begin
	FMesh.Destroy();
	FMesh := nil;
	end;
TerrainGenerator := TSGFractalTerrainGenerator.Create();
TerrainGenerator.Size := FSize;
FMesh := TerrainGenerator.GenerateMesh(Context, @TSGExample16VertexFunction, @TSGExample16ColorFunction);
TerrainGenerator.Destroy();
if FMesh <> nil then
	FMesh.LoadToVBO();
end;

destructor TSGExample16.Destroy();
begin
if FFont <> nil then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
if FCamera <> nil then
	begin
	FCamera .Destroy();
	FCamera := nil;
	end;
inherited;
end;

procedure TSGExample16.Paint();
var
	Light : TSGVertex3f;
begin
FCamera.CallAction();

Light.Import(cos(FLightAngle),0.5,sin(FLightAngle));
Light *= 40;
FLightAngle += Context.ElapsedTime * 0.01;

Render.Color3f(1,1,1);
Render.BeginScene(SGR_POINTS);
Render.Vertex(Light);
Render.EndScene();

Render.Enable(SGR_LIGHTING);
Render.Enable(SGR_LIGHT0);
Render.Lightfv(SGR_LIGHT0,SGR_POSITION,@Light);

if FMesh <> nil then
	FMesh.Paint();
//DrawDebugCube();

Render.Disable(SGR_LIGHTING);

if (Context.KeyPressedType = SGDownKey) and 
   (Context.KeyPressedChar = 'R') then
	Generate();
if (Context.KeyPressedType = SGDownKey) and 
   (Context.KeyPressedChar in ['0'..'9']) then
	begin
	if Context.KeyPressedChar = '0' then
		FSize := 10
	else
		FSize := SGVal(Context.KeyPressedChar);
	Generate();
	end;
end;

procedure TSGExample16.DrawDebugCube();
begin
with Render do 
	begin
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
	end;
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample16;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
