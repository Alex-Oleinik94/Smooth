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

type
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
		
		FMesh : TSG3DObject;
		FShader : TSGShaderProgram;
		
		FThreadsCount : TSGLongWord;
		FThreads : packed array of TSGThread;
			private
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

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

FSize := 75;
SetLength(FArray, FSize * FSize * FSize);
fillchar(FArray[0],4 * FSize * FSize * FSize, 0);

SetLength(FGases, 2);
FGases[0].Import(1,0,0);
FGases[1].Import(0,1,0);

FThreadsCount := 4;
SetLength(FThreads, FThreadsCount);
for i := 0 to FThreadsCount - 1 do
	begin
	
	end;
end;

destructor TSGExample15.Destroy();
begin
FCamera.Destroy();
inherited;
end;

procedure TSGExample15.Draw();
begin
FCamera.CallAction();

end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample15;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
