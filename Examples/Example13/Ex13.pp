{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex13;
	interface
{$ELSE}
	program Example13;
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
	,SaGeUtils
	,SaGeRender
	,SaGeCommon
	,crt
	,SaGeScreen
	,SaGeMesh
	,SaGeShaders
	;

const
	VertexShaderSourse = '// Vertex Shader '+#13+#10+
		'uniform mat4 boneMat[32]; '+#13+#10+
		'varying float texNum; '+#13+#10+
		'void main() '+#13+#10+
		'{ '+#13+#10+
		'float boneIndex[3]; '+#13+#10+
		'float boneWeight[3]; '+#13+#10+
		'texNum = gl_Vertex[3]; '+#13+#10+
		'vec4 fixedTexCoord = gl_MultiTexCoord0; '+#13+#10+
		'vec4 fixedColor = gl_Color; '+#13+#10+
		'vec4 fixedVertex = gl_Vertex; '+#13+#10+
		'vec4 finalVertex = vec4(0,0,0,1); '+#13+#10+
		'boneIndex[0] = floor(fixedTexCoord[2]*255.0+0.001); '+#13+#10+
		'boneWeight[0] = fixedTexCoord[3]; '+#13+#10+
		'boneIndex[1] = floor(fixedColor[0]*255.0+0.001); '+#13+#10+
		'boneWeight[1] = fixedColor[1]; '+#13+#10+
		'boneIndex[2] = floor(fixedColor[2]*255.0+0.001); '+#13+#10+
		'boneWeight[2] = fixedColor[3]; '+#13+#10+
		'fixedTexCoord[2] = 0.0; '+#13+#10+
		'fixedTexCoord[3] = 1.0; '+#13+#10+
		'fixedColor[0] = 1.0; '+#13+#10+
		'fixedColor[1] = 1.0; '+#13+#10+
		'fixedColor[2] = 1.0; '+#13+#10+
		'fixedColor[3] = 1.0; '+#13+#10+
		'fixedVertex[3] = 1.0; '+#13+#10+
		'mat4 finalMatrix = mat4(0); '+#13+#10+
		'for (int i = 0; i < 3; i++) '+#13+#10+
			'finalMatrix += boneWeight[i]*boneMat[int(boneIndex[i])]; '+#13+#10+
		'finalVertex = finalMatrix*fixedVertex; '+#13+#10+
		'finalVertex[3] = 1.0; '+#13+#10+
		'gl_Position = gl_ModelViewProjectionMatrix * finalVertex; '+#13+#10+
		'gl_FrontColor = fixedColor; '+#13+#10+
		'gl_TexCoord[0] = fixedTexCoord; '+#13+#10+
		'}';
	FragmentShaderSourse = '// Fragment Shader '+#13+#10+
		'uniform sampler2D myTexture0; '+#13+#10+
		'uniform sampler2D myTexture1; '+#13+#10+
		'uniform sampler2D myTexture2; '+#13+#10+
		'uniform sampler2D myTexture3; '+#13+#10+
		'uniform sampler2D myTexture4; '+#13+#10+
		'uniform sampler2D myTexture5; '+#13+#10+
		'uniform sampler2D myTexture6; '+#13+#10+
		'uniform sampler2D myTexture7; '+#13+#10+
		'varying float texNum; '+#13+#10+
		'void main() '+#13+#10+
		'{ '+#13+#10+
		' float texNum2 = floor(texNum*255.0-1.0+0.001); '+#13+#10+
		' if (texNum2==0.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture0, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==1.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture1, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==2.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture2, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==3.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture3, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==4.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture4, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==5.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture5, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==6.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture6, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==7.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture7, gl_TexCoord[0].st );  '+#13+#10+
		'}';

type
	TSGExample13=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FShaderProgram : TSGShaderProgram;
		FVertexShader, FFragmentShader : TSGShader;
		FRotateAngle : TSGFloat;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample13.ClassName():TSGString;
begin
Result := 'Скелетная анимация';
end;

constructor TSGExample13.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FRotateAngle := 0;

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
FCamera.Up:=SGVertexImport(0,0,1);
FCamera.Location:=SGVertexImport(0,-10,-10);
FCamera.View:=(SGVertexImport(0,0,0)-SGVertexImport(0,-350,100)).Normalized();

FVertexShader := TSGShader.Create(Context,SGR_VERTEX_SHADER);
FVertexShader.Sourse(VertexShaderSourse);
if not FVertexShader.Compile() then
	FVertexShader.PrintInfoLog();

FFragmentShader := TSGShader.Create(Context,SGR_FRAGMENT_SHADER);
FFragmentShader.Sourse(FragmentShaderSourse);
if not FFragmentShader.Compile() then
	FFragmentShader.PrintInfoLog();

FShaderProgram := TSGShaderProgram.Create(Context);
FShaderProgram.Attach(FVertexShader);
FShaderProgram.Attach(FFragmentShader);
if not FShaderProgram.Link() then
	FShaderProgram.PrintInfoLog();
end;

destructor TSGExample13.Destroy();
begin
inherited;
end;

procedure TSGExample13.Draw();
begin
FCamera.CallAction();
FRotateAngle += Context.ElapsedTime/100;
Render.Rotatef(FRotateAngle,FCamera.Up.x,FCamera.Up.y,FCamera.Up.z);

end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample13;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
