{$INCLUDE SaGe.inc}
program Example6_2;
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
	,SaGeCommon
	,SaGeMesh
	,SaGeImages
	,Ex6_D,Ex6_N
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
		FMesh   : TSGCustomModel;
		
		FSunAngle : TSGSingle;
		FImageBump, FImageTexture : TSGImage;
		FSunRadius : TSGSingle;
		end;

class function TSGExample.ClassName():TSGString;
begin
Result := 'Bump Mapping 2';
end;

constructor TSGExample.Create(const VContext : TSGContext);
var
	i : TSGLongWord;
	r : TSGSingle = 2;
	a : TSGSingle = pi * 2;
	n : TSGByte    = 20;
	t : TSGSingle;
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FMesh := nil;
FSunAngle  := 0;
FSunRadius := r * 0.6;
t := n/a;

FMesh := TSGCustomModel.Create();
FMesh.Context := Context;

FMesh.AddObject();
FMesh.LastObject().BumpFormat := SGMeshBumpTypeCopyTexture2f;
FMesh.LastObject().HasNormals := True;
FMesh.LastObject().HasTexture := True;
FMesh.LastObject().HasColors  := False;
FMesh.LastObject().VertexType := SGMeshVertexType3f;
FMesh.LastObject().Vertexes   := n * 2;

FMesh.LastObject().AddFaceArray();
FMesh.LastObject().AutoSetIndexFormat(0, n * 2);
FMesh.LastObject().PoligonesType     [0] := SGR_TRIANGLES;
FMesh.LastObject().Faces             [0] := (n - 1) * 2;

FMesh.LastObject().ArVertex3f [0]^.Import(cos(0)*r,sin(0)*r, 1);
FMesh.LastObject().ArVertex3f [1]^.Import(cos(0)*r,sin(0)*r,-1);
FMesh.LastObject().ArTexVertex[0]^.Import(0,0);
FMesh.LastObject().ArTexVertex[1]^.Import(0,1);
FMesh.LastObject().ArNormal   [0]^.Import(-cos(0),-sin(0),0);
FMesh.LastObject().ArNormal   [1]^.Import(-cos(0),-sin(0),0);

for i := 1 to n - 1 do
	begin
	FMesh.LastObject().ArVertex3f [i*2+0]^.Import(cos(a*i/(n-1))*r,sin(a*i/(n-1))*r, 1);
	FMesh.LastObject().ArVertex3f [i*2+1]^.Import(cos(a*i/(n-1))*r,sin(a*i/(n-1))*r,-1);
	FMesh.LastObject().ArTexVertex[i*2+0]^.Import(i/(n-1)*t,0);
	FMesh.LastObject().ArTexVertex[i*2+1]^.Import(i/(n-1)*t,1);
	FMesh.LastObject().ArNormal   [i*2+0]^.Import(-cos(a*i/(n-1)),-sin(a*i/(n-1)),0);
	FMesh.LastObject().ArNormal   [i*2+1]^.Import(-cos(a*i/(n-1)),-sin(a*i/(n-1)),0);
	
	FMesh.LastObject().SetFaceTriangle(0, (i - 1)*2+0, i*2+0,i*2-2,i*2-1);
	FMesh.LastObject().SetFaceTriangle(0, (i - 1)*2+1, i*2+0,i*2-1,i*2+1);
	end;

FMesh.AddMaterial ().Name := 'name';
FMesh.LastMaterial().AddDiffuseMap('Ex6_D.jpg');
FMesh.LastMaterial().AddBumpMap   ('Ex6_N.jpg');

FMesh.LastObject().CreateMaterialIDInLastFaceArray('name');

FMesh.LoadToVBO();

FImageBump    := FMesh.LastMaterial().ImageBump;
FImageTexture := FMesh.LastMaterial().ImageTexture;

//FMesh.WriteInfo();
end;

destructor TSGExample.Destroy();
begin
inherited;
end;

procedure TSGExample.Draw();
procedure DrawHints();
var
	i : TSGWord;
begin
i:= Context.Height - 70;
Render.InitMatrixMode(SG_2D);
Render.Color3f(1,1,1);
SGScreen.Font.DrawFontFromTwoVertex2f('Press "1" to associate Diffuse as Diffuse and Bump as Bump.',
	SGVertex2fImport(0,i),SGVertex2fImport(Context.Width,i + SGScreen.Font.FontHeight));
i += SGScreen.Font.FontHeight;
SGScreen.Font.DrawFontFromTwoVertex2f('Press "2" to associate Diffuse as Diffuse.',
	SGVertex2fImport(0,i),SGVertex2fImport(Context.Width,i + SGScreen.Font.FontHeight));
i += SGScreen.Font.FontHeight;
SGScreen.Font.DrawFontFromTwoVertex2f('Press "3" to associate Bump as Diffuse.',
	SGVertex2fImport(0,i),SGVertex2fImport(Context.Width,i + SGScreen.Font.FontHeight));
i += SGScreen.Font.FontHeight;
SGScreen.Font.DrawFontFromTwoVertex2f('Press "4" to associate Diffuse as Bump and Bump as Diffuse.',
	SGVertex2fImport(0,i),SGVertex2fImport(Context.Width,i + SGScreen.Font.FontHeight));
end;
var
	FSun : TSGVertex3f;
begin
FCamera.CallAction();

FSunAngle += Context.ElapsedTime*0.01;
FSun.Import(cos(FSunAngle)*FSunRadius,sin(FSunAngle)*FSunRadius);

Render.Color3f(1,1,1);
Render.BeginScene(SGR_POINTS);
FSun.Vertex(Render);
Render.EndScene();

Render.Disable(SGR_BLEND);
Render.Enable (SGR_LIGHTING);
Render.Enable (SGR_LIGHT0);
Render.Lightfv(SGR_LIGHT0, SGR_POSITION, @FSun);

if FMesh.LastMaterial().EnableBump then
	Render.BeginBumpMapping(@FSun);

FMesh.Draw();

if FMesh.LastMaterial().EnableBump then
	Render.EndBumpMapping();

Render.Enable (SGR_BLEND);
Render.Disable(SGR_LIGHTING);
Render.Disable(SGR_LIGHT0);

DrawHints();
if Context.KeyPressed and (Context.KeyPressedType=SGDownKey) then
case Context.KeyPressedChar of
'1' : 
	begin
	FMesh.LastObject().BumpFormat := SGMeshBumpTypeCopyTexture2f;
	FMesh.LastMaterial().EnableBump := True;
	FMesh.LastMaterial().EnableTexture := True;
	FMesh.LastMaterial().ImageBump := FImageBump;
	FMesh.LastMaterial().ImageTexture := FImageTexture;
	end;
'2' :
	begin
	FMesh.LastObject().BumpFormat := SGMeshBumpTypeNone;
	FMesh.LastMaterial().EnableBump := False;
	FMesh.LastMaterial().EnableTexture := True;
	FMesh.LastMaterial().ImageTexture := FImageTexture;
	end;
'3' :
	begin
	FMesh.LastObject().BumpFormat := SGMeshBumpTypeNone;
	FMesh.LastMaterial().EnableBump := False;
	FMesh.LastMaterial().EnableTexture := True;
	FMesh.LastMaterial().ImageTexture := FImageBump;
	end;
'4' :
	begin
	FMesh.LastObject().BumpFormat := SGMeshBumpTypeCopyTexture2f;
	FMesh.LastMaterial().EnableBump := True;
	FMesh.LastMaterial().EnableTexture := True;
	FMesh.LastMaterial().ImageBump := FImageTexture;
	FMesh.LastMaterial().ImageTexture := FImageBump;
	end;
end;
end;

begin
ExampleClass := TSGExample;
RunApplication();
end.
