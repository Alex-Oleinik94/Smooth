{$INCLUDE Smooth.inc}

{$IF not defined(MOBILE)}
	//{$DEFINE WITHSmoothLIBRARY}
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
	 SmoothSysUtils
	,SmoothBase
	,SmoothLog
	,SmoothResourceManager
	{$IF defined(ANDROID)}
		,android_native_app_glue
		,SmoothConsolePaintableTools
		,SmoothContextUtils
		,SmoothLists
		{$ENDIF}
	{$IF defined(WITHSmoothLIBRARY)}
		,SmoothLibrary
		{$ENDIF}
	{$IF (not defined(WITHSmoothLIBRARY)) and (not defined(ANDROID))}
		,SmoothConsoleTools
		{$ENDIF}
	;

{$IF defined(ANDROID)}
	procedure android_main(State: PAndroid_App); cdecl; export;
	begin
	SLog.Source('Entering "procedure android_main(state: Pandroid_app); cdecl; export;" in "Main"');
	{$IFDEF WITHEXCEPTIONTRACEING}
	try
	{$ENDIF}
	SConsoleShowAllApplications(nil, SContextOptionAndroidApp(State));
	{$IFDEF WITHEXCEPTIONTRACEING}
	except on e : TSException do
		begin
		SLogMakeSignificant();
		SPrintExceptionStackTrace(e);
		end;
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
	{$IF defined(WITHSMOOTHLIBRARY)}
		SExecuteLibraryConsoleHandler();
	{$ELSE}
		SExecuteConsoleHandler();
	{$ENDIF}
	{$IFDEF WITHEXCEPTIONTRACEING}
	except on e : TSException do
		begin
		SLogMakeSignificant();
		SPrintExceptionStackTrace(e);
		//Write('Press ENTER! ');ReadLn();
		end;
	end;
	{$ENDIF}
	end.
	{$ENDIF}
