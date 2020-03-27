{$INCLUDE Smooth.inc}

unit SmoothNotepad;

interface

uses 
	 Crt
	,SysUtils
	,Classes
	
	,SmoothBase
	,SmoothLists
	,SmoothContext
	,SmoothScreenClasses
	,SmoothCommonStructs
	,SmoothRender
	,SmoothRenderBase
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothMakefileReader
	,SmoothResourceManager
	,SmoothScreenBase
	,SmoothFont
	,SmoothExtensionManager
	,SmoothScreenCommonComponents
	;

type
	TSNotepad = class;
	
	TSNInset = class(TSOverComponent)
			public
		constructor Create();
		destructor Destroy(); override;
			public
		procedure Paint(); override;
			protected
		FTitle : TSString;
		FTitleWidth : TSLongWord;
		FOwner : TSNotepad;
		FBegin, FEnd : TSFloat;
			protected
		procedure SetTitle(const VTitle : TSString);
		function GetTitle() : TSString;
		procedure SetOwner(const VOwner : TSNotepad);
		function GetTitleWidth() : TSLongWord;
			public
		property Title : TSString read GetTitle write SetTitle;
		property TitleWidth : TSLongWord read GetTitleWidth;
		property Owner : TSNotepad write SetOwner;
		end;
	
	TSNInsetList = packed array of TSNInset;
	
	TSNotepad = class(TSScreenComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure UpDate();override;
		procedure Paint();override;
		procedure Resize();override;
			private
		procedure ProcessMakefileComand(const Comand : TSString);
		procedure OpenMakefileProjects();
		procedure AddMakefileDirectory(const VDirName : TSString);
		procedure AddMakefileProject(const VProjName : TSString);
			public
		procedure AddFile(const VFileName : TSString; const VLine : TSLongWord = 0; const VColumn : TSLongWord = 0);
		procedure AddMakeFile(const VFileName : TSString);
			private
		FInsets : TSNInsetList;
		FActiveInset : TSLongWord;
		FMakefile : TSMakefileReader;
		FMakefileDirectories : TSStringList;
		FMakefileProjects    : TSStringList;
			private
		procedure AddInset(const VInset : TSNInset);
		function CountInsets() : TSLongWord;
		function InsetIndex(const VInset : TSNInset) : TSLongWord;
			public
		function ActiveInset() : TSNInset;
		end;
	
	TSNotepadApplication = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		procedure LoadRenderResources();override;
		procedure DeleteRenderResources();override;
		class function ClassName() : TSString;override;
		procedure Resize(); override;
			private
		FNotepad : TSNotepad;
		end;

implementation

uses
	 SmoothNotepadTextInset
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothRenderInterface
	,SmoothCommon
	,SmoothContextUtils
	,SmoothScreen
	,SmoothRectangleWithRoundedCorners
	
	,StrMan
	;

class function TSNotepadApplication.ClassName() : TSString;
begin
Result := 'Текстовой редактор';
end;

constructor TSNotepadApplication.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FNotepad := TSNotepad.Create();
TSScreen(Context.Screen).CreateChild(FNotepad);
FNotepad.SetBounds(0, 50, Render.Width, Render.Height - 50);
FNotepad.BoundsMakeReal();
FNotepad.Visible := True;
FNotepad.AddMakeFile('.' + DirectorySeparator + '..' + DirectorySeparator + 'Build' + DirectorySeparator + 'Makefile');
FNotepad.OpenMakefileProjects();
end;

procedure TSNotepadApplication.Resize();
begin
FNotepad.SetBounds(0, 50, Render.Width, Render.Height - 50);
end;

procedure TSNotepadApplication.LoadRenderResources();
begin
inherited;
end;

procedure TSNotepadApplication.DeleteRenderResources();
begin
inherited;
end;

destructor TSNotepadApplication.Destroy();
begin
if FNotepad <> nil then
	begin
	FNotepad.Destroy();
	FNotepad := nil;
	end;
inherited;
end;

procedure TSNotepadApplication.Paint();
begin
end;

procedure TSNotepad.AddMakefileDirectory(const VDirName : TSString);

function NotExistsInSavedDirectories(const VDirectoryName : TSString) : TSBoolean;
var
	S : TSString;
begin
Result := True;
for S in FMakefileDirectories do
	if S = VDirectoryName then
		begin
		Result := False;
		break;
		end;
end;

procedure AddToSavedDirectories(const VDirectoryName : TSString);
begin
if FMakefileDirectories = nil then
	SetLength(FMakefileDirectories, 1)
else
	SetLength(FMakefileDirectories, Length(FMakefileDirectories) + 1);
FMakefileDirectories[High(FMakefileDirectories)] := VDirectoryName;
end;

var
	TotalString : TSString;
begin
TotalString := SFilePath(FMakefile.FileName) + VDirName;
if (not (TotalString in FMakefileDirectories)) then
	if SResourceFiles.FileExists(TotalString) then
		FMakefileDirectories += TotalString;
end;

procedure TSNotepad.AddMakefileProject(const VProjName : TSString);

function ValidProject(const VProjectName : TSString) : TSBoolean;
begin
Result := False;
if (not (VProjectName in FMakefileProjects)) then
	if SResourceFiles.FileExists(VProjectName) then
		Result := True;
end;

var
	ProjectName : TSString;

begin
ProjectName := SFilePath(FMakefile.FileName) + VProjName;
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

procedure TSNotepad.OpenMakefileProjects();
var
	S : TSString;
begin
for S in FMakefileProjects do
	AddFile(S);
end;

procedure TSNotepad.ProcessMakefileComand(const Comand : TSString);
var
	WordIndex, CountWords : TSLongWord;
	S : TSString;
begin
CountWords := StringWordCount(Comand, ' ');
if (CountWords > 1) and (SUpCaseString(StringWordGet(Comand, ' 	', 1)) = 'FPC') then
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

procedure TSNotepad.AddMakeFile(const VFileName : TSString);
var
	TargetIndex : TSLongWord;
	Identifier  : TSMRIdentifier;
begin
if FMakefile <> nil then
	begin
	FMakefile.Destroy();
	FMakefile := nil;
	end;
if SResourceFiles.FileExists(VFileName) then
	FMakefile := TSMakefileReader.Create(VFileName)
else if SResourceFiles.FileExists(VFileName + 'Makefile') then
	FMakefile := TSMakefileReader.Create(VFileName + 'Makefile')
else if SResourceFiles.FileExists(VFileName + DirectorySeparator + 'Makefile') then
	FMakefile := TSMakefileReader.Create(VFileName + DirectorySeparator + 'Makefile');
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

procedure TSNotepad.Resize();

procedure ResizeInsets();
var
	i : TSLongWord;
begin
if CountInsets() >0 then
	for i := 0 to CountInsets() - 1 do
		begin
		FInsets[i].SetBounds(0, Skin.Font.FontHeight + 10, Width, Height - (Skin.Font.FontHeight + 10));
		FInsets[i].BoundsMakeReal();
		FInsets[i].Resize();
		end;
end;

begin
ResizeInsets();
inherited;
end;

procedure TSNInset.Paint();
begin
inherited;
end;

function TSNotepad.ActiveInset() : TSNInset;
begin
if CountInsets() = 0 then
	Result := nil
else if (FActiveInset >= 0) and (FActiveInset <= CountInsets() - 1) then
	Result := FInsets[FActiveInset]
else
	Result := nil;
end;

procedure TSNotepad.Paint();

procedure DrawInsetsTitles();
var
	i : TSLongWord;
	Shift : TSLongWord;
	Vertex : TSVertex3f;
	Color1, Color2 : TSColor4f;
begin
if CountInsets() > 0 then
	begin
	Shift := 1;
	Vertex := SPoint2int32ToVertex3f(GetVertex([SS_LEFT,SS_TOP],S_VERTEX_FOR_PARENT));
	for i := 0 to CountInsets() - 1 do
		begin
		if FInsets[i] = ActiveInset() then
			begin
			Color1 := SColor4fFromUInt32($00FF00).WithAlpha(0.6);
			Color2 := SColor4fFromUInt32($00FFFF).WithAlpha(0.8);
			end
		else
			begin
			Color1 := SColor4fFromUInt32($009900).WithAlpha(0.6);
			Color2 := SColor4fFromUInt32($009999).WithAlpha(0.8);
			end;
		SRoundQuad(Render,
			SVertex3fImport(
				Vertex.x + Shift,
				Vertex.y + 1),
			SVertex3fImport(
				Vertex.x + Shift + FInsets[i].TitleWidth + 10,
				Vertex.y + Skin.Font.FontHeight + 10 - 3),
			5,10,
			Color1,
			Color2,
			True);
		Render.Color4f(1,1,1,1);
		Skin.Font.DrawFontFromTwoVertex2f(
			FInsets[i].Title,
			SVertex2fImport(
				Vertex.x + Shift,
				Vertex.y + 1),
			SVertex2fImport(
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

function TSNInset.GetTitleWidth() : TSLongWord;
begin
if FTitleWidth = 0 then
	FTitleWidth := Skin.Font.StringLength(FTitle);
Result := FTitleWidth;
end;

procedure TSNInset.SetOwner(const VOwner : TSNotepad);
begin
FOwner := VOwner;
end;

constructor TSNInset.Create();
begin
inherited;
FTitle := '';
FOwner := nil;
FTitleWidth := 0;
FBegin := 0;
FEnd := 30;
end;

destructor TSNInset.Destroy();
begin
inherited;
end;

procedure TSNInset.SetTitle(const VTitle : TSString);
begin
FTitle := VTitle;
end;

function TSNInset.GetTitle() : TSString;
begin
Result := FTitle;
end;

function TSNotepad.InsetIndex(const VInset : TSNInset) : TSLongWord;
var
	i : TSLongWord;
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

function TSNotepad.CountInsets() : TSLongWord;
begin
if FInsets = nil then
	Result := 0
else
	Result := Length(FInsets);
end;

procedure TSNotepad.AddInset(const VInset : TSNInset);
begin
SetLength(FInsets, CountInsets() + 1);
FInsets[High(FInsets)] := VInset;
CreateChild(VInset);
VInset.Owner := Self;
VInset.SetBounds(0, Skin.Font.FontHeight + 10, Width, Height - (Skin.Font.FontHeight + 10));
VInset.BoundsMakeReal();
end;

procedure TSNotepad.AddFile(const VFileName : TSString; const VLine : TSLongWord = 0; const VColumn : TSLongWord = 0);
var
	Inset : TSNTextInset = nil;
begin
Inset := TSNTextInset.Create();
AddInset(Inset);
FActiveInset := InsetIndex(Inset);
Inset.Title := SFileName(VFileName);
Inset.FileName := VFileName;
Inset.GoToPosition(VLine, VColumn);
end;

constructor TSNotepad.Create();
begin
inherited;
FInsets := nil;
FActiveInset := 0;
FMakefile := nil;
FMakefileDirectories := nil;
FMakefileProjects := nil;
end;

destructor TSNotepad.Destroy();
begin
SetLength(FMakefileDirectories,0);
SetLength(FMakefileProjects,0);
SetLength(FInsets, 0);
inherited;
end;

procedure TSNotepad.UpDate();
begin
if (Context.KeyPressed and (Context.KeyPressedType = SDownKey) and (Context.KeyPressedByte = 9 {Tab}) and (Context.KeysPressed(S_CTRL_KEY))) then
	begin
	FActiveInset += 1;
	if FActiveInset >= CountInsets() then
		FActiveInset := 0;
	Context.SetKey(SNullKey,0);
	end;
inherited;
end;

initialization
begin
SRegisterDrawClass(TSNotepadApplication);
end;

end.
