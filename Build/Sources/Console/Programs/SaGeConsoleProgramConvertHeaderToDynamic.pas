{$INCLUDE SaGe.inc}

unit SaGeConsoleProgramConvertHeaderToDynamic;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeConsoleToolsBase
	;

procedure SGConsoleConvertHeaderToDynamic(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	StrMan
	
	,SaGeVersion
	,SaGeResourceManager
	,SaGeConvertHeaderToDynamic
	;

procedure SGConsoleConvertHeaderToDynamic(const VParams : TSGConcoleCallerParams = nil);

function ParamIsMode(const VParam : TSGString): TSGBool;
var
	UpCasedParam : TSGString;
begin
UpCasedParam := SGUpCaseString(VParam);
Result := ((UpCasedParam = SGDDHModeObjFpc) or (UpCasedParam = SGDDHModeDelphi) or (UpCasedParam = SGDDHModeFpc));
end;

function ParamIsWriteMode(const VParam : TSGString):TSGBool;
var
	UpCasedParam : TSGString;
begin
UpCasedParam := SGUpCaseString(VParam);
Result := ((UpCasedParam = SGDDHWriteModeFpc) or (UpCasedParam = SGDDHWriteModeSaGe) or (UpCasedParam = SGDDHWriteModeObjectSaGe));
end;

function IsNullUtil() : TSGBool;
begin
Result := (Length(VParams) = 4) and (SGResourceFiles.FileExists(VParams[1])) and ParamIsMode(VParams[3]);
if not Result then
	Result := (Length(VParams) = 3) and (SGResourceFiles.FileExists(VParams[1]));
if Result then
	Result := SGUpCaseString(StringTrimLeft(VParams[0], '-')) = 'NU';
end;

begin
if (Length(VParams) = 2) and (SGResourceFiles.FileExists(VParams[0])) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1])
else if (Length(VParams) = 4) and (SGResourceFiles.FileExists(VParams[0])) and ParamIsMode(VParams[2]) and ParamIsWriteMode(VParams[3]) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1], VParams[2], VParams[3])
else if (Length(VParams) = 3) and (SGResourceFiles.FileExists(VParams[0])) and ParamIsWriteMode(VParams[2]) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1], SGDDHModeDef, VParams[2])
else if (Length(VParams) = 3) and (SGResourceFiles.FileExists(VParams[0])) and ParamIsMode(VParams[2]) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1], VParams[2])
else if IsNullUtil() then
	if (Length(VParams) = 3) then
		TSGDoDynamicHeader.NullUtil(VParams[1], VParams[2])
	else
		TSGDoDynamicHeader.NullUtil(VParams[1], VParams[2], VParams[3])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"[--nu] @infilename @outfilename [@mode] [@write_mode]". ');
	WriteLn('Param @mode is in set of "',SGDDHModeObjFpc,'", "',SGDDHModeFpc,'" or "',SGDDHModeDelphi,'".');
	WriteLn('Param @write_mode is in set of "',SGDDHWriteModeFpc,'", "',SGDDHWriteModeSaGe,'" or "',SGDDHWriteModeObjectSaGe,'".');
	end;
end;
end.
