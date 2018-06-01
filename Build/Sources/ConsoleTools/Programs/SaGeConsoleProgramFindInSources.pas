{$INCLUDE SaGe.inc}

unit SaGeConsoleProgramFindInSources;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeClasses
	,SaGeConsoleToolsBase
	,SaGeDateTime
	
	,Classes
	;

type
	TSGFinderInSources = class(TSGObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FFileExtensions : TSGStringList;
		FSearchingDirectory : TSGString;
		FWords : TSGStringList;
		FRealTimeProgress : TSGBoolean;
		FWithQuotes : TSGBoolean;
		FFileList : packed array of TFileStream;
			private
		FOutDirectory : TSGString;
		FFoundedMatches : TSGUInt64;
		FSearchedFolders : TSGUInt64;
		FSearchedFiles : TSGUInt64;
			private
		FWhereYOnBegin : TSGUInt16;
		FDateTimeStart : TSGDateTime;
		FDateTimeEnd : TSGDateTime;
		FDateTimeLastProgress : TSGDateTime;
		FUpdateInterval : TSGUInt64;
			private
		procedure InitFileExtensions();
		function PreccessParams(const VParams : TSGConcoleCallerParams = nil) : TSGBoolean;
		function WordsLength() : TSGMaxEnum;
		procedure Searching();
		procedure ScaningWords();
		procedure ClearSearchData();
		procedure DestroyFiles();
			private
		procedure SearchingInDirectory(const Directory : TSGString);
		procedure SearchingFilesInDirectory(const Directory : TSGString);
		procedure SearchingInFile(const FileName : TSGString);
		procedure SearchingDirectoriesInDirectory(const Directory : TSGString);
		procedure PrintProgress();
		procedure AddMatchesToResults(const FileName : TSGString; const NumLineMatches : TSGUInt64; const CurentLine : TSGUInt64);
			public
		procedure Search(const VParams : TSGConcoleCallerParams = nil);
		end;

procedure SGConsoleFindInSources(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 SaGeStringUtils
	,SaGeStreamUtils
	,SaGeFileUtils
	,SaGeVersion
	
	,Dos
	,Crt
	,StrMan
	;

//===================================
//==========GENERAL=FUNCTION=========
//===================================

procedure SGConsoleFindInSources(const VParams : TSGConcoleCallerParams = nil);
begin
with TSGFinderInSources.Create() do
	begin
	Search(VParams);
	Destroy();
	end;
end;

//=====================================
//==========TSGFinderInSources=========
//=====================================

procedure TSGFinderInSources.AddMatchesToResults(const FileName : TSGString; const NumLineMatches : TSGUInt64; const CurentLine : TSGUInt64);
var
	OldResultsLength : TSGMaxEnum;
	i : TSGMaxEnum;
	Quote : TSGString;
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
				SGStr(NumLineMatches) + 
				' matches.txt', fmCreate);
	end;
if FWithQuotes then
	Quote := '"'
else
	Quote := '';
SGWriteStringToStream(Quote + FileName + Quote + ' : ' + Quote + SGStr(CurentLine) + Quote + SGWinEoln, FFileList[NumLineMatches - 1], False);
end;

procedure TSGFinderInSources.SearchingInFile(const FileName : TSGString);
var
	NumLineMatches : TSGUInt64;
	CurentLine : TSGUInt64;
	SearchFile : TextFile;
	TempString : TSGString;
	i : TSGMaxEnum;
begin
FSearchedFiles += 1;

Assign(SearchFile, FileName);
Reset(SearchFile);
CurentLine := 0;
while not Eof(SearchFile) do
	begin
	CurentLine += 1;
	ReadLn(SearchFile, TempString);
	TempString := SGUpCaseString(TempString);
	NumLineMatches := 0;
	for i := 0 to High(FWords) do
		if Pos(FWords[i], TempString) <> 0 then
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

procedure TSGFinderInSources.PrintProgress();
var
	FDateTimeNow : TSGDateTime;
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

procedure TSGFinderInSources.SearchingFilesInDirectory(const Directory : TSGString);
var
	SearchRec : Dos.SearchRec;
	i : TSGMaxEnum;
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

procedure TSGFinderInSources.SearchingDirectoriesInDirectory(const Directory : TSGString);
var
	SearchRec : Dos.SearchRec;
begin
Dos.FindFirst(Directory + DirectorySeparator + '*', $10, SearchRec);
while DosError <> 18 do
	begin
	if  (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and 
		(not (SGFileExists(Directory + DirectorySeparator + SearchRec.Name))) then
			SearchingInDirectory(Directory + DirectorySeparator + SearchRec.Name);
	Dos.FindNext(SearchRec);
	end;
Dos.FindClose(SearchRec);
end;

procedure TSGFinderInSources.SearchingInDirectory(const Directory : TSGString);
begin
FSearchedFolders += 1;
SearchingFilesInDirectory(Directory + DirectorySeparator);
SearchingDirectoriesInDirectory(Directory);
end;

procedure TSGFinderInSources.DestroyFiles();
var
	i : TSGMaxEnum;
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

procedure TSGFinderInSources.Searching();
begin
ScaningWords();
ClearSearchData();

FOutDirectory := SGFreeDirectoryName('Find In Sources Results', 'Part');
SGMakeDirectory(FOutDirectory);

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
Write(SGTextTimeBetweenDates(FDateTimeStart, FDateTimeEnd, 'ENG'));
TextColor(15);
WriteLn('.');

if FFoundedMatches = 0 then
	begin
	if SGStringListLength(FWords) > 0 then
		begin
		TextColor(12);
		WriteLn('Matches don''t exists...');
		TextColor(15);
		end;
	if SGExistsDirectory(FOutDirectory) then
		begin
		SGDeleteDirectory(FOutDirectory);
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

procedure TSGFinderInSources.Search(const VParams : TSGConcoleCallerParams = nil);
begin
if PreccessParams(VParams) then
	if WordsLength() = 0 then
		begin
		SGPrintEngineVersion();
		TextColor(12);
		WriteLn('Nothing to find!');
		TextColor(15);
		end
	else
		Searching();
TextColor(7);
end;

procedure TSGFinderInSources.ScaningWords();
var
	i : TSGMaxEnum;
	TempWord : TSGString;
begin
SGUpCaseStringList(FWords);
i := Low(FWords);
while (i <= High(FWords)) do
	begin
	TempWord := StringTrimAll(FWords[i], ' 	');
	if TempWord = '' then
		SGStringListDeleteByIndex(FWords, i)
	else
		i += 1;
	end;
end;

function TSGFinderInSources.WordsLength() : TSGMaxEnum;
begin
if FWords = nil then
	Result := 0
else
	Result := Length(FWords);
end;

function TSGFinderInSources.PreccessParams(const VParams : TSGConcoleCallerParams = nil) : TSGBoolean;
var
	ContinueExecuting : TSGBoolean = True;

function ProccessChangeSearchingDirectory(const Comand : TSGString):TSGBool;
var
	i : TSGMaxEnum;
	TempSearchingDirectory : TSGString = '';
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

SGPrintEngineVersion();
TextColor(15);
Write('Selected searching directory "');
TextColor(14);
Write(FSearchingDirectory);
TextColor(15);
WriteLn('".');
end;

function ProccessAddExtension(const Comand : TSGString):TSGBool;
var
	TempExtension : TSGString = '';
	i : TSGMaxEnum;
begin
TempExtension := '';
for i := 7 to Length(Comand) do
	TempExtension += SGDownCase(Comand[i]);
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

function ProccessViewExtensions(const Comand : TSGString):TSGBool;
var
	i : TSGMaxEnum;
begin
Result := True;
SGPrintEngineVersion();
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

function ProccessRealTimeMiliSec(const Comand : TSGString):TSGBool;
var
	TempString : TSGString;
	i : TSGMaxEnum;
	TempUpdateInterval : TSGUInt64;
begin
FRealTimeProgress := True;
TempString := '';
for i := 3 to Length(Comand) do
	TempString += Comand[i];
TempUpdateInterval := SGVal(TempString);
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
	Write(SGMiliSecondsToStringTime(FUpdateInterval, 'ENG'));
	TextColor(15);
	WriteLn('.');
	end;
end;

function ProccessRealTime(const Comand : TSGString):TSGBool;
begin
FRealTimeProgress := True;
Result := True;
end;

function ProccessWithQuotes(const Comand : TSGString):TSGBool;
begin
FWithQuotes := True;
Result := True;
end;

function ProccessNewWord(const Comand : TSGString):TSGBool;
var
	i : TSGMaxEnum;
	TempWord : TSGString;
begin
TempWord := '';
for i := 5 to Length(Comand) do
	TempWord += Comand[i];
Result := TempWord <> '';
if Result then
	begin
	FWords += TempWord;
	
	SGPrintEngineVersion();
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
	with TSGConsoleCaller.Create(VParams) do
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

procedure TSGFinderInSources.InitFileExtensions();
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

constructor TSGFinderInSources.Create();
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

procedure TSGFinderInSources.ClearSearchData();
begin
FFoundedMatches := 0;
FSearchedFolders := 0;
FWhereYOnBegin := 0;
FSearchedFiles := 0;
end;

destructor TSGFinderInSources.Destroy();
begin
DestroyFiles();
SetLength(FFileExtensions, 0);
SetLength(FWords, 0);
FSearchingDirectory := '';
FOutDirectory := '';
inherited Destroy();
end;

end.
