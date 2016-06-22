{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex6;
	interface
{$ELSE}
	program Example6;
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
	SaGeCommonClasses
	,SaGeBased
	,SaGeBase
	,SaGeRenderConstants
	,SaGeUtils
	,SaGeScreen
	,SaGeCommon
	,SaGeMesh
	,SaGeImages
	
	,Ex6_D
	,Ex6_N
	;
type
	TSGExample6=class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FMesh   : TSGCustomModel;
		
		FSunAngle : TSGSingle;
		FImageBump, FImageTexture : TSGImage;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample6.ClassName():TSGString;
begin
Result := 'Bump Mapping';
end;

constructor TSGExample6.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FMesh := nil;
FSunAngle:=0;

FMesh := TSGCustomModel.Create();
FMesh.Context := Context;

FMesh.AddObject();
FMesh.LastObject().BumpFormat := SGMeshBumpTypeCopyTexture2f;
FMesh.LastObject().HasNormals := True;
FMesh.LastObject().HasTexture := True;
FMesh.LastObject().HasColors  := False;
FMesh.LastObject().VertexType := SGMeshVertexType3f;
FMesh.LastObject().Vertexes   := 4;
FMesh.LastObject().ArVertex3f[0]^.Import(-1,-1);
FMesh.LastObject().ArVertex3f[1]^.Import(-1,1);
FMesh.LastObject().ArVertex3f[2]^.Import(1,1);
FMesh.LastObject().ArVertex3f[3]^.Import(1,-1);
FMesh.LastObject().ArTexVertex[0]^.Import(0,0);
FMesh.LastObject().ArTexVertex[1]^.Import(0,1);
FMesh.LastObject().ArTexVertex[2]^.Import(1,1);
FMesh.LastObject().ArTexVertex[3]^.Import(1,0);
FMesh.LastObject().ArNormal[0]^.Import(0,0,1);
FMesh.LastObject().ArNormal[1]^.Import(0,0,1);
FMesh.LastObject().ArNormal[2]^.Import(0,0,1);
FMesh.LastObject().ArNormal[3]^.Import(0,0,1);
FMesh.LastObject().AddFaceArray();
FMesh.LastObject().AutoSetIndexFormat(0,4);
FMesh.LastObject().PoligonesType[0] := SGR_TRIANGLES;
FMesh.LastObject().Faces [0] := 2;
FMesh.LastObject().SetFaceTriangle(0,  0,  0,1,2);
FMesh.LastObject().SetFaceTriangle(0,  1,  0,2,3);

FMesh.AddMaterial ().Name := 'name';
FMesh.LastMaterial().AddDiffuseMap('Ex6_D.jpg');
FMesh.LastMaterial().AddBumpMap   ('Ex6_N.jpg');

FMesh.LastObject().CreateMaterialIDInLastFaceArray('name');

FMesh.LoadToVBO();

FImageBump    := FMesh.LastMaterial().ImageBump;
FImageTexture := FMesh.LastMaterial().ImageTexture;
end;

destructor TSGExample6.Destroy();
begin
inherited;
end;

procedure TSGExample6.Paint();
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
FSun.Import(cos(FSunAngle)*2,sin(FSunAngle)*2,2);

Render.Color3f(1,1,1);
Render.BeginScene(SGR_POINTS);
FSun.Vertex(Render);
Render.EndScene();

Render.Disable(SGR_BLEND);
Render.Enable(SGR_LIGHTING);
Render.Enable(SGR_LIGHT0);
Render.Lightfv(SGR_LIGHT0, SGR_POSITION, @FSun);

if FMesh.LastMaterial().EnableBump then
	Render.BeginBumpMapping(@FSun);

FMesh.Paint();

if FMesh.LastMaterial().EnableBump then
	Render.EndBumpMapping();

Render.Enable(SGR_BLEND);
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

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample6;
	RunApplication();
	{$ENDIF}
end.
