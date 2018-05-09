{$INCLUDE SaGe.inc}

unit SaGeConsoleNetTools;

interface

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleHTTPGet(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleNetServer(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleNetClient(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleInternetPacketDumper(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 StrMan
	,Classes
	
	,SaGeVersion
	,SaGeNet
	,SaGeStringUtils
	,SaGeLog
	,SaGeConsoleUtils
	,SaGeInternetPacketDumper
	,SaGeCasesOfPrint
	;

procedure SGConsoleInternetPacketDumper(const VParams : TSGConcoleCallerParams = nil);
begin
if SGCountConsoleParams(VParams) = 0 then
	begin
	with TSGInternetPacketDumper.Create() do
		begin
		Loop();
		Destroy();
		end;
	end
else
	SGHint('Params are not alowed here!');
end;

procedure SGConsoleNetClient(const VParams : TSGConcoleCallerParams = nil);
var
	URL : TSGString = '';
begin
URL := SGStringFromStringList(VParams, '');
if URL <> '' then
	SGConsoleUDPClient(URL)
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'" @URL ".');
	end;
end;

procedure SGConsoleNetServer(const VParams : TSGConcoleCallerParams = nil);
begin
if (SGCountConsoleParams(VParams) = 1) and (SGVal(VParams[0]) <> 0) then
	begin
	SGConsoleUDPServer(SGVal(VParams[0]));
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'" @port ".');
	end;
end;

procedure SGConsoleHTTPGet(const VParams : TSGConcoleCallerParams = nil);
var
	URL : TSGString = '';
	FileName : TSGString = '';
	UseLibrary : TSGString = 'lNet';
	TimeOut : TSGLongWord = SGDefaultHTTPTimeOut;
	Errors : TSGBool = False;

function Parse() : TSGBoolean;
var
	i : TSGLongWord;
	ParamsCount : TSGLongWord;
	Param : TSGString;
	Comand : TSGString;
begin
i := 0;
ParamsCount := SGCountConsoleParams(VParams);
Result := True;
while i < ParamsCount do
	begin
	Param := VParams[i];
	Comand := '';
	if StringTrimLeft(Param, '-') <> Param then
		Comand := SGUpCaseString(StringTrimLeft(Param, '-'));
	if (Comand = '') and (i = ParamsCount - 1) then
		URL := Param
	else if (Comand <> '') and (i < ParamsCount - 2) then
		begin
		if (Comand = 'O') or (Comand = 'OUT') or (Comand = 'OUTPUT') then
			FileName := VParams[i + 1]
		else if (Comand = 'T') or (Comand = 'TIME') or (Comand = 'TIMEOUT') then
			TimeOut := SGVal(VParams[i + 1])
		else if (Comand = 'L') or (Comand = 'LIB') or (Comand = 'LIBRARY') then
			UseLibrary := VParams[i + 1]
		else
			begin
			Result := False;
			break;
			end;
		i += 1;
		end
	else if (Comand <> '') and (i < ParamsCount - 1) then
		begin
		if (Comand = 'E') or (Comand = 'ERRORS') then
				Errors := True
		else
			begin
			Result := False;
			break;
			end;
		end
	else
		begin
		Result := False;
		break;
		end;
	i += 1;
	end;
end;

function HTTPGet() : TSGBool;
var
	Stream : TMemoryStream = nil;
	CasesOfPrint : TSGCasesOfPrint = [];
begin
if Errors then
	CasesOfPrint := SGCasesOfPrintFull;
if SGCasePrint in CasesOfPrint then
	SGPrintEngineVersion();
Stream := SGHTTPGetMemoryStream(URL, TimeOut, CasesOfPrint);
Result := Stream <> nil;
if Result then
	begin
	if FileName <> '' then
		Stream.SaveToFile(FileName)
	else
		begin
		SGPrintStream(Stream);
		SGLog.Source(Stream);
		end;
	Stream.Destroy();
	end;
end;

begin
if Parse() and (URL <> '') then
	begin
	if not HTTPGet() then
		begin
		SGPrintEngineVersion();
		SGHint('HTTP:GET - Error!', SGCasesOfPrintFull);
		end;
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"[ --e] [ --o @filename] [ --l @library] [ --t @timeout] @URL".');
	end;
end;

end.
