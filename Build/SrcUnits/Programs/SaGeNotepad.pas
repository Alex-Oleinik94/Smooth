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
	,SaGeRender
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
		FScrolTimer : TSGFloat;
			private
		procedure SetFile(const VFileName : TSGString);
		procedure LoadFile();
		function CountLines() : TSGLongWord;
		procedure GoToPosition(const Line, Column : TSGLongWord);
		procedure MoveVertical(const Param : TSGFloat);
		procedure StandardizateView();
			public
		property FileName : TSGString write SetFile;
			public
		procedure FromDraw();override;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromResize();override;
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
		procedure FromResize();override;
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

procedure TSGNotepad.FromResize();

procedure ResizeInsets();
var
	i : TSGLongWord;
begin
if CountInsets() >0 then
	for i := 0 to CountInsets() - 1 do
		begin
		FInsets[i].SetBounds(0, FFont.FontHeight + 10, Width, Height - (FFont.FontHeight + 10));
		FInsets[i].BoundsToNeedBounds();
		FInsets[i].FromResize();
		end;
end;

begin
SetBounds(0, 0, ScreenWidth, ScreenHeight);
ResizeInsets();
inherited;
end;

procedure TSGNTextInset.FromResize();
begin
StandardizateView();
inherited;
end;

procedure TSGNTextInset.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
if Visible then if CanRePleace then if CursorInComponentNow then
	begin
	if (Context.CursorWheel() <> SGNoCursorWheel)then
		begin
		if Context.CursorWheel() = SGUpCursorWheel then
			begin
			MoveVertical(-3);
			end
		else
			begin
			MoveVertical( 3);
			end;
		end;
	end;
inherited;
end;

procedure TSGNTextInset.MoveVertical(const Param : TSGFloat);
begin
FBegin += Param;
FEnd += Param;
StandardizateView();
FScrolTimer := 1;
end;

procedure TSGNTextInset.FromUpDate(var FCanChange:Boolean);
begin
if FOwner <> nil then
	Visible := FOwner.ActiveInset() = Self;
FScrolTimer := FScrolTimer * 0.95;
inherited;
end;

function TSGNotepad.ActiveInset() : TSGNInset;
begin
if CountInsets() = 0 then
	Result := nil
else if (FActiveInset >= 0) and (FActiveInset <= CountInsets() - 1) then
	Result := FInsets[FActiveInset]
else
	Result := nil;
end;

procedure TSGNTextInset.StandardizateView();
var
	Difference, DifferenceOld, Middle : TSGFloat;
begin
DifferenceOld := Abs(FEnd - FBegin);
Difference := Height / Font.FontHeight;
if Abs(Difference - DifferenceOld) > SGZero then
	begin
	Middle := (FEnd + FBegin) / 2;
	FBegin := Middle - Difference / 2;
	FEnd := Middle + Difference / 2;
	end;
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
end;

procedure TSGNTextInset.GoToPosition(const Line, Column : TSGLongWord);
var
	Difference : TSGFloat;
begin
Difference := Height / Font.FontHeight;
FBegin := (Line + 0.5) - Difference / 2;
FEnd := FBegin + Difference;
StandardizateView();
FCursorPos.Import(Line, Column);
end;

procedure TSGNTextInset.FromDraw();

procedure DrawTextAndNumLines();
var
	i, ii : TSGLongWord;
	Vertex : TSGVertex3f;
	MaxLinesShift : TSGLongWord;
begin
MaxLinesShift := Font.StringLength(SGStr(CountLines())) + 5;
ii := Trunc(FBegin);
Vertex := SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
for i := ii to Trunc(FEnd) do
	begin
	if i > CountLines() then
		break;
	Render.Color3f(0.9,0.9,0.9);
	Font.DrawFontFromTwoVertex2f(
		SGStr(i+1),
		SGVertex2fImport(
			Vertex.x,
			Vertex.y + (i - ii) * Font.FontHeight),
		SGVertex2fImport(
			Vertex.x + MaxLinesShift,
			Vertex.y + (i - ii + 1) * Font.FontHeight),
		False);
	Render.Color3f(1,1,1);
	Font.DrawFontFromTwoVertex2f(
		FFile[i],
		SGVertex2fImport(
			Vertex.x + MaxLinesShift,
			Vertex.y + (i - ii) * Font.FontHeight),
		SGVertex2fImport(
			Vertex.x + Width,
			Vertex.y + (i - ii + 1) * Font.FontHeight),
		False);
	end;
end;

procedure DrawScrollBar();
const
	ScrollBarWidth = 20;
var
	VertexTop, VertexBottom : TSGVertex3f;
	VertexTopLeft, VertexBottomLeft : TSGVertex3f;
	AreaAll : TSGFloat;
begin
VertexTop := SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_TOP],SG_VERTEX_FOR_PARENT));
VertexBottom := SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT));
VertexBottomLeft := VertexBottom; VertexBottomLeft.x -= ScrollBarWidth * FScrolTimer;
VertexTopLeft := VertexTop; VertexTopLeft.x -= ScrollBarWidth * FScrolTimer;
AreaAll := CountLines();
Render.BeginScene(SGR_QUADS);

Render.Color4f(0.3,0.3,0.3,FScrolTimer);
VertexTop.Vertex(Render);
VertexBottom.Vertex(Render);
VertexBottomLeft.Vertex(Render);
VertexTopLeft.Vertex(Render);

Render.Color4f(0.1,0.9,0.1,FScrolTimer);
Render.Vertex2f(
	VertexTop.x,
	VertexTop.y + FBegin / AreaAll * Height);
Render.Vertex2f(
	VertexTop.x,
	VertexTop.y + FEnd / AreaAll * Height);
Render.Vertex2f(
	VertexTopLeft.x,
	VertexTop.y + FEnd / AreaAll * Height);
Render.Vertex2f(
	VertexTopLeft.x,
	VertexTop.y + FBegin / AreaAll * Height);
Render.EndScene();
end;

begin
if FOwner.ActiveInset() = Self then
	begin
	DrawTextAndNumLines();
	DrawScrollBar();
	end;
inherited;
end;

procedure TSGNotepad.FromDraw();

procedure DrawInsetsTitles();
var
	i : TSGLongWord;
	Shift : TSGLongWord;
	Vertex : TSGVertex3f;
	Color1, Color2 : TSGColor4f;
begin
if CountInsets() > 0 then
	begin
	Shift := 1;
	Vertex := SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
	for i := 0 to CountInsets() - 1 do
		begin
		if FInsets[i] = ActiveInset() then
			begin
			Color1 := SGGetColor4fFromLongWord($00FF00).WithAlpha(0.6);
			Color2 := SGGetColor4fFromLongWord($00FFFF).WithAlpha(0.8);
			end
		else
			begin
			Color1 := SGGetColor4fFromLongWord($009900).WithAlpha(0.6);
			Color2 := SGGetColor4fFromLongWord($009999).WithAlpha(0.8);
			end;
		SGRoundQuad(Render,
			SGVertexImport(
				Vertex.x + Shift,
				Vertex.y + 1),
			SGVertexImport(
				Vertex.x + Shift + FInsets[i].TitleWidth + 10,
				Vertex.y + FFont.FontHeight + 10 - 3),
			5,10,
			Color1,
			Color2,
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
FScrolTimer := 1;
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
Notepad.SetBounds(0, 0, Notepad.Render.Width, Notepad.Render.Height);
Notepad.BoundsToNeedBounds();
Notepad.Visible := True;
Notepad.AddFile(VFileName);
Notepad.AddFile(VFileName);
Notepad.AddFile(VFileName);
Notepad.AddFile(VFileName);
end;

end.
