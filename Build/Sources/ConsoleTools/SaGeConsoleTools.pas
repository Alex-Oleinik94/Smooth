{$INCLUDE SaGe.inc}

unit SaGeConsoleTools;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeConsoleToolsBase
	;

procedure SGConsoleFPCTCTransliater(const VParams : TSGConcoleCallerParams = nil);

procedure SGConsoleRunConsole(const VParams : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGGeneralConsoleCaller() : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGOtherConsoleCaller()   : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGHttpConsoleCaller()    : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGUdpConsoleCaller()     : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGNetConsoleCaller()     : TSGConsoleCaller; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	// Aditional console program includes
	 SaGeConsoleProgramFindInPas
	,SaGeConsoleProgramGoogleReNameCache
	,SaGeConsoleProgramConvertHeaderToDynamic
	
	// Aditional console tool includes
	,SaGeConsoleEngineTools
	,SaGeConsolePaintableTools
	,SaGeConsoleMathTools
	,SaGeConsoleImageTools
	,SaGeConsoleBuildTools
	,SaGeConsoleNetTools
	,SaGeConsoleShaderTools
	,SaGeConsoleHashTools
	
	// Engine includes
	,SaGeVersion
	,SaGeFPCToC
	;

var
	GeneralConsoleCaller : TSGConsoleCaller = nil;
	OtherConsoleCaller   : TSGConsoleCaller = nil;
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

procedure DestroyUdpConsoleCaller();
begin
if UdpConsoleCaller <> nil then
	begin
	UdpConsoleCaller.Destroy();
	UdpConsoleCaller := nil;
	end;
end;

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

procedure DestroyHttpConsoleCaller();
begin
if HttpConsoleCaller <> nil then
	begin
	HttpConsoleCaller.Destroy();
	HttpConsoleCaller := nil;
	end;
end;

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

procedure DestroyNetConsoleCaller();
begin
if NetConsoleCaller <> nil then
	begin
	NetConsoleCaller.Destroy();
	NetConsoleCaller := nil;
	end;
end;

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
(*=====OtherConsoleCaller====*)
//============================

procedure RunOtherConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
OtherConsoleCaller.Params := VParams;
OtherConsoleCaller.Execute();
end;

procedure DestroyOtherConsoleCaller();
begin
if OtherConsoleCaller <> nil then
	begin
	OtherConsoleCaller.Destroy();
	OtherConsoleCaller := nil;
	end;
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

procedure DestroyGeneralConsoleCaller();
begin
if GeneralConsoleCaller <> nil then
	begin
	GeneralConsoleCaller.Destroy();
	GeneralConsoleCaller := nil;
	end;
end;

procedure InitGeneralConsoleCaller();
begin
if GeneralConsoleCaller <> nil then
	Exit;
GeneralConsoleCaller := TSGConsoleCaller.Create(nil);
GeneralConsoleCaller.AddComand(@SGConcoleCaller, ['CONSOLE'], 'Run console caller');
GeneralConsoleCaller.Category('Applications');
GeneralConsoleCaller.AddComand(@SGConsoleFindInPas, ['FIP'], 'Find In Pas program');
GeneralConsoleCaller.AddComand(@SGConsoleMake, ['MAKE'], 'Make utility');
GeneralConsoleCaller.AddComand(@SGConsoleShowAllApplications, ['GUI',''], 'Shows all 3D/2D scenes');
GeneralConsoleCaller.Category('System applications');
GeneralConsoleCaller.AddComand(@SGConsoleAddToLog, ['ATL'], 'Add line To Log');
GeneralConsoleCaller.AddComand(@SGConsoleConvertDirectoryFilesToPascalUnits, ['CDTPUARU'], 'Convert Directory Files To Pascal Units utility');
GeneralConsoleCaller.AddComand(@SGConsoleConvertHeaderToDynamic, ['CHTD','DDH'], 'Convert pascal Header to Dynamic utility');
GeneralConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnit, ['CFTPU'], 'Convert File To Pascal Unit utility');
GeneralConsoleCaller.AddComand(@SGConsoleShaderReadWrite, ['SRW'], 'Read shader file with params and write it as single file without directives');
GeneralConsoleCaller.AddComand(@RunNetConsoleCaller, ['net'], 'Internet tools');
GeneralConsoleCaller.AddComand(@RunOtherConsoleCaller, ['oecp'], 'Other Engine''s Console Programs');
GeneralConsoleCaller.Category('Build tools');
GeneralConsoleCaller.AddComand(@SGConsoleBuild, ['BUILD'], 'Building SaGe Engine');
GeneralConsoleCaller.AddComand(@SGConsoleClearFileRegistrationResources, ['Cfrr'], 'Clear File Registration Resources');
GeneralConsoleCaller.AddComand(@SGConsoleClearFileRegistrationPackages, ['Cfrp'], 'Clear File Registration Packages');
GeneralConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnitAndRegisterUnit, ['CFTPUARU'], 'Convert File To Pascal Unit And Register Unit in registration file');
GeneralConsoleCaller.AddComand(@SGConsoleConvertCachedFileToPascalUnitAndRegisterUnit, ['CCFTPUARU'], 'Convert Cached File To Pascal Unit And Register Unit in registration file');
GeneralConsoleCaller.AddComand(@SGConsoleIncEngineVersion, ['IV'], 'Increment engine Version');
GeneralConsoleCaller.AddComand(@SGConsoleBuildFiles, ['BF'], 'Build files in datafile');
GeneralConsoleCaller.Category('System tools');
GeneralConsoleCaller.AddComand(@SGConsoleHash, ['hash'], 'Hash file or directory');
GeneralConsoleCaller.AddComand(@SGConsoleIsConsole, ['ic'], 'Return bool value, is console or not');
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
InitGeneralConsoleCaller();
InitOtherConsoleCaller();
end;

procedure DestroyConsoleCallers();
begin
DestroyUdpConsoleCaller();
DestroyHttpConsoleCaller();
DestroyNetConsoleCaller();
DestroyOtherConsoleCaller();
DestroyGeneralConsoleCaller();
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
