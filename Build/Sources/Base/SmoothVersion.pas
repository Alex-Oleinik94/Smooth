{$INCLUDE Smooth.inc}

unit SmoothVersion;

interface

uses
	 SmoothBase
	,SmoothResourceManager
	,SmoothDateTime
	,SmoothFileUtils
	
	,Classes
	;

const
	VersionFileName = SEngineDirectory + DirectorySeparator + 'version.txt';

function SEngineVersion() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SEngineFullVersion() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SPrintEngineVersion();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SIncEngineVersion(const IsRelease : TSBoolean = False) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

var
	SApplicationName : TSString = 'Smooth';
const
	SVerUnknown = 'unknown';

const
	SVerCPU =
		{$IF defined(CPU64)}
			'64'
		{$ELSE}
			{$IFDEF CPU32}
				'32'
			{$ELSE}
				{$IFDEF CPU16}
					'16'
				{$ELSE}
					SVerUnknown
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
		;
const
	SVerOS =
		{$IFDEF MSWINDOWS}
			'Windows'
		{$ELSE}
			{$IF defined(ANDROID) or (defined(UNIX) and defined(MOBILE))}
				'Android'
			{$ELSE}
				{$IF defined(DARWIN) and (not defined(MOBILE))}
					'Mac OS X'
				{$ELSE}
					{$IF defined(MOBILE) and defined(DARWIN)}
						'iOS'
					{$ELSE}
						{$IFDEF LINUX}
							'Linux'
						{$ELSE}
							{$IFDEF UNIX}
								'Unix'
							{$ELSE}
								SVerUnknown
							{$ENDIF}
						{$ENDIF}
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
		;

function SEngineTarget(const C : TSChar = ' ') : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SEngineTargetVersion(const C : TSChar = ' ') : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SPushVersionToWindowsResourseFile(const FileName : TSString; const Define : TSString; const WithQuotes : TSBoolean = True);

implementation

uses
	 SmoothLog
	,SmoothStreamUtils
	,SmoothStringUtils
	,SmoothBaseUtils
	,SmoothSysUtils
	,SmoothCasesOfPrint
	
	,Crt
	;

procedure SPushVersionToWindowsResourseFile(const FileName : TSString; const Define : TSString; const WithQuotes : TSBoolean = True);

function IsStringFounded(const Str : TSString) : TSBoolean;
begin

end;

var
	InputStream : TMemoryStream;
	OutputStream : TMemoryStream;

procedure Loop();
var
	Str : TSString;
begin
Str := '';
repeat
Str := SReadLnStringFromStream(InputStream);
until IsStringFounded(Str);
end;

begin
OutputStream := TMemoryStream.Create();
InputStream := TMemoryStream.Create();
InputStream.LoadFromFile(FileName);
Loop();
InputStream.Destroy();
InputStream := nil;
OutputStream.SaveToFile(FileName);
OutputStream.Destroy();
OutputStream := nil;
end;

function SEngineTargetVersion(const C : TSChar = ' ') : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SEngineTarget(C) + C + 'bit';
end;

function SEngineTarget(const C : TSChar = ' ') : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SVerOS + C + SVerCPU;
end;

function SEngineFullVersion() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 'Smooth Engine version '+SEngineVersion()+' (' + SEngineTargetVersion(' ') + ')';
end;

function SEngineVersion() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream: TMemoryStream;
	S : TSString;
begin
Result := '';
if (SResourceFiles <> nil) and SResourceFiles.FileExists(VersionFileName) then
	begin
	Stream := TMemoryStream.Create();
	SResourceFiles.LoadMemoryStreamFromFile(Stream, VersionFileName);
	Stream.Position := 0;
	Result += SReadLnStringFromStream(Stream);
	Result += '.';
	Result += SReadLnStringFromStream(Stream);
	Result += '.';
	Result += SReadLnStringFromStream(Stream);
	Result += '.';
	Result += SReadLnStringFromStream(Stream);
	S := SReadLnStringFromStream(Stream);
	if S <> '' then
		Result += ' (' + S + ')';
	S := SReadLnStringFromStream(Stream);
	if S <> '' then
		Result += ' [' + S + ']';
	Stream.Destroy();
	end
else
	Result += 'unknown';
end;

var
	VersionPrinted : TSBoolean = False;

procedure SPrintEngineVersion();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if not VersionPrinted then
	begin
	TextColor(7);
	SHint(SEngineFullVersion(), SCasesOfPrintFull, True);
	//WriteLn('Copyright (c) 2012-2016 by Alex');
	SLog.Source('Operating system: ' + SOperatingSystemVersion());
	end;
VersionPrinted := True;
end;

function SIncEngineVersion(const IsRelease : TSBoolean = False) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TMemoryStream;
	s1, s2, s3, s4 : TSString;
	n : TSLongWord;
	d : TSDateTime;
begin
Stream := TMemoryStream.Create();
Stream.LoadFromFile(VersionFileName);
Stream.Position := 0;
s1 := SReadLnStringFromStream(Stream);
s2 := SReadLnStringFromStream(Stream);
s3 := SReadLnStringFromStream(Stream);
n := SVal(SReadLnStringFromStream(Stream));
Stream.Destroy();
s4 := SStr(n + 1 + Byte(IsRelease));
Stream := TMemoryStream.Create();
SWriteStringToStream(s1 + DefaultEndOfLine, Stream, False);
SWriteStringToStream(s2 + DefaultEndOfLine, Stream, False);
SWriteStringToStream(s3 + DefaultEndOfLine, Stream, False);
SWriteStringToStream(s4 + DefaultEndOfLine, Stream, False);
SWriteStringToStream(Iff(IsRelease, 'Release', 'Debug') + DefaultEndOfLine, Stream, False);
d.Get();
SWriteStringToStream(SStr(d.Years) + '/' + SStr(d.Month) + '/' + SStr(d.Day) + DefaultEndOfLine, Stream, False);
Stream.Position := 0;
Stream.SaveToFile(VersionFileName);
Stream.Destroy();
Result := 
	s1 + '.' + s2 + '.' + s3 + '.' + s4 + ' ' +
	Iff(IsRelease, 'Release', 'Debug') + ' ' +
	'[' + SStr(d.Years) + '/' + SStr(d.Month) + '/' + SStr(d.Day) + ']';
end;

{$IF defined(LIBRARY)}
exports
	SEngineVersion
	;
{$ENDIF}

initialization
begin

end;

end.
