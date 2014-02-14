{$IFNDEF ANDROID}
	{$IFDEF UNIX}
		{$DEFINE LINUX}
		{$ENDIF}
	{$ENDIF}

{$MODE OBJFPC}
{$IFNDEF ANDROID}
	{$ASMMODE INTEL}
{$ELSE}
	//{$ASMMODE ?} - Я не знаю, какой нужен для arm-android
	{$ENDIF}
{$H+}

//{$DEFINE LAZARUS}
//{$DEFINE GLUT}

{$WARNINGS OFF}
{$NOTES ON}
{$NOTES OFF}

//{$DEFINE SGDebuging}
//{$DEFINE SGMoreDebuging}
