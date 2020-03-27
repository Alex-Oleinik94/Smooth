{$INCLUDE Smooth.inc}

unit SmoothConsoleProgramFindInSources;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothConsoleCaller
	,SmoothDateTime
	
	,Classes
	;

type
	TSFinderInSources = class(TSObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FFileExtensions : TSStringList;
		FSearchingDirectory : TSString;
		FWords : TSStringList;
		FRealTimeProgress : TSBoolean;
		FWithQuotes : TSBoolean;
		FFileList : packed array of TFileStream;
			private
		FOutDirectory : TSString;
		FFoundedMatches : TSUInt64;
		FSearchedFolders : TSUInt64;
		FSearchedFiles : TSUInt64;
			private
		FWhereYOnBegin : TSUInt16;
		FDateTimeStart : TSDateTime;
		FDateTimeEnd : TSDateTime;
		FDateTimeLastProgress : TSDateTime;
		FUpdateInterval : TSUInt64;
			private
		procedure InitFileExtensions();
		function PreccessParams(const VParams : TSConcoleCallerParams = nil) : TSBoolean;
		function WordsLength() : TSMaxEnum;
		procedure Searching();
		procedure ScaningWords();
		procedure ClearSearchData();
		procedure DestroyFiles();
			private
		procedure SearchingInDirectory(const Directory : TSString);
		procedure SearchingFilesInDirectory(const Directory : TSString);
		procedure SearchingInFile(const FileName : TSString);
		procedure SearchingDirectoriesInDirectory(const Directory : TSString);
		procedure PrintProgress(const TimeCase : TSBool = True);
		procedure AddMatchesToResults(const FileName : TSString; const NumLineMatches : TSUInt64; const CurentLine : TSUInt64);
			public
		procedure Search(const VParams : TSConcoleCallerParams = nil);
		end;

procedure SConsoleFindInSources(const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 SmoothStringUtils
	,SmoothStreamUtils
	,SmoothFileUtils
	,SmoothVersion
	,SmoothLog
	
	,Dos
	,Crt
	,StrMan
	;

//===================================
//==========GENERAL=FUNCTION=========
//===================================

procedure SConsoleFindInSources(const VParams : TSConcoleCallerParams = nil);
begin
with TSFinderInSources.Create() do
	begin
	Search(VParams);
	Destroy();
	end;
end;

//=====================================
//==========TSFinderInSources=========
//=====================================

procedure TSFinderInSources.AddMatchesToResults(const FileName : TSString; const NumLineMatches : TSUInt64; const CurentLine : TSUInt64);
var
	OldResultsLength : TSMaxEnum;
	i : TSMaxEnum;
	Quote : TSString;
begin
if NumLineMatches <= 0 then
	exit;
if FFileList = nil then
	OldResultsLength := 0
else
	OldResultsLength := Length(FFileList);
if NumLineMatches > OldResultsLength then
	begin
	SetLength(FFileList, NumLineMatches);
	for i := OldResultsLength to NumLineMatches - 1 do
		FFileList[i] := nil;
	if FFileList[NumLineMatches - 1] = nil then
		FFileList[NumLineMatches - 1] := 
			TFileStream.Create(
				FOutDirectory + 
				DirectorySeparator + 
				'Results of ' + 
				SStr(NumLineMatches) + 
				' matches.txt', fmCreate);
	end;
if FWithQuotes then
	Quote := '"'
else
	Quote := '';
SWriteStringToStream(Quote + FileName + Quote + ' : ' + Quote + SStr(CurentLine) + Quote + SWinEoln, FFileList[NumLineMatches - 1], False);
end;

procedure TSFinderInSources.SearchingInFile(const FileName : TSString);
var
	NumLineMatches : TSUInt64;
	CurentLine : TSUInt64;
	SearchFile : TextFile;
	TempString : TSString;
	Index : TSMaxEnum;
	FileOpen : TSBoolean;
begin
Assign(SearchFile, FileName);
try
	Reset(SearchFile);
	FileOpen := True;
except
	FileOpen := False;
end;
if (FileOpen) then
	begin
	TSLog.Source('Searching in file "' + FileName + '".');
	FSearchedFiles += 1;
	
	CurentLine := 0;
	while not Eof(SearchFile) do
		begin
		CurentLine += 1;
		ReadLn(SearchFile, TempString);
		TempString := SUpCaseString(TempString);
		NumLineMatches := 0;
		for Index := 0 to High(FWords) do
			if Pos(FWords[Index], TempString) <> 0 then
				NumLineMatches += 1;
		if NumLineMatches > 0 then
			begin
			FFoundedMatches += NumLineMatches;
			AddMatchesToResults(FileName, NumLineMatches, CurentLine);
			end;
		end;
	Close(SearchFile);

	if FRealTimeProgress then
		PrintProgress();
	end;
end;

procedure TSFinderInSources.PrintProgress(const TimeCase : TSBool = True);
var
	FDateTimeNow : TSDateTime;
begin
if (TimeCase) then
	begin
	if FUpdateInterval > 0 then
		begin
		FDateTimeNow.Get();
		if (FDateTimeNow - FDateTimeLastProgress).GetPastMiliSeconds() >= FUpdateInterval then
			FDateTimeLastProgress := FDateTimeNow
		else
			exit;
		end;
	if FRealTimeProgress then
		GoToXY(1, FWhereYOnBegin);
	end;
TextColor(15);
Write('Finded ');
TextColor(10);
Write(FFoundedMatches);
TextColor(15);
Write(' matches. Processed ');
TextColor(10);
Write(FSearchedFiles);
TextColor(15);
Write(' files in ');
TextColor(14);
Write(FSearchedFolders);
TextColor(15);
WriteLn(' directories...');
end;

procedure TSFinderInSources.SearchingFilesInDirectory(const Directory : TSString);
var
	SearchRec : Dos.SearchRec;
	i : TSMaxEnum;
begin
for i := 0 to High(FFileExtensions) do
	begin
	Dos.FindFirst(Directory + DirectorySeparator + '*.' + FFileExtensions[i], $3F, SearchRec);
	while DosError <> 18 do
		begin
		SearchingInFile(Directory + SearchRec.name);
		Dos.FindNext(SearchRec);
		end;
	Dos.FindClose(SearchRec);
	end;
end;

procedure TSFinderInSources.SearchingDirectoriesInDirectory(const Directory : TSString);
var
	SearchRec : Dos.SearchRec;
begin
Dos.FindFirst(Directory + DirectorySeparator + '*', $10, SearchRec);
while DosError <> 18 do
	begin
	if  (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and 
		(not (SFileExists(Directory + DirectorySeparator + SearchRec.Name))) then
			SearchingInDirectory(Directory + DirectorySeparator + SearchRec.Name);
	Dos.FindNext(SearchRec);
	end;
Dos.FindClose(SearchRec);
end;

procedure TSFinderInSources.SearchingInDirectory(const Directory : TSString);
begin
FSearchedFolders += 1;
SearchingFilesInDirectory(Directory + DirectorySeparator);
SearchingDirectoriesInDirectory(Directory);
end;

procedure TSFinderInSources.DestroyFiles();
var
	i : TSMaxEnum;
begin
if (FFileList <> nil) and (Length(FFileList) > 0) then
	begin
	for i := 0 to High(FFileList) do
		if FFileList[i] <> nil then
			begin
			FFileList[i].Destroy;
			FFileList[i] := nil;
			end;
	SetLength(FFileList, 0);
	end;
end;

procedure TSFinderInSources.Searching();
begin
ScaningWords();
ClearSearchData();
FOutDirectory := SFreeDirectoryName('Find In Sources Results', 'Part');
SMakeDirectory(FOutDirectory);

if (FSearchingDirectory = '') then
	FSearchingDirectory := '.';

TextColor(15);
Write('Created results directory "');
TextColor(14);
Write(FOutDirectory);
TextColor(15);
WriteLn('".');
WriteLn('Find was begining... Psess any key to stop him...');

FWhereYOnBegin := WhereY();

FDateTimeStart.Get();
FDateTimeLastProgress := FDateTimeStart;
SearchingInDirectory(FSearchingDirectory);
FDateTimeEnd.Get();

PrintProgress();
DestroyFiles();

TextColor(15);
Write('Searching done at ');
TextColor(10);
Write(STextTimeBetweenDates(FDateTimeStart, FDateTimeEnd, 'ENG'));
TextColor(15);
WriteLn('.');

PrintProgress(False);

if FFoundedMatches = 0 then
	begin
	if SStringListLength(FWords) > 0 then
		begin
		TextColor(12);
		WriteLn('Matches don''t exists...');
		TextColor(15);
		end;
	if SExistsDirectory(FOutDirectory) then
		begin
		SDeleteDirectory(FOutDirectory);
		TextColor(15);
		Write('Deleted results directory "');
		TextColor(14);
		Write(FOutDirectory);
		TextColor(15);
		WriteLn('".');
		end;
	end;
TextColor(7);
end;

procedure TSFinderInSources.Search(const VParams : TSConcoleCallerParams = nil);
begin
if PreccessParams(VParams) then
	if WordsLength() = 0 then
		begin
		SPrintEngineVersion();
		TextColor(12);
		WriteLn('Nothing to find!');
		TextColor(15);
		end
	else
		Searching();
TextColor(7);
end;

procedure TSFinderInSources.ScaningWords();
var
	i : TSMaxEnum;
	TempWord : TSString;
begin
SUpCaseStringList(FWords);
i := Low(FWords);
while (i <= High(FWords)) do
	begin
	TempWord := StringTrimAll(FWords[i], ' 	');
	if TempWord = '' then
		SStringListDeleteByIndex(FWords, i)
	else
		i += 1;
	end;
end;

function TSFinderInSources.WordsLength() : TSMaxEnum;
begin
if FWords = nil then
	Result := 0
else
	Result := Length(FWords);
end;

function TSFinderInSources.PreccessParams(const VParams : TSConcoleCallerParams = nil) : TSBoolean;
var
	ContinueExecuting : TSBoolean = True;

function ProccessChangeSearchingDirectory(const Comand : TSString):TSBool;
var
	i : TSMaxEnum;
	TempSearchingDirectory : TSString = '';
begin
Result := True;
TempSearchingDirectory := '';
for i := 3 to Length(Comand) do
	TempSearchingDirectory += Comand[i];
while   (Length(TempSearchingDirectory) > 0) and 
		((TempSearchingDirectory[Length(TempSearchingDirectory)] = '\') or 
		 (TempSearchingDirectory[Length(TempSearchingDirectory)] = '/')) do
	SetLength(TempSearchingDirectory, Length(TempSearchingDirectory) - 1);
if TempSearchingDirectory = '' then
	TempSearchingDirectory := '.';
FSearchingDirectory := TempSearchingDirectory;

SPrintEngineVersion();
TextColor(15);
Write('Selected searching directory "');
TextColor(14);
Write(FSearchingDirectory);
TextColor(15);
WriteLn('".');
end;

function ProccessAddExtension(const Comand : TSString):TSBool;
var
	TempExtension : TSString = '';
	i : TSMaxEnum;
begin
TempExtension := '';
for i := 7 to Length(Comand) do
	TempExtension += SDownCase(Comand[i]);
Result := TempExtension <> '';
if Result then
	begin
	FFileExtensions += TempExtension;
	
	TextColor(15);
	Write('Added file extension "');
	TextColor(13);
	Write(TempExtension);
	TextColor(15);
	WriteLn('".');
	
	TempExtension:= '';
	end;
end;

function ProccessViewExtensions(const Comand : TSString):TSBool;
var
	i : TSMaxEnum;
begin
Result := True;
SPrintEngineVersion();
TextColor(15);
Write('Finded extensions:');
TextColor(14);
Write('{');
for i := 0 to High(FFileExtensions) do
	begin
	TextColor(13);
	Write(FFileExtensions[i]);
	TextColor(14);
	if i <> High(FFileExtensions) then
		Write(',');
	end;
TextColor(14);
WriteLn('}');
TextColor(15);
ContinueExecuting := False;
end;

function ProccessRealTimeMiliSec(const Comand : TSString):TSBool;
var
	TempString : TSString;
	i : TSMaxEnum;
	TempUpdateInterval : TSUInt64;
begin
FRealTimeProgress := True;
TempString := '';
for i := 3 to Length(Comand) do
	TempString += Comand[i];
TempUpdateInterval := SVal(TempString);
Result := TempUpdateInterval <> 0;
if Result then
	begin
	FUpdateInterval := TempUpdateInterval;
	
	TextColor(15);
	Write('Updating interval: ');
	TextColor(10);
	Write(FUpdateInterval);
	TextColor(15);
	Write(' = ');
	TextColor(10);
	Write(SMiliSecondsToStringTime(FUpdateInterval, 'ENG'));
	TextColor(15);
	WriteLn('.');
	end;
end;

function ProccessRealTime(const Comand : TSString):TSBool;
begin
FRealTimeProgress := True;
Result := True;
end;

function ProccessWithQuotes(const Comand : TSString):TSBool;
begin
FWithQuotes := True;
Result := True;
end;

function ProccessNewWord(const Comand : TSString):TSBool;
var
	i : TSMaxEnum;
	TempWord : TSString;
begin
TempWord := '';
for i := 5 to Length(Comand) do
	TempWord += Comand[i];
Result := TempWord <> '';
if Result then
	begin
	FWords += TempWord;
	
	SPrintEngineVersion();
	TextColor(15);
	Write('Word "');
	TextColor(14);
	Write(TempWord);
	TextColor(15);
	WriteLn('" added.');
	end;
end;

begin
Result := True;
TextColor(15);
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSConsoleCaller.Create(VParams) do
		begin
		Category('Find in Sources help');
		AddComand(@ProccessChangeSearchingDirectory, ['fd*?'],  'for change searching directory');
		AddComand(@ProccessViewExtensions, ['viewext'], 'for view file extension for find');
		AddComand(@ProccessAddExtension, ['addext*?'], 'for add file extension for find');
		AddComand(@ProccessNewWord, ['word*?'], 'for add word for searching');
		AddComand(@ProccessWithQuotes, ['wq'], 'for out to results files with quotes');
		AddComand(@ProccessRealTimeMiliSec, ['rt*?'], 'for print realtime statistics data one at $num milisec');
		AddComand(@ProccessRealTime, ['rt'], 'for print realtime statistics data (update when directory was allmost searched)');
		Result := Execute();
		Result := Result and ContinueExecuting;
		Destroy();
		end;
TextColor(7);
end;

procedure TSFinderInSources.InitFileExtensions();
begin
SetLength(FFileExtensions, 0);
FFileExtensions += 'pas';
FFileExtensions += 'pp';
FFileExtensions += 'inc';
FFileExtensions += 'cpp';
FFileExtensions += 'cxx';
FFileExtensions += 'h';
FFileExtensions += 'hpp';
FFileExtensions += 'hxx';
FFileExtensions += 'c';
FFileExtensions += 'html';
FFileExtensions += 'bat';
FFileExtensions += 'cmd';
FFileExtensions += 'sh';
FFileExtensions += 'lua';
end;

constructor TSFinderInSources.Create();
begin
inherited Create();
InitFileExtensions();
FSearchingDirectory := '';
FWords := nil;
FOutDirectory := '';
FRealTimeProgress := False;
FFileList := nil;
FWithQuotes := False;
FUpdateInterval := 0;
end;

procedure TSFinderInSources.ClearSearchData();
begin
FFoundedMatches := 0;
FSearchedFolders := 0;
FWhereYOnBegin := 0;
FSearchedFiles := 0;
end;

destructor TSFinderInSources.Destroy();
begin
DestroyFiles();
SetLength(FFileExtensions, 0);
SetLength(FWords, 0);
FSearchingDirectory := '';
FOutDirectory := '';
inherited Destroy();
end;

end.
