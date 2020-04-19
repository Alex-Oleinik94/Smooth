{$INCLUDE Smooth.inc}

unit SmoothConsoleProgramEngineRenamer;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothConsoleHandler
	;

procedure SConsoleEngineRenamer(const VParams : TSConsoleHandlerParams = nil);

implementation

uses
	 SmoothStringUtils
	,SmoothConsoleTools
	;

procedure SConsoleEngineRenamer(const VParams : TSConsoleHandlerParams = nil);
var
	FileExtensions : TSStringList = nil;
	Words : TSStringList = nil;
	Replacements : TSStringList = nil;
	Separators : TSStringList = nil;

function DecodeParams() : TSBool;

function AddReplacement(const Param : TSString) : TSBool;
var
	Value : TSString;
begin
Result := False;
Value := SParseValueFromComand(Param, ['r:','replacement:']);
Result := Value <> '';
if Result then
	Replacements += Value;
end;

function AddWord(const Param : TSString) : TSBool;
var
	Value : TSString;
begin
Result := False;
Value := SParseValueFromComand(Param, ['w:','word:']);
Result := Value <> '';
if Result then
	Words += Value;
end;

begin
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSConsoleHandler.Create(VParams) do
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
SConsoleToolsConsoleHandler.AddComand('Other tools', @SConsoleEngineRenamer, ['enginerenamer', 'ern'], 'Engine renamer');
end;

end.
