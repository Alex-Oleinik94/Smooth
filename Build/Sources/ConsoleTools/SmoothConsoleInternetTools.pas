{$INCLUDE Smooth.inc}

unit SmoothConsoleInternetTools;

interface

uses
	 SmoothBase
	,SmoothConsoleCaller
	;

procedure SConsoleHTTPGet(const VParams : TSConcoleCallerParams = nil);
procedure SConsoleNetServer(const VParams : TSConcoleCallerParams = nil);
procedure SConsoleNetClient(const VParams : TSConcoleCallerParams = nil);
procedure SConsoleInternetPacketRuntimeDumper(const VParams : TSConcoleCallerParams = nil);
procedure SConsoleDescriptPCapNG(const VParams : TSConcoleCallerParams = nil);
procedure SConsoleConnectionsCaptor(const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 StrMan
	,Classes
	
	,SmoothVersion
	,SmoothStringUtils
	,SmoothLog
	,SmoothConsoleUtils
	,SmoothInternetPacketRuntimeDumper
	,SmoothCasesOfPrint
	,SmoothlNetHTTPUtils
	,SmoothlNetUDPConnection
	,SmoothlNetConnectionClasses
	,SmoothPCapNGUtils
	,SmoothFileUtils
	,SmoothInternetConnectionsCaptor
	;

procedure SConsoleConnectionsCaptor(const VParams : TSConcoleCallerParams = nil);
var
	ModeDataTransfer : TSBoolean = False;
	ModePacketStorage : TSBoolean = False;
	ModeRuntimeDataDumper : TSBoolean = False;
	ModeRuntimePacketDumper : TSBoolean = False;
	LargeStatisticsInformation : TSBool = False;

function ProccessLargeStatisticsInformation(const Comand : TSString):TSBool;
begin
Result := True;
LargeStatisticsInformation := not LargeStatisticsInformation;
end;

function ProccessModeDataTransfer(const Comand : TSString):TSBool;
begin
Result := True;
ModeDataTransfer := not ModeDataTransfer;
end;

function ProccessModePacketStorage(const Comand : TSString):TSBool;
begin
Result := True;
ModePacketStorage := not ModePacketStorage;
end;

function ProccessModeRuntimeDataDumper(const Comand : TSString):TSBool;
begin
Result := True;
ModeRuntimePacketDumper := not ModeRuntimePacketDumper;
end;

function ProccessModeRuntimePacketDumper(const Comand : TSString):TSBool;
begin
Result := True;
ModeDataTransfer := not ModeDataTransfer;
end;

var
	Connections : TSInternetConnectionsCaptor = nil;
	Success : TSBoolean = True;
begin
SPrintEngineVersion();
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSConsoleCaller.Create(VParams) do
		begin
		AddComand(@ProccessLargeStatisticsInformation, ['lsi'],  'Large statistics information');
		Category('Modes');
		AddComand(@ProccessModeDataTransfer,           ['mdt'],  'Enable/disable data transfer mode');
		AddComand(@ProccessModePacketStorage,          ['mps'],  'Enable/disable packet starage mode');
		AddComand(@ProccessModeRuntimeDataDumper,      ['mrdd'], 'Enable/disable runtime data dumping (carefully)');
		AddComand(@ProccessModeRuntimePacketDumper,    ['mrpd'], 'Enable/disable runtime packet dumping (carefully)');
		Success := Execute();
		Destroy();
		end;
if Success then
	begin
	Connections := TSInternetConnectionsCaptor.Create();
	Connections.PossibilityBreakLoopFromConsole := True;
	Connections.ProcessTimeOutUpdates := True;
	Connections.InfoTimeOut := 60;
	Connections.ModeDataTransfer := ModeDataTransfer;
	Connections.ModePacketStorage := ModePacketStorage;
	Connections.ModeRuntimeDataDumper := ModeRuntimeDataDumper;
	Connections.ModeRuntimePacketDumper := ModeRuntimePacketDumper;
	Connections.LargeStatisticsInformation := LargeStatisticsInformation;
	Connections.Loop();
	Connections.LogStatistic();
	SKill(Connections);
	end;
end;

procedure SConsoleDescriptPCapNG(const VParams : TSConcoleCallerParams = nil);
var
	Index : TSMaxEnum;
	AllParamsFileExists : TSBoolean = True;
begin
if (SCountConsoleParams(VParams) > 0) then
	begin
	AllParamsFileExists := True;
	for Index := 0 to High(VParams) do
		if not SFileExists(VParams[Index]) then
			begin
			AllParamsFileExists := False;
			SPrintEngineVersion();
			SHint('Error: File "' + VParams[Index] + '" not exists!');
			end;
	if AllParamsFileExists then
		for Index := 0 to High(VParams) do
			SDescriptPCapNGFile(VParams[Index]);
	end
else
	SHint('Error: Specify PCapNG file(s)!');
end;

procedure SConsoleInternetPacketRuntimeDumper(const VParams : TSConcoleCallerParams = nil);
begin
if SCountConsoleParams(VParams) = 0 then
	begin
	with TSInternetPacketRuntimeDumper.Create() do
		begin
		Loop();
		Destroy();
		end;
	end
else
	SHint('Params are not alowed here!');
end;

procedure SConsoleNetClient(const VParams : TSConcoleCallerParams = nil);
var
	URL : TSString = '';
begin
URL := SStringFromStringList(VParams, '');
if URL <> '' then
	SConsoleUDPClient(URL)
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'" @URL ".');
	end;
end;

procedure SConsoleNetServer(const VParams : TSConcoleCallerParams = nil);
begin
if (SCountConsoleParams(VParams) = 1) and (SVal(VParams[0]) <> 0) then
	begin
	SConsoleUDPServer(SVal(VParams[0]));
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'" @port ".');
	end;
end;

procedure SConsoleHTTPGet(const VParams : TSConcoleCallerParams = nil);
var
	URL : TSString = '';
	FileName : TSString = '';
	UseLibrary : TSString = 'lNet';
	TimeOut : TSLongWord = SDefaultHTTPTimeOut;
	Errors : TSBool = False;

function Parse() : TSBoolean;
var
	i : TSLongWord;
	ParamsCount : TSLongWord;
	Param : TSString;
	Comand : TSString;
begin
i := 0;
ParamsCount := SCountConsoleParams(VParams);
Result := True;
while i < ParamsCount do
	begin
	Param := VParams[i];
	Comand := '';
	if StringTrimLeft(Param, '-') <> Param then
		Comand := SUpCaseString(StringTrimLeft(Param, '-'));
	if (Comand = '') and (i = ParamsCount - 1) then
		URL := Param
	else if (Comand <> '') and (i < ParamsCount - 2) then
		begin
		if (Comand = 'O') or (Comand = 'OUT') or (Comand = 'OUTPUT') then
			FileName := VParams[i + 1]
		else if (Comand = 'T') or (Comand = 'TIME') or (Comand = 'TIMEOUT') then
			TimeOut := SVal(VParams[i + 1])
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

function HTTPGet() : TSBool;
var
	Stream : TMemoryStream = nil;
	CasesOfPrint : TSCasesOfPrint = [];
begin
if Errors then
	CasesOfPrint := SCasesOfPrintFull;
if SCasePrint in CasesOfPrint then
	SPrintEngineVersion();
Stream := SHTTPGetMemoryStream(URL, TimeOut, CasesOfPrint);
Result := Stream <> nil;
if Result then
	begin
	if FileName <> '' then
		Stream.SaveToFile(FileName)
	else
		begin
		SPrintStream(Stream);
		SLog.Source(Stream);
		end;
	Stream.Destroy();
	end;
end;

begin
if Parse() and (URL <> '') then
	begin
	if not HTTPGet() then
		begin
		SPrintEngineVersion();
		SHint('HTTP:GET - Error!', SCasesOfPrintFull);
		end;
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"[ --e] [ --o @filename] [ --l @library] [ --t @timeout] @URL".');
	end;
end;

end.
