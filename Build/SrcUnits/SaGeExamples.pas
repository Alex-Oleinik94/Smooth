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
	,SaGeRender;
{type
	TSGExampleShader=class(TSGDrawClass)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
		end;}
{type
	TSGBezierCurve =object
		StartArray : TArTSGVertex3f;
		EndArray : TArTSGVertex3f;
		Detalization:dword;
		procedure Clear;
		procedure InitVertex(const k:TSGVertex3f);
		procedure Calculate;
		procedure Init(const p:Pointer = nil);
		procedure SetArray(const a:TArTSGVertex3f);
		function SetDetalization(const l:dword):boolean;
		function GetDetalization:longword;
		procedure CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
		end;
	SGBezierCurve = TSGBezierCurve;}
	
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

{procedure TSGBezierCurve.Calculate;
var
	i:longword;

function GetKoor(const R:real;const A:TArTSGVertex3f):TSGVertex3f;
var
	A2:TArTSGVertex3f;
	i:longint;
begin
if Length(a)=2 then
	begin
	GetKoor:=SGGetVertexInAttitude(A[Low(A)],A[High(A)],r);
	end
else
	begin
	SetLength(A2,Length(A)-1);
	for i:=Low(A2) to High(A2) do
		A2[i]:=SGGetVertexInAttitude(A[i],A[i+1],r);
	GetKoor:=GetKoor(R,A2);
	SetLength(A2,0);
	end;
end;

begin
SetLength(EndArray,Detalization+1);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i]:=GetKoor(i/Detalization,StartArray);
	end;
end;

procedure TSGBezierCurve.InitVertex(const k:TSGVertex3f);
begin
SetLength(StartArray,Length(StartArray)+1);
StartArray[High(StartArray)]:=k;
end;

procedure TSGBezierCurve.Clear;
begin
SetLength(StartArray,0);
SetLength(EndArray,0);
SetDetalization(40);
end;
function TSGBezierCurve.GetDetalization:longword;
begin
GetDetalization:=Detalization;
end;

procedure TSGBezierCurve.SetArray(const a:TArTSGVertex3f);
begin
SetLength(StartArray,0);
StartArray:=a;
end;

function TSGBezierCurve.SetDetalization(const l:dword):boolean;
begin
if l>0 then
	begin
	SetDetalization:=true;
	Detalization:=l;
	end
else
	SetDetalization:=false;
end;

procedure TSGBezierCurve.Init(const p:Pointer = nil);
var	
	i:longint;
begin
GlBegin(SGR_LINE_STRIP);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i].Vertex(p);
	end;
GlEnd();
end;

procedure TSGBezierCurve.CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
var
	i:longint;
begin
Clear;
SetDetalization(Detalization1);
for i:=1 to KolVertex do
	InitVertex(SGTSGVertex3fImport(
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1)));
Calculate;
end;}

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
