{$INCLUDE Includes\SaGe.inc}

unit SaGeShaders;

interface
uses
	crt
	,SaGeBase
	,SaGeBased
	,SaGeCommon
	,SysUtils
	,SaGeRender
	,SaGeContext
	;
type
	TSGShaderProgram=class;
	TSGShader=class(TSGContextObject)
			public
		constructor Create(const VContext:TSGContext;const ShaderType:LongWord = SGR_VERTEX_SHADER);
		destructor Destroy();override;
		function Compile():Boolean;inline;
		procedure Sourse(const s:string);overload;
		procedure PrintInfoLog();
			private
		FShader : TSGLongWord;
		FType   : TSGLongWord;
			public
		property Shader : TSGLongWord read FShader;
		property Handle : TSGLongWord read FShader;
		end;
	TSGShaderProgram=class(TSGContextObject)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy;override;
		procedure Attach(const NewShader:TSGShader);
		function Link():Boolean;
		procedure PrintInfoLog();
		procedure Use();
			private
		FProgram : TSGLongWord;
		FShaders :
			packed array of
				TSGShader;
			public
		property Handle : TSGLongWord read FProgram;
		end;

implementation

procedure TSGShaderProgram.Use();
begin
Render.UseProgram(Handle);
end;

constructor TSGShaderProgram.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FProgram:=Render.CreateShaderProgram();
FShaders:=nil;
end;

procedure TSGShaderProgram.Attach(const NewShader:TSGShader);
begin
if FShaders=nil then
	SetLength(FShaders,1)
else
	SetLength(FShaders,Length(FShaders)+1);
FShaders[High(FShaders)]:=NewShader;
Render.AttachShader(FProgram,NewShader.Shader);
end;

procedure TSGShaderProgram.PrintInfoLog();
var
	MaxLength, Length: Integer;
	InfoLog: array of Char;
	i : LongInt;
	Log : String = '';
begin
Render.GetObjectParameteriv(FProgram, SGR_OBJECT_INFO_LOG_LENGTH_ARB, @MaxLength);
if MaxLength > 1 then
	begin
	Length := MaxLength;
	SetLength(InfoLog, MaxLength);
	Render.GetInfoLog(FProgram, MaxLength, Length, @infolog[0]);
	for i := 0 to High(InfoLog) do
		if (InfoLog[i] = #13) then
			Log += '/n'
		else if (InfoLog[i] <> #10) then
			Log += InfoLog[i];
	SGLog.Sourse('TSGShaderProgram.PrintInfoLog : Program="'+SGStr(FProgram)+'", Log="'+Log+'".');
	SetLength(InfoLog, 0);
	end;
end;

function TSGShaderProgram.Link():Boolean;
var
	linked : integer;
begin
Render.LinkShaderProgram(FProgram);
Render.GetObjectParameteriv(FProgram, SGR_OBJECT_LINK_STATUS_ARB, @linked);
Result := linked = SGR_TRUE;
SGLog.Sourse('TSGShaderProgram.Link : Program="'+SGStr(FProgram)+'", Result="'+SGStr(Result)+'".');
end;

destructor TSGShaderProgram.Destroy;
var
	i:LongWord;
begin
if FShaders<>nil then
	begin
	for i:=0 to High(FShaders) do
		FShaders[i].Destroy;
	SetLength(FShaders,0);
	end;
Render.DeleteShaderProgram(FProgram);
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
Render.GetObjectParameteriv(FShader, SGR_INFO_LOG_LENGTH,@InfoLogLength);
if InfoLogLength>0 then
	begin
	GetMem(InfoLog,InfoLogLength);
	Render.GetInfoLog(FShader, InfoLogLength, CharsWritten, InfoLog);
	SGLog.Sourse('TSGShader.PrintInfoLog : "'+SGPCharToString(InfoLog)+'".');
	FreeMem(InfoLog,InfoLogLength);
	end;
end;
procedure TSGShader.Sourse(const s:string);
var
	pc:PChar = nil;
	pcl:integer = 0;
begin
SGLog.Sourse('TSGShader.Sourse : Begin to sourse shader "'+SGStr(FShader)+'"');// : "'+s+'"');
pc:=SGStringToPChar(s);
Render.ShaderSource(FShader,pc,SGPCharLength(pc));
SGLog.Sourse('TSGShader.Sourse : Shader soursed "'+SGStr(FShader)+'"');
FreeMem(pc);
end;

function TSGShader.Compile():Boolean;inline;
var
	compiled : integer;
begin
Result := False;
Render.CompileShader(FShader);
Render.GetObjectParameteriv(FShader, SGR_OBJECT_COMPILE_STATUS_ARB, @compiled);
Result := compiled = SGR_TRUE;
SGLog.Sourse('TSGShader.Compile : Shader="'+SGStr(FShader)+'", Result="'+SGStr(Result)+'"');
end;

constructor TSGShader.Create(const VContext:TSGContext;const ShaderType:LongWord = SGR_VERTEX_SHADER);
function WTS:string;
begin
if ShaderType=SGR_VERTEX_SHADER then
	Result:='SGR_VERTEX_SHADER'
else if ShaderType=SGR_FRAGMENT_SHADER then
	Result:='SGR_FRAGMENT_SHADER'
else
	Result:='UNKNOWN';
end;
begin
(Self as TSGContextObject).Create(VContext);
if Render.ShadersSuppored() then
	begin
	FShader:=Render.CreateShader(ShaderType);
	end
else
	begin
	SGLog.Sourse('Fatal error: TSGShader.Create : Shaders not suppored!');
	end;
FType:=ShaderType;
SGLog.Sourse('TSGShader.Create : Create Shader "'+SGStr(FShader)+'" as "'+WTS+'"');
end;
destructor TSGShader.Destroy;
begin
Render.DeleteShader(FShader);
FType:=0;
inherited;
end;

end.
