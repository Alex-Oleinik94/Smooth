{$INCLUDE SaGe.inc}

unit SaGeNotepad;

interface

uses 
	 crt
	,SysUtils
	,SaGeBase
	,SaGeBased
	,SaGeContext
	,SaGeScreen
	,SaGeUtils
	,Classes
	,SaGeCommon
	;

type
	TSGNotepad = class;
	
	TSGNInset = class(TSGComponent)
			public
		constructor Create();
		destructor Destroy();override;
			private
		FTitle : TSGString;
		FTitleWidth : TSGLongWord;
		FOwner : TSGNotepad;
		FBegin, FEnd : TSGFloat;
			protected
		procedure SetTitle(const VTitle : TSGString);
		function GetTitle() : TSGString;
		procedure SetOwner(const VOwner : TSGNotepad);
		function GetTitleWidth() : TSGLongWord;
			public
		property Title : TSGString read GetTitle write SetTitle;
		property TitleWidth : TSGLongWord read GetTitleWidth;
		property Owner : TSGNotepad write SetOwner;
		end;
	
	TSGNTextInset = class(TSGNInset)
			public
		constructor Create();
		destructor Destroy();override;
			private
		FFileName : TSGString;
		FFile : TSGArString;
		FCursorPos : TSGPoint2f;
			private
		procedure SetFile(const VFileName : TSGString);
		procedure LoadFile();
		function CountLines() : TSGLongWord;
		procedure GoToPosition(const Line, Column : TSGLongWord);
			public
		property FileName : TSGString write SetFile;
			public
		procedure FromDraw();override;
		end;
	
	TSGNInsetList = packed array of TSGNInset;
	
	TSGNotepad = class(TSGComponent)
			public
		constructor Create();
		destructor Destroy();override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw();override;
			public
		procedure AddFile(const VFileName : TSGString; const VLine : TSGLongWord = 0; const VColumn : TSGLongWord = 0);
			private
		FInsets : TSGNInsetList;
		FActiveInset : TSGLongWord;
			private
		procedure AddInset(const VInset : TSGNInset);
		function CountInsets() : TSGLongWord;
		function InsetIndex(const VInset : TSGNInset) : TSGLongWord;
		function ActiveInset() : TSGNInset;
		end;

procedure SGRunNotepad(const VFileName : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

function TSGNotepad.ActiveInset() : TSGNInset;
begin
if CountInsets() = 0 then
	Result := nil
else if (FActiveInset >= 0) and (FActiveInset <= CountInsets() - 1) then
	Result := FInsets[FActiveInset]
else
	Result := nil;
end;

procedure TSGNTextInset.GoToPosition(const Line, Column : TSGLongWord);
var
	Difference : TSGFloat;
begin
Difference := Height / Font.FontHeight;
FBegin := (Line + 0.5) - Difference / 2;
FEnd := FBegin + Difference;
if FEnd > CountLines() then
	begin
	FEnd := CountLines();
	FBegin := FEnd - Difference;
	end;
if FBegin < 0 then
	begin
	FBegin := 0;
	FEnd := Difference;
	end;
FCursorPos.Import(Line, Column);
end;

procedure TSGNTextInset.FromDraw();
var
	i, ii : TSGLongWord;
	Vertex : TSGVertex3f;
begin
if FOwner.ActiveInset() = Self then
	begin
	ii := Trunc(FBegin);
	Vertex := SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
	for i := ii to Trunc(FEnd) do
		begin
		if i > CountLines() then
			break;
		Font.DrawFontFromTwoVertex2f(
			FFile[i],
			SGVertex2fImport(
				Vertex.x + 0,
				Vertex.y + (i - ii) * Font.FontHeight),
			SGVertex2fImport(
				Vertex.x + Width,
				Vertex.y + (i - ii + 1) * Font.FontHeight),
			False);
		end;
	end;
inherited;
end;

procedure TSGNotepad.FromDraw();

procedure DrawInsetsTitles();
var
	i : TSGLongWord;
	Shift : TSGLongWord;
	Vertex : TSGVertex3f;
begin
if CountInsets() > 0 then
	begin
	Shift := 1;
	Vertex := SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
	for i := 0 to CountInsets() - 1 do
		begin
		SGRoundQuad(Render,
			SGVertexImport(
				Vertex.x + Shift,
				Vertex.y + 1),
			SGVertexImport(
				Vertex.x + Shift + FInsets[i].TitleWidth + 10,
				Vertex.y + FFont.FontHeight + 10 - 3),
			5,10,
			SGGetColor4fFromLongWord($00FF00).WithAlpha(0.6),
			SGGetColor4fFromLongWord($00FFFF).WithAlpha(0.8),
			True);
		Render.Color4f(1,1,1,1);
		Font.DrawFontFromTwoVertex2f(
			FInsets[i].Title,
			SGVertex2fImport(
				Vertex.x + Shift,
				Vertex.y + 1),
			SGVertex2fImport(
				Vertex.x + Shift + FInsets[i].TitleWidth + 10,
				Vertex.y + FFont.FontHeight + 10  - 3));
		Shift += FInsets[i].TitleWidth + 10 + 2;
		end;
	end;
end;

begin
DrawInsetsTitles();
inherited;
end;

function TSGNTextInset.CountLines() : TSGLongWord;
begin
if FFile = nil then
	Result := 0
else
	Result := Length(FFile);
end;

constructor TSGNTextInset.Create();
begin
inherited;
FFileName := '';
FFile := nil;
end;

destructor TSGNTextInset.Destroy();
begin
SetLength(FFile, 0);
inherited;
end;

procedure TSGNTextInset.SetFile(const VFileName : TSGString);
begin
FFileName := VFileName;
LoadFile();
end;

procedure TSGNTextInset.LoadFile();
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FFileName);
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	SetLength(FFile, CountLines() + 1);
	FFile[High(FFile)] := SGReadLnStringFromStream(Stream);
	end;
Stream.Destroy();
end;

function TSGNInset.GetTitleWidth() : TSGLongWord;
begin
if FTitleWidth = 0 then
	FTitleWidth := Font.StringLength(FTitle);
Result := FTitleWidth;
end;

procedure TSGNInset.SetOwner(const VOwner : TSGNotepad);
begin
FOwner := VOwner;
end;

constructor TSGNInset.Create();
begin
inherited;
FTitle := '';
FOwner := nil;
FTitleWidth := 0;
end;

destructor TSGNInset.Destroy();
begin
inherited;
end;

procedure TSGNInset.SetTitle(const VTitle : TSGString);
begin
FTitle := VTitle;
end;

function TSGNInset.GetTitle() : TSGString;
begin
Result := FTitle;
end;

function TSGNotepad.InsetIndex(const VInset : TSGNInset) : TSGLongWord;
var
	i : TSGLongWord;
begin
if CountInsets() = 0 then
	Result := 0
else
	for i := 0 to High(FInsets) do
		if FInsets[i] = VInset then
			begin
			Result := i;
			break;
			end;
end;

function TSGNotepad.CountInsets() : TSGLongWord;
begin
if FInsets = nil then
	Result := 0
else
	Result := Length(FInsets);
end;

procedure TSGNotepad.AddInset(const VInset : TSGNInset);
begin
SetLength(FInsets, CountInsets() + 1);
FInsets[High(FInsets)] := VInset;
CreateChild(VInset);
VInset.Owner := Self;
VInset.SetBounds(0, FFont.FontHeight + 10, Width, Height - (FFont.FontHeight + 10));
VInset.BoundsToNeedBounds();
end;

procedure TSGNotepad.AddFile(const VFileName : TSGString; const VLine : TSGLongWord = 0; const VColumn : TSGLongWord = 0);
var
	Inset : TSGNTextInset = nil;
begin
Inset := TSGNTextInset.Create();
AddInset(Inset);
FActiveInset := InsetIndex(Inset);
Inset.Title := SGGetFileName(VFileName);
Inset.FileName := VFileName;
Inset.GoToPosition(VLine, VColumn);
end;

constructor TSGNotepad.Create();
begin
inherited;
FInsets := nil;
FActiveInset := 0;
end;

destructor TSGNotepad.Destroy();
begin
SetLength(FInsets, 0);
inherited;
end;

procedure TSGNotepad.FromUpDate(var FCanChange:Boolean);
begin
inherited;
end;

procedure TSGNotepad.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited;
end;

procedure SGRunNotepad(const VFileName : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Notepad : TSGNotepad;
begin
Notepad := TSGNotepad.Create();
SGScreen.CreateChild(Notepad);
Notepad.SetBounds(0, 0, Notepad.Context.Width, Notepad.Context.Height);
Notepad.BoundsToNeedBounds();
Notepad.Visible := True;
Notepad.AddFile(VFileName);
Notepad.AddFile(VFileName);
Notepad.AddFile(VFileName);
Notepad.AddFile(VFileName);
end;

end.
