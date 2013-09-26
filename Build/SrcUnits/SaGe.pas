

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
	SGFrameButtonsType0f =               $000003;
	SGFrameButtonsTypeCleared = SGFrameButtonsType0f;
	SGFrameButtonsType1f =               $000004;
	SGFrameButtonsType3f =               $000005;
	
	SGObjectTimerConst : real = 0.02;
	
	SGFrameAnimationConst = 200;
	SGFrameFObject = 5;
	SGFrameFNObject = 1;
	
	SGAlignNone =                        $000006;
	SGAlignLeft =                        $000007;
	SGAlignRight =                       $000008;
	SGAlignTop =                         $000009;
	SGAlignBottom =                      $00000A;
	SGAlignClient =                      $00000B;
	
	SGAnchorRight =                      $00000D;
	SGAnchorLeft =                       $00000E;
	SGAnchorTop =                        $00000F;
	SGAnchorBottom =                     $000010;
	
	SG_VERTEX_FOR_CHILDREN =             $000013;
	SG_VERTEX_FOR_PARENT =               $000014;
	
	SG_LEFT =                            $000015;
	SG_TOP =                             $000016;
	SG_HEIGHT =                          $000017;
	SG_WIDTH =                           $000018;
	SG_RIGHT =                           $000019;
	SG_BOTTOM =                          $00001A;
	
	SG_VARIABLE =                        $00001B;
	SG_CONST =                           $00001C;
	SG_OPERATOR =                        $00001D;
	SG_BOOLEAN =                         $00001E;
	SG_REAL =                            $00001F;
	SG_NUMERIC =                         $000020;
	SG_OBJECT =                          $000021;
	SG_NONE =                            $000022;
	SG_NOTHINC = SG_NONE;
	SG_NOTHINK = SG_NONE;
	SG_FUNCTION =                        $000023;
	
	SG_ERROR =                           $000024;
	SG_WARNING =                         $000025;
	SG_NOTE =                            $000026;
	
	SG_GLSL_3_0 =                          $000028;
	SG_GLSL_ARB =                          $000029;
	
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
