{$INCLUDE SaGe.inc}

unit SaGeConsoleShaderTools;

interface

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleShaderReadWrite                       (const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 StrMan
	
	,SaGeVersion
	,SaGeResourceManager
	,SaGeShaders
	,SaGeShaderReader
	;

procedure SGConsoleShaderReadWrite(const VParams : TSGConcoleCallerParams = nil);
var
	i, ii : TSGLongWord;
	Params : TSGConcoleCallerParams;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii >= 2) and SGResourceFiles.FileExists(VParams[0]) then
	begin
	SetLength(Params,Length(VParams)-2);
	if Length(Params)>0 then
		for i := 2 to High(VParams) do
			Params[i-2] := VParams[i];
	SGReadAndSaveShaderSourceFile(VParams[0], VParams[1], Params);
	SetLength(Params,0);
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@infile @outfile [@shaderParam(0)..@shaderParam(i)]"');
	end;
end;

end.
