{$INCLUDE Smooth.inc}

unit SmoothNotepadFileOpener;

interface

uses 
	 SmoothBase
	,SmoothLists
	,SmoothNotepad
	,SmoothFileOpener
	,SmoothContextInterface
	;
type
	TSNotepadFileOpener = class(TSFileOpener)
			public
		class function ClassName() : TSString; override;
		class function GetExpansions() : TSStringList; override;
		class function GetDrawableClass() : TSFileOpenerDrawableClass;override;
		class function ExpansionsSupported(const VExpansions : TSStringList) : TSBool; override;
		end;

	TSNotepadFileOpenerDrawable = class (TSFileOpenerDrawable)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
		procedure Resize(); override;
			private
		FNotepad : TSNotepad;
		end;
	
implementation

uses
	 SmoothStringUtils
	;

// TSNotepadFileOpener

class function TSNotepadFileOpener.ClassName() : TSString;
begin
Result := 'TSNotepadFileOpener';
end;

class function TSNotepadFileOpener.GetExpansions() : TSStringList;
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

Result += 'vmg';
end;

class function TSNotepadFileOpener.GetDrawableClass() : TSFileOpenerDrawableClass;
begin
Result := TSNotepadFileOpenerDrawable;
end;

class function TSNotepadFileOpener.ExpansionsSupported(const VExpansions : TSStringList) : TSBool;
var
	SL : TSStringList = nil;
begin
SL := GetExpansions();
SL := SUpCasedStringList(SL, True);
Result := VExpansions in SL;
SetLength(SL, 0);
end;

// TSNotepadFileOpenerDrawable

constructor TSNotepadFileOpenerDrawable.Create(const VContext : ISContext);
begin
inherited;
FNotepad := TSNotepad.Create();
Context.Screen.CreateChild(FNotepad);
FNotepad.SetBounds(0, 0, Render.Width, Render.Height);
FNotepad.BoundsMakeReal();
FNotepad.Visible := True;
end;

destructor TSNotepadFileOpenerDrawable.Destroy();
begin
if FNotepad <> nil then
	begin
	FNotepad.Destroy();
	FNotepad := nil;
	end;
inherited;
end;

class function TSNotepadFileOpenerDrawable.ClassName() : TSString;
begin
Result := 'TSNotepadFileOpenerDrawable';
end;

procedure TSNotepadFileOpenerDrawable.DeleteRenderResources();
begin
inherited;
end;

procedure TSNotepadFileOpenerDrawable.LoadRenderResources();
var
	FileName : TSString;
begin
inherited;
if FFiles <> nil then if (Length(FFiles) > 0) then
	begin
	for FileName in FFiles do
		FNotepad.AddFile(FileName);
	SetLength(FFiles, 0);
	end;
end;

procedure TSNotepadFileOpenerDrawable.Resize();
begin
if FNotepad <> nil then
	FNotepad.SetBounds(0, 0, Render.Width, Render.Height);
end;

initialization
begin
SRegistryFileOpener(TSNotepadFileOpener);
end;

end.