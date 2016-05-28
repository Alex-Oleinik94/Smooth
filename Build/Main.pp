{$INCLUDE SrcUnits\Includes\SaGe.inc}
{$IFNDEF MOBILE}
	{$IFNDEF DARWIN}
		{$IFDEF RELEASE}
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
	{$IFDEF UNIX}
		{$IF defined(UseCThreads)}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeBase
	,SaGeBased
	,SaGeResourseManager
	{$INCLUDE SrcUnits\Temp\SaGeRMFiles.inc}
	,SaGeConsoleTools
	;

{$IFDEF ANDROID}
	procedure android_main(State: PAndroid_App); cdecl; export;
	begin
	SGLog.Sourse('Entering "procedure android_main(state: Pandroid_app); cdecl; export;" in "Main"');
	ShowGUIWithAllApplications(State);
	end;
	
	exports 
			ANativeActivity_onCreate name 'ANativeActivity_onCreate';
	
	begin
	end.
{$ELSE}	
	begin
	//SGConcoleCaller(SGArConstToArString(['-gui']));
	StandartCallConcoleCaller();
	end.
	{$ENDIF}
