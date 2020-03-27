{$INCLUDE Smooth.inc}

//{$DEFINE S_DEBUG_SHADERS}
{$IFDEF S_DEBUG_SHADERS}
	{$DEFINE S_BASE_DEBUG_SHADERS}
{$ELSE}
	//{$DEFINE S_BASE_DEBUG_SHADERS}
{$ENDIF}

unit SmoothShaders;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothRenderBase
	;
type
	TSShaderProgram = class;
	TSShader = class(TSContextObject)
			public
		constructor Create(const VContext : ISContext;const ShaderType:LongWord = SR_VERTEX_SHADER);
		destructor Destroy();override;
		function Compile():TSBoolean;inline;
		procedure Source(const S : TSString);overload;
		procedure PrintInfoLog();
			private
		FShader : TSLongWord;
		FType   : TSLongWord;
			public
		property Shader : TSLongWord read FShader;
		property Handle : TSLongWord read FShader;
			public
		function StringType() : TSString;
		end;
	
	TSShaderProgram = class(TSContextObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy;override;
		procedure Attach(const NewShader:TSShader);
		function Link():TSBoolean;
		procedure PrintInfoLog();
		procedure Use();
		function GetUniformLocation(const VLocationName : PSChar): TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function GetUniformLocation(const VLocationName : TSString): TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
			private
		FProgram : TSLongWord;
		FShaders :
			packed array of
				TSShader;
			public
		property Handle : TSLongWord read FProgram;
		end;

procedure SShaderLog(const VLog : PSChar);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SShaderLog(const VLog : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SCreateShaderProgramFromSources(const Context : ISContext;const VVertexSource, VFragmentSource : TSString): TSShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	,SmoothLog
	;

procedure SShaderLog(const VLog : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Stream : TMemoryStream = nil;
	Str : TSString;
begin
Stream := SStringToStream(VLog);
Stream.Position := 0;
repeat
Str := '';
Str := SReadStringFromStream(Stream);
if Str <> '' then
	SLog.Source('     ' + Str, False);
until (Stream.Size = Stream.Position);
Stream.Destroy();
end;

procedure SShaderLog(const VLog : PSChar);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SShaderLog(SPCharToString(VLog));
end;

function SCreateShaderProgramFromSources(const Context : ISContext;const VVertexSource, VFragmentSource : TSString): TSShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	FFragmentShader, FVertexShader : TSShader;
begin
Result := nil;

FVertexShader := TSShader.Create(Context, SR_VERTEX_SHADER);
FVertexShader.Source(VVertexSource);
if not FVertexShader.Compile() then
	FVertexShader.PrintInfoLog();

FFragmentShader := TSShader.Create(Context, SR_FRAGMENT_SHADER);
FFragmentShader.Source(VFragmentSource);
if not FFragmentShader.Compile() then
	FFragmentShader.PrintInfoLog();

Result := TSShaderProgram.Create(Context);
Result.Attach(FVertexShader);
Result.Attach(FFragmentShader);
if not Result.Link() then
	Result.PrintInfoLog();
end;

//==============================//
//=======TSShaderProgram=======//
//==============================//

function TSShaderProgram.GetUniformLocation(const VLocationName : TSString): TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	c : PChar;
begin
c := SStringToPChar(VLocationName);
Result := Render.GetUniformLocation(FProgram,c);
FreeMem(c,Length(VLocationName));
end;

function TSShaderProgram.GetUniformLocation(const VLocationName : PSChar): TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := Render.GetUniformLocation(FProgram,VLocationName);
end;

procedure TSShaderProgram.Use();
begin
Render.UseProgram(Handle);
end;

constructor TSShaderProgram.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FProgram:=Render.CreateShaderProgram();
FShaders:=nil;
end;

procedure TSShaderProgram.Attach(const NewShader:TSShader);
begin
if FShaders=nil then
	SetLength(FShaders,1)
else
	SetLength(FShaders,Length(FShaders)+1);
FShaders[High(FShaders)]:=NewShader;
Render.AttachShader(FProgram,NewShader.Shader);
end;

procedure TSShaderProgram.PrintInfoLog();
var
	MaxLength, Length: Integer;
	InfoLog: array of Char;
	i : LongInt;
	Log : TSString = '';
begin
Render.GetObjectParameteriv(FProgram, SR_OBJECT_INFO_LOG_LENGTH_ARB, @MaxLength);
if MaxLength > 1 then
	begin
	Length := MaxLength;
	SetLength(InfoLog, MaxLength);
	Render.GetInfoLog(FProgram, MaxLength, Length, @infolog[0]);
	for i := 0 to Length - 1 do
		Log += InfoLog[i];
	SLog.Source('TSShaderProgram__PrintInfoLog(). Program : ' + SStr(FProgram) + ', Log --->');
	SShaderLog(Log);
	SetLength(InfoLog, 0);
	end;
end;

function TSShaderProgram.Link():Boolean;
var
	linked : integer;
begin
Render.LinkShaderProgram(FProgram);
Render.GetObjectParameteriv(FProgram, SR_OBJECT_LINK_STATUS_ARB, @linked);
Result := linked = SR_TRUE;
{$IFDEF S_BASE_DEBUG_SHADERS}
	SLog.Source('TSShaderProgram.Link : Program="'+SStr(FProgram)+'", Result="'+SStr(Result)+'".');
	{$ENDIF}
end;

destructor TSShaderProgram.Destroy;
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
//=======TSShader=======//
//=======================//

procedure TSShader.PrintInfoLog();
var
	InfoLogLength:LongInt = 0;
	InfoLog:PChar = nil;
	CharsWritten:LongInt  = 0;
begin
Render.GetObjectParameteriv(FShader, SR_INFO_LOG_LENGTH, @InfoLogLength);
if InfoLogLength>0 then
	begin
	GetMem(InfoLog, InfoLogLength);
	Render.GetInfoLog(FShader, InfoLogLength, CharsWritten, InfoLog);
	SLog.Source(['TSShader__PrintInfoLog(). Shader : ', FShader, ', Type : ', StringType(), ', Log --->']);
	SShaderLog(InfoLog);
	FreeMem(InfoLog, InfoLogLength);
	end;
end;

procedure TSShader.Source(const S : TSString);
var
	pc:PChar = nil;
begin
{$IFDEF S_DEBUG_SHADERS}
SLog.Source('TSShader.Source : Begin to Source shader "'+SStr(FShader)+'"');// : "'+s+'"');
{$ENDIF}
pc:=SStringToPChar(s);
Render.ShaderSource(FShader, pc, SPCharLength(pc));
{$IFDEF S_DEBUG_SHADERS}
SLog.Source('TSShader.Source : Shader Sourced "'+SStr(FShader)+'"');
{$ENDIF}
FreeMem(pc);
end;

function TSShader.Compile():Boolean;inline;
var
	compiled : integer;
begin
Result := False;
Render.CompileShader(FShader);
Render.GetObjectParameteriv(FShader, SR_OBJECT_COMPILE_STATUS_ARB, @compiled);
Result := compiled = SR_TRUE;
{$IFDEF S_BASE_DEBUG_SHADERS}
	SLog.Source('TSShader.Compile : Shader="'+SStr(FShader)+'", Result="'+SStr(Result)+'", Type="'+StringType()+'"');
	{$ENDIF}
end;

function TSShader.StringType() : TSString;
begin
if FType=SR_VERTEX_SHADER then
	Result:='SR_VERTEX_SHADER'
else if FType=SR_FRAGMENT_SHADER then
	Result:='SR_FRAGMENT_SHADER'
else
	Result:='UNKNOWN';
end;

constructor TSShader.Create(const VContext : ISContext;const ShaderType:LongWord = SR_VERTEX_SHADER);
begin
inherited Create(VContext);
if Render.SupportedShaders() then
	begin
	FShader:=Render.CreateShader(ShaderType);
	end
else
	begin
	SLog.Source('TSShader.Create : Fatal error : Shaders not suppored!');
	end;
FType:=ShaderType;
{$IFDEF S_DEBUG_SHADERS}
	SLog.Source('TSShader.Create : Create Shader "'+SStr(FShader)+'" as "'+StringType()+'"');
	{$ENDIF}
end;

destructor TSShader.Destroy;
begin
if RenderAssigned() then
	Render.DeleteShader(FShader);
FType:=0;
inherited;
end;

end.
