{$INCLUDE Includes\Smooth.inc}

unit SmoothLibrary;

interface

uses
	 SmoothBase
	,SmoothVersion
	
	,Classes
	;

var
	SConcoleCaller : procedure(const VParams : TSConcoleCallerParams = nil);cdecl;
	SGetEngineVersion : function () : TSString;

procedure SStandartLibraryCallConcoleCaller();

implementation

procedure SStandartLibraryCallConcoleCaller();
begin
if SConcoleCaller = nil then
	begin
	SPrintEngineVersion();
	WriteLn('Error while loading Smooth library!');
	end
else
	begin
	//WriteLn('Running Smooth library version: ', SGetEngineVersion());
	SConcoleCaller(SSystemParamsToConcoleCallerParams());
	end;
end;

var
	Lib : TSLibHandle = 0;

procedure FreeLibrary();
begin
if Lib <> 0 then
	UnloadLibrary(Lib);
Lib := 0;
SConcoleCaller := nil;
SGetEngineVersion := nil;
end;

procedure InitLibrary();
const
	LibraryName = SLibraryNameBegin + 'Smooth' + SLibraryNameEnd;
begin
FreeLibrary();
Lib := LoadLibrary(LibraryName);
Pointer(SConcoleCaller) := GetProcAddress(Lib,'SConcoleCaller');
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
