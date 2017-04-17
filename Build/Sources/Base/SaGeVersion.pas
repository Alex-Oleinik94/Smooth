{$INCLUDE SaGe.inc}

unit SaGeVersion;

interface

uses
	 SaGeBase
	,SaGeResourceManager
	,SaGeDateTime
	,SaGeStringUtils
	,SaGeFileUtils
	
	,Classes
	;

const
	VersionFileName = SGEngineDirectory + DirectorySeparator + 'version.txt';

function SGEngineVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGEngineFullVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPrintEngineVersion();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGIncEngineVersion(const IsRelease : TSGBoolean = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

const
	SGVerUnknown = 'unknown';

const
	SGVerCPU =
		{$IF defined(CPU64)}
			'64'
		{$ELSE}
			{$IFDEF CPU32}
				'32'
			{$ELSE}
				{$IFDEF CPU16}
					'16'
				{$ELSE}
					SGVerUnknown
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
		;
const
	SGVerOS =
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
								SGVerUnknown
							{$ENDIF}
						{$ENDIF}
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
		;

function SGEngineTarget(const C : TSGChar = ' ') : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGEngineTargetVersion(const C : TSGChar = ' ') : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeLog
	,SaGeBaseUtils
	,SaGeSysUtils
	;

function SGEngineTargetVersion(const C : TSGChar = ' ') : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGEngineTarget(C) + ' bit';
end;

function SGEngineTarget(const C : TSGChar = ' ') : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGVerOS + C + SGVerCPU;
end;

function SGEngineFullVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 'SaGe Engine version '+SGEngineVersion()+' (' + SGEngineTargetVersion(' ') + ')';
end;

function SGEngineVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream: TMemoryStream;
	S : TSGString;
begin
Result := '';
if (SGResourceFiles <> nil) and SGResourceFiles.FileExists(VersionFileName) then
	begin
	Stream := TMemoryStream.Create();
	SGResourceFiles.LoadMemoryStreamFromFile(Stream, VersionFileName);
	Stream.Position := 0;
	Result += SGReadLnStringFromStream(Stream);
	Result += '.';
	Result += SGReadLnStringFromStream(Stream);
	Result += '.';
	Result += SGReadLnStringFromStream(Stream);
	Result += '.';
	Result += SGReadLnStringFromStream(Stream);
	S := SGReadLnStringFromStream(Stream);
	if S <> '' then
		Result += ' (' + S + ')';
	S := SGReadLnStringFromStream(Stream);
	if S <> '' then
		Result += ' [' + S + ']';
	Stream.Destroy();
	end
else
	Result += 'unknown';
end;

var
	VersionPrinted : TSGBoolean = False;

procedure SGPrintEngineVersion();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if not VersionPrinted then
	begin
	SGHint(SGEngineFullVersion(), SGViewTypeFull, True);
	//WriteLn('Copyright (c) 2012-2016 by Alex');
	SGLog.Source('Operating system: ' + SGOperatingSystemVersion());
	end;
VersionPrinted := True;
end;

procedure SGIncEngineVersion(const IsRelease : TSGBoolean = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TMemoryStream;
	s1,s2,s3 : TSGString;
	n : TSGLongWord;
	d : TSGDateTime;
begin
Stream := TMemoryStream.Create();
Stream.LoadFromFile(VersionFileName);
Stream.Position := 0;
s1 := SGReadLnStringFromStream(Stream);
s2 := SGReadLnStringFromStream(Stream);
s3 := SGReadLnStringFromStream(Stream);
n := SGVal(SGReadLnStringFromStream(Stream));
Stream.Destroy();
Stream := TMemoryStream.Create();
SGWriteStringToStream(s1 + SGWinEoln, Stream, False);
SGWriteStringToStream(s2 + SGWinEoln, Stream, False);
SGWriteStringToStream(s3 + SGWinEoln, Stream, False);
SGWriteStringToStream(SGStr(n + 1 + Byte(IsRelease)) + SGWinEoln, Stream, False);
SGWriteStringToStream(Iff(IsRelease,'Release','Debug') + SGWinEoln, Stream, False);
d.Get();
SGWriteStringToStream(SGStr(d.Years) + '/' + SGStr(d.Month) + '/' + SGStr(d.Day) + SGWinEoln, Stream, False);
Stream.Position := 0;
Stream.SaveToFile(VersionFileName);
Stream.Destroy();
end;

{$IF defined(LIBRARY)}
exports
	SGEngineVersion
	;
{$ENDIF}

initialization
begin

end;

end.