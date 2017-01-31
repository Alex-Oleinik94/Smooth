{$INCLUDE SaGe.inc}

unit SaGeConsoleProgramGoogleReNameCache;

interface

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleGoogleReNameCache(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 Dos
	,Classes
	{$IFDEF MSWINDOWS}
		,Windows
	{$ELSE}
		,Unix
	{$ENDIF}
	
	,SaGeContext
	,SaGeVersion
	,SaGeImageFormatDeterminer
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	;

procedure SGConsoleGoogleReNameCache(const VParams : TSGConcoleCallerParams = nil);
type
	TSGGRCResult = (SGBad, SGSuccess, SGUnknown);
var
	CacheDirectory : TSGString = '';
	TempDirectory : TSGString = '';
	ComplitedDirectory : TSGString = '';
	TempDirectoryEnabled : TSGBool = False;
	WriteUnknows : TSGBool = False;
	OpenResultDir : TSGBool = True;
	Mask : TSGString = 'f_*';

procedure OpenResultDirectoy();
begin
{$IFDEF MSWINDOWS}
	Exec('explorer.exe', '"' + ComplitedDirectory + '"');
	{$ENDIF}
end;

procedure MoveCachedFile(const Source, Destination : TSGString);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
{$IFDEF MOBILE}
{$HINT GRC not allowed here!}
{$ELSE}
{$IFDEF MSWINDOWS}MoveFile{$ELSE}RenameFile{$ENDIF}(
	SGStringToPChar(Source),
	SGStringToPChar(Destination)
	);
{$ENDIF}
end;

function BeginingOfStream(const Stream : TStream) : TStream;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Stream;
Result.Position := 0;
end;

function FindFileExpansion(const Stream : TStream) : TSGString;

function MatchingByte(const B : TSGByte) : TSGBool;
var
	SB : TSGByte;
begin
with BeginingOfStream(Stream) do
	ReadBuffer(SB, 1);
Result := B = SB;
end;

function MatchingByte2(const B1, B2 : TSGByte) : TSGBool;
var
	SB1, SB2 : TSGByte;
begin
with BeginingOfStream(Stream) do
	begin
	ReadBuffer(SB1, 1);
	ReadBuffer(SB2, 1);
	end;
Result := (B1 = SB1) and (B2 = SB2);
end;

begin
Result := '';
if MatchingByte(8508) or
   MatchingByte(29230) or
   MatchingByte(35615) or
   MatchingByte(10799) or
   MatchingByte(12079) or
   MatchingByte(28777) or
   MatchingByte(10250) then
	Result := ' ';
Result := TSGImageFormatDeterminer.DetermineExpansion(Stream);
if MatchingByte(22339) then ; //хз
if MatchingByte(20617) then Result := 'png';
if MatchingByte(55551) then Result := 'jpg';
if MatchingByte(17481) then Result := 'mp3';
//if MatchingByte(18759) then Result := 'gif';
if MatchingByte2(0, 8192) then Result := 'wmv';
if  SGMatchingStreamString(BeginingOfStream(Stream), '<!doctype html><html', False) or
	SGMatchingStreamString(BeginingOfStream(Stream), '<html',                False) then
		Result := 'html';
end;

procedure WriteUnknownFile(const FileName : TSGString; const Stream : TStream);
var
	Len : TSGUInt32 = 20;
	Str : packed array of TSGChar;
	C : TSGChar;
	Str2 : TSGString;
begin
Stream.Position := 0;
if Stream.Size < Len then
	Len := Stream.Size;
SetLength(Str, Len);
Stream.ReadBuffer(Str[0], Len);
for C in Str do
	Str2 += C;
SGHint(['GRC: Unknown "',FileName,'", ', SGGetSizeString(Stream.Size, 'EN'),' : ', Str2, SGStringIf(Len <> Stream.Size, '..')]);
SetLength(Str, 0);
end;

function Proccess(const FileName : TSGString) : TSGGRCResult;
var
	Expansion : TSGString;
	Stream : TMemoryStream = nil;
begin
Result := SGBad;
Expansion := '';
Stream := TMemoryStream.Create();
Stream.LoadFromFile(CacheDirectory + DirectorySeparator + FileName);
Expansion := FindFileExpansion(Stream);
if (Expansion = '') and WriteUnknows then
	WriteUnknownFile(FileName, Stream);
Stream.Destroy();
Stream := nil;
if Expansion=' ' then
	begin
	if TempDirectoryEnabled then
		MoveCachedFile(CacheDirectory + DirectorySeparator + FileName, TempDirectory + DirectorySeparator + FileName);
	end
else if Expansion<>'' then
	MoveCachedFile(CacheDirectory + DirectorySeparator + FileName, ComplitedDirectory + DirectorySeparator + FileName + '.' + Expansion);
if Expansion = '' then
	Result := SGUnknown
else if Expansion = ' ' then
	Result := SGBad
else
	Result := SGSuccess;
end;

procedure MainLoop();
var
	Files : TSGStringList = nil;
	FileName : TSGString;
var
	CountBad : TSGUInt32 = 0;
	CountUnknown : TSGUInt32 = 0;
	CountComplited : TSGUInt32 = 0;
	FileResult : TSGGRCResult;
begin
Files := SGDirectoryFiles(CacheDirectory + DirectorySeparator, Mask);
for FileName in Files do
	if not ('.' in FileName) then
		case Proccess(FileName) of
		SGUnknown : CountUnknown += 1;
		SGBad     : CountBad += 1;
		SGSuccess : CountComplited += 1;
		end;
SGHint(['Some statistic info:']);
SGHint(['  ', CountComplited, ' complited files.']);
SGHint(['  ', CountUnknown, ' unknown files.']);
SGHint(['  ', CountBad, ' bad files.']);
if OpenResultDir and (CountComplited <> 0) then
	OpenResultDirectoy();
SetLength(Files, 0);
end;

function ReadParams() : TSGBool;

function SelectCacheDir(const Param : TSGString) : TSGBool;
begin
Result := False;
(** TODO **)
if Result then
	SGHint('GRC: Set cache directory to "' + CacheDirectory + '".');
end;

function SelectTempDir(const Param : TSGString) : TSGBool;
begin
Result := False;
(** TODO **)
if Result then
	begin
	TempDirectoryEnabled := True;
	SGHint('GRC: Temp directory enabled and set to "' + TempDirectory + '".');
	end;
end;

function SelectResultDir(const Param : TSGString) : TSGBool;
begin
Result := False;
(** TODO **)
if Result then
	SGHint('GRC: Set result directory to "' + ComplitedDirectory + '".');
end;

function SelectCacheDirSimject(const Param : TSGString) : TSGBool;
begin
Result := False;
{$IFDEF MSWINDOWS}
	CacheDirectory := TSGCompatibleContext.UserProfilePath() + DirectorySeparator + 'AppData' + DirectorySeparator + 'Local' + DirectorySeparator + 'Slimjet' + DirectorySeparator + 'User Data' + DirectorySeparator + 'Default' + DirectorySeparator + 'Cache';
	Result := True;
{$ELSE MSWINDOWS}
	(** TODO **)
{$ENDIF MSWINDOWS}
if Result then
	SGHint('GRC: Set cache directory to "' + CacheDirectory + '".');
end;

function EnableTempDirectory(const Param : TSGString) : TSGBool;
begin
Result := True;
TempDirectoryEnabled := True;
SGHint('GRC: Enabled temp directory.');
end;

function EnableWriteUnknows(const Param : TSGString) : TSGBool;
begin
Result := True;
WriteUnknows := True;
SGHint('GRC: Enabled writing unknows.');
end;

function SetMask(const Param : TSGString) : TSGBool;
begin
Result := False;
(** TODO **)
if Result then
	SGHint('GRC: Set mask cached files to "' + Mask + '".');
end;

begin
Result := True;
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSGConsoleCaller.Create(VParams) do
		begin
		Category('Settings');
		AddComand(@EnableTempDirectory, ['temp'], 'Enable temp directory');
		AddComand(@EnableWriteUnknows, ['wu'], 'Enable write unknows');
		AddComand(@SetMask, ['mask:*?'], 'Set file mask for cache files');
		Category('Default paths');
		AddComand(@SelectCacheDirSimject, ['cd:Slimjet','cache:Slimjet'], 'Set cache directory for browser Slimjet for curent user');
		Category('Paths');
		AddComand(@SelectCacheDir, ['cd:*?','cache:*?'], 'Set cache directory');
		AddComand(@SelectTempDir, ['td:*?','temp:*?'], 'Set temp directory');
		AddComand(@SelectResultDir, ['rd:*?','result:*?'], 'Set directory for results');
		Result := Execute();
		Destroy();
		end;
if CacheDirectory = '' then
	CacheDirectory := '.' + DirectorySeparator + 'Cache';
if (TempDirectory = '') and TempDirectoryEnabled then
	TempDirectory := CacheDirectory + DirectorySeparator + 'Temp';
if ComplitedDirectory = '' then
	ComplitedDirectory := CacheDirectory + DirectorySeparator + 'Complited';
end;

begin
SGPrintEngineVersion();
if not ReadParams() then
	Exit;
if not SGExistsDirectory(CacheDirectory) then
	begin
	SGHint(['GRC: Cashe Directory does not exists: "',CacheDirectory,'"!']);
	Exit;
	end;
if TempDirectoryEnabled then
	SGMakeDirectory(TempDirectory);
SGMakeDirectory(ComplitedDirectory);
MainLoop();
end;

end.
