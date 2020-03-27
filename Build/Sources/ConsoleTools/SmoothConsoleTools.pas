{$INCLUDE Smooth.inc}

unit SmoothConsoleTools;

interface

uses
	 SmoothBase
	,SmoothConsoleCaller
	;

procedure SConsoleFPCTCTransliater(const VParams : TSConcoleCallerParams = nil);

procedure SConsoleRunConsole(const VParams : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SConcoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGeneralConsoleCaller() : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SOtherConsoleCaller()   : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SBuildConsoleCaller()   : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SApplicationsConsoleCaller() : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SHttpConsoleCaller()    : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SUdpConsoleCaller()     : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SInternetConsoleCaller() : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

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
	,SmoothConsoleProgramFindInSources
	,SmoothConsoleProgramGoogleReNameCache
	,SmoothConsoleProgramDynamicHeadersMaker
	//,SmoothConsoleProgramUSMBIO ("deprecated")
	,SmoothConsoleProgramEngineRenamer
	;

var
	GeneralConsoleCaller : TSConsoleCaller = nil;
	OtherConsoleCaller   : TSConsoleCaller = nil;
	BuildConsoleCaller   : TSConsoleCaller = nil;
	ApplicationsConsoleCaller   : TSConsoleCaller = nil;
	HttpConsoleCaller    : TSConsoleCaller = nil;
	UdpConsoleCaller     : TSConsoleCaller = nil;
	InternetConsoleCaller :  TSConsoleCaller = nil;

procedure SConcoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
GeneralConsoleCaller.Params := VParams;
GeneralConsoleCaller.Execute();
end;

procedure SStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSConcoleCallerParams;
begin
Params := SSystemParamsToConcoleCallerParams();
SConcoleCaller(Params);
SetLength(Params, 0);
end;

procedure SConsoleRunConsole(const VParams : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSConcoleCallerParams = nil;
begin
Params := SParseStringToConsoleCallerParams(VParams);
SConcoleCaller(Params);
SetLength(Params, 0);
end;

procedure SConsoleFPCTCTransliater(const VParams : TSConcoleCallerParams = nil);
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

procedure RunUdpConsoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
UdpConsoleCaller.Params := VParams;
UdpConsoleCaller.Execute();
end;

procedure InitUdpConsoleCaller();
begin
if UdpConsoleCaller <> nil then
	exit;
UdpConsoleCaller := TSConsoleCaller.Create(nil);
UdpConsoleCaller.Category('UDP tools');
UdpConsoleCaller.AddComand(@SConsoleNetServer, ['Server'], 'Run server');
UdpConsoleCaller.AddComand(@SConsoleNetClient, ['Connect'], 'Connect to server');
end;

//============================
(*============Http===========*)
//============================

procedure RunHttpConsoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
HttpConsoleCaller.Params := VParams;
HttpConsoleCaller.Execute();
end;

procedure InitHttpConsoleCaller();
begin
if HttpConsoleCaller <> nil then
	Exit;
HttpConsoleCaller := TSConsoleCaller.Create(nil);
HttpConsoleCaller.Category('HTTP tools');
HttpConsoleCaller.AddComand(@SConsoleHTTPGet,  ['get'], 'GET Method');
end;

//=================================
(*=============Internet===========*)
//=================================

procedure RunInternetConsoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InternetConsoleCaller.Params := VParams;
InternetConsoleCaller.Execute();
end;

procedure InitInternetConsoleCaller();
begin
if InternetConsoleCaller <> nil then
	Exit;
InternetConsoleCaller := TSConsoleCaller.Create(nil);
InternetConsoleCaller.Category('Internet tools');
InternetConsoleCaller.AddComand(@RunHttpConsoleCaller, ['Http'], 'HTTP tools');
InternetConsoleCaller.AddComand(@RunUdpConsoleCaller, ['Udp'], 'UDP tools');
InternetConsoleCaller.AddComand(@SConsoleInternetPacketRuntimeDumper, ['ipd', 'iprd'], 'Internet Packet Runtime Dumper');
InternetConsoleCaller.AddComand(@SConsoleDescriptPCapNG, ['dpcapng'], 'Descript PCapNG file');
InternetConsoleCaller.AddComand(@SConsoleConnectionsCaptor, ['cc'], 'Connections captor');
end;

//============================
(*=====BuildConsoleCaller====*)
//============================

procedure RunBuildConsoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
BuildConsoleCaller.Params := VParams;
BuildConsoleCaller.Execute();
end;

procedure InitBuildConsoleCaller();
begin
if BuildConsoleCaller <> nil then
	Exit;
BuildConsoleCaller := TSConsoleCaller.Create(nil);
BuildConsoleCaller.Category('Build tools');
BuildConsoleCaller.AddComand(@SConsoleBuild, ['BUILD'], 'Building Smooth Engine');
BuildConsoleCaller.AddComand(@SConsoleClearFileRegistrationResources, ['Cfrr'], 'Clear File Registration Resources');
BuildConsoleCaller.AddComand(@SConsoleClearFileForRegistrationExtensions, ['Cffre'], 'Clear File For Registration Extensions');
BuildConsoleCaller.AddComand(@SConsoleConvertFileToPascalUnitAndRegisterUnit, ['CFTPUARU'], 'Convert File To Pascal Unit And Register Unit in registration file');
BuildConsoleCaller.AddComand(@SConsoleConvertCachedFileToPascalUnitAndRegisterUnit, ['CCFTPUARU'], 'Convert Cached File To Pascal Unit And Register Unit in registration file');
BuildConsoleCaller.AddComand(@SConsoleIncEngineVersion, ['IV'], 'Increment engine Version');
BuildConsoleCaller.AddComand(@SConsoleBuildFiles, ['BF'], 'Build files in datafile');
BuildConsoleCaller.AddComand(@SConsoleDefineSkiper, ['ds'], 'Tool to skip defines in file');
BuildConsoleCaller.AddComand(@SConsoleVersionTo_RC_WindowsFile, ['vtrc'], 'curent Version To RC windows file');
BuildConsoleCaller.AddComand(@SConsoleIsConsole, ['ic'], 'Return bool value, is console or not');
BuildConsoleCaller.AddComand(@SConsoleConvertFileToPascalUnit, ['CFTPU'], 'Convert File To Pascal Unit utility');
BuildConsoleCaller.AddComand(@SConsoleConvertDirectoryFilesToPascalUnits, ['CDTPUARU'], 'Convert Directory Files To Pascal Units utility');
BuildConsoleCaller.AddComand(@SConsoleAddToLog, ['ATL'], 'Add line To Log');
BuildConsoleCaller.AddComand(@SConsoleOpenLastLog, ['oll'], 'Open Last Log file');
end;

//===================================
(*=====ApplicationsConsoleCaller====*)
//===================================

procedure RunApplicationsConsoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ApplicationsConsoleCaller.Params := VParams;
ApplicationsConsoleCaller.Execute();
end;

procedure InitApplicationsConsoleCaller();
begin
if ApplicationsConsoleCaller <> nil then
	Exit;
ApplicationsConsoleCaller := TSConsoleCaller.Create(nil);
ApplicationsConsoleCaller.Category('Applications');
ApplicationsConsoleCaller.AddComand(@SConsoleShowAllApplications, ['GUI', ''], 'Shows all 3D/2D scenes');
ApplicationsConsoleCaller.AddComand(@SConsoleDynamicHeadersMaker, ['CHTD', 'DDH'], 'Convert pascal Header to Dynamic utility');
ApplicationsConsoleCaller.AddComand(@SConsoleShaderReadWrite, ['SRW'], 'Read shader file with params and write it as single file without directives');
ApplicationsConsoleCaller.AddComand(@SConsoleHash, ['hash'], 'Hash file or directory');
ApplicationsConsoleCaller.AddComand(@SConsoleFindInSources, ['FIS','SIS'], 'Program for searching in the sources');
ApplicationsConsoleCaller.AddComand(@SConsoleMake, ['MAKE'], 'Make utility');
end;

//============================
(*=====OtherConsoleCaller====*)
//============================

procedure RunOtherConsoleCaller(const VParams : TSConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
OtherConsoleCaller.Params := VParams;
OtherConsoleCaller.Execute();
end;

procedure InitOtherConsoleCaller();
begin
if OtherConsoleCaller <> nil then
	Exit;
OtherConsoleCaller := TSConsoleCaller.Create(nil);
OtherConsoleCaller.Category('Images tools');
OtherConsoleCaller.AddComand(@SConsoleImageResizer, ['IR'], 'Image Resizer');
OtherConsoleCaller.AddComand(@SConsoleConvertImageToSmoothImageAlphaFormat, ['CTSIA'], 'Convert image To SmoothImagesAlpha format');
OtherConsoleCaller.Category('Math tools');
OtherConsoleCaller.AddComand(@SConsoleCalculateExpression, ['ce'], 'Calculate Expression');
OtherConsoleCaller.AddComand(@SConsoleCalculateBoolTable, ['cbt'], 'Calculate Boolean Table');
OtherConsoleCaller.Category('Other tools');
OtherConsoleCaller.AddComand(@SConsoleGoogleReNameCache, ['grc'], 'Tool for renameing browser cache files');
OtherConsoleCaller.AddComand(@SConsoleFPCTCTransliater, ['fpctc'], 'Tool for transliating FPC to C');
end;

//============================
(*===========General=========*)
//============================

procedure InitGeneralConsoleCaller();
begin
if GeneralConsoleCaller <> nil then
	Exit;
GeneralConsoleCaller := TSConsoleCaller.Create(nil);
GeneralConsoleCaller.AddComand(@SConcoleCaller, ['CONSOLE'], 'Run console caller');
GeneralConsoleCaller.Category('Applications');
GeneralConsoleCaller.AddComand(@SConsoleShowAllApplications, ['GUI', ''], 'Shows all 3D/2D scenes');
GeneralConsoleCaller.Category('Other tools');
GeneralConsoleCaller.AddComand(@RunInternetConsoleCaller, ['inet'], 'Internet tools');
GeneralConsoleCaller.AddComand(@RunOtherConsoleCaller, ['oa'], 'Other Engine''s Console Programs');
GeneralConsoleCaller.AddComand(@RunBuildConsoleCaller, ['bt'], 'Build tools');
GeneralConsoleCaller.AddComand(@RunApplicationsConsoleCaller, ['app'], 'Applications');
GeneralConsoleCaller.Category('System tools');
GeneralConsoleCaller.AddComand(@SConsoleExtractFiles, ['EF'], 'Extract all files in this application');
GeneralConsoleCaller.AddComand(@SConsoleWriteOpenableExpansions, ['woe'], 'Write all of openable expansions of files');
GeneralConsoleCaller.AddComand(@SConsoleWriteFiles, ['WF'], 'Write all files in this application');
GeneralConsoleCaller.AddComand(@SConsoleDllPrintStat, ['dlps'], 'Prints all statistics data of dynamic libraries, used in this application');
end;

(* == == == == == == == == == == == == == == *)
(* == == == == == == == == == == == == == == *)
(* == == == == == ==GETTERS== == == == == == *)
(* == == == == == == == == == == == == == == *)
(* == == == == == == == == == == == == == == *)

function SApplicationsConsoleCaller()   : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitApplicationsConsoleCaller();
Result := ApplicationsConsoleCaller;
end;

function SBuildConsoleCaller()   : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitBuildConsoleCaller();
Result := BuildConsoleCaller;
end;

function SGeneralConsoleCaller() : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitGeneralConsoleCaller();
Result := GeneralConsoleCaller;
end;

function SOtherConsoleCaller()   : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitOtherConsoleCaller();
Result := OtherConsoleCaller;
end;

function SHttpConsoleCaller()    : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitHttpConsoleCaller();
Result := HttpConsoleCaller;
end;

function SUdpConsoleCaller()     : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitUdpConsoleCaller();
Result := UdpConsoleCaller;
end;

function SInternetConsoleCaller()     : TSConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitInternetConsoleCaller();
Result := InternetConsoleCaller;
end;

//============================

procedure InitConsoleCallers();
begin
InitUdpConsoleCaller();
InitHttpConsoleCaller();
InitInternetConsoleCaller();
InitOtherConsoleCaller();
InitBuildConsoleCaller();
InitApplicationsConsoleCaller();
InitGeneralConsoleCaller();
end;

procedure DestroyConsoleCallers();
begin
SKill(UdpConsoleCaller);
SKill(HttpConsoleCaller);
SKill(InternetConsoleCaller);
SKill(OtherConsoleCaller);
SKill(BuildConsoleCaller);
SKill(ApplicationsConsoleCaller);
SKill(GeneralConsoleCaller);
end;

initialization
begin
InitConsoleCallers();
end;

finalization
begin
DestroyConsoleCallers();
end;

end.
