{$INCLUDE SaGe.inc}

unit SaGeConsoleTools;

interface

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleFPCTCTransliater(const VParams : TSGConcoleCallerParams = nil);

procedure SGConsoleRunConsole(const VParams : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGGeneralConsoleCaller() : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGOtherConsoleCaller()   : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGBuildConsoleCaller()   : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGApplicationsConsoleCaller() : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGHttpConsoleCaller()    : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGUdpConsoleCaller()     : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGNetConsoleCaller()     : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	// Engine includes
	 SaGeVersion
	,SaGeFPCToC
	
	// Aditional console tool includes
	,SaGeConsoleEngineTools
	,SaGeConsolePaintableTools
	,SaGeConsoleMathTools
	,SaGeConsoleImageTools
	,SaGeConsoleBuildTools
	,SaGeConsoleNetTools
	,SaGeConsoleShaderTools
	,SaGeConsoleHashTools
	
	// Aditional console program includes
	,SaGeConsoleProgramFindInPas
	,SaGeConsoleProgramGoogleReNameCache
	,SaGeConsoleProgramConvertHeaderToDynamic
	,SaGeConsoleProgramUSMBIOS
	,SaGeConsoleProgramEngineRenamer
	;

var
	GeneralConsoleCaller : TSGConsoleCaller = nil;
	OtherConsoleCaller   : TSGConsoleCaller = nil;
	BuildConsoleCaller   : TSGConsoleCaller = nil;
	ApplicationsConsoleCaller   : TSGConsoleCaller = nil;
	HttpConsoleCaller    : TSGConsoleCaller = nil;
	UdpConsoleCaller     : TSGConsoleCaller = nil;
	NetConsoleCaller     :  TSGConsoleCaller = nil;

procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
GeneralConsoleCaller.Params := VParams;
GeneralConsoleCaller.Execute();
end;

procedure SGStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSGConcoleCallerParams;
begin
Params := SGSystemParamsToConcoleCallerParams();
SGConcoleCaller(Params);
SetLength(Params, 0);
end;

procedure SGConsoleRunConsole(const VParams : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSGConcoleCallerParams = nil;
begin
Params := SGParseStringToConsoleCallerParams(VParams);
SGConcoleCaller(Params);
SetLength(Params, 0);
end;

procedure SGConsoleFPCTCTransliater(const VParams : TSGConcoleCallerParams = nil);
var
	SGT : SGTranslater = nil;
begin
SGPrintEngineVersion();
SGT := SGTranslater.Create('cmd');
SGT.Params := VParams;
SGT.GoTranslate();
SGT.Destroy();
end;

//============================
(*============Udp===========*)
//============================

procedure RunUdpConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
UdpConsoleCaller.Params := VParams;
UdpConsoleCaller.Execute();
end;

procedure InitUdpConsoleCaller();
begin
if UdpConsoleCaller <> nil then
	exit;
UdpConsoleCaller := TSGConsoleCaller.Create(nil);
UdpConsoleCaller.Category('UDP tools');
UdpConsoleCaller.AddComand(@SGConsoleNetServer, ['Server'], 'Run server');
UdpConsoleCaller.AddComand(@SGConsoleNetClient, ['Connect'], 'Connect to server');
end;

//============================
(*============Http===========*)
//============================

procedure RunHttpConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
HttpConsoleCaller.Params := VParams;
HttpConsoleCaller.Execute();
end;

procedure InitHttpConsoleCaller();
begin
if HttpConsoleCaller <> nil then
	Exit;
HttpConsoleCaller := TSGConsoleCaller.Create(nil);
HttpConsoleCaller.Category('HTTP tools');
HttpConsoleCaller.AddComand(@SGConsoleHTTPGet,  ['get'], 'GET Method');
end;

//============================
(*=============Net===========*)
//============================

procedure RunNetConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
NetConsoleCaller.Params := VParams;
NetConsoleCaller.Execute();
end;

procedure InitNetConsoleCaller();
begin
if NetConsoleCaller <> nil then
	Exit;
NetConsoleCaller := TSGConsoleCaller.Create(nil);
NetConsoleCaller.Category('Internet tools');
NetConsoleCaller.AddComand(@RunHttpConsoleCaller, ['Http'], 'HTTP tools');
NetConsoleCaller.AddComand(@RunUdpConsoleCaller, ['Udp'], 'UDP tools');
end;

//============================
(*=====BuildConsoleCaller====*)
//============================

procedure RunBuildConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
BuildConsoleCaller.Params := VParams;
BuildConsoleCaller.Execute();
end;

procedure InitBuildConsoleCaller();
begin
if BuildConsoleCaller <> nil then
	Exit;
BuildConsoleCaller := TSGConsoleCaller.Create(nil);
BuildConsoleCaller.Category('Build tools');
BuildConsoleCaller.AddComand(@SGConsoleBuild, ['BUILD'], 'Building SaGe Engine');
BuildConsoleCaller.AddComand(@SGConsoleClearFileRegistrationResources, ['Cfrr'], 'Clear File Registration Resources');
BuildConsoleCaller.AddComand(@SGConsoleClearFileRegistrationPackages, ['Cfrp'], 'Clear File Registration Packages');
BuildConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnitAndRegisterUnit, ['CFTPUARU'], 'Convert File To Pascal Unit And Register Unit in registration file');
BuildConsoleCaller.AddComand(@SGConsoleConvertCachedFileToPascalUnitAndRegisterUnit, ['CCFTPUARU'], 'Convert Cached File To Pascal Unit And Register Unit in registration file');
BuildConsoleCaller.AddComand(@SGConsoleIncEngineVersion, ['IV'], 'Increment engine Version');
BuildConsoleCaller.AddComand(@SGConsoleBuildFiles, ['BF'], 'Build files in datafile');
BuildConsoleCaller.AddComand(@SGConsoleDefineSkiper, ['ds'], 'Tool to skip defines in file');
BuildConsoleCaller.AddComand(@SGConsoleVersionTo_RC_WindowsFile, ['vtrc'], 'curent Version To RC windows file');
BuildConsoleCaller.AddComand(@SGConsoleIsConsole, ['ic'], 'Return bool value, is console or not');
BuildConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnit, ['CFTPU'], 'Convert File To Pascal Unit utility');
BuildConsoleCaller.AddComand(@SGConsoleConvertDirectoryFilesToPascalUnits, ['CDTPUARU'], 'Convert Directory Files To Pascal Units utility');
BuildConsoleCaller.AddComand(@SGConsoleAddToLog, ['ATL'], 'Add line To Log');
BuildConsoleCaller.AddComand(@SGConsoleOpenLastLog, ['oll'], 'Open Last Log file');
end;

//===================================
(*=====ApplicationsConsoleCaller====*)
//===================================

procedure RunApplicationsConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ApplicationsConsoleCaller.Params := VParams;
ApplicationsConsoleCaller.Execute();
end;

procedure InitApplicationsConsoleCaller();
begin
if ApplicationsConsoleCaller <> nil then
	Exit;
ApplicationsConsoleCaller := TSGConsoleCaller.Create(nil);
ApplicationsConsoleCaller.Category('Applications');
ApplicationsConsoleCaller.AddComand(@SGConsoleShowAllApplications, ['GUI', ''], 'Shows all 3D/2D scenes');
ApplicationsConsoleCaller.AddComand(@SGConsoleConvertHeaderToDynamic, ['CHTD', 'DDH'], 'Convert pascal Header to Dynamic utility');
ApplicationsConsoleCaller.AddComand(@SGConsoleShaderReadWrite, ['SRW'], 'Read shader file with params and write it as single file without directives');
ApplicationsConsoleCaller.AddComand(@SGConsoleHash, ['hash'], 'Hash file or directory');
ApplicationsConsoleCaller.AddComand(@SGConsoleFindInPas, ['FIP'], 'Find In Pas program');
ApplicationsConsoleCaller.AddComand(@SGConsoleMake, ['MAKE'], 'Make utility');
end;

//============================
(*=====OtherConsoleCaller====*)
//============================

procedure RunOtherConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
OtherConsoleCaller.Params := VParams;
OtherConsoleCaller.Execute();
end;

procedure InitOtherConsoleCaller();
begin
if OtherConsoleCaller <> nil then
	Exit;
OtherConsoleCaller := TSGConsoleCaller.Create(nil);
OtherConsoleCaller.Category('Images tools');
OtherConsoleCaller.AddComand(@SGConsoleImageResizer, ['IR'], 'Image Resizer');
OtherConsoleCaller.AddComand(@SGConsoleConvertImageToSaGeImageAlphaFormat, ['CTSGIA'], 'Convert image To SaGeImagesAlpha format');
OtherConsoleCaller.Category('Math tools');
OtherConsoleCaller.AddComand(@SGConsoleCalculateExpression, ['ce'], 'Calculate Expression');
OtherConsoleCaller.AddComand(@SGConsoleCalculateBoolTable, ['cbt'], 'Calculate Boolean Table');
OtherConsoleCaller.Category('Other tools');
OtherConsoleCaller.AddComand(@SGConsoleGoogleReNameCache, ['grc'], 'Tool for renameing browser cache files');
OtherConsoleCaller.AddComand(@SGConsoleFPCTCTransliater, ['fpctc'], 'Tool for transliating FPC to C');
end;

//============================
(*===========General=========*)
//============================

procedure InitGeneralConsoleCaller();
begin
if GeneralConsoleCaller <> nil then
	Exit;
GeneralConsoleCaller := TSGConsoleCaller.Create(nil);
GeneralConsoleCaller.AddComand(@SGConcoleCaller, ['CONSOLE'], 'Run console caller');
GeneralConsoleCaller.Category('Applications');
GeneralConsoleCaller.AddComand(@SGConsoleShowAllApplications, ['GUI', ''], 'Shows all 3D/2D scenes');
GeneralConsoleCaller.Category('Other tools');
GeneralConsoleCaller.AddComand(@RunNetConsoleCaller, ['net', 'nt'], 'Internet tools');
GeneralConsoleCaller.AddComand(@RunOtherConsoleCaller, ['oa'], 'Other Engine''s Console Programs');
GeneralConsoleCaller.AddComand(@RunBuildConsoleCaller, ['bt'], 'Build tools');
GeneralConsoleCaller.AddComand(@RunApplicationsConsoleCaller, ['app'], 'Applications');
GeneralConsoleCaller.Category('System tools');
GeneralConsoleCaller.AddComand(@SGConsoleExtractFiles, ['EF'], 'Extract all files in this application');
GeneralConsoleCaller.AddComand(@SGConsoleWriteOpenableExpansions, ['woe'], 'Write all of openable expansions of files');
GeneralConsoleCaller.AddComand(@SGConsoleWriteFiles, ['WF'], 'Write all files in this application');
GeneralConsoleCaller.AddComand(@SGConsoleDllPrintStat, ['dlps'], 'Prints all statistics data of dynamic libraries, used in this application');
end;

(* == == == == == == == == == == == == == == *)
(* == == == == == == == == == == == == == == *)
(* == == == == == ==GETTERS== == == == == == *)
(* == == == == == == == == == == == == == == *)
(* == == == == == == == == == == == == == == *)

function SGApplicationsConsoleCaller()   : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitApplicationsConsoleCaller();
Result := ApplicationsConsoleCaller;
end;

function SGBuildConsoleCaller()   : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitBuildConsoleCaller();
Result := BuildConsoleCaller;
end;

function SGGeneralConsoleCaller() : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitGeneralConsoleCaller();
Result := GeneralConsoleCaller;
end;

function SGOtherConsoleCaller()   : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitOtherConsoleCaller();
Result := OtherConsoleCaller;
end;

function SGHttpConsoleCaller()    : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitHttpConsoleCaller();
Result := HttpConsoleCaller;
end;

function SGUdpConsoleCaller()     : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitUdpConsoleCaller();
Result := UdpConsoleCaller;
end;

function SGNetConsoleCaller()     : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
InitNetConsoleCaller();
Result := NetConsoleCaller;
end;

//============================

procedure InitConsoleCallers();
begin
InitUdpConsoleCaller();
InitHttpConsoleCaller();
InitNetConsoleCaller();
InitOtherConsoleCaller();
InitBuildConsoleCaller();
InitApplicationsConsoleCaller();
InitGeneralConsoleCaller();
end;

procedure DestroyConsoleCallers();
begin
SGKill(UdpConsoleCaller);
SGKill(HttpConsoleCaller);
SGKill(NetConsoleCaller);
SGKill(OtherConsoleCaller);
SGKill(BuildConsoleCaller);
SGKill(ApplicationsConsoleCaller);
SGKill(GeneralConsoleCaller);
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
