{$INCLUDE SaGe.inc}

//{$DEFINE SG_DEBUG_SHADERS}
{$IFDEF SG_DEBUG_SHADERS}
	{$DEFINE SG_BASE_DEBUG_SHADERS}
{$ELSE}
	//{$DEFINE SG_BASE_DEBUG_SHADERS}
{$ENDIF}

unit SaGeShaders;

interface
uses
	 Crt
	,SysUtils
	,Classes
	
	,StrMan
	
	,SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeCommonClasses
	,SaGeResourceManager
	,SaGeMath
	,SaGeRenderConstants
	;
type
	TSGShaderParams = TSGStringList;
	TSGShaderProgram = class;
	TSGShader = class(TSGContextabled)
			public
		constructor Create(const VContext : ISGContext;const ShaderType:LongWord = SGR_VERTEX_SHADER);
		destructor Destroy();override;
		function Compile():Boolean;inline;
		procedure Source(const s:string);overload;
		procedure PrintInfoLog();
			private
		FShader : TSGLongWord;
		FType   : TSGLongWord;
			public
		property Shader : TSGLongWord read FShader;
		property Handle : TSGLongWord read FShader;
			public
		function StringType() : TSGString;
		end;
	
	TSGShaderProgram=class(TSGContextabled)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy;override;
		procedure Attach(const NewShader:TSGShader);
		function Link():Boolean;
		procedure PrintInfoLog();
		procedure Use();
		function GetUniformLocation(const VLocationName : PChar): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function GetUniformLocation(const VLocationName : TSGString): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
			private
		FProgram : TSGLongWord;
		FShaders :
			packed array of
				TSGShader;
			public
		property Handle : TSGLongWord read FProgram;
		end;
	
	TSGShaderReader = class
			public
		constructor Create();
		destructor Destroy();override;
			private
		FStandartParams : packed array of
			packed record
				FNumber : TSGLongWord;
				FParam  : TSGString;
				end;
		FStream : TMemoryStream;
		FFileParams : TSGShaderParams;
		FFileName : TSGString;
			public
		function IdentifierValue(VString : TSGString;const VAditionalParams : TSGString = ''):TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessString(const VString : TSGString;const VAditionalParams : TSGString = ''):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessFor(const VVariable : TSGString; const VBegin, VEnd : TSGLongInt; const VString : TSGString;const NeedEolns : TSGBoolean = False;const VAditionalParams : TSGString = ''):TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessComand(const VComand : TSGString; VParams : TSGShaderParams;const Stream : TMemoryStream;const VAditionalParams : TSGString = ''):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function FindComand(VString : TSGString; out VParams : TSGShaderParams; out ComandShift : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessCustomString(const S : TSGString; const Stream : TMemoryStream; const VAditionalParams : TSGString = '';const UseEoln : TSGBoolean = True):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Process():TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessStrings(VString : TSGString;const VAditionalParams : TSGString = ''):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		function WithParam(const VAditionalParams : TSGString; const VParam:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function WithParam(const VAditionalParams : TSGString; const VParam, VValue:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function DelParam(const VAditionalParams : TSGString; const VParam:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetParam(const VAditionalParams : TSGString; const VParam:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ConqutinateParam(const VAditionalParams : TSGString; const VParam, VConqutinateValue:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		function WithComandShift(const VAditionalParams : TSGString; const VShift:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetComandShift(const VAditionalParams : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property FileName : TSGString write FFileName;
		property FileParams : TSGShaderParams write FFileParams;
		end;

function SGCreateShaderProgramFromSources(const Context : ISGContext;const VVertexSource, VFragmentSource : TSGString): TSGShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSaveShaderSourceToFile(const VFileName, VSource : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadShaderSourceFromFile(const VFileName : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGReadShaderSourceFromFile(const VFileName : TSGString; const VFileParams : TSGShaderParams):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGReadShaderSourceFromFile(const VFileName : TSGString; const VFileParams : array of const ):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSGString; const VFileParams : TSGShaderParams);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSGString; const VFileParams : array of const );{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeStringUtils
	,SaGeLog
	;

procedure SGReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSGString; const VFileParams : TSGShaderParams);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SGSaveShaderSourceToFile(VOutFileName,SGReadShaderSourceFromFile(VInFileName,VFileParams));
end;

procedure SGReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSGString; const VFileParams : array of const );{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SGSaveShaderSourceToFile(VOutFileName,SGReadShaderSourceFromFile(VInFileName,VFileParams));
end;

function SGReadShaderSourceFromFile(const VFileName : TSGString; const VFileParams : array of const):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	FileParams : TSGShaderParams;
begin
Result:='';
FileParams := SGArConstToArString(VFileParams);
Result := SGReadShaderSourceFromFile(VFileName,FileParams);
SetLength(FileParams,0);
end;

function TSGShaderReader.DelParam(const VAditionalParams : TSGString; const VParam:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
	S, P : TSGString;
begin
Result := '';
for i := 1 to StringWordCount(VAditionalParams,',') do
	begin
	S := StringWordGet(VAditionalParams,',',i);
	P := StringWordGet(S,'=',1);
	if P <> VParam then
		begin
		if Result <> '' then
			Result += ',';
		Result += S;
		end;
	end;
end;

function TSGShaderReader.GetParam(const VAditionalParams : TSGString; const VParam:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
	S, P : TSGString;
	Pattern : TSGBoolean;
begin
Result := '';
for i := 1 to StringWordCount(VAditionalParams,',') do
	begin
	S := StringWordGet(VAditionalParams,',',i);
	Pattern := StringMatching(S,'*=*');
	P := StringWordGet(S,'=',1);
	if (not Pattern) and (P=VParam) then
		begin
		Result := '1';
		break;
		end
	else if (Pattern) and (P=VParam) then
		begin
		Result := StringWordGet(S,'=',2);
		break;
		end;
	end;
end;

function TSGShaderReader.WithComandShift(const VAditionalParams : TSGString; const VShift:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:= WithParam(VAditionalParams, 'ComandShift', SGStringReplace(SGStringReplace(GetComandShift(VAditionalParams) + VShift,' ','S'),'	','T'));
end;

function TSGShaderReader.GetComandShift(const VAditionalParams : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGStringReplace(SGStringReplace(GetParam(VAditionalParams,'ComandShift'),'S',' '),'T','	');
end;

function TSGShaderReader.ConqutinateParam(const VAditionalParams : TSGString; const VParam, VConqutinateValue:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := WithParam(VAditionalParams,VParam,GetParam(VAditionalParams,VParam) + VConqutinateValue);
end;

function TSGShaderReader.WithParam(const VAditionalParams : TSGString; const VParam, VValue:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := WithParam(VAditionalParams,VParam + '=' + VValue);
end;

function TSGShaderReader.WithParam(const VAditionalParams : TSGString; const VParam:TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DelParam(VAditionalParams,VParam);
if Result <> '' then
	Result += ',';
Result += VParam;
end;

constructor TSGShaderReader.Create();
begin
FStandartParams := nil;
end;

destructor TSGShaderReader.Destroy();
begin
SetLength(FStandartParams,0);
SetLength(FFileParams,0);
inherited;
end;

procedure SGSaveShaderSourceToFile(const VFileName, VSource : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	f : TextFile;
begin
Assign(f, VFileName);
Rewrite(f);
Write(f,VSource);
Close(f);
end;

function TSGShaderProgram.GetUniformLocation(const VLocationName : TSGString): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	c : PChar;
begin
c := SGStringToPChar(VLocationName);
Result := Render.GetUniformLocation(FProgram,c);
FreeMem(c,Length(VLocationName));
end;

function TSGShaderProgram.GetUniformLocation(const VLocationName : PChar): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := Render.GetUniformLocation(FProgram,VLocationName);
end;

function SGCreateShaderProgramFromSources(const Context : ISGContext;const VVertexSource, VFragmentSource : TSGString): TSGShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	FFragmentShader, FVertexShader : TSGShader;
begin
FVertexShader := TSGShader.Create(Context,SGR_VERTEX_SHADER);
FVertexShader.Source(VVertexSource);
if not FVertexShader.Compile() then
	FVertexShader.PrintInfoLog();

FFragmentShader := TSGShader.Create(Context,SGR_FRAGMENT_SHADER);
FFragmentShader.Source(VFragmentSource);
if not FFragmentShader.Compile() then
	FFragmentShader.PrintInfoLog();

Result := TSGShaderProgram.Create(Context);
Result.Attach(FVertexShader);
Result.Attach(FFragmentShader);
if not Result.Link() then
	Result.PrintInfoLog();
end;

function SGReadShaderSourceFromFile(const VFileName : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	VFileParams : TSGShaderParams;
begin
Result := SGReadShaderSourceFromFile(VFileName,VFileParams);
end;

function SGReadShaderSourceFromFile(const VFileName : TSGString; const VFileParams : TSGShaderParams):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Reader : TSGShaderReader = nil;
begin
Reader := TSGShaderReader.Create();
Reader.FileName := VFileName;
Reader.FileParams := VFileParams;
Result := Reader.Process();
Reader.Destroy();
end;

function TSGShaderReader.ProcessStrings(VString : TSGString;const VAditionalParams : TSGString = ''):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TMemoryStream;
	S : TSGString;
begin
Result := '';
Stream := TMemoryStream.Create();
Stream.WriteBuffer(VString[1],Length(VString));
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	S := SGReadLnStringFromStream(Stream);
	if Stream.Position = Stream.Size then
		Result += ProcessCustomString(S,Stream,VAditionalParams,False)
	else
		Result += ProcessCustomString(S,Stream,VAditionalParams,True);
	end;
Stream.Destroy();
end;

function TSGShaderReader.IdentifierValue(VString : TSGString;const VAditionalParams : TSGString = ''):TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii : TSGLongWord;
	S : TSGString;
begin
Result := VString;
if (Length(VString)>5) then
	begin
	VString := StringTrimAll(VString,' 	');
	VString := StringTrimAll(VString,'/');
	VString := StringTrimAll(VString,'*');
	VString := StringTrimLeft(VString,'#');
	VString := StringTrimAll(VString,' 	');
	i := SGVal(VString);
	if (i<>0) or ((i=0) and (StringTrimAll(VString,'0') = '')) then
		begin
		if (FFileParams = nil) or (Length(FFileParams)<i+1) then
			begin
			if (FStandartParams<>nil) and (Length(FStandartParams)>0) then
				for ii := 0 to High(FStandartParams) do
					if FStandartParams[ii].FNumber = i then
						begin
						Result := FStandartParams[ii].FParam;
						break;
						end;
			end
		else
			Result := FFileParams[i];
		end
	else if 'RI' = SGUpCaseString(VString) then
		begin
		Result := 'RandomIdentifier_';
		for i := 0 to random(10)+5 do
			begin
			ii := Random(3);
			if ii = 0 then
				Result += Char(Random(26)+Byte('a'))
			else if ii = 1 then
				Result += Char(Random(26)+Byte('A'))
			else
				Result += Char(Random(10)+Byte('0'));
			end;
		end
	else if SGUpCaseString(VString) = 'EOLN' then
		begin
		Result := SGWinEoln;
		end
	else if SGUpCaseString(VString) = 'NOTHINK' then
		begin
		Result := '';
		end
	else
		begin
		iii := StringWordCount(VAditionalParams,',');
		if iii <> 0 then
			begin
			ii := 1;
			while (ii <= iii) do
				begin
				S := StringWordGet(VAditionalParams,',',ii);
				S := StringTrimAll(S,' 	');
				i := StringWordCount(S,'=');
				if i = 2 then
					begin
					if StringTrimAll(StringWordGet(S,'=',1),' 	') = VString then
						begin
						Result := StringTrimAll(StringWordGet(S,'=',2),' 	');
						break;
						end;
					end
				else
					begin
					end;
				ii += 1;
				end;
			end;
		end;
	end;
end;

function TSGShaderReader.ProcessString(const VString : TSGString;const VAditionalParams : TSGString = ''):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSGLongWord;
	S : TSGString;
begin
Result := '';
i := 1;
while i <= Length(VString) do
	begin
	if (VString[i]='/') and (i + 5 <= Length(VString)) and (VString[i+1]='*')and (VString[i+2]='#') then
		begin
		S := '/*#';
		ii := i+3;
		while (VString[ii] <> '*') and (VString[ii]<>'/') and (i <= Length(VString)) do
			begin
			S += VString[ii];
			ii += 1;
			end;
		if (VString[ii]='*') and (i+1<=Length(VString)) and (VString[ii+1]='/') then
			begin
			i := ii + 2;
			S += '*/';
			Result += IdentifierValue(S,VAditionalParams);
			end
		else
			begin
			Result += S;
			i := ii;
			end;
		end
	else
		begin
		Result += VString[i];
		i += 1;
		end;
	end;
end;

function TSGShaderReader.ProcessFor(const VVariable : TSGString; const VBegin, VEnd : TSGLongInt; const VString : TSGString;const NeedEolns : TSGBoolean = False;const VAditionalParams : TSGString = ''):TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongInt;
	S : TSGString;
begin
Result := '';
if VString <> '' then
	for i := VBegin to VEnd do
		begin
		S := ProcessStrings(VString,WithParam(VAditionalParams,VVariable,SGStr(i)));
		Result += S;
		if NeedEolns and (i <> VEnd) and (S <> SGWinEoln) then
			Result += SGWinEoln;
		end;
end;

function TSGShaderReader.ProcessComand(const VComand : TSGString; VParams : TSGShaderParams;const Stream : TMemoryStream;const VAditionalParams : TSGString = ''):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii : LongWord;
	S, S1, S2, C, CS : TSGString;
	CH : TSGChar;
	Params : TSGShaderParams;
begin
Result := '';
if VComand='IF' then
	begin
	S := '';
	iii := 0;
	if (VParams<>nil) and (Length(VParams)>0) then
		for i := 0 to High(VParams) do
			begin
			if i <> 0 then
				S += ' ';
			S += VParams[i];
			end;
	S := ProcessString(S, VAditionalParams);
	if StringWordCount(S,'==') = 2 then
		begin
		iii := Byte((StringTrimAll(StringWordGet(S,'==',1),' 	') = StringTrimAll(StringWordGet(S,'==',2),' 	')) and (StringTrimAll(StringWordGet(S,'==',1),' 	') <> ''));
		end
	else
		begin
		//TODO
		end;
	S := ''; S1 := ''; S2 := '';
	ii := 1;
	i := 1;
	while i <> 0 do
		begin
		S := SGReadLnStringFromStream(Stream);
		C := SGUpCaseString(FindComand(S,Params,CS));
		if C = 'IF' then
			i += 1
		else if C = 'ENDIF' then
			i -= 1;
		if (C='ELSE') and (i = 1) then
			ii := byte(not(boolean(ii)));
		if (C = '') or ((C <> '') and (
			(((C='IF') or (C='ENDIF')) and (i>=1)) or
			((C='ELSE') and (i>=2))
			)) then
			begin
			if ii = 1 then
				S1 += S
			else
				S2 += S;
			end;
		end;
	if boolean(iii) then
		begin
		if S1 <> '' then
			Result := ProcessStrings(S1,VAditionalParams);
		end
	else
		begin
		if S2 <> '' then
			Result := ProcessStrings(S2,VAditionalParams);
		end;
	end
else if VComand='FOR' then
	begin
	if (VParams=nil) or (Length(VParams)<3) then
		begin
		S := FFileName+'(for) Error: Syntax error count of params';
		{$IFNDEF RELEASE}
			WriteLn(S);
			{$ENDIF}
		SGLog.Source(S);
		S := '';
		end
	else
		begin
		S := '';
		if Length(VParams)>3 then
			for i := 3 to High(VParams) do
				begin
				if i <> 3 then
					S += ' ';
				S += VParams[i];
				end;
		iii := 0;
		if S <> '' then
			for i := 1 to Length(S) do
				if S[i] = '{' then
					iii += 1
				else if S[i] = '}' then
					iii -= 1;
		if (Length(S)>0) and (S[Length(S)] <> '}') then
			S += SGWinEoln;
		while (iii > 0) and (FStream.Position <> FStream.Size) do
			begin
			FStream.ReadBuffer(CH,1);
			if CH = '{' then
				iii += 1
			else if CH = '}' then
				iii -= 1;
			S += CH;
			end;
		ii := 0;
		if Length(S)>=2 then
			begin
			if (S[1] = '{') and (S[Length(S)] = '}') then
				begin
				S1 := '';
				for i := 2 to Length(S)-1 do
					S1 += S[i];
				S := S1;
				ii += 1;
				end;
			end;
		Result += ProcessFor(
			VParams[0],
			SGVal(SGCalculateExpression(ProcessString(VParams[1],VAditionalParams))),
			SGVal(SGCalculateExpression(ProcessString(VParams[2],VAditionalParams))),
			S,
			ii = 0,
			VAditionalParams);
		end;
	end
else if (VComand = SGUpCaseString('standartparam')) or (VComand='SP') then
	begin
	i := 0;
	if FStandartParams <> nil then
		i := Length(FStandartParams);
	SetLength(FStandartParams, i + 1);
	FStandartParams[High(FStandartParams)].FNumber := SGVal(SGCalculateExpression(ProcessString(VParams[0])));
	FStandartParams[High(FStandartParams)].FParam  := SGCalculateExpression(ProcessString(VParams[1]));
	end
else if (VComand='I') or (VComand='INC') or (VComand='INCLUDE') then
	begin
	S := '';
	if (VParams<> nil) and (Length(VParams)>0) then
		begin
		if (SGResourceFiles.FileExists(SGGetFileWay(FFileName) + VParams[0])) then
			S := SGGetFileWay(FFileName) + VParams[0]
		else if SGResourceFiles.FileExists(VParams[0]) then
			S := VParams[0]
		else
			begin
			S := FFileName+'(include) Error: Syntax error, filename expected but "identifier '+SGUpCaseString(VParams[0])+'" found';
			{$IFNDEF RELEASE}
				WriteLn(S);
				{$ENDIF}
			SGLog.Source(S);
			S := '';
			end;
		end
	else
		begin
		S := FFileName+'(include) Error: Syntax error, filename expected but nothink found';
		{$IFNDEF RELEASE}
			WriteLn(S);
			{$ENDIF}
		SGLog.Source(S);
		S := '';
		end;
	if SGResourceFiles.FileExists(S) then
		begin
		if (VParams <> nil) and (Length(VParams)>1) then
			for i := 1 to High(VParams) do
				VParams[i-1] := ProcessString(VParams[i],VAditionalParams);
		if (VParams <> nil) and (Length(VParams)>0) then
			SetLength(VParams,Length(VParams)-1);
		Result += SGReadShaderSourceFromFile(S,VParams);
		end
	else
		begin
		S := FFileName+'(include) Fatal: Filename don''t found';
		{$IFNDEF RELEASE}
			WriteLn(S);
			{$ENDIF}
		SGLog.Source(S);
		S := '';
		end;
	end
else
	begin
	Result += '#' + SGDownCaseString(VComand);
	if (VParams <> nil) and (Length(VParams)<>0) then
		for i := 0 to High(VParams) do
			Result += ' ' + VParams[i];
	end;
end;

function TSGShaderReader.FindComand(VString : TSGString; out VParams : TSGShaderParams; out ComandShift : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function IsBadSimbol(const Simbol : TSGChar):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Simbol = ' ') or (Simbol = '	') or (Simbol = #27) or (Simbol = #13) or (Simbol = #10) or (Simbol = #0);
end;

function ReadParam(var i : TSGLongWord):TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
while (not IsBadSimbol(VString[i])) and (Length(VString)>=i) do
	begin
	Result += VString[i];
	i += 1;
	end;
end;

procedure FindParams(var i : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(VParams,0);
while i <= Length(VString) do
	begin
	while IsBadSimbol(VString[i]) and (Length(VString)>=i) do
		i += 1;
	if Length(VString)>=i then
		begin
		SetLength(VParams,Length(VParams)+1);
		VParams[High(VParams)] := ReadParam(i);
		end;
	end;
end;

var
	i : TSGLongWord;

begin
Result := '';
ComandShift := '';
i := 1;
while (i <= Length(VString)) and (VString[i] <> '#') do
	begin
	ComandShift += VString[i];
	i += 1;
	end;
VString := StringTrimLeft(VString,' 	');
if Length(VString)>=2 then
	if VString[1] = '#' then
		begin
		i := 2;
		Result := ReadParam(i);
		FindParams(i);
		end
	else
		ComandShift := ''
else
	ComandShift := '';
end;

function TSGShaderReader.ProcessCustomString(const S : TSGString; const Stream : TMemoryStream;const VAditionalParams : TSGString = '';const UseEoln : TSGBoolean = True):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C, S1, CS : TSGString;
	Params : TSGShaderParams;
begin
Result := '';
C := FindComand(S,Params,CS);
if C='' then
	begin
	S1 := ProcessString(S,VAditionalParams);
	S1 := GetComandShift(VAditionalParams) + S1;
	if StringTrimAll(S1,' 	') <> '' then
		begin
		Result += S1;
		if UseEoln and (StringTrimAll(S1,' 	') <> SGWinEoln) then
			Result += SGWinEoln;
		end;
	end
else
	begin
	S1 := ProcessComand(SGUpCaseString(C),Params,Stream,WithComandShift(VAditionalParams,CS));
	if StringTrimAll(S1,' 	') <> '' then
		Result += S1;
	if (StringTrimAll(S1,' 	') <> '') and UseEoln and (S1 <> SGWinEoln) then
		Result += SGWinEoln;
	SetLength(Params,0);
	end;
end;

function TSGShaderReader.Process():TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
FStream := TMemoryStream.Create();
if SGResourceFiles.LoadMemoryStreamFromFile(FStream,FFileName) then
	begin
	FStream.Position := 0;
	while FStream.Position <> FStream.Size do
		Result += ProcessCustomString(SGReadLnStringFromStream(FStream),FStream);
	end;
FStream.Destroy();
end;

procedure TSGShaderProgram.Use();
begin
Render.UseProgram(Handle);
end;

constructor TSGShaderProgram.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FProgram:=Render.CreateShaderProgram();
FShaders:=nil;
end;

procedure TSGShaderProgram.Attach(const NewShader:TSGShader);
begin
if FShaders=nil then
	SetLength(FShaders,1)
else
	SetLength(FShaders,Length(FShaders)+1);
FShaders[High(FShaders)]:=NewShader;
Render.AttachShader(FProgram,NewShader.Shader);
end;

procedure TSGShaderProgram.PrintInfoLog();
var
	MaxLength, Length: Integer;
	InfoLog: array of Char;
	i : LongInt;
	Log : String = '';
begin
Render.GetObjectParameteriv(FProgram, SGR_OBJECT_INFO_LOG_LENGTH_ARB, @MaxLength);
if MaxLength > 1 then
	begin
	Length := MaxLength;
	SetLength(InfoLog, MaxLength);
	Render.GetInfoLog(FProgram, MaxLength, Length, @infolog[0]);
	for i := 0 to High(InfoLog) do
		if (InfoLog[i] = #13) then
			Log += '/n'
		else if (InfoLog[i] <> #10) then
			Log += InfoLog[i];
	SGLog.Source('TSGShaderProgram.PrintInfoLog : Program="'+SGStr(FProgram)+'", Log="'+Log+'".');
	SetLength(InfoLog, 0);
	end;
end;

function TSGShaderProgram.Link():Boolean;
var
	linked : integer;
begin
Render.LinkShaderProgram(FProgram);
Render.GetObjectParameteriv(FProgram, SGR_OBJECT_LINK_STATUS_ARB, @linked);
Result := linked = SGR_TRUE;
{$IFDEF SG_BASE_DEBUG_SHADERS}
	SGLog.Source('TSGShaderProgram.Link : Program="'+SGStr(FProgram)+'", Result="'+SGStr(Result)+'".');
	{$ENDIF}
end;

destructor TSGShaderProgram.Destroy;
var
	i:LongWord;
begin
if FShaders<>nil then
	begin
	for i:=0 to High(FShaders) do
		FShaders[i].Destroy;
	SetLength(FShaders,0);
	end;
if RenderAssigned() then
	Render.DeleteShaderProgram(FProgram);
inherited;
end;

procedure TSGShader.PrintInfoLog;
var
	InfoLogLength:LongInt = 0;
	InfoLog:PChar = nil;
	CharsWritten:LongInt  = 0;
begin
Render.GetObjectParameteriv(FShader, SGR_INFO_LOG_LENGTH,@InfoLogLength);
if InfoLogLength>0 then
	begin
	GetMem(InfoLog,InfoLogLength);
	Render.GetInfoLog(FShader, InfoLogLength, CharsWritten, InfoLog);
	SGLog.Source('TSGShader.PrintInfoLog : "'+SGPCharToString(InfoLog)+'".');
	FreeMem(InfoLog,InfoLogLength);
	end;
end;
procedure TSGShader.Source(const s:string);
var
	pc:PChar = nil;
begin
{$IFDEF SG_DEBUG_SHADERS}
SGLog.Source('TSGShader.Source : Begin to Source shader "'+SGStr(FShader)+'"');// : "'+s+'"');
{$ENDIF}
pc:=SGStringToPChar(s);
Render.ShaderSource(FShader,pc,SGPCharLength(pc));
{$IFDEF SG_DEBUG_SHADERS}
SGLog.Source('TSGShader.Source : Shader Sourced "'+SGStr(FShader)+'"');
{$ENDIF}
FreeMem(pc);
end;

function TSGShader.Compile():Boolean;inline;
var
	compiled : integer;
begin
Result := False;
Render.CompileShader(FShader);
Render.GetObjectParameteriv(FShader, SGR_OBJECT_COMPILE_STATUS_ARB, @compiled);
Result := compiled = SGR_TRUE;
{$IFDEF SG_BASE_DEBUG_SHADERS}
	SGLog.Source('TSGShader.Compile : Shader="'+SGStr(FShader)+'", Result="'+SGStr(Result)+'", Type="'+StringType()+'"');
	{$ENDIF}
end;

function TSGShader.StringType() : TSGString;
begin
if FType=SGR_VERTEX_SHADER then
	Result:='SGR_VERTEX_SHADER'
else if FType=SGR_FRAGMENT_SHADER then
	Result:='SGR_FRAGMENT_SHADER'
else
	Result:='UNKNOWN';
end;

constructor TSGShader.Create(const VContext : ISGContext;const ShaderType:LongWord = SGR_VERTEX_SHADER);
begin
inherited Create(VContext);
if Render.SupporedShaders() then
	begin
	FShader:=Render.CreateShader(ShaderType);
	end
else
	begin
	SGLog.Source('TSGShader.Create : Fatal error : Shaders not suppored!');
	end;
FType:=ShaderType;
{$IFDEF SG_DEBUG_SHADERS}
	SGLog.Source('TSGShader.Create : Create Shader "'+SGStr(FShader)+'" as "'+StringType()+'"');
	{$ENDIF}
end;

destructor TSGShader.Destroy;
begin
if RenderAssigned() then
	Render.DeleteShader(FShader);
FType:=0;
inherited;
end;

end.
