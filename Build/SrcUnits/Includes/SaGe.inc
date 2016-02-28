{$IFNDEF ANDROID}
	{$IFDEF UNIX}
		{$IFNDEF DARWIN}
			{$DEFINE LINUX}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}

//Это на будущее, если будим прогать под iOS
{$IFDEF ANDROID}
	{$DEFINE MOBILE}
	//{$ASMMODE DIRECT}
	{$ENDIF}

{$IFNDEF MOBILE}
	{$DEFINE WITHLIBPNG}
	{$ENDIF}

{$IFDEF FPC}
	{$PACKRECORDS C}
	{$MODE OBJFPC}
	{$IFNDEF ANDROID}
		{$ASMMODE INTEL}
	{$ELSE}
		//{$ASMMODE ?} - Я не знаю, какой нужен для arm-android
		{$ENDIF}
	{$H+}
	{$ENDIF}

//{$DEFINE LAZARUS}
//{$DEFINE GLUT}

{$WARNINGS OFF}
{$NOTES OFF}
{$HINTS OFF}

{$DEFINE SGDebuging}
//{$DEFINE SGMoreDebuging}

{$IF defined(CPU386) and defined(CPU32) and (not defined(DARWIN))}
	{$DEFINE WITHASMINC}
	{$ENDIF}

//{$IFNDEF ANDROID}
	{$DEFINE SUPPORTINLINE}
	//{$ENDIF}}
