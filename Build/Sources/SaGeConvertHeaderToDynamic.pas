{$INCLUDE SaGe.inc}

unit SaGeConvertHeaderToDynamic;

interface

uses
	 SaGeBased
	,Classes
	;

type
	TSGDoDynamicHeader = class
			public
		constructor Create(const VFileName, VOutFileName : TSGString; const VMode : TSGString = 'OBJFPC');virtual;
		destructor Destroy();override;
		procedure PrintErrors();virtual;
		procedure Execute();virtual;
			private
		FInFileName, FOutFileName : TSGString;
		FInStream, FOutStream : TMemoryStream;
		FMode : TSGString;
			protected
		function GetNextIdentivier(const NeedsToWrite : TSGBool = True) : TSGString;
		function SeeNextIdentifier() : TSGString;
		end;

procedure SGConvertHeaderToDynamic(const VInFile, VOutFile : TSGString; const VMode : TSGString = 'OBJFPC');

implementation

uses
	SaGeResourseManager
	,SaGeBase
	,SaGeVersion
	,StrMan
	;

procedure SGConvertHeaderToDynamic(const VInFile, VOutFile : TSGString; const VMode : TSGString = 'OBJFPC');
var
	V : TSGDoDynamicHeader = nil;
begin
V := TSGDoDynamicHeader.Create(VInFile, VOutFile, VMode);
V.Execute();
V.PrintErrors();
V.Destroy();
V := nil;
end;

constructor TSGDoDynamicHeader.Create(const VFileName, VOutFileName : TSGString; const VMode : TSGString = 'OBJFPC');
begin
FMode := SGUpCaseString(VMode);
FInFileName := VFileName;
FOutFileName := VOutFileName;
FOutStream := TMemoryStream.Create();
FInStream := TMemoryStream.Create();
SGResourseFiles.LoadMemoryStreamFromFile(FInStream, FInFileName);
FInStream.Position := 0;
end;

destructor TSGDoDynamicHeader.Destroy();
begin
FOutStream.Position := 0;
WriteLn('ConvertHeaderToDynamic : Out file size = ',FOutStream.Size,'.');
FOutStream.SaveToFile(FOutFileName);
FOutStream.Destroy();
FInStream.Destroy();
inherited;
end;

procedure TSGDoDynamicHeader.PrintErrors();
begin

end;

function TSGDoDynamicHeader.SeeNextIdentifier() : TSGString;
var
	InPos : TSGUInt64;
begin
InPos := FInStream.Position;
Result := '';
while (Result <> '') and (FInStream.Position <> FInStream.Size) do
	Result := GetNextIdentivier(False);
FInStream.Position := InPos;
end;

function TSGDoDynamicHeader.GetNextIdentivier(const NeedsToWrite : TSGBool = True) : TSGString;

function GoodChar(const C : TSGChar):TSGBool;
begin
Result := C in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_&0123456789.';
end;

function SpaceChar(const C : TSGChar):TSGBoolean;
begin
Result := C in ' 	';
end;

function BadChar(const C : TSGChar):TSGBoolean;
begin
Result := C in '()[]:;@^,*<>/=+''{}$-#';
end;

function EoChar(const C : TSGChar):TSGBool;
begin
Result := C in #10#13#0;
end;

function BadString(const S : TSGString):TSGBoolean;
var
	ArrBadStr : array [0..10] of TSGString =
		(':=','<>','>=','<=','!=','**','+=','/=','*=','-=','..');
	Index : TSGUInt8 = 0;
begin
Result := False;
for Index := Low(ArrBadStr) to High(ArrBadStr) do
	if S = ArrBadStr[Index] then
		begin
		Result := True;
		break;
		end;
end;

function NextChar() : TSGChar;
begin
FInStream.ReadBuffer(Result, 1);
FInStream.Position := FInStream.Position - 1;
end;

procedure DecPos(const DecCount : TSGUInt8 = 1);
begin
FInStream.Position := FInStream.Position - DecCount;
end;

function  RWChar() : TSGChar;
begin
FInStream.ReadBuffer(Result, 1);
if NeedsToWrite then
	FOutStream.WriteBuffer(Result, 1);
end;

procedure Comments();
var
	ComFirstType : TSGLongInt = 0;
	ComSecondType : TSGLongInt = 0;
	C : TSGChar;
begin
repeat
C := RWChar();
if C = '{' then
	ComFirstType += 1
else if C = '}' then
	ComFirstType -= 1
else if (C = '(') and (NextChar() = '*') then
	begin
	ComSecondType += 1;
	RWChar();
	end
else if (C = '*') and (NextChar() = ')') then
	begin
	ComSecondType -= 1;
	RWChar();
	end;
until (ComFirstType = 0) and (ComSecondType = 0);
end;

procedure OneLineComment();
begin
while not EoChar(RWChar()) do
	;
end;

var
	C : TSGChar;
	Succ : TSGBoolean = False;
begin
Result := '';
while (not Succ) and (FInStream.Position <> FInStream.Size) do
	begin
	FInStream.ReadBuffer(C, 1);
	if SpaceChar(C) and (Result <> '') then
		begin
		DecPos();
		Succ := True;
		end
	else if SpaceChar(C) and (Result = '') then
		begin
		if NeedsToWrite then
			FOutStream.WriteBuffer(C, 1);
		end
	else if (Result = '') and (C='/') and (FInStream.Position < FInStream.Size) and (NextChar() = '/') then
		begin
		DecPos();
		OneLineComment();
		Succ := True;
		end
	else if (Result = '') and (((C = '(') and (NextChar() = '*')) or (C in '{')) then
		begin
		DecPos();
		Comments();
		Succ := True;
		end
	else if (Result <> '') and (((C = '(') and (NextChar() = '*')) or (C in '{')) then
		begin
		DecPos();
		Succ := True;
		end
	else if EoChar(C) then
		begin
		if Result <> '' then
			begin
			DecPos();
			Succ := True;
			end
		else
			begin
			if NeedsToWrite then
				FOutStream.WriteBuffer(C, 1);
			end;
		end
	else if (FInStream.Position < FInStream.Size) and BadString(C + NextChar()) then
		begin
		if Result = '' then
			begin
			Result := C + ' ';
			FInStream.ReadBuffer(Result[2], 1);
			end
		else
			begin
			DecPos();
			end;
		Succ := True;
		end
	else if BadChar(C) then
		begin
		if Result = '' then
			begin
			Result := C;
			end
		else
			begin
			DecPos();
			end;
		Succ := True;
		end
	else if GoodChar(C) then
		begin
		Result += C;
		end
	else
		begin
		
		end;
	end;
end;

procedure TSGDoDynamicHeader.Execute();
var
	ExternalCount : TSGUInt32 = 0;

var
	ExternalProcedures : packed array of
		packed record
			FPascalName      : TSGString;
			FExternalName    : TSGString;
			FExternalLibrary : TSGString;
			end = nil;

procedure AddExternalProcedure(const PN, EN, EL : TSGString);
begin
if ExternalProcedures = nil then
	SetLength(ExternalProcedures, 1)
else
	SetLength(ExternalProcedures, Length(ExternalProcedures) + 1);
ExternalProcedures[High(ExternalProcedures)].FPascalName      := PN;
ExternalProcedures[High(ExternalProcedures)].FExternalName    := EN;
ExternalProcedures[High(ExternalProcedures)].FExternalLibrary := EL;
end;

procedure GetSizePos(var Size, Pos : TSGUInt32);
begin
Size := FOutStream.Size;
Pos  := FInStream.Position;
end;

procedure SetSizePos(const Size, Pos : TSGUInt32);
begin
FOutStream.Size := Size;
FOutStream.Position := Size;
FInStream.Position := Pos;
end;

function ReWriteExternal(const S : TSGString):TSGString;
var
	Str : TSGString;

function EoChar(const C : TSGChar):TSGBool;
begin
Result := C in #10#13#0;
end;

function GetProcName(): TSGString;
var
	i : TSGLongInt;
begin
i := StringPos('(', Str, 0);
Result := '';
while (Str[i] <> ' ') or (Result = '') do
	begin
	if not (Str[i] in '( 	') then
		Result += Str[i];
	i -= 1;
	end;
Result := StringReverse(Result);
end;

function GetProcExternalName(): TSGString;
var
	WordCount : TSGUInt32 = 0;
begin
WordCount := StringWordCount(Str, ' ');
if SGUpCaseString(StringWordGet(Str, ' ', WordCount - 4)) = 'NAME' then
	begin
	Result := '''' + StringWordGet(Str, ' ', WordCount - 2) + '''';
	end
else if SGUpCaseString(StringWordGet(Str, ' ', WordCount - 2)) = 'NAME' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 2);
	end
else
	Result := GetProcName();
end;

function GetProcLib(): TSGString;
var
	WordCount : TSGUInt32 = 0;
begin
WordCount := StringWordCount(Str, ' ');
if SGUpCaseString(StringWordGet(Str, ' ', WordCount - 2)) = 'EXTERNAL' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 1);
	end
else if SGUpCaseString(StringWordGet(Str, ' ', WordCount - 4)) = 'EXTERNAL' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 3);
	end
else if SGUpCaseString(StringWordGet(Str, ' ', WordCount - 6)) = 'EXTERNAL' then
	begin
	if StringWordGet(Str, ' ', WordCount - 5) = '''' then
		begin
		Result := StringWordGet(Str, ' ', WordCount - 4);
		end
	else
		begin
		Result := StringWordGet(Str, ' ', WordCount - 5);
		end;
	end
else if SGUpCaseString(StringWordGet(Str, ' ', WordCount - 8)) = 'EXTERNAL' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 6);
	end
else
	begin
	WriteLn('Can''t find external lib!');
	//WriteLn(Str);
	//FOutStream.SaveToFile(FOutFileName);
	Halt();
	end;
end;

function NextWord(StringIndex : TSGLongWord):TSGString;
begin
Result := '';
while (StringIndex <= Length(Str)) and (Str[StringIndex] <> ' ') do
	begin
	Result += Str[StringIndex];
	StringIndex += 1;
	end;
end;

function GetProcType(): TSGString;
var
	i : TSGLongWord;
begin
i := 1;
Result := '';
while Str[i] <> ' ' do
	begin
	Result += Str[i];
	i += 1;
	end;
i := StringPos('(', Str, 0);
while (SGUpCaseString(NextWord(i)) <> 'EXTERNAL') do
	begin
	if not ((i <= Length(Str))) then
		begin
		//WriteLn(Str);ReadLn();
		end;
	Result += Str[i];
	i += 1;
	end;
end;

var
	i : TSGUInt32 = 0;
begin
Str := '';
for i := 1 to Length(S) do
	begin
	if EoChar(S[i]) then
		begin
		end
	else if (S[i] = '	') or (S[i] = ' ') then
		begin
		if (Length(Str) > 0) then
			begin
			if Str[Length(Str)] <> ' ' then
				Str += ' ';
			end;
		end
	else
		Str += S[i];
	end;
AddExternalProcedure(GetProcName(), GetProcExternalName(), GetProcLib());
Result := 'var ' + GetProcName() + ' : ' + GetProcType();
Result += SGWinEoln;
end;

function ReadChar() : TSGChar;
begin
FInStream.ReadBuffer(Result, 1);
end;

function Process() : TSGUInt32;
var
	UnitName : TSGString = '';

procedure WriteReadWriteProcedures();
var
	i : TSGUInt32 = 0;
	Typization : packed array of
		packed array of
			packed record
				FPascalName      : TSGString;
				FExternalName    : TSGString;
				FExternalLibrary : TSGString;
				end = nil;

procedure ProcessTypization();

function IndexOfType(const S : TSGString):TSGLongInt;
var
	i : TSGLongWord;
begin
Result := -1;
if Typization = nil then
	begin
	SetLength(Typization, 1);
	Result := 0;
	end
else
	begin
	for i := 0 to High(Typization) do
		if Typization[i][0].FExternalLibrary = S then
			begin
			Result := i;
			break;
			end;
	if Result = -1 then
		begin
		SetLength(Typization, Length(Typization) + 1);
		Typization[High(Typization)] := nil;
		Result := High(Typization);
		end;
	end;
end;

var
	Index, i : TSGLongInt;
begin
for i := 0 to High(ExternalProcedures) do
	begin
	Index := IndexOfType(ExternalProcedures[i].FExternalLibrary);
	if Typization[Index] = nil then
		SetLength(Typization[Index], 1)
	else
		SetLength(Typization[Index], Length(Typization[Index]) + 1);
	Typization[Index][High(Typization[Index])].FExternalLibrary := ExternalProcedures[i].FExternalLibrary;
	Typization[Index][High(Typization[Index])].FPascalName      := ExternalProcedures[i].FPascalName;
	Typization[Index][High(Typization[Index])].FExternalName    := ExternalProcedures[i].FExternalName;
	end;
end;

function StringInQuotes(const S : TSGString):TSGString;
begin
if S[1] = '''' then
	Result := S
else
	Result := '''' + S + '''';
end;

var
	ii : TSGLongWord;
begin
//SGWriteStringToStream(SGWinEoln + '{$mode '+FMode+'}' + SGWinEoln, FOutStream, False);

SGWriteStringToStream(SGWinEoln + 'procedure Load_HINT(const Er : String);' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('begin' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('//WriteLn(Er);' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('SGLog.Sourse(Er);' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('end;' + SGWinEoln, FOutStream, False);

SGWriteStringToStream('procedure Free_'+UnitName+'();' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('begin' + SGWinEoln, FOutStream, False);
for i := 0 to High(ExternalProcedures) do
	SGWriteStringToStream(''+ExternalProcedures[i].FPascalName+' := nil;' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('end;' + SGWinEoln, FOutStream, False);

ProcessTypization();

for ii := 0 to High(Typization) do
	begin
	SGWriteStringToStream('function Load_'+UnitName+'_'+SGStr(ii)+'(const UnitName : PChar) : Boolean;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('const' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	TotalProcCount = '+SGStr(Length(Typization[ii]))+';' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('var' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	UnitLib : LongWord;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	CountLoadSuccs : LongWord;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('function LoadProcedure(const Name : PChar) : Pointer;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('begin' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('Result := GetProcAddress(UnitLib, Name);' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('if Result = nil then' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	Load_HINT(''Initialization '+SGUpCaseString(UnitName)+' unit from ''+SGPCharToString(UnitName)+'': Error while loading "''+SGPCharToString(Name)+''"!'')' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('else' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	CountLoadSuccs := CountLoadSuccs + 1;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('end;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('begin' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('UnitLib := LoadLibrary(UnitName);' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('Result := UnitLib <> 0;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('CountLoadSuccs := 0;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('if not Result then' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	begin' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	Load_HINT(''Initialization '+SGUpCaseString(UnitName)+' unit from ''+SGPCharToString(UnitName)+'': Error while loading dynamic library!'');' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	exit;' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('	end;' + SGWinEoln, FOutStream, False);
	for i := 0 to High(Typization[ii]) do
		begin
		if FMode <> 'OBJFPC' then
			begin
			SGWriteStringToStream(Typization[ii][i].FPascalName+' := LoadProcedure('+StringInQuotes(Typization[ii][i].FExternalName)+');' + SGWinEoln, FOutStream, False);
			{SGWriteStringToStream(
				' if @' + Typization[ii][i].FPascalName + ' = nil then begin WriteLn(''Error while loading "'+
				Typization[ii][i].FPascalName+'" from "'',UnitName,''".''); Result := False; end;' + SGWinEoln, FOutStream, False);}
			end
		else
			begin
			SGWriteStringToStream('Pointer(' + Typization[ii][i].FPascalName + ') := LoadProcedure('+StringInQuotes(Typization[ii][i].FExternalName)+');' + SGWinEoln, FOutStream, False);
			end;
		end;
	SGWriteStringToStream('Load_HINT(''Initialization '+SGUpCaseString(UnitName)+' unit from ''+SGPCharToString(UnitName)+''/''+'+StringInQuotes(Typization[ii][0].FExternalLibrary)+'+'': Loaded ''+SGStrReal(CountLoadSuccs/TotalProcCount*100,3)+''% (''+SGStr(CountLoadSuccs)+''/''+SGStr(TotalProcCount)+'').'');' + SGWinEoln, FOutStream, False);
	SGWriteStringToStream('end;' + SGWinEoln, FOutStream, False);
	end;

SGWriteStringToStream(SGWinEoln + 'function Load_'+UnitName+'() : Boolean;' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('var' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('	i : LongWord;' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('	R : array[0..'+SGStr(High(Typization))+'] of Boolean;' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('begin' + SGWinEoln, FOutStream, False);
for i := 0 to High(Typization) do
	begin
	SGWriteStringToStream('R['+SGStr(i)+'] := Load_'+UnitName+'_'+SGStr(i)+'('+Typization[i][0].FExternalLibrary+');' + SGWinEoln, FOutStream, False);
	end;
SGWriteStringToStream('Result := True;' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('for i := 0 to '+SGStr(High(Typization))+' do' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('	Result := Result and R[i];' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('end;' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('initialization' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('begin' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('Free_'+UnitName+'();' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('Load_'+UnitName+'();' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('end;' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('finalization' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('begin' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('Free_'+UnitName+'();' + SGWinEoln, FOutStream, False);
SGWriteStringToStream('end;' + SGWinEoln, FOutStream, False);

for i := 0 to High(Typization) do
	SetLength(Typization[i],0);
SetLength(Typization, 0);
end;

var
	Identifier : TSGString;
	ProcOutSize, ProcInPos, LastOutSize, LastInPos : TSGUInt32;
	i : TSGUInt32;
begin
Result := 0;
UnitName := SGGetFileName(FInFileName);
while FInStream.Size <> FInStream.Position do
	begin
	GetSizePos(LastOutSize, LastInPos);
	Identifier := GetNextIdentivier();
	if (SGUpCaseString(Identifier) = 'PROCEDURE') or (SGUpCaseString(Identifier) = 'FUNCTION') then
		begin
		ProcOutSize := LastOutSize;
		ProcInPos   := LastInPos;
		end
	else if SGUpCaseString(Identifier) = 'EXTERNAL' then
		begin
		ExternalCount += 1;
		while GetNextIdentivier() <> ';' do 
			;
		SetSizePos(ProcOutSize, FInStream.Position);
		i := FInStream.Position;
		
		FInStream.Position := ProcInPos;
		Identifier := '';
		while (FInStream.Position <> i) and (FInStream.Position < FInStream.Size) do
			Identifier += ReadChar();
		SGWriteStringToStream(SGWinEoln + '(*' + SGWinEoln + Identifier + SGWinEoln + '*)' + SGWinEoln, FOutStream, False);
		//WriteLn(Identifier);
		FInStream.Position := ProcInPos;
		Identifier := '';
		while (FInStream.Position <> i) and (FInStream.Position < FInStream.Size) do
			begin
			if Identifier <> '' then
				Identifier += ' ';
			Identifier += GetNextIdentivier(False);
			end;
		
		Identifier := ReWriteExternal(Identifier);
		end
	else if (SGUpCaseString(Identifier) = 'END.') then
		begin
		WriteReadWriteProcedures();
		end;
	SGWriteStringToStream(Identifier, FOutStream, False);
	Result += 1;
	end;
{for i := 0 to High(ExternalProcedures) do
	begin
	WriteLn(i,' ',ExternalProcedures[i].FExternalName);
	WriteLn(i,' ',ExternalProcedures[i].FExternalLibrary);
	WriteLn(i,' ',ExternalProcedures[i].FPascalName);
	ReadLn();
	end;}
end;

var
	Count : TSGUInt32 = 0;
begin
SGPrintEngineVersion();
WriteLn('ConvertHeaderToDynamic : In file size = ',FInStream.Size,'.');
Count := 0;
while FInStream.Size <> FInStream.Position do
	begin
	SGReadLnStringFromStream(FInStream);
	Count += 1;
	end;
WriteLn('ConvertHeaderToDynamic : In file total lines = ',Count,'.');
FInStream.Position := 0;
Count := Process();
WriteLn('ConvertHeaderToDynamic : In file identifier count = ',Count,'.');
WriteLn('ConvertHeaderToDynamic : External count = ',ExternalCount,'.');
SetLength(ExternalProcedures, 0);
end;

end.
