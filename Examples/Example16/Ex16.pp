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
		procedure LoadDeviceResourses();override;
		procedure DeleteDeviceResourses();override;
			protected
		FCamera : TSGCamera;
		FFont : TSGFont;
		FMesh : TSG3DObject;
			protected
		procedure Generate();
		procedure DrawDebugCube();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}


procedure TSGExample16.LoadDeviceResourses();
begin
Generate();
end;

procedure TSGExample16.DeleteDeviceResourses();
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

inherited Create(VContext);

FFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
FFont.SetContext(Context);
FFont.Loading();
FFont.ToTexture();

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);

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
	VAltitude * 40, 
	TSGExample16CorrectFloat(VY, VSize));
end;

function TSGExample16ColorFunction(const VAltitude : TSGFloat) : TSGColor4f;
var
	A : TSGFloat;
begin
A := (VAltitude + 0.4) / 0.8;

Result := SGVertex4fImport(0,1,0,1) * A + SGVertex4fImport(0,0,1,1) * (1 - A);
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
begin
FCamera.CallAction();
if FMesh <> nil then
	FMesh.Paint();
DrawDebugCube();
if (Context.KeyPressedType = SGDownKey) and 
   (Context.KeyPressedChar = 'R') then
	Generate();
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
