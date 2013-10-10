

{$i Includes\SaGe.inc}

unit SaGe;

interface

uses 
	crt
	{,gl
	,glu
	,glext}
	,Classes
	,SysUtils
	{{$IFDEF GLUT}
		,glut 
		{$ENDIF}}
	,dos
	{{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,Dl
		,x
		,xlib
		,xutil
		,glx
		{$ENDIF}}
	,SaGeImages
	,SaGeBase
	,DynLibs
	;
const
	{$IFDEF GLUT}
		SGGLUTDLL = 
		{$IFDEF MSWINDOWS}
			'glut32.dll';
		{$ELSE}
			{$IFDEF darwin}
				'/System/Library/Frameworks/GLUT.framework/GLUT';
			{$ELSE}
				{$IFDEF MORPHOS}
					'libglut.so.3';
				{$ELSE}
					'';
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	
	
type
	{$IFDEF SGDebuging}
		(*$NOTE type*)
		{$ENDIF}
	
	
	
var
	{$IFDEF SGDebuging}
		(*$NOTE var*)
		{$ENDIF}
	
	
	
	SGContextResized:Boolean = False;

var
	SGIsOpenGLInit:Boolean = False;

procedure SGCrearOpenGL;
procedure SGInitOpenGL;
procedure SGLoadFrameIdentity;


//procedure SGLookAt(Mesh,Camera,CameraTop:SGVertex3f);
{procedure SGLookAt(Mesh,Camera,CameraTop:SGVertex3f);
begin
gluLookAt(Mesh.x,Mesh.y,Mesh.z,Camera.x,Camera.y,Camera.z,CameraTop.x,CameraTop.y,CameraTop.z);
end;}
implementation
{$IFDEF SGDebuging}
	(*$NOTE implementation*)
	{$ENDIF}

procedure SGInitOpenGL;

begin
if SGIsOpenGLInit then
	Exit;

if SGCLLoadProcedure<>nil then
	SGCLLoadProcedure;

SGIsOpenGLInit:=True;
end;


end.
