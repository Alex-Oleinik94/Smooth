{$INCLUDE Smooth.inc}

unit SmoothFileUtils;

interface

uses
	 SmoothBase
	,SmoothLists
	
	,Classes
	,SysUtils
	;

const
	// Separators
	WinDirectorySeparator = '\';
	UnixDirectorySeparator = '/';
	DirectorySeparator =
		{$IFDEF MSWINDOWS}
			WinDirectorySeparator
		{$ELSE}
			UnixDirectorySeparator
			{$ENDIF}
		;
	DirectorySeparators = [WinDirectorySeparator, UnixDirectorySeparator];
const
	// Smooth Directories
	SSmoothDirectory     = '.' + DirectorySeparator + '..';
	SDataDirectory     = SSmoothDirectory + DirectorySeparator + 'Data';
	STempDirectory     = SSmoothDirectory + DirectorySeparator + 'Temp';
	SFontDirectory     = SDataDirectory + DirectorySeparator + 'Fonts';
	STextureDirectory  = SDataDirectory + DirectorySeparator + 'Textures';
	SModelsDirectory   = SDataDirectory + DirectorySeparator + 'Models';
	SExamplesDirectory = SDataDirectory + DirectorySeparator + 'Examples';
	SEngineDirectory   = SDataDirectory + DirectorySeparator + 'Engine';
	SImagesDirectory   = SDataDirectory + DirectorySeparator + 'Images';
	SFontsDirectory    = SFontDirectory;
	STexturesDirectory = STextureDirectory;
	
	SDefaultImageExtension = '.sia';
	SDefaultFontExtension = '.sf';
	SDefaultFontFileName = SFontDirectory + DirectorySeparator + {$IFDEF MOBILE} 'Times New Roman' + SDefaultFontExtension {$ELSE} 'Tahoma' + SDefaultFontExtension {$ENDIF};
	
	// Smooth Absolute Directories
	SAbsoluteSmoothDirectory = 
		{$IFDEF MOBILE}
			{$IFDEF ANDROID}
				DirectorySeparator + 'sdcard' + DirectorySeparator + '.Smooth'
			{$ELSE}
				''
			{$ENDIF}
		{$ELSE}
			SSmoothDirectory
		{$ENDIF}
		;
	SAbsoluteDataDirectory     = SAbsoluteSmoothDirectory + DirectorySeparator + 'Data';
	SAbsoluteTempDirectory     = SAbsoluteSmoothDirectory + DirectorySeparator + 'Temp';
	SAbsoluteFontDirectory     = SAbsoluteDataDirectory + DirectorySeparator + 'Fonts';
	SAbsoluteTextureDirectory  = SAbsoluteDataDirectory + DirectorySeparator + 'Textures';
	SAbsoluteModelsDirectory   = SAbsoluteDataDirectory + DirectorySeparator + 'Models';
	SAbsoluteExamplesDirectory = SAbsoluteDataDirectory + DirectorySeparator + 'Examples';
	SAbsoluteEngineDirectory   = SAbsoluteDataDirectory + DirectorySeparator + 'Engine';
	SAbsoluteImagesDirectory   = SAbsoluteDataDirectory + DirectorySeparator + 'Images';
	SAbsoluteTexturesDirectory = SAbsoluteTextureDirectory;
	SAbsoluteFontsDirectory    = SAbsoluteFontDirectory;
const
	// end of line
	CR = #13; // "Mac end of line"
	LF = #10; // "Unix end of line"
	CRLF = #13#10; // "Win end of line"
	DefaultEndOfLine = CRLF;
	// end of file
	EndOfFile = #$1A;
	
(************)
(** COMMON **)
(************)

function SCheckDirectorySeparators(const Path : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SExportStringToFile(const FileName, Data : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(**********)
(** FILE **)
(**********)

function SFileExtension(const FileName : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SFileNameWithoutExtension(const FileName : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SFreeFileName(const Name : TSString; const Sl : TSString = 'Copy') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SSetExtensionToFileName(const FileName, Extension : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SFileName(const PathName : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SFilePath(Path : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SApplicationFileName() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SFileExists(const FileName : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SDeleteFile(const FileName : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SRenameFile(const FileName, MustFileName : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(***************)
(** DIRECTORY **)
(***************)

function SAplicationFileDirectory() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SFreeDirectoryName(const Name : TSString; const sl : TSString = 'Copy') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SMakeDirectory(const Directory : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SMakeDirectories(const FinalDirectory : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SDeleteDirectory(const Directory : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SExistsDirectory(const Directory : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SDirectoryDirectories(Catalog : TSString; const What : TSString = '') : TSStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(************************)
(** DIRECTORY AND FILES**)
(************************)

function SDirectoryFiles(Catalog : TSString; const What : TSString = '') : TSStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	;

(************)
(** COMMON **)
(************)

function SCheckDirectorySeparators(const Path : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar;
begin
Result := '';
for C in Path do
	if C in DirectorySeparators then
		Result += DirectorySeparator
	else
		Result += C;
end;

procedure SExportStringToFile(const FileName, Data : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	f : TextFile;
begin
Assign(f, FileName);
Rewrite(f);
Write(f, Data);
Close(f);
end;

(************************)
(** DIRECTORY AND FILES**)
(************************)

function SDirectoryFiles(Catalog : TSString; const What : TSString = '') : TSStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Found : Integer;
	SearchRec : TSearchRec;
begin
Result := nil;
if Catalog = '' then
	Catalog := '.';
Catalog := SCheckDirectorySeparators(Catalog);
if Catalog[Length(Catalog)] <> DirectorySeparator then
	Catalog += DirectorySeparator;
if What <> '' then
	Found := FindFirst(Catalog + What, faAnyFile, SearchRec)
else
	Found := FindFirst(Catalog + '*', faAnyFile, SearchRec);
while Found = 0 do
	begin
	Result += SearchRec.Name;
	Found := FindNext(SearchRec);
	end;
SysUtils.FindClose(SearchRec);
end;

(**********)
(** FILE **)
(**********)

function SRenameFile(const FileName, MustFileName : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := RenameFile(FileName, MustFileName);
end;

function SDeleteFile(const FileName : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DeleteFile(FileName);
end;

function SFileExists(const FileName : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FileExists(SCheckDirectorySeparators(FileName));
end;

function SApplicationFileName() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if argc > 0 then
	Result := SCheckDirectorySeparators(argv[0])
else
	Result := '';
end;

function SFilePath(Path : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index, Index2 : TSUInt32;
begin
Path := SCheckDirectorySeparators(Path);
if SFileName(Path) = '' then
	Result := Path
else
	begin
	Result:='';
	Index2 := 0;
	for Index:=1 to Length(Path) do
		if Path[Index] in [UnixDirectorySeparator, WinDirectorySeparator] then
			Index2:=Index;
	if Index2<>0 then
		begin
		for Index:=1 to Index2 do
			Result += Path[Index];
		end;
	end;
end;

function SFileName(const PathName : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSUInt32;
	B : TSBool   = False;
	E : TSBool   = False;
	S : TSString = '';
begin
Result:='';
Index:=Length(PathName);
while (not E) and (Index>0) and (PathName[Index]<>UnixDirectorySeparator) and (PathName[Index]<>WinDirectorySeparator)  do
	begin
	Result+=PathName[Index];
	if PathName[Index]='.' then
		if b then
			E:=True
		else
			begin
			b:=True;
			Result:='';
			end;
	Index-=1;
	end;
S:=Result;
Result:='';
for Index:=Length(S) downto 1 do
	Result+=S[Index];
SetLength(S,0);
Result := SCheckDirectorySeparators(Result);
end;

function SSetExtensionToFileName(const FileName, Extension : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Extension <> '' then
	Result := SFilePath(FileName) + SFileNameWithoutExtension(SFileName(FileName)) + '.' + Extension
else
	Result := SFilePath(FileName) + SFileNameWithoutExtension(SFileName(FileName));
Result := SCheckDirectorySeparators(Result);
end;

function SFreeFileName(const Name : TSString; const Sl : TSString = 'Copy') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	FileExtension : TSString = '';
	FileName      : TSString = '';

function FileNameFromNumber(const Number : TSInt32) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FileName;
if Number > 0 then
	begin
	Result += ' (';
	if Sl <> '' then
		Result += Sl + ' ';
	Result += SStr(Number) + ')';
	end;
if FileExtension <> '' then
	Result += '.' + FileExtension;
end;

var
	Number        : TSInt32 = 1;
begin
if SFileExists(Name) then
	begin
	FileExtension := SFileExtension(Name);
	FileName := SFileNameWithoutExtension(Name);
	while SFileExists(FileNameFromNumber(Number)) do
		Number += 1;
	Result := FileNameFromNumber(Number);
	end
else
	Result := Name;
Result := SCheckDirectorySeparators(Result);
end;

function SFileNameWithoutExtension(const FileName : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSInt32;
	PointPosition : TSInt32 = 0;
begin
for Index:=1 to Length(FileName) do
	begin
	if FileName[Index]='.' then
		begin
		PointPosition:=Index;
		end;
	end;
if (PointPosition=0) then
	Result:=FileName
else
	begin
	Result:='';
	for Index:=1 to PointPosition-1 do
		Result+=FileName[Index];
	end;
Result := SCheckDirectorySeparators(Result);
end;

function SFileExtension(const FileName : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSInt32;
	Extension : TSString = '';
begin
Result:='';
i:=Length(FileName);
while (i<>0)and(FileName[i]<>'.')and(FileName[i]<>UnixDirectorySeparator)and(FileName[i]<>WinDirectorySeparator) do
	begin
	Result+=FileName[i];
	i-=1;
	end;
if FileName=Result then
	Result:=''
else
	begin
	Extension:=Result;
	Result:='';
	i:=Length(Extension);
	while i<>0 do
		begin
		Result+=Extension[i];
		i-=1;
		end;
	end;
Result := SUpCaseString(Result);
end;

(***************)
(** DIRECTORY **)
(***************)

procedure SDeleteDirectory(const Directory : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
RMDIR(Directory);
end;

function SAplicationFileDirectory() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if argc > 0 then
	Result := SFilePath(argv[0])
else
	Result := '';
end;

function SFreeDirectoryName(const Name : TSString; const Sl : TSString = 'Copy') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function DirectoryNameFromNumber(const Number : TSInt32) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Name;
if Number > 0 then
	begin
	Result += ' (';
	if Sl <> '' then
		Result += Sl + ' ';
	Result += SStr(Number) + ')';
	end;
end;

var
	Number : TSInt32 = 1;
begin
if SExistsDirectory(Name) then
	begin
	while SExistsDirectory(DirectoryNameFromNumber(Number)) do
		Number += 1;
	Result := DirectoryNameFromNumber(Number);
	end
else
	Result := Name;
Result := SCheckDirectorySeparators(Result);
end;

function SMakeDirectory(const Directory : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := True;
try
	MKDir(SCheckDirectorySeparators(Directory));
except
	Result := False;
end;
end;

procedure SMakeDirectories(const FinalDirectory : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	DirectoryList : TSStringList = nil;
	i : TSUInt32 = 0;
	Path : TSString = '';
begin
SetLength(DirectoryList, 1);
DirectoryList[0] := '';
i := 1;
while (i <= Length(FinalDirectory)) do
	begin
	if FinalDirectory[i] in [UnixDirectorySeparator, WinDirectorySeparator] then
		begin
		SetLength(DirectoryList, Length(DirectoryList) + 1);
		DirectoryList[High(DirectoryList)] := '';
		end
	else
		begin
		DirectoryList[High(DirectoryList)] += FinalDirectory[i];
		end;
	i += 1;
	end;
Path := '';
for i:=0 to High(DirectoryList) do
	if DirectoryList[i] <> '' then
		begin
		if (DirectoryList[i] <> '.') and (DirectoryList[i] <> '..') then
			SMakeDirectory(Path + DirectoryList[i]);
		Path += DirectoryList[i] + DirectorySeparator;
		end;
SetLength(DirectoryList, 0);
end;

function SExistsDirectory(const Directory : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DirectoryExists(SCheckDirectorySeparators(Directory));
end;

function SDirectoryDirectories(Catalog : TSString; const What : TSString = '') : TSStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Found : Integer;
	SearchRec : TSearchRec;
begin
Result := nil;
if Catalog = '' then
	Catalog := '.';
Catalog := SCheckDirectorySeparators(Catalog);
if Catalog[Length(Catalog)] <> DirectorySeparator then
	Catalog += DirectorySeparator;
if What <> '' then
	Found := FindFirst(Catalog + What, faDirectory, SearchRec)
else
	Found := FindFirst(Catalog + '*', faDirectory, SearchRec);
while Found = 0 do
	begin
	if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (not SFileExists(Catalog + DirectorySeparator + SearchRec.Name)) then
		Result += SearchRec.Name;
	Found := FindNext(SearchRec);
	end;
SysUtils.FindClose(SearchRec);
end;

end.
