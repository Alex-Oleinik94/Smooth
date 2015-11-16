{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex15;
	interface
{$ELSE}
	program Example15;
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
	,SaGeRender
	,SaGeUtils
	,SaGeScreen
	,SaGeMesh
	,SaGeCommon
	,Classes
	,SysUtils
	,SaGeShaders
	,SaGePhysics
	;
{-$DEFINE USEINLINE}
type
	TSGExample15 = class;
	TGasSourse = packed record
		FPosition : TSGPoint3f;
		FSize : TSGByte;
		FGasPointer : TSGLongWord;
		end;
	TThread = packed record
		FThread : TSGThread;
		FRunning : TSGBoolean;
		FBeginPointer, FEndPointer : TSGLongWord;
		FNeedExit : TSGBoolean;
		FClass : TSGExample15;
		end;
	TArray = packed array of TSGLongWord;
	TSGExample15 = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		
		FSize  : TSGLongWord; 
		FArray : TArray;
		FGases : packed array of TSGColor3f;
		FSourses : packed array of TGasSourse;
		FFlag : TSGBoolean;
		
		FMesh : TSG3DObject;
		FShader : TSGShaderProgram;
		
		FThreadsCount : TSGLongWord;
		FThreads : packed array of TThread;
			public
		procedure Calculate(const VBeginPos, VEndPos : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
			private
		procedure WaitForThreads();{$IFDEF USEINLINE}inline;{$ENDIF}
		procedure ResumeThreads();{$IFDEF USEINLINE}inline;{$ENDIF}
		procedure Uniform(const VUseGeses : Boolean = False);{$IFDEF USEINLINE}inline;{$ENDIF}
		procedure CalculateMesh(const VSize : TSGFloat = 1);{$IFDEF USEINLINE}inline;{$ENDIF}
		procedure AddGasSourse(const VPosition : TSGPoint3f; const VSize : TSGLongWord; const VGas : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
		function AddGasType(const VColor : TSGColor3f):TSGLongWord;{$IFDEF USEINLINE}inline;{$ENDIF}
		procedure SetSize(const FNewSize : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
		procedure StartThreads(const VCount : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
		procedure CalcuteteShader();{$IFDEF USEINLINE}inline;{$ENDIF}
		end;



{$IFDEF ENGINE}
	function SGPoint3fImport(const x1,y1,z1 : TSGLongInt):TSGPoint3f;{$IFDEF USEINLINE}inline;{$ENDIF}
	
	implementation
	{$ENDIF}

function SGPoint3fImport(const x1,y1,z1 : TSGLongInt):TSGPoint3f;{$IFDEF USEINLINE}inline;{$ENDIF}
begin
Result.Import(x1,y1,z1);
end;

procedure TSGExample15.CalcuteteShader();{$IFDEF USEINLINE}inline;{$ENDIF}

function CalcVertexShader(): TSGString;  {$IFDEF USEINLINE}inline;{$ENDIF}
begin
Result := '';
end;

function CalcFragmentShader(): TSGString; {$IFDEF USEINLINE}inline;{$ENDIF}
begin
Result := '';
end;

begin
if FShader <> nil then
	FShader.Destroy();
FShader := SGCreateShaderProgramFromSourses(Context,
	CalcVertexShader(),
	CalcFragmentShader());
end;

procedure TSGExample15.Calculate(const VBeginPos, VEndPos : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
begin

end;

procedure TSGExample15ThreadProc(var VThread : TThread);

procedure WaitForMainThread();{$IFDEF USEINLINE}inline;{$ENDIF}
begin
while not VThread.FRunning do
	SysUtils.Sleep(2);
end;

begin
while not VThread.FNeedExit do
	begin
	WaitForMainThread();
	VThread.FClass.Calculate(VThread.FBeginPointer,VThread.FEndPointer);
	VThread.FRunning := False;
	end;
end;

procedure TSGExample15.StartThreads(const VCount : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
var
	i, ii, iii, iiii : TSGLongWord;
begin
iiii := FSize * FSize;
FThreadsCount := VCount;
SetLength(FThreads, FThreadsCount);
if FThreadsCount <> 0 then
	for i := 0 to FThreadsCount - 1 do
		begin
		FThreads[i].FThread := TSGThread.Create(TSGThreadProcedure(@TSGExample15ThreadProc), @FThreads[i], False);
		FThreads[i].FRunning := False;
		FThreads[i].FNeedExit := False;
		ii := Round(iiii / FThreadsCount * i);
		iii := Round(iiii / FThreadsCount * (i + 1));
		FThreads[i].FBeginPointer := ii;
		FThreads[i].FEndPointer := iii - 1;
		FThreads[i].FClass := Self;
		FThreads[i].FThread.Start();
		end;
end;

procedure TSGExample15.SetSize(const FNewSize : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
FSize := FNewSize;
i := FSize * FSize * FSize;
SetLength(FArray, i);
if (i <> 0) then
	FillChar(FArray[0],4 * i, 0);
end;

procedure TSGExample15.AddGasSourse(const VPosition : TSGPoint3f; const VSize : TSGLongWord; const VGas : TSGLongWord);{$IFDEF USEINLINE}inline;{$ENDIF}
begin
if FSourses <> nil then
	SetLength(FSourses,Length(FSourses)+1)
else
	SetLength(FSourses,1);
FSourses[High(FSourses)].FPosition := VPosition;
FSourses[High(FSourses)].FSize := VSize;
FSourses[High(FSourses)].FGasPointer := VGas;
end;

function TSGExample15.AddGasType(const VColor : TSGColor3f):TSGLongWord;{$IFDEF USEINLINE}inline;{$ENDIF}
begin
if FGases <> nil then
	SetLength(FGases,Length(FGases)+1)
else
	SetLength(FGases,1);
FGases[High(FGases)] := VColor;
Result := Length(FGases);
end;

procedure TSGExample15.WaitForThreads();{$IFDEF USEINLINE}inline;{$ENDIF}

function ThreadsReady() : TSGBoolean;{$IFDEF USEINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := True;
for i := 0 to FThreadsCount - 1 do
	begin
	if FThreads[i].FRunning then
		begin
		Result := False;
		break;
		end;
	end;
end;

begin
while not ThreadsReady() do
	SysUtils.Sleep(2);
end;

procedure TSGExample15.ResumeThreads();{$IFDEF USEINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
for i := 0 to FThreadsCount - 1 do
	FThreads[i].FRunning := True;
end;

procedure TSGExample15.Uniform(const VUseGeses : Boolean = False);{$IFDEF USEINLINE}inline;{$ENDIF}
begin
if VUseGeses then
	begin
	
	end;

end;

procedure TSGExample15.CalculateMesh(const VSize : TSGFloat = 1);{$IFDEF USEINLINE}inline;{$ENDIF}
var
	i, ii, iii : TSGLongWord;
	d : TSGFloat;
begin
d := VSize / 2.0;

FMesh := TSG3DObject.Create();
FMesh.Context := Context;
FMesh.CountTextureFloatsInVertexArray := 2;
FMesh.ObjectPoligonesType := SGR_POINTS;
FMesh.HasNormals := False;
FMesh.SetColorType(SGMeshColorType3f);
FMesh.HasTexture := False;
FMesh.HasColors  := False;
FMesh.EnableCullFace := True;
FMesh.EnableCullFaceFront := False;
FMesh.EnableCullFaceBack := True;
FMesh.VertexType := SGMeshVertexType4f;

FMesh.Vertexes   := FSize * FSize * FSize;
for i := 0 to FSize - 1 do
	for ii := 0 to FSize - 1 do
		for iii := 0 to FSize - 1 do
			begin
			FMesh.ArVertex4f[i + ii * FSize + iii * FSize * FSize]^.Import(
				- d + VSize * (i / (FSize - 1)),
				- d + VSize * (i / (FSize - 1)),
				- d + VSize * (i / (FSize - 1)),
				(i + ii * FSize + iii * FSize * FSize) / 255);
			end;

FMesh.LoadToVBO();
end;

class function TSGExample15.ClassName():TSGString;
begin
Result := 'Test Gas Diffusion With Shaders';
end;

constructor TSGExample15.Create(const VContext : TSGContext);
var
	i : TSGLongWord;
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.Context := Context;

FMesh := nil;
FShader := nil;
FGases := nil;
FSourses := nil;
FFlag := False;

SetSize(75);
AddGasSourse(SGPoint3fImport(trunc(FSize * 0.33),trunc(FSize * 0.33),trunc(FSize * 0.33)),5,AddGasType(SGColorImport(1,0,0)));
AddGasSourse(SGPoint3fImport(trunc(FSize * 0.66),trunc(FSize * 0.66),trunc(FSize * 0.66)),5,AddGasType(SGColorImport(0,1,0)));

CalcuteteShader();

FShader.Use();
Uniform(True);
Render.UseProgram(0);

CalculateMesh(5);
end;

destructor TSGExample15.Destroy();
begin
FCamera.Destroy();
inherited;
end;

procedure TSGExample15.Draw();
begin
WaitForThreads();
FShader.Use();
Uniform();
ResumeThreads();
FCamera.CallAction();
FMesh.Draw();
Render.UseProgram(0);
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample15;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
