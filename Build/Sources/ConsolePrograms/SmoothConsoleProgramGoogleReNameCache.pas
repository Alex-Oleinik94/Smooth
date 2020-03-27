{$INCLUDE Smooth.inc}

unit SmoothConsoleProgramGoogleReNameCache;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothConsoleCaller
	;

procedure SConsoleGoogleReNameCache(const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 Dos
	,Classes
	,SysUtils
	{$IFDEF MSWINDOWS}
		,Windows
	{$ELSE}
		,Unix
	{$ENDIF}
	
	,SmoothContext
	,SmoothVersion
	,SmoothImageFormatDeterminer
	,SmoothStreamUtils
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	;

procedure SConsoleGoogleReNameCache(const VParams : TSConcoleCallerParams = nil);
type
	TSGRCResult = (SBad, SSuccess, SUnknown);
var
	CacheDirectory : TSString = '';
	TempDirectory : TSString = '';
	ComplitedDirectory : TSString = '';
	TempDirectoryEnabled : TSBool = False;
	WriteUnknows : TSBool = False;
	OpenResultDir : TSBool = True;
	Mask : TSString = 'f_*';

procedure OpenResultDirectoy();
begin
{$IFDEF MSWINDOWS}
	Exec('explorer.exe', '"' + ComplitedDirectory + '"');
	{$ENDIF}
end;

procedure MoveCachedFile(const Source, Destination : TSString);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
{$IFDEF MOBILE}
{$HINT GRC not allowed here!}
{$ELSE}
{$IFDEF MSWINDOWS}MoveFile{$ELSE}RenameFile{$ENDIF}(
	SStringToPChar(Source),
	SStringToPChar(Destination)
	);
{$ENDIF}
end;

function BeginingOfStream(const Stream : TStream) : TStream;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Stream;
Result.Position := 0;
end;

function FindFileExpansion(const Stream : TStream) : TSString;

function MatchingByte(const B : TSByte) : TSBool;
var
	SB : TSByte;
begin
with BeginingOfStream(Stream) do
	ReadBuffer(SB, 1);
Result := B = SB;
end;

function MatchingByte2(const B1, B2 : TSByte) : TSBool;
var
	SB1, SB2 : TSByte;
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
Result := TSImageFormatDeterminer.DetermineExpansion(Stream);
if MatchingByte(22339) then ; //хз
if MatchingByte(20617) then Result := 'png';
if MatchingByte(55551) then Result := 'jpg';
if MatchingByte(17481) then Result := 'mp3';
//if MatchingByte(18759) then Result := 'gif';
if MatchingByte2(0, 8192) then Result := 'wmv';
if  SMatchingStreamString(BeginingOfStream(Stream), '<!doctype html><html', False) or
	SMatchingStreamString(BeginingOfStream(Stream), '<html',                False) then
		Result := 'html';
end;

procedure WriteUnknownFile(const FileName : TSString; const Stream : TStream);
var
	Len : TSUInt32 = 20;
	Str : packed array of TSChar;
	C : TSChar;
	Str2 : TSString;
begin
Stream.Position := 0;
if Stream.Size < Len then
	Len := Stream.Size;
SetLength(Str, Len);
Stream.ReadBuffer(Str[0], Len);
for C in Str do
	Str2 += C;
SHint(['GRC: Unknown "',FileName,'", ', SGetSizeString(Stream.Size, 'EN'),' : ', Str2, SStringIf(Len <> Stream.Size, '..')]);
SetLength(Str, 0);
end;

function Proccess(const FileName : TSString) : TSGRCResult;
var
	Expansion : TSString;
	Stream : TMemoryStream = nil;
begin
Result := SBad;
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
	Result := SUnknown
else if Expansion = ' ' then
	Result := SBad
else
	Result := SSuccess;
end;

procedure MainLoop();
var
	Files : TSStringList = nil;
	FileName : TSString;
var
	CountBad : TSUInt32 = 0;
	CountUnknown : TSUInt32 = 0;
	CountComplited : TSUInt32 = 0;
	FileResult : TSGRCResult;
begin
Files := SDirectoryFiles(CacheDirectory + DirectorySeparator, Mask);
for FileName in Files do
	if not ('.' in FileName) then
		case Proccess(FileName) of
		SUnknown : CountUnknown += 1;
		SBad     : CountBad += 1;
		SSuccess : CountComplited += 1;
		end;
SHint(['Some statistic info:']);
SHint(['  ', CountComplited, ' complited files.']);
SHint(['  ', CountUnknown, ' unknown files.']);
SHint(['  ', CountBad, ' bad files.']);
if OpenResultDir and (CountComplited <> 0) then
	OpenResultDirectoy();
SetLength(Files, 0);
end;

function ReadParams() : TSBool;

function SelectCacheDirSimject(const Param : TSString) : TSBool;
begin
Result := False;
{$IFDEF MSWINDOWS}
	CacheDirectory := TSCompatibleContext.UserProfilePath() + DirectorySeparator + 'AppData' + DirectorySeparator + 'Local' + DirectorySeparator + 'Slimjet' + DirectorySeparator + 'User Data' + DirectorySeparator + 'Default' + DirectorySeparator + 'Cache';
	Result := True;
{$ELSE MSWINDOWS}
	(** TODO **)
{$ENDIF MSWINDOWS}
if Result then
	SHint('GRC: Set cache directory to "' + CacheDirectory + '".');
end;

function EnableTempDirectory(const Param : TSString) : TSBool;
begin
Result := True;
TempDirectoryEnabled := True;
SHint('GRC: Enabled temp directory.');
end;

function EnableWriteUnknows(const Param : TSString) : TSBool;
begin
Result := True;
WriteUnknows := True;
SHint('GRC: Enabled writing unknows.');
end;

function SetMask(const Param : TSString) : TSBool;
var
	Value : TSString;
begin
Result := False;
Value := SParseValueFromComand(Param, ['mask:']);
Result :=  Value <> '';
if Result then
	begin
	Mask := Value;
	SHint('GRC: Set mask cached files to "' + Mask + '".');
	end;
end;

function SelectCacheDir(const Param : TSString) : TSBool;
var
	Value : TSString;
begin
Result := False;
Value := SParseValueFromComand(Param, ['cd:','cache:']);
Result := Value <> '';
if Result then
	begin
	CacheDirectory := Value;
	SHint(['GRC: Set cache directory to "', CacheDirectory, '".']);
	end;
end;

function SelectTempDir(const Param : TSString) : TSBool;
var
	Value : TSString;
begin
Result := False;
Value := SParseValueFromComand(Param, ['td:','temp:']);
Result := Value <> '';
if Result then
	begin
	TempDirectory := Value;
	TempDirectoryEnabled := True;
	SHint('GRC: Temp directory enabled and set to "' + TempDirectory + '".');
	end;
end;

function SelectResultDir(const Param : TSString) : TSBool;
var
	Value : TSString;
begin
Result := False;
Value := SParseValueFromComand(Param, ['rd:','result:']);
Result := Value <> '';
if Result then
	begin
	ComplitedDirectory := Value;
	SHint(['GRC: Set result directory to "', ComplitedDirectory, '".']);
	end;
end;

begin
Result := True;
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSConsoleCaller.Create(VParams) do
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
SPrintEngineVersion();
if not ReadParams() then
	Exit;
if not SExistsDirectory(CacheDirectory) then
	begin
	SHint(['GRC: Cashe Directory does not exists: "',CacheDirectory,'"!']);
	Exit;
	end;
if TempDirectoryEnabled then
	SMakeDirectory(TempDirectory);
SMakeDirectory(ComplitedDirectory);
MainLoop();
end;

end.
