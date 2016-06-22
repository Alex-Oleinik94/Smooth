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
	,SaGeRenderConstants
	,SaGeCommonClasses
	,SaGeMakefileReader
	,SaGeResourseManager
	,StrMan
	;

type
	TSGNotepad = class;
	
	TSGNInset = class(TSGComponent)
			public
		constructor Create();
		destructor Destroy();override;
			public
		procedure FromDraw();override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
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
		FScrolTimer : TSGFloat;
		
		FCursorOnText : TSGBoolean;
		FCursorOnTextPrev : TSGBoolean;
		
		FTextCursor : record
			FLine : TSGLongWord;
			FColumn : TSGLongWord;
			FTimer : TSGFloat;
			end;
		
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
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw();override;
		procedure FromResize();override;
			private
		procedure ProcessMakefileComand(const Comand : TSGString);
		procedure OpenMakefileProjects();
		procedure AddMakefileDirectory(const VDirName : TSGString);
		procedure AddMakefileProject(const VProjName : TSGString);
			public
		procedure AddFile(const VFileName : TSGString; const VLine : TSGLongWord = 0; const VColumn : TSGLongWord = 0);
		procedure AddMakeFile(const VFileName : TSGString);
			private
		FInsets : TSGNInsetList;
		FActiveInset : TSGLongWord;
		FMakefile : TSGMakefileReader;
		FMakefileDirectories : TSGArString;
		FMakefileProjects    : TSGArString;
			private
		procedure AddInset(const VInset : TSGNInset);
		function CountInsets() : TSGLongWord;
		function InsetIndex(const VInset : TSGNInset) : TSGLongWord;
		function ActiveInset() : TSGNInset;
		end;
	
	TSGNotepadApplication = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		procedure LoadDeviceResourses();override;
		procedure DeleteDeviceResourses();override;
		class function ClassName() : TSGString;override;
			private
		FNotepad : TSGNotepad;
		end;

implementation

class function TSGNotepadApplication.ClassName() : TSGString;
begin
Result := 'Текстовой редактор';
end;

constructor TSGNotepadApplication.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FNotepad := TSGNotepad.Create();
SGScreen.CreateChild(FNotepad);
FNotepad.SetBounds(0, 50, Render.Width, Render.Height - 50);
FNotepad.BoundsToNeedBounds();
FNotepad.Visible := True;
FNotepad.AddMakeFile('.\..\Build');
FNotepad.OpenMakefileProjects();
end;

procedure TSGNotepadApplication.LoadDeviceResourses();
begin
end;

procedure TSGNotepadApplication.DeleteDeviceResourses();
begin
end;

destructor TSGNotepadApplication.Destroy();
begin
if FNotepad <> nil then
	begin
	FNotepad.Destroy();
	FNotepad := nil;
	end;
inherited;
end;

procedure TSGNotepadApplication.Paint();
begin
end;

procedure TSGNotepad.AddMakefileDirectory(const VDirName : TSGString);

function NotExistsInSavedDirectories(const VDirectoryName : TSGString) : TSGBoolean;
var
	S : TSGString;
begin
Result := True;
for S in FMakefileDirectories do
	if S = VDirectoryName then
		begin
		Result := False;
		break;
		end;
end;

procedure AddToSavedDirectories(const VDirectoryName : TSGString);
begin
if FMakefileDirectories = nil then
	SetLength(FMakefileDirectories, 1)
else
	SetLength(FMakefileDirectories, Length(FMakefileDirectories) + 1);
FMakefileDirectories[High(FMakefileDirectories)] := VDirectoryName;
end;

var
	TotalString : TSGString;
begin
TotalString := SGGetFileWay(FMakefile.FileName) + VDirName;
if (not (TotalString in FMakefileDirectories)) then
	if SGResourseFiles.FileExists(TotalString) then
		FMakefileDirectories += TotalString;
end;

procedure TSGNotepad.AddMakefileProject(const VProjName : TSGString);

function ValidProject(const VProjectName : TSGString) : TSGBoolean;
begin
Result := False;
if (not (VProjectName in FMakefileProjects)) then
	if SGResourseFiles.FileExists(VProjectName) then
		Result := True;
end;

var
	ProjectName : TSGString;
begin
ProjectName := SGGetFileWay(FMakefile.FileName) + VProjName;
if ValidProject(ProjectName) then
	FMakefileProjects += ProjectName
else if ValidProject(ProjectName + '.pp') then
	FMakefileProjects += ProjectName + '.pp'
else if ValidProject(ProjectName + '.pas') then
	FMakefileProjects += ProjectName + '.pas'
else if ValidProject(ProjectName + '.lpr') then
	FMakefileProjects += ProjectName + '.lpr'
else if ValidProject(ProjectName + '.dpr') then
	FMakefileProjects += ProjectName + '.dpr';
end;

procedure TSGNotepad.OpenMakefileProjects();
var
	S : TSGString;
begin
for S in FMakefileProjects do
	AddFile(S);
end;

procedure TSGNotepad.ProcessMakefileComand(const Comand : TSGString);
var
	WordIndex, CountWords : TSGLongWord;
	S : TSGString;
begin
CountWords := StringWordCount(Comand, ' ');
if (CountWords > 1) and (SGUpCaseString(StringWordGet(Comand, ' 	', 1)) = 'FPC') then
	begin
	for WordIndex := 1 to CountWords do
		begin
		S := StringWordGet(Comand, ' 	', WordIndex);
		if Length(S) > 3 then
			if '-Fu' + StringExtract(S, 3, Length(S) - 3) = S then
				begin
				AddMakefileDirectory(StringExtract(S, 3, Length(S) - 3));
				end;
		end;
	AddMakefileProject(StringWordGet(Comand, ' 	', CountWords));
	end;
end;

procedure TSGNotepad.AddMakeFile(const VFileName : TSGString);
var
	TargetIndex : TSGLongWord;
	Identifier  : TSGMRIdentifier;
begin
if FMakefile <> nil then
	begin
	FMakefile.Destroy();
	FMakefile := nil;
	end;
if SGResourseFiles.FileExists(VFileName) then
	FMakefile := TSGMakefileReader.Create(VFileName)
else if SGResourseFiles.FileExists(VFileName + 'Makefile') then
	FMakefile := TSGMakefileReader.Create(VFileName + 'Makefile')
else if SGResourseFiles.FileExists(VFileName + Slash + 'Makefile') then
	FMakefile := TSGMakefileReader.Create(VFileName + Slash + 'Makefile');
if FMakefile <> nil then
	begin
	WriteLn(FMakefile.TargetCount() );
	if FMakefile.TargetCount() <> 0 then
		begin
		for TargetIndex := 0 to FMakefile.TargetCount() - 1 do
			begin
			for Identifier in FMakefile.GetTarget(TargetIndex).FComands do
				begin
				ProcessMakefileComand(Identifier.FAbsoluteIdentifier);
				end;
			end;
		end;
	end;
end;

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
SetBounds(0, 50, ScreenWidth, ScreenHeight - 50);
ResizeInsets();
inherited;
end;

procedure TSGNTextInset.FromResize();
begin
StandardizateView();
inherited;
end;

procedure TSGNInset.FromDraw();
begin
FCursorOnComponent := False;
inherited;
end;

procedure TSGNInset.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited;
end;

procedure TSGNTextInset.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
if Visible then if CanRePleace then if CursorInComponentNow then
	begin
	if (Context.CursorWheel() <> SGNullCursorWheel)then
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

var
	Line : TSGLongWord;
	CursorPos : TSGPoint2f;

function IsCurOnText():TSGBoolean;
begin
Result := False;
if not FCursorOnComponent then
	Exit;
CursorPos := Context.CursorPosition(SGNowCursorPosition) - SGPoint2fImport(FRealLeft, FRealTop);
Line := Trunc(FBegin + Abs(FEnd - FBegin) * ((CursorPos.y) / Height));
Result := (Font.StringLength(FFile[Line]) + Font.StringLength(SGStr(CountLines())) + 5 >= CursorPos.x) and
		  (Font.StringLength(SGStr(CountLines())) + 5 <= CursorPos.x);
end;

procedure ProcessCursors();
begin
FCursorOnText := IsCurOnText();
if FCursorOnText then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SGC_IBEAM)) then
		Context.Cursor := TSGCursor.Create(SGC_IBEAM);
if FCursorOnTextPrev and (not FCursorOnText) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SGC_IBEAM)) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
FCursorOnTextPrev := FCursorOnText;
end;

begin
if FOwner <> nil then
	Visible := FOwner.ActiveInset() = Self;
FScrolTimer := FScrolTimer * 0.95;
if FCursorOnComponent or FCursorOnText or FCursorOnTextPrev then
	ProcessCursors();
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
FTextCursor.FLine := Line;
FTextCursor.FColumn := Column;
FTextCursor.FTimer := 1;
end;

procedure TSGNTextInset.FromDraw();

procedure DrawTextAndNumLines();
var
	i, ii : TSGLongWord;
	Vertex : TSGVertex3f;
	MaxLinesShift : TSGLongWord;
	Alpha, Shift : TSGFloat;
begin
MaxLinesShift := Font.StringLength(SGStr(CountLines())) + 5;
ii := Trunc(FBegin);
Vertex := SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
Shift := Abs(FBegin - ii);
Vertex.y -= Shift * Font.FontHeight;
for i := ii to Trunc(FEnd) + 1 do
	begin
	if i >= CountLines() then
		break;
	
	if i = ii  then
		Alpha := (1 - Shift) ** 2
	else if i - Shift + 1 > FEnd then
		Alpha := Abs(FEnd - i + Shift - 1) ** 2
	else
		Alpha := 1;
	
	Render.Color4f(0.9,0.9,0.9,Alpha);
	Font.DrawFontFromTwoVertex2f(
		SGStr(i+1),
		SGVertex2fImport(
			Vertex.x,
			Vertex.y + (i - ii) * Font.FontHeight),
		SGVertex2fImport(
			Vertex.x + MaxLinesShift,
			Vertex.y + (i - ii + 1) * Font.FontHeight),
		False);
	Render.Color4f(1,1,1,Alpha);
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
inherited;
DrawInsetsTitles();
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
FMakefile := nil;
FMakefileDirectories := nil;
FMakefileProjects := nil;
end;

destructor TSGNotepad.Destroy();
begin
SetLength(FMakefileDirectories,0);
SetLength(FMakefileProjects,0);
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

end.
