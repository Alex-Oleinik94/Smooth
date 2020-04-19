{$INCLUDE Smooth.inc}

unit SmoothConsoleProgramDynamicHeadersMaker;

interface

uses
	 SmoothBase
	,SmoothConsoleHandler
	;

procedure SConsoleDynamicHeadersMaker(const VParams : TSConsoleHandlerParams = nil);

implementation

uses
	 StrMan
	
	,SmoothVersion
	,SmoothResourceManager
	,SmoothDynamicHeadersMaker
	,SmoothStringUtils
	;

procedure SConsoleDynamicHeadersMaker(const VParams : TSConsoleHandlerParams = nil);

function ParamIsMode(const VParam : TSString): TSBool;
var
	UpCasedParam : TSString;
begin
UpCasedParam := SUpCaseString(VParam);
Result := ((UpCasedParam = SDDHModeObjFpc) or (UpCasedParam = SDDHModeDelphi) or (UpCasedParam = SDDHModeFpc));
end;

function ParamIsWriteMode(const VParam : TSString):TSBool;
var
	UpCasedParam : TSString;
begin
UpCasedParam := SUpCaseString(VParam);
Result := ((UpCasedParam = SDDHWriteModeFpc) or (UpCasedParam = SDDHWriteModeSmooth) or (UpCasedParam = SDDHWriteModeObjectSmooth));
end;

function IsNullUtil() : TSBool;
begin
Result := (Length(VParams) = 4) and (SResourceFiles.FileExists(VParams[1])) and ParamIsMode(VParams[3]);
if not Result then
	Result := (Length(VParams) = 3) and (SResourceFiles.FileExists(VParams[1]));
if Result then
	Result := SUpCaseString(StringTrimLeft(VParams[0], '-')) = 'NU';
end;

begin
if (Length(VParams) = 2) and (SResourceFiles.FileExists(VParams[0])) then
	SDynamicHeadersMaker(VParams[0], VParams[1])
else if (Length(VParams) = 4) and (SResourceFiles.FileExists(VParams[0])) and ParamIsMode(VParams[2]) and ParamIsWriteMode(VParams[3]) then
	SDynamicHeadersMaker(VParams[0], VParams[1], VParams[2], VParams[3])
else if (Length(VParams) = 3) and (SResourceFiles.FileExists(VParams[0])) and ParamIsWriteMode(VParams[2]) then
	SDynamicHeadersMaker(VParams[0], VParams[1], SDDHModeDef, VParams[2])
else if (Length(VParams) = 3) and (SResourceFiles.FileExists(VParams[0])) and ParamIsMode(VParams[2]) then
	SDynamicHeadersMaker(VParams[0], VParams[1], VParams[2])
else if IsNullUtil() then
	if (Length(VParams) = 3) then
		TSDoDynamicHeader.NullUtil(VParams[1], VParams[2])
	else
		TSDoDynamicHeader.NullUtil(VParams[1], VParams[2], VParams[3])
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"[--nu] @infilename @outfilename [@mode] [@write_mode]". ');
	WriteLn('Param @mode is in set of "',SDDHModeObjFpc,'", "',SDDHModeFpc,'" or "',SDDHModeDelphi,'".');
	WriteLn('Param @write_mode is in set of "',SDDHWriteModeFpc,'", "',SDDHWriteModeSmooth,'" or "',SDDHWriteModeObjectSmooth,'".');
	end;
end;
end.
