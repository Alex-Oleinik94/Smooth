{$INCLUDE SaGe.inc}

unit SaGeLog;

interface

uses
	 Classes
	,SysUtils
	
	,SaGeBase
	,SaGeBased
	;
var
	//Если эту переменную задать как False, то SGLog.Source нечего делать не будет,
	//и самого файлика лога SGLog.Create не создаст
	SGLogEnable : TSGBoolean = {$IFDEF RELEASE}False{$ELSE}True{$ENDIF};
const
	SGLogDirectory = {$IFDEF ANDROID}'/sdcard/.SaGe'{$ELSE}SGDataDirectory{$ENDIF};
type
	TSGLog = class(TObject)
			public
		constructor Create();
		destructor Destroy();override;
		procedure Source(const s:string;const WithTime:Boolean = True);overload;
		procedure Source(const Ar : array of const;const WithTime:Boolean = True);overload;
		procedure Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
		procedure Source(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
			private
		FFileStream : TFileStream;
		end;
var
	//Экземпляр класса лога программы
	SGLog : TSGLog = nil;

implementation

uses
	 SaGeDateTime
	,SaGeStringUtils
	
	,StrMan
	;

procedure TSGLog.Source(const Ar : array of const; const WithTime:Boolean = True);
var
	OutString:String = '';
begin
 if SGLogEnable then
	begin
	OutString:=SGGetStringFromConstArray(Ar);
	Source(OutString,WithTime);
	SetLength(OutString,0);
	end;
end;

procedure TSGLog.Source(const ArS : TSGStringList; const Title : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
var
	i, WordCount, MaxLength, n, ii: TSGLongWord;
	TempS : TSGString;
begin
WordCount := 0;
if ArS <> nil then
	WordCount := Length(ArS);
if WordCount > 0 then
	begin
	Source(Title + ' (' + SGStr(WordCount) + ')',True);
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

procedure TSGLog.Source(const S : TSGString; const Title : TSGString; const Separators : TSGString; const SimbolsLength : TSGUInt16 = 150);overload;
var
	ArS : TSGStringList = nil;
begin
ArS := SGStringListFromString(S, Separators);
Source(ArS, Title, SimbolsLength);
SetLength(ArS, 0);
end;

procedure TSGLog.Source(const s:string;const WithTime:Boolean = True);
var
	ss:string;
	a:TSGDateTime;
	pc:PChar;
begin
if SGLogEnable then
	if not WithTime then
		begin
		pc:=SGStringToPChar(s+SGWinEoln);
		FFileStream.WriteBuffer(pc^,Length(s)+2);
		FreeMem(pc,Length(s)+3);
		end
	else
		begin
		a.Get;
		with a do
			ss:='['+SGStr(Day)+'.'+SGStr(Month)+'.'+SGStr(Years)+'/'+SGStr(Week)+']'+
				'['+SGStr(Hours)+':'+SGStr(Minutes)+':'+SGStr(Seconds)+'/'+SGStr(Sec100)+'] -->'+s;
		pc:=SGStringToPChar(ss+SGWinEoln);
		FFileStream.WriteBuffer(pc^,Length(ss)+2);
		FreeMem(pc,Length(ss)+3);
		end;
end;

constructor TSGLog.Create();
begin
inherited;
if SGLogEnable then
	FFileStream:=TFileStream.Create(SGLogDirectory+Slash+'EngineLog.log',fmCreate);
end;

destructor TSGLog.Destroy;
begin
if SGLogEnable then
	FFileStream.Destroy;
inherited;
end;

initialization
begin
{$IFDEF ANDROID}
	SGMakeDirectory(SGLogDirectory);
	{$ENDIF}
try
	SGLog := TSGLog.Create();
	SGLog.Source('(***) SaGe Engine Log (***)', False);
	SGLog.Source('  << Create Log >>');
except
	SGLogEnable := False;
	SGLog := TSGLog.Create();
end;
end;

finalization
begin
SGLog.Source('  << Destroy Log >>');
SGLog.Destroy();
SGLog := nil;
end;

end.
