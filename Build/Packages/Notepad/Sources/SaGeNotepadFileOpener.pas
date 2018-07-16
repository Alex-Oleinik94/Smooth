{$INCLUDE SaGe.inc}

unit SaGeNotepadFileOpener;

interface

uses 
	 SaGeBase
	,SaGeLists
	,SaGeNotepad
	,SaGeFileOpener
	,SaGeContextInterface
	;
type
	TSGNotepadFileOpener = class(TSGFileOpener)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; override;
		class function GetDrawableClass() : TSGFileOpenerDrawableClass;override;
		class function ExpansionsSupported(const VExpansions : TSGStringList) : TSGBool; override;
		end;

	TSGNotepadFileOpenerDrawable = class (TSGFileOpenerDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
		procedure Resize(); override;
			private
		FNotepad : TSGNotepad;
		end;
	
implementation

uses
	 SaGeStringUtils
	,SaGeScreen
	;

// TSGNotepadFileOpener

class function TSGNotepadFileOpener.ClassName() : TSGString;
begin
Result := 'TSGNotepadFileOpener';
end;

class function TSGNotepadFileOpener.GetExpansions() : TSGStringList;
begin
Result := nil;

Result += 'BAT';
Result += 'CMD';
Result += 'SH';

Result += 'PAS';
Result += 'PP';
Result += 'INC';
Result += 'LPI';
Result += 'DPI';

Result += 'C';
Result += 'C++';
Result += 'CXX';
Result += 'H';

Result += 'INI';
Result += 'CFG';
Result += 'TXT';
Result += 'XML';
Result += 'HTML';

Result += 'gitignore';
Result += 'md';
Result += 'gitconfig';
end;

class function TSGNotepadFileOpener.GetDrawableClass() : TSGFileOpenerDrawableClass;
begin
Result := TSGNotepadFileOpenerDrawable;
end;

class function TSGNotepadFileOpener.ExpansionsSupported(const VExpansions : TSGStringList) : TSGBool;
var
	SL : TSGStringList = nil;
begin
SL := GetExpansions();
SL := SGUpCasedStringList(SL, True);
Result := VExpansions in SL;
SetLength(SL, 0);
end;

// TSGNotepadFileOpenerDrawable

constructor TSGNotepadFileOpenerDrawable.Create(const VContext : ISGContext);
begin
inherited;
FNotepad := TSGNotepad.Create();
TSGScreen(Context.Screen).CreateChild(FNotepad);
FNotepad.SetBounds(0, 0, Render.Width, Render.Height);
FNotepad.BoundsMakeReal();
FNotepad.Visible := True;
end;

destructor TSGNotepadFileOpenerDrawable.Destroy();
begin
if FNotepad <> nil then
	begin
	FNotepad.Destroy();
	FNotepad := nil;
	end;
inherited;
end;

class function TSGNotepadFileOpenerDrawable.ClassName() : TSGString;
begin
Result := 'TSGNotepadFileOpenerDrawable';
end;

procedure TSGNotepadFileOpenerDrawable.DeleteRenderResources();
begin
inherited;
end;

procedure TSGNotepadFileOpenerDrawable.LoadRenderResources();
var
	FileName : TSGString;
begin
inherited;
if FFiles <> nil then if (Length(FFiles) > 0) then
	begin
	for FileName in FFiles do
		FNotepad.AddFile(FileName);
	SetLength(FFiles, 0);
	end;
end;

procedure TSGNotepadFileOpenerDrawable.Resize();
begin
if FNotepad <> nil then
	FNotepad.SetBounds(0, 0, Render.Width, Render.Height);
end;

initialization
begin
SGRegistryFileOpener(TSGNotepadFileOpener);
end;

end.
