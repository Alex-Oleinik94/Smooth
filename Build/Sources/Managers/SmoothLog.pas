{$INCLUDE Smooth.inc}

unit SmoothLog;

interface

uses
	 SmoothBase
	,SmoothCasesOfPrint
	,SmoothFileUtils
	,SmoothBaseClasses
	,SmoothLists
	
	,Classes
	;
type
	TSLog = class(TSNamed)
			public
		class procedure Source(const S : TSString; const WithTime : TSBoolean = True; const WithEoln : TSBoolean = True); overload;
		class procedure Source(const Stream : TStream; const WithTime : TSBoolean = False); overload;
		class procedure Source(const Ar : array of const; const WithTime : TSBoolean = True); overload;
		class procedure Source(const S : TSString; const Title : TSString; const Separators : TSString; const SimbolsLength : TSUInt16 = 150); overload;
		class procedure Source(const ArS : TSStringList; const Title : TSString; const ViewTime : TSBoolean = True; const SimbolsLength : TSUInt16 = 150); overload;
		end;
	SLog = TSLog;

procedure SHint(const MesSmoothStr : TSString; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog];const ViewTime : TSBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SHint(const MesSmoothPtrs : array of const; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog];const ViewTime : TSBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SLogParams(Params : TSStringList; const FreeMemList : TSBoolean = True);
function SLogDateTimeString(const WithArrow : TSBoolean = True; const ForFileSystem : TSBoolean = False) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SLogDirectory() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SLogMakeSignificant();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SAddToLog(const FileName, Line : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothDateTime
	,SmoothStringUtils
	,SmoothStreamUtils
	,SmoothBaseUtils
	,SmoothConsoleUtils
	,SmoothEncodingUtils
	,SmoothConsoleHandler
	,SmoothLogStream
	
	,StrMan
	;

procedure SLogMakeSignificant();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
LogSignificant := True;
end;

function SLogDirectory() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SmoothLogStream.SLogDirectory();
end;

function SLogDateTimeString(const WithArrow : TSBoolean = True; const ForFileSystem : TSBoolean = False) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SDateTimeString(ForFileSystem) + Iff(WithArrow, ' -->');
end;

procedure SAddToLog(const FileName, Line : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ss : TSString;
	pc :PSChar;
	FFileStream : TMemoryStream;
begin
FFileStream := TMemoryStream.Create();
if SFileExists(FileName) then
	begin
	FFileStream.LoadFromFile(FileName);
	FFileStream.Position := FFileStream.Size;
	end;
ss := SLogDateTimeString() + Line;
pc := SStringToPChar(ss + DefaultEndOfLine);
FFileStream.WriteBuffer(pc^, Length(ss) + 2);
FreeMem(pc, Length(ss) + 3);
FFileStream.Position := 0;
FFileStream.SaveToFile(FileName);
FFileStream.Destroy();
end;

procedure SHint(const MesSmoothPtrs : array of const; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog];const ViewTime : TSBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
SHint(SStr(MesSmoothPtrs), CasesOfPrint, ViewTime);
end;

procedure SHint(const MesSmoothStr : TSString; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog];const ViewTime : TSBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
if SCaseLog in CasesOfPrint then
	SLog.Source(MesSmoothStr, ViewTime);
if SCasePrint in CasesOfPrint then
	WriteLn(SConvertStringToConsoleEncoding(MesSmoothStr));
end;

class procedure TSLog.Source(const Ar : array of const; const WithTime : TSBoolean = True);
begin
if LogEnablement <> SLogDisabled then
	Source(SStr(Ar), WithTime);
end;

class procedure TSLog.Source(const ArS : TSStringList; const Title : TSString; const ViewTime : TSBoolean = True; const SimbolsLength : TSUInt16 = 150);overload;
var
	i, WordCount, MaxLength, n, ii, TitleLength : TSMaxEnum;
	TempS : TSString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	if (WordCount = 1) and ((Length(Title + ' ->') + 1 + Length(SStringFromStringList(ArS, ' '))) < (SimbolsLength - 30)) then
		Source(Title + ' -> ' + SStringFromStringList(ArS, ' '), ViewTime)
	else if (Length(Title + ' (' + SStr(WordCount) + ') ->') + 1 + Length(SStringFromStringList(ArS, ' '))) < (SimbolsLength - 30) then
		Source(Title + ' (' + SStr(WordCount) + ') -> ' + SStringFromStringList(ArS, ' '), ViewTime)
	else
		begin
		Source(Title + ' (' + SStr(WordCount) + ') --->', ViewTime);
		MaxLength := Length(ArS[0]);
		if Length(ArS) > 1 then
			begin
			for i := 1 to High(ArS) do
				if Length(ArS[i]) > MaxLength then
					MaxLength := Length(ArS[i]);
			end;
		MaxLength += 2;
		n := 150 div MaxLength;
		MaxLength += (150 mod MaxLength) div n;
		ii := 0;
		TempS := '  ';
		for i := 0 to High(ArS) do
			begin
			if (ii = n - 1) or (i = High(ArS)) then
				TempS += ArS[i]
			else
				TempS += StringJustifyLeft(ArS[i], MaxLength, ' ');
			ii +=1;
			if ii = n then
				begin
				ii := 0;
				Source(TempS, False);
				TempS := '  ';
				end;
			end;
		if TempS <> '  ' then
			Source(TempS, False);
		end;
	end;
end;

class procedure TSLog.Source(const S : TSString; const Title : TSString; const Separators : TSString; const SimbolsLength : TSUInt16 = 150);overload;
var
	ArS : TSStringList = nil;
begin
ArS := SStringListFromString(S, Separators);
Source(ArS, Title, True, SimbolsLength);
SetLength(ArS, 0);
end;

class procedure TSLog.Source(const Stream : TStream; const WithTime : TSBoolean = False);overload;
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	Source(SReadLnStringFromStream(Stream), WithTime);
	end;
Stream.Position := 0;
end;

class procedure TSLog.Source(const S : TSString; const WithTime : TSBoolean = True; const WithEoln : TSBoolean = True);overload;
begin
SLogWrite(
	Iff(WithTime, SLogDateTimeString()) + 
	SStringDeleteEndOfLineDublicates(
		SConvertString(S, SEncodingWindows1251) + 
		Iff(WithEoln, DefaultEndOfLine)))
end;

procedure SLogParams(Params : TSStringList; const FreeMemList : TSBoolean = True);
var
	Str : TSString = '';
begin
Str := SStringFromStringList(Params, ' ');
if StringTrimAll(Str, ' ') <> '' then
	if Length(Str) < 106 then
		TSLog.Source('Executable params: ' + Str)
	else if Length(Str) < 150 then
		begin
		TSLog.Source('Executable params --> (' + SStr(Length(Params)) + ')');
		TSLog.Source('  ' + Str);
		end
	else
		TSLog.Source(Params, 'Executable params');
if FreeMemList then
	SetLength(Params, 0);
end;

initialization
begin
if LogEnablement <> SLogDisabled then
	begin
	SLog.Source('********************************************', False);
	SLog.Source('* (v)_(O_o)_(V)  Smooth log  (V)_(o_O)_(v) *', False);
	SLog.Source('********************************************', False);
	SLog.Source('		<< Log created >>');
	SLogParams(SSystemParamsToConsoleHandlerParams());
	end;
end;

finalization
begin
if LogEnablement <> SLogDisabled then
	SLog.Source('		<< Log destroyed >>');
end;

end.
