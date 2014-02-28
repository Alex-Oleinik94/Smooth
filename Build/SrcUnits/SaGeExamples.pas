{$I Includes\SaGe.inc}

unit SaGeExamples;

interface
uses
	 SaGeCommon
	,Classes
	,SaGeMesh
	,SaGeFractals
	,SaGeUtils
	,SaGeContext
	//,SaGeShaders
	,SaGeScreen
	,SaGeNet
	,SaGeMath
	,SaGeGeneticalAlgoritm
	,SaGeBase
	,SaGeBased
	,SaGeRender
	,SaGeImages
	;
{type
	TSGExampleShader=class(TSGDrawClass)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
		end;}
	
{$DEFINE SGREADINTERFACE}
{$i Includes\SaGeExampleGraphViewer.inc}
{$i Includes\SaGeExampleGeneticalAlgoritm.inc}
{$i Includes\SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION}
{$i Includes\SaGeExampleGraphViewer.inc}
{$i Includes\SaGeExampleGeneticalAlgoritm.inc}
{$i Includes\SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADIMPLEMENTATION}

{constructor TSGExampleShader.Create;
var
	Shader:TSGShader = nil;
begin
inherited;
Shader:=TSGShader.Create(SGR_VERTEX_SHADER);
Shader.Sourse(
	'#version 150'+#13+#10+
	'uniform mat4 viewMatrix, projMatrix;'+#13+#10+
	''+#13+#10+
	'in vec4 position;'+#13+#10+
	'in vec3 color;'+#13+#10+
	''+#13+#10+
	'out vec3 Color;'+#13+#10+
	''+#13+#10+
	'void main()'+#13+#10+
	'	{'+#13+#10+
	'	Color = color;'+#13+#10+
	'	gl_Position = projMatrix * viewMatrix * position ;'+#13+#10+
	'	}');
Shader.Compile;

end;

destructor TSGExampleShader.Destroy;
begin

inherited;
end;

class function TSGExampleShader.ClassName:string;
begin
Result:='Exaple Shaders';
end;

procedure TSGExampleShader.Draw;
begin

end;}


end.
