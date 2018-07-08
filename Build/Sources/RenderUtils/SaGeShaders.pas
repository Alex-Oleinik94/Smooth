{$INCLUDE SaGe.inc}

//{$DEFINE SG_DEBUG_SHADERS}
{$IFDEF SG_DEBUG_SHADERS}
	{$DEFINE SG_BASE_DEBUG_SHADERS}
{$ELSE}
	//{$DEFINE SG_BASE_DEBUG_SHADERS}
{$ENDIF}

unit SaGeShaders;

interface

uses
	 Classes
	
	,SaGeBase
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeRenderBase
	;
type
	TSGShaderProgram = class;
	TSGShader = class(TSGContextObject)
			public
		constructor Create(const VContext : ISGContext;const ShaderType:LongWord = SGR_VERTEX_SHADER);
		destructor Destroy();override;
		function Compile():TSGBoolean;inline;
		procedure Source(const S : TSGString);overload;
		procedure PrintInfoLog();
			private
		FShader : TSGLongWord;
		FType   : TSGLongWord;
			public
		property Shader : TSGLongWord read FShader;
		property Handle : TSGLongWord read FShader;
			public
		function StringType() : TSGString;
		end;
	
	TSGShaderProgram = class(TSGContextObject)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy;override;
		procedure Attach(const NewShader:TSGShader);
		function Link():TSGBoolean;
		procedure PrintInfoLog();
		procedure Use();
		function GetUniformLocation(const VLocationName : PSGChar): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function GetUniformLocation(const VLocationName : TSGString): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
			private
		FProgram : TSGLongWord;
		FShaders :
			packed array of
				TSGShader;
			public
		property Handle : TSGLongWord read FProgram;
		end;

procedure SGShaderLog(const VLog : PSGChar);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGShaderLog(const VLog : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGCreateShaderProgramFromSources(const Context : ISGContext;const VVertexSource, VFragmentSource : TSGString): TSGShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	,SaGeLog
	;

procedure SGShaderLog(const VLog : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Stream : TMemoryStream = nil;
	Str : TSGString;
begin
Stream := SGStringToStream(VLog);
Stream.Position := 0;
repeat
Str := '';
Str := SGReadStringFromStream(Stream);
if Str <> '' then
	SGLog.Source('     ' + Str, False);
until (Stream.Size = Stream.Position);
Stream.Destroy();
end;

procedure SGShaderLog(const VLog : PSGChar);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SGShaderLog(SGPCharToString(VLog));
end;

function SGCreateShaderProgramFromSources(const Context : ISGContext;const VVertexSource, VFragmentSource : TSGString): TSGShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	FFragmentShader, FVertexShader : TSGShader;
begin
Result := nil;

FVertexShader := TSGShader.Create(Context, SGR_VERTEX_SHADER);
FVertexShader.Source(VVertexSource);
if not FVertexShader.Compile() then
	FVertexShader.PrintInfoLog();

FFragmentShader := TSGShader.Create(Context, SGR_FRAGMENT_SHADER);
FFragmentShader.Source(VFragmentSource);
if not FFragmentShader.Compile() then
	FFragmentShader.PrintInfoLog();

Result := TSGShaderProgram.Create(Context);
Result.Attach(FVertexShader);
Result.Attach(FFragmentShader);
if not Result.Link() then
	Result.PrintInfoLog();
end;

//==============================//
//=======TSGShaderProgram=======//
//==============================//

function TSGShaderProgram.GetUniformLocation(const VLocationName : TSGString): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	c : PChar;
begin
c := SGStringToPChar(VLocationName);
Result := Render.GetUniformLocation(FProgram,c);
FreeMem(c,Length(VLocationName));
end;

function TSGShaderProgram.GetUniformLocation(const VLocationName : PSGChar): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := Render.GetUniformLocation(FProgram,VLocationName);
end;

procedure TSGShaderProgram.Use();
begin
Render.UseProgram(Handle);
end;

constructor TSGShaderProgram.Create(const VContext : ISGContext);
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
	Log : TSGString = '';
begin
Render.GetObjectParameteriv(FProgram, SGR_OBJECT_INFO_LOG_LENGTH_ARB, @MaxLength);
if MaxLength > 1 then
	begin
	Length := MaxLength;
	SetLength(InfoLog, MaxLength);
	Render.GetInfoLog(FProgram, MaxLength, Length, @infolog[0]);
	for i := 0 to Length - 1 do
		Log += InfoLog[i];
	SGLog.Source('TSGShaderProgram__PrintInfoLog(). Program : ' + SGStr(FProgram) + ', Log --->');
	SGShaderLog(Log);
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
{$IFDEF SG_BASE_DEBUG_SHADERS}
	SGLog.Source('TSGShaderProgram.Link : Program="'+SGStr(FProgram)+'", Result="'+SGStr(Result)+'".');
	{$ENDIF}
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
if RenderAssigned() then
	Render.DeleteShaderProgram(FProgram);
inherited;
end;

//=======================//
//=======TSGShader=======//
//=======================//

procedure TSGShader.PrintInfoLog();
var
	InfoLogLength:LongInt = 0;
	InfoLog:PChar = nil;
	CharsWritten:LongInt  = 0;
begin
Render.GetObjectParameteriv(FShader, SGR_INFO_LOG_LENGTH, @InfoLogLength);
if InfoLogLength>0 then
	begin
	GetMem(InfoLog, InfoLogLength);
	Render.GetInfoLog(FShader, InfoLogLength, CharsWritten, InfoLog);
	SGLog.Source(['TSGShader__PrintInfoLog(). Shader : ', FShader, ', Type : ', StringType(), ', Log --->']);
	SGShaderLog(InfoLog);
	FreeMem(InfoLog, InfoLogLength);
	end;
end;

procedure TSGShader.Source(const S : TSGString);
var
	pc:PChar = nil;
begin
{$IFDEF SG_DEBUG_SHADERS}
SGLog.Source('TSGShader.Source : Begin to Source shader "'+SGStr(FShader)+'"');// : "'+s+'"');
{$ENDIF}
pc:=SGStringToPChar(s);
Render.ShaderSource(FShader, pc, SGPCharLength(pc));
{$IFDEF SG_DEBUG_SHADERS}
SGLog.Source('TSGShader.Source : Shader Sourced "'+SGStr(FShader)+'"');
{$ENDIF}
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
{$IFDEF SG_BASE_DEBUG_SHADERS}
	SGLog.Source('TSGShader.Compile : Shader="'+SGStr(FShader)+'", Result="'+SGStr(Result)+'", Type="'+StringType()+'"');
	{$ENDIF}
end;

function TSGShader.StringType() : TSGString;
begin
if FType=SGR_VERTEX_SHADER then
	Result:='SGR_VERTEX_SHADER'
else if FType=SGR_FRAGMENT_SHADER then
	Result:='SGR_FRAGMENT_SHADER'
else
	Result:='UNKNOWN';
end;

constructor TSGShader.Create(const VContext : ISGContext;const ShaderType:LongWord = SGR_VERTEX_SHADER);
begin
inherited Create(VContext);
if Render.SupporedShaders() then
	begin
	FShader:=Render.CreateShader(ShaderType);
	end
else
	begin
	SGLog.Source('TSGShader.Create : Fatal error : Shaders not suppored!');
	end;
FType:=ShaderType;
{$IFDEF SG_DEBUG_SHADERS}
	SGLog.Source('TSGShader.Create : Create Shader "'+SGStr(FShader)+'" as "'+StringType()+'"');
	{$ENDIF}
end;

destructor TSGShader.Destroy;
begin
if RenderAssigned() then
	Render.DeleteShader(FShader);
FType:=0;
inherited;
end;

end.
