{$INCLUDE SaGe.inc}

{$IF not defined(MOBILE)}
	//{$DEFINE WITHSAGELIBRARY}
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
	{$IF defined(UNIX) and defined(UseCThreads)}
		cthreads,
		{$ENDIF}
	 SaGeBase
	,SaGeBased
	,SaGeContext
	,SysUtils
	,SaGeResourceManager
	{$IF defined(ANDROID)}
		,android_native_app_glue
		,SaGeConsolePaintableTools
		{$ENDIF}

	{$IF defined(WITHSAGELIBRARY)}
		,SaGeLibrary
		{$ENDIF}
	{$IF (not defined(WITHSAGELIBRARY)) and (not defined(ANDROID))}
		,SaGeConsoleTools
		{$ENDIF}
	;

{$IF defined(ANDROID)}
	procedure android_main(State: PAndroid_App); cdecl; export;
	begin
	SGLog.Source('Entering "procedure android_main(state: Pandroid_app); cdecl; export;" in "Main"');
	{$IFDEF WITHEXCEPTIONTRACEING}
	try
	{$ENDIF}
	SGConsoleShowAllApplications(nil, SGContextOptionAndroidApp(State));
	{$IFDEF WITHEXCEPTIONTRACEING}
	except on e : Exception do
		SGPrintExceptionStackTrace(e);
	end;
	{$ENDIF}
	end;

	exports
			ANativeActivity_onCreate name 'ANativeActivity_onCreate';

	begin
	end.
{$ELSE}
	begin
	{$IFDEF WITHEXCEPTIONTRACEING}
	try
	{$ENDIF}
	{$IF defined(WITHSAGELIBRARY)}
		SGStandartLabraryCallConcoleCaller();
	{$ELSE}
		SGStandartCallConcoleCaller();
	{$ENDIF}
	{$IFDEF WITHEXCEPTIONTRACEING}
	except on e : Exception do
		begin
		SGPrintExceptionStackTrace(e);
		//Write('Press ENTER! ');ReadLn();
		end;
	end;
	{$ENDIF}
	end.
	{$ENDIF}
