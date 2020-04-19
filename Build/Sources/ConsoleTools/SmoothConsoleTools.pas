{$INCLUDE Smooth.inc}

unit SmoothConsoleTools;

interface

uses
	 SmoothBase
	,SmoothConsoleHandler
	;

procedure SConsoleFPCTCTransliater(const VParams : TSConsoleHandlerParams = nil);

procedure SConsoleRunConsole(const VParams : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SExecuteConsoleHandler(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SMainConsoleHandler() : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SConsoleToolsConsoleHandler()   : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SBuildConsoleHandler()   : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SApplicationsConsoleHandler() : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SHttpConsoleHandler()    : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SUdpConsoleHandler()     : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SInternetConsoleHandler() : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	// Engine includes
	 SmoothVersion
	,SmoothFPCToC
	
	// Aditional console tool includes
	,SmoothConsoleEngineTools
	,SmoothConsolePaintableTools
	,SmoothConsoleMathTools
	,SmoothConsoleImageTools
	,SmoothConsoleBuildTools
	,SmoothConsoleInternetTools
	,SmoothConsoleShaderTools
	,SmoothConsoleHashTools
	
	// Aditional console program includes
	,SmoothConsoleProgramSearchInSources
	,SmoothConsoleProgramGoogleReNameCache
	,SmoothConsoleProgramDynamicHeadersMaker
	//,SmoothConsoleProgramUSMBIO ("deprecated")
	,SmoothConsoleProgramEngineRenamer
	;

var
	MainConsoleHandler : TSConsoleHandler = nil;
	ConsoleToolsConsoleHandler   : TSConsoleHandler = nil;
	BuildConsoleHandler   : TSConsoleHandler = nil;
	ApplicationsConsoleHandler   : TSConsoleHandler = nil;
	HttpConsoleHandler    : TSConsoleHandler = nil;
	UdpConsoleHandler     : TSConsoleHandler = nil;
	InternetConsoleHandler :  TSConsoleHandler = nil;

procedure SConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
MainConsoleHandler.Params := VParams;
MainConsoleHandler.Execute();
end;

procedure SExecuteConsoleHandler();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSConsoleHandlerParams;
begin
Params := SSystemParamsToConsoleHandlerParams();
SConsoleHandler(Params);
SetLength(Params, 0);
end;

procedure SConsoleRunConsole(const VParams : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSConsoleHandlerParams = nil;
begin
Params := SParseStringToConsoleHandlerParams(VParams);
SConsoleHandler(Params);
SetLength(Params, 0);
end;

procedure SConsoleFPCTCTransliater(const VParams : TSConsoleHandlerParams = nil);
var
	ST : STranslater = nil;
begin
SPrintEngineVersion();
ST := STranslater.Create('cmd');
ST.Params := VParams;
ST.GoTranslate();
ST.Destroy();
end;

//============================
(*============Udp===========*)
//============================

procedure RunUdpConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
UdpConsoleHandler.Params := VParams;
UdpConsoleHandler.Execute();
end;

procedure InitUdpConsoleHandler();
begin
if UdpConsoleHandler <> nil then
	exit;
UdpConsoleHandler := TSConsoleHandler.Create(nil);
UdpConsoleHandler.Category('UDP tools');
UdpConsoleHandler.AddComand(@SConsoleNetServer, ['Server'], 'Run server');
UdpConsoleHandler.AddComand(@SConsoleNetClient, ['Connect'], 'Connect to server');
end;

//============================
(*============Http===========*)
//============================

procedure RunHttpConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
HttpConsoleHandler.Params := VParams;
HttpConsoleHandler.Execute();
end;

procedure InitHttpConsoleHandler();
begin
if HttpConsoleHandler <> nil then
	Exit;
HttpConsoleHandler := TSConsoleHandler.Create(nil);
HttpConsoleHandler.Category('HTTP tools');
HttpConsoleHandler.AddComand(@SConsoleHTTPGet,  ['get'], 'GET Method');
end;

//=================================
(*=============Internet===========*)
//=================================

procedure RunInternetConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InternetConsoleHandler.Params := VParams;
InternetConsoleHandler.Execute();
end;

procedure InitInternetConsoleHandler();
begin
if InternetConsoleHandler <> nil then
	Exit;
InternetConsoleHandler := TSConsoleHandler.Create(nil);
InternetConsoleHandler.Category('Internet tools');
InternetConsoleHandler.AddComand(@RunHttpConsoleHandler, ['Http'], 'HTTP tools');
InternetConsoleHandler.AddComand(@RunUdpConsoleHandler, ['Udp'], 'UDP tools');
InternetConsoleHandler.AddComand(@SConsoleInternetPacketRuntimeDumper, ['ipd', 'iprd'], 'Internet Packet Runtime Dumper');
InternetConsoleHandler.AddComand(@SConsoleDescriptPCapNG, ['dpcapng'], 'Descript PCapNG file');
InternetConsoleHandler.AddComand(@SConsoleConnectionsCaptor, ['cc'], 'Connections captor');
end;

//============================
(*=====BuildConsoleHandler====*)
//============================

procedure RunBuildConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
BuildConsoleHandler.Params := VParams;
BuildConsoleHandler.Execute();
end;

procedure InitBuildConsoleHandler();
begin
if BuildConsoleHandler <> nil then
	Exit;
BuildConsoleHandler := TSConsoleHandler.Create(nil);
BuildConsoleHandler.Category('Build tools');
BuildConsoleHandler.AddComand(@SConsoleBuild, ['BUILD'], 'Building Smooth Engine');
BuildConsoleHandler.AddComand(@SConsoleClearFileRegistrationResources, ['Cfrr'], 'Clear File Registration Resources');
BuildConsoleHandler.AddComand(@SConsoleClearFileForRegistrationExtensions, ['Cffre'], 'Clear File For Registration Extensions');
BuildConsoleHandler.AddComand(@SConsoleConvertFileToPascalUnitAndRegisterUnit, ['CFTPUARU'], 'Convert File To Pascal Unit And Register Unit in registration file');
BuildConsoleHandler.AddComand(@SConsoleConvertCachedFileToPascalUnitAndRegisterUnit, ['CCFTPUARU'], 'Convert Cached File To Pascal Unit And Register Unit in registration file');
BuildConsoleHandler.AddComand(@SConsoleIncEngineVersion, ['IV'], 'Increment engine Version');
BuildConsoleHandler.AddComand(@SConsoleBuildFiles, ['BF'], 'Build files in datafile');
BuildConsoleHandler.AddComand(@SConsoleDefineSkiper, ['ds'], 'Tool to skip defines in file');
BuildConsoleHandler.AddComand(@SConsoleVersionTo_RC_WindowsFile, ['vtrc'], 'curent Version To RC windows file');
BuildConsoleHandler.AddComand(@SConsoleIsConsole, ['ic'], 'Return bool value, is console or not');
BuildConsoleHandler.AddComand(@SConsoleConvertFileToPascalUnit, ['CFTPU'], 'Convert File To Pascal Unit utility');
BuildConsoleHandler.AddComand(@SConsoleConvertDirectoryFilesToPascalUnits, ['CDTPUARU'], 'Convert Directory Files To Pascal Units utility');
BuildConsoleHandler.AddComand(@SConsoleAddToLog, ['ATL'], 'Add line To Log');
BuildConsoleHandler.AddComand(@SConsoleOpenLastLog, ['oll'], 'Open Last Log file');
end;

//===================================
(*=====ApplicationsConsoleHandler====*)
//===================================

procedure RunApplicationsConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ApplicationsConsoleHandler.Params := VParams;
ApplicationsConsoleHandler.Execute();
end;

procedure InitApplicationsConsoleHandler();
begin
if ApplicationsConsoleHandler <> nil then
	Exit;
ApplicationsConsoleHandler := TSConsoleHandler.Create(nil);
ApplicationsConsoleHandler.Category('Applications');
ApplicationsConsoleHandler.AddComand(@SConsoleShowAllApplications, ['GUI', ''], 'Shows all 3D/2D scenes');
ApplicationsConsoleHandler.AddComand(@SConsoleDynamicHeadersMaker, ['CHTD', 'DDH'], 'Convert pascal Header to Dynamic utility');
ApplicationsConsoleHandler.AddComand(@SConsoleShaderReadWrite, ['SRW'], 'Read shader file with params and write it as single file without directives');
ApplicationsConsoleHandler.AddComand(@SConsoleHash, ['hash'], 'Hash file (hash directory)');
ApplicationsConsoleHandler.AddComand(@SConsoleSearchInSources, ['SIS'], 'Search in the sources (text files)');
ApplicationsConsoleHandler.AddComand(@SConsoleMake, ['MAKE'], 'Build program from makefile');
end;

//============================
(*=====ConsoleToolsConsoleHandler====*)
//============================

procedure RunConsoleToolsConsoleHandler(const VParams : TSConsoleHandlerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ConsoleToolsConsoleHandler.Params := VParams;
ConsoleToolsConsoleHandler.Execute();
end;

procedure InitConsoleToolsConsoleHandler();
begin
if ConsoleToolsConsoleHandler <> nil then
	Exit;
ConsoleToolsConsoleHandler := TSConsoleHandler.Create(nil);
ConsoleToolsConsoleHandler.Category('Images tools');
ConsoleToolsConsoleHandler.AddComand(@SConsoleImageResizer, ['IR'], 'Resize image');
ConsoleToolsConsoleHandler.AddComand(@SConsoleConvertImageToSmoothImageAlphaFormat, ['CTSIA'], 'Convert image To SmoothImagesAlpha format');
ConsoleToolsConsoleHandler.Category('Math tools');
ConsoleToolsConsoleHandler.AddComand(@SConsoleCalculateExpression, ['ce'], 'Calculate expression');
ConsoleToolsConsoleHandler.AddComand(@SConsoleCalculateBoolTable, ['cbt'], 'Calculate boolean Table');
ConsoleToolsConsoleHandler.Category('Other tools');
ConsoleToolsConsoleHandler.AddComand(@SConsoleGoogleReNameCache, ['grc'], 'Tool for renameing browser cache files');
ConsoleToolsConsoleHandler.AddComand(@SConsoleFPCTCTransliater, ['fpctc'], 'Tool for transliating FPC to C');
end;

//============================
(*===========General=========*)
//============================

procedure InitMainConsoleHandler();
begin
if MainConsoleHandler <> nil then
	Exit;
MainConsoleHandler := TSConsoleHandler.Create(nil);
MainConsoleHandler.AddComand(@SConsoleHandler, ['CONSOLE'], 'Run console caller');
MainConsoleHandler.Category('Applications');
MainConsoleHandler.AddComand(@SConsoleShowAllApplications, ['GUI', ''], 'Shows all 3D/2D scenes');
MainConsoleHandler.Category('Other tools');
MainConsoleHandler.AddComand(@RunInternetConsoleHandler, ['inet'], 'Internet tools');
MainConsoleHandler.AddComand(@RunBuildConsoleHandler, ['bt'], 'Build tools');
MainConsoleHandler.AddComand(@RunApplicationsConsoleHandler, ['app'], 'Applications');
MainConsoleHandler.AddComand(@RunConsoleToolsConsoleHandler, ['oa'], 'Other console programs');
MainConsoleHandler.Category('System tools');
MainConsoleHandler.AddComand(@SConsoleExtractFiles, ['EF'], 'Extract all files in this application');
MainConsoleHandler.AddComand(@SConsoleWriteOpenableExtensions, ['woe'], 'Write all of openable Extensions of files');
MainConsoleHandler.AddComand(@SConsoleWriteFiles, ['WF'], 'Write all files in this application');
MainConsoleHandler.AddComand(@SConsoleDllPrintStat, ['dlps'], 'Prints all statistics data of dynamic libraries, used in this application');
end;

(* == == == == == == == == == == == == == == *)
(* == == == == == == == == == == == == == == *)
(* == == == == == ==GETTERS== == == == == == *)
(* == == == == == == == == == == == == == == *)
(* == == == == == == == == == == == == == == *)

function SApplicationsConsoleHandler()   : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitApplicationsConsoleHandler();
Result := ApplicationsConsoleHandler;
end;

function SBuildConsoleHandler()   : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitBuildConsoleHandler();
Result := BuildConsoleHandler;
end;

function SMainConsoleHandler() : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitMainConsoleHandler();
Result := MainConsoleHandler;
end;

function SConsoleToolsConsoleHandler()   : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitConsoleToolsConsoleHandler();
Result := ConsoleToolsConsoleHandler;
end;

function SHttpConsoleHandler()    : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitHttpConsoleHandler();
Result := HttpConsoleHandler;
end;

function SUdpConsoleHandler()     : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitUdpConsoleHandler();
Result := UdpConsoleHandler;
end;

function SInternetConsoleHandler()     : TSConsoleHandler; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitInternetConsoleHandler();
Result := InternetConsoleHandler;
end;

//============================

procedure InitConsoleHandlers();
begin
InitUdpConsoleHandler();
InitHttpConsoleHandler();
InitInternetConsoleHandler();
InitConsoleToolsConsoleHandler();
InitBuildConsoleHandler();
InitApplicationsConsoleHandler();
InitMainConsoleHandler();
end;

procedure DestroyConsoleHandlers();
begin
SKill(UdpConsoleHandler);
SKill(HttpConsoleHandler);
SKill(InternetConsoleHandler);
SKill(ConsoleToolsConsoleHandler);
SKill(BuildConsoleHandler);
SKill(ApplicationsConsoleHandler);
SKill(MainConsoleHandler);
end;

initialization
begin
InitConsoleHandlers();
end;

finalization
begin
DestroyConsoleHandlers();
end;

end.
