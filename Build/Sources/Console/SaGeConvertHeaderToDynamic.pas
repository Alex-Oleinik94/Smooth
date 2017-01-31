{$INCLUDE SaGe.inc}

unit SaGeConvertHeaderToDynamic;

interface

uses
	 SaGeBase
	
	,Classes
	;

const
	SGDDHModeObjFpc = 'OBJFPC';
	SGDDHModeFpc = 'FPC';
	SGDDHModeDelphi = 'DELPHI';
	SGDDHModeDef = SGDDHModeObjFpc;

	SGDDHWriteModeFpc = 'FPC';
	SGDDHWriteModeSaGe = 'SAGE';
	SGDDHWriteModeObjectSaGe = 'OBJECT_SAGE';
	SGDDHWriteModeDef = SGDDHWriteModeObjectSaGe;

type
	TSGDDHExternal = object
		FPascalName      : TSGString;
		FExternalName    : TSGString;
		FExternalLibrary : TSGString;
		end;
	TSGDDHExternalList = packed array of TSGDDHExternal;
	TSGDDHExternalTypification = packed array of TSGDDHExternalList;
type
	TSGDoDynamicHeader = class
			public
		constructor Create(const VFileName, VOutFileName : TSGString; const VMode : TSGString = SGDDHModeDef);virtual;
		destructor Destroy();override;
		procedure PrintErrors();virtual;
		procedure Execute();virtual;
			private
		FInFileName, FOutFileName : TSGString;
		FInStream, FOutStream : TMemoryStream;
		FMode : TSGString;
		FWriteMode : TSGString;
			private
		procedure WriteString(const S : TSGString);
		procedure WriteLnString(const S : TSGString);
		procedure WriteLoadExternal(const Ex : TSGDDHExternal);
		function StringInQuotes(const S : TSGString):TSGString;
			protected
		function GetNextIdentivier(const NeedsToWrite : TSGBool = True) : TSGString;
		function SeeNextIdentifier() : TSGString;
			public
		property WriteMode : TSGString write FWriteMode;
			public
		class procedure NullUtil(const VInFile, VOutFile : TSGString; const VMode : TSGString = SGDDHModeDef);
		end;

procedure SGConvertHeaderToDynamic(const VInFile, VOutFile : TSGString; const VMode : TSGString = SGDDHModeDef; const VWriteMode : TSGString = SGDDHWriteModeDef);

implementation

uses
	 SaGeResourceManager
	,SaGeVersion
	,SaGeStringUtils
	,SaGeLog
	,SaGeFileUtils
	
	,StrMan
	;

class procedure TSGDoDynamicHeader.NullUtil(const VInFile, VOutFile : TSGString; const VMode : TSGString = SGDDHModeDef);
var
	InFileStream, OutFileStream : TMemoryStream;
	S, W : TSGString;
	L : TSGUInt32 = 0;
begin
SGPrintEngineVersion();
SGHint('Input  file "' + VInFile + '"');
SGHint('Output file "' + VOutFile + '"');
SGHint('Mode = "' + SGUpCaseString(VMode) + '"');
InFileStream := TMemoryStream.Create();
OutFileStream := TMemoryStream.Create();
InFileStream.LoadFromFile(VInFile);
InFileStream.Position := 0;
while InFileStream.Position <> InFileStream.Size do
	begin
	S := SGReadLnStringFromStream(InFileStream);
	if StringWordCount(S, ' ') > 0 then
		begin
		l += 1;
		W := StringWordGet(S, ' ', 1);
		//if VMode = SGDDHModeDelphi then
		//	SGWriteStringToStream('Pointer(', OutFileStream, False);
		SGWriteStringToStream(W, OutFileStream, False);
		//if VMode = SGDDHModeDelphi then
		//	SGWriteStringToStream(') ', OutFileStream, False);
		SGWriteStringToStream(' := nil;' + SGWinEoln, OutFileStream, False);
		end;
	end;
SGHint('Total lines : ' + SGStr(l));
OutFileStream.Position := 0;
OutFileStream.SaveToFile(VOutFile);
OutFileStream.Destroy();
InFileStream.Destroy();
end;

procedure SGConvertHeaderToDynamic(const VInFile, VOutFile : TSGString; const VMode : TSGString = SGDDHModeDef; const VWriteMode : TSGString = SGDDHWriteModeDef);
var
	V : TSGDoDynamicHeader = nil;
begin
V := TSGDoDynamicHeader.Create(VInFile, VOutFile, VMode);
V.WriteMode := VWriteMode;
V.Execute();
V.PrintErrors();
V.Destroy();
V := nil;
end;

constructor TSGDoDynamicHeader.Create(const VFileName, VOutFileName : TSGString; const VMode : TSGString = SGDDHModeDef);
begin
FMode := SGUpCaseString(VMode);
FInFileName := VFileName;
FOutFileName := VOutFileName;
FOutStream := TMemoryStream.Create();
FInStream := TMemoryStream.Create();
SGResourceFiles.LoadMemoryStreamFromFile(FInStream, FInFileName);
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

procedure TSGDoDynamicHeader.WriteString(const S : TSGString);
begin
SGWriteStringToStream(S, FOutStream, False);
end;

procedure TSGDoDynamicHeader.WriteLnString(const S : TSGString);
begin
SGWriteStringToStream(S + SGWinEoln, FOutStream, False);
end;

function TSGDoDynamicHeader.StringInQuotes(const S : TSGString):TSGString;
begin
if S[1] = '''' then
	Result := S
else
	Result := '''' + S + '''';
end;

procedure TSGDoDynamicHeader.WriteLoadExternal(const Ex : TSGDDHExternal);
begin
if FMode <> SGDDHModeObjFpc then
	begin
	WriteString(Ex.FPascalName);
	{WriteString(
		' if @' + Ex.FPascalName + ' = nil then begin WriteLn(''Error while loading "'+
		Ex.FPascalName+'" from "'',UnitName,''".''); Result := False; end;' + SGWinEoln);}
	end
else
	begin
	WriteString('Pointer(' + Ex.FPascalName + ')');
	end;
WriteLnString(' := LoadProcedure('+StringInQuotes(Ex.FExternalName)+');');
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
Result := '';
i := StringPos('(', Str, 0);
if i = 0 then
	i := StringPos(':', Str, 0);
if i = 0 then
	i := StringPos(';', Str, 0);
if i = 0 then
	begin
	SGLog.Source('TSGDoDynamicHeader.Execute().ReWriteExternal(S).GetProcName() = ''''.');
	SGLog.Source('Where S = ''' + S + '''.');
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
Result := '';
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
	SGLog.Source('TSGDoDynamicHeader.Execute().ReWriteExternal(S).GetProcLib() = ''''.');
	SGLog.Source('Where S = ''' + S + '''.');
	exit;
	end;
end;

function NextWord(StringIndex : TSGLongWord):TSGString;
begin
Result := '';
while (StringIndex <= Length(Str)) and (not(Str[StringIndex] in '	 ')) do
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
	SGLog.Source('TSGDoDynamicHeader.Execute().ReWriteExternal(S).GetProcType() = ''''.');
	SGLog.Source('Where S = ''' + S + '''.');
	exit;
	end;
while (SGUpCaseString(NextWord(i)) <> 'EXTERNAL') do
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
	Typification : TSGDDHExternalTypification = nil;

procedure ProcessTypification();

function IndexOfType(const S : TSGString):TSGLongInt;
var
	i : TSGLongWord;
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
	Index, i : TSGLongInt;
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
	i, ii : TSGUInt32;
begin
if Typification <> nil then if Length(Typification) > 0 then
	for i := 0 to High(Typification) do
		if Typification[i] <> nil then if Length(Typification[i]) > 0 then
			for ii := 0 to High(Typification[i]) do
				WriteLoadExternal(Typification[i][ii]);
end;

var
	ii : TSGLongWord;
begin
//WriteString(SGWinEoln + '{$mode '+FMode+'}' + SGWinEoln);
ProcessTypification();

WriteString('// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=' + SGWinEoln);
WriteString('// =*=*= SaGe DLL IMPLEMENTATION =*=*=*=' + SGWinEoln);
WriteString('// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=' + SGWinEoln);
WriteString(SGWinEoln);

if FWriteMode <> SGDDHWriteModeObjectSaGe then
	begin
	WriteString(SGWinEoln + 'procedure Load_HINT(const Er : String);' + SGWinEoln);
	WriteString('begin' + SGWinEoln);
	if FWriteMode = SGDDHWriteModeSaGe then
		WriteString('//');
	WriteString('WriteLn(Er);' + SGWinEoln);
	if not (FWriteMode = SGDDHWriteModeFpc) then
		WriteString('SGLog.Source(Er);' + SGWinEoln)
	else
		WriteString('//Can source Er to log' + SGWinEoln);
	WriteString('end;' + SGWinEoln);
	end;

if FWriteMode = SGDDHWriteModeObjectSaGe then
	begin
	WriteString('type' + SGWinEoln);
	WriteString('	TSGDll' + UnitName + ' = class(TSGDll)' + SGWinEoln);
	WriteString('			public' + SGWinEoln);
	WriteString('		class function SystemNames() : TSGStringList; override;' + SGWinEoln);
	WriteString('		class function DllNames() : TSGStringList; override;' + SGWinEoln);
	WriteString('		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; override;' + SGWinEoln);
	WriteString('		class procedure Free(); override;' + SGWinEoln);
	WriteString('		end;' + SGWinEoln);
	end;

if FWriteMode <> SGDDHWriteModeObjectSaGe then
	WriteString('procedure Free_'+UnitName+'();' + SGWinEoln)
else
	WriteString('class procedure TSGDll' + UnitName + '.Free();' + SGWinEoln);
WriteString('begin' + SGWinEoln);
for i := 0 to High(ExternalProcedures) do
	WriteString(''+ExternalProcedures[i].FPascalName+' := nil;' + SGWinEoln);
WriteString('end;' + SGWinEoln);

if FWriteMode = SGDDHWriteModeObjectSaGe then
	begin
	WriteString('class function TSGDll' + UnitName + '.SystemNames() : TSGStringList;' + SGWinEoln);
	WriteString('begin' + SGWinEoln);
	WriteString('Result := nil;' + SGWinEoln);
	WriteString('Result += '''+UnitName+''';' + SGWinEoln);
	WriteString('end;' + SGWinEoln);
	WriteString('class function TSGDll' + UnitName + '.DllNames() : TSGStringList;' + SGWinEoln);
	WriteString('begin' + SGWinEoln);
	WriteString('Result := nil;' + SGWinEoln);
	if Typification <> nil then if Length(Typification) > 0 then
		for i := 0 to High(Typification) do
		WriteString('Result += '+Typification[i][0].FExternalLibrary+';' + SGWinEoln);
	WriteString('end;' + SGWinEoln);
	WriteString('class function TSGDll' + UnitName + '.Load(const VDll : TSGLibHandle) : TSGDllLoadObject;' + SGWinEoln);
	WriteString('var' + SGWinEoln);
	WriteString('	LoadResult : PSGDllLoadObject = nil;' + SGWinEoln);
	WriteLnString('');
	WriteString('function LoadProcedure(const Name : PChar) : Pointer;' + SGWinEoln);
	WriteString('begin' + SGWinEoln);
	WriteString('Result := GetProcAddress(VDll, Name);' + SGWinEoln);
	WriteString('if Result = nil then' + SGWinEoln);
		WriteString('LoadResult^.FFunctionErrors += SGPCharToString(Name)' + SGWinEoln);
	WriteString('else' + SGWinEoln);
		WriteString('LoadResult^.FFunctionLoaded += 1;' + SGWinEoln);
	WriteString('end;' + SGWinEoln);
	WriteLnString('');
	WriteString('begin' + SGWinEoln);
	WriteString('Result.Clear();' + SGWinEoln);
	WriteString('Result.FFunctionCount := ' + SGStr(ExternalCount) + ';' + SGWinEoln);
	WriteString('LoadResult := @Result;' + SGWinEoln);
	WriteLoadExternals();
	WriteString('end;' + SGWinEoln);
	WriteLnString('');
	WriteString('initialization' + SGWinEoln);
	WriteString('	TSGDll' + UnitName + '.Create();' + SGWinEoln);
	end
else
	begin
	for ii := 0 to High(Typification) do
		begin
		WriteString('function Load_'+UnitName+'_'+SGStr(ii)+'(const UnitName : PChar) : Boolean;' + SGWinEoln);
		WriteString('const' + SGWinEoln);
		WriteString('	TotalProcCount = '+SGStr(Length(Typification[ii]))+';' + SGWinEoln);
		WriteString('var' + SGWinEoln);
		WriteString('	UnitLib : TSGMaxEnum;' + SGWinEoln);
		WriteString('	CountLoadSuccs : LongWord;' + SGWinEoln);
		WriteString('function LoadProcedure(const Name : PChar) : Pointer;' + SGWinEoln);
		WriteString('begin' + SGWinEoln);
		WriteString('Result := GetProcAddress(UnitLib, Name);' + SGWinEoln);
		WriteString('if Result = nil then' + SGWinEoln);
		WriteString('	Load_HINT(''Initialization '+SGUpCaseString(UnitName)+' unit from ''+SGPCharToString(UnitName)+'': Error while loading "''+SGPCharToString(Name)+''"!'')' + SGWinEoln);
		WriteString('else' + SGWinEoln);
		WriteString('	CountLoadSuccs := CountLoadSuccs + 1;' + SGWinEoln);
		WriteString('end;' + SGWinEoln);
		WriteString('begin' + SGWinEoln);
		WriteString('UnitLib := LoadLibrary(UnitName);' + SGWinEoln);
		WriteString('Result := UnitLib <> 0;' + SGWinEoln);
		WriteString('CountLoadSuccs := 0;' + SGWinEoln);
		WriteString('if not Result then' + SGWinEoln);
		WriteString('	begin' + SGWinEoln);
		WriteString('	Load_HINT(''Initialization '+SGUpCaseString(UnitName)+' unit from ''+SGPCharToString(UnitName)+'': Error while loading dynamic library!'');' + SGWinEoln);
		WriteString('	exit;' + SGWinEoln);
		WriteString('	end;' + SGWinEoln);
		for i := 0 to High(Typification[ii]) do
			WriteLoadExternal(Typification[ii][i]);
		WriteString('Load_HINT(''Initialization '+SGUpCaseString(UnitName)+' unit from ''+SGPCharToString(UnitName)+''/''+'+StringInQuotes(Typification[ii][0].FExternalLibrary)+'+'': Loaded ''+SGStrReal(CountLoadSuccs/TotalProcCount*100,3)+''% (''+SGStr(CountLoadSuccs)+''/''+SGStr(TotalProcCount)+'').'');' + SGWinEoln);
		WriteString('end;' + SGWinEoln);
		end;

	WriteString(SGWinEoln + 'function Load_'+UnitName+'() : Boolean;' + SGWinEoln);
	WriteString('var' + SGWinEoln);
	WriteString('	i : LongWord;' + SGWinEoln);
	WriteString('	R : array[0..'+SGStr(High(Typification))+'] of Boolean;' + SGWinEoln);
	WriteString('begin' + SGWinEoln);
	for i := 0 to High(Typification) do
		begin
		WriteString('R['+SGStr(i)+'] := Load_'+UnitName+'_'+SGStr(i)+'('+Typification[i][0].FExternalLibrary+');' + SGWinEoln);
		end;
	WriteString('Result := True;' + SGWinEoln);
	WriteString('for i := 0 to '+SGStr(High(Typification))+' do' + SGWinEoln);
	WriteString('	Result := Result and R[i];' + SGWinEoln);
	WriteString('end;' + SGWinEoln);
	WriteString('initialization' + SGWinEoln);
	WriteString('begin' + SGWinEoln);
	WriteString('Free_'+UnitName+'();' + SGWinEoln);
	WriteString('Load_'+UnitName+'();' + SGWinEoln);
	WriteString('end;' + SGWinEoln);
	WriteString('finalization' + SGWinEoln);
	WriteString('begin' + SGWinEoln);
	WriteString('Free_'+UnitName+'();' + SGWinEoln);
	WriteString('end;' + SGWinEoln);
	end;

for i := 0 to High(Typification) do
	SetLength(Typification[i],0);
SetLength(Typification, 0);
end;

var
	Identifier : TSGString;
	ProcOutSize, ProcInPos, LastOutSize, LastInPos : TSGUInt32;
	i : TSGUInt32;
begin
Result := 0;
UnitName := SGFileName(FInFileName);
while FInStream.Size <> FInStream.Position do
	begin
	GetSizePos(LastOutSize, LastInPos);
	Identifier := GetNextIdentivier();
	if (SGUpCaseString(Identifier) = 'PROCEDURE') or (SGUpCaseString(Identifier) = 'FUNCTION') then
		begin
		ProcOutSize := LastOutSize;
		ProcInPos   := LastInPos;
		end
	else if (SGUpCaseString(Identifier) = 'IMPLEMENTATION') and (FWriteMode <> SGDDHWriteModeFpc) then
		begin
		Identifier := '';
		WriteString('implementation' + SGWinEoln);
		WriteString(SGWinEoln);
		WriteString('uses ' + SGWinEoln);
		WriteString('	 SaGeBase' + SGWinEoln);
		if FWriteMode = SGDDHWriteModeObjectSaGe then
			WriteString('	,SaGeDllManager' + SGWinEoln);
		WriteString('	;' + SGWinEoln);
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
		WriteString(SGWinEoln + '(*' + SGWinEoln + Identifier + SGWinEoln + '*)' + SGWinEoln);
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
