{$INCLUDE SaGe.inc}

unit SaGeConsoleProgramEngineRenamer;

interface

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleEngineRenamer(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 SaGeStringUtils
	,SaGeConsoleTools
	;

procedure SGConsoleEngineRenamer(const VParams : TSGConcoleCallerParams = nil);
var
	FileExtensions : TSGStringList = nil;
	Words : TSGStringList = nil;
	Replacements : TSGStringList = nil;
	Separators : TSGStringList = nil;

function DecodeParams() : TSGBool;

function AddReplacement(const Param : TSGString) : TSGBool;
var
	Value : TSGString;
begin
Result := False;
Value := SGParseValueFromComand(Param, ['r:','replacement:']);
Result := Value <> '';
if Result then
	Replacements += Value;
end;

function AddWord(const Param : TSGString) : TSGBool;
var
	Value : TSGString;
begin
Result := False;
Value := SGParseValueFromComand(Param, ['w:','word:']);
Result := Value <> '';
if Result then
	Words += Value;
end;

begin
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSGConsoleCaller.Create(VParams) do
		begin
		AddComand(@AddReplacement, ['r:','replacement:'], 'Add Replacement');
		AddComand(@AddWord,        ['w:','word:'],        'Add Word');
		Result := Execute();
		Destroy();
		end;
end;

procedure SeparatorsSorting();
begin

end;

begin
if DecodeParams() then
	begin
	SeparatorsSorting();
	
	end;
end;

initialization
begin
SGOtherConsoleCaller.AddComand('Other tools', @SGConsoleEngineRenamer, ['enginerenamer', 'ern'], 'Launch engine renamer');
end;

end.
