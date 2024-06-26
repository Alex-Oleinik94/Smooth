{$IFDEF LINUX}
	{$DEFINE UseCThreads}
	{$ENDIF}

{$IFNDEF ANDROID}
	{$IFDEF UNIX}
		{$IFNDEF DARWIN}
			{$DEFINE LINUX}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}

{$IFDEF ANDROID}
	{$DEFINE MOBILE}
	//{$ASMMODE DIRECT}
	{$ENDIF}

(*{$IF (not defined(MOBILE)) and (not (defined(DARWIN) and defined(CPU32)))}
	{$DEFINE WITHLIBPNG}
	{$ENDIF}*)

{$IFDEF RELEASE}
	{$DEFINE SUPPORTINLINE}
	{$ENDIF}

{$DEFINE WITHEXCEPTIONTRACEING}

{$IFDEF FPC}
	{$PACKRECORDS C}
	{$MODE OBJFPC}
	{$IFNDEF ANDROID}
		{$ASMMODE INTEL}
	{$ELSE}
		//{$ASMMODE ?}
		{$ENDIF}
	{$H+}
	//{$INTERFACES CORBA}
	{$INTERFACES COM}
	//{$CALLING Register}
	{$SMARTLINK ON}
	{$R-}
	{$MACRO ON}
	{$modeswitch nestedprocvars}
	{$modeswitch typehelpers}
	//{$modeswitch ADVANCEDRECORDS} //allow the use of advanced records (i.e. records with methods)
	//{$static on} // for static object fields (analog class fields for classes)
	{$ENDIF}

{$IFNDEF MOBILE}
	{$DEFINE DESKTOP}
	{$ENDIF}

{$IFDEF DESKTOP}
	{$DEFINE WITH_GLUT}
	{$ENDIF}

{$IF defined(ANDROID) or defined(WIN64)}
	{$DEFINE WITHOUT_EXTENDED}
	{$ENDIF}

{$WARNINGS OFF}
{$NOTES OFF}
{$HINTS OFF}

{$IF defined(CPU386) and defined(CPU32) and (not defined(DARWIN)) and (not defined(MOBILE))}
	{$DEFINE WITHASMINC}
	{$ENDIF}

{$IFNDEF MSWINDOWS}
	{$OVERFLOWCHECKS OFF}
	{$ENDIF}

{$IF (not defined(RELEASE)) and (not defined(ANDROID))}
	{$DEFINE WITHLEAKSDETECTOR}
	{$ENDIF}

{$IF not defined(FPC_HAS_CONSTREF)}
	{$DEFINE constref := const}
	{$ENDIF}
