{$INCLUDE SaGe.inc}

unit SaGeConsoleHashTools;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeConsoleToolsBase
	;

procedure SGConsoleHash(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	StrMan
	
	,SaGeHash
	,SaGeVersion
	,SaGeResourceManager
	,SaGeStringUtils
	;

procedure SGConsoleHash(const VParams : TSGConcoleCallerParams = nil);

procedure PrintHashHelp(const Str : TSGString = SGConsoleErrorString);
begin
WriteLn('Use [--h/--help/--?] [--pht] [--eq @path_1 @path_2] [--@hash_type_1..--@hash_type_N @path].');
WriteLn('  Where @hash_type_? is a name of hash type.');
WriteLn('  Where @path is a path to file or directory to hashing.');
WriteLn('  Where param --pht used for print suppored hash types.');
WriteLn('  Where param --eq checked equals hash data in files @path_1 and @path_2.');
end;

var
	i : TSGUInt32;
	Param : TSGString;
	HashTypes : TSGHashParam = [];
begin
SGPrintEngineVersion();
if (VParams = nil) or (Length(VParams) = 0) then
	SGHint('Nothink to hash!')
else
	begin
	for i := 0 to High(VParams) do
		if not ((SGResourceFiles.FileExists(VParams[i]) or SGExistsDirectory(VParams[i])) and (i = High(VParams))) then
			begin
			Param := SGUpCaseString(StringTrimLeft(VParams[i], '-'));
			if ((Param = 'PRINTHASHTYPES') or (Param = 'PHT') or (Param = 'PRINTHASHTYPE')) and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
				begin
				SGConsolePrintHashTypes();
				Halt(0);
				end
			else if ((Param = 'HELP') or (Param = 'H') or (Param = '?')) and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
				begin
				PrintHashHelp('Use ');
				Halt(0);
				end
			else if (Param = 'EQ') and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
				begin
				if (i = 0) and (Length(VParams) = 3) and SGResourceFiles.FileExists(VParams[i + 1]) and SGResourceFiles.FileExists(VParams[i + 2]) then
					SGConsoleCheckEqualsDirectoryData(VParams[i + 1], VParams[i + 2])
				else
					begin
					PrintHashHelp();
					end;
				Halt(0);
				end
			else
				begin
				if (SGHashStrType(Param) <> SGHashTypeNone) and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
					HashTypes += [SGHashStrType(Param)]
				else
					begin
					SGHint('Illegal param "' + Param + '"!');
					PrintHashHelp();
					Halt(1);
					end;
				end;
			end;
	SaGeHash.SGConsoleHash(VParams[High(VParams)], HashTypes);
	end;
end;

end.
