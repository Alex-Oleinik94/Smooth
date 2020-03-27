{$INCLUDE Smooth.inc}

unit SmoothConsoleShaderTools;

interface

uses
	 SmoothBase
	,SmoothConsoleCaller
	;

procedure SConsoleShaderReadWrite                       (const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 StrMan
	
	,SmoothVersion
	,SmoothResourceManager
	,SmoothShaders
	,SmoothShaderReader
	;

procedure SConsoleShaderReadWrite(const VParams : TSConcoleCallerParams = nil);
var
	i, ii : TSLongWord;
	Params : TSConcoleCallerParams;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii >= 2) and SResourceFiles.FileExists(VParams[0]) then
	begin
	SetLength(Params,Length(VParams)-2);
	if Length(Params)>0 then
		for i := 2 to High(VParams) do
			Params[i-2] := VParams[i];
	SReadAndSaveShaderSourceFile(VParams[0], VParams[1], Params);
	SetLength(Params,0);
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@infile @outfile [@shaderParam(0)..@shaderParam(i)]"');
	end;
end;

end.
