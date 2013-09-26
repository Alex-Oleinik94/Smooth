{$I Includes\SaGe.inc}

unit SaGeShaders;

interface
uses
	crt
	,SaGeBase
	,SaGeCommon
	,SysUtils
	;
type
	{
	GL_VERTEX_SHADER
	GL_FRAGMENT_SHADER
	GL_VERTEX_SHADER_ARB = GL_VERTEX_SHADER
	GL_FRAGMENT_SHADER_ARB = GL_FRAGMENT_SHADER
	}
	TSGProgram=class;
	TSGShader=class(TObject)
			public
		constructor Create(const ShaderType:LongWord = GL_VERTEX_SHADER;const Version:LongWord = SG_GLSL_ARB);
		destructor Destroy;override;
		procedure Compile;inline;
		procedure Sourse(const s:string);overload;
		procedure PrintInfoLog;
			private
		FShader:GLuint;
		FType:LongWord;
		FVersion:LongWord;
			public
		property Shader:GLuint read FShader;
		end;
	TSGProgram=class(TObject)
			public
		constructor Create;
		destructor Destroy;override;
		procedure Attach(const NewShader:TSGShader);
			private
		FProgram:GLuint;
		FShaders:
			packed array of
				TSGShader;
		end;
implementation

constructor TSGProgram.Create;
begin
inherited;
FProgram:=glCreateProgram();
FShaders:=nil;
end;
procedure TSGProgram.Attach(const NewShader:TSGShader);
begin
if FShaders=nil then
	SetLength(FShaders,1)
else
	SetLength(FShaders,Length(FShaders)+1);
FShaders[High(FShaders)]:=NewShader;
glAttachShader(FProgram,NewShader.Shader);
end;
destructor TSGProgram.Destroy;
var
	i:LongWord;
begin
if FShaders<>nil then
	begin
	for i:=0 to High(FShaders) do
		FShaders[i].Destroy;
	SetLength(FShaders,0);
	end;
glDeleteProgram(FProgram);
inherited;
end;

procedure TSGShader.PrintInfoLog;
var
	InfoLogLength:LongInt = 0;
	InfoLog:PChar = nil;
	CharsWritten:LongInt  = 0;
var
	Success:Boolean = False;
begin
if FVersion=SG_GLSL_3_0 then
	begin
	glGetProgramiv(FShader, GL_INFO_LOG_LENGTH,@InfoLogLength);
	if InfoLogLength>0 then
		begin
		GetMem(InfoLog,InfoLogLength);
		glGetProgramInfoLog(FShader, InfoLogLength, @CharsWritten, InfoLog);
		SGLog.Sourse('TSGShader.PrintInfoLog : "'+SGPCharToString(InfoLog)+'".');
		FreeMem(InfoLog,InfoLogLength);
		end;
	end
else
	begin
	glGetObjectParameterivARB(FShader,GL_OBJECT_COMPILE_STATUS_ARB,@Success);
	if not Success then
		begin
		glGetObjectParameterivARB(FShader, GL_OBJECT_INFO_LOG_LENGTH_ARB,@InfoLogLength);
		GetMem(InfoLog,InfoLogLength);
		glGetInfoLogARB(FShader, InfoLogLength, @CharsWritten, InfoLog);
		SGLog.Sourse('TSGShader.PrintInfoLog : "'+SGPCharToString(InfoLog)+'".');//915
		FreeMem(InfoLog,InfoLogLength);
		end;
	end;
end;
procedure TSGShader.Sourse(const s:string);
var
	pc:PChar = nil;
	pcl:GLInt = 0;
begin
SGLog.Sourse('TSGShader.Sourse : Begin to sourse shader "'+SGStr(FShader)+'"');// : "'+s+'"');
pc:=SGStringToPChar(s);
pcl:=SGPCharLength(pc);
if FVersion=SG_GLSL_3_0 then
	glShaderSource(FShader,1,@pc,@pcl)
else if FVersion=SG_GLSL_ARB then
	glShaderSourceARB(FShader,1,@pc,@pcl);
SGLog.Sourse('TSGShader.Sourse : Shader soursed "'+SGStr(FShader)+'"');// : "'+s+'"');
FreeMem(pc);
end;

procedure TSGShader.Compile;inline;
begin
if FVersion=SG_GLSL_3_0 then
	glCompileShader(FShader)
else if FVersion=SG_GLSL_ARB then
	begin
	glCompileShaderARB(FShader);
	PrintInfoLog;
	end;
end;

constructor TSGShader.Create(const ShaderType:LongWord = GL_VERTEX_SHADER;const Version:LongWord = SG_GLSL_ARB);
function WTS:string;
begin
if ShaderType=GL_VERTEX_SHADER then
	Result:='GL_VERTEX_SHADER'
else if ShaderType=GL_FRAGMENT_SHADER then
	Result:='GL_FRAGMENT_SHADER'
else
	Result:='UNKNOWN';
end;
begin
inherited Create;
if Version=SG_GLSL_ARB then
	begin
	if not SGIsSuppored_GL_ARB_shader_objects then
		begin
		SGLog.Sourse('Fatal error: TSGShader.Create : "GL_ARB_shader_objects" is not suppored!');
		raise Exception.Create('TSGShader : "GL_ARB_shader_objects" is not suppored!');
		end
	else
		begin
		FShader:=glCreateShaderObjectARB(ShaderType);
		end;
	end
else if Version = SG_GLSL_3_0 then
	begin
	if not SGIsSuppored_GL_version_3_0 then
		begin
		SGLog.Sourse('Fatal error: TSGShader.Create : "GL_version_3_0" is not suppored!');
		raise Exception.Create('TSGShader : "GL_version_3_0" is not suppored!');
		end
	else
		begin
		FShader:=glCreateShader(ShaderType);
		end;
	end
else
	begin
	SGLog.Sourse('Fatal error: TSGShader.Create : Unknown Version format!');
	raise Exception.Create('TSGShader.Create : Unknown Version format!');
	end;
FType:=ShaderType;
FVersion:=Version;
SGLog.Sourse('TSGShader.Create : Create Shader "'+SGStr(FShader)+'" as "'+WTS+'"');
end;
destructor TSGShader.Destroy;
begin
if FVersion=SG_GLSL_3_0 then
	glDeleteShader(FShader)
else if FVersion=SG_GLSL_ARB then
	glDeleteObjectARB(FShader);
FType:=0;
FVersion:=0;
inherited;
end;


end.
