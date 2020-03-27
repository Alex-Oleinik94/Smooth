{ FreeGlut extensions, see http://freeglut.sourceforge.net/ .
  Complements the Glut unit that defines standard Glut functionality.
  Function entry points will be nil if freeglut is not
  actually available (or if freeglut version necessary for specific extension
  is not available).

  Includes all the extensions up to FreeGlut 2.6.0 version.
  Omitted is only deprecated stuff, and glutGetProcAddress
  (which is not needed as we have nice glext unit in FPC). }

unit FreeGlut;

{$mode Delphi} {< to keep assignments to proc vars look the same as in glut.pp }
{$MACRO ON}
{ Keep this synched with glut.pp "extdecl" definition. }
{$IFDEF Windows}
  {$DEFINE extdecl := stdcall}
{$ELSE}
  {$DEFINE extdecl := cdecl}
{$ENDIF}

interface

uses DynLibs, dglOpenGL, Glut;

type
  TGLdouble3 = array [0..2] of GLdouble;
  PGLdouble3 = ^TGLdouble3;

const
  // Additional GLUT Key definitions for the Special key function
  GLUT_KEY_NUM_LOCK = $006D;
  GLUT_KEY_BEGIN    = $006E;
  GLUT_KEY_DELETE   = $006F;

  // GLUT API Extension macro definitions -- behaviour when the user clicks on an "x" to close a window
  GLUT_ACTION_EXIT                 = 0;
  GLUT_ACTION_GLUTMAINLOOP_RETURNS = 1;
  GLUT_ACTION_CONTINUE_EXECUTION   = 2;

  // Create a new rendering context when the user opens a new window?
  GLUT_CREATE_NEW_CONTEXT  = 0;
  GLUT_USE_CURRENT_CONTEXT = 1;

  // Direct/Indirect rendering context options (has meaning only in Unix/X11)
  GLUT_FORCE_INDIRECT_CONTEXT  = 0;
  GLUT_ALLOW_DIRECT_CONTEXT    = 1;
  GLUT_TRY_DIRECT_CONTEXT      = 2;
  GLUT_FORCE_DIRECT_CONTEXT    = 3;

  // GLUT API Extension macro definitions -- the glutGet parameters
  GLUT_INIT_STATE = $007C;

  GLUT_ACTION_ON_WINDOW_CLOSE = $01F9;

  GLUT_WINDOW_BORDER_WIDTH  = $01FA;
  GLUT_WINDOW_HEADER_HEIGHT = $01FB;

  GLUT_VERSION = $01FC;

  GLUT_RENDERING_CONTEXT = $01FD;
  GLUT_DIRECT_RENDERING  = $01FE;

  GLUT_FULL_SCREEN = $01FF;

  // New tokens for glutInitDisplayMode.
  // Only one GLUT_AUXn bit may be used at a time.
  // Value 0x0400 is defined in OpenGLUT.
  GLUT_AUX  = $1000;

  GLUT_AUX1 = $1000;
  GLUT_AUX2 = $2000;
  GLUT_AUX3 = $4000;
  GLUT_AUX4 = $8000;

  // Context-related flags
  GLUT_INIT_MAJOR_VERSION = $0200;
  GLUT_INIT_MINOR_VERSION = $0201;
  GLUT_INIT_FLAGS         = $0202;
  GLUT_INIT_PROFILE       = $0203;

  // Flags for glutInitContextFlags
  GLUT_DEBUG              = $0001;
  GLUT_FORWARD_COMPATIBLE = $0002;

  // Flags for glutInitContextProfile
  GLUT_CORE_PROFILE          = $0001;
  GLUT_COMPATIBILITY_PROFILE = $0002;

  // GLUT API macro definitions -- the display mode definitions
  GLUT_CAPTIONLESS = $0400;
  GLUT_BORDERLESS  = $0800;
  GLUT_SRGB        = $1000;

var
  // Process loop function
  glutMainLoopEvent: procedure; extdecl;
  glutLeaveMainLoop: procedure; extdecl;
  glutExit:  procedure; extdecl;

  // Window management functions
  glutFullScreenToggle: procedure; extdecl;

  // Window-specific callback functions
  glutMouseWheelFunc: procedure(callback: TGlut4IntCallback); extdecl;
  glutCloseFunc: procedure(callback: TGlutVoidCallback); extdecl;
  // A. Donev: Also a destruction callback for menus
  glutMenuDestroyFunc: procedure(callback: TGlutVoidCallback); extdecl;

  // State setting and retrieval functions
  glutSetOption: procedure(option_flag: GLenum; value: Integer); extdecl;
  glutGetModeValues: function(mode: GLenum; size: PInteger): Integer; extdecl;
  // A.Donev: User-data manipulation
  glutGetWindowData: function: Pointer; extdecl;
  glutSetWindowData: procedure(data: Pointer); extdecl;
  glutGetMenuData: function: Pointer; extdecl;
  glutSetMenuData: procedure(data: Pointer); extdecl;

  // Font stuff
  glutBitmapHeight: function(font : pointer): Integer; extdecl;
  glutStrokeHeight: function(font : pointer): GLfloat; extdecl;
  glutBitmapString: procedure(font : pointer; const str: PChar); extdecl;
  glutStrokeString: procedure(font : pointer; const str: PChar); extdecl;

  // Geometry functions
  glutWireRhombicDodecahedron: procedure; extdecl;
  glutSolidRhombicDodecahedron: procedure; extdecl;
  glutWireSierpinskiSponge: procedure(num_levels: Integer; offset: PGLdouble3; scale: GLdouble); extdecl;
  glutSolidSierpinskiSponge: procedure(num_levels: Integer; offset: PGLdouble3; scale: GLdouble); extdecl;
  glutWireCylinder: procedure(radius: GLdouble; height: GLdouble; slices: GLint; stacks: GLint); extdecl;
  glutSolidCylinder: procedure(radius: GLdouble; height: GLdouble; slices: GLint; stacks: GLint); extdecl;

  // Initialization functions
  glutInitContextVersion: procedure(majorVersion: Integer; minorVersion: Integer); extdecl;
  glutInitContextFlags: procedure(flags: Integer); extdecl;
  glutInitContextProfile: procedure(profile: Integer); extdecl;

implementation

uses
	 SmoothBase
	,SmoothLists
	,SmoothDllManager
	,SmoothSysUtils
	;

type
	TSDllFreeGLUT = class(TSDll)
			public
		class function SystemNames() : TSStringList; override;
		class function DllNames() : TSStringList; override;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;
		class procedure Free(); override;
		end;

class function TSDllFreeGLUT.SystemNames() : TSStringList;
begin
Result := 'FreeGLUT';
Result += 'LibFreeGlut';
Result += 'FreeGlut32';
Result += 'FGlut';
Result += 'FGlut32';
end;

class function TSDllFreeGLUT.DllNames() : TSStringList;
begin
Result := nil;
Result += 'freeglut';
{$IFDEF Windows}
Result += 'glut32.dll';
{$ELSE}
{$ifdef darwin}
Result += '/System/Library/Frameworks/GLUT.framework/GLUT';
{$else}
{$IFDEF haiku}
Result += 'libglut.so';
{$ELSE}
{$IFNDEF MORPHOS}
Result += 'libglut.so.3';
{$ENDIF}
{$ENDIF}
{$endif}
{$ENDIF}
end;

class function TSDllFreeGLUT.Load(const VDll : TSLibHandle) : TSDllLoadObject;
var
	LoadResult : PSDllLoadObject = nil;

function fglutGetProcAddress(const S : PChar):Pointer;
begin
Result := GetProcAddress(VDll, S);
LoadResult^.FFunctionCount += 1;
if Result <> nil then
	LoadResult^.FFunctionLoaded += 1;
end;

begin
Result.Clear();
LoadResult := @Result;
  @glutMainLoopEvent := fglutGetProcAddress('glutMainLoopEvent');
  @glutLeaveMainLoop := fglutGetProcAddress('glutLeaveMainLoop');
  @glutExit := fglutGetProcAddress('glutExit');
  @glutFullScreenToggle := fglutGetProcAddress('glutFullScreenToggle');
  @glutMouseWheelFunc := fglutGetProcAddress('glutMouseWheelFunc');
  @glutCloseFunc := fglutGetProcAddress('glutCloseFunc');
  @glutMenuDestroyFunc := fglutGetProcAddress('glutMenuDestroyFunc');
  @glutSetOption := fglutGetProcAddress('glutSetOption');
  @glutGetModeValues := fglutGetProcAddress('glutGetModeValues');
  @glutGetWindowData := fglutGetProcAddress('glutGetWindowData');
  @glutSetWindowData := fglutGetProcAddress('glutSetWindowData');
  @glutGetMenuData := fglutGetProcAddress('glutGetMenuData');
  @glutSetMenuData := fglutGetProcAddress('glutSetMenuData');
  @glutBitmapHeight := fglutGetProcAddress('glutBitmapHeight');
  @glutStrokeHeight := fglutGetProcAddress('glutStrokeHeight');
  @glutBitmapString := fglutGetProcAddress('glutBitmapString');
  @glutStrokeString := fglutGetProcAddress('glutStrokeString');
  @glutWireRhombicDodecahedron := fglutGetProcAddress('glutWireRhombicDodecahedron');
  @glutSolidRhombicDodecahedron := fglutGetProcAddress('glutSolidRhombicDodecahedron');
  @glutWireSierpinskiSponge := fglutGetProcAddress('glutWireSierpinskiSponge');
  @glutSolidSierpinskiSponge := fglutGetProcAddress('glutSolidSierpinskiSponge');
  @glutWireCylinder := fglutGetProcAddress('glutWireCylinder');
  @glutSolidCylinder := fglutGetProcAddress('glutSolidCylinder');
  @glutInitContextVersion := fglutGetProcAddress('glutInitContextVersion');
  @glutInitContextFlags := fglutGetProcAddress('glutInitContextFlags');
  @glutInitContextProfile := fglutGetProcAddress('glutInitContextProfile');
end;

class procedure TSDllFreeGLUT.Free();
begin
  @glutMainLoopEvent := nil;
  @glutLeaveMainLoop := nil;
  @glutExit := nil;
  @glutFullScreenToggle := nil;
  @glutMouseWheelFunc := nil;
  @glutCloseFunc := nil;
  @glutMenuDestroyFunc := nil;
  @glutSetOption := nil;
  @glutGetModeValues := nil;
  @glutGetWindowData := nil;
  @glutSetWindowData := nil;
  @glutGetMenuData := nil;
  @glutSetMenuData := nil;
  @glutBitmapHeight := nil;
  @glutStrokeHeight := nil;
  @glutBitmapString := nil;
  @glutStrokeString := nil;
  @glutWireRhombicDodecahedron := nil;
  @glutSolidRhombicDodecahedron := nil;
  @glutWireSierpinskiSponge := nil;
  @glutSolidSierpinskiSponge := nil;
  @glutWireCylinder := nil;
  @glutSolidCylinder := nil;
  @glutInitContextVersion := nil;
  @glutInitContextFlags := nil;
  @glutInitContextProfile := nil;
end;

initialization
begin
TSDllFreeGLUT.Create();
end;

end.
