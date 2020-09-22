{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex16;
	interface
{$ELSE}
	program Example16;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 Crt
	,Math
	
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothFont
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothScreen
	,SmoothVertexObject
	,SmoothShaders
	,SmoothImage
	,SmoothFractalTerrain
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothMathUtils
	,SmoothCamera
	,SmoothContextUtils
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleCaller
		{$ENDIF}
	
	,Ex5_Physics
	;

type
	TSExample16 = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
		procedure LoadRenderResources();override;
		procedure DeleteRenderResources();override;
			protected
		FCamera : TSCamera;
		FFont : TSFont;
		F3dObject : TS3DObject;
		FSize : TSLongWord;
		FLightAngle : TSSingle;
			protected
		procedure Generate();
		procedure DrawDebugCube();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}


procedure TSExample16.LoadRenderResources();
begin
Generate();
end;

procedure TSExample16.DeleteRenderResources();
begin
SKill(F3dObject);
end;

class function TSExample16.ClassName():TSString;
begin
Result := 'Фрактальный ландшафт';
end;

constructor TSExample16.Create(const VContext : ISContext);
begin
FFont := nil;
FCamera := nil;
F3dObject := nil;
FSize := 9;
FLightAngle := 0;

inherited Create(VContext);

FFont := SCreateFontFromFile(Context, SDefaultFontFileName);

FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
FCamera.Location := TSVector3f.Create(15, 15, -15) * 5.5;

Generate();
end;

function TSExample16CorrectFloat(const A, S : TSFloat):TSFloat;
begin
Result := ((A / S) - 0.5) * 100;
end;

function TSExample16VertexFunction(const VX, VY, VSize : TSLongWord; const VAltitude : TSFloat) : TSVector3f;

begin
Result.Import(
	TSExample16CorrectFloat(VX, VSize),
	((VAltitude + 0.41) / 0.82) * ((VAltitude + 0.41) / 0.82) * 40, 
	TSExample16CorrectFloat(VY, VSize));
end;

function TSExample16ColorShiftFunction(const P, P1, P2 : TSFloat;const C1, C2 : TSColor4f):TSColor4f;
begin
Result.Import(0,0,0,0);
if (P >= P1 - SZero) and (P <= P2 + SZero) then
	begin
	Result := 
		C1 * ((P2 - P) / Abs(P2 - P1)) +
		C2 * ((P - P1) / Abs(P2 - P1));
	end;
end;

function TSExample16ColorFunction(const VAltitude : TSFloat) : TSColor4f;
var
	A : TSFloat;
begin
A := (VAltitude + 0.41) / 0.82;
Result := TSExample16ColorShiftFunction(A, 0,    0.33, SVertex4fImport(0,0,1,1), SVertex4fImport(0.3,0.3,0.3,1))
	    + TSExample16ColorShiftFunction(A, 0.33, 0.66, SVertex4fImport(0.3,0.3,0.3,1), SVertex4fImport(0.545,0.411,0.007,1))
        + TSExample16ColorShiftFunction(A, 0.66,    1, SVertex4fImport(0.545,0.411,0.007,1), SVertex4fImport(0,1,0,1));
if A > 1 then
	Result.Import(1,1,1,1)
else if A < 0 then
	Result.Import(0, 0, 1/4, 1);
end;

procedure TSExample16.Generate();
var
	TerrainGenerator : TSFractalTerrainGenerator;
begin
if F3dObject <> nil then
	begin
	F3dObject.Destroy();
	F3dObject := nil;
	end;
TerrainGenerator := TSFractalTerrainGenerator.Create();
TerrainGenerator.Size := FSize;
F3dObject := TerrainGenerator.Generate3dObject(Context, @TSExample16VertexFunction, @TSExample16ColorFunction);
TerrainGenerator.Destroy();
if F3dObject <> nil then
	F3dObject.LoadToVBO();
end;

destructor TSExample16.Destroy();
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

procedure TSExample16.Paint();
var
	Light : TSVertex3f;
begin
FCamera.InitMatrixAndMove();

Light.Import(cos(FLightAngle),0.5,sin(FLightAngle));
Light *= 40;
FLightAngle += Context.ElapsedTime * 0.01;

Render.Color3f(1,1,1);
Render.BeginScene(SR_POINTS);
Render.Vertex(Light);
Render.EndScene();

Render.Enable(SR_LIGHTING);
Render.Enable(SR_LIGHT0);
Render.Lightfv(SR_LIGHT0,SR_POSITION,@Light);

if F3dObject <> nil then
	F3dObject.Paint();
//DrawDebugCube();

Render.Disable(SR_LIGHTING);

if (Context.KeyPressedType = SDownKey) and 
   (Context.KeyPressedChar = 'R') then
	Generate();
if (Context.KeyPressedType = SDownKey) and 
   (Context.KeyPressedChar in ['0'..'9']) then
	begin
	if Context.KeyPressedChar = '0' then
		FSize := 10
	else
		FSize := SVal(Context.KeyPressedChar);
	Generate();
	end;
end;

procedure TSExample16.DrawDebugCube();
begin
with Render do 
	begin
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
	end;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample16, SSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
