{

  Adaption of the delphi3d.net OpenGL units to FreePascal
  Sebastian Guenther (sg@freepascal.org) in 2002
  These units are free to use
}

{$MACRO ON}
{$MODE Delphi}
{$IFDEF Windows}
  {$DEFINE extdecl := stdcall}
{$ELSE}
  {$DEFINE extdecl := cdecl}
{$ENDIF}

{$IFDEF MORPHOS}
{$INLINE ON}
{$DEFINE GLUT_UNIT}
{$ENDIF}

unit Glut;

// Copyright (c) Mark J. Kilgard, 1994, 1995, 1996. */

(* This program is freely distributable without licensing fees  and is
   provided without guarantee or warrantee expressed or  implied. This
   program is -not- in the public domain. *)

{******************************************************************************}
{ Converted to Delphi by Tom Nuydens (tom@delphi3d.net)                        }
{   Contributions by Igor Karpov (glygrik@hotbox.ru)                           }
{   For the latest updates, visit Delphi3D: http://www.delphi3d.net            }
{******************************************************************************}

interface

uses
  SysUtils,
  {$IFDEF Windows}
  Windows, dynlibs,
  {$ELSE}
  {$IFDEF MORPHOS}
  TinyGL,
  {$ELSE}
  dynlibs,
  {$ENDIF}
  {$ENDIF}
  dglOpenGL;

type
  TGlutVoidCallback = procedure; cdecl;
  TGlut1IntCallback = procedure(value: Integer); cdecl;
  TGlut2IntCallback = procedure(v1, v2: Integer); cdecl;
  TGlut3IntCallback = procedure(v1, v2, v3: Integer); cdecl;
  TGlut4IntCallback = procedure(v1, v2, v3, v4: Integer); cdecl;
  TGlut1Char2IntCallback = procedure(c: Byte; v1, v2: Integer); cdecl;
  TGlut1UInt3IntCallback = procedure(u: Cardinal; v1, v2, v3: Integer); cdecl;

const
  GLUT_API_VERSION                = 3;
  GLUT_XLIB_IMPLEMENTATION        = 12;
  // Display mode bit masks.
  GLUT_RGB                        = 0;
  GLUT_RGBA                       = GLUT_RGB;
  GLUT_INDEX                      = 1;
  GLUT_SINGLE                     = 0;
  GLUT_DOUBLE                     = 2;
  GLUT_ACCUM                      = 4;
  GLUT_ALPHA                      = 8;
  GLUT_DEPTH                      = 16;
  GLUT_STENCIL                    = 32;
  GLUT_MULTISAMPLE                = 128;
  GLUT_STEREO                     = 256;
  GLUT_LUMINANCE                  = 512;

  // Mouse buttons.
  GLUT_LEFT_BUTTON                = 0;
  GLUT_MIDDLE_BUTTON              = 1;
  GLUT_RIGHT_BUTTON               = 2;

  // Mouse button state.
  GLUT_DOWN                       = 0;
  GLUT_UP                         = 1;

  // function keys
  GLUT_KEY_F1                     = 1;
  GLUT_KEY_F2                     = 2;
  GLUT_KEY_F3                     = 3;
  GLUT_KEY_F4                     = 4;
  GLUT_KEY_F5                     = 5;
  GLUT_KEY_F6                     = 6;
  GLUT_KEY_F7                     = 7;
  GLUT_KEY_F8                     = 8;
  GLUT_KEY_F9                     = 9;
  GLUT_KEY_F10                    = 10;
  GLUT_KEY_F11                    = 11;
  GLUT_KEY_F12                    = 12;
  // directional keys
  GLUT_KEY_LEFT                   = 100;
  GLUT_KEY_UP                     = 101;
  GLUT_KEY_RIGHT                  = 102;
  GLUT_KEY_DOWN                   = 103;
  GLUT_KEY_PAGE_UP                = 104;
  GLUT_KEY_PAGE_DOWN              = 105;
  GLUT_KEY_HOME                   = 106;
  GLUT_KEY_END                    = 107;
  GLUT_KEY_INSERT                 = 108;

  // Entry/exit  state.
  GLUT_LEFT                       = 0;
  GLUT_ENTERED                    = 1;

  // Menu usage state.
  GLUT_MENU_NOT_IN_USE            = 0;
  GLUT_MENU_IN_USE                = 1;

  // Visibility  state.
  GLUT_NOT_VISIBLE                = 0;
  GLUT_VISIBLE                    = 1;

  // Window status  state.
  GLUT_HIDDEN                     = 0;
  GLUT_FULLY_RETAINED             = 1;
  GLUT_PARTIALLY_RETAINED         = 2;
  GLUT_FULLY_COVERED              = 3;

  // Color index component selection values.
  GLUT_RED                        = 0;
  GLUT_GREEN                      = 1;
  GLUT_BLUE                       = 2;

  // Layers for use.
  GLUT_NORMAL                     = 0;
  GLUT_OVERLAY                    = 1;

{$ifdef Windows}
  // Stroke font constants (use these in GLUT program).
  GLUT_STROKE_ROMAN               = Pointer(0);
  GLUT_STROKE_MONO_ROMAN          = Pointer(1);

  // Bitmap font constants (use these in GLUT program).
  GLUT_BITMAP_9_BY_15             = Pointer(2);
  GLUT_BITMAP_8_BY_13             = Pointer(3);
  GLUT_BITMAP_TIMES_ROMAN_10      = Pointer(4);
  GLUT_BITMAP_TIMES_ROMAN_24      = Pointer(5);
  GLUT_BITMAP_HELVETICA_10        = Pointer(6);
  GLUT_BITMAP_HELVETICA_12        = Pointer(7);
  GLUT_BITMAP_HELVETICA_18        = Pointer(8);
{$else Windows}
var
  // Stroke font constants (use these in GLUT program).
  GLUT_STROKE_ROMAN               : Pointer;
  GLUT_STROKE_MONO_ROMAN          : Pointer;

  // Bitmap font constants (use these in GLUT program).
  GLUT_BITMAP_9_BY_15             : Pointer;
  GLUT_BITMAP_8_BY_13             : Pointer;
  GLUT_BITMAP_TIMES_ROMAN_10      : Pointer;
  GLUT_BITMAP_TIMES_ROMAN_24      : Pointer;
  GLUT_BITMAP_HELVETICA_10        : Pointer;
  GLUT_BITMAP_HELVETICA_12        : Pointer;
  GLUT_BITMAP_HELVETICA_18        : Pointer;

const
{$endif Windows}

  // glutGet parameters.
  GLUT_WINDOW_X                   = 100;
  GLUT_WINDOW_Y                   = 101;
  GLUT_WINDOW_WIDTH               = 102;
  GLUT_WINDOW_HEIGHT              = 103;
  GLUT_WINDOW_BUFFER_SIZE         = 104;
  GLUT_WINDOW_STENCIL_SIZE        = 105;
  GLUT_WINDOW_DEPTH_SIZE          = 106;
  GLUT_WINDOW_RED_SIZE            = 107;
  GLUT_WINDOW_GREEN_SIZE          = 108;
  GLUT_WINDOW_BLUE_SIZE           = 109;
  GLUT_WINDOW_ALPHA_SIZE          = 110;
  GLUT_WINDOW_ACCUM_RED_SIZE      = 111;
  GLUT_WINDOW_ACCUM_GREEN_SIZE    = 112;
  GLUT_WINDOW_ACCUM_BLUE_SIZE     = 113;
  GLUT_WINDOW_ACCUM_ALPHA_SIZE    = 114;
  GLUT_WINDOW_DOUBLEBUFFER        = 115;
  GLUT_WINDOW_RGBA                = 116;
  GLUT_WINDOW_PARENT              = 117;
  GLUT_WINDOW_NUM_CHILDREN        = 118;
  GLUT_WINDOW_COLORMAP_SIZE       = 119;
  GLUT_WINDOW_NUM_SAMPLES         = 120;
  GLUT_WINDOW_STEREO              = 121;
  GLUT_WINDOW_CURSOR              = 122;
  GLUT_SCREEN_WIDTH               = 200;
  GLUT_SCREEN_HEIGHT              = 201;
  GLUT_SCREEN_WIDTH_MM            = 202;
  GLUT_SCREEN_HEIGHT_MM           = 203;
  GLUT_MENU_NUM_ITEMS             = 300;
  GLUT_DISPLAY_MODE_POSSIBLE      = 400;
  GLUT_INIT_WINDOW_X              = 500;
  GLUT_INIT_WINDOW_Y              = 501;
  GLUT_INIT_WINDOW_WIDTH          = 502;
  GLUT_INIT_WINDOW_HEIGHT         = 503;
  GLUT_INIT_DISPLAY_MODE          = 504;
  GLUT_ELAPSED_TIME               = 700;
  GLUT_WINDOW_FORMAT_ID		  = 123;

  // glutDeviceGet parameters.
  GLUT_HAS_KEYBOARD               = 600;
  GLUT_HAS_MOUSE                  = 601;
  GLUT_HAS_SPACEBALL              = 602;
  GLUT_HAS_DIAL_AND_BUTTON_BOX    = 603;
  GLUT_HAS_TABLET                 = 604;
  GLUT_NUM_MOUSE_BUTTONS          = 605;
  GLUT_NUM_SPACEBALL_BUTTONS      = 606;
  GLUT_NUM_BUTTON_BOX_BUTTONS     = 607;
  GLUT_NUM_DIALS                  = 608;
  GLUT_NUM_TABLET_BUTTONS         = 609;
  GLUT_DEVICE_IGNORE_KEY_REPEAT   = 610;
  GLUT_DEVICE_KEY_REPEAT          = 611;
  GLUT_HAS_JOYSTICK               = 612;
  GLUT_OWNS_JOYSTICK              = 613;
  GLUT_JOYSTICK_BUTTONS           = 614;
  GLUT_JOYSTICK_AXES              = 615;
  GLUT_JOYSTICK_POLL_RATE         = 616;


  // glutLayerGet parameters.
  GLUT_OVERLAY_POSSIBLE           = 800;
  GLUT_LAYER_IN_USE               = 801;
  GLUT_HAS_OVERLAY                = 802;
  GLUT_TRANSPARENT_INDEX          = 803;
  GLUT_NORMAL_DAMAGED             = 804;
  GLUT_OVERLAY_DAMAGED            = 805;

  // glutVideoResizeGet parameters.
  GLUT_VIDEO_RESIZE_POSSIBLE       = 900;
  GLUT_VIDEO_RESIZE_IN_USE         = 901;
  GLUT_VIDEO_RESIZE_X_DELTA        = 902;
  GLUT_VIDEO_RESIZE_Y_DELTA        = 903;
  GLUT_VIDEO_RESIZE_WIDTH_DELTA    = 904;
  GLUT_VIDEO_RESIZE_HEIGHT_DELTA   = 905;
  GLUT_VIDEO_RESIZE_X              = 906;
  GLUT_VIDEO_RESIZE_Y              = 907;
  GLUT_VIDEO_RESIZE_WIDTH          = 908;
  GLUT_VIDEO_RESIZE_HEIGHT         = 909;

  // glutGetModifiers return mask.
  GLUT_ACTIVE_SHIFT                = 1;
  GLUT_ACTIVE_CTRL                 = 2;
  GLUT_ACTIVE_ALT                  = 4;

  // glutSetCursor parameters.
  // Basic arrows.
  GLUT_CURSOR_RIGHT_ARROW          = 0;
  GLUT_CURSOR_LEFT_ARROW           = 1;
  // Symbolic cursor shapes.
  GLUT_CURSOR_INFO                 = 2;
  GLUT_CURSOR_DESTROY              = 3;
  GLUT_CURSOR_HELP                 = 4;
  GLUT_CURSOR_CYCLE                = 5;
  GLUT_CURSOR_SPRAY                = 6;
  GLUT_CURSOR_WAIT                 = 7;
  GLUT_CURSOR_TEXT                 = 8;
  GLUT_CURSOR_CROSSHAIR            = 9;
  // Directional cursors.
  GLUT_CURSOR_UP_DOWN              = 10;
  GLUT_CURSOR_LEFT_RIGHT           = 11;
  // Sizing cursors.
  GLUT_CURSOR_TOP_SIDE             = 12;
  GLUT_CURSOR_BOTTOM_SIDE          = 13;
  GLUT_CURSOR_LEFT_SIDE            = 14;
  GLUT_CURSOR_RIGHT_SIDE           = 15;
  GLUT_CURSOR_TOP_LEFT_CORNER      = 16;
  GLUT_CURSOR_TOP_RIGHT_CORNER     = 17;
  GLUT_CURSOR_BOTTOM_RIGHT_CORNER  = 18;
  GLUT_CURSOR_BOTTOM_LEFT_CORNER   = 19;
  // Inherit from parent window.
  GLUT_CURSOR_INHERIT              = 100;
  // Blank cursor.
  GLUT_CURSOR_NONE                 = 101;
  // Fullscreen crosshair (if available).
  GLUT_CURSOR_FULL_CROSSHAIR       = 102;

  // GLUT device control sub-API.
  // glutSetKeyRepeat modes.
  GLUT_KEY_REPEAT_OFF      = 0;
  GLUT_KEY_REPEAT_ON       = 1;
  GLUT_KEY_REPEAT_DEFAULT  = 2;

// Joystick button masks.
  GLUT_JOYSTICK_BUTTON_A = 1;
  GLUT_JOYSTICK_BUTTON_B = 2;
  GLUT_JOYSTICK_BUTTON_C = 4;
  GLUT_JOYSTICK_BUTTON_D = 8;

  // GLUT game mode sub-API.
  // glutGameModeGet.
  GLUT_GAME_MODE_ACTIVE           = 0;
  GLUT_GAME_MODE_POSSIBLE         = 1;
  GLUT_GAME_MODE_WIDTH            = 2;
  GLUT_GAME_MODE_HEIGHT           = 3;
  GLUT_GAME_MODE_PIXEL_DEPTH      = 4;
  GLUT_GAME_MODE_REFRESH_RATE     = 5;
  GLUT_GAME_MODE_DISPLAY_CHANGED  = 6;

{$IFDEF MORPHOS}

{ MorphOS GL works differently due to different dynamic-library handling on Amiga-like }
{ systems, so its headers are included here. }
{$INCLUDE tinyglh.inc}

{$ELSE MORPHOS}

var
// GLUT initialization sub-API.
  glutInit: procedure(argcp: PInteger; argv: PPChar); extdecl;
  glutInitDisplayMode: procedure(mode: Cardinal); extdecl;
  glutInitDisplayString: procedure(const str: PChar); extdecl;
  glutInitWindowPosition: procedure(x, y: Integer); extdecl;
  glutInitWindowSize: procedure(width, height: Integer); extdecl;
  glutMainLoop: procedure; extdecl;

// GLUT window sub-API.
  glutCreateWindow: function(const title: PChar): Integer; extdecl;
  glutCreateSubWindow: function(win, x, y, width, height: Integer): Integer; extdecl;
  glutDestroyWindow: procedure(win: Integer); extdecl;
  glutPostRedisplay: procedure; extdecl;
  glutPostWindowRedisplay: procedure(win: Integer); extdecl;
  glutSwapBuffers: procedure; extdecl;
  glutGetWindow: function: Integer; extdecl;
  glutSetWindow: procedure(win: Integer); extdecl;
  glutSetWindowTitle: procedure(const title: PChar); extdecl;
  glutSetIconTitle: procedure(const title: PChar); extdecl;
  glutPositionWindow: procedure(x, y: Integer); extdecl;
  glutReshapeWindow: procedure(width, height: Integer); extdecl;
  glutPopWindow: procedure; extdecl;
  glutPushWindow: procedure; extdecl;
  glutIconifyWindow: procedure; extdecl;
  glutShowWindow: procedure; extdecl;
  glutHideWindow: procedure; extdecl;
  glutFullScreen: procedure; extdecl;
  glutSetCursor: procedure(cursor: Integer); extdecl;
  glutWarpPointer: procedure(x, y: Integer); extdecl;

// GLUT overlay sub-API.
  glutEstablishOverlay: procedure; extdecl;
  glutRemoveOverlay: procedure; extdecl;
  glutUseLayer: procedure(layer: GLenum); extdecl;
  glutPostOverlayRedisplay: procedure; extdecl;
  glutPostWindowOverlayRedisplay: procedure(win: Integer); extdecl;
  glutShowOverlay: procedure; extdecl;
  glutHideOverlay: procedure; extdecl;

// GLUT menu sub-API.
  glutCreateMenu: function(callback: TGlut1IntCallback): Integer; extdecl;
  glutDestroyMenu: procedure(menu: Integer); extdecl;
  glutGetMenu: function: Integer; extdecl;
  glutSetMenu: procedure(menu: Integer); extdecl;
  glutAddMenuEntry: procedure(const caption: PChar; value: Integer); extdecl;
  glutAddSubMenu: procedure(const caption: PChar; submenu: Integer); extdecl;
  glutChangeToMenuEntry: procedure(item: Integer; const caption: PChar; value: Integer); extdecl;
  glutChangeToSubMenu: procedure(item: Integer; const caption: PChar; submenu: Integer); extdecl;
  glutRemoveMenuItem: procedure(item: Integer); extdecl;
  glutAttachMenu: procedure(button: Integer); extdecl;
  glutDetachMenu: procedure(button: Integer); extdecl;

// GLUT window callback sub-API.
  glutDisplayFunc: procedure(f: TGlutVoidCallback); extdecl;
  glutReshapeFunc: procedure(f: TGlut2IntCallback); extdecl;
  glutKeyboardFunc: procedure(f: TGlut1Char2IntCallback); extdecl;
  glutMouseFunc: procedure(f: TGlut4IntCallback); extdecl;
  glutMotionFunc: procedure(f: TGlut2IntCallback); extdecl;
  glutPassiveMotionFunc: procedure(f: TGlut2IntCallback); extdecl;
  glutEntryFunc: procedure(f: TGlut1IntCallback); extdecl;
  glutVisibilityFunc: procedure(f: TGlut1IntCallback); extdecl;
  glutIdleFunc: procedure(f: TGlutVoidCallback); extdecl;
  glutTimerFunc: procedure(millis: Cardinal; f: TGlut1IntCallback; value: Integer); extdecl;
  glutMenuStateFunc: procedure(f: TGlut1IntCallback); extdecl;
  glutSpecialFunc: procedure(f: TGlut3IntCallback); extdecl;
  glutSpaceballMotionFunc: procedure(f: TGlut3IntCallback); extdecl;
  glutSpaceballRotateFunc: procedure(f: TGlut3IntCallback); extdecl;
  glutSpaceballButtonFunc: procedure(f: TGlut2IntCallback); extdecl;
  glutButtonBoxFunc: procedure(f: TGlut2IntCallback); extdecl;
  glutDialsFunc: procedure(f: TGlut2IntCallback); extdecl;
  glutTabletMotionFunc: procedure(f: TGlut2IntCallback); extdecl;
  glutTabletButtonFunc: procedure(f: TGlut4IntCallback); extdecl;
  glutMenuStatusFunc: procedure(f: TGlut3IntCallback); extdecl;
  glutOverlayDisplayFunc: procedure(f:TGlutVoidCallback); extdecl;
  glutWindowStatusFunc: procedure(f: TGlut1IntCallback); extdecl;
  glutKeyboardUpFunc: procedure(f: TGlut1Char2IntCallback); extdecl;
  glutSpecialUpFunc: procedure(f: TGlut3IntCallback); extdecl;
  glutJoystickFunc: procedure(f: TGlut1UInt3IntCallback; pollInterval: Integer); extdecl;

// GLUT color index sub-API.
  glutSetColor: procedure(cell: Integer; red, green, blue: GLfloat); extdecl;
  glutGetColor: function(ndx, component: Integer): GLfloat; extdecl;
  glutCopyColormap: procedure(win: Integer); extdecl;

// GLUT state retrieval sub-API.
  glutGet: function(t: GLenum): Integer; extdecl;
  glutDeviceGet: function(t: GLenum): Integer; extdecl;

// GLUT extension support sub-API
  glutExtensionSupported: function(const name: PChar): Integer; extdecl;
  glutGetModifiers: function: Integer; extdecl;
  glutLayerGet: function(t: GLenum): Integer; extdecl;

// GLUT font sub-API
  glutBitmapCharacter: procedure(font : pointer; character: Integer); extdecl;
  glutBitmapWidth: function(font : pointer; character: Integer): Integer; extdecl;
  glutStrokeCharacter: procedure(font : pointer; character: Integer); extdecl;
  glutStrokeWidth: function(font : pointer; character: Integer): Integer; extdecl;
  glutBitmapLength: function(font: pointer; const str: PChar): Integer; extdecl;
  glutStrokeLength: function(font: pointer; const str: PChar): Integer; extdecl;

// GLUT pre-built models sub-API
  glutWireSphere: procedure(radius: GLdouble; slices, stacks: GLint); extdecl;
  glutSolidSphere: procedure(radius: GLdouble; slices, stacks: GLint); extdecl;
  glutWireCone: procedure(base, height: GLdouble; slices, stacks: GLint); extdecl;
  glutSolidCone: procedure(base, height: GLdouble; slices, stacks: GLint); extdecl;
  glutWireCube: procedure(size: GLdouble); extdecl;
  glutSolidCube: procedure(size: GLdouble); extdecl;
  glutWireTorus: procedure(innerRadius, outerRadius: GLdouble; sides, rings: GLint); extdecl;
  glutSolidTorus: procedure(innerRadius, outerRadius: GLdouble; sides, rings: GLint); extdecl;
  glutWireDodecahedron: procedure; extdecl;
  glutSolidDodecahedron: procedure; extdecl;
  glutWireTeapot: procedure(size: GLdouble); extdecl;
  glutSolidTeapot: procedure(size: GLdouble); extdecl;
  glutWireOctahedron: procedure; extdecl;
  glutSolidOctahedron: procedure; extdecl;
  glutWireTetrahedron: procedure; extdecl;
  glutSolidTetrahedron: procedure; extdecl;
  glutWireIcosahedron: procedure; extdecl;
  glutSolidIcosahedron: procedure; extdecl;

// GLUT video resize sub-API.
  glutVideoResizeGet: function(param: GLenum): Integer; extdecl;
  glutSetupVideoResizing: procedure; extdecl;
  glutStopVideoResizing: procedure; extdecl;
  glutVideoResize: procedure(x, y, width, height: Integer); extdecl;
  glutVideoPan: procedure(x, y, width, height: Integer); extdecl;

// GLUT debugging sub-API.
  glutReportErrors: procedure; extdecl;

// GLUT device control sub-API.

  glutIgnoreKeyRepeat: procedure(ignore: Integer); extdecl;
  glutSetKeyRepeat: procedure(repeatMode: Integer); extdecl;
  glutForceJoystickFunc: procedure; extdecl;

// GLUT game mode sub-API.

  //example glutGameModeString('1280x1024:32@75');
  glutGameModeString : procedure (const AString : PChar); extdecl;
  glutEnterGameMode : function : integer; extdecl;
  glutLeaveGameMode : procedure; extdecl;
  glutGameModeGet : function (mode : GLenum) : integer; extdecl;
{$ENDIF MORPHOS}

implementation

{$IFDEF MORPHOS}

{ MorphOS GL works differently due to different dynamic-library handling on Amiga-like }
{ systems, so its functions are included here. }
{$INCLUDE tinygl.inc}

uses
	 SaGeBase
	,SaGeLists
	,SaGeDllManager
	,SaGeSysUtils
	;

{$ELSE MORPHOS}

uses 
	 FreeGlut
	,SaGeBase
	,SaGeLists
	,SaGeDllManager
	,SaGeSysUtils
	;
{$ENDIF MORPHOS}

type
	TSGDllGLUT = class(TSGDll)
			public
		class function SystemNames() : TSGStringList; override;
		class function DllNames() : TSGStringList; override;
		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; override;
		class function ChildNames() : TSGStringList; override;
		class procedure Free(); override;
		end;

class function TSGDllGLUT.ChildNames() : TSGStringList;
begin
Result := 'freeglut';
end;

class procedure TSGDllGLUT.Free(); 
begin
{$IFDEF MORPHOS}
  // MorphOS's GL will closed down by TinyGL unit, nothing is needed here.
{$ELSE MORPHOS}
  @glutInit := nil;
  @glutInitDisplayMode := nil;
  @glutInitDisplayString := nil;
  @glutInitWindowPosition := nil;
  @glutInitWindowSize := nil;
  @glutMainLoop := nil;
  @glutCreateWindow := nil;
  @glutCreateSubWindow := nil;
  @glutDestroyWindow := nil;
  @glutPostRedisplay := nil;
  @glutPostWindowRedisplay := nil;
  @glutSwapBuffers := nil;
  @glutGetWindow := nil;
  @glutSetWindow := nil;
  @glutSetWindowTitle := nil;
  @glutSetIconTitle := nil;
  @glutPositionWindow := nil;
  @glutReshapeWindow := nil;
  @glutPopWindow := nil;
  @glutPushWindow := nil;
  @glutIconifyWindow := nil;
  @glutShowWindow := nil;
  @glutHideWindow := nil;
  @glutFullScreen := nil;
  @glutSetCursor := nil;
  @glutWarpPointer := nil;
  @glutEstablishOverlay := nil;
  @glutRemoveOverlay := nil;
  @glutUseLayer := nil;
  @glutPostOverlayRedisplay := nil;
  @glutPostWindowOverlayRedisplay := nil;
  @glutShowOverlay := nil;
  @glutHideOverlay := nil;
  @glutCreateMenu := nil;
  @glutDestroyMenu := nil;
  @glutGetMenu := nil;
  @glutSetMenu := nil;
  @glutAddMenuEntry := nil;
  @glutAddSubMenu := nil;
  @glutChangeToMenuEntry := nil;
  @glutChangeToSubMenu := nil;
  @glutRemoveMenuItem := nil;
  @glutAttachMenu := nil;
  @glutDetachMenu := nil;
  @glutDisplayFunc := nil;
  @glutReshapeFunc := nil;
  @glutKeyboardFunc := nil;
  @glutMouseFunc := nil;
  @glutMotionFunc := nil;
  @glutPassiveMotionFunc := nil;
  @glutEntryFunc := nil;
  @glutVisibilityFunc := nil;
  @glutIdleFunc := nil;
  @glutTimerFunc := nil;
  @glutMenuStateFunc := nil;
  @glutSpecialFunc := nil;
  @glutSpaceballMotionFunc := nil;
  @glutSpaceballRotateFunc := nil;
  @glutSpaceballButtonFunc := nil;
  @glutButtonBoxFunc := nil;
  @glutDialsFunc := nil;
  @glutTabletMotionFunc := nil;
  @glutTabletButtonFunc := nil;
  @glutMenuStatusFunc := nil;
  @glutOverlayDisplayFunc := nil;
  @glutWindowStatusFunc := nil;
  @glutKeyboardUpFunc := nil;
  @glutSpecialUpFunc := nil;
  @glutJoystickFunc := nil;
  @glutSetColor := nil;
  @glutGetColor := nil;
  @glutCopyColormap := nil;
  @glutGet := nil;
  @glutDeviceGet := nil;
  @glutExtensionSupported := nil;
  @glutGetModifiers := nil;
  @glutLayerGet := nil;
  @glutBitmapCharacter := nil;
  @glutBitmapWidth := nil;
  @glutStrokeCharacter := nil;
  @glutStrokeWidth := nil;
  @glutBitmapLength := nil;
  @glutStrokeLength := nil;
  @glutWireSphere := nil;
  @glutSolidSphere := nil;
  @glutWireCone := nil;
  @glutSolidCone := nil;
  @glutWireCube := nil;
  @glutSolidCube := nil;
  @glutWireTorus := nil;
  @glutSolidTorus := nil;
  @glutWireDodecahedron := nil;
  @glutSolidDodecahedron := nil;
  @glutWireTeapot := nil;
  @glutSolidTeapot := nil;
  @glutWireOctahedron := nil;
  @glutSolidOctahedron := nil;
  @glutWireTetrahedron := nil;
  @glutSolidTetrahedron := nil;
  @glutWireIcosahedron := nil;
  @glutSolidIcosahedron := nil;
  @glutVideoResizeGet := nil;
  @glutSetupVideoResizing := nil;
  @glutStopVideoResizing := nil;
  @glutVideoResize := nil;
  @glutVideoPan := nil;
  @glutReportErrors := nil;
  @glutIgnoreKeyRepeat := nil;
  @glutSetKeyRepeat := nil;
  @glutForceJoystickFunc := nil;
  @glutGameModeString := nil;
  @glutEnterGameMode := nil;
  @glutLeaveGameMode := nil;
  @glutGameModeGet := nil;
{$ENDIF MORPHOS}
end;

class function TSGDllGLUT.Load(const VDll : TSGLibHandle) : TSGDllLoadObject;
{$IFDEF MORPHOS}
begin
Result.Clear();
  // MorphOS's GL has own initialization in TinyGL unit, nothing is needed here.
end;
{$ELSE MORPHOS}
var
	LoadResult : PSGDllLoadObject = nil;

function GetGLutProcAddress(const ProcName: PChar): Pointer;
begin
Result := GetProcAddress(VDll, ProcName);
LoadResult^.FFunctionCount += 1;
if Result <> nil then
	LoadResult^.FFunctionLoaded += 1;
end;

begin
Result.Clear();
LoadResult := @Result;
  try
    @glutInit := GetGLutProcAddress('glutInit');
    @glutInitDisplayMode := GetGLutProcAddress('glutInitDisplayMode');
    @glutInitDisplayString := GetGLutProcAddress('glutInitDisplayString');
    @glutInitWindowPosition := GetGLutProcAddress('glutInitWindowPosition');
    @glutInitWindowSize := GetGLutProcAddress('glutInitWindowSize');
    @glutMainLoop := GetGLutProcAddress('glutMainLoop');
    @glutCreateWindow := GetGLutProcAddress('glutCreateWindow');
    @glutCreateSubWindow := GetGLutProcAddress('glutCreateSubWindow');
    @glutDestroyWindow := GetGLutProcAddress('glutDestroyWindow');
    @glutPostRedisplay := GetGLutProcAddress('glutPostRedisplay');
    @glutPostWindowRedisplay := GetGLutProcAddress('glutPostWindowRedisplay');
    @glutSwapBuffers := GetGLutProcAddress('glutSwapBuffers');
    @glutGetWindow := GetGLutProcAddress('glutGetWindow');
    @glutSetWindow := GetGLutProcAddress('glutSetWindow');
    @glutSetWindowTitle := GetGLutProcAddress('glutSetWindowTitle');
    @glutSetIconTitle := GetGLutProcAddress('glutSetIconTitle');
    @glutPositionWindow := GetGLutProcAddress('glutPositionWindow');
    @glutReshapeWindow := GetGLutProcAddress('glutReshapeWindow');
    @glutPopWindow := GetGLutProcAddress('glutPopWindow');
    @glutPushWindow := GetGLutProcAddress('glutPushWindow');
    @glutIconifyWindow := GetGLutProcAddress('glutIconifyWindow');
    @glutShowWindow := GetGLutProcAddress('glutShowWindow');
    @glutHideWindow := GetGLutProcAddress('glutHideWindow');
    @glutFullScreen := GetGLutProcAddress('glutFullScreen');
    @glutSetCursor := GetGLutProcAddress('glutSetCursor');
    @glutWarpPointer := GetGLutProcAddress('glutWarpPointer');
    @glutEstablishOverlay := GetGLutProcAddress('glutEstablishOverlay');
    @glutRemoveOverlay := GetGLutProcAddress('glutRemoveOverlay');
    @glutUseLayer := GetGLutProcAddress('glutUseLayer');
    @glutPostOverlayRedisplay := GetGLutProcAddress('glutPostOverlayRedisplay');
    @glutPostWindowOverlayRedisplay := GetGLutProcAddress('glutPostWindowOverlayRedisplay');
    @glutShowOverlay := GetGLutProcAddress('glutShowOverlay');
    @glutHideOverlay := GetGLutProcAddress('glutHideOverlay');
    @glutCreateMenu := GetGLutProcAddress('glutCreateMenu');
    @glutDestroyMenu := GetGLutProcAddress('glutDestroyMenu');
    @glutGetMenu := GetGLutProcAddress('glutGetMenu');
    @glutSetMenu := GetGLutProcAddress('glutSetMenu');
    @glutAddMenuEntry := GetGLutProcAddress('glutAddMenuEntry');
    @glutAddSubMenu := GetGLutProcAddress('glutAddSubMenu');
    @glutChangeToMenuEntry := GetGLutProcAddress('glutChangeToMenuEntry');
    @glutChangeToSubMenu := GetGLutProcAddress('glutChangeToSubMenu');
    @glutRemoveMenuItem := GetGLutProcAddress('glutRemoveMenuItem');
    @glutAttachMenu := GetGLutProcAddress('glutAttachMenu');
    @glutDetachMenu := GetGLutProcAddress('glutDetachMenu');
    @glutDisplayFunc := GetGLutProcAddress('glutDisplayFunc');
    @glutReshapeFunc := GetGLutProcAddress('glutReshapeFunc');
    @glutKeyboardFunc := GetGLutProcAddress('glutKeyboardFunc');
    @glutMouseFunc := GetGLutProcAddress('glutMouseFunc');
    @glutMotionFunc := GetGLutProcAddress('glutMotionFunc');
    @glutPassiveMotionFunc := GetGLutProcAddress('glutPassiveMotionFunc');
    @glutEntryFunc := GetGLutProcAddress('glutEntryFunc');
    @glutVisibilityFunc := GetGLutProcAddress('glutVisibilityFunc');
    @glutIdleFunc := GetGLutProcAddress('glutIdleFunc');
    @glutTimerFunc := GetGLutProcAddress('glutTimerFunc');
    @glutMenuStateFunc := GetGLutProcAddress('glutMenuStateFunc');
    @glutSpecialFunc := GetGLutProcAddress('glutSpecialFunc');
    @glutSpaceballMotionFunc := GetGLutProcAddress('glutSpaceballMotionFunc');
    @glutSpaceballRotateFunc := GetGLutProcAddress('glutSpaceballRotateFunc');
    @glutSpaceballButtonFunc := GetGLutProcAddress('glutSpaceballButtonFunc');
    @glutButtonBoxFunc := GetGLutProcAddress('glutButtonBoxFunc');
    @glutDialsFunc := GetGLutProcAddress('glutDialsFunc');
    @glutTabletMotionFunc := GetGLutProcAddress('glutTabletMotionFunc');
    @glutTabletButtonFunc := GetGLutProcAddress('glutTabletButtonFunc');
    @glutMenuStatusFunc := GetGLutProcAddress('glutMenuStatusFunc');
    @glutOverlayDisplayFunc := GetGLutProcAddress('glutOverlayDisplayFunc');
    @glutWindowStatusFunc := GetGLutProcAddress('glutWindowStatusFunc');
    @glutKeyboardUpFunc := GetGLutProcAddress('glutKeyboardUpFunc');
    @glutSpecialUpFunc := GetGLutProcAddress('glutSpecialUpFunc');
    @glutJoystickFunc := GetGLutProcAddress('glutJoystickFunc');
    @glutSetColor := GetGLutProcAddress('glutSetColor');
    @glutGetColor := GetGLutProcAddress('glutGetColor');
    @glutCopyColormap := GetGLutProcAddress('glutCopyColormap');
    @glutGet := GetGLutProcAddress('glutGet');
    @glutDeviceGet := GetGLutProcAddress('glutDeviceGet');
    @glutExtensionSupported := GetGLutProcAddress('glutExtensionSupported');
    @glutGetModifiers := GetGLutProcAddress('glutGetModifiers');
    @glutLayerGet := GetGLutProcAddress('glutLayerGet');
    @glutBitmapCharacter := GetGLutProcAddress('glutBitmapCharacter');
    @glutBitmapWidth := GetGLutProcAddress('glutBitmapWidth');
    @glutStrokeCharacter := GetGLutProcAddress('glutStrokeCharacter');
    @glutStrokeWidth := GetGLutProcAddress('glutStrokeWidth');
    @glutBitmapLength := GetGLutProcAddress('glutBitmapLength');
    @glutStrokeLength := GetGLutProcAddress('glutStrokeLength');
    @glutWireSphere := GetGLutProcAddress('glutWireSphere');
    @glutSolidSphere := GetGLutProcAddress('glutSolidSphere');
    @glutWireCone := GetGLutProcAddress('glutWireCone');
    @glutSolidCone := GetGLutProcAddress('glutSolidCone');
    @glutWireCube := GetGLutProcAddress('glutWireCube');
    @glutSolidCube := GetGLutProcAddress('glutSolidCube');
    @glutWireTorus := GetGLutProcAddress('glutWireTorus');
    @glutSolidTorus := GetGLutProcAddress('glutSolidTorus');
    @glutWireDodecahedron := GetGLutProcAddress('glutWireDodecahedron');
    @glutSolidDodecahedron := GetGLutProcAddress('glutSolidDodecahedron');
    @glutWireTeapot := GetGLutProcAddress('glutWireTeapot');
    @glutSolidTeapot := GetGLutProcAddress('glutSolidTeapot');
    @glutWireOctahedron := GetGLutProcAddress('glutWireOctahedron');
    @glutSolidOctahedron := GetGLutProcAddress('glutSolidOctahedron');
    @glutWireTetrahedron := GetGLutProcAddress('glutWireTetrahedron');
    @glutSolidTetrahedron := GetGLutProcAddress('glutSolidTetrahedron');
    @glutWireIcosahedron := GetGLutProcAddress('glutWireIcosahedron');
    @glutSolidIcosahedron := GetGLutProcAddress('glutSolidIcosahedron');
    @glutVideoResizeGet := GetGLutProcAddress('glutVideoResizeGet');
    @glutSetupVideoResizing := GetGLutProcAddress('glutSetupVideoResizing');
    @glutStopVideoResizing := GetGLutProcAddress('glutStopVideoResizing');
    @glutVideoResize := GetGLutProcAddress('glutVideoResize');
    @glutVideoPan := GetGLutProcAddress('glutVideoPan');
    @glutReportErrors := GetGLutProcAddress('glutReportErrors');
    @glutIgnoreKeyRepeat := GetGLutProcAddress('glutIgnoreKeyRepeat');
    @glutSetKeyRepeat := GetGLutProcAddress('glutSetKeyRepeat');
    @glutForceJoystickFunc := GetGLutProcAddress('glutForceJoystickFunc');
    @glutGameModeString := GetGLutProcAddress('glutGameModeString');
    @glutEnterGameMode := GetGLutProcAddress('glutEnterGameMode');
    @glutLeaveGameMode := GetGLutProcAddress('glutLeaveGameMode');
    @glutGameModeGet := GetGLutProcAddress('glutGameModeGet');
{$ifndef Windows}
    GLUT_STROKE_ROMAN := GetGLutProcAddress('glutStrokeRoman');
    GLUT_STROKE_MONO_ROMAN := GetGLutProcAddress('glutStrokeMonoRoman');
    GLUT_BITMAP_9_BY_15 := GetGLutProcAddress('glutBitmap9By15');
    GLUT_BITMAP_8_BY_13 := GetGLutProcAddress('glutBitmap8By13');
    GLUT_BITMAP_TIMES_ROMAN_10 := GetGLutProcAddress('glutBitmapTimesRoman10');
    GLUT_BITMAP_TIMES_ROMAN_24 := GetGLutProcAddress('glutBitmapTimesRoman24');
    GLUT_BITMAP_HELVETICA_10 := GetGLutProcAddress('glutBitmapHelvetica10');
    GLUT_BITMAP_HELVETICA_12 := GetGLutProcAddress('glutBitmapHelvetica12');
    GLUT_BITMAP_HELVETICA_18 := GetGLutProcAddress('glutBitmapHelvetica18');
{$endif Windows}
  except
    
  end;
end;
{$ENDIF MORPHOS}

class function TSGDllGLUT.SystemNames() : TSGStringList; 
begin
Result := 'GLUT';
Result += 'LibGlut';
Result += 'Glut32';
end;

class function TSGDllGLUT.DllNames() : TSGStringList;
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

initialization
begin
TSGDllGLUT.Create();
end;

end.
