{$IFNDEF ANDROID}
	{$IFDEF UNIX}
		{$DEFINE LINUX}
		{$ENDIF}
	{$ENDIF}

//Это на будущее, если будим прогать под iOS
{$IFDEF ANDROID}
	{$DEFINE MOBILE}
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
