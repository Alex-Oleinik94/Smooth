{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex6;
	interface
{$ELSE}
	program Example6;
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
	,SmoothScreenClasses
	,SmoothCommonStructs
	,Smooth3dObject
	,SmoothVertexObject
	,SmoothMaterial
	,SmoothImage
	,SmoothCamera
	,SmoothFileUtils
	,SmoothContextUtils
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	;
type
	TSExample6=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FCamera : TSCamera;
		F3dObject   : TSCustomModel;
		
		FSunAngle : TSSingle;
		FImageBump, FImageTexture : TSImage;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample6.ClassName():TSString;
begin
Result := 'Bump Mapping';
end;

constructor TSExample6.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
F3dObject := nil;
FSunAngle:=0;

F3dObject := TSCustomModel.Create();
F3dObject.Context := Context;

F3dObject.AddObject();
F3dObject.LastObject().BumpFormat := SBumpFormatCopyTexture2f;
F3dObject.LastObject().HasNormals := True;
F3dObject.LastObject().HasTexture := True;
F3dObject.LastObject().HasColors  := False;
F3dObject.LastObject().VertexType := S3dObjectVertexType3f;
F3dObject.LastObject().Vertices   := 4;
F3dObject.LastObject().ArVertex3f[0]^.Import(-1,-1);
F3dObject.LastObject().ArVertex3f[1]^.Import(-1,1);
F3dObject.LastObject().ArVertex3f[2]^.Import(1,1);
F3dObject.LastObject().ArVertex3f[3]^.Import(1,-1);
F3dObject.LastObject().ArTexVertex[0]^.Import(0,0);
F3dObject.LastObject().ArTexVertex[1]^.Import(0,1);
F3dObject.LastObject().ArTexVertex[2]^.Import(1,1);
F3dObject.LastObject().ArTexVertex[3]^.Import(1,0);
F3dObject.LastObject().ArNormal[0]^.Import(0,0,1);
F3dObject.LastObject().ArNormal[1]^.Import(0,0,1);
F3dObject.LastObject().ArNormal[2]^.Import(0,0,1);
F3dObject.LastObject().ArNormal[3]^.Import(0,0,1);
F3dObject.LastObject().AddFaceArray();
F3dObject.LastObject().AutoSetIndexFormat(0,4);
F3dObject.LastObject().PoligonesType[0] := SR_TRIANGLES;
F3dObject.LastObject().Faces [0] := 2;
F3dObject.LastObject().SetFaceTriangle(0,  0,  0,1,2);
F3dObject.LastObject().SetFaceTriangle(0,  1,  0,2,3);

F3dObject.AddMaterial ().Name := 'name';
F3dObject.LastMaterial().AddDiffuseMap(SExamplesDirectory + DirectorySeparator + '6' + DirectorySeparator + 'D.jpg');
F3dObject.LastMaterial().AddBumpMap   (SExamplesDirectory + DirectorySeparator + '6' + DirectorySeparator + 'N.jpg');

F3dObject.LastObject().LastObjectFace()^.FMaterial := F3dObject.IdentifyMaterial('name');

if Render.SupportedGraphicalBuffers() then
	F3dObject.LoadToVBO();

FImageBump    := F3dObject.LastMaterial().ImageBump;
FImageTexture := F3dObject.LastMaterial().ImageTexture;
end;

destructor TSExample6.Destroy();
begin
FImageBump := nil;
FImageTexture := nil;
if FCamera <> nil then
	begin
	FCamera.Destroy();
	FCamera := nil;
	end;
if F3dObject <> nil then
	begin
	F3dObject.Destroy();
	F3dObject := nil;
	end;
inherited;
end;

procedure TSExample6.Paint();
procedure DrawHints();
var
	i : TSWord;
begin
i:= Render.Height - 70;
Render.InitMatrixMode(S_2D);
Render.Color3f(1,1,1);
(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('Press "1" to associate Diffuse as Diffuse and Bump as Bump.',
	SVertex2fImport(0,i),SVertex2fImport(Render.Width,i + (Screen as TSScreenComponent).Skin.Font.FontHeight), False);
i += (Screen as TSScreenComponent).Skin.Font.FontHeight;
(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('Press "2" to associate Diffuse as Diffuse.',
	SVertex2fImport(0,i),SVertex2fImport(Render.Width,i + (Screen as TSScreenComponent).Skin.Font.FontHeight), False);
i += (Screen as TSScreenComponent).Skin.Font.FontHeight;
(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('Press "3" to associate Bump as Diffuse.',
	SVertex2fImport(0,i),SVertex2fImport(Render.Width,i + (Screen as TSScreenComponent).Skin.Font.FontHeight), False);
i += (Screen as TSScreenComponent).Skin.Font.FontHeight;
(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('Press "4" to associate Diffuse as Bump and Bump as Diffuse.',
	SVertex2fImport(0,i),SVertex2fImport(Render.Width,i + (Screen as TSScreenComponent).Skin.Font.FontHeight), False);
end;
var
	FSun : TSVertex3f;
begin
FCamera.CallAction();

FSunAngle += Context.ElapsedTime*0.01;
FSun.Import(cos(FSunAngle)*2,sin(FSunAngle)*2,2);

Render.Color3f(1,1,1);
Render.BeginScene(SR_POINTS);
Render.Vertex(FSun);
Render.EndScene();

Render.Disable(SR_BLEND);
Render.Enable(SR_LIGHTING);
Render.Enable(SR_LIGHT0);
Render.Lightfv(SR_LIGHT0, SR_POSITION, @FSun);

if F3dObject.LastMaterial().EnableBump then
	Render.BeginBumpMapping(@FSun);

F3dObject.Paint();

if F3dObject.LastMaterial().EnableBump then
	Render.EndBumpMapping();

Render.Enable(SR_BLEND);
Render.Disable(SR_LIGHTING);
Render.Disable(SR_LIGHT0);

DrawHints();
if Context.KeyPressed and (Context.KeyPressedType=SDownKey) then
case Context.KeyPressedChar of
'1' : 
	begin
	F3dObject.LastObject().BumpFormat := SBumpFormatCopyTexture2f;
	F3dObject.LastMaterial().EnableBump := True;
	F3dObject.LastMaterial().EnableTexture := True;
	F3dObject.LastMaterial().ImageBump := FImageBump;
	F3dObject.LastMaterial().ImageTexture := FImageTexture;
	end;
'2' :
	begin
	F3dObject.LastObject().BumpFormat := SBumpFormatNone;
	F3dObject.LastMaterial().EnableBump := False;
	F3dObject.LastMaterial().EnableTexture := True;
	F3dObject.LastMaterial().ImageTexture := FImageTexture;
	end;
'3' :
	begin
	F3dObject.LastObject().BumpFormat := SBumpFormatNone;
	F3dObject.LastMaterial().EnableBump := False;
	F3dObject.LastMaterial().EnableTexture := True;
	F3dObject.LastMaterial().ImageTexture := FImageBump;
	end;
'4' :
	begin
	F3dObject.LastObject().BumpFormat := SBumpFormatCopyTexture2f;
	F3dObject.LastMaterial().EnableBump := True;
	F3dObject.LastMaterial().EnableTexture := True;
	F3dObject.LastMaterial().ImageBump := FImageTexture;
	F3dObject.LastMaterial().ImageTexture := FImageBump;
	end;
end;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample6, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
