{$INCLUDE Includes\SaGe.inc}

unit SaGeLibrary;

interface

uses
	SaGeBase
	,SaGeBased
	,Classes
	,SaGeVersion
	;

var
	SGConcoleCaller : procedure(const VParams : TSGConcoleCallerParams = nil);cdecl;
	SGGetEngineVersion : function () : TSGString;

procedure SGStandartLabraryCallConcoleCaller();

implementation

procedure SGStandartLabraryCallConcoleCaller();
begin
if SGConcoleCaller = nil then
	begin
	SGPrintEngineVersion();
	WriteLn('Error while loading SaGe library!');
	end
else
	begin
	//WriteLn('Running SaGe library version: ', SGGetEngineVersion());
	SGConcoleCaller(SGSystemParamsToConcoleCallerParams());
	end;
end;

var
	Lib : TSGLibHandle = 0;

procedure FreeLibrary();
begin
if Lib <> 0 then
	UnloadLibrary(Lib);
Lib := 0;
SGConcoleCaller := nil;
SGGetEngineVersion := nil;
end;

procedure InitLibrary();
const
	LibraryName = SGLibraryNameBegin + 'SaGe' + SGLibraryNameEnd;
begin
FreeLibrary();
Lib := LoadLibrary(LibraryName);
Pointer(SGConcoleCaller) := GetProcAddress(Lib,'SGConcoleCaller');
Pointer(SGGetEngineVersion) := GetProcAddress(Lib,'SGGetEngineVersion');
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
