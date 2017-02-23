{$INCLUDE SaGe.inc}

unit SaGeNotepad;

interface

uses 
	 Crt
	,SysUtils
	,Classes
	
	,SaGeBase
	,SaGeContext
	,SaGeScreen
	,SaGeCommon
	,SaGeRender
	,SaGeRenderConstants
	,SaGeCommonClasses
	,SaGeMakefileReader
	,SaGeResourceManager
	,SaGeScreenBase
	,SaGeUtils
	,SaGePackages
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
			protected
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
		FMakefileDirectories : TSGStringList;
		FMakefileProjects    : TSGStringList;
			private
		procedure AddInset(const VInset : TSGNInset);
		function CountInsets() : TSGLongWord;
		function InsetIndex(const VInset : TSGNInset) : TSGLongWord;
			public
		function ActiveInset() : TSGNInset;
		end;
	
	TSGNotepadApplication = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		procedure LoadDeviceResources();override;
		procedure DeleteDeviceResources();override;
		class function ClassName() : TSGString;override;
		procedure Resize(); override;
			private
		FNotepad : TSGNotepad;
		end;

implementation

uses
	 SaGeNotepadTextInset
	,SaGeStringUtils
	,SaGeFileUtils
	
	,StrMan
	;

class function TSGNotepadApplication.ClassName() : TSGString;
begin
Result := 'Текстовой редактор';
end;

constructor TSGNotepadApplication.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FNotepad := TSGNotepad.Create();
TSGScreen(Context.Screen).CreateChild(FNotepad);
FNotepad.SetBounds(0, 50, Render.Width, Render.Height - 50);
FNotepad.BoundsToNeedBounds();
FNotepad.Visible := True;
FNotepad.AddMakeFile('.' + DirectorySeparator + '..' + DirectorySeparator + 'Build' + DirectorySeparator + 'Makefile');
FNotepad.OpenMakefileProjects();
end;

procedure TSGNotepadApplication.Resize();
begin
FNotepad.SetBounds(0, 50, Render.Width, Render.Height - 50);
end;

procedure TSGNotepadApplication.LoadDeviceResources();
begin
inherited;
end;

procedure TSGNotepadApplication.DeleteDeviceResources();
begin
inherited;
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
TotalString := SGFilePath(FMakefile.FileName) + VDirName;
if (not (TotalString in FMakefileDirectories)) then
	if SGResourceFiles.FileExists(TotalString) then
		FMakefileDirectories += TotalString;
end;

procedure TSGNotepad.AddMakefileProject(const VProjName : TSGString);

function ValidProject(const VProjectName : TSGString) : TSGBoolean;
begin
Result := False;
if (not (VProjectName in FMakefileProjects)) then
	if SGResourceFiles.FileExists(VProjectName) then
		Result := True;
end;

var
	ProjectName : TSGString;

begin
ProjectName := SGFilePath(FMakefile.FileName) + VProjName;
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
if SGResourceFiles.FileExists(VFileName) then
	FMakefile := TSGMakefileReader.Create(VFileName)
else if SGResourceFiles.FileExists(VFileName + 'Makefile') then
	FMakefile := TSGMakefileReader.Create(VFileName + 'Makefile')
else if SGResourceFiles.FileExists(VFileName + DirectorySeparator + 'Makefile') then
	FMakefile := TSGMakefileReader.Create(VFileName + DirectorySeparator + 'Makefile');
if FMakefile <> nil then
	begin
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
		FInsets[i].SetBounds(0, Skin.Font.FontHeight + 10, Width, Height - (Skin.Font.FontHeight + 10));
		FInsets[i].BoundsToNeedBounds();
		FInsets[i].FromResize();
		end;
end;

begin
ResizeInsets();
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

function TSGNotepad.ActiveInset() : TSGNInset;
begin
if CountInsets() = 0 then
	Result := nil
else if (FActiveInset >= 0) and (FActiveInset <= CountInsets() - 1) then
	Result := FInsets[FActiveInset]
else
	Result := nil;
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
	Vertex := SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
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
			SGVertex3fImport(
				Vertex.x + Shift,
				Vertex.y + 1),
			SGVertex3fImport(
				Vertex.x + Shift + FInsets[i].TitleWidth + 10,
				Vertex.y + Skin.Font.FontHeight + 10 - 3),
			5,10,
			Color1,
			Color2,
			True);
		Render.Color4f(1,1,1,1);
		Skin.Font.DrawFontFromTwoVertex2f(
			FInsets[i].Title,
			SGVertex2fImport(
				Vertex.x + Shift,
				Vertex.y + 1),
			SGVertex2fImport(
				Vertex.x + Shift + FInsets[i].TitleWidth + 10,
				Vertex.y + Skin.Font.FontHeight + 10  - 3));
		Shift += FInsets[i].TitleWidth + 10 + 2;
		end;
	end;
end;

begin
inherited;
DrawInsetsTitles();
end;

function TSGNInset.GetTitleWidth() : TSGLongWord;
begin
if FTitleWidth = 0 then
	FTitleWidth := Skin.Font.StringLength(FTitle);
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
FBegin := 0;
FEnd := 30;
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
VInset.SetBounds(0, Skin.Font.FontHeight + 10, Width, Height - (Skin.Font.FontHeight + 10));
VInset.BoundsToNeedBounds();
end;

procedure TSGNotepad.AddFile(const VFileName : TSGString; const VLine : TSGLongWord = 0; const VColumn : TSGLongWord = 0);
var
	Inset : TSGNTextInset = nil;
begin
Inset := TSGNTextInset.Create();
AddInset(Inset);
FActiveInset := InsetIndex(Inset);
Inset.Title := SGFileName(VFileName);
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
if (Context.KeyPressed and (Context.KeyPressedType = SGDownKey) and (Context.KeyPressedByte = 9 {Tab}) and (Context.KeysPressed(SG_CTRL_KEY))) then
	begin
	FActiveInset += 1;
	if FActiveInset >= CountInsets() then
		FActiveInset := 0;
	Context.SetKey(SGNullKey,0);
	end;
inherited;
end;

procedure TSGNotepad.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited;
end;

initialization
begin
SGRegisterDrawClass(TSGNotepadApplication);
end;

end.
