{$INCLUDE SaGe.inc}

unit SaGeLog;

interface

uses
	 SaGeBase
	,SaGeCasesOfPrint
	,SaGeFileUtils
	,SaGeClasses
	,SaGeLists
	
	,Classes
	;
type
	TSGLog = class(TSGNamed)
			public
		class procedure Source(const S : TSGString; const WithTime : TSGBoolean = True; const WithEoln : TSGBoolean = True); overload;
		class procedure Source(const Stream : TStream; const WithTime : TSGBoolean = False); overload;
		class procedure Source(const Ar : array of const; const WithTime : TSGBoolean = True); overload;
		class procedure Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150); overload;
		class procedure Source(const ArS : TSGStringList; const Title : TSGString; const ViewTime : TSGBoolean = True; const SimbolsLength : TSGUInt16 = 150); overload;
		end;
	SGLog = TSGLog;

procedure SGHint(const MessageStr : TSGString; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGHint(const MessagePtrs : array of const; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
procedure SGLogParams(Params : TSGStringList; const FreeMemList : TSGBoolean = True);
function SGLogDateTimeString(const WithArrow : TSGBoolean = True; const ForFileSystem : TSGBoolean = False) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGLogDirectory() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGAddToLog(const FileName, Line : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeDateTime
	,SaGeStringUtils
	,SaGeStreamUtils
	,SaGeBaseUtils
	,SaGeConsoleUtils
	,SaGeEncodingUtils
	,SaGeConsoleToolsBase
	,SaGeLogStream
	
	,StrMan
	;

function SGLogDirectory() : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SaGeLogStream.SGLogDirectory();
end;

function SGLogDateTimeString(const WithArrow : TSGBoolean = True; const ForFileSystem : TSGBoolean = False) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGDateTimeString(ForFileSystem) + Iff(WithArrow, ' -->');
end;

procedure SGAddToLog(const FileName, Line : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ss : TSGString;
	pc :PSGChar;
	FFileStream : TMemoryStream;
begin
FFileStream := TMemoryStream.Create();
if SGFileExists(FileName) then
	begin
	FFileStream.LoadFromFile(FileName);
	FFileStream.Position := FFileStream.Size;
	end;
ss := SGLogDateTimeString() + Line;
pc := SGStringToPChar(ss + SGWinEoln);
FFileStream.WriteBuffer(pc^, Length(ss) + 2);
FreeMem(pc, Length(ss) + 3);
FFileStream.Position := 0;
FFileStream.SaveToFile(FileName);
FFileStream.Destroy();
end;

procedure SGHint(const MessagePtrs : array of const; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
SGHint(SGStr(MessagePtrs), CasesOfPrint, ViewTime);
end;

procedure SGHint(const MessageStr : TSGString; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog];const ViewTime : TSGBoolean = False);{$IFDEF SUPPORTINLINE} inline; {$ENDIF}overload;
begin
if SGCaseLog in CasesOfPrint then
	SGLog.Source(MessageStr, ViewTime);
if SGCasePrint in CasesOfPrint then
	WriteLn(SGConvertStringToConsoleEncoding(MessageStr));
end;

class procedure TSGLog.Source(const Ar : array of const; const WithTime : TSGBoolean = True);
begin
if SGLogEnable then
	Source(SGStr(Ar), WithTime);
end;

class procedure TSGLog.Source(const ArS : TSGStringList; const Title : TSGString; const ViewTime : TSGBoolean = True; const SimbolsLength : TSGUInt16 = 150);overload;
var
	i, WordCount, MaxLength, n, ii, TitleLength : TSGMaxEnum;
	TempS : TSGString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	if (WordCount = 1) and ((Length(Title + ' ->') + 1 + Length(SGStringFromStringList(ArS, ' '))) < (SimbolsLength - 30)) then
		Source(Title + ' -> ' + SGStringFromStringList(ArS, ' '), ViewTime)
	else if (Length(Title + ' (' + SGStr(WordCount) + ') ->') + 1 + Length(SGStringFromStringList(ArS, ' '))) < (SimbolsLength - 30) then
		Source(Title + ' (' + SGStr(WordCount) + ') -> ' + SGStringFromStringList(ArS, ' '), ViewTime)
	else
		begin
		Source(Title + ' (' + SGStr(WordCount) + ') --->', ViewTime);
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

class procedure TSGLog.Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
var
	ArS : TSGStringList = nil;
begin
ArS := SGStringListFromString(S, Separators);
Source(ArS, Title, True, SimbolsLength);
SetLength(ArS, 0);
end;

class procedure TSGLog.Source(const Stream : TStream; const WithTime : TSGBoolean = False);overload;
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	Source(SGReadLnStringFromStream(Stream), WithTime);
	end;
Stream.Position := 0;
end;

class procedure TSGLog.Source(const S : TSGString; const WithTime : TSGBoolean = True; const WithEoln : TSGBoolean = True);overload;
begin
SGLogWrite(
	Iff(WithTime, SGLogDateTimeString()) + 
	SGStringDeleteEndOfLineDublicates(
		SGConvertString(S, SGEncodingWindows1251) + 
		Iff(WithEoln, SGWinEoln)))
end;

procedure SGLogParams(Params : TSGStringList; const FreeMemList : TSGBoolean = True);
var
	Str : TSGString = '';
begin
Str := SGStringFromStringList(Params, ' ');
if StringTrimAll(Str, ' ') <> '' then
	if Length(Str) < 106 then
		TSGLog.Source('Executable params: ' + Str)
	else if Length(Str) < 150 then
		begin
		TSGLog.Source('Executable params --> (' + SGStr(Length(Params)) + ')');
		TSGLog.Source('  ' + Str);
		end
	else
		TSGLog.Source(Params, 'Executable params');
if FreeMemList then
	SetLength(Params, 0);
end;

initialization
begin
if SGLogEnable then
	begin
	SGLog.Source('*************************************************', False);
	SGLog.Source('* (v)_(O_o)_(V)  SaGe Engine Log  (V)_(o_O)_(v) *', False);
	SGLog.Source('*************************************************', False);
	SGLog.Source('		<< Log created >>');
	SGLogParams(SGSystemParamsToConcoleCallerParams());
	end;
end;

finalization
begin
if SGLogEnable then
	SGLog.Source('		<< Log destroyed >>');
end;

end.
