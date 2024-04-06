{$INCLUDE Smooth.inc}

unit SmoothConsoleProgramSearchInSources;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothConsoleHandler
	,SmoothDateTime
	
	,Classes
	;

type
	TSSearchInSources = class(TSObject)
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
		FNumberOfFoundedConformities : TSUInt64;
		FNumberOfSearchedFolders : TSUInt64;
		FNumberOfSearchedFiles : TSUInt64;
			private
		FWhereYOnBegin : TSUInt16;
		FDateTimeStart : TSDateTime;
		FDateTimeEnd : TSDateTime;
		FDateTimeLastProgress : TSDateTime;
		FUpdateInterval : TSUInt64;
			private
		procedure InitFileExtensions();
		function PreccessParams(const VParams : TSConsoleHandlerParams = nil) : TSBoolean;
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
		procedure AddConformitiesToResults(const FileName : TSString; const NumberOfConformitiesInLine : TSUInt64; const CurrentLine : TSUInt64);
			public
		procedure Search(const VParams : TSConsoleHandlerParams = nil);
		end;

procedure SConsoleSearchInSources(const VParams : TSConsoleHandlerParams = nil);

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

procedure SConsoleSearchInSources(const VParams : TSConsoleHandlerParams = nil);
begin
with TSSearchInSources.Create() do
	begin
	Search(VParams);
	Destroy();
	end;
end;

//=====================================
//==========TSSearchInSources=========
//=====================================

procedure TSSearchInSources.AddConformitiesToResults(const FileName : TSString; const NumberOfConformitiesInLine : TSUInt64; const CurrentLine : TSUInt64);
var
	OldResultsLength : TSMaxEnum;
	i : TSMaxEnum;
	Quote : TSString;
begin
if NumberOfConformitiesInLine <= 0 then
	exit;
if FFileList = nil then
	OldResultsLength := 0
else
	OldResultsLength := Length(FFileList);
if NumberOfConformitiesInLine > OldResultsLength then
	begin
	SetLength(FFileList, NumberOfConformitiesInLine);
	for i := OldResultsLength to NumberOfConformitiesInLine - 1 do
		FFileList[i] := nil;
	if FFileList[NumberOfConformitiesInLine - 1] = nil then
		FFileList[NumberOfConformitiesInLine - 1] := TFileStream.Create(SStr([FOutDirectory, DirectorySeparator, 'Results of ', NumberOfConformitiesInLine, ' conformities.txt']), fmCreate);
	end;
if FWithQuotes then
	Quote := '"'
else
	Quote := '';
SWriteStringToStream(Quote + FileName + Quote + ' : ' + Quote + SStr(CurrentLine) + Quote + DefaultEndOfLine, FFileList[NumberOfConformitiesInLine - 1], False);
end;

procedure TSSearchInSources.SearchingInFile(const FileName : TSString);
var
	NumberOfConformitiesInLine : TSUInt64;
	CurrentLine : TSUInt64;
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
	TSLog.Source('Search in file "' + FileName + '".');
	FNumberOfSearchedFiles += 1;
	
	CurrentLine := 0;
	while not Eof(SearchFile) do
		begin
		CurrentLine += 1;
		ReadLn(SearchFile, TempString);
		TempString := SUpCaseString(TempString);
		NumberOfConformitiesInLine := 0;
		for Index := 0 to High(FWords) do
			if Pos(FWords[Index], TempString) <> 0 then
				NumberOfConformitiesInLine += 1;
		if NumberOfConformitiesInLine > 0 then
			begin
			FNumberOfFoundedConformities += NumberOfConformitiesInLine;
			AddConformitiesToResults(FileName, NumberOfConformitiesInLine, CurrentLine);
			end;
		end;
	Close(SearchFile);

	if FRealTimeProgress then
		PrintProgress();
	end;
end;

procedure TSSearchInSources.PrintProgress(const TimeCase : TSBool = True);
var
	FDateTimeNow : TSDateTime;
begin
if (TimeCase) then
	begin
	if FUpdateInterval > 0 then
		begin
		FDateTimeNow.Get();
		if (FDateTimeNow - FDateTimeLastProgress).GetPastMilliseconds() >= FUpdateInterval then
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
Write(FNumberOfFoundedConformities);
TextColor(15);
Write(' conformities. Processed ');
TextColor(10);
Write(FNumberOfSearchedFiles);
TextColor(15);
Write(' files in ');
TextColor(14);
Write(FNumberOfSearchedFolders);
TextColor(15);
WriteLn(' directories.');
end;

procedure TSSearchInSources.SearchingFilesInDirectory(const Directory : TSString);
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

procedure TSSearchInSources.SearchingDirectoriesInDirectory(const Directory : TSString);
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

procedure TSSearchInSources.SearchingInDirectory(const Directory : TSString);
begin
FNumberOfSearchedFolders += 1;
SearchingFilesInDirectory(Directory + DirectorySeparator);
SearchingDirectoriesInDirectory(Directory);
end;

procedure TSSearchInSources.DestroyFiles();
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

procedure TSSearchInSources.Searching();
begin
ScaningWords();
ClearSearchData();
FOutDirectory := SFreeDirectoryName('Search in sources results', '');
SMakeDirectory(FOutDirectory);

if (FSearchingDirectory = '') then
	FSearchingDirectory := '.';

TextColor(15);
Write('Created results directory "');
TextColor(14);
Write(FOutDirectory);
TextColor(15);
WriteLn('".');
WriteLn('Search was begins. Press any key to stop.');

FWhereYOnBegin := WhereY();

FDateTimeStart.Get();
FDateTimeLastProgress := FDateTimeStart;
SearchingInDirectory(FSearchingDirectory);
FDateTimeEnd.Get();

PrintProgress();
DestroyFiles();

TextColor(15);
Write('The search lasted ');
TextColor(10);
Write(STextTimeBetweenDates(FDateTimeStart, FDateTimeEnd, 'ENG'));
TextColor(15);
WriteLn('.');

PrintProgress(False);

if FNumberOfFoundedConformities = 0 then
	begin
	if SStringListLength(FWords) > 0 then
		begin
		TextColor(12);
		WriteLn('No ñonformities found.');
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

procedure TSSearchInSources.Search(const VParams : TSConsoleHandlerParams = nil);
begin
if PreccessParams(VParams) then
	if WordsLength() = 0 then
		begin
		SPrintEngineVersion();
		TextColor(12);
		WriteLn('Words for search don''t set; use command "--word*?" for set word for search.');
		TextColor(15);
		end
	else
		Searching();
TextColor(7);
end;

procedure TSSearchInSources.ScaningWords();
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

function TSSearchInSources.WordsLength() : TSMaxEnum;
begin
if FWords = nil then
	Result := 0
else
	Result := Length(FWords);
end;

function TSSearchInSources.PreccessParams(const VParams : TSConsoleHandlerParams = nil) : TSBoolean;
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
Write('Set search directory "');
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
Write('Extensions:');
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

function ProccessRealTimeMS(const Comand : TSString):TSBool;
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
	Write('Update interval: ');
	TextColor(10);
	Write(FUpdateInterval);
	TextColor(15);
	Write(' = ');
	TextColor(10);
	Write(SMilliSecondsToStringTime(FUpdateInterval, 'ENG'));
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
	with TSConsoleHandler.Create(VParams) do
		begin
		Category('Search in sources help');
		AddComand(@ProccessChangeSearchingDirectory, ['fd*?'],  'Set searching directory');
		AddComand(@ProccessViewExtensions, ['viewext'], 'View file extension for search');
		AddComand(@ProccessAddExtension, ['addext*?'], 'Add file extension for search');
		AddComand(@ProccessNewWord, ['word*?'], 'Add word for search');
		AddComand(@ProccessWithQuotes, ['wq'], 'Write to search result file filenames with quotes');
		AddComand(@ProccessRealTimeMS, ['rt*?'], 'Set update interval (ms) for print real time statistic');
		AddComand(@ProccessRealTime, ['rt'], 'Print real time statistic (update when search in directory was done)');
		Result := Execute();
		Result := Result and ContinueExecuting;
		Destroy();
		end;
TextColor(7);
end;

procedure TSSearchInSources.InitFileExtensions();
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
FFileExtensions += 'xml';
FFileExtensions += 'bat';
FFileExtensions += 'cmd';
FFileExtensions += 'sh';
FFileExtensions += 'lua';
end;

constructor TSSearchInSources.Create();
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

procedure TSSearchInSources.ClearSearchData();
begin
FNumberOfFoundedConformities := 0;
FNumberOfSearchedFolders := 0;
FWhereYOnBegin := 0;
FNumberOfSearchedFiles := 0;
end;

destructor TSSearchInSources.Destroy();
begin
DestroyFiles();
SetLength(FFileExtensions, 0);
SetLength(FWords, 0);
FSearchingDirectory := '';
FOutDirectory := '';
inherited Destroy();
end;

end.
