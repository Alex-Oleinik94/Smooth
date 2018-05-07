{$INCLUDE SaGe.inc}

unit SaGeFileUtils;

interface

uses
	 Classes
	,SysUtils
	
	,SaGeBase
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
	// SaGe Directories
	SGSaGeDirectory     = '.' + DirectorySeparator + '..';
	SGDataDirectory     = SGSaGeDirectory + DirectorySeparator + 'Data';
	SGTempDirectory     = SGSaGeDirectory + DirectorySeparator + 'Temp';
	SGFontDirectory     = SGDataDirectory + DirectorySeparator + 'Fonts';
	SGTextureDirectory  = SGDataDirectory + DirectorySeparator + 'Textures';
	SGModelsDirectory   = SGDataDirectory + DirectorySeparator + 'Models';
	SGExamplesDirectory = SGDataDirectory + DirectorySeparator + 'Examples';
	SGEngineDirectory   = SGDataDirectory + DirectorySeparator + 'Engine';
	SGImagesDirectory   = SGDataDirectory + DirectorySeparator + 'Images';
	SGFontsDirectory    = SGFontDirectory;
	SGTexturesDirectory = SGTextureDirectory;
	// SaGe Absolute Directories
	SGAbsoluteSaGeDirectory = 
		{$IFDEF MOBILE}
			{$IFDEF ANDROID}
				DirectorySeparator + 'sdcard' + DirectorySeparator + '.SaGe'
			{$ELSE}
				''
			{$ENDIF}
		{$ELSE}
			SGSaGeDirectory
		{$ENDIF}
		;
	SGAbsoluteDataDirectory     = SGAbsoluteSaGeDirectory + DirectorySeparator + 'Data';
	SGAbsoluteTempDirectory     = SGAbsoluteSaGeDirectory + DirectorySeparator + 'Temp';
	SGAbsoluteFontDirectory     = SGAbsoluteDataDirectory + DirectorySeparator + 'Fonts';
	SGAbsoluteTextureDirectory  = SGAbsoluteDataDirectory + DirectorySeparator + 'Textures';
	SGAbsoluteModelsDirectory   = SGAbsoluteDataDirectory + DirectorySeparator + 'Models';
	SGAbsoluteExamplesDirectory = SGAbsoluteDataDirectory + DirectorySeparator + 'Examples';
	SGAbsoluteEngineDirectory   = SGAbsoluteDataDirectory + DirectorySeparator + 'Engine';
	SGAbsoluteImagesDirectory   = SGAbsoluteDataDirectory + DirectorySeparator + 'Images';
	SGAbsoluteTexturesDirectory = SGAbsoluteTextureDirectory;
	SGAbsoluteFontsDirectory    = SGAbsoluteFontDirectory;
const
	// End Of Line$File
	SGUnixEoln = #10;
	SGWinEoln  = #13#10;
	SGMacEoln  = #13;
	SGEof      = #$1A;

(************)
(** COMMON **)
(************)

function SGCheckDirectorySeparators(const Path : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGExportStringToFile(const FileName, Data : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(**********)
(** FILE **)
(**********)

function SGFileExpansion(const FileName : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFileNameWithoutExpansion(const FileName : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFreeFileName(const Name : TSGString; const Sl : TSGString = 'Copy') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGSetExpansionToFileName(const FileName, Expansion : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFileName(const PathName : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFilePath(Path : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGApplicationFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFileExists(const FileName : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(***************)
(** DIRECTORY **)
(***************)

function SGAplicationFileDirectory() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGFreeDirectoryName(const Name : TSGString; const sl : TSGString = 'Copy') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGMakeDirectory(const Directory : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGMakeDirectories(const FinalDirectory : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGDeleteDirectory(const Directory : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGExistsDirectory(const Directory : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDirectoryDirectories(Catalog : TSGString; const What : TSGString = '') : TSGStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(************************)
(** DIRECTORY AND FILES**)
(************************)

function SGDirectoryFiles(Catalog : TSGString; const What : TSGString = '') : TSGStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	;

(************)
(** COMMON **)
(************)

function SGCheckDirectorySeparators(const Path : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar;
begin
Result := '';
for C in Path do
	if C in DirectorySeparators then
		Result += DirectorySeparator
	else
		Result += C;
end;

procedure SGExportStringToFile(const FileName, Data : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function SGDirectoryFiles(Catalog : TSGString; const What : TSGString = '') : TSGStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Found : Integer;
	SearchRec : TSearchRec;
begin
Result := nil;
if Catalog = '' then
	Catalog := '.';
Catalog := SGCheckDirectorySeparators(Catalog);
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

function SGFileExists(const FileName : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FileExists(SGCheckDirectorySeparators(FileName));
end;

function SGApplicationFileName() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if argc > 0 then
	Result := SGCheckDirectorySeparators(argv[0])
else
	Result := '';
end;

function SGFilePath(Path : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSGUInt32;
begin
Path := SGCheckDirectorySeparators(Path);
if SGFileName(Path) = '' then
	Result := Path
else
	begin
	Result:='';
	ii := 0;
	for i:=1 to Length(Path) do
		if Path[i] in [UnixDirectorySeparator, WinDirectorySeparator] then
			ii:=i;
	if ii<>0 then
		begin
		for i:=1 to ii do
			Result += Path[i];
		end;
	end;
end;

function SGFileName(const PathName : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
	B : TSGBool   = False;
	E : TSGBool   = False;
	S : TSGString = '';
begin
Result:='';
i:=Length(PathName);
while (not E) and (i>0) and (PathName[i]<>UnixDirectorySeparator) and (PathName[i]<>WinDirectorySeparator)  do
	begin
	Result+=PathName[i];
	if PathName[i]='.' then
		if b then
			E:=True
		else
			begin
			b:=True;
			Result:='';
			end;
	i-=1;
	end;
S:=Result;
Result:='';
for i:=Length(S) downto 1 do
	Result+=S[i];
SetLength(S,0);
Result := SGCheckDirectorySeparators(Result);
end;

function SGSetExpansionToFileName(const FileName, Expansion : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Expansion <> '' then
	Result := SGFilePath(FileName) + SGFileNameWithoutExpansion(SGFileName(FileName)) + '.' + Expansion
else
	Result := SGFilePath(FileName) + SGFileNameWithoutExpansion(SGFileName(FileName));
Result := SGCheckDirectorySeparators(Result);
end;

function SGFreeFileName(const Name : TSGString; const Sl : TSGString = 'Copy') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	FileExpansion : TSGString = '';
	FileName      : TSGString = '';

function FileNameFromNumber(const Number : TSGInt32) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FileName;
if Number > 0 then
	begin
	Result += ' (';
	if Sl <> '' then
		Result += Sl + ' ';
	Result += SGStr(Number) + ')';
	end;
if FileExpansion <> '' then
	Result += '.' + FileExpansion;
end;

var
	Number        : TSGInt32 = 1;
begin
if SGFileExists(Name) then
	begin
	FileExpansion := SGFileExpansion(Name);
	FileName := SGFileNameWithoutExpansion(Name);
	while SGFileExists(FileNameFromNumber(Number)) do
		Number += 1;
	Result := FileNameFromNumber(Number);
	end
else
	Result := Name;
Result := SGCheckDirectorySeparators(Result);
end;

function SGFileNameWithoutExpansion(const FileName : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
	PointPosition : TSGInt32 = 0;
begin
for i:=1 to Length(FileName) do
	begin
	if FileName[i]='.' then
		begin
		PointPosition:=i;
		end;
	end;
if (PointPosition=0) then
	Result:=FileName
else
	begin
	Result:='';
	for i:=1 to PointPosition-1 do
		Result+=FileName[i];
	end;
Result := SGCheckDirectorySeparators(Result);
end;

function SGFileExpansion(const FileName : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGInt32;
	Expansion : TSGString = '';
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
	Expansion:=Result;
	Result:='';
	i:=Length(Expansion);
	while i<>0 do
		begin
		Result+=Expansion[i];
		i-=1;
		end;
	end;
Result := SGUpCaseString(Result);
end;

(***************)
(** DIRECTORY **)
(***************)

procedure SGDeleteDirectory(const Directory : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
RMDIR(Directory);
end;

function SGAplicationFileDirectory() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if argc > 0 then
	Result := SGFilePath(argv[0])
else
	Result := '';
end;

function SGFreeDirectoryName(const Name : TSGString; const Sl : TSGString = 'Copy') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function DirectoryNameFromNumber(const Number : TSGInt32) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Name;
if Number > 0 then
	begin
	Result += ' (';
	if Sl <> '' then
		Result += Sl + ' ';
	Result += SGStr(Number) + ')';
	end;
end;

var
	Number : TSGInt32 = 1;
begin
if SGExistsDirectory(Name) then
	begin
	while SGExistsDirectory(DirectoryNameFromNumber(Number)) do
		Number += 1;
	Result := DirectoryNameFromNumber(Number);
	end
else
	Result := Name;
Result := SGCheckDirectorySeparators(Result);
end;

function SGMakeDirectory(const Directory : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := True;
try
	MKDir(SGCheckDirectorySeparators(Directory));
except
	Result := False;
end;
end;

procedure SGMakeDirectories(const FinalDirectory : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	DirectoryList : TSGStringList = nil;
	i : TSGUInt32 = 0;
	Path : TSGString = '';
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
			SGMakeDirectory(Path + DirectoryList[i]);
		Path += DirectoryList[i] + DirectorySeparator;
		end;
SetLength(DirectoryList, 0);
end;

function SGExistsDirectory(const Directory : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DirectoryExists(SGCheckDirectorySeparators(Directory));
end;

function SGDirectoryDirectories(Catalog : TSGString; const What : TSGString = '') : TSGStringList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Found : Integer;
	SearchRec : TSearchRec;
begin
Result := nil;
if Catalog = '' then
	Catalog := '.';
Catalog := SGCheckDirectorySeparators(Catalog);
if Catalog[Length(Catalog)] <> DirectorySeparator then
	Catalog += DirectorySeparator;
if What <> '' then
	Found := FindFirst(Catalog + What, faDirectory, SearchRec)
else
	Found := FindFirst(Catalog + '*', faDirectory, SearchRec);
while Found = 0 do
	begin
	if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (not SGFileExists(Catalog + DirectorySeparator + SearchRec.Name)) then
		Result += SearchRec.Name;
	Found := FindNext(SearchRec);
	end;
SysUtils.FindClose(SearchRec);
end;

end.
