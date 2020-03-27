{$INCLUDE Smooth.inc}

unit SmoothConsoleHashTools;

interface

uses
	 SmoothBase
	,SmoothConsoleCaller
	;

procedure SConsoleHash(const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 StrMan
	
	,SmoothHash
	,SmoothVersion
	,SmoothResourceManager
	,SmoothStringUtils
	,SmoothLog
	,SmoothFileUtils
	;

procedure SConsoleHash(const VParams : TSConcoleCallerParams = nil);

procedure PrintHashHelp(const Str : TSString = SConsoleErrorString);
begin
WriteLn('Use [--h/--help/--?] [--pht] [--eq @path_1 @path_2] [--@hash_type_1..--@hash_type_N @path].');
WriteLn('  Where @hash_type_? is a name of hash type.');
WriteLn('  Where @path is a path to file or directory to hashing.');
WriteLn('  Where param --pht used for print suppored hash types.');
WriteLn('  Where param --eq checked equals hash data in files @path_1 and @path_2.');
end;

var
	i : TSUInt32;
	Param : TSString;
	HashTypes : TSHashParam = [];
begin
SPrintEngineVersion();
if (VParams = nil) or (Length(VParams) = 0) then
	SHint('Nothink to hash!')
else
	begin
	for i := 0 to High(VParams) do
		if not ((SResourceFiles.FileExists(VParams[i]) or SExistsDirectory(VParams[i])) and (i = High(VParams))) then
			begin
			Param := SUpCaseString(StringTrimLeft(VParams[i], '-'));
			if ((Param = 'PRINTHASHTYPES') or (Param = 'PHT') or (Param = 'PRINTHASHTYPE')) and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
				begin
				SConsolePrintHashTypes();
				Halt(0);
				end
			else if ((Param = 'HELP') or (Param = 'H') or (Param = '?')) and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
				begin
				PrintHashHelp('Use ');
				Halt(0);
				end
			else if (Param = 'EQ') and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
				begin
				if (i = 0) and (Length(VParams) = 3) and SResourceFiles.FileExists(VParams[i + 1]) and SResourceFiles.FileExists(VParams[i + 2]) then
					SConsoleCheckEqualsDirectoryData(VParams[i + 1], VParams[i + 2])
				else
					begin
					PrintHashHelp();
					end;
				Halt(0);
				end
			else
				begin
				if (SHashStrType(Param) <> SHashTypeNone) and (StringTrimLeft(VParams[i], '-') <> VParams[i]) then
					HashTypes += [SHashStrType(Param)]
				else
					begin
					SHint('Illegal param "' + Param + '"!');
					PrintHashHelp();
					Halt(1);
					end;
				end;
			end;
	SmoothHash.SConsoleHash(VParams[High(VParams)], HashTypes);
	end;
end;

end.
