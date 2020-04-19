{$INCLUDE Smooth.inc}

unit SmoothDynamicHeadersMaker;

interface

uses
	 SmoothBase
	
	,Classes
	;

const
	SDDHModeObjFpc = 'OBJFPC';
	SDDHModeFpc = 'FPC';
	SDDHModeDelphi = 'DELPHI';
	SDDHModeDef = SDDHModeObjFpc;

	SDDHWriteModeFpc = 'FPC';
	SDDHWriteModeSmooth = 'SAGE';
	SDDHWriteModeObjectSmooth = 'OBJECT_SAGE';
	SDDHWriteModeDef = SDDHWriteModeObjectSmooth;

type
	TSDDHExternal = object
		FPascalName      : TSString;
		FExternalName    : TSString;
		FExternalLibrary : TSString;
		end;
	TSDDHExternalList = packed array of TSDDHExternal;
	TSDDHExternalTypification = packed array of TSDDHExternalList;
type
	TSDoDynamicHeader = class
			public
		constructor Create(const VFileName, VOutFileName : TSString; const VMode : TSString = SDDHModeDef);virtual;
		destructor Destroy();override;
		procedure PrintErrors();virtual;
		procedure Execute();virtual;
			private
		FInFileName, FOutFileName : TSString;
		FInStream, FOutStream : TMemoryStream;
		FMode : TSString;
		FWriteMode : TSString;
			private
		procedure WriteString(const S : TSString);
		procedure WriteLnString(const S : TSString);
		procedure WriteLoadExternal(const Ex : TSDDHExternal);
		function StringInQuotes(const S : TSString):TSString;
			protected
		function GetNextIdentivier(const NeedsToWrite : TSBool = True) : TSString;
		function SeeNextIdentifier() : TSString;
			public
		property WriteMode : TSString write FWriteMode;
			public
		class procedure NullUtil(const VInFile, VOutFile : TSString; const VMode : TSString = SDDHModeDef);
		end;

procedure SDynamicHeadersMaker(const VInFile, VOutFile : TSString; const VMode : TSString = SDDHModeDef; const VWriteMode : TSString = SDDHWriteModeDef);

implementation

uses
	 SmoothResourceManager
	,SmoothVersion
	,SmoothStringUtils
	,SmoothStreamUtils
	,SmoothLog
	,SmoothFileUtils
	
	,StrMan
	;

class procedure TSDoDynamicHeader.NullUtil(const VInFile, VOutFile : TSString; const VMode : TSString = SDDHModeDef);
var
	InFileStream, OutFileStream : TMemoryStream;
	S, W : TSString;
	L : TSUInt32 = 0;
begin
SPrintEngineVersion();
SHint('Input  file "' + VInFile + '"');
SHint('Output file "' + VOutFile + '"');
SHint('Mode = "' + SUpCaseString(VMode) + '"');
InFileStream := TMemoryStream.Create();
OutFileStream := TMemoryStream.Create();
InFileStream.LoadFromFile(VInFile);
InFileStream.Position := 0;
while InFileStream.Position <> InFileStream.Size do
	begin
	S := SReadLnStringFromStream(InFileStream);
	if StringWordCount(S, ' ') > 0 then
		begin
		l += 1;
		W := StringWordGet(S, ' ', 1);
		//if VMode = SDDHModeDelphi then
		//	SWriteStringToStream('Pointer(', OutFileStream, False);
		SWriteStringToStream(W, OutFileStream, False);
		//if VMode = SDDHModeDelphi then
		//	SWriteStringToStream(') ', OutFileStream, False);
		SWriteStringToStream(' := nil;' + DefaultEndOfLine, OutFileStream, False);
		end;
	end;
SHint('Total lines : ' + SStr(l));
OutFileStream.Position := 0;
OutFileStream.SaveToFile(VOutFile);
OutFileStream.Destroy();
InFileStream.Destroy();
end;

procedure SDynamicHeadersMaker(const VInFile, VOutFile : TSString; const VMode : TSString = SDDHModeDef; const VWriteMode : TSString = SDDHWriteModeDef);
var
	V : TSDoDynamicHeader = nil;
begin
V := TSDoDynamicHeader.Create(VInFile, VOutFile, VMode);
V.WriteMode := VWriteMode;
V.Execute();
V.PrintErrors();
V.Destroy();
V := nil;
end;

constructor TSDoDynamicHeader.Create(const VFileName, VOutFileName : TSString; const VMode : TSString = SDDHModeDef);
begin
FMode := SUpCaseString(VMode);
FInFileName := VFileName;
FOutFileName := VOutFileName;
FOutStream := TMemoryStream.Create();
FInStream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(FInStream, FInFileName);
FInStream.Position := 0;
end;

destructor TSDoDynamicHeader.Destroy();
begin
FOutStream.Position := 0;
WriteLn('DynamicHeadersMaker : Out file size = ',FOutStream.Size,'.');
FOutStream.SaveToFile(FOutFileName);
FOutStream.Destroy();
FInStream.Destroy();
inherited;
end;

procedure TSDoDynamicHeader.PrintErrors();
begin

end;

function TSDoDynamicHeader.SeeNextIdentifier() : TSString;
var
	InPos : TSUInt64;
begin
InPos := FInStream.Position;
Result := '';
while (Result <> '') and (FInStream.Position <> FInStream.Size) do
	Result := GetNextIdentivier(False);
FInStream.Position := InPos;
end;

function TSDoDynamicHeader.GetNextIdentivier(const NeedsToWrite : TSBool = True) : TSString;

function GoodChar(const C : TSChar):TSBool;
begin
Result := C in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_&0123456789.';
end;

function SpaceChar(const C : TSChar):TSBoolean;
begin
Result := C in ' 	';
end;

function BadChar(const C : TSChar):TSBoolean;
begin
Result := C in '()[]:;@^,*<>/=+''{}$-#';
end;

function EoChar(const C : TSChar):TSBool;
begin
Result := C in #10#13#0;
end;

function BadString(const S : TSString):TSBoolean;
var
	ArrBadStr : array [0..10] of TSString =
		(':=','<>','>=','<=','!=','**','+=','/=','*=','-=','..');
	Index : TSUInt8 = 0;
begin
Result := False;
for Index := Low(ArrBadStr) to High(ArrBadStr) do
	if S = ArrBadStr[Index] then
		begin
		Result := True;
		break;
		end;
end;

function NextChar() : TSChar;
begin
FInStream.ReadBuffer(Result, 1);
FInStream.Position := FInStream.Position - 1;
end;

procedure DecPos(const DecCount : TSUInt8 = 1);
begin
FInStream.Position := FInStream.Position - DecCount;
end;

function  RWChar() : TSChar;
begin
FInStream.ReadBuffer(Result, 1);
if NeedsToWrite then
	FOutStream.WriteBuffer(Result, 1);
end;

procedure Comments();
var
	ComFirstType : TSLongInt = 0;
	ComSecondType : TSLongInt = 0;
	C : TSChar;
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
	C : TSChar;
	Succ : TSBoolean = False;
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

procedure TSDoDynamicHeader.WriteString(const S : TSString);
begin
SWriteStringToStream(S, FOutStream, False);
end;

procedure TSDoDynamicHeader.WriteLnString(const S : TSString);
begin
SWriteStringToStream(S + DefaultEndOfLine, FOutStream, False);
end;

function TSDoDynamicHeader.StringInQuotes(const S : TSString):TSString;
begin
if S[1] = '''' then
	Result := S
else
	Result := '''' + S + '''';
end;

procedure TSDoDynamicHeader.WriteLoadExternal(const Ex : TSDDHExternal);
begin
if FMode <> SDDHModeObjFpc then
	begin
	WriteString(Ex.FPascalName);
	{WriteString(
		' if @' + Ex.FPascalName + ' = nil then begin WriteLn(''Error while loading "'+
		Ex.FPascalName+'" from "'',UnitName,''".''); Result := False; end;' + DefaultEndOfLine);}
	end
else
	begin
	WriteString('Pointer(' + Ex.FPascalName + ')');
	end;
WriteLnString(' := LoadProcedure('+StringInQuotes(Ex.FExternalName)+');');
end;

procedure TSDoDynamicHeader.Execute();
var
	ExternalCount : TSUInt32 = 0;

var
	ExternalProcedures : packed array of
		packed record
			FPascalName      : TSString;
			FExternalName    : TSString;
			FExternalLibrary : TSString;
			end = nil;

procedure AddExternalProcedure(const PN, EN, EL : TSString);
begin
if ExternalProcedures = nil then
	SetLength(ExternalProcedures, 1)
else
	SetLength(ExternalProcedures, Length(ExternalProcedures) + 1);
ExternalProcedures[High(ExternalProcedures)].FPascalName      := PN;
ExternalProcedures[High(ExternalProcedures)].FExternalName    := EN;
ExternalProcedures[High(ExternalProcedures)].FExternalLibrary := EL;
end;

procedure GetSizePos(var Size, Pos : TSUInt32);
begin
Size := FOutStream.Size;
Pos  := FInStream.Position;
end;

procedure SetSizePos(const Size, Pos : TSUInt32);
begin
FOutStream.Size := Size;
FOutStream.Position := Size;
FInStream.Position := Pos;
end;

function ReWriteExternal(const S : TSString):TSString;
var
	Str : TSString;

function EoChar(const C : TSChar):TSBool;
begin
Result := C in #10#13#0;
end;

function GetProcName(): TSString;
var
	i : TSLongInt;
begin
Result := '';
i := StringPos('(', Str, 0);
if i = 0 then
	i := StringPos(':', Str, 0);
if i = 0 then
	i := StringPos(';', Str, 0);
if i = 0 then
	begin
	SLog.Source('TSDoDynamicHeader.Execute().ReWriteExternal(S).GetProcName() = ''''.');
	SLog.Source('Where S = ''' + S + '''.');
	exit;
	end;
while (not (Str[i] in ' 	')) or (Result = '') do
	begin
	if not (Str[i] in ':;( 	') then
		Result += Str[i];
	i -= 1;
	end;
Result := StringReverse(Result);
end;

function GetProcExternalName(): TSString;
var
	WordCount : TSUInt32 = 0;
begin
WordCount := StringWordCount(Str, ' ');
if SUpCaseString(StringWordGet(Str, ' ', WordCount - 4)) = 'NAME' then
	begin
	Result := '''' + StringWordGet(Str, ' ', WordCount - 2) + '''';
	end
else if SUpCaseString(StringWordGet(Str, ' ', WordCount - 2)) = 'NAME' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 2);
	end
else
	Result := GetProcName();
end;

function GetProcLib(): TSString;
var
	WordCount : TSUInt32 = 0;
begin
Result := '';
WordCount := StringWordCount(Str, ' ');
if SUpCaseString(StringWordGet(Str, ' ', WordCount - 2)) = 'EXTERNAL' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 1);
	end
else if SUpCaseString(StringWordGet(Str, ' ', WordCount - 4)) = 'EXTERNAL' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 3);
	end
else if SUpCaseString(StringWordGet(Str, ' ', WordCount - 6)) = 'EXTERNAL' then
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
else if SUpCaseString(StringWordGet(Str, ' ', WordCount - 8)) = 'EXTERNAL' then
	begin
	Result := StringWordGet(Str, ' ', WordCount - 6);
	end
else
	begin
	SLog.Source('TSDoDynamicHeader.Execute().ReWriteExternal(S).GetProcLib() = ''''.');
	SLog.Source('Where S = ''' + S + '''.');
	exit;
	end;
end;

function NextWord(StringIndex : TSLongWord):TSString;
begin
Result := '';
while (StringIndex <= Length(Str)) and (not(Str[StringIndex] in '	 ')) do
	begin
	Result += Str[StringIndex];
	StringIndex += 1;
	end;
end;

function GetProcType(): TSString;
var
	i : TSLongWord;
begin
i := 1;
Result := '';
while not (Str[i] in '	 ') do
	begin
	Result += Str[i];
	i += 1;
	end;
i := StringPos('(', Str, 0);
if i = 0 then
	i := StringPos(':', Str, 0);
if i = 0 then
	i := StringPos(';', Str, 0);
if i = 0 then
	begin
	SLog.Source('TSDoDynamicHeader.Execute().ReWriteExternal(S).GetProcType() = ''''.');
	SLog.Source('Where S = ''' + S + '''.');
	exit;
	end;
while (SUpCaseString(NextWord(i)) <> 'EXTERNAL') do
	begin
	if not ((i <= Length(Str))) then
		begin
		WriteLn(Str);ReadLn();
		end;
	Result += Str[i];
	i += 1;
	end;
end;

var
	i : TSUInt32 = 0;
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
Result += DefaultEndOfLine;
end;

function ReadChar() : TSChar;
begin
FInStream.ReadBuffer(Result, 1);
end;

function Process() : TSUInt32;
var
	UnitName : TSString = '';

procedure WriteReadWriteProcedures();
var
	i : TSUInt32 = 0;
	Typification : TSDDHExternalTypification = nil;

procedure ProcessTypification();

function IndexOfType(const S : TSString):TSLongInt;
var
	i : TSLongWord;
begin
Result := -1;
if Typification = nil then
	begin
	SetLength(Typification, 1);
	Result := 0;
	end
else
	begin
	for i := 0 to High(Typification) do
		if Typification[i][0].FExternalLibrary = S then
			begin
			Result := i;
			break;
			end;
	if Result = -1 then
		begin
		SetLength(Typification, Length(Typification) + 1);
		Typification[High(Typification)] := nil;
		Result := High(Typification);
		end;
	end;
end;

var
	Index, i : TSLongInt;
begin
for i := 0 to High(ExternalProcedures) do
	begin
	Index := IndexOfType(ExternalProcedures[i].FExternalLibrary);
	if Typification[Index] = nil then
		SetLength(Typification[Index], 1)
	else
		SetLength(Typification[Index], Length(Typification[Index]) + 1);
	Typification[Index][High(Typification[Index])].FExternalLibrary := ExternalProcedures[i].FExternalLibrary;
	Typification[Index][High(Typification[Index])].FPascalName      := ExternalProcedures[i].FPascalName;
	Typification[Index][High(Typification[Index])].FExternalName    := ExternalProcedures[i].FExternalName;
	end;
end;

procedure WriteLoadExternals();
var
	i, ii : TSUInt32;
begin
if Typification <> nil then if Length(Typification) > 0 then
	for i := 0 to High(Typification) do
		if Typification[i] <> nil then if Length(Typification[i]) > 0 then
			for ii := 0 to High(Typification[i]) do
				WriteLoadExternal(Typification[i][ii]);
end;

var
	ii : TSLongWord;
begin
//WriteString(DefaultEndOfLine + '{$mode '+FMode+'}' + DefaultEndOfLine);
ProcessTypification();

WriteString('// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=' + DefaultEndOfLine);
WriteString('// =*=*= Smooth DLL IMPLEMENTATION =*=*=*=' + DefaultEndOfLine);
WriteString('// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=' + DefaultEndOfLine);
WriteString(DefaultEndOfLine);

if FWriteMode <> SDDHWriteModeObjectSmooth then
	begin
	WriteString(DefaultEndOfLine + 'procedure Load_HINT(const Er : String);' + DefaultEndOfLine);
	WriteString('begin' + DefaultEndOfLine);
	if FWriteMode = SDDHWriteModeSmooth then
		WriteString('//');
	WriteString('WriteLn(Er);' + DefaultEndOfLine);
	if not (FWriteMode = SDDHWriteModeFpc) then
		WriteString('SLog.Source(Er);' + DefaultEndOfLine)
	else
		WriteString('//Can source Er to log' + DefaultEndOfLine);
	WriteString('end;' + DefaultEndOfLine);
	end;

if FWriteMode = SDDHWriteModeObjectSmooth then
	begin
	WriteString('type' + DefaultEndOfLine);
	WriteString('	TSDll' + UnitName + ' = class(TSDll)' + DefaultEndOfLine);
	WriteString('			public' + DefaultEndOfLine);
	WriteString('		class function SystemNames() : TSStringList; override;' + DefaultEndOfLine);
	WriteString('		class function DllNames() : TSStringList; override;' + DefaultEndOfLine);
	WriteString('		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;' + DefaultEndOfLine);
	WriteString('		class procedure Free(); override;' + DefaultEndOfLine);
	WriteString('		end;' + DefaultEndOfLine);
	end;

if FWriteMode <> SDDHWriteModeObjectSmooth then
	WriteString('procedure Free_'+UnitName+'();' + DefaultEndOfLine)
else
	WriteString('class procedure TSDll' + UnitName + '.Free();' + DefaultEndOfLine);
WriteString('begin' + DefaultEndOfLine);
for i := 0 to High(ExternalProcedures) do
	WriteString(''+ExternalProcedures[i].FPascalName+' := nil;' + DefaultEndOfLine);
WriteString('end;' + DefaultEndOfLine);

if FWriteMode = SDDHWriteModeObjectSmooth then
	begin
	WriteString('class function TSDll' + UnitName + '.SystemNames() : TSStringList;' + DefaultEndOfLine);
	WriteString('begin' + DefaultEndOfLine);
	WriteString('Result := nil;' + DefaultEndOfLine);
	WriteString('Result += '''+UnitName+''';' + DefaultEndOfLine);
	WriteString('end;' + DefaultEndOfLine);
	WriteString('class function TSDll' + UnitName + '.DllNames() : TSStringList;' + DefaultEndOfLine);
	WriteString('begin' + DefaultEndOfLine);
	WriteString('Result := nil;' + DefaultEndOfLine);
	if Typification <> nil then if Length(Typification) > 0 then
		for i := 0 to High(Typification) do
		WriteString('Result += '+Typification[i][0].FExternalLibrary+';' + DefaultEndOfLine);
	WriteString('end;' + DefaultEndOfLine);
	WriteString('class function TSDll' + UnitName + '.Load(const VDll : TSLibHandle) : TSDllLoadObject;' + DefaultEndOfLine);
	WriteString('var' + DefaultEndOfLine);
	WriteString('	LoadResult : PSDllLoadObject = nil;' + DefaultEndOfLine);
	WriteLnString('');
	WriteString('function LoadProcedure(const Name : PChar) : Pointer;' + DefaultEndOfLine);
	WriteString('begin' + DefaultEndOfLine);
	WriteString('Result := GetProcAddress(VDll, Name);' + DefaultEndOfLine);
	WriteString('if Result = nil then' + DefaultEndOfLine);
		WriteString('LoadResult^.FFunctionErrors += SPCharToString(Name)' + DefaultEndOfLine);
	WriteString('else' + DefaultEndOfLine);
		WriteString('LoadResult^.FFunctionLoaded += 1;' + DefaultEndOfLine);
	WriteString('end;' + DefaultEndOfLine);
	WriteLnString('');
	WriteString('begin' + DefaultEndOfLine);
	WriteString('Result.Clear();' + DefaultEndOfLine);
	WriteString('Result.FFunctionCount := ' + SStr(ExternalCount) + ';' + DefaultEndOfLine);
	WriteString('LoadResult := @Result;' + DefaultEndOfLine);
	WriteLoadExternals();
	WriteString('end;' + DefaultEndOfLine);
	WriteLnString('');
	WriteString('initialization' + DefaultEndOfLine);
	WriteString('	TSDll' + UnitName + '.Create();' + DefaultEndOfLine);
	end
else
	begin
	for ii := 0 to High(Typification) do
		begin
		WriteString('function Load_'+UnitName+'_'+SStr(ii)+'(const UnitName : PChar) : Boolean;' + DefaultEndOfLine);
		WriteString('const' + DefaultEndOfLine);
		WriteString('	TotalProcCount = '+SStr(Length(Typification[ii]))+';' + DefaultEndOfLine);
		WriteString('var' + DefaultEndOfLine);
		WriteString('	UnitLib : TSMaxEnum;' + DefaultEndOfLine);
		WriteString('	CountLoadSuccs : LongWord;' + DefaultEndOfLine);
		WriteString('function LoadProcedure(const Name : PChar) : Pointer;' + DefaultEndOfLine);
		WriteString('begin' + DefaultEndOfLine);
		WriteString('Result := GetProcAddress(UnitLib, Name);' + DefaultEndOfLine);
		WriteString('if Result = nil then' + DefaultEndOfLine);
		WriteString('	Load_HINT(''Initialization '+SUpCaseString(UnitName)+' unit from ''+SPCharToString(UnitName)+'': Error while loading "''+SPCharToString(Name)+''"!'')' + DefaultEndOfLine);
		WriteString('else' + DefaultEndOfLine);
		WriteString('	CountLoadSuccs := CountLoadSuccs + 1;' + DefaultEndOfLine);
		WriteString('end;' + DefaultEndOfLine);
		WriteString('begin' + DefaultEndOfLine);
		WriteString('UnitLib := LoadLibrary(UnitName);' + DefaultEndOfLine);
		WriteString('Result := UnitLib <> 0;' + DefaultEndOfLine);
		WriteString('CountLoadSuccs := 0;' + DefaultEndOfLine);
		WriteString('if not Result then' + DefaultEndOfLine);
		WriteString('	begin' + DefaultEndOfLine);
		WriteString('	Load_HINT(''Initialization '+SUpCaseString(UnitName)+' unit from ''+SPCharToString(UnitName)+'': Error while loading dynamic library!'');' + DefaultEndOfLine);
		WriteString('	exit;' + DefaultEndOfLine);
		WriteString('	end;' + DefaultEndOfLine);
		for i := 0 to High(Typification[ii]) do
			WriteLoadExternal(Typification[ii][i]);
		WriteString('Load_HINT(''Initialization '+SUpCaseString(UnitName)+' unit from ''+SPCharToString(UnitName)+''/''+'+StringInQuotes(Typification[ii][0].FExternalLibrary)+'+'': Loaded ''+SStrReal(CountLoadSuccs/TotalProcCount*100,3)+''% (''+SStr(CountLoadSuccs)+''/''+SStr(TotalProcCount)+'').'');' + DefaultEndOfLine);
		WriteString('end;' + DefaultEndOfLine);
		end;

	WriteString(DefaultEndOfLine + 'function Load_'+UnitName+'() : Boolean;' + DefaultEndOfLine);
	WriteString('var' + DefaultEndOfLine);
	WriteString('	i : LongWord;' + DefaultEndOfLine);
	WriteString('	R : array[0..'+SStr(High(Typification))+'] of Boolean;' + DefaultEndOfLine);
	WriteString('begin' + DefaultEndOfLine);
	for i := 0 to High(Typification) do
		begin
		WriteString('R['+SStr(i)+'] := Load_'+UnitName+'_'+SStr(i)+'('+Typification[i][0].FExternalLibrary+');' + DefaultEndOfLine);
		end;
	WriteString('Result := True;' + DefaultEndOfLine);
	WriteString('for i := 0 to '+SStr(High(Typification))+' do' + DefaultEndOfLine);
	WriteString('	Result := Result and R[i];' + DefaultEndOfLine);
	WriteString('end;' + DefaultEndOfLine);
	WriteString('initialization' + DefaultEndOfLine);
	WriteString('begin' + DefaultEndOfLine);
	WriteString('Free_'+UnitName+'();' + DefaultEndOfLine);
	WriteString('Load_'+UnitName+'();' + DefaultEndOfLine);
	WriteString('end;' + DefaultEndOfLine);
	WriteString('finalization' + DefaultEndOfLine);
	WriteString('begin' + DefaultEndOfLine);
	WriteString('Free_'+UnitName+'();' + DefaultEndOfLine);
	WriteString('end;' + DefaultEndOfLine);
	end;

for i := 0 to High(Typification) do
	SetLength(Typification[i],0);
SetLength(Typification, 0);
end;

var
	Identifier : TSString;
	ProcOutSize, ProcInPos, LastOutSize, LastInPos : TSUInt32;
	i : TSUInt32;
begin
Result := 0;
UnitName := SFileName(FInFileName);
while FInStream.Size <> FInStream.Position do
	begin
	GetSizePos(LastOutSize, LastInPos);
	Identifier := GetNextIdentivier();
	if (SUpCaseString(Identifier) = 'PROCEDURE') or (SUpCaseString(Identifier) = 'FUNCTION') then
		begin
		ProcOutSize := LastOutSize;
		ProcInPos   := LastInPos;
		end
	else if (SUpCaseString(Identifier) = 'IMPLEMENTATION') and (FWriteMode <> SDDHWriteModeFpc) then
		begin
		Identifier := '';
		WriteString('implementation' + DefaultEndOfLine);
		WriteString(DefaultEndOfLine);
		WriteString('uses ' + DefaultEndOfLine);
		WriteString('	 SmoothBase' + DefaultEndOfLine);
		if FWriteMode = SDDHWriteModeObjectSmooth then
			begin
			WriteLnString('	,SmoothDllManager');
			WriteLnString('	,SmoothSysUtils');
			WriteLnString('	,SmoothStringUtils');
			end;
		WriteString('	;' + DefaultEndOfLine);
		end
	else if SUpCaseString(Identifier) = 'EXTERNAL' then
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
		WriteString(DefaultEndOfLine + '(*' + DefaultEndOfLine + Identifier + DefaultEndOfLine + '*)' + DefaultEndOfLine);
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
	else if (SUpCaseString(Identifier) = 'END.') then
		begin
		WriteReadWriteProcedures();
		end;
	WriteString(Identifier);
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
	Count : TSUInt32 = 0;
begin
FWriteMode := SUpCaseString(FWriteMode);
SPrintEngineVersion();
WriteLn('DynamicHeadersMaker : In file size = ',FInStream.Size,'(',SMemorySizeToString(FInStream.Size,'EN'),')','.');
Count := 0;
while FInStream.Size <> FInStream.Position do
	begin
	SReadLnStringFromStream(FInStream);
	Count += 1;
	end;
WriteLn('DynamicHeadersMaker : In file total lines = ',Count,'.');
FInStream.Position := 0;
Count := Process();
WriteLn('DynamicHeadersMaker : In file identifier count = ',Count,'.');
WriteLn('DynamicHeadersMaker : External count = ',ExternalCount,'.');
SetLength(ExternalProcedures, 0);
end;

end.
