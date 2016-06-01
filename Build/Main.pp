{$INCLUDE SrcUnits\Includes\SaGe.inc}
{$IF not defined(MOBILE)}
	{$IF not defined(DARWIN)}
		{$IF defined(RELEASE)}
			{$APPTYPE GUI}
		{$ELSE}
			{$APPTYPE CONSOLE}
			{$ENDIF}
		{$ENDIF}
	program Main;
{$ELSE}
	library Main;
	{$ENDIF}
uses
	{$IF defined(UNIX)}
		{$IF defined(UseCThreads)}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeBase
	,SaGeBased
	{$IF defined(ANDROID)}
		,android_native_app_glue
		{$ENDIF}
	
	,SaGeResourseManager
	{$INCLUDE SrcUnits\Temp\SaGeRMFiles.inc}
	,SaGeConsoleTools
	;

{$IF defined(ANDROID)}
	procedure android_main(State: PAndroid_App); cdecl; export;
	begin
	SGLog.Sourse('Entering "procedure android_main(state: Pandroid_app); cdecl; export;" in "Main"');
	SGConsoleShowAllApplications(nil,State);
	end;
	
	exports 
			ANativeActivity_onCreate name 'ANativeActivity_onCreate';
	
	begin
	end.
{$ELSE}
	begin
	SGStandartCallConcoleCaller();
	end.
	{$ENDIF}
