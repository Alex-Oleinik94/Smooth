{$INCLUDE Includes\SaGe.inc}

unit SaGeVersion;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeResourseManager
	,Classes
	;

const
	VersionFileName = SGEngineDirectory + Slash + 'version.txt';

function SGGetEngineVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetEngineFullVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

implementation

function SGGetEngineFullVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 'SaGe Engine version '+SGGetEngineVersion()+' ('+SGVerOS+' '+SGVerCPU+' bit)';
end;

function SGGetEngineVersion() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var 
	Stream: TMemoryStream;
	S : TSGString;
begin
Result := '';
if SGResourseFiles.FileExists(VersionFileName) then
	begin
	Stream := TMemoryStream.Create();
	SGResourseFiles.LoadMemoryStreamFromFile(Stream, VersionFileName);
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
	WriteLn(SGGetEngineFullVersion());
	//WriteLn('Copyright (c) 2012-2016 by Alex');
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
	SGGetEngineVersion
	;
{$ENDIF}

initialization
begin
SGLog.Sourse(SGGetEngineFullVersion());
end;

end.
