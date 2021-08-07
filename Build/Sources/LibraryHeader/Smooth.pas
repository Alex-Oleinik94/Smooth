{$INCLUDE Includes\Smooth.inc}

unit Smooth;

interface

uses
	 SmoothBase
	,SmoothVersion
	
	,Classes
	;

var
	SConsoleHandler : procedure(const VParams : TSConsoleHandlerParams = nil);cdecl;
	SGetEngineVersion : function () : TSString;

procedure SExecuteLibraryConsoleHandler();

implementation

procedure SExecuteLibraryConsoleHandler();
begin
if SConsoleHandler = nil then
	begin
	SPrintEngineVersion();
	WriteLn('Error while loading Smooth library!');
	end
else
	begin
	//WriteLn('Running Smooth library version: ', SGetEngineVersion());
	SConsoleHandler(SSystemParamsToConsoleHandlerParams());
	end;
end;

var
	Lib : TSLibHandle = 0;

procedure FreeLibrary();
begin
SConsoleHandler := nil;
SGetEngineVersion := nil;
if Lib <> 0 then
	UnloadLibrary(Lib);
Lib := 0;
end;

procedure InitLibrary();
const
	LibraryName = SLibraryNameBegin + 'Smooth' + SLibraryNameEnd;
begin
FreeLibrary();
Lib := LoadLibrary(LibraryName);
Pointer(SConsoleHandler) := GetProcAddress(Lib,'SConsoleHandler');
Pointer(SGetEngineVersion) := GetProcAddress(Lib,'SGetEngineVersion');
end;

initialization
begin
InitLibrary();
end;

finalization
begin
FreeLibrary();
end;

end.
