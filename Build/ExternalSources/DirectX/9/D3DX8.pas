{******************************************************************************}
{*                                                                            *}
{*  Copyright (C) Microsoft Corporation.  All Rights Reserved.                *}
{*                                                                            *}
{*  File:       d3dx8.h, d3dx8core.h, d3dx8math.h, d3dx8math.inl,             *}
{*              d3dx8effect.h, d3dx8mesh.h, d3dx8shape.h, d3dx8tex.h          *}
{*  Content:    Direct3DX 8.1 headers                                         *}
{*                                                                            *}
{*  Direct3DX 8.1 Delphi adaptation by Alexey Barkovoy                        *}
{*  E-Mail: directx@clootie.ru                                                *}
{*                                                                            *}
{*  Modified: 12-Feb-2005                                                     *}
{*                                                                            *}
{*  Partly based upon :                                                       *}
{*    Direct3DX 7.0 Delphi adaptation by                                      *}
{*      Arne Sch�pers, e-Mail: [look at www.delphi-jedi.org/DelphiGraphics/]  *}
{*                                                                            *}
{*  Latest version can be downloaded from:                                    *}
{*    http://clootie.ru                                                       *}
{*    http://sourceforge.net/projects/delphi-dx9sdk                           *}
{*                                                                            *}
{*  This File contains only Direct3DX 8.x Definitions.                        *}
{*  If you want to use D3DX7 version of D3DX use translation by Arne Sch�pers *}
{*                                                                            *}
{******************************************************************************}
{                                                                              }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{                                                                              }
{ The contents of this file are used with permission, subject to the Mozilla   }
{ Public License Version 1.1 (the "License"); you may not use this file except }
{ in compliance with the License. You may obtain a copy of the License at      }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ Alternatively, the contents of this file may be used under the terms of the  }
{ GNU Lesser General Public License (the  "LGPL License"), in which case the   }
{ provisions of the LGPL License are applicable instead of those above.        }
{ If you wish to allow use of your version of this file only under the terms   }
{ of the LGPL License and not to allow others to use your version of this file }
{ under the MPL, indicate your decision by deleting  the provisions above and  }
{ replace  them with the notice and other provisions required by the LGPL      }
{ License.  If you do not delete the provisions above, a recipient may use     }
{ your version of this file under either the MPL or the LGPL License.          }
{                                                                              }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{                                                                              }
{******************************************************************************}

// Original source contained in "D3DX8.par"

{$I DirectX.inc}

unit D3DX8;

interface

// Remove "dot" below to link with debug version of D3DX8
// (for Delphi it works only in JEDI version of headers)
{.$DEFINE DEBUG}


// Do not emit <DXFile.hpp> to C++Builder



uses
  Windows, ActiveX,
  SysUtils, Direct3D8, DXFile;

const
  //////////// DLL export definitions ///////////////////////////////////////
  d3dx8dll ={$IFDEF DEBUG} 'd3dx8d.dll'{$ELSE} 'D3DX81ab.dll'{$ENDIF};


///////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8.h
//  Content:    D3DX utility library
//
///////////////////////////////////////////////////////////////////////////

const
  // #define D3DX_DEFAULT ULONG_MAX
  D3DX_DEFAULT          = $FFFFFFFF;

var
  // #define D3DX_DEFAULT_FLOAT FLT_MAX
  // Forced to define as 'var' cos pascal compiler treats all consts as Double
  D3DX_DEFAULT_FLOAT: Single = 3.402823466e+38;  // max single value




//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8math.h
//  Content:    D3DX math types and functions
//
//////////////////////////////////////////////////////////////////////////////

//===========================================================================
//
// General purpose utilities
//
//===========================================================================
const
  D3DX_PI: Single       = 3.141592654;
  D3DX_1BYPI: Single    = 0.318309886;

//#define D3DXToRadian( degree ) ((degree) * (D3DX_PI / 180.0f))
function D3DXToRadian(Degree: Single): Single;
//#define D3DXToDegree( radian ) ((radian) * (180.0f / D3DX_PI))
function D3DXToDegree(Radian: Single): Single;


//===========================================================================
//
// Vectors
//
//===========================================================================

//--------------------------
// 2D Vector
//--------------------------
type
  PD3DXVector2 = ^TD3DXVector2;
  TD3DXVector2 = packed record
    x, y: Single;
  end;

// Some pascal equalents of C++ class functions & operators
const D3DXVector2Zero: TD3DXVector2 = (x:0; y:0);  // (0,0)
function D3DXVector2(_x, _y: Single): TD3DXVector2;
function D3DXVector2Equal(const v1, v2: TD3DXVector2): Boolean;


//--------------------------
// 3D Vector
//--------------------------
type
  PD3DXVector3 = ^TD3DXVector3;
  TD3DXVector3 = TD3DVector;

// Some pascal equalents of C++ class functions & operators
const D3DXVector3Zero: TD3DXVector3 = (x:0; y:0; z:0);  // (0,0,0)
function D3DXVector3(_x, _y, _z: Single): TD3DXVector3;
function D3DXVector3Equal(const v1, v2: TD3DXVector3): Boolean;


//--------------------------
// 4D Vector
//--------------------------
type
  PD3DXVector4 = ^TD3DXVector4;
  TD3DXVector4 = packed record
    x, y, z, w: Single;
  end;

// Some pascal equalents of C++ class functions & operators
const D3DXVector4Zero: TD3DXVector4 = (x:0; y:0; z:0; w:0);  // (0,0,0,0)
function D3DXVector4(_x, _y, _z, _w: Single): TD3DXVector4;
function D3DXVector4Equal(const v1, v2: TD3DXVector4): Boolean;

//===========================================================================
//
// Matrices
//
//===========================================================================
type
  PD3DXMatrix = ^TD3DXMatrix;
  TD3DXMatrix = TD3DMatrix;

// Some pascal equalents of C++ class functions & operators
function D3DXMatrix(
  _m00, _m01, _m02, _m03,
  _m10, _m11, _m12, _m13,
  _m20, _m21, _m22, _m23,
  _m30, _m31, _m32, _m33: Single): TD3DXMatrix;
function D3DXMatrixAdd(out mOut: TD3DXMatrix; const m1, m2: TD3DXMatrix): PD3DXMatrix;
function D3DXMatrixSubtract(out mOut: TD3DXMatrix; const m1, m2: TD3DXMatrix): PD3DXMatrix;
function D3DXMatrixMul(out mOut: TD3DXMatrix; const m: TD3DXMatrix; MulBy: Single): PD3DXMatrix;
function D3DXMatrixEqual(const m1, m2: TD3DXMatrix): Boolean;


//===========================================================================
//
// Aligned Matrices
//
// This class helps keep matrices 16-byte aligned as preferred by P4 cpus.
// It aligns matrices on the stack and on the heap or in global scope.
// It does this using __declspec(align(16)) which works on VC7 and on VC 6
// with the processor pack. Unfortunately there is no way to detect the
// latter so this is turned on only on VC7. On other compilers this is the
// the same as D3DXMATRIX.
// Using this class on a compiler that does not actually do the alignment
// can be dangerous since it will not expose bugs that ignore alignment.
// E.g if an object of this class in inside a struct or class, and some code
// memcopys data in it assuming tight packing. This could break on a compiler
// that eventually start aligning the matrix.
//
//===========================================================================

// Translator comments: None of current pascal compilers can even align data
// inside records to 16 byte boundary, so we just leave aligned matrix
// declaration equal to standart matrix
type
  PD3DXMatrixA16 = ^TD3DXMatrixA16;
  TD3DXMatrixA16 = TD3DXMatrix;


//===========================================================================
//
//    Quaternions
//
//===========================================================================
type
  PD3DXQuaternion = ^TD3DXQuaternion;
  TD3DXQuaternion = packed record
    x, y, z, w: Single;
  end;

// Some pascal equalents of C++ class functions & operators
function D3DXQuaternion(_x, _y, _z, _w: Single): TD3DXQuaternion;
function D3DXQuaternionAdd(const q1, q2: TD3DXQuaternion): TD3DXQuaternion;
function D3DXQuaternionSubtract(const q1, q2: TD3DXQuaternion): TD3DXQuaternion;
function D3DXQuaternionEqual(const q1, q2: TD3DXQuaternion): Boolean;
function D3DXQuaternionScale(out qOut: TD3DXQuaternion; const q: TD3DXQuaternion;
  s: Single): PD3DXQuaternion;


//===========================================================================
//
// Planes
//
//===========================================================================
type
  PD3DXPlane = ^TD3DXPlane;
  TD3DXPlane = packed record
    a, b, c, d: Single;
  end;

// Some pascal equalents of C++ class functions & operators
const D3DXPlaneZero: TD3DXPlane = (a:0; b:0; c:0; d:0);  // (0,0,0,0)
function D3DXPlane(_a, _b, _c, _d: Single): TD3DXPlane;
function D3DXPlaneEqual(const p1, p2: TD3DXPlane): Boolean;


//===========================================================================
//
// Colors
//
//===========================================================================
type
  PD3DXColor = PD3DColorValue;
  TD3DXColor = TD3DColorValue;

function D3DXColor(_r, _g, _b, _a: Single): TD3DXColor;
function D3DXColorToDWord(c: TD3DXColor): DWord;
function D3DXColorFromDWord(c: DWord): TD3DXColor;
function D3DXColorEqual(const c1, c2: TD3DXColor): Boolean;


//===========================================================================
//
// D3DX math functions:
//
// NOTE:
//  * All these functions can take the same object as in and out parameters.
//
//  * Out parameters are typically also returned as return values, so that
//    the output of one function may be used as a parameter to another.
//
//===========================================================================

//--------------------------
// 2D Vector
//--------------------------

// inline

function D3DXVec2Length(const v: TD3DXVector2): Single;

function D3DXVec2LengthSq(const v: TD3DXVector2): Single;

function D3DXVec2Dot(const v1, v2: TD3DXVector2): Single;

// Z component of ((x1,y1,0) cross (x2,y2,0))
function D3DXVec2CCW(const v1, v2: TD3DXVector2): Single;

function D3DXVec2Add(const v1, v2: TD3DXVector2): TD3DXVector2;

function D3DXVec2Subtract(const v1, v2: TD3DXVector2): TD3DXVector2;

// Minimize each component.  x = min(x1, x2), y = min(y1, y2)
function D3DXVec2Minimize(out vOut: TD3DXVector2; const v1, v2: TD3DXVector2): PD3DXVector2;

// Maximize each component.  x = max(x1, x2), y = max(y1, y2)
function D3DXVec2Maximize(out vOut: TD3DXVector2; const v1, v2: TD3DXVector2): PD3DXVector2;

function D3DXVec2Scale(out vOut: TD3DXVector2; const v: TD3DXVector2; s: Single): PD3DXVector2;

// Linear interpolation. V1 + s(V2-V1)
function D3DXVec2Lerp(out vOut: TD3DXVector2; const v1, v2: TD3DXVector2; s: Single): PD3DXVector2;

// non-inline

(*

function D3DXVec2Normalize(out vOut: TD3DXVector2; const v: TD3DXVector2): PD3DXVector2; stdcall; external d3dx8dll;
*)
var D3DXVec2Normalize : function( out vOut : TD3DXVector2 ; const v : TD3DXVector2 ) : PD3DXVector2 ; stdcall ;


// Hermite interpolation between position V1, tangent T1 (when s == 0)
// and position V2, tangent T2 (when s == 1).

(*

function D3DXVec2Hermite(out vOut: TD3DXVector2;
   const v1, t1, v2, t2: TD3DXVector2; s: Single): PD3DXVector2; stdcall; external d3dx8dll;
*)
var D3DXVec2Hermite : function( out vOut : TD3DXVector2 ; const v1 , t1 , v2 , t2 : TD3DXVector2 ; s : Single ) : PD3DXVector2 ; stdcall ;


// CatmullRom interpolation between V1 (when s == 0) and V2 (when s == 1)

(*

function D3DXVec2CatmullRom(out vOut: TD3DXVector2;
   const v0, v1, v2, v3: TD3DXVector2; s: Single): PD3DXVector2; stdcall; external d3dx8dll;
*)
var D3DXVec2CatmullRom : function( out vOut : TD3DXVector2 ; const v0 , v1 , v2 , v3 : TD3DXVector2 ; s : Single ) : PD3DXVector2 ; stdcall ;


// Barycentric coordinates.  V1 + f(V2-V1) + g(V3-V1)

(*

function D3DXVec2BaryCentric(out vOut: TD3DXVector2;
   const v1, v2, v3: TD3DXVector2; f, g: Single): PD3DXVector2; stdcall; external d3dx8dll;
*)
var D3DXVec2BaryCentric : function( out vOut : TD3DXVector2 ; const v1 , v2 , v3 : TD3DXVector2 ; f , g : Single ) : PD3DXVector2 ; stdcall ;


// Transform (x, y, 0, 1) by matrix.

(*

function D3DXVec2Transform(out vOut: TD3DXVector4;
  const v: TD3DXVector2; const m: TD3DXMatrix): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec2Transform : function( out vOut : TD3DXVector4 ; const v : TD3DXVector2 ; const m : TD3DXMatrix ) : PD3DXVector4 ; stdcall ;


// Transform (x, y, 0, 1) by matrix, project result back into w=1.

(*

function D3DXVec2TransformCoord(out vOut: TD3DXVector2;
  const v: TD3DXVector2; const m: TD3DXMatrix): PD3DXVector2; stdcall; external d3dx8dll;
*)
var D3DXVec2TransformCoord : function( out vOut : TD3DXVector2 ; const v : TD3DXVector2 ; const m : TD3DXMatrix ) : PD3DXVector2 ; stdcall ;


// Transform (x, y, 0, 0) by matrix.

(*

function D3DXVec2TransformNormal(out vOut: TD3DXVector2;
  const v: TD3DXVector2; const m: TD3DXMatrix): PD3DXVector2; stdcall; external d3dx8dll;
*)
var D3DXVec2TransformNormal : function( out vOut : TD3DXVector2 ; const v : TD3DXVector2 ; const m : TD3DXMatrix ) : PD3DXVector2 ; stdcall ;



//--------------------------
// 3D Vector
//--------------------------

// inline

function D3DXVec3Length(const v: TD3DXVector3): Single;

function D3DXVec3LengthSq(const v: TD3DXVector3): Single;

function D3DXVec3Dot(const v1, v2: TD3DXVector3): Single;

function D3DXVec3Cross(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;

function D3DXVec3Add(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;

function D3DXVec3Subtract(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;

// Minimize each component.  x = min(x1, x2), y = min(y1, y2), ...
function D3DXVec3Minimize(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;

// Maximize each component.  x = max(x1, x2), y = max(y1, y2), ...
function D3DXVec3Maximize(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;

function D3DXVec3Scale(out vOut: TD3DXVector3; const v: TD3DXVector3; s: Single): PD3DXVector3;

// Linear interpolation. V1 + s(V2-V1)
function D3DXVec3Lerp(out vOut: TD3DXVector3;
  const v1, v2: TD3DXVector3; s: Single): PD3DXVector3;

// non-inline

(*


function D3DXVec3Normalize(out vOut: TD3DXVector3;
   const v: TD3DXVector3): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3Normalize : function( out vOut : TD3DXVector3 ; const v : TD3DXVector3 ) : PD3DXVector3 ; stdcall ;


// Hermite interpolation between position V1, tangent T1 (when s == 0)
// and position V2, tangent T2 (when s == 1).

(*

function D3DXVec3Hermite(out vOut: TD3DXVector3;
   const v1, t1, v2, t2: TD3DXVector3; s: Single): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3Hermite : function( out vOut : TD3DXVector3 ; const v1 , t1 , v2 , t2 : TD3DXVector3 ; s : Single ) : PD3DXVector3 ; stdcall ;


// CatmullRom interpolation between V1 (when s == 0) and V2 (when s == 1)

(*

function D3DXVec3CatmullRom(out vOut: TD3DXVector3;
   const v0, v1, v2, v3: TD3DXVector3; s: Single): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3CatmullRom : function( out vOut : TD3DXVector3 ; const v0 , v1 , v2 , v3 : TD3DXVector3 ; s : Single ) : PD3DXVector3 ; stdcall ;


// Barycentric coordinates.  V1 + f(V2-V1) + g(V3-V1)

(*

function D3DXVec3BaryCentric(out vOut: TD3DXVector3;
   const v1, v2, v3: TD3DXVector3; f, g: Single): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3BaryCentric : function( out vOut : TD3DXVector3 ; const v1 , v2 , v3 : TD3DXVector3 ; f , g : Single ) : PD3DXVector3 ; stdcall ;


// Transform (x, y, z, 1) by matrix.

(*

function D3DXVec3Transform(out vOut: TD3DXVector4;
  const v: TD3DXVector3; const m: TD3DXMatrix): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec3Transform : function( out vOut : TD3DXVector4 ; const v : TD3DXVector3 ; const m : TD3DXMatrix ) : PD3DXVector4 ; stdcall ;


// Transform (x, y, z, 1) by matrix, project result back into w=1.

(*

function D3DXVec3TransformCoord(out vOut: TD3DXVector3;
  const v: TD3DXVector3; const m: TD3DXMatrix): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3TransformCoord : function( out vOut : TD3DXVector3 ; const v : TD3DXVector3 ; const m : TD3DXMatrix ) : PD3DXVector3 ; stdcall ;


// Transform (x, y, z, 0) by matrix.  If you transforming a normal by a
// non-affine matrix, the matrix you pass to this function should be the
// transpose of the inverse of the matrix you would use to transform a coord.

(*

function D3DXVec3TransformNormal(out vOut: TD3DXVector3;
  const v: TD3DXVector3; const m: TD3DXMatrix): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3TransformNormal : function( out vOut : TD3DXVector3 ; const v : TD3DXVector3 ; const m : TD3DXMatrix ) : PD3DXVector3 ; stdcall ;


// Project vector from object space into screen space

(*

function D3DXVec3Project(out vOut: TD3DXVector3;
  const v: TD3DXVector3; const pViewport: TD3DViewport8;
  const pProjection, pView, pWorld: TD3DXMatrix): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3Project : function( out vOut : TD3DXVector3 ; const v : TD3DXVector3 ; const pViewport : TD3DViewport8 ; const pProjection , pView , pWorld : TD3DXMatrix ) : PD3DXVector3 ; stdcall ;


// Project vector from screen space into object space

(*

function D3DXVec3Unproject(out vOut: TD3DXVector3;
  const v: TD3DXVector3; const pViewport: TD3DViewport8;
  const pProjection, pView, pWorld: TD3DXMatrix): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXVec3Unproject : function( out vOut : TD3DXVector3 ; const v : TD3DXVector3 ; const pViewport : TD3DViewport8 ; const pProjection , pView , pWorld : TD3DXMatrix ) : PD3DXVector3 ; stdcall ;



//--------------------------
// 4D Vector
//--------------------------

// inline

function D3DXVec4Length(const v: TD3DXVector4): Single;

function D3DXVec4LengthSq(const v: TD3DXVector4): Single;

function D3DXVec4Dot(const v1, v2: TD3DXVector4): Single;

function D3DXVec4Add(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;

function D3DXVec4Subtract(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;

// Minimize each component.  x = min(x1, x2), y = min(y1, y2), ...
function D3DXVec4Minimize(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;

// Maximize each component.  x = max(x1, x2), y = max(y1, y2), ...
function D3DXVec4Maximize(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;

function D3DXVec4Scale(out vOut: TD3DXVector4; const v: TD3DXVector4; s: Single): PD3DXVector4;

// Linear interpolation. V1 + s(V2-V1)
function D3DXVec4Lerp(out vOut: TD3DXVector4;
  const v1, v2: TD3DXVector4; s: Single): PD3DXVector4;

// non-inline

// Cross-product in 4 dimensions.

(*

function D3DXVec4Cross(out vOut: TD3DXVector4;
  const v1, v2, v3: TD3DXVector4): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec4Cross : function( out vOut : TD3DXVector4 ; const v1 , v2 , v3 : TD3DXVector4 ) : PD3DXVector4 ; stdcall ;

(*


function D3DXVec4Normalize(out vOut: TD3DXVector4;
  const v: TD3DXVector4): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec4Normalize : function( out vOut : TD3DXVector4 ; const v : TD3DXVector4 ) : PD3DXVector4 ; stdcall ;


// Hermite interpolation between position V1, tangent T1 (when s == 0)
// and position V2, tangent T2 (when s == 1).

(*

function D3DXVec4Hermite(out vOut: TD3DXVector4;
   const v1, t1, v2, t2: TD3DXVector4; s: Single): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec4Hermite : function( out vOut : TD3DXVector4 ; const v1 , t1 , v2 , t2 : TD3DXVector4 ; s : Single ) : PD3DXVector4 ; stdcall ;


// CatmullRom interpolation between V1 (when s == 0) and V2 (when s == 1)

(*

function D3DXVec4CatmullRom(out vOut: TD3DXVector4;
   const v0, v1, v2, v3: TD3DXVector4; s: Single): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec4CatmullRom : function( out vOut : TD3DXVector4 ; const v0 , v1 , v2 , v3 : TD3DXVector4 ; s : Single ) : PD3DXVector4 ; stdcall ;


// Barycentric coordinates.  V1 + f(V2-V1) + g(V3-V1)

(*

function D3DXVec4BaryCentric(out vOut: TD3DXVector4;
   const v1, v2, v3: TD3DXVector4; f, g: Single): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec4BaryCentric : function( out vOut : TD3DXVector4 ; const v1 , v2 , v3 : TD3DXVector4 ; f , g : Single ) : PD3DXVector4 ; stdcall ;


// Transform vector by matrix.

(*

function D3DXVec4Transform(out vOut: TD3DXVector4;
  const v: TD3DXVector4; const m: TD3DXMatrix): PD3DXVector4; stdcall; external d3dx8dll;
*)
var D3DXVec4Transform : function( out vOut : TD3DXVector4 ; const v : TD3DXVector4 ; const m : TD3DXMatrix ) : PD3DXVector4 ; stdcall ;



//--------------------------
// 4D Matrix
//--------------------------

// inline

function D3DXMatrixIdentity(out mOut: TD3DXMatrix): PD3DXMatrix;

function D3DXMatrixIsIdentity(const m: TD3DXMatrix): BOOL;

// non-inline

(*


function D3DXMatrixfDeterminant(const m: TD3DXMatrix): Single; stdcall; external d3dx8dll;
*)
var D3DXMatrixfDeterminant : function( const m : TD3DXMatrix ) : Single ; stdcall ;

(*


function D3DXMatrixTranspose(out pOut: TD3DXMatrix; const pM: TD3DXMatrix): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixTranspose : function( out pOut : TD3DXMatrix ; const pM : TD3DXMatrix ) : PD3DXMatrix ; stdcall ;


// Matrix multiplication.  The result represents the transformation M2
// followed by the transformation M1.  (Out = M1 * M2)

(*

function D3DXMatrixMultiply(out mOut: TD3DXMatrix; const m1, m2: TD3DXMatrix): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixMultiply : function( out mOut : TD3DXMatrix ; const m1 , m2 : TD3DXMatrix ) : PD3DXMatrix ; stdcall ;


// Matrix multiplication, followed by a transpose. (Out = T(M1 * M2))

(*

function D3DXMatrixMultiplyTranspose(out pOut: TD3DXMatrix; const pM1, pM2: TD3DXMatrix): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixMultiplyTranspose : function( out pOut : TD3DXMatrix ; const pM1 , pM2 : TD3DXMatrix ) : PD3DXMatrix ; stdcall ;


// Calculate inverse of matrix.  Inversion my fail, in which case NULL will
// be returned.  The determinant of pM is also returned it pfDeterminant
// is non-NULL.

(*

function D3DXMatrixInverse(out mOut: TD3DXMatrix; pfDeterminant: PSingle;
    const m: TD3DXMatrix): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixInverse : function( out mOut : TD3DXMatrix ; pfDeterminant : PSingle ; const m : TD3DXMatrix ) : PD3DXMatrix ; stdcall ;


// Build a matrix which scales by (sx, sy, sz)

(*

function D3DXMatrixScaling(out mOut: TD3DXMatrix; sx, sy, sz: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixScaling : function( out mOut : TD3DXMatrix ; sx , sy , sz : Single ) : PD3DXMatrix ; stdcall ;


// Build a matrix which translates by (x, y, z)

(*

function D3DXMatrixTranslation(out mOut: TD3DXMatrix; x, y, z: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixTranslation : function( out mOut : TD3DXMatrix ; x , y , z : Single ) : PD3DXMatrix ; stdcall ;


// Build a matrix which rotates around the X axis

(*

function D3DXMatrixRotationX(out mOut: TD3DXMatrix; angle: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixRotationX : function( out mOut : TD3DXMatrix ; angle : Single ) : PD3DXMatrix ; stdcall ;


// Build a matrix which rotates around the Y axis

(*

function D3DXMatrixRotationY(out mOut: TD3DXMatrix; angle: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixRotationY : function( out mOut : TD3DXMatrix ; angle : Single ) : PD3DXMatrix ; stdcall ;


// Build a matrix which rotates around the Z axis

(*

function D3DXMatrixRotationZ(out mOut: TD3DXMatrix; angle: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixRotationZ : function( out mOut : TD3DXMatrix ; angle : Single ) : PD3DXMatrix ; stdcall ;


// Build a matrix which rotates around an arbitrary axis

(*

function D3DXMatrixRotationAxis(out mOut: TD3DXMatrix; const v: TD3DXVector3;
  angle: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixRotationAxis : function( out mOut : TD3DXMatrix ; const v : TD3DXVector3 ; angle : Single ) : PD3DXMatrix ; stdcall ;


// Build a matrix from a quaternion

(*

function D3DXMatrixRotationQuaternion(out mOut: TD3DXMatrix; const Q: TD3DXQuaternion): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixRotationQuaternion : function( out mOut : TD3DXMatrix ; const Q : TD3DXQuaternion ) : PD3DXMatrix ; stdcall ;


// Yaw around the Y axis, a pitch around the X axis,
// and a roll around the Z axis.

(*

function D3DXMatrixRotationYawPitchRoll(out mOut: TD3DXMatrix; yaw, pitch, roll: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixRotationYawPitchRoll : function( out mOut : TD3DXMatrix ; yaw , pitch , roll : Single ) : PD3DXMatrix ; stdcall ;



// Build transformation matrix.  NULL arguments are treated as identity.
// Mout = Msc-1 * Msr-1 * Ms * Msr * Msc * Mrc-1 * Mr * Mrc * Mt

(*

function D3DXMatrixTransformation(out mOut: TD3DXMatrix;
   pScalingCenter: PD3DXVector3;
   pScalingRotation: PD3DXQuaternion; pScaling, pRotationCenter: PD3DXVector3;
   pRotation: PD3DXQuaternion; pTranslation: PD3DXVector3): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixTransformation : function( out mOut : TD3DXMatrix ; pScalingCenter : PD3DXVector3 ; pScalingRotation : PD3DXQuaternion ; pScaling , pRotationCenter : PD3DXVector3 ; pRotation : PD3DXQuaternion ; pTranslation : PD3DXVector3 ) : PD3DXMatrix ; stdcall ;


// Build affine transformation matrix.  NULL arguments are treated as identity.
// Mout = Ms * Mrc-1 * Mr * Mrc * Mt

(*

function D3DXMatrixAffineTransformation(out mOut: TD3DXMatrix;
   Scaling: Single; pRotationCenter: PD3DXVector3;
   pRotation: PD3DXQuaternion; pTranslation: PD3DXVector3): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixAffineTransformation : function( out mOut : TD3DXMatrix ; Scaling : Single ; pRotationCenter : PD3DXVector3 ; pRotation : PD3DXQuaternion ; pTranslation : PD3DXVector3 ) : PD3DXMatrix ; stdcall ;


// Build a lookat matrix. (right-handed)

(*

function D3DXMatrixLookAtRH(out mOut: TD3DXMatrix; const Eye, At, Up: TD3DXVector3): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixLookAtRH : function( out mOut : TD3DXMatrix ; const Eye , At , Up : TD3DXVector3 ) : PD3DXMatrix ; stdcall ;


// Build a lookat matrix. (left-handed)

(*

function D3DXMatrixLookAtLH(out mOut: TD3DXMatrix; const Eye, At, Up: TD3DXVector3): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixLookAtLH : function( out mOut : TD3DXMatrix ; const Eye , At , Up : TD3DXVector3 ) : PD3DXMatrix ; stdcall ;


// Build a perspective projection matrix. (right-handed)

(*

function D3DXMatrixPerspectiveRH(out mOut: TD3DXMatrix; w, h, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixPerspectiveRH : function( out mOut : TD3DXMatrix ; w , h , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build a perspective projection matrix. (left-handed)

(*

function D3DXMatrixPerspectiveLH(out mOut: TD3DXMatrix; w, h, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixPerspectiveLH : function( out mOut : TD3DXMatrix ; w , h , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build a perspective projection matrix. (right-handed)

(*

function D3DXMatrixPerspectiveFovRH(out mOut: TD3DXMatrix; flovy, aspect, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixPerspectiveFovRH : function( out mOut : TD3DXMatrix ; flovy , aspect , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build a perspective projection matrix. (left-handed)

(*

function D3DXMatrixPerspectiveFovLH(out mOut: TD3DXMatrix; flovy, aspect, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixPerspectiveFovLH : function( out mOut : TD3DXMatrix ; flovy , aspect , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build a perspective projection matrix. (right-handed)

(*

function D3DXMatrixPerspectiveOffCenterRH(out mOut: TD3DXMatrix;
   l, r, b, t, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixPerspectiveOffCenterRH : function( out mOut : TD3DXMatrix ; l , r , b , t , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build a perspective projection matrix. (left-handed)

(*

function D3DXMatrixPerspectiveOffCenterLH(out mOut: TD3DXMatrix;
   l, r, b, t, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixPerspectiveOffCenterLH : function( out mOut : TD3DXMatrix ; l , r , b , t , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build an ortho projection matrix. (right-handed)

(*

function D3DXMatrixOrthoRH(out mOut: TD3DXMatrix; w, h, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixOrthoRH : function( out mOut : TD3DXMatrix ; w , h , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build an ortho projection matrix. (left-handed)

(*

function D3DXMatrixOrthoLH(out mOut: TD3DXMatrix; w, h, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixOrthoLH : function( out mOut : TD3DXMatrix ; w , h , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build an ortho projection matrix. (right-handed)

(*

function D3DXMatrixOrthoOffCenterRH(out mOut: TD3DXMatrix;
  l, r, b, t, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixOrthoOffCenterRH : function( out mOut : TD3DXMatrix ; l , r , b , t , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build an ortho projection matrix. (left-handed)

(*

function D3DXMatrixOrthoOffCenterLH(out mOut: TD3DXMatrix;
  l, r, b, t, zn, zf: Single): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixOrthoOffCenterLH : function( out mOut : TD3DXMatrix ; l , r , b , t , zn , zf : Single ) : PD3DXMatrix ; stdcall ;


// Build a matrix which flattens geometry into a plane, as if casting
// a shadow from a light.

(*

function D3DXMatrixShadow(out mOut: TD3DXMatrix;
  const Light: TD3DXVector4; const Plane: TD3DXPlane): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixShadow : function( out mOut : TD3DXMatrix ; const Light : TD3DXVector4 ; const Plane : TD3DXPlane ) : PD3DXMatrix ; stdcall ;


// Build a matrix which reflects the coordinate system about a plane

(*

function D3DXMatrixReflect(out mOut: TD3DXMatrix;
   const Plane: TD3DXPlane): PD3DXMatrix; stdcall; external d3dx8dll;
*)
var D3DXMatrixReflect : function( out mOut : TD3DXMatrix ; const Plane : TD3DXPlane ) : PD3DXMatrix ; stdcall ;



//--------------------------
// Quaternion
//--------------------------

// inline

function D3DXQuaternionLength(const q: TD3DXQuaternion): Single;

// Length squared, or "norm"
function D3DXQuaternionLengthSq(const q: TD3DXQuaternion): Single;

function D3DXQuaternionDot(const q1, q2: TD3DXQuaternion): Single;

// (0, 0, 0, 1)
function D3DXQuaternionIdentity(out qOut: TD3DXQuaternion): PD3DXQuaternion;

function D3DXQuaternionIsIdentity (const q: TD3DXQuaternion): BOOL;

// (-x, -y, -z, w)
function D3DXQuaternionConjugate(out qOut: TD3DXQuaternion;
  const q: TD3DXQuaternion): PD3DXQuaternion;


// non-inline

// Compute a quaternin's axis and angle of rotation. Expects unit quaternions.

(*

procedure D3DXQuaternionToAxisAngle(const q: TD3DXQuaternion;
  out Axis: TD3DXVector3; out Angle: Single); stdcall; external d3dx8dll;
*)
var D3DXQuaternionToAxisAngle : procedure( const q : TD3DXQuaternion ; out Axis : TD3DXVector3 ; out Angle : Single ) ; stdcall ;


// Build a quaternion from a rotation matrix.

(*

function D3DXQuaternionRotationMatrix(out qOut: TD3DXQuaternion;
  const m: TD3DXMatrix): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionRotationMatrix : function( out qOut : TD3DXQuaternion ; const m : TD3DXMatrix ) : PD3DXQuaternion ; stdcall ;


// Rotation about arbitrary axis.

(*

function D3DXQuaternionRotationAxis(out qOut: TD3DXQuaternion;
  const v: TD3DXVector3; Angle: Single): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionRotationAxis : function( out qOut : TD3DXQuaternion ; const v : TD3DXVector3 ; Angle : Single ) : PD3DXQuaternion ; stdcall ;


// Yaw around the Y axis, a pitch around the X axis,
// and a roll around the Z axis.

(*

function D3DXQuaternionRotationYawPitchRoll(out qOut: TD3DXQuaternion;
  yaw, pitch, roll: Single): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionRotationYawPitchRoll : function( out qOut : TD3DXQuaternion ; yaw , pitch , roll : Single ) : PD3DXQuaternion ; stdcall ;


// Quaternion multiplication.  The result represents the rotation Q2
// followed by the rotation Q1.  (Out = Q2 * Q1)

(*

function D3DXQuaternionMultiply(out qOut: TD3DXQuaternion;
   const q1, q2: TD3DXQuaternion): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionMultiply : function( out qOut : TD3DXQuaternion ; const q1 , q2 : TD3DXQuaternion ) : PD3DXQuaternion ; stdcall ;

(*


function D3DXQuaternionNormalize(out qOut: TD3DXQuaternion;
   const q: TD3DXQuaternion): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionNormalize : function( out qOut : TD3DXQuaternion ; const q : TD3DXQuaternion ) : PD3DXQuaternion ; stdcall ;


// Conjugate and re-norm

(*

function D3DXQuaternionInverse(out qOut: TD3DXQuaternion;
   const q: TD3DXQuaternion): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionInverse : function( out qOut : TD3DXQuaternion ; const q : TD3DXQuaternion ) : PD3DXQuaternion ; stdcall ;


// Expects unit quaternions.
// if q = (cos(theta), sin(theta) * v); ln(q) = (0, theta * v)

(*

function D3DXQuaternionLn(out qOut: TD3DXQuaternion;
   const q: TD3DXQuaternion): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionLn : function( out qOut : TD3DXQuaternion ; const q : TD3DXQuaternion ) : PD3DXQuaternion ; stdcall ;


// Expects pure quaternions. (w == 0)  w is ignored in calculation.
// if q = (0, theta * v); exp(q) = (cos(theta), sin(theta) * v)

(*

function D3DXQuaternionExp(out qOut: TD3DXQuaternion;
   const q: TD3DXQuaternion): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionExp : function( out qOut : TD3DXQuaternion ; const q : TD3DXQuaternion ) : PD3DXQuaternion ; stdcall ;


// Spherical linear interpolation between Q1 (s == 0) and Q2 (s == 1).
// Expects unit quaternions.

(*

function D3DXQuaternionSlerp(out qOut: TD3DXQuaternion;
   const q1, q2: TD3DXQuaternion; t: Single): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionSlerp : function( out qOut : TD3DXQuaternion ; const q1 , q2 : TD3DXQuaternion ; t : Single ) : PD3DXQuaternion ; stdcall ;


// Spherical quadrangle interpolation.
// Slerp(Slerp(Q1, C, t), Slerp(A, B, t), 2t(1-t))

(*

function D3DXQuaternionSquad(out qOut: TD3DXQuaternion;
   const pQ1, pA, pB, pC: TD3DXQuaternion; t: Single): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionSquad : function( out qOut : TD3DXQuaternion ; const pQ1 , pA , pB , pC : TD3DXQuaternion ; t : Single ) : PD3DXQuaternion ; stdcall ;


// Setup control points for spherical quadrangle interpolation
// from Q1 to Q2.  The control points are chosen in such a way
// to ensure the continuity of tangents with adjacent segments.

(*

procedure D3DXQuaternionSquadSetup(out pAOut, pBOut, pCOut: TD3DXQuaternion;
   const pQ0, pQ1, pQ2, pQ3: TD3DXQuaternion); stdcall; external d3dx8dll;
*)
var D3DXQuaternionSquadSetup : procedure( out pAOut , pBOut , pCOut : TD3DXQuaternion ; const pQ0 , pQ1 , pQ2 , pQ3 : TD3DXQuaternion ) ; stdcall ;


// Barycentric interpolation.
// Slerp(Slerp(Q1, Q2, f+g), Slerp(Q1, Q3, f+g), g/(f+g))

(*

function D3DXQuaternionBaryCentric(out qOut: TD3DXQuaternion;
   const q1, q2, q3: TD3DXQuaternion; f, g: Single): PD3DXQuaternion; stdcall; external d3dx8dll;
*)
var D3DXQuaternionBaryCentric : function( out qOut : TD3DXQuaternion ; const q1 , q2 , q3 : TD3DXQuaternion ; f , g : Single ) : PD3DXQuaternion ; stdcall ;



//--------------------------
// Plane
//--------------------------

// inline

// ax + by + cz + dw
function D3DXPlaneDot(const p: TD3DXPlane; const v: TD3DXVector4): Single;

// ax + by + cz + d
function D3DXPlaneDotCoord(const p: TD3DXPlane; const v: TD3DXVector3): Single;

// ax + by + cz
function D3DXPlaneDotNormal(const p: TD3DXPlane; const v: TD3DXVector3): Single;


// non-inline

// Normalize plane (so that |a,b,c| == 1)

(*

function D3DXPlaneNormalize(out pOut: TD3DXPlane; const p: TD3DXPlane): PD3DXPlane; stdcall; external d3dx8dll;
*)
var D3DXPlaneNormalize : function( out pOut : TD3DXPlane ; const p : TD3DXPlane ) : PD3DXPlane ; stdcall ;


// Find the intersection between a plane and a line.  If the line is
// parallel to the plane, NULL is returned.

(*

function D3DXPlaneIntersectLine(out vOut: TD3DXVector3;
   const p: TD3DXPlane; const v1, v2: TD3DXVector3): PD3DXVector3; stdcall; external d3dx8dll;
*)
var D3DXPlaneIntersectLine : function( out vOut : TD3DXVector3 ; const p : TD3DXPlane ; const v1 , v2 : TD3DXVector3 ) : PD3DXVector3 ; stdcall ;


// Construct a plane from a point and a normal

(*

function D3DXPlaneFromPointNormal(out pOut: TD3DXPlane;
   const vPoint, vNormal: TD3DXVector3): PD3DXPlane; stdcall; external d3dx8dll;
*)
var D3DXPlaneFromPointNormal : function( out pOut : TD3DXPlane ; const vPoint , vNormal : TD3DXVector3 ) : PD3DXPlane ; stdcall ;


// Construct a plane from 3 points

(*

function D3DXPlaneFromPoints(out pOut: TD3DXPlane;
   const v1, v2, v3: TD3DXVector3): PD3DXPlane; stdcall; external d3dx8dll;
*)
var D3DXPlaneFromPoints : function( out pOut : TD3DXPlane ; const v1 , v2 , v3 : TD3DXVector3 ) : PD3DXPlane ; stdcall ;


// Transform a plane by a matrix.  The vector (a,b,c) must be normal.
// M should be the inverse transpose of the transformation desired.

(*

function D3DXPlaneTransform(out pOut: TD3DXPlane; const p: TD3DXPlane; const m: TD3DXMatrix): PD3DXPlane; stdcall; external d3dx8dll;
*)
var D3DXPlaneTransform : function( out pOut : TD3DXPlane ; const p : TD3DXPlane ; const m : TD3DXMatrix ) : PD3DXPlane ; stdcall ;



//--------------------------
// Color
//--------------------------

// inline

// (1-r, 1-g, 1-b, a)
function D3DXColorNegative(out cOut: TD3DXColor; const c: TD3DXColor): PD3DXColor;

function D3DXColorAdd(out cOut: TD3DXColor; const c1, c2: TD3DXColor): PD3DXColor;

function D3DXColorSubtract(out cOut: TD3DXColor; const c1, c2: TD3DXColor): PD3DXColor;

function D3DXColorScale(out cOut: TD3DXColor; const c: TD3DXColor; s: Single): PD3DXColor;

// (r1*r2, g1*g2, b1*b2, a1*a2)
function D3DXColorModulate(out cOut: TD3DXColor; const c1, c2: TD3DXColor): PD3DXColor;

// Linear interpolation of r,g,b, and a. C1 + s(C2-C1)
function D3DXColorLerp(out cOut: TD3DXColor; const c1, c2: TD3DXColor; s: Single): PD3DXColor;

// non-inline

// Interpolate r,g,b between desaturated color and color.
// DesaturatedColor + s(Color - DesaturatedColor)

(*

function D3DXColorAdjustSaturation(out cOut: TD3DXColor;
   const pC: TD3DXColor; s: Single): PD3DXColor; stdcall; external d3dx8dll;
*)
var D3DXColorAdjustSaturation : function( out cOut : TD3DXColor ; const pC : TD3DXColor ; s : Single ) : PD3DXColor ; stdcall ;


// Interpolate r,g,b between 50% grey and color.  Grey + s(Color - Grey)

(*

function D3DXColorAdjustContrast(out cOut: TD3DXColor;
   const pC: TD3DXColor; c: Single): PD3DXColor; stdcall; external d3dx8dll;
*)
var D3DXColorAdjustContrast : function( out cOut : TD3DXColor ; const pC : TD3DXColor ; c : Single ) : PD3DXColor ; stdcall ;



//--------------------------
// Misc
//--------------------------

// Calculate Fresnel term given the cosine of theta (likely obtained by
// taking the dot of two normals), and the refraction index of the material.

(*

function D3DXFresnelTerm(CosTheta, RefractionIndex: Single): Single; stdcall; external d3dx8dll;
*)
var D3DXFresnelTerm : function( CosTheta , RefractionIndex : Single ) : Single ; stdcall ;




//===========================================================================
//
//    Matrix Stack
//
//===========================================================================

type
  ID3DXMatrixStack = interface(IUnknown)
    ['{E3357330-CC5E-11d2-A434-00A0C90629A8}']
    //
    // ID3DXMatrixStack methods
    //

    // Pops the top of the stack, returns the current top
    // *after* popping the top.
    function Pop: HResult; stdcall;

    // Pushes the stack by one, duplicating the current matrix.
    function Push: HResult; stdcall;

    // Loads identity in the current matrix.
    function LoadIdentity: HResult; stdcall;

    // Loads the given matrix into the current matrix
    function LoadMatrix(const M: TD3DXMatrix): HResult; stdcall;

    // Right-Multiplies the given matrix to the current matrix.
    // (transformation is about the current world origin)
    function MultMatrix(const M: TD3DXMatrix): HResult; stdcall;

    // Left-Multiplies the given matrix to the current matrix
    // (transformation is about the local origin of the object)
    function MultMatrixLocal(const M: TD3DXMatrix): HResult; stdcall;

    // Right multiply the current matrix with the computed rotation
    // matrix, counterclockwise about the given axis with the given angle.
    // (rotation is about the current world origin)
    function RotateAxis(const V: TD3DXVector3; Angle: Single): HResult; stdcall;

    // Left multiply the current matrix with the computed rotation
    // matrix, counterclockwise about the given axis with the given angle.
    // (rotation is about the local origin of the object)
    function RotateAxisLocal(const V: TD3DXVector3; Angle: Single): HResult; stdcall;

    // Right multiply the current matrix with the computed rotation
    // matrix. All angles are counterclockwise. (rotation is about the
    // current world origin)

    // The rotation is composed of a yaw around the Y axis, a pitch around
    // the X axis, and a roll around the Z axis.
    function RotateYawPitchRoll(yaw, pitch, roll: Single): HResult; stdcall;

    // Left multiply the current matrix with the computed rotation
    // matrix. All angles are counterclockwise. (rotation is about the
    // local origin of the object)

    // The rotation is composed of a yaw around the Y axis, a pitch around
    // the X axis, and a roll around the Z axis.
    function RotateYawPitchRollLocal(yaw, pitch, roll: Single): HResult; stdcall;

    // Right multiply the current matrix with the computed scale
    // matrix. (transformation is about the current world origin)
    function Scale(x, y, z: Single): HResult; stdcall;

    // Left multiply the current matrix with the computed scale
    // matrix. (transformation is about the local origin of the object)
    function ScaleLocal(x, y, z: Single): HResult; stdcall;

    // Right multiply the current matrix with the computed translation
    // matrix. (transformation is about the current world origin)
    function Translate(x, y, z: Single): HResult; stdcall;

    // Left multiply the current matrix with the computed translation
    // matrix. (transformation is about the local origin of the object)
    function TranslateLocal(x, y, z: Single): HResult; stdcall;

    // Obtain the current matrix at the top of the stack
    function GetTop: PD3DXMatrix; stdcall;
  end;

type
  IID_ID3DXMatrixStack = ID3DXMatrixStack;
(*


function D3DXCreateMatrixStack(Flags: DWord; out Stack: ID3DXMatrixStack): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateMatrixStack : function( Flags : DWord ; out Stack : ID3DXMatrixStack ) : HResult ; stdcall ;








///////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8core.h
//  Content:    D3DX core types and functions
//
///////////////////////////////////////////////////////////////////////////

type
///////////////////////////////////////////////////////////////////////////
// ID3DXBuffer:
// ------------
// The buffer object is used by D3DX to return arbitrary size data.
//
// GetBufferPointer -
//    Returns a pointer to the beginning of the buffer.
//
// GetBufferSize -
//    Returns the size of the buffer, in bytes.
///////////////////////////////////////////////////////////////////////////

  PID3DXBuffer = ^ID3DXBuffer;
  ID3DXBuffer = interface(IUnknown)
    ['{932E6A7E-C68E-45dd-A7BF-53D19C86DB1F}']
    // ID3DXBuffer
    function GetBufferPointer: Pointer; stdcall;
    function GetBufferSize: DWord; stdcall;
  end;



///////////////////////////////////////////////////////////////////////////
// ID3DXFont:
// ----------
// Font objects contain the textures and resources needed to render
// a specific font on a specific device.
//
// Begin -
//    Prepartes device for drawing text.  This is optional.. if DrawText
//    is called outside of Begin/End, it will call Begin and End for you.
//
// DrawText -
//    Draws formatted text on a D3D device.  Some parameters are
//    surprisingly similar to those of GDI's DrawText function.  See GDI
//    documentation for a detailed description of these parameters.
//
// End -
//    Restores device state to how it was when Begin was called.
//
// OnLostDevice, OnResetDevice -
//    Call OnLostDevice() on this object before calling Reset() on the
//    device, so that this object can release any stateblocks and video
//    memory resources.  After Reset(), the call OnResetDevice().
//
///////////////////////////////////////////////////////////////////////////

  ID3DXFont = interface(IUnknown)
    ['{89FAD6A5-024D-49af-8FE7-F51123B85E25}']
    // ID3DXFont
    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;
    function GetLogFont(out pLogFont: TLogFont): HResult; stdcall;

    function _Begin: HResult; stdcall;
    function DrawTextA(pString: PAnsiChar; Count: Integer; const pRect: TRect; Format: DWord; Color: TD3DColor): Integer; stdcall;
    function DrawTextW(pString: PWideChar; Count: Integer; const pRect: TRect; Format: DWord; Color: TD3DColor): Integer; stdcall;
    function _End: HResult; stdcall;

    function OnLostDevice: HResult; stdcall;
    function OnResetDevice: HResult; stdcall;
  end;
(*



function D3DXCreateFont(pDevice: IDirect3DDevice8; hFont: HFONT;
  out ppFont: ID3DXFont): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateFont : function( pDevice : IDirect3DDevice8 ; hFont : HFONT ; out ppFont : ID3DXFont ) : HResult ; stdcall ;

(*


function D3DXCreateFontIndirect(pDevice: IDirect3DDevice8;
  const pLogFont: TLogFont; out ppFont: ID3DXFont): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateFontIndirect : function( pDevice : IDirect3DDevice8 ; const pLogFont : TLogFont ; out ppFont : ID3DXFont ) : HResult ; stdcall ;




///////////////////////////////////////////////////////////////////////////
// ID3DXSprite:
// ------------
// This object intends to provide an easy way to drawing sprites using D3D.
//
// Begin -
//    Prepares device for drawing sprites
//
// Draw, DrawAffine, DrawTransform -
//    Draws a sprite in screen-space.  Before transformation, the sprite is
//    the size of SrcRect, with its top-left corner at the origin (0,0).
//    The color and alpha channels are modulated by Color.
//
// End -
//     Restores device state to how it was when Begin was called.
//
// OnLostDevice, OnResetDevice -
//    Call OnLostDevice() on this object before calling Reset() on the
//    device, so that this object can release any stateblocks and video
//    memory resources.  After Reset(), the call OnResetDevice().
///////////////////////////////////////////////////////////////////////////
type

  ID3DXSprite = interface(IUnknown)
    ['{13D69D15-F9B0-4e0f-B39E-C91EB33F6CE7}']
    // ID3DXSprite
    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;

    function _Begin: HResult; stdcall;

    function Draw(pSrcTexture: IDirect3DTexture8; pSrcRect: PRect;
      pScaling, pRotationCenter: PD3DXVector2; Rotation: Single;
      pTranslation: PD3DXVector2; Color: TD3DColor): HResult; stdcall;

    function DrawTransform(pSrcTexture: IDirect3DTexture8; pSrcRect: PRect;
      const pTransform: TD3DXMatrix; Color: TD3DColor): HResult; stdcall;

    function _End: HResult; stdcall;

    function OnLostDevice: HResult; stdcall;
    function OnResetDevice: HResult; stdcall;
  end;
(*



function D3DXCreateSprite(ppDevice: IDirect3DDevice8;
  out ppSprite: ID3DXSprite): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateSprite : function( ppDevice : IDirect3DDevice8 ; out ppSprite : ID3DXSprite ) : HResult ; stdcall ;




///////////////////////////////////////////////////////////////////////////
// ID3DXRenderToSurface:
// ---------------------
// This object abstracts rendering to surfaces.  These surfaces do not
// necessarily need to be render targets.  If they are not, a compatible
// render target is used, and the result copied into surface at end scene.
//
// BeginScene, EndScene -
//    Call BeginScene() and EndScene() at the beginning and ending of your
//    scene.  These calls will setup and restore render targets, viewports,
//    etc..
//
// OnLostDevice, OnResetDevice -
//    Call OnLostDevice() on this object before calling Reset() on the
//    device, so that this object can release any stateblocks and video
//    memory resources.  After Reset(), the call OnResetDevice().
///////////////////////////////////////////////////////////////////////////
type

  PD3DXRTSDesc = ^TD3DXRTSDesc;
  _D3DXRTS_DESC = packed record
    Width: LongWord;
    Height: LongWord;
    Format: TD3DFormat;
    DepthStencil: BOOL;
    DepthStencilFormat: TD3DFormat;
  end {_D3DXRTS_DESC};
  D3DXRTS_DESC = _D3DXRTS_DESC;
  TD3DXRTSDesc = _D3DXRTS_DESC;


  ID3DXRenderToSurface = interface(IUnknown)
    ['{82DF5B90-E34E-496e-AC1C-62117A6A5913}']
    // ID3DXRenderToSurface
    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;
    function GetDesc(out pDesc: TD3DXRTSDesc): HResult; stdcall;

    function BeginScene(pSurface: IDirect3DSurface8; pViewport: PD3DViewport8): HResult; stdcall;
    function EndScene: HResult; stdcall;

    function OnLostDevice: HResult; stdcall;
    function OnResetDevice: HResult; stdcall;
  end;
(*



function D3DXCreateRenderToSurface(ppDevice: IDirect3DDevice8;
  Width: LongWord;
  Height: LongWord;
  Format: TD3DFormat;
  DepthStencil: BOOL;
  DepthStencilFormat: TD3DFormat;
  out ppRenderToSurface: ID3DXRenderToSurface): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateRenderToSurface : function( ppDevice : IDirect3DDevice8 ; Width : LongWord ; Height : LongWord ; Format : TD3DFormat ; DepthStencil : BOOL ; DepthStencilFormat : TD3DFormat ; out ppRenderToSurface : ID3DXRenderToSurface ) : HResult ; stdcall ;




///////////////////////////////////////////////////////////////////////////
// ID3DXRenderToEnvMap:
// --------------------
// This object abstracts rendering to environment maps.  These surfaces
// do not necessarily need to be render targets.  If they are not, a
// compatible render target is used, and the result copied into the
// environment map at end scene.
//
// BeginCube, BeginSphere, BeginHemisphere, BeginParabolic -
//    This function initiates the rendering of the environment map.  As
//    parameters, you pass the textures in which will get filled in with
//    the resulting environment map.
//
// Face -
//    Call this function to initiate the drawing of each face.  For each
//    environment map, you will call this six times.. once for each face
//    in D3DCUBEMAP_FACES.
//
// End -
//    This will restore all render targets, and if needed compose all the
//    rendered faces into the environment map surfaces.
//
// OnLostDevice, OnResetDevice -
//    Call OnLostDevice() on this object before calling Reset() on the
//    device, so that this object can release any stateblocks and video
//    memory resources.  After Reset(), the call OnResetDevice().
///////////////////////////////////////////////////////////////////////////
type

  PD3DXRTEDesc = ^TD3DXRTEDesc;
  _D3DXRTE_DESC = record
    Size: LongWord;
    Format: TD3DFormat;
    DepthStencil: Bool;
    DepthStencilFormat: TD3DFormat;
  end {_D3DXRTE_DESC};
  D3DXRTE_DESC = _D3DXRTE_DESC;
  TD3DXRTEDesc = _D3DXRTE_DESC;


  ID3DXRenderToEnvMap = interface(IUnknown)
    ['{4E42C623-9451-44b7-8C86-ABCCDE5D52C8}']
    // ID3DXRenderToEnvMap
    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;
    function GetDesc(out pDesc: TD3DXRTEDesc): HResult; stdcall;

    function BeginCube(pCubeTex: IDirect3DCubeTexture8): HResult; stdcall;

    function BeginSphere(pTex: IDirect3DTexture8): HResult; stdcall;

    function BeginHemisphere(pTexZPos, pTexZNeg: IDirect3DTexture8): HResult; stdcall;

    function BeginParabolic(pTexZPos, pTexZNeg: IDirect3DTexture8): HResult; stdcall;

    function Face(Face: TD3DCubemapFaces): HResult; stdcall;
    function _End: HResult; stdcall;

    function OnLostDevice: HResult; stdcall;
    function OnResetDevice: HResult; stdcall;
  end;
(*



function D3DXCreateRenderToEnvMap(ppDevice: IDirect3DDevice8;
  Size: LongWord;
  Format: TD3DFormat;
  DepthStencil: BOOL;
  DepthStencilFormat: TD3DFormat;
  out ppRenderToEnvMap: ID3DXRenderToEnvMap): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateRenderToEnvMap : function( ppDevice : IDirect3DDevice8 ; Size : LongWord ; Format : TD3DFormat ; DepthStencil : BOOL ; DepthStencilFormat : TD3DFormat ; out ppRenderToEnvMap : ID3DXRenderToEnvMap ) : HResult ; stdcall ;




///////////////////////////////////////////////////////////////////////////
// Shader assemblers:
///////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------
// D3DXASM flags:
// --------------
//
// D3DXASM_DEBUG
//   Generate debug info.
//
// D3DXASM_SKIPVALIDATION
//   Do not validate the generated code against known capabilities and
//   constraints.  This option is only recommended when assembling shaders
//   you KNOW will work.  (ie. have assembled before without this option.)
//-------------------------------------------------------------------------
const
  D3DXASM_DEBUG           = (1 shl 0);
  D3DXASM_SKIPVALIDATION  = (1 shl 1);


//-------------------------------------------------------------------------
// D3DXAssembleShader:
// -------------------
// Assembles an ascii description of a vertex or pixel shader into
// binary form.
//
// Parameters:
//  pSrcFile
//      Source file name
//  hSrcModule
//      Module handle. if NULL, current module will be used.
//  pSrcResource
//      Resource name in module
//  pSrcData
//      Pointer to source code
//  SrcDataLen
//      Size of source code, in bytes
//  Flags
//      D3DXASM_xxx flags
//  ppConstants
//      Returns an ID3DXBuffer object containing constant declarations.
//  ppCompiledShader
//      Returns an ID3DXBuffer object containing the object code.
//  ppCompilationErrors
//      Returns an ID3DXBuffer object containing ascii error messages
//-------------------------------------------------------------------------

(*


function D3DXAssembleShaderFromFileA(
  pSrcFile: PAnsiChar;
  Flags: DWord;
  ppConstants: PID3DXBuffer;
  ppCompiledShader: PID3DXBuffer;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXAssembleShaderFromFileA';
*)
var D3DXAssembleShaderFromFileA : function( pSrcFile : PAnsiChar ; Flags : DWord ; ppConstants : PID3DXBuffer ; ppCompiledShader : PID3DXBuffer ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXAssembleShaderFromFileW(
  pSrcFile: PWideChar;
  Flags: DWord;
  ppConstants: PID3DXBuffer;
  ppCompiledShader: PID3DXBuffer;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXAssembleShaderFromFileW';
*)
var D3DXAssembleShaderFromFileW : function( pSrcFile : PWideChar ; Flags : DWord ; ppConstants : PID3DXBuffer ; ppCompiledShader : PID3DXBuffer ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXAssembleShaderFromFile(
  pSrcFile: PChar;
  Flags: DWord;
  ppConstants: PID3DXBuffer;
  ppCompiledShader: PID3DXBuffer;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXAssembleShaderFromFileA';
*)
var D3DXAssembleShaderFromFile : function( pSrcFile : PChar ; Flags : DWord ; ppConstants : PID3DXBuffer ; ppCompiledShader : PID3DXBuffer ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*



function D3DXAssembleShaderFromResourceA(
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  Flags: DWord;
  ppConstants: PID3DXBuffer;
  ppCompiledShader: PID3DXBuffer;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXAssembleShaderFromResourceA';
*)
var D3DXAssembleShaderFromResourceA : function( hSrcModule : HModule ; pSrcResource : PAnsiChar ; Flags : DWord ; ppConstants : PID3DXBuffer ; ppCompiledShader : PID3DXBuffer ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXAssembleShaderFromResourceW(
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  Flags: DWord;
  ppConstants: PID3DXBuffer;
  ppCompiledShader: PID3DXBuffer;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXAssembleShaderFromResourceW';
*)
var D3DXAssembleShaderFromResourceW : function( hSrcModule : HModule ; pSrcResource : PWideChar ; Flags : DWord ; ppConstants : PID3DXBuffer ; ppCompiledShader : PID3DXBuffer ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXAssembleShaderFromResource(
  hSrcModule: HModule;
  pSrcResource: PChar;
  Flags: DWord;
  ppConstants: PID3DXBuffer;
  ppCompiledShader: PID3DXBuffer;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXAssembleShaderFromResourceA';
*)
var D3DXAssembleShaderFromResource : function( hSrcModule : HModule ; pSrcResource : PChar ; Flags : DWord ; ppConstants : PID3DXBuffer ; ppCompiledShader : PID3DXBuffer ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*



function D3DXAssembleShader(
  const pSrcData;
  SrcDataLen: LongWord;
  Flags: DWord;
  ppConstants: PID3DXBuffer;
  ppCompiledShader: PID3DXBuffer;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXAssembleShader : function( const pSrcData ; SrcDataLen : LongWord ; Flags : DWord ; ppConstants : PID3DXBuffer ; ppCompiledShader : PID3DXBuffer ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;



///////////////////////////////////////////////////////////////////////////
// Misc APIs:
///////////////////////////////////////////////////////////////////////////


//-------------------------------------------------------------------------
// D3DXGetErrorString:
// ------------------
// Returns the error string for given an hresult.  Interprets all D3DX and
// D3D hresults.
//
// Parameters:
//  hr
//      The error code to be deciphered.
//  pBuffer
//      Pointer to the buffer to be filled in.
//  BufferLen
//      Count of characters in buffer.  Any error message longer than this
//      length will be truncated to fit.
//-------------------------------------------------------------------------

(*

function D3DXGetErrorStringA(hr: HResult; pBuffer: PAnsiChar; BufferLen: LongWord): HResult; stdcall; external d3dx8dll name 'D3DXGetErrorStringA'; overload;
*)
var _D3DXGetErrorStringA : function( hr : HResult ; pBuffer : PAnsiChar ; BufferLen : LongWord ) : HResult ; stdcall ;
(*

function D3DXGetErrorStringW(hr: HResult; pBuffer: PWideChar; BufferLen: LongWord): HResult; stdcall; external d3dx8dll name 'D3DXGetErrorStringW'; overload;
*)
var _D3DXGetErrorStringW : function( hr : HResult ; pBuffer : PWideChar ; BufferLen : LongWord ) : HResult ; stdcall ;
(*

function D3DXGetErrorString(hr: HResult; pBuffer: PChar; BufferLen: LongWord): HResult; stdcall; external d3dx8dll name 'D3DXGetErrorStringA'; overload;
*)
var _D3DXGetErrorString : function( hr : HResult ; pBuffer : PChar ; BufferLen : LongWord ) : HResult ; stdcall ;

// Object Pascal support functions for D3DXGetErrorString
function D3DXGetErrorStringA(hr: HResult): String; overload;
function D3DXGetErrorStringW(hr: HResult): WideString; overload;
{$IFNDEF UNICODE}
function D3DXGetErrorString(hr: HResult): String; overload;
{$ELSE}
function D3DXGetErrorString(hr: HResult): WideString; overload;
{$ENDIF}



///////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8effect.h
//  Content:    D3DX effect types and functions
//
///////////////////////////////////////////////////////////////////////////

const
  D3DXFX_DONOTSAVESTATE = (1 shl 0);

type
  _D3DXPARAMETERTYPE = (
    D3DXPT_DWORD        {= 0},
    D3DXPT_FLOAT        {= 1},
    D3DXPT_VECTOR       {= 2},
    D3DXPT_MATRIX       {= 3},
    D3DXPT_TEXTURE      {= 4},
    D3DXPT_VERTEXSHADER {= 5},
    D3DXPT_PIXELSHADER  {= 6},
    D3DXPT_CONSTANT     {= 7},
    D3DXPT_STRING       {= 8}
  ); {_D3DXPARAMETERTYPE}
  D3DXPARAMETERTYPE = _D3DXPARAMETERTYPE;
  TD3DXParameterType = _D3DXPARAMETERTYPE;

type
  PD3DXEffectDesc = ^TD3DXEffectDesc;
  _D3DXEFFECT_DESC = packed record
    Parameters: LongWord;
    Techniques: LongWord;
  end;
  D3DXEFFECT_DESC = _D3DXEFFECT_DESC;
  TD3DXEffectDesc = _D3DXEFFECT_DESC;


  PD3DXParameterDesc = ^TD3DXParameterDesc;
  _D3DXPARAMETER_DESC = packed record
    Name:  PAnsiChar;
    Index: PAnsiChar;
    _Type: TD3DXParameterType;
  end;
  D3DXPARAMETER_DESC = _D3DXPARAMETER_DESC;
  TD3DXParameterDesc = _D3DXPARAMETER_DESC;


  PD3DXTechniqueDesc = ^TD3DXTechniqueDesc;
  _D3DXTECHNIQUE_DESC = packed record
    Name:  PAnsiChar;
    Index: PAnsiChar;
    Passes: LongWord;
  end;
  D3DXTECHNIQUE_DESC = _D3DXTECHNIQUE_DESC;
  TD3DXTechniqueDesc = _D3DXTECHNIQUE_DESC;


  PD3DXPassDesc = ^TD3DXPassDesc;
  _D3DXPASS_DESC = packed record
    Name:  PAnsiChar;
    Index: PAnsiChar;
  end;
  D3DXPASS_DESC = _D3DXPASS_DESC;
  TD3DXPassDesc = _D3DXPASS_DESC;



//////////////////////////////////////////////////////////////////////////////
// ID3DXEffect ///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


  ID3DXEffect = interface(IUnknown)
    ['{648B1CEB-8D4E-4d66-B6FA-E44969E82E89}']
    // ID3DXEffect
    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;
    function GetDesc(out pDesc: TD3DXEffectDesc): HResult; stdcall;
    function GetParameterDesc(pParameter: PAnsiChar; out pDesc: TD3DXParameterDesc): HResult; stdcall;
    function GetTechniqueDesc(pTechnique: PAnsiChar; out pDesc: TD3DXTechniqueDesc): HResult; stdcall;
    function GetPassDesc(pTechnique, pPass: PAnsiChar; out pDesc: TD3DXPassDesc): HResult; stdcall;
    function FindNextValidTechnique(pTechnique: PAnsiChar; out pDesc: TD3DXTechniqueDesc): HResult; stdcall;
    function CloneEffect(pDevice: IDirect3DDevice8; out ppEffect: ID3DXEffect): HResult; stdcall;
    function GetCompiledEffect(out ppCompiledEffect: ID3DXBuffer): HResult; stdcall;

    function SetTechnique(pTechnique: PAnsiChar): HResult; stdcall;
    function GetTechnique(out ppTechnique: PAnsiChar): HResult; stdcall;

    function SetDword(pParameter: PAnsiChar; dw: DWord): HResult; stdcall;
    function GetDword(pParameter: PAnsiChar; out pdw: DWord): HResult; stdcall;
    function SetFloat(pParameter: PAnsiChar; f: Single): HResult; stdcall;
    function GetFloat(pParameter: PAnsiChar; out pf: Single): HResult; stdcall;
    function SetVector(pParameter: PAnsiChar; const pVector: TD3DXVector4): HResult; stdcall;
    function GetVector(pParameter: PAnsiChar; out pVector: TD3DXVector4): HResult; stdcall;
    function SetMatrix(pParameter: PAnsiChar; const pMatrix: TD3DXMatrix): HResult; stdcall;
    function GetMatrix(pParameter: PAnsiChar; out pMatrix: TD3DXMatrix): HResult; stdcall;
    function SetTexture(pParameter: PAnsiChar; pTexture: IDirect3DBaseTexture8): HResult; stdcall;
    function GetTexture(pParameter: PAnsiChar; out ppTexture: IDirect3DBaseTexture8): HResult; stdcall;
    function SetVertexShader(pParameter: PAnsiChar; Handle: DWord): HResult; stdcall;
    function GetVertexShader(pParameter: PAnsiChar; out Handle: DWord): HResult; stdcall;
    function SetPixelShader(pParameter: PAnsiChar; Handle: DWord): HResult; stdcall;
    function GetPixelShader(pParameter: PAnsiChar; out Handle: DWord): HResult; stdcall;
    function SetString(pParameter: PAnsiChar; pString: PAnsiChar): HResult; stdcall;
    function GetString(pParameter: PAnsiChar; out ppString: PAnsiChar): HResult; stdcall;
    function IsParameterUsed(pParameter: PAnsiChar): BOOL; stdcall;

    function Validate: HResult; stdcall;
    function _Begin(out pPasses: LongWord; Flags: DWord): HResult; stdcall;
    function Pass(Pass: LongWord): HResult; stdcall;
    function _End: HResult; stdcall;
    function OnLostDevice: HResult; stdcall;
    function OnResetDevice: HResult; stdcall;
  end;



//////////////////////////////////////////////////////////////////////////////
// APIs //////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



//----------------------------------------------------------------------------
// D3DXCreateEffect:
// -----------------
// Creates an effect from an ascii or binaray effect description.
//
// Parameters:
//  pDevice
//      Pointer of the device on which to create the effect
//  pSrcFile
//      Name of the file containing the effect description
//  hSrcModule
//      Module handle. if NULL, current module will be used.
//  pSrcResource
//      Resource name in module
//  pSrcData
//      Pointer to effect description
//  SrcDataSize
//      Size of the effect description in bytes
//  ppEffect
//      Returns a buffer containing created effect.
//  ppCompilationErrors
//      Returns a buffer containing any error messages which occurred during
//      compile.  Or NULL if you do not care about the error messages.
//
//----------------------------------------------------------------------------

(*



function D3DXCreateEffectFromFileA(
  pDevice: IDirect3DDevice8;
  pSrcFile: PAnsiChar;
  out ppEffect: ID3DXEffect;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXCreateEffectFromFileA';
*)
var D3DXCreateEffectFromFileA : function( pDevice : IDirect3DDevice8 ; pSrcFile : PAnsiChar ; out ppEffect : ID3DXEffect ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXCreateEffectFromFileW(
  pDevice: IDirect3DDevice8;
  pSrcFile: PWideChar;
  out ppEffect: ID3DXEffect;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXCreateEffectFromFileW';
*)
var D3DXCreateEffectFromFileW : function( pDevice : IDirect3DDevice8 ; pSrcFile : PWideChar ; out ppEffect : ID3DXEffect ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXCreateEffectFromFile(
  pDevice: IDirect3DDevice8;
  pSrcFile: PChar;
  out ppEffect: ID3DXEffect;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXCreateEffectFromFileA';
*)
var D3DXCreateEffectFromFile : function( pDevice : IDirect3DDevice8 ; pSrcFile : PChar ; out ppEffect : ID3DXEffect ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXCreateEffectFromResourceA(
  pDevice: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  out ppEffect: ID3DXEffect;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXCreateEffectFromResourceA';
*)
var D3DXCreateEffectFromResourceA : function( pDevice : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; out ppEffect : ID3DXEffect ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXCreateEffectFromResourceW(
  pDevice: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  out ppEffect: ID3DXEffect;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXCreateEffectFromResourceW';
*)
var D3DXCreateEffectFromResourceW : function( pDevice : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PWideChar ; out ppEffect : ID3DXEffect ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXCreateEffectFromResource(
  pDevice: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PChar;
  out ppEffect: ID3DXEffect;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll name 'D3DXCreateEffectFromResourceA';
*)
var D3DXCreateEffectFromResource : function( pDevice : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PChar ; out ppEffect : ID3DXEffect ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;

(*



function D3DXCreateEffect(
  pDevice: IDirect3DDevice8;
  const pSrcData;
  SrcDataSize: LongWord;
  out ppEffect: ID3DXEffect;
  ppCompilationErrors: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateEffect : function( pDevice : IDirect3DDevice8 ; const pSrcData ; SrcDataSize : LongWord ; out ppEffect : ID3DXEffect ; ppCompilationErrors : PID3DXBuffer ) : HResult ; stdcall ;








//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8mesh.h
//  Content:    D3DX mesh types and functions
//
//////////////////////////////////////////////////////////////////////////////

type
  _D3DXMESH = DWord;
  TD3DXMesh = _D3DXMESH;

// Mesh options - lower 3 bytes only, upper byte used by _D3DXMESHOPT option flags
const
  D3DXMESH_32BIT                  = $001; // If set, then use 32 bit indices, if not set use 16 bit indices.
  D3DXMESH_DONOTCLIP              = $002; // Use D3DUSAGE_DONOTCLIP for VB & IB.
  D3DXMESH_POINTS                 = $004; // Use D3DUSAGE_POINTS for VB & IB.
  D3DXMESH_RTPATCHES              = $008; // Use D3DUSAGE_RTPATCHES for VB & IB.
  D3DXMESH_NPATCHES      = $4000;// Use D3DUSAGE_NPATCHES for VB & IB.
  D3DXMESH_VB_SYSTEMMEM      = $010; // Use D3DPOOL_SYSTEMMEM for VB. Overrides D3DXMESH_MANAGEDVERTEXBUFFER
  D3DXMESH_VB_MANAGED             = $020; // Use D3DPOOL_MANAGED for VB.
  D3DXMESH_VB_WRITEONLY           = $040; // Use D3DUSAGE_WRITEONLY for VB.
  D3DXMESH_VB_DYNAMIC             = $080; // Use D3DUSAGE_DYNAMIC for VB.
  D3DXMESH_VB_SOFTWAREPROCESSING = $8000; // Use D3DUSAGE_SOFTWAREPROCESSING for VB.
  D3DXMESH_IB_SYSTEMMEM      = $100; // Use D3DPOOL_SYSTEMMEM for IB. Overrides D3DXMESH_MANAGEDINDEXBUFFER
  D3DXMESH_IB_MANAGED             = $200; // Use D3DPOOL_MANAGED for IB.
  D3DXMESH_IB_WRITEONLY           = $400; // Use D3DUSAGE_WRITEONLY for IB.
  D3DXMESH_IB_DYNAMIC             = $800; // Use D3DUSAGE_DYNAMIC for IB.
  D3DXMESH_IB_SOFTWAREPROCESSING= $10000; // Use D3DUSAGE_SOFTWAREPROCESSING for IB.

  D3DXMESH_VB_SHARE               = $1000; // Valid for Clone* calls only, forces cloned mesh/pmesh to share vertex buffer

  D3DXMESH_USEHWONLY              = $2000; // Valid for ID3DXSkinMesh::ConvertToBlendedMesh

  // Helper options
  D3DXMESH_SYSTEMMEM      = $110; // D3DXMESH_VB_SYSTEMMEM | D3DXMESH_IB_SYSTEMMEM
  D3DXMESH_MANAGED                = $220; // D3DXMESH_VB_MANAGED | D3DXMESH_IB_MANAGED
  D3DXMESH_WRITEONLY              = $440; // D3DXMESH_VB_WRITEONLY | D3DXMESH_IB_WRITEONLY
  D3DXMESH_DYNAMIC                = $880; // D3DXMESH_VB_DYNAMIC | D3DXMESH_IB_DYNAMIC
  D3DXMESH_SOFTWAREPROCESSING   = $18000; // D3DXMESH_VB_SOFTWAREPROCESSING | D3DXMESH_IB_SOFTWAREPROCESSING

type
  // option field values for specifying min value in D3DXGeneratePMesh and D3DXSimplifyMesh
  _D3DXMESHSIMP = (
    D3DXMESHSIMP_INVALID_0{= 0x0},
    D3DXMESHSIMP_VERTEX   {= 0x1},
    D3DXMESHSIMP_FACE     {= 0x2}
  );
  TD3DMeshSimp = _D3DXMESHSIMP;

  _MAX_FVF_DECL_SIZE = DWord;
const
  MAX_FVF_DECL_SIZE = 20;

type
  TFVFDeclaration = array [0..MAX_FVF_DECL_SIZE-1] of DWord;

  PD3DXAttributeRange = ^TD3DXAttributeRange;
  _D3DXATTRIBUTERANGE = packed record
    AttribId:    DWord;
    FaceStart:   DWord;
    FaceCount:   DWord;
    VertexStart: DWord;
    VertexCount: DWord;
  end;
  D3DXATTRIBUTERANGE = _D3DXATTRIBUTERANGE;
  TD3DXAttributeRange = _D3DXATTRIBUTERANGE;

  PD3DXMaterial = ^TD3DXMaterial;
  D3DXMATERIAL = packed record
    MatD3D: TD3Dmaterial8;
    pTextureFilename: PAnsiChar;
  end;
  TD3DXMaterial = D3DXMATERIAL;

  PD3DXAttributeWeights = ^TD3DXAttributeWeights;
  _D3DXATTRIBUTEWEIGHTS = packed record
    Position: Single;
    Boundary: Single;
    Normal:   Single;
    Diffuse:  Single;
    Specular: Single;
    Tex: array[0..7] of Single;
  end;
  D3DXATTRIBUTEWEIGHTS = _D3DXATTRIBUTEWEIGHTS;
  TD3DXAttributeWeights = _D3DXATTRIBUTEWEIGHTS;

  _D3DXWELDEPSILONSFLAGS = DWord;
  TD3DXWeldEpsilonsFlags = _D3DXWELDEPSILONSFLAGS;

const
  D3DXWELDEPSILONS_WELDALL = $1;              // weld all vertices marked by adjacency as being overlapping

  D3DXWELDEPSILONS_WELDPARTIALMATCHES = $2;   // if a given vertex component is within epsilon, modify partial matched
                                                 // vertices so that both components identical AND if all components "equal"
                                                 // remove one of the vertices
  D3DXWELDEPSILONS_DONOTREMOVEVERTICES = $4;  // instructs weld to only allow modifications to vertices and not removal
                                                 // ONLY valid if D3DXWELDEPSILONS_WELDPARTIALMATCHES is set
                                                 // useful to modify vertices to be equal, but not allow vertices to be removed

type
  PD3DXWeldEpsilons = ^TD3DXWeldEpsilons;
  _D3DXWELDEPSILONS = packed record
    SkinWeights: Single;
    Normal: Single;
    Tex: array[0..7] of Single;
    Flags: DWord;
  end;
  D3DXWELDEPSILONS = _D3DXWELDEPSILONS;
  TD3DXWeldEpsilons = _D3DXWELDEPSILONS;

  ID3DXMesh = interface;

  ID3DXBaseMesh = interface(IUnknown)
    ['{2A835771-BF4D-43f4-8E14-82A809F17D8A}']
    // ID3DXBaseMesh
    function DrawSubset(AttribId: DWord): HResult; stdcall;
    function GetNumFaces: DWord; stdcall;
    function GetNumVertices: DWord; stdcall;
    function GetFVF: DWord; stdcall;
    function GetDeclaration(out Declaration: TFVFDeclaration): HResult; stdcall;
    function GetOptions: DWord; stdcall;
    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;
    function CloneMeshFVF(Options, FVF: DWord; ppDevice: IDirect3DDevice8;
      out ppCloneMesh: ID3DXMesh): HResult; stdcall;
    function CloneMesh(Options: DWord; pDeclaration: PDWord;
      ppDevice: IDirect3DDevice8; out ppCloneMesh: ID3DXMesh): HResult; stdcall;
    function GetVertexBuffer(out ppVB: IDirect3DVertexBuffer8): HResult; stdcall;
    function GetIndexBuffer(out ppIB: IDirect3DIndexBuffer8): HResult; stdcall;
    function LockVertexBuffer(Flags: DWord; out ppData: PByte): HResult; stdcall;
    function UnlockVertexBuffer: HResult; stdcall;
    function LockIndexBuffer(Flags: DWord; out ppData: PByte): HResult; stdcall;
    function UnlockIndexBuffer: HResult; stdcall;
    function GetAttributeTable(pAttribTable: PD3DXAttributeRange;
      pAttribTableSize: PDWord): HResult; stdcall;

    function ConvertPointRepsToAdjacency(pPRep: PDWord; pAdjacency: PDWord): HResult; stdcall;
    function ConvertAdjacencyToPointReps(pAdjacency: PDWord; pPRep: PDWord): HResult; stdcall;
    function GenerateAdjacency(Epsilon: Single; pAdjacency: PDWord): HResult; stdcall;
  end;

  ID3DXMesh = interface(ID3DXBaseMesh)
    ['{CCAE5C3B-4DD1-4d0f-997E-4684CA64557F}']
    // ID3DXMesh
    function LockAttributeBuffer(Flags: DWord; out ppData: PDWORD): HResult; stdcall;
    function UnlockAttributeBuffer: HResult; stdcall;
    function Optimize(Flags: DWord; pAdjacencyIn, pAdjacencyOut: PDWord;
      pFaceRemap: PDWord; ppVertexRemap: PID3DXBuffer;
      out ppOptMesh: ID3DXMesh): HResult; stdcall;
    function OptimizeInplace(Flags: DWord; pAdjacencyIn, pAdjacencyOut: PDWord;
      pFaceRemap: PDWord; ppVertexRemap: PID3DXBuffer): HResult; stdcall;
  end;

  ID3DXPMesh = interface(ID3DXBaseMesh)
    ['{19FBE386-C282-4659-97BD-CB869B084A6C}']
    // ID3DXPMesh
    function ClonePMeshFVF(Options, FVF: DWord; ppDevice: IDirect3DDevice8;
      out ppCloneMesh: ID3DXPMesh): HResult; stdcall;
    function ClonePMesh(Options: DWord; pDeclaration: PDWord;
      ppDevice: IDirect3DDevice8; out ppCloneMesh: ID3DXPMesh): HResult; stdcall;
    function SetNumFaces(Faces: DWord): HResult; stdcall;
    function SetNumVertices(Vertices: DWord): HResult; stdcall;
    function GetMaxFaces: DWord; stdcall;
    function GetMinFaces: DWord; stdcall;
    function GetMaxVertices: DWord; stdcall;
    function GetMinVertices: DWord; stdcall;
    function Save(pStream: IStream; pMaterials: PD3DXMaterial;
       NumMaterials: DWord): HResult; stdcall;

    function Optimize(Flags: DWord; pAdjacencyOut: PDWord;
      pFaceRemap: PDWord; ppVertexRemap: PID3DXBuffer;
      out ppOptMesh: ID3DXMesh): HResult; stdcall;

    function OptimizeBaseLOD(Flags: DWord; pFaceRemap: PDWord): HResult; stdcall;
    function TrimByFaces(NewFacesMin, NewFacesMax: DWord; rgiFaceRemap, rgiVertRemap: PDWord): HResult; stdcall;
    function TrimByVertices(NewVerticesMin, NewVerticesMax: DWord; rgiFaceRemap, rgiVertRemap: PDWord): HResult; stdcall;

    function GetAdjacency(pAdjacency: PDWord): HResult; stdcall;
  end;

  ID3DXSPMesh = interface(IUnknown)
    ['{4E3CA05C-D4FF-4d11-8A02-16459E08F6F4}']
    // ID3DXSPMesh
    function GetNumFaces: DWord; stdcall;
    function GetNumVertices: DWord; stdcall;
    function GetFVF: DWord; stdcall;
    function GetDeclaration(out Declaration: TFVFDeclaration): HResult; stdcall;
    function GetOptions: DWord; stdcall;

    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;
    function CloneMeshFVF(Options, FVF: DWord; ppDevice: IDirect3DDevice8;
      pAdjacencyOut, pVertexRemapOut: PDWord;
      out ppCloneMesh: ID3DXMesh): HResult; stdcall;
    function CloneMesh(Options: DWord; pDeclaration: PDWord;
      ppDevice: IDirect3DDevice8; pAdjacencyOut, pVertexRemapOut: PDWord;
      out ppCloneMesh: ID3DXMesh): HResult; stdcall;

    function ClonePMeshFVF(Options, FVF: DWord; ppDevice: IDirect3DDevice8;
      pVertexRemapOut: PDWord; out ppCloneMesh: ID3DXPMesh): HResult; stdcall;
    function ClonePMesh(Options: DWord; pDeclaration: PDWord;
      ppDevice: IDirect3DDevice8; pVertexRemapOut: PDWord;
      out ppCloneMesh: ID3DXPMesh): HResult; stdcall;

    function ReduceFaces(Faces: DWord): HResult; stdcall;
    function ReduceVertices(Vertices: DWord): HResult; stdcall;
    function GetMaxFaces: DWord; stdcall;
    function GetMaxVertices: DWord; stdcall;
    function GetVertexAttributeWeights(pVertexAttributeWeights: PD3DXAttributeWeights): HResult; stdcall;
    function GetVertexWeights(pVertexWeights: PSingle): HResult; stdcall;
  end;

const
  UNUSED16      = $ffff;
  UNUSED32      = $ffffffff;

// ID3DXMesh::Optimize options - upper byte only, lower 3 bytes used from _D3DXMESH option flags
type
  _D3DXMESHOPT = DWord;
  TD3DXMeshOpt = _D3DXMESHOPT;

const
  D3DXMESHOPT_COMPACT       = $01000000;
  D3DXMESHOPT_ATTRSORT      = $02000000;
  D3DXMESHOPT_VERTEXCACHE   = $04000000;
  D3DXMESHOPT_STRIPREORDER  = $08000000;
  D3DXMESHOPT_IGNOREVERTS   = $10000000;  // optimize faces only; don't touch vertices
  D3DXMESHOPT_SHAREVB       =     $1000;         // same as D3DXMESH_VB_SHARE

// Subset of the mesh that has the same attribute and bone combination.
// This subset can be rendered in a single draw call
type
  PDWordArray = ^TDWordArray;
  TDWordArray = array[0..8181] of DWord;

  PD3DXBoneCombination = ^TD3DXBoneCombination;
  _D3DXBONECOMBINATION = packed record
    AttribId: DWord;
    FaceStart: DWord;
    FaceCount: DWord;
    VertexStart: DWord;
    VertexCount: DWord;
    BoneId: PDWordArray; // [ DWORD* ]  in original d3dx8mesh.h
  end;
  D3DXBONECOMBINATION = _D3DXBONECOMBINATION;
  TD3DXBoneCombination = _D3DXBONECOMBINATION;

  ID3DXSkinMesh = interface(IUnknown)
    ['{8DB06ECC-EBFC-408a-9404-3074B4773515}']
    // close to ID3DXMesh
    function GetNumFaces: DWord; stdcall;
    function GetNumVertices: DWord; stdcall;
    function GetFVF: DWord; stdcall;
    function GetDeclaration(out Declaration: TFVFDeclaration): HResult; stdcall;
    function GetOptions: DWord; stdcall;
    function GetDevice(out ppDevice: IDirect3DDevice8): HResult; stdcall;
    function GetVertexBuffer(out ppVB: IDirect3DVertexBuffer8): HResult; stdcall;
    function GetIndexBuffer(out ppIB: IDirect3DIndexBuffer8): HResult; stdcall;
    function LockVertexBuffer(Flags: DWord; out ppData: PByte): HResult; stdcall;
    function UnlockVertexBuffer: HResult; stdcall;
    function LockIndexBuffer(Flags: DWord; out ppData: PByte): HResult; stdcall;
    function UnlockIndexBuffer: HResult; stdcall;
    function LockAttributeBuffer(Flags: DWord; out ppData: PDWORD): HResult; stdcall;
    function UnlockAttributeBuffer: HResult; stdcall;
    // ID3DXSkinMesh
    function GetNumBones: DWord; stdcall;
    function GetOriginalMesh(out ppMesh: ID3DXMesh): HResult; stdcall;
    function SetBoneInfluence(bone, numInfluences: DWord; vertices: PDWord;
      weights: PSingle): HResult; stdcall;
    function GetNumBoneInfluences(bone: DWord): DWord; stdcall;
    function GetBoneInfluence(bone: DWord; vertices: PDWord;
      weights: PSingle): HResult; stdcall;
    function GetMaxVertexInfluences(out maxVertexInfluences: DWord): HResult; stdcall;
    function GetMaxFaceInfluences(out maxFaceInfluences: DWord): HResult; stdcall;

    function ConvertToBlendedMesh(Options: DWord;
      pAdjacencyIn, pAdjacencyOut: PDWord;
      out pNumBoneCombinations: DWord; out ppBoneCombinationTable: ID3DXBuffer;
      pFaceRemap: PDWord; ppVertexRemap: PID3DXBuffer;
      out ppMesh: ID3DXMesh): HResult; stdcall;

    function ConvertToIndexedBlendedMesh(Options: DWord;
      pAdjacencyIn: PDWord; paletteSize: DWord; pAdjacencyOut: PDWord;
      out pNumBoneCombinations: DWord; out ppBoneCombinationTable: ID3DXBuffer;
      pFaceRemap: PDWord; ppVertexRemap: PID3DXBuffer;
      out ppMesh: ID3DXMesh): HResult; stdcall;

    function GenerateSkinnedMesh(Options: DWord; minWeight: Single;
      pAdjacencyIn, pAdjacencyOut: PDWord;
      pFaceRemap: PDWord; ppVertexRemap: PID3DXBuffer;
      out ppMesh: ID3DXMesh): HResult; stdcall;
    function UpdateSkinnedMesh(
      const pBoneTransforms: TD3DXmatrix; pBoneInvTransforms: PD3DXmatrix;
      ppMesh: ID3DXMesh): HResult; stdcall;
  end;

type
  IID_ID3DXBaseMesh     = ID3DXBaseMesh;
  IID_ID3DXMesh         = ID3DXMesh;
  IID_ID3DXPMesh        = ID3DXPMesh;
  IID_ID3DXSPMesh       = ID3DXSPMesh;
  IID_ID3DXSkinMesh     = ID3DXSkinMesh;
(*



function D3DXCreateMesh(NumFaces, NumVertices: DWord; Options: DWord;
  pDeclaration: PDWord; pD3D: IDirect3DDevice8; out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateMesh : function( NumFaces , NumVertices : DWord ; Options : DWord ; pDeclaration : PDWord ; pD3D : IDirect3DDevice8 ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXCreateMeshFVF(NumFaces, NumVertices: DWord; Options: DWord;
  FVF: DWord; pD3D: IDirect3DDevice8; out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateMeshFVF : function( NumFaces , NumVertices : DWord ; Options : DWord ; FVF : DWord ; pD3D : IDirect3DDevice8 ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXCreateSPMesh(pMesh: ID3DXMesh; pAdjacency: PDWord;
  pVertexAttributeWeights: PD3DXAttributeWeights; pVertexWeights: PSingle;
  out ppSMesh: ID3DXSPMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateSPMesh : function( pMesh : ID3DXMesh ; pAdjacency : PDWord ; pVertexAttributeWeights : PD3DXAttributeWeights ; pVertexWeights : PSingle ; out ppSMesh : ID3DXSPMesh ) : HResult ; stdcall ;


// clean a mesh up for simplification, try to make manifold

(*

function D3DXCleanMesh(pMeshIn: ID3DXMesh; pAdjacencyIn: PDWord;
  out ppMeshOut: ID3DXMesh; pAdjacencyOut: PDWord;
  ppErrorsAndWarnings: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCleanMesh : function( pMeshIn : ID3DXMesh ; pAdjacencyIn : PDWord ; out ppMeshOut : ID3DXMesh ; pAdjacencyOut : PDWord ; ppErrorsAndWarnings : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXValidMesh(pMeshIn: ID3DXMesh; pAdjacency: PDWord;
  ppErrorsAndWarnings: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXValidMesh : function( pMeshIn : ID3DXMesh ; pAdjacency : PDWord ; ppErrorsAndWarnings : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXGeneratePMesh(pMesh: ID3DXMesh; pAdjacency: PDWord;
  pVertexAttributeWeights: PD3DXAttributeWeights; pVertexWeights: PSingle;
  MinValue: DWord; Options: TD3DMeshSimp; out ppPMesh: ID3DXPMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXGeneratePMesh : function( pMesh : ID3DXMesh ; pAdjacency : PDWord ; pVertexAttributeWeights : PD3DXAttributeWeights ; pVertexWeights : PSingle ; MinValue : DWord ; Options : TD3DMeshSimp ; out ppPMesh : ID3DXPMesh ) : HResult ; stdcall ;

(*


function D3DXSimplifyMesh(pMesh: ID3DXMesh; pAdjacency: PDWord;
  pVertexAttributeWeights: PD3DXAttributeWeights; pVertexWeights: PSingle;
  MinValue: DWord; Options: TD3DMeshSimp; out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXSimplifyMesh : function( pMesh : ID3DXMesh ; pAdjacency : PDWord ; pVertexAttributeWeights : PD3DXAttributeWeights ; pVertexWeights : PSingle ; MinValue : DWord ; Options : TD3DMeshSimp ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXComputeBoundingSphere(const pPointsFVF; NumVertices: DWord;
  FVF: DWord; out pCenter: TD3DXVector3; out pRadius: Single): HResult; stdcall; external d3dx8dll;
*)
var D3DXComputeBoundingSphere : function( const pPointsFVF ; NumVertices : DWord ; FVF : DWord ; out pCenter : TD3DXVector3 ; out pRadius : Single ) : HResult ; stdcall ;

(*


function D3DXComputeBoundingBox(const pPointsFVF; NumVertices: DWord;
  FVF: DWord; out pMin, pMax: TD3DXVector3): HResult; stdcall; external d3dx8dll;
*)
var D3DXComputeBoundingBox : function( const pPointsFVF ; NumVertices : DWord ; FVF : DWord ; out pMin , pMax : TD3DXVector3 ) : HResult ; stdcall ;

(*


function D3DXComputeNormals(pMesh: ID3DXBaseMesh; pAdjacency: PDWord): HResult; stdcall; external d3dx8dll;
*)
var D3DXComputeNormals : function( pMesh : ID3DXBaseMesh ; pAdjacency : PDWord ) : HResult ; stdcall ;

(*


function D3DXCreateBuffer(NumBytes: DWord; out ppBuffer: ID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateBuffer : function( NumBytes : DWord ; out ppBuffer : ID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXLoadMeshFromX(pFilename: PAnsiChar; Options: DWord;
  pD3D: IDirect3DDevice8; ppAdjacency, ppMaterials: PID3DXBuffer;
  pNumMaterials: PDWord; out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadMeshFromX : function( pFilename : PAnsiChar ; Options : DWord ; pD3D : IDirect3DDevice8 ; ppAdjacency , ppMaterials : PID3DXBuffer ; pNumMaterials : PDWord ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXLoadMeshFromXInMemory(Memory: PByte; SizeOfMemory: DWord;
  Options: DWord; pD3D: IDirect3DDevice8;
  ppAdjacency, ppMaterials: PID3DXBuffer;
  pNumMaterials: PDWord; out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadMeshFromXInMemory : function( Memory : PByte ; SizeOfMemory : DWord ; Options : DWord ; pD3D : IDirect3DDevice8 ; ppAdjacency , ppMaterials : PID3DXBuffer ; pNumMaterials : PDWord ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXLoadMeshFromXResource(Module: HModule; Name: PAnsiChar; _Type: PAnsiChar;
  Options: DWord; pD3D: IDirect3DDevice8;
  ppAdjacency, ppMaterials: PID3DXBuffer;
  pNumMaterials: PDWord; out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadMeshFromXResource : function( Module : HModule ; Name : PAnsiChar ; _Type : PAnsiChar ; Options : DWord ; pD3D : IDirect3DDevice8 ; ppAdjacency , ppMaterials : PID3DXBuffer ; pNumMaterials : PDWord ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXSaveMeshToX(pFilename: PAnsiChar; ppMesh: ID3DXMesh;
  pAdjacency: PDWord; pMaterials: PD3DXMaterial; NumMaterials: DWord;
  Format: DWord): HResult; stdcall; external d3dx8dll;
*)
var D3DXSaveMeshToX : function( pFilename : PAnsiChar ; ppMesh : ID3DXMesh ; pAdjacency : PDWord ; pMaterials : PD3DXMaterial ; NumMaterials : DWord ; Format : DWord ) : HResult ; stdcall ;

(*


function D3DXCreatePMeshFromStream(pStream: IStream; Options: DWord;
  pD3D: IDirect3DDevice8; ppMaterials: PID3DXBuffer;
  pNumMaterials: PDWord; out ppPMesh: ID3DXPMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreatePMeshFromStream : function( pStream : IStream ; Options : DWord ; pD3D : IDirect3DDevice8 ; ppMaterials : PID3DXBuffer ; pNumMaterials : PDWord ; out ppPMesh : ID3DXPMesh ) : HResult ; stdcall ;

(*


function D3DXCreateSkinMesh(NumFaces, NumVertices, NumBones, Options: DWord;
  pDeclaration: PDWord; pD3D: IDirect3DDevice8;
  out ppSkinMesh: ID3DXSkinMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateSkinMesh : function( NumFaces , NumVertices , NumBones , Options : DWord ; pDeclaration : PDWord ; pD3D : IDirect3DDevice8 ; out ppSkinMesh : ID3DXSkinMesh ) : HResult ; stdcall ;

(*


function D3DXCreateSkinMeshFVF(NumFaces, NumVertices, NumBones, Options: DWord;
  FVF: DWord; pD3D: IDirect3DDevice8;
  out ppSkinMesh: ID3DXSkinMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateSkinMeshFVF : function( NumFaces , NumVertices , NumBones , Options : DWord ; FVF : DWord ; pD3D : IDirect3DDevice8 ; out ppSkinMesh : ID3DXSkinMesh ) : HResult ; stdcall ;

(*


function D3DXCreateSkinMeshFromMesh(pMesh: ID3DXMesh; numBones: DWord;
  out ppSkinMesh: ID3DXSkinMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateSkinMeshFromMesh : function( pMesh : ID3DXMesh ; numBones : DWord ; out ppSkinMesh : ID3DXSkinMesh ) : HResult ; stdcall ;

(*


function D3DXLoadMeshFromXof(pXofObjMesh: IDirectXFileData;
  Options: DWord; pD3D: IDirect3DDevice8;
  ppAdjacency, ppMaterials: PID3DXBuffer;
  pNumMaterials: PDWord; out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadMeshFromXof : function( pXofObjMesh : IDirectXFileData ; Options : DWord ; pD3D : IDirect3DDevice8 ; ppAdjacency , ppMaterials : PID3DXBuffer ; pNumMaterials : PDWord ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXLoadSkinMeshFromXof(pXofObjMesh: IDirectXFileData;
  Options: DWord; pD3D: IDirect3DDevice8;
  ppAdjacency, ppMaterials: PID3DXBuffer;
  pmMatOut: PDWord; ppBoneNames, ppBoneTransforms: PID3DXBuffer;
  out ppMesh: ID3DXMesh): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadSkinMeshFromXof : function( pXofObjMesh : IDirectXFileData ; Options : DWord ; pD3D : IDirect3DDevice8 ; ppAdjacency , ppMaterials : PID3DXBuffer ; pmMatOut : PDWord ; ppBoneNames , ppBoneTransforms : PID3DXBuffer ; out ppMesh : ID3DXMesh ) : HResult ; stdcall ;

(*


function D3DXTessellateNPatches(pMeshIn: ID3DXMesh;
  pAdjacencyIn: PDWord; NumSegs: Single;
  QuadraticInterpNormals: BOOL; // if false use linear intrep for normals, if true use quadratic
  out ppMeshOut: ID3DXMesh; ppAdjacencyOut: PDWord): HResult; stdcall; external d3dx8dll;
*)
var D3DXTessellateNPatches : function( pMeshIn : ID3DXMesh ; pAdjacencyIn : PDWord ; NumSegs : Single ; QuadraticInterpNormals : BOOL ; out ppMeshOut : ID3DXMesh ; ppAdjacencyOut : PDWord ) : HResult ; stdcall ;

(*


function D3DXGetFVFVertexSize(FVF: DWord): LongWord; stdcall; external d3dx8dll;
*)
var D3DXGetFVFVertexSize : function( FVF : DWord ) : LongWord ; stdcall ;

(*


function D3DXDeclaratorFromFVF(FVF: DWord; out Declaration: TFVFDeclaration): HResult; stdcall; external d3dx8dll;
*)
var D3DXDeclaratorFromFVF : function( FVF : DWord ; out Declaration : TFVFDeclaration ) : HResult ; stdcall ;

(*


function D3DXFVFFromDeclarator(pDeclarator: PDWord; out pFVF: DWord): HResult; stdcall; external d3dx8dll;
*)
var D3DXFVFFromDeclarator : function( pDeclarator : PDWord ; out pFVF : DWord ) : HResult ; stdcall ;

(*


function D3DXWeldVertices(pMesh: ID3DXMesh; pEpsilons: PD3DXWeldEpsilons;
  rgdwAdjacencyIn, rgdwAdjacencyOut, pFaceRemap: PDWord;
  ppVertexRemap: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXWeldVertices : function( pMesh : ID3DXMesh ; pEpsilons : PD3DXWeldEpsilons ; rgdwAdjacencyIn , rgdwAdjacencyOut , pFaceRemap : PDWord ; ppVertexRemap : PID3DXBuffer ) : HResult ; stdcall ;


type
  PD3DXIntersectInfo = ^TD3DXIntersectInfo;
  _D3DXINTERSECTINFO = packed record
    FaceIndex: DWord;                // index of face intersected
    U: Single;                       // Barycentric Hit Coordinates
    V: Single;                       // Barycentric Hit Coordinates
    Dist: Single;                    // Ray-Intersection Parameter Distance
  end;
  D3DXINTERSECTINFO = _D3DXINTERSECTINFO;
  TD3DXIntersectInfo = _D3DXINTERSECTINFO;
(*


function D3DXIntersect(pMesh: ID3DXBaseMesh;
  const pRayPos, pRayDir: TD3DXVector3;
  out pHit: BOOL;                   // True if any faces were intersected
  pFaceIndex: PDWord;               // index of closest face intersected
  pU: PSingle;                      // Barycentric Hit Coordinates
  pV: PSingle;                      // Barycentric Hit Coordinates
  pDist: PSingle;                   // Ray-Intersection Parameter Distance
  ppAllHits: PID3DXBuffer;          // Array of D3DXINTERSECTINFOs for all hits (not just closest)
  pCountOfHits: PDWord              // Number of entries in AllHits array
 ): HResult; stdcall; external d3dx8dll;
*)
var D3DXIntersect : function( pMesh : ID3DXBaseMesh ; const pRayPos , pRayDir : TD3DXVector3 ; out pHit : BOOL ; pFaceIndex : PDWord ; pU : PSingle ; pV : PSingle ; pDist : PSingle ; ppAllHits : PID3DXBuffer ; pCountOfHits : PDWord ) : HResult ; stdcall ;

(*


function D3DXIntersectSubset(pMesh: ID3DXBaseMesh; AttribId: DWord;
  const pRayPos, pRayDir: TD3DXVector3;
  out pHit: BOOL;                   // True if any faces were intersected
  pFaceIndex: PDWord;               // index of closest face intersected
  pU: PSingle;                      // Barycentric Hit Coordinates
  pV: PSingle;                      // Barycentric Hit Coordinates
  pDist: PSingle;                   // Ray-Intersection Parameter Distance
  ppAllHits: PID3DXBuffer;          // Array of D3DXINTERSECTINFOs for all hits (not just closest)
  pCountOfHits: PDWord              // Number of entries in AllHits array
 ): HResult; stdcall; external d3dx8dll;
*)
var D3DXIntersectSubset : function( pMesh : ID3DXBaseMesh ; AttribId : DWord ; const pRayPos , pRayDir : TD3DXVector3 ; out pHit : BOOL ; pFaceIndex : PDWord ; pU : PSingle ; pV : PSingle ; pDist : PSingle ; ppAllHits : PID3DXBuffer ; pCountOfHits : PDWord ) : HResult ; stdcall ;

(*



function D3DXSplitMesh(pMeshIn: ID3DXMesh; pAdjacencyIn: PDWord;
  MaxSize, Options: DWord;
  out pMeshesOut: DWord; out ppMeshArrayOut: ID3DXBuffer;
  ppAdjacencyArrayOut, ppFaceRemapArrayOut, ppVertRemapArrayOut: PID3DXBuffer
 ): HResult; stdcall; external d3dx8dll;
*)
var D3DXSplitMesh : function( pMeshIn : ID3DXMesh ; pAdjacencyIn : PDWord ; MaxSize , Options : DWord ; out pMeshesOut : DWord ; out ppMeshArrayOut : ID3DXBuffer ; ppAdjacencyArrayOut , ppFaceRemapArrayOut , ppVertRemapArrayOut : PID3DXBuffer ) : HResult ; stdcall ;

(*


function D3DXIntersectTri(
    const p0: TD3DXVector3;           // Triangle vertex 0 position
    const p1: TD3DXVector3;           // Triangle vertex 1 position
    const p2: TD3DXVector3;           // Triangle vertex 2 position
    const pRayPos: TD3DXVector3;      // Ray origin
    const pRayDir: TD3DXVector3;      // Ray direction
    out pU: Single;                   // Barycentric Hit Coordinates
    out pV: Single;                   // Barycentric Hit Coordinates
    out pDist: Single                 // Ray-Intersection Parameter Distance
 ): BOOL; stdcall; external d3dx8dll;
*)
var D3DXIntersectTri : function( const p0 : TD3DXVector3 ; const p1 : TD3DXVector3 ; const p2 : TD3DXVector3 ; const pRayPos : TD3DXVector3 ; const pRayDir : TD3DXVector3 ; out pU : Single ; out pV : Single ; out pDist : Single ) : BOOL ; stdcall ;

(*


function D3DXSphereBoundProbe(const pCenter: TD3DXVector3; Radius: Single;
  out pRayPosition, pRayDirection: TD3DXVector3): BOOL; stdcall; external d3dx8dll;
*)
var D3DXSphereBoundProbe : function( const pCenter : TD3DXVector3 ; Radius : Single ; out pRayPosition , pRayDirection : TD3DXVector3 ) : BOOL ; stdcall ;

(*


function D3DXBoxBoundProbe(const pMin, pMax: TD3DXVector3;
  out pRayPosition, pRayDirection: TD3DXVector3): BOOL; stdcall; external d3dx8dll;
*)
var D3DXBoxBoundProbe : function( const pMin , pMax : TD3DXVector3 ; out pRayPosition , pRayDirection : TD3DXVector3 ) : BOOL ; stdcall ;


type
  _D3DXERR = HResult;

const
  D3DXERR_CANNOTMODIFYINDEXBUFFER       = HResult(MAKE_D3DHRESULT_R or 2900);
  D3DXERR_INVALIDMESH      = HResult(MAKE_D3DHRESULT_R or 2901);
  D3DXERR_CANNOTATTRSORT                = HResult(MAKE_D3DHRESULT_R or 2902);
  D3DXERR_SKINNINGNOTSUPPORTED    = HResult(MAKE_D3DHRESULT_R or 2903);
  D3DXERR_TOOMANYINFLUENCES    = HResult(MAKE_D3DHRESULT_R or 2904);
  D3DXERR_INVALIDDATA                   = HResult(MAKE_D3DHRESULT_R or 2905);
  D3DXERR_LOADEDMESHASNODATA            = HResult(MAKE_D3DHRESULT_R or 2906);

const
  D3DX_COMP_TANGENT_NONE = $FFFFFFFF;
(*


function D3DXComputeTangent(InMesh: ID3DXMesh; TexStage: DWord;
  OutMesh: ID3DXMesh; TexStageUVec, TexStageVVec: DWord;
  Wrap: DWord; Adjacency: PDWord): HResult; stdcall; external d3dx8dll;
*)
var D3DXComputeTangent : function( InMesh : ID3DXMesh ; TexStage : DWord ; OutMesh : ID3DXMesh ; TexStageUVec , TexStageVVec : DWord ; Wrap : DWord ; Adjacency : PDWord ) : HResult ; stdcall ;

(*


function D3DXConvertMeshSubsetToSingleStrip(MeshIn: ID3DXBaseMesh;
  AttribId: DWord; IBOptions: DWord;
  out ppIndexBuffer: IDirect3DIndexBuffer8; pNumIndices: PDWord
 ): HResult; stdcall; external d3dx8dll;
*)
var D3DXConvertMeshSubsetToSingleStrip : function( MeshIn : ID3DXBaseMesh ; AttribId : DWord ; IBOptions : DWord ; out ppIndexBuffer : IDirect3DIndexBuffer8 ; pNumIndices : PDWord ) : HResult ; stdcall ;

(*


function D3DXConvertMeshSubsetToStrips(MeshIn: ID3DXBaseMesh;
  AttribId: DWord; IBOptions: DWord;
  out ppIndexBuffer: IDirect3DIndexBuffer8; pNumIndices: PDWord;
  ppStripLengths: PID3DXBuffer; pNumStrips: PDWord): HResult; stdcall; external d3dx8dll;
*)
var D3DXConvertMeshSubsetToStrips : function( MeshIn : ID3DXBaseMesh ; AttribId : DWord ; IBOptions : DWord ; out ppIndexBuffer : IDirect3DIndexBuffer8 ; pNumIndices : PDWord ; ppStripLengths : PID3DXBuffer ; pNumStrips : PDWord ) : HResult ; stdcall ;








///////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8shapes.h
//  Content:    D3DX simple shapes
//
///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
// Functions:
///////////////////////////////////////////////////////////////////////////


//-------------------------------------------------------------------------
// D3DXCreatePolygon:
// ------------------
// Creates a mesh containing an n-sided polygon.  The polygon is centered
// at the origin.
//
// Parameters:
//
//  pDevice     The D3D device with which the mesh is going to be used.
//  Length      Length of each side.
//  Sides       Number of sides the polygon has.  (Must be >= 3)
//  ppMesh      The mesh object which will be created
//  ppAdjacency Returns a buffer containing adjacency info.  Can be NULL.
//-------------------------------------------------------------------------

(*

function D3DXCreatePolygon(ppDevice: IDirect3DDevice8;
  Length: Single;
  Sides: LongWord;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreatePolygon : function( ppDevice : IDirect3DDevice8 ; Length : Single ; Sides : LongWord ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ) : HResult ; stdcall ;



//-------------------------------------------------------------------------
// D3DXCreateBox:
// --------------
// Creates a mesh containing an axis-aligned box.  The box is centered at
// the origin.
//
// Parameters:
//
//  pDevice     The D3D device with which the mesh is going to be used.
//  Width       Width of box (along X-axis)
//  Height      Height of box (along Y-axis)
//  Depth       Depth of box (along Z-axis)
//  ppMesh      The mesh object which will be created
//  ppAdjacency Returns a buffer containing adjacency info.  Can be NULL.
//-------------------------------------------------------------------------

(*

function D3DXCreateBox(ppDevice: IDirect3DDevice8;
  Width,
  Height,
  Depth: Single;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateBox : function( ppDevice : IDirect3DDevice8 ; Width , Height , Depth : Single ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ) : HResult ; stdcall ;



//-------------------------------------------------------------------------
// D3DXCreateCylinder:
// -------------------
// Creates a mesh containing a cylinder.  The generated cylinder is
// centered at the origin, and its axis is aligned with the Z-axis.
//
// Parameters:
//
//  pDevice     The D3D device with which the mesh is going to be used.
//  Radius1     Radius at -Z end (should be >= 0.0f)
//  Radius2     Radius at +Z end (should be >= 0.0f)
//  Length      Length of cylinder (along Z-axis)
//  Slices      Number of slices about the main axis
//  Stacks      Number of stacks along the main axis
//  ppMesh      The mesh object which will be created
//  ppAdjacency Returns a buffer containing adjacency info.  Can be NULL.
//-------------------------------------------------------------------------

(*

function D3DXCreateCylinder(ppDevice: IDirect3DDevice8;
  Radius1,
  Radius2,
  Length: Single;
  Slices,
  Stacks: LongWord;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateCylinder : function( ppDevice : IDirect3DDevice8 ; Radius1 , Radius2 , Length : Single ; Slices , Stacks : LongWord ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ) : HResult ; stdcall ;



//-------------------------------------------------------------------------
// D3DXCreateSphere:
// -----------------
// Creates a mesh containing a sphere.  The sphere is centered at the
// origin.
//
// Parameters:
//
//  pDevice     The D3D device with which the mesh is going to be used.
//  Radius      Radius of the sphere (should be >= 0.0f)
//  Slices      Number of slices about the main axis
//  Stacks      Number of stacks along the main axis
//  ppMesh      The mesh object which will be created
//  ppAdjacency Returns a buffer containing adjacency info.  Can be NULL.
//-------------------------------------------------------------------------

(*

function D3DXCreateSphere(ppDevice: IDirect3DDevice8;
  Radius: Single;
  Slices,
  Stacks: LongWord;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateSphere : function( ppDevice : IDirect3DDevice8 ; Radius : Single ; Slices , Stacks : LongWord ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ) : HResult ; stdcall ;



//-------------------------------------------------------------------------
// D3DXCreateTorus:
// ----------------
// Creates a mesh containing a torus.  The generated torus is centered at
// the origin, and its axis is aligned with the Z-axis.
//
// Parameters:
//
//  pDevice     The D3D device with which the mesh is going to be used.
//  InnerRadius Inner radius of the torus (should be >= 0.0f)
//  OuterRadius Outer radius of the torue (should be >= 0.0f)
//  Sides       Number of sides in a cross-section (must be >= 3)
//  Rings       Number of rings making up the torus (must be >= 3)
//  ppMesh      The mesh object which will be created
//  ppAdjacency Returns a buffer containing adjacency info.  Can be NULL.
//-------------------------------------------------------------------------

(*

function D3DXCreateTorus(ppDevice: IDirect3DDevice8;
  InnerRadius,
  OuterRadius: Single;
  Sides,
  Rings: LongWord;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateTorus : function( ppDevice : IDirect3DDevice8 ; InnerRadius , OuterRadius : Single ; Sides , Rings : LongWord ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ) : HResult ; stdcall ;



//-------------------------------------------------------------------------
// D3DXCreateTeapot:
// -----------------
// Creates a mesh containing a teapot.
//
// Parameters:
//
//  pDevice     The D3D device with which the mesh is going to be used.
//  ppMesh      The mesh object which will be created
//  ppAdjacency Returns a buffer containing adjacency info.  Can be NULL.
//-------------------------------------------------------------------------

(*

function D3DXCreateTeapot(ppDevice: IDirect3DDevice8;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateTeapot : function( ppDevice : IDirect3DDevice8 ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ) : HResult ; stdcall ;



//-------------------------------------------------------------------------
// D3DXCreateText:
// ---------------
// Creates a mesh containing the specified text using the font associated
// with the device context.
//
// Parameters:
//
//  pDevice       The D3D device with which the mesh is going to be used.
//  hDC           Device context, with desired font selected
//  pText         Text to generate
//  Deviation     Maximum chordal deviation from true font outlines
//  Extrusion     Amount to extrude text in -Z direction
//  ppMesh        The mesh object which will be created
//  pGlyphMetrics Address of buffer to receive glyph metric data (or NULL)
//-------------------------------------------------------------------------

(*


function D3DXCreateTextA(ppDevice: IDirect3DDevice8;
  hDC: HDC;
  pText: PAnsiChar;
  Deviation: Single;
  Extrusion: Single;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer;
  pGlyphMetrics: PGlyphMetricsFloat): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextA';
*)
var D3DXCreateTextA : function( ppDevice : IDirect3DDevice8 ; hDC : HDC ; pText : PAnsiChar ; Deviation : Single ; Extrusion : Single ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ; pGlyphMetrics : PGlyphMetricsFloat ) : HResult ; stdcall ;

(*


function D3DXCreateTextW(ppDevice: IDirect3DDevice8;
  hDC: HDC;
  pText: PWideChar;
  Deviation: Single;
  Extrusion: Single;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer;
  pGlyphMetrics: PGlyphMetricsFloat): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextW';
*)
var D3DXCreateTextW : function( ppDevice : IDirect3DDevice8 ; hDC : HDC ; pText : PWideChar ; Deviation : Single ; Extrusion : Single ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ; pGlyphMetrics : PGlyphMetricsFloat ) : HResult ; stdcall ;

(*


function D3DXCreateText(ppDevice: IDirect3DDevice8;
  hDC: HDC;
  pText: PChar;
  Deviation: Single;
  Extrusion: Single;
  out ppMesh: ID3DXMesh;
  ppAdjacency: PID3DXBuffer;
  pGlyphMetrics: PGlyphMetricsFloat): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextA';
*)
var D3DXCreateText : function( ppDevice : IDirect3DDevice8 ; hDC : HDC ; pText : PChar ; Deviation : Single ; Extrusion : Single ; out ppMesh : ID3DXMesh ; ppAdjacency : PID3DXBuffer ; pGlyphMetrics : PGlyphMetricsFloat ) : HResult ; stdcall ;








//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8tex.h
//  Content:    D3DX texturing APIs
//
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// D3DX_FILTER flags:
// ------------------
//
// A valid filter must contain one of these values:
//
//  D3DX_FILTER_NONE
//      No scaling or filtering will take place.  Pixels outside the bounds
//      of the source image are assumed to be transparent black.
//  D3DX_FILTER_POINT
//      Each destination pixel is computed by sampling the nearest pixel
//      from the source image.
//  D3DX_FILTER_LINEAR
//      Each destination pixel is computed by linearly interpolating between
//      the nearest pixels in the source image.  This filter works best
//      when the scale on each axis is less than 2.
//  D3DX_FILTER_TRIANGLE
//      Every pixel in the source image contributes equally to the
//      destination image.  This is the slowest of all the filters.
//  D3DX_FILTER_BOX
//      Each pixel is computed by averaging a 2x2(x2) box pixels from
//      the source image. Only works when the dimensions of the
//      destination are half those of the source. (as with mip maps)
//
// And can be OR'd with any of these optional flags:
//
//  D3DX_FILTER_MIRROR_U
//      Indicates that pixels off the edge of the texture on the U-axis
//      should be mirrored, not wraped.
//  D3DX_FILTER_MIRROR_V
//      Indicates that pixels off the edge of the texture on the V-axis
//      should be mirrored, not wraped.
//  D3DX_FILTER_MIRROR_W
//      Indicates that pixels off the edge of the texture on the W-axis
//      should be mirrored, not wraped.
//  D3DX_FILTER_MIRROR
//      Same as specifying D3DX_FILTER_MIRROR_U | D3DX_FILTER_MIRROR_V |
//      D3DX_FILTER_MIRROR_V
//  D3DX_FILTER_DITHER
//      Dithers the resulting image.
//
//----------------------------------------------------------------------------

const
  D3DX_FILTER_NONE      = (1 shl 0);
  D3DX_FILTER_POINT     = (2 shl 0);
  D3DX_FILTER_LINEAR    = (3 shl 0);
  D3DX_FILTER_TRIANGLE  = (4 shl 0);
  D3DX_FILTER_BOX       = (5 shl 0);

  D3DX_FILTER_MIRROR_U  = (1 shl 16);
  D3DX_FILTER_MIRROR_V  = (2 shl 16);
  D3DX_FILTER_MIRROR_W  = (4 shl 16);
  D3DX_FILTER_MIRROR    = (7 shl 16);
  D3DX_FILTER_DITHER    = (8 shl 16);


//----------------------------------------------------------------------------
// D3DX_NORMALMAP flags:
// ---------------------
// These flags are used to control how D3DXComputeNormalMap generates normal
// maps.  Any number of these flags may be OR'd together in any combination.
//
//  D3DX_NORMALMAP_MIRROR_U
//      Indicates that pixels off the edge of the texture on the U-axis
//      should be mirrored, not wraped.
//  D3DX_NORMALMAP_MIRROR_V
//      Indicates that pixels off the edge of the texture on the V-axis
//      should be mirrored, not wraped.
//  D3DX_NORMALMAP_MIRROR
//      Same as specifying D3DX_NORMALMAP_MIRROR_U | D3DX_NORMALMAP_MIRROR_V
//  D3DX_NORMALMAP_INVERTSIGN
//      Inverts the direction of each normal
//  D3DX_NORMALMAP_COMPUTE_OCCLUSION
//      Compute the per pixel Occlusion term and encodes it into the alpha.
//      An Alpha of 1 means that the pixel is not obscured in anyway, and
//      an alpha of 0 would mean that the pixel is completly obscured.
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------

const
  D3DX_NORMALMAP_MIRROR_U     = (1 shl 16);
  D3DX_NORMALMAP_MIRROR_V     = (2 shl 16);
  D3DX_NORMALMAP_MIRROR       = (3 shl 16);
  D3DX_NORMALMAP_INVERTSIGN   = (8 shl 16);
  D3DX_NORMALMAP_COMPUTE_OCCLUSION = (16 shl 16);


//----------------------------------------------------------------------------
// D3DX_CHANNEL flags:
// -------------------
// These flags are used by functions which operate on or more channels
// in a texture.
//
// D3DX_CHANNEL_RED
//     Indicates the red channel should be used
// D3DX_CHANNEL_BLUE
//     Indicates the blue channel should be used
// D3DX_CHANNEL_GREEN
//     Indicates the green channel should be used
// D3DX_CHANNEL_ALPHA
//     Indicates the alpha channel should be used
// D3DX_CHANNEL_LUMINANCE
//     Indicates the luminaces of the red green and blue channels should be
//     used.
//
//----------------------------------------------------------------------------

const
  D3DX_CHANNEL_RED            = (1 shl 0);
  D3DX_CHANNEL_BLUE           = (1 shl 1);
  D3DX_CHANNEL_GREEN          = (1 shl 2);
  D3DX_CHANNEL_ALPHA          = (1 shl 3);
  D3DX_CHANNEL_LUMINANCE      = (1 shl 4);


//----------------------------------------------------------------------------
// D3DXIMAGE_FILEFORMAT:
// ---------------------
// This enum is used to describe supported image file formats.
//
//----------------------------------------------------------------------------

type
  PD3DXImageFileFormat = ^TD3DXImageFileFormat;
  _D3DXIMAGE_FILEFORMAT = (
    D3DXIFF_BMP        {= 0},
    D3DXIFF_JPG        {= 1},
    D3DXIFF_TGA        {= 2},
    D3DXIFF_PNG        {= 3},
    D3DXIFF_DDS        {= 4},
    D3DXIFF_PPM        {= 5},
    D3DXIFF_DIB        {= 6}
  );
  D3DXIMAGE_FILEFORMAT = _D3DXIMAGE_FILEFORMAT;
  TD3DXImageFileFormat = _D3DXIMAGE_FILEFORMAT;


//----------------------------------------------------------------------------
// LPD3DXFILL2D and LPD3DXFILL3D:
// ------------------------------
// Function types used by the texture fill functions.
//
// Parameters:
//  pOut
//      Pointer to a vector which the function uses to return its result.
//      X,Y,Z,W will be mapped to R,G,B,A respectivly.
//  pTexCoord
//      Pointer to a vector containing the coordinates of the texel currently
//      being evaluated.  Textures and VolumeTexture texcoord components
//      range from 0 to 1. CubeTexture texcoord component range from -1 to 1.
//  pTexelSize
//      Pointer to a vector containing the dimensions of the current texel.
//  pData
//      Pointer to user data.
//
//----------------------------------------------------------------------------

type
  // typedef VOID (*LPD3DXFILL2D)(D3DXVECTOR4 *pOut, D3DXVECTOR2 *pTexCoord, D3DXVECTOR2 *pTexelSize, LPVOID pData);
  LPD3DXFILL2D = procedure (out pOut: TD3DXVector4; const pTexCoord, pTexelSize: TD3DXVector2; var pData); cdecl;
  TD3DXFill2D = LPD3DXFILL2D;
  // typedef VOID (*LPD3DXFILL3D)(D3DXVECTOR4 *pOut, D3DXVECTOR3 *pTexCoord, D3DXVECTOR3 *pTexelSize, LPVOID pData);
  LPD3DXFILL3D = procedure (out pOut: TD3DXVector4; const pTexCoord, pTexelSize: TD3DXVector3; var pData); cdecl;
  TD3DXFill3D = LPD3DXFILL3D;


//----------------------------------------------------------------------------
// D3DXIMAGE_INFO:
// ---------------
// This structure is used to return a rough description of what the
// the original contents of an image file looked like.
//
//  Width
//      Width of original image in pixels
//  Height
//      Height of original image in pixels
//  Depth
//      Depth of original image in pixels
//  MipLevels
//      Number of mip levels in original image
//  Format
//      D3D format which most closely describes the data in original image
//  ResourceType
//      D3DRESOURCETYPE representing the type of texture stored in the file.
//      D3DRTYPE_TEXTURE, D3DRTYPE_VOLUMETEXTURE, or D3DRTYPE_CUBETEXTURE.
//  ImageFileFormat
//      D3DXIMAGE_FILEFORMAT representing the format of the image file.
//
//----------------------------------------------------------------------------

type
  PD3DXImageInfo = ^TD3DXImageInfo;
  _D3DXIMAGE_INFO = packed record
    Width:      LongWord;
    Height:     LongWord;
    Depth:      LongWord;
    MipLevels:  LongWord;
    Format:     TD3DFormat;
    ResourceType: TD3DResourceType;
    ImageFileFormat: TD3DXImageFileFormat;
  end;
  D3DXIMAGE_INFO = _D3DXIMAGE_INFO;
  TD3DXImageInfo = _D3DXIMAGE_INFO;


//////////////////////////////////////////////////////////////////////////////
// Image File APIs ///////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// GetImageInfoFromFile/Resource:
// ------------------------------
// Fills in a D3DXIMAGE_INFO struct with information about an image file.
//
// Parameters:
//  pSrcFile
//      File name of the source image.
//  pSrcModule
//      Module where resource is located, or NULL for module associated
//      with image the os used to create the current process.
//  pSrcResource
//      Resource name
//  pSrcData
//      Pointer to file in memory.
//  SrcDataSize
//      Size in bytes of file in memory.
//  pSrcInfo
//      Pointer to a D3DXIMAGE_INFO structure to be filled in with the
//      description of the data in the source image file.
//
//----------------------------------------------------------------------------

(*


function D3DXGetImageInfoFromFileA(
  pSrcFile: PAnsiChar;
  out pSrcInfo: TD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXGetImageInfoFromFileA';
*)
var D3DXGetImageInfoFromFileA : function( pSrcFile : PAnsiChar ; out pSrcInfo : TD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXGetImageInfoFromFileW(
  pSrcFile: PWideChar;
  out pSrcInfo: TD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXGetImageInfoFromFileW';
*)
var D3DXGetImageInfoFromFileW : function( pSrcFile : PWideChar ; out pSrcInfo : TD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXGetImageInfoFromFile(
  pSrcFile: PChar;
  out pSrcInfo: TD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXGetImageInfoFromFileA';
*)
var D3DXGetImageInfoFromFile : function( pSrcFile : PChar ; out pSrcInfo : TD3DXImageInfo ) : HResult ; stdcall ;

(*



function D3DXGetImageInfoFromResourceA(
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  out pSrcInfo: TD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXGetImageInfoFromResourceA';
*)
var D3DXGetImageInfoFromResourceA : function( hSrcModule : HModule ; pSrcResource : PAnsiChar ; out pSrcInfo : TD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXGetImageInfoFromResourceW(
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  out pSrcInfo: TD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXGetImageInfoFromResourceW';
*)
var D3DXGetImageInfoFromResourceW : function( hSrcModule : HModule ; pSrcResource : PWideChar ; out pSrcInfo : TD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXGetImageInfoFromResource(
  hSrcModule: HModule;
  pSrcResource: PChar;
  out pSrcInfo: TD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXGetImageInfoFromResourceA';
*)
var D3DXGetImageInfoFromResource : function( hSrcModule : HModule ; pSrcResource : PChar ; out pSrcInfo : TD3DXImageInfo ) : HResult ; stdcall ;

(*



function D3DXGetImageInfoFromFileInMemory(
  const pSrcData;
  SrcDataSize: LongWord;
  out pSrcInfo: TD3DXImageInfo): HResult; stdcall; external d3dx8dll;
*)
var D3DXGetImageInfoFromFileInMemory : function( const pSrcData ; SrcDataSize : LongWord ; out pSrcInfo : TD3DXImageInfo ) : HResult ; stdcall ;



//////////////////////////////////////////////////////////////////////////////
// Load/Save Surface APIs ////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


//----------------------------------------------------------------------------
// D3DXLoadSurfaceFromFile/Resource:
// ---------------------------------
// Load surface from a file or resource
//
// Parameters:
//  pDestSurface
//      Destination surface, which will receive the image.
//  pDestPalette
//      Destination palette of 256 colors, or NULL
//  pDestRect
//      Destination rectangle, or NULL for entire surface
//  pSrcFile
//      File name of the source image.
//  pSrcModule
//      Module where resource is located, or NULL for module associated
//      with image the os used to create the current process.
//  pSrcResource
//      Resource name
//  pSrcData
//      Pointer to file in memory.
//  SrcDataSize
//      Size in bytes of file in memory.
//  pSrcRect
//      Source rectangle, or NULL for entire image
//  Filter
//      D3DX_FILTER flags controlling how the image is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_TRIANGLE.
//  ColorKey
//      Color to replace with transparent black, or 0 to disable colorkey.
//      This is always a 32-bit ARGB color, independent of the source image
//      format.  Alpha is significant, and should usually be set to FF for
//      opaque colorkeys.  (ex. Opaque black == 0xff000000)
//  pSrcInfo
//      Pointer to a D3DXIMAGE_INFO structure to be filled in with the
//      description of the data in the source image file, or NULL.
//
//----------------------------------------------------------------------------

(*

function D3DXLoadSurfaceFromFileA(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  pSrcFile: PAnsiChar;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadSurfaceFromFileA';
*)
var D3DXLoadSurfaceFromFileA : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; pSrcFile : PAnsiChar ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadSurfaceFromFileW(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  pSrcFile: PWideChar;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadSurfaceFromFileW';
*)
var D3DXLoadSurfaceFromFileW : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; pSrcFile : PWideChar ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadSurfaceFromFile(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  pSrcFile: PChar;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadSurfaceFromFileA';
*)
var D3DXLoadSurfaceFromFile : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; pSrcFile : PChar ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*




function D3DXLoadSurfaceFromResourceA(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadSurfaceFromResourceA';
*)
var D3DXLoadSurfaceFromResourceA : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadSurfaceFromResourceW(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadSurfaceFromResourceW';
*)
var D3DXLoadSurfaceFromResourceW : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; hSrcModule : HModule ; pSrcResource : PWideChar ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadSurfaceFromResource(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  hSrcModule: HModule;
  pSrcResource: PChar;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadSurfaceFromResourceA';
*)
var D3DXLoadSurfaceFromResource : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; hSrcModule : HModule ; pSrcResource : PChar ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*




function D3DXLoadSurfaceFromFileInMemory(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  const pSrcData;
  SrcDataSize: LongWord;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadSurfaceFromFileInMemory : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; const pSrcData ; SrcDataSize : LongWord ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXLoadSurfaceFromSurface:
// ---------------------------
// Load surface from another surface (with color conversion)
//
// Parameters:
//  pDestSurface
//      Destination surface, which will receive the image.
//  pDestPalette
//      Destination palette of 256 colors, or NULL
//  pDestRect
//      Destination rectangle, or NULL for entire surface
//  pSrcSurface
//      Source surface
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//  pSrcRect
//      Source rectangle, or NULL for entire surface
//  Filter
//      D3DX_FILTER flags controlling how the image is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_TRIANGLE.
//  ColorKey
//      Color to replace with transparent black, or 0 to disable colorkey.
//      This is always a 32-bit ARGB color, independent of the source image
//      format.  Alpha is significant, and should usually be set to FF for
//      opaque colorkeys.  (ex. Opaque black == 0xff000000)
//
//----------------------------------------------------------------------------

(*


function D3DXLoadSurfaceFromSurface(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  pSrcSurface: IDirect3DSurface8;
  pSrcPalette: PPaletteEntry;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadSurfaceFromSurface : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; pSrcSurface : IDirect3DSurface8 ; pSrcPalette : PPaletteEntry ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXLoadSurfaceFromMemory:
// ---------------------------
// Load surface from memory.
//
// Parameters:
//  pDestSurface
//      Destination surface, which will receive the image.
//  pDestPalette
//      Destination palette of 256 colors, or NULL
//  pDestRect
//      Destination rectangle, or NULL for entire surface
//  pSrcMemory
//      Pointer to the top-left corner of the source image in memory
//  SrcFormat
//      Pixel format of the source image.
//  SrcPitch
//      Pitch of source image, in bytes.  For DXT formats, this number
//      should represent the width of one row of cells, in bytes.
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//  pSrcRect
//      Source rectangle.
//  Filter
//      D3DX_FILTER flags controlling how the image is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_TRIANGLE.
//  ColorKey
//      Color to replace with transparent black, or 0 to disable colorkey.
//      This is always a 32-bit ARGB color, independent of the source image
//      format.  Alpha is significant, and should usually be set to FF for
//      opaque colorkeys.  (ex. Opaque black == 0xff000000)
//
//----------------------------------------------------------------------------

(*


function D3DXLoadSurfaceFromMemory(
  pDestSurface: IDirect3DSurface8;
  pDestPalette: PPaletteEntry;
  pDestRect: PRect;
  const pSrcMemory;
  SrcFormat: TD3DFormat;
  SrcPitch: LongWord;
  pSrcPalette: PPaletteEntry;
  pSrcRect: PRect;
  Filter: DWord;
  ColorKey: TD3DColor): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadSurfaceFromMemory : function( pDestSurface : IDirect3DSurface8 ; pDestPalette : PPaletteEntry ; pDestRect : PRect ; const pSrcMemory ; SrcFormat : TD3DFormat ; SrcPitch : LongWord ; pSrcPalette : PPaletteEntry ; pSrcRect : PRect ; Filter : DWord ; ColorKey : TD3DColor ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXSaveSurfaceToFile:
// ----------------------
// Save a surface to a image file.
//
// Parameters:
//  pDestFile
//      File name of the destination file
//  DestFormat
//      D3DXIMAGE_FILEFORMAT specifying file format to use when saving.
//  pSrcSurface
//      Source surface, containing the image to be saved
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//  pSrcRect
//      Source rectangle, or NULL for the entire image
//
//----------------------------------------------------------------------------

(*


function D3DXSaveSurfaceToFileA(
  pDestFile: PAnsiChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcSurface: IDirect3DSurface8;
  pSrcPalette: PPaletteEntry;
  pSrcRect: PRect): HResult; stdcall; external d3dx8dll name 'D3DXSaveSurfaceToFileA';
*)
var D3DXSaveSurfaceToFileA : function( pDestFile : PAnsiChar ; DestFormat : TD3DXImageFileFormat ; pSrcSurface : IDirect3DSurface8 ; pSrcPalette : PPaletteEntry ; pSrcRect : PRect ) : HResult ; stdcall ;

(*


function D3DXSaveSurfaceToFileW(
  pDestFile: PWideChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcSurface: IDirect3DSurface8;
  pSrcPalette: PPaletteEntry;
  pSrcRect: PRect): HResult; stdcall; external d3dx8dll name 'D3DXSaveSurfaceToFileW';
*)
var D3DXSaveSurfaceToFileW : function( pDestFile : PWideChar ; DestFormat : TD3DXImageFileFormat ; pSrcSurface : IDirect3DSurface8 ; pSrcPalette : PPaletteEntry ; pSrcRect : PRect ) : HResult ; stdcall ;

(*


function D3DXSaveSurfaceToFile(
  pDestFile: PChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcSurface: IDirect3DSurface8;
  pSrcPalette: PPaletteEntry;
  pSrcRect: PRect): HResult; stdcall; external d3dx8dll name 'D3DXSaveSurfaceToFileA';
*)
var D3DXSaveSurfaceToFile : function( pDestFile : PChar ; DestFormat : TD3DXImageFileFormat ; pSrcSurface : IDirect3DSurface8 ; pSrcPalette : PPaletteEntry ; pSrcRect : PRect ) : HResult ; stdcall ;




//////////////////////////////////////////////////////////////////////////////
// Load/Save Volume APIs /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


//----------------------------------------------------------------------------
// D3DXLoadVolumeFromFile/Resource:
// --------------------------------
// Load volume from a file or resource
//
// Parameters:
//  pDestVolume
//      Destination volume, which will receive the image.
//  pDestPalette
//      Destination palette of 256 colors, or NULL
//  pDestBox
//      Destination box, or NULL for entire volume
//  pSrcFile
//      File name of the source image.
//  pSrcModule
//      Module where resource is located, or NULL for module associated
//      with image the os used to create the current process.
//  pSrcResource
//      Resource name
//  pSrcData
//      Pointer to file in memory.
//  SrcDataSize
//      Size in bytes of file in memory.
//  pSrcBox
//      Source box, or NULL for entire image
//  Filter
//      D3DX_FILTER flags controlling how the image is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_TRIANGLE.
//  ColorKey
//      Color to replace with transparent black, or 0 to disable colorkey.
//      This is always a 32-bit ARGB color, independent of the source image
//      format.  Alpha is significant, and should usually be set to FF for
//      opaque colorkeys.  (ex. Opaque black == 0xff000000)
//  pSrcInfo
//      Pointer to a D3DXIMAGE_INFO structure to be filled in with the
//      description of the data in the source image file, or NULL.
//
//----------------------------------------------------------------------------

(*


function D3DXLoadVolumeFromFileA(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  pSrcFile: PAnsiChar;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadVolumeFromFileA';
*)
var D3DXLoadVolumeFromFileA : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; pSrcFile : PAnsiChar ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadVolumeFromFileW(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  pSrcFile: PWideChar;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadVolumeFromFileW';
*)
var D3DXLoadVolumeFromFileW : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; pSrcFile : PWideChar ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadVolumeFromFile(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  pSrcFile: PChar;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadVolumeFromFileA';
*)
var D3DXLoadVolumeFromFile : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; pSrcFile : PChar ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*



function D3DXLoadVolumeFromResourceA(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadVolumeFromResourceA';
*)
var D3DXLoadVolumeFromResourceA : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadVolumeFromResourceW(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadVolumeFromResourceW';
*)
var D3DXLoadVolumeFromResourceW : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; hSrcModule : HModule ; pSrcResource : PWideChar ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*


function D3DXLoadVolumeFromResource(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  hSrcModule: HModule;
  pSrcResource: PChar;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll name 'D3DXLoadVolumeFromResourceA';
*)
var D3DXLoadVolumeFromResource : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; hSrcModule : HModule ; pSrcResource : PChar ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;

(*



function D3DXLoadVolumeFromFileInMemory(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  const pSrcData;
  SrcDataSize: LongWord;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadVolumeFromFileInMemory : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; const pSrcData ; SrcDataSize : LongWord ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXLoadVolumeFromVolume:
// ---------------------------
// Load volume from another volume (with color conversion)
//
// Parameters:
//  pDestVolume
//      Destination volume, which will receive the image.
//  pDestPalette
//      Destination palette of 256 colors, or NULL
//  pDestBox
//      Destination box, or NULL for entire volume
//  pSrcVolume
//      Source volume
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//  pSrcBox
//      Source box, or NULL for entire volume
//  Filter
//      D3DX_FILTER flags controlling how the image is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_TRIANGLE.
//  ColorKey
//      Color to replace with transparent black, or 0 to disable colorkey.
//      This is always a 32-bit ARGB color, independent of the source image
//      format.  Alpha is significant, and should usually be set to FF for
//      opaque colorkeys.  (ex. Opaque black == 0xff000000)
//
//----------------------------------------------------------------------------

(*


function D3DXLoadVolumeFromVolume(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  pSrcVolume: IDirect3DVolume8;
  pSrcPalette: PPaletteEntry;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadVolumeFromVolume : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; pSrcVolume : IDirect3DVolume8 ; pSrcPalette : PPaletteEntry ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXLoadVolumeFromMemory:
// ---------------------------
// Load volume from memory.
//
// Parameters:
//  pDestVolume
//      Destination volume, which will receive the image.
//  pDestPalette
//      Destination palette of 256 colors, or NULL
//  pDestBox
//      Destination box, or NULL for entire volume
//  pSrcMemory
//      Pointer to the top-left corner of the source volume in memory
//  SrcFormat
//      Pixel format of the source volume.
//  SrcRowPitch
//      Pitch of source image, in bytes.  For DXT formats, this number
//      should represent the size of one row of cells, in bytes.
//  SrcSlicePitch
//      Pitch of source image, in bytes.  For DXT formats, this number
//      should represent the size of one slice of cells, in bytes.
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//  pSrcBox
//      Source box.
//  Filter
//      D3DX_FILTER flags controlling how the image is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_TRIANGLE.
//  ColorKey
//      Color to replace with transparent black, or 0 to disable colorkey.
//      This is always a 32-bit ARGB color, independent of the source image
//      format.  Alpha is significant, and should usually be set to FF for
//      opaque colorkeys.  (ex. Opaque black == 0xff000000)
//
//----------------------------------------------------------------------------

(*


function D3DXLoadVolumeFromMemory(
  pDestVolume: IDirect3DVolume8;
  pDestPalette: PPaletteEntry;
  pDestBox: TD3DBox;
  const pSrcMemory;
  SrcFormat: TD3DFormat;
  SrcRowPitch: LongWord;
  SrcSlicePitch: LongWord;
  pSrcPalette: PPaletteEntry;
  pSrcBox: TD3DBox;
  Filter: DWord;
  ColorKey: TD3DColor): HResult; stdcall; external d3dx8dll;
*)
var D3DXLoadVolumeFromMemory : function( pDestVolume : IDirect3DVolume8 ; pDestPalette : PPaletteEntry ; pDestBox : TD3DBox ; const pSrcMemory ; SrcFormat : TD3DFormat ; SrcRowPitch : LongWord ; SrcSlicePitch : LongWord ; pSrcPalette : PPaletteEntry ; pSrcBox : TD3DBox ; Filter : DWord ; ColorKey : TD3DColor ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXSaveVolumeToFile:
// ---------------------
// Save a volume to a image file.
//
// Parameters:
//  pDestFile
//      File name of the destination file
//  DestFormat
//      D3DXIMAGE_FILEFORMAT specifying file format to use when saving.
//  pSrcVolume
//      Source volume, containing the image to be saved
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//  pSrcBox
//      Source box, or NULL for the entire volume
//
//----------------------------------------------------------------------------

(*


function D3DXSaveVolumeToFileA(
  pDestFile: PAnsiChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcVolume: IDirect3DVolume8;
  pSrcPalette: PPaletteEntry;
  pSrcBox: TD3DBox): HResult; stdcall; external d3dx8dll name 'D3DXSaveVolumeToFileA';
*)
var D3DXSaveVolumeToFileA : function( pDestFile : PAnsiChar ; DestFormat : TD3DXImageFileFormat ; pSrcVolume : IDirect3DVolume8 ; pSrcPalette : PPaletteEntry ; pSrcBox : TD3DBox ) : HResult ; stdcall ;

(*


function D3DXSaveVolumeToFileW(
  pDestFile: PWideChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcVolume: IDirect3DVolume8;
  pSrcPalette: PPaletteEntry;
  pSrcBox: TD3DBox): HResult; stdcall; external d3dx8dll name 'D3DXSaveVolumeToFileW';
*)
var D3DXSaveVolumeToFileW : function( pDestFile : PWideChar ; DestFormat : TD3DXImageFileFormat ; pSrcVolume : IDirect3DVolume8 ; pSrcPalette : PPaletteEntry ; pSrcBox : TD3DBox ) : HResult ; stdcall ;

(*


function D3DXSaveVolumeToFile(
  pDestFile: PChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcVolume: IDirect3DVolume8;
  pSrcPalette: PPaletteEntry;
  pSrcBox: TD3DBox): HResult; stdcall; external d3dx8dll name 'D3DXSaveVolumeToFileA';
*)
var D3DXSaveVolumeToFile : function( pDestFile : PChar ; DestFormat : TD3DXImageFileFormat ; pSrcVolume : IDirect3DVolume8 ; pSrcPalette : PPaletteEntry ; pSrcBox : TD3DBox ) : HResult ; stdcall ;




//////////////////////////////////////////////////////////////////////////////
// Create/Save Texture APIs //////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


//----------------------------------------------------------------------------
// D3DXCheckTextureRequirements:
// -----------------------------
// Checks texture creation parameters.  If parameters are invalid, this
// function returns corrected parameters.
//
// Parameters:
//
//  pDevice
//      The D3D device to be used
//  pWidth, pHeight, pDepth, pSize
//      Desired size in pixels, or NULL.  Returns corrected size.
//  pNumMipLevels
//      Number of desired mipmap levels, or NULL.  Returns corrected number.
//  Usage
//      Texture usage flags
//  pFormat
//      Desired pixel format, or NULL.  Returns corrected format.
//  Pool
//      Memory pool to be used to create texture
//
//----------------------------------------------------------------------------

(*

function D3DXCheckTextureRequirements(
  pDevice: IDirect3DDevice8;
  pWidth: PLongWord;
  pHeight: PLongWord;
  pNumMipLevels: PLongWord;
  Usage: DWord;
  pFormat: PD3DFormat;
  Pool: TD3DPool): HResult; stdcall; external d3dx8dll;
*)
var D3DXCheckTextureRequirements : function( pDevice : IDirect3DDevice8 ; pWidth : PLongWord ; pHeight : PLongWord ; pNumMipLevels : PLongWord ; Usage : DWord ; pFormat : PD3DFormat ; Pool : TD3DPool ) : HResult ; stdcall ;

(*


function D3DXCheckCubeTextureRequirements(
  pDevice: IDirect3DDevice8;
  pSize: PLongWord;
  pNumMipLevels: PLongWord;
  Usage: DWord;
  pFormat: PD3DFormat;
  Pool: TD3DPool): HResult; stdcall; external d3dx8dll;
*)
var D3DXCheckCubeTextureRequirements : function( pDevice : IDirect3DDevice8 ; pSize : PLongWord ; pNumMipLevels : PLongWord ; Usage : DWord ; pFormat : PD3DFormat ; Pool : TD3DPool ) : HResult ; stdcall ;

(*


function D3DXCheckVolumeTextureRequirements(
  pDevice: IDirect3DDevice8;
  pWidth: PLongWord;
  pHeight: PLongWord;
  pDepth: PLongWord;
  pNumMipLevels: PLongWord;
  Usage: DWord;
  pFormat: PD3DFormat;
  Pool: TD3DPool): HResult; stdcall; external d3dx8dll;
*)
var D3DXCheckVolumeTextureRequirements : function( pDevice : IDirect3DDevice8 ; pWidth : PLongWord ; pHeight : PLongWord ; pDepth : PLongWord ; pNumMipLevels : PLongWord ; Usage : DWord ; pFormat : PD3DFormat ; Pool : TD3DPool ) : HResult ; stdcall ;



//----------------------------------------------------------------------------
// D3DXCreateTexture:
// ------------------
// Create an empty texture
//
// Parameters:
//
//  pDevice
//      The D3D device with which the texture is going to be used.
//  Width, Height, Depth, Size
//      size in pixels; these must be non-zero
//  MipLevels
//      number of mip levels desired; if zero or D3DX_DEFAULT, a complete
//      mipmap chain will be created.
//  Usage
//      Texture usage flags
//  Format
//      Pixel format.
//  Pool
//      Memory pool to be used to create texture
//  ppTexture, ppCubeTexture, ppVolumeTexture
//      The texture object that will be created
//
//----------------------------------------------------------------------------

(*


function D3DXCreateTexture(
  Device: IDirect3DDevice8;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateTexture : function( Device : IDirect3DDevice8 ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTexture(
  Device: IDirect3DDevice8;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateCubeTexture : function( Device : IDirect3DDevice8 ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTexture(
  Device: IDirect3DDevice8;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateVolumeTexture : function( Device : IDirect3DDevice8 ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXCreateTextureFromFile/Resource:
// -----------------------------------
// Create a texture object from a file or resource.
//
// Parameters:
//
//  pDevice
//      The D3D device with which the texture is going to be used.
//  pSrcFile
//      File name.
//  hSrcModule
//      Module handle. if NULL, current module will be used.
//  pSrcResource
//      Resource name in module
//  pvSrcData
//      Pointer to file in memory.
//  SrcDataSize
//      Size in bytes of file in memory.
//  Width, Height, Depth, Size
//      Size in pixels; if zero or D3DX_DEFAULT, the size will be taken
//      from the file.
//  MipLevels
//      Number of mip levels;  if zero or D3DX_DEFAULT, a complete mipmap
//      chain will be created.
//  Usage
//      Texture usage flags
//  Format
//      Desired pixel format.  If D3DFMT_UNKNOWN, the format will be
//      taken from the file.
//  Pool
//      Memory pool to be used to create texture
//  Filter
//      D3DX_FILTER flags controlling how the image is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_TRIANGLE.
//  MipFilter
//      D3DX_FILTER flags controlling how each miplevel is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_BOX,
//  ColorKey
//      Color to replace with transparent black, or 0 to disable colorkey.
//      This is always a 32-bit ARGB color, independent of the source image
//      format.  Alpha is significant, and should usually be set to FF for
//      opaque colorkeys.  (ex. Opaque black == 0xff000000)
//  pSrcInfo
//      Pointer to a D3DXIMAGE_INFO structure to be filled in with the
//      description of the data in the source image file, or NULL.
//  pPalette
//      256 color palette to be filled in, or NULL
//  ppTexture, ppCubeTexture, ppVolumeTexture
//      The texture object that will be created
//
//----------------------------------------------------------------------------


// FromFile

(*


function D3DXCreateTextureFromFileA(
  Device: IDirect3DDevice8;
  pSrcFile: PAnsiChar;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromFileA';
*)
var D3DXCreateTextureFromFileA : function( Device : IDirect3DDevice8 ; pSrcFile : PAnsiChar ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromFileW(
  Device: IDirect3DDevice8;
  pSrcFile: PWideChar;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromFileW';
*)
var D3DXCreateTextureFromFileW : function( Device : IDirect3DDevice8 ; pSrcFile : PWideChar ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromFile(
  Device: IDirect3DDevice8;
  pSrcFile: PChar;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromFileA';
*)
var D3DXCreateTextureFromFile : function( Device : IDirect3DDevice8 ; pSrcFile : PChar ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateCubeTextureFromFileA(
  Device: IDirect3DDevice8;
  pSrcFile: PAnsiChar;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromFileA';
*)
var D3DXCreateCubeTextureFromFileA : function( Device : IDirect3DDevice8 ; pSrcFile : PAnsiChar ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromFileW(
  Device: IDirect3DDevice8;
  pSrcFile: PWideChar;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromFileW';
*)
var D3DXCreateCubeTextureFromFileW : function( Device : IDirect3DDevice8 ; pSrcFile : PWideChar ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromFile(
  Device: IDirect3DDevice8;
  pSrcFile: PChar;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromFileA';
*)
var D3DXCreateCubeTextureFromFile : function( Device : IDirect3DDevice8 ; pSrcFile : PChar ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateVolumeTextureFromFileA(
  Device: IDirect3DDevice8;
  pSrcFile: PAnsiChar;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromFileA';
*)
var D3DXCreateVolumeTextureFromFileA : function( Device : IDirect3DDevice8 ; pSrcFile : PAnsiChar ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromFileW(
  Device: IDirect3DDevice8;
  pSrcFile: PWideChar;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromFileW';
*)
var D3DXCreateVolumeTextureFromFileW : function( Device : IDirect3DDevice8 ; pSrcFile : PWideChar ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromFile(
  Device: IDirect3DDevice8;
  pSrcFile: PChar;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromFileA';
*)
var D3DXCreateVolumeTextureFromFile : function( Device : IDirect3DDevice8 ; pSrcFile : PChar ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;



// FromResource

(*


function D3DXCreateTextureFromResourceA(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromResourceA';
*)
var D3DXCreateTextureFromResourceA : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromResourceW(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromResourceW';
*)
var D3DXCreateTextureFromResourceW : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PWideChar ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromResource(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PChar;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromResourceA';
*)
var D3DXCreateTextureFromResource : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PChar ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateCubeTextureFromResourceA(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromResourceA';
*)
var D3DXCreateCubeTextureFromResourceA : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromResourceW(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromResourceW';
*)
var D3DXCreateCubeTextureFromResourceW : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PWideChar ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromResource(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PChar;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromResourceA';
*)
var D3DXCreateCubeTextureFromResource : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PChar ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateVolumeTextureFromResourceA(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromResourceA';
*)
var D3DXCreateVolumeTextureFromResourceA : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromResourceW(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromResourceW';
*)
var D3DXCreateVolumeTextureFromResourceW : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PWideChar ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromResource(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PChar;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromResourceA';
*)
var D3DXCreateVolumeTextureFromResource : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PChar ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;



// FromFileEx

(*


function D3DXCreateTextureFromFileExA(
  Device: IDirect3DDevice8;
  pSrcFile: PAnsiChar;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromFileExA';
*)
var D3DXCreateTextureFromFileExA : function( Device : IDirect3DDevice8 ; pSrcFile : PAnsiChar ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromFileExW(
  Device: IDirect3DDevice8;
  pSrcFile: PWideChar;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromFileExW';
*)
var D3DXCreateTextureFromFileExW : function( Device : IDirect3DDevice8 ; pSrcFile : PWideChar ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromFileEx(
  Device: IDirect3DDevice8;
  pSrcFile: PChar;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromFileExA';
*)
var D3DXCreateTextureFromFileEx : function( Device : IDirect3DDevice8 ; pSrcFile : PChar ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateCubeTextureFromFileExA(
  Device: IDirect3DDevice8;
  pSrcFile: PAnsiChar;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromFileExA';
*)
var D3DXCreateCubeTextureFromFileExA : function( Device : IDirect3DDevice8 ; pSrcFile : PAnsiChar ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromFileExW(
  Device: IDirect3DDevice8;
  pSrcFile: PWideChar;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromFileExW';
*)
var D3DXCreateCubeTextureFromFileExW : function( Device : IDirect3DDevice8 ; pSrcFile : PWideChar ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromFileEx(
  Device: IDirect3DDevice8;
  pSrcFile: PChar;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromFileExA';
*)
var D3DXCreateCubeTextureFromFileEx : function( Device : IDirect3DDevice8 ; pSrcFile : PChar ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateVolumeTextureFromFileExA(
  Device: IDirect3DDevice8;
  pSrcFile: PAnsiChar;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromFileExA';
*)
var D3DXCreateVolumeTextureFromFileExA : function( Device : IDirect3DDevice8 ; pSrcFile : PAnsiChar ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromFileExW(
  Device: IDirect3DDevice8;
  pSrcFile: PWideChar;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromFileExW';
*)
var D3DXCreateVolumeTextureFromFileExW : function( Device : IDirect3DDevice8 ; pSrcFile : PWideChar ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromFileEx(
  Device: IDirect3DDevice8;
  pSrcFile: PChar;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromFileExA';
*)
var D3DXCreateVolumeTextureFromFileEx : function( Device : IDirect3DDevice8 ; pSrcFile : PChar ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;



// FromResourceEx

(*


function D3DXCreateTextureFromResourceExA(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromResourceExA';
*)
var D3DXCreateTextureFromResourceExA : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromResourceExW(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromResourceExW';
*)
var D3DXCreateTextureFromResourceExW : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PWideChar ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateTextureFromResourceEx(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PChar;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateTextureFromResourceExA';
*)
var D3DXCreateTextureFromResourceEx : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PChar ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateCubeTextureFromResourceExA(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromResourceExA';
*)
var D3DXCreateCubeTextureFromResourceExA : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromResourceExW(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromResourceExW';
*)
var D3DXCreateCubeTextureFromResourceExW : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PWideChar ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromResourceEx(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PChar;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateCubeTextureFromResourceExA';
*)
var D3DXCreateCubeTextureFromResourceEx : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PChar ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*



function D3DXCreateVolumeTextureFromResourceExA(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PAnsiChar;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromResourceExA';
*)
var D3DXCreateVolumeTextureFromResourceExA : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PAnsiChar ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromResourceExW(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PWideChar;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromResourceExW';
*)
var D3DXCreateVolumeTextureFromResourceExW : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PWideChar ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromResourceEx(
  Device: IDirect3DDevice8;
  hSrcModule: HModule;
  pSrcResource: PChar;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll name 'D3DXCreateVolumeTextureFromResourceExA';
*)
var D3DXCreateVolumeTextureFromResourceEx : function( Device : IDirect3DDevice8 ; hSrcModule : HModule ; pSrcResource : PChar ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;



// FromFileInMemory

(*


function D3DXCreateTextureFromFileInMemory(
  Device: IDirect3DDevice8;
  const pSrcData;
  SrcDataSize: LongWord;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateTextureFromFileInMemory : function( Device : IDirect3DDevice8 ; const pSrcData ; SrcDataSize : LongWord ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromFileInMemory(
  Device: IDirect3DDevice8;
  const pSrcData;
  SrcDataSize: LongWord;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateCubeTextureFromFileInMemory : function( Device : IDirect3DDevice8 ; const pSrcData ; SrcDataSize : LongWord ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromFileInMemory(
  Device: IDirect3DDevice8;
  const pSrcData;
  SrcDataSize: LongWord;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateVolumeTextureFromFileInMemory : function( Device : IDirect3DDevice8 ; const pSrcData ; SrcDataSize : LongWord ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;



// FromFileInMemoryEx

(*


function D3DXCreateTextureFromFileInMemoryEx(
  Device: IDirect3DDevice8;
  const pSrcData;
  SrcDataSize: LongWord;
  Width: LongWord;
  Height: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppTexture: IDirect3DTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateTextureFromFileInMemoryEx : function( Device : IDirect3DDevice8 ; const pSrcData ; SrcDataSize : LongWord ; Width : LongWord ; Height : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppTexture : IDirect3DTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateCubeTextureFromFileInMemoryEx(
  Device: IDirect3DDevice8;
  const pSrcData;
  SrcDataSize: LongWord;
  Size: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppCubeTexture: IDirect3DCubeTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateCubeTextureFromFileInMemoryEx : function( Device : IDirect3DDevice8 ; const pSrcData ; SrcDataSize : LongWord ; Size : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppCubeTexture : IDirect3DCubeTexture8 ) : HResult ; stdcall ;

(*


function D3DXCreateVolumeTextureFromFileInMemoryEx(
  Device: IDirect3DDevice8;
  const pSrcData;
  SrcDataSize: LongWord;
  Width: LongWord;
  Height: LongWord;
  Depth: LongWord;
  MipLevels: LongWord;
  Usage: DWord;
  Format: TD3DFormat;
  Pool: TD3DPool;
  Filter: DWord;
  MipFilter: DWord;
  ColorKey: TD3DColor;
  pSrcInfo: PD3DXImageInfo;
  pPalette: PPaletteEntry;
  out ppVolumeTexture: IDirect3DVolumeTexture8): HResult; stdcall; external d3dx8dll;
*)
var D3DXCreateVolumeTextureFromFileInMemoryEx : function( Device : IDirect3DDevice8 ; const pSrcData ; SrcDataSize : LongWord ; Width : LongWord ; Height : LongWord ; Depth : LongWord ; MipLevels : LongWord ; Usage : DWord ; Format : TD3DFormat ; Pool : TD3DPool ; Filter : DWord ; MipFilter : DWord ; ColorKey : TD3DColor ; pSrcInfo : PD3DXImageInfo ; pPalette : PPaletteEntry ; out ppVolumeTexture : IDirect3DVolumeTexture8 ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXSaveTextureToFile:
// ----------------------
// Save a texture to a file.
//
// Parameters:
//  pDestFile
//      File name of the destination file
//  DestFormat
//      D3DXIMAGE_FILEFORMAT specifying file format to use when saving.
//  pSrcTexture
//      Source texture, containing the image to be saved
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//
//----------------------------------------------------------------------------

(*



function D3DXSaveTextureToFileA(
  pDestFile: PAnsiChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcTexture: IDirect3DBaseTexture8;
  pSrcPalette: PPaletteEntry): HResult; stdcall; external d3dx8dll name 'D3DXSaveTextureToFileA';
*)
var D3DXSaveTextureToFileA : function( pDestFile : PAnsiChar ; DestFormat : TD3DXImageFileFormat ; pSrcTexture : IDirect3DBaseTexture8 ; pSrcPalette : PPaletteEntry ) : HResult ; stdcall ;

(*


function D3DXSaveTextureToFileW(
  pDestFile: PWideChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcTexture: IDirect3DBaseTexture8;
  pSrcPalette: PPaletteEntry): HResult; stdcall; external d3dx8dll name 'D3DXSaveTextureToFileW';
*)
var D3DXSaveTextureToFileW : function( pDestFile : PWideChar ; DestFormat : TD3DXImageFileFormat ; pSrcTexture : IDirect3DBaseTexture8 ; pSrcPalette : PPaletteEntry ) : HResult ; stdcall ;

(*


function D3DXSaveTextureToFile(
  pDestFile: PChar;
  DestFormat: TD3DXImageFileFormat;
  pSrcTexture: IDirect3DBaseTexture8;
  pSrcPalette: PPaletteEntry): HResult; stdcall; external d3dx8dll name 'D3DXSaveTextureToFileA';
*)
var D3DXSaveTextureToFile : function( pDestFile : PChar ; DestFormat : TD3DXImageFileFormat ; pSrcTexture : IDirect3DBaseTexture8 ; pSrcPalette : PPaletteEntry ) : HResult ; stdcall ;





//////////////////////////////////////////////////////////////////////////////
// Misc Texture APIs /////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// D3DXFilterTexture:
// ------------------
// Filters mipmaps levels of a texture.
//
// Parameters:
//  pBaseTexture
//      The texture object to be filtered
//  pPalette
//      256 color palette to be used, or NULL for non-palettized formats
//  SrcLevel
//      The level whose image is used to generate the subsequent levels.
//  Filter
//      D3DX_FILTER flags controlling how each miplevel is filtered.
//      Or D3DX_DEFAULT for D3DX_FILTER_BOX,
//
//-------------------------------------------------------------------------

(*


function D3DXFilterTexture(
  pTexture: IDirect3DTexture8;
  pPalette: PPaletteEntry;
  SrcLevel: LongWord;
  Filter: DWord): HResult; stdcall; external d3dx8dll;
*)
var D3DXFilterTexture : function( pTexture : IDirect3DTexture8 ; pPalette : PPaletteEntry ; SrcLevel : LongWord ; Filter : DWord ) : HResult ; stdcall ;


// #define D3DXFilterCubeTexture D3DXFilterTexture
// In Pascal this mapped to DLL-exported "D3DXFilterTexture" function

(*

function D3DXFilterCubeTexture(
  pTexture: IDirect3DCubeTexture8;
  pPalette: PPaletteEntry;
  SrcLevel: LongWord;
  Filter: DWord): HResult; stdcall; external d3dx8dll name 'D3DXFilterTexture';
*)
var D3DXFilterCubeTexture : function( pTexture : IDirect3DCubeTexture8 ; pPalette : PPaletteEntry ; SrcLevel : LongWord ; Filter : DWord ) : HResult ; stdcall ;


// #define D3DXFilterVolumeTexture D3DXFilterTexture
// In Pascal this mapped to DLL-exported "D3DXFilterTexture" function

(*

function D3DXFilterVolumeTexture(
  pTexture: IDirect3DVolumeTexture8;
  pPalette: PPaletteEntry;
  SrcLevel: LongWord;
  Filter: DWord): HResult; stdcall; external d3dx8dll name 'D3DXFilterTexture';
*)
var D3DXFilterVolumeTexture : function( pTexture : IDirect3DVolumeTexture8 ; pPalette : PPaletteEntry ; SrcLevel : LongWord ; Filter : DWord ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXFillTexture:
// ----------------
// Uses a user provided function to fill each texel of each mip level of a
// given texture.
//
// Paramters:
//  pTexture, pCubeTexture, pVolumeTexture
//      Pointer to the texture to be filled.
//  pFunction
//      Pointer to user provided evalutor function which will be used to
//      compute the value of each texel.
//  pData
//      Pointer to an arbitrary block of user defined data.  This pointer
//      will be passed to the function provided in pFunction
//-----------------------------------------------------------------------------

(*


function D3DXFillTexture(
  pTexture: IDirect3DTexture8;
  pFunction: TD3DXFill2D;
  pData: Pointer): HResult; stdcall; external d3dx8dll;
*)
var D3DXFillTexture : function( pTexture : IDirect3DTexture8 ; pFunction : TD3DXFill2D ; pData : Pointer ) : HResult ; stdcall ;

(*


function D3DXFillCubeTexture(
  pCubeTexture: IDirect3DCubeTexture8;
  pFunction: TD3DXFill2D;
  pData: Pointer): HResult; stdcall; external d3dx8dll;
*)
var D3DXFillCubeTexture : function( pCubeTexture : IDirect3DCubeTexture8 ; pFunction : TD3DXFill2D ; pData : Pointer ) : HResult ; stdcall ;

(*


function D3DXFillVolumeTexture(
  pVolumeTexture: IDirect3DVolumeTexture8;
  pFunction: TD3DXFill3D;
  pData: Pointer): HResult; stdcall; external d3dx8dll;
*)
var D3DXFillVolumeTexture : function( pVolumeTexture : IDirect3DVolumeTexture8 ; pFunction : TD3DXFill3D ; pData : Pointer ) : HResult ; stdcall ;




//----------------------------------------------------------------------------
// D3DXComputeNormalMap:
// ---------------------
// Converts a height map into a normal map.  The (x,y,z) components of each
// normal are mapped to the (r,g,b) channels of the output texture.
//
// Parameters
//  pTexture
//      Pointer to the destination texture
//  pSrcTexture
//      Pointer to the source heightmap texture
//  pSrcPalette
//      Source palette of 256 colors, or NULL
//  Flags
//      D3DX_NORMALMAP flags
//  Channel
//      D3DX_CHANNEL specifying source of height information
//  Amplitude
//      The constant value which the height information is multiplied by.
//---------------------------------------------------------------------------

(*


function D3DXComputeNormalMap(
  pTexture: IDirect3DTexture8;
  pSrcTexture: IDirect3DTexture8;
  pSrcPalette: PPaletteEntry;
  Flags: DWord;
  Channel: DWord;
  Amplitude: Single): HResult; stdcall; external d3dx8dll;
*)
var D3DXComputeNormalMap : function( pTexture : IDirect3DTexture8 ; pSrcTexture : IDirect3DTexture8 ; pSrcPalette : PPaletteEntry ; Flags : DWord ; Channel : DWord ; Amplitude : Single ) : HResult ; stdcall ;




//********************************************************************
// Introduced types for compatibility with "REVISED" D3DX8.pas translation
// by Ampaze (Tim Baumgarten) from www.Delphi-Jedi.org/DelphiGraphics
type
  PD3DXEffect_Desc      = PD3DXEffectDesc;
  PD3DXImage_Info       = PD3DXImageInfo;
  PD3DXParameter_Desc   = PD3DXParameterDesc;
  PD3DXPass_Desc        = PD3DXPassDesc;
  PD3DXRTE_Desc         = PD3DXRTEDesc;
  PD3DXRTS_Desc         = PD3DXRTSDesc;
  PD3DXTechnique_Desc   = PD3DXTechniqueDesc;

  TD3DXEffect_Desc      = TD3DXEffectDesc;
  TD3DXImage_Info       = TD3DXImageInfo;
  TD3DXParameter_Desc   = TD3DXParameterDesc;
  TD3DXPass_Desc        = TD3DXPassDesc;
  TD3DXRTE_Desc         = TD3DXRTEDesc;
  TD3DXRTS_Desc         = TD3DXRTSDesc;
  TD3DXTechnique_Desc   = TD3DXTechniqueDesc;

  PD3DXImage_FileFormat = PD3DXImageFileFormat;
  TD3DXImage_FileFormat = TD3DXImageFileFormat;

//***************************************************************************//
//***************************************************************************//
//***************************************************************************//
implementation
//***************************************************************************//
//***************************************************************************//
//***************************************************************************//

uses
	 SmoothBase
	,SmoothLists
	,SmoothDllManager
	,SmoothStringUtils
	,SmoothSysUtils
	;

//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8math.h
//  Content:    D3DX math types and functions
//
//////////////////////////////////////////////////////////////////////////////



//===========================================================================
//
// General purpose utilities
//
//===========================================================================


function D3DXToRadian(Degree: Single): Single;
begin
  Result:= Degree * (D3DX_PI / 180.0);
end;

function D3DXToDegree(Radian: Single): Single;
begin
  Result:= Radian * (180.0 / D3DX_PI);
end;


//--------------------------
// 2D Vector
//--------------------------

function D3DXVector2(_x, _y: Single): TD3DXVector2;
begin
  Result.x:= _x; Result.y:= _y;
end;

function D3DXVector2Equal(const v1, v2: TD3DXVector2): Boolean;
begin
  Result:= (v1.x = v2.x) and (v1.y = v2.y);
end;


//--------------------------
// 3D Vector
//--------------------------
function D3DXVector3(_x, _y, _z: Single): TD3DXVector3;
begin
  Result.x:= _x; Result.y:= _y; Result.z:=_z;
end;

function D3DXVector3Equal(const v1, v2: TD3DXVector3): Boolean;
begin
  Result:= (v1.x = v2.x) and (v1.y = v2.y) and (v1.z = v2.z);
end;


//--------------------------
// 4D Vector
//--------------------------

function D3DXVector4(_x, _y, _z, _w: Single): TD3DXVector4;
begin
  with Result do
  begin
    x:= _x; y:= _y; z:= _z; w:= _w;
  end;
end;

function D3DXVector4Equal(const v1, v2: TD3DXVector4): Boolean;
begin
  Result:= (v1.x = v2.x) and (v1.y = v2.y) and
    (v1.z = v2.z) and (v1.w = v2.w);
end;


//--------------------------
// 4D Matrix
//--------------------------
function D3DXMatrix(
  _m00, _m01, _m02, _m03,
  _m10, _m11, _m12, _m13,
  _m20, _m21, _m22, _m23,
  _m30, _m31, _m32, _m33: Single): TD3DXMatrix;
begin
  with Result do
  begin
    m[0,0]:= _m00; m[0,1]:= _m01; m[0,2]:= _m02; m[0,3]:= _m03;
    m[1,0]:= _m10; m[1,1]:= _m11; m[1,2]:= _m12; m[1,3]:= _m13;
    m[2,0]:= _m20; m[2,1]:= _m21; m[2,2]:= _m22; m[2,3]:= _m23;
    m[3,0]:= _m30; m[3,1]:= _m31; m[3,2]:= _m32; m[3,3]:= _m33;
  end;
end;

function D3DXMatrixAdd(out mOut: TD3DXMatrix; const m1, m2: TD3DXMatrix): PD3DXMatrix;
var
  pOut, p1, p2: PSingle; x: Integer;
begin
  pOut:= @mOut._11; p1:= @m1._11; p2:= @m2._11;
  for x:= 0 to 15 do
  begin
    pOut^:= p1^+p2^;
    Inc(pOut); Inc(p1); Inc(p2);
  end;
  Result:= @mOut;
end;

function D3DXMatrixSubtract(out mOut: TD3DXMatrix; const m1, m2: TD3DXMatrix): PD3DXMatrix;
var
  pOut, p1, p2: PSingle; x: Integer;
begin
  pOut:= @mOut._11; p1:= @m1._11; p2:= @m2._11;
  for x:= 0 to 15 do
  begin
    pOut^:= p1^-p2^;
    Inc(pOut); Inc(p1); Inc(p2);
  end;
  Result:= @mOut;
end;

function D3DXMatrixMul(out mOut: TD3DXMatrix; const m: TD3DXMatrix; MulBy: Single): PD3DXMatrix;
var
  pOut, p: PSingle; x: Integer;
begin
  pOut:= @mOut._11; p:= @m._11;
  for x:= 0 to 15 do
  begin
    pOut^:= p^* MulBy;
    Inc(pOut); Inc(p);
  end;
  Result:= @mOut;
end;

function D3DXMatrixEqual(const m1, m2: TD3DXMatrix): Boolean;
begin
  Result:= CompareMem(@m1, @m2, SizeOf(TD3DXMatrix));
end;

//--------------------------
// Quaternion
//--------------------------
function D3DXQuaternion(_x, _y, _z, _w: Single): TD3DXQuaternion;
begin
  with Result do
  begin
    x:= _x; y:= _y; z:= _z; w:= _w;
  end;
end;

function D3DXQuaternionAdd(const q1, q2: TD3DXQuaternion): TD3DXQuaternion;
begin
  with Result do
  begin
    x:= q1.x+q2.x; y:= q1.y+q2.y; z:= q1.z+q2.z; w:= q1.w+q2.w;
  end;
end;

function D3DXQuaternionSubtract(const q1, q2: TD3DXQuaternion): TD3DXQuaternion;
begin
  with Result do
  begin
    x:= q1.x-q2.x; y:= q1.y-q2.y; z:= q1.z-q2.z; w:= q1.w-q2.w;
  end;
end;

function D3DXQuaternionEqual(const q1, q2: TD3DXQuaternion): Boolean;
begin
  Result:= (q1.x = q2.x) and (q1.y = q2.y) and
    (q1.z = q2.z) and (q1.w = q2.w);
end;

function D3DXQuaternionScale(out qOut: TD3DXQuaternion; const q: TD3DXQuaternion;
  s: Single): PD3DXQuaternion;
begin
  with qOut do
  begin
    x:= q.x*s; y:= q.y*s; z:= q.z*s; w:= q.w*s;
  end;
  Result:= @qOut;
end;


//--------------------------
// Plane
//--------------------------

function D3DXPlane(_a, _b, _c, _d: Single): TD3DXPlane;
begin
  with Result do
  begin
    a:= _a; b:= _b; c:= _c; d:= _d;
  end;
end;

function D3DXPlaneEqual(const p1, p2: TD3DXPlane): Boolean;
begin
  Result:=
    (p1.a = p2.a) and (p1.b = p2.b) and
    (p1.c = p2.c) and (p1.d = p2.d);
end;


//--------------------------
// Color
//--------------------------

function D3DXColor(_r, _g, _b, _a: Single): TD3DXColor;
begin
  with Result do
  begin
    r:= _r; g:= _g; b:= _b; a:= _a;
  end;
end;

function D3DXColorToDWord(c: TD3DXColor): DWord;

  function ColorLimit(const x: Single): DWord;
  begin
    if x > 1.0 then Result:= 255
     else if x < 0 then Result:= 0
      else Result:= Trunc(x * 255.0 + 0.5);
  end;
begin
  Result:= ColorLimit(c.a) shl 24 or ColorLimit(c.r) shl 16
    or ColorLimit(c.g) shl 8 or ColorLimit(c.b);
end;

function D3DXColorFromDWord(c: DWord): TD3DXColor;
const
  f: Single = 1/255;
begin
  with Result do
  begin
    r:= f * Byte(c shr 16);
    g:= f * Byte(c shr  8);
    b:= f * Byte(c shr  0);
    a:= f * Byte(c shr 24);
  end;
end;

function D3DXColorEqual(const c1, c2: TD3DXColor): Boolean;
begin
  Result:= (c1.r = c2.r) and (c1.g = c2.g) and (c1.b = c2.b) and (c1.a = c2.a);
end;


//===========================================================================
//
// D3DX math functions:
//
// NOTE:
//  * All these functions can take the same object as in and out parameters.
//
//  * Out parameters are typically also returned as return values, so that
//    the output of one function may be used as a parameter to another.
//
//===========================================================================

//--------------------------
// 2D Vector
//--------------------------

// "inline"
function D3DXVec2Length(const v: TD3DXVector2): Single;
begin
  with v do Result:= Sqrt(x*x + y*y);
end;

function D3DXVec2LengthSq(const v: TD3DXVector2): Single;
begin
  with v do Result:= x*x + y*y;
end;

function D3DXVec2Dot(const v1, v2: TD3DXVector2): Single;
begin
  Result:= v1.x*v2.x + v1.y*v2.y;
end;

// Z component of ((x1,y1,0) cross (x2,y2,0))
function D3DXVec2CCW(const v1, v2: TD3DXVector2): Single;
begin
  Result:= v1.x*v2.y - v1.y*v2.x;
end;

function D3DXVec2Add(const v1, v2: TD3DXVector2): TD3DXVector2;
begin
  Result.x:= v1.x + v2.x;
  Result.y:= v1.y + v2.y;
end;

function D3DXVec2Subtract(const v1, v2: TD3DXVector2): TD3DXVector2;
begin
  Result.x:= v1.x - v2.x;
  Result.y:= v1.y - v2.y;
end;

// Minimize each component.  x = min(x1, x2), y = min(y1, y2)
function D3DXVec2Minimize(out vOut: TD3DXVector2; const v1, v2: TD3DXVEctor2): PD3DXVector2;
begin
  if v1.x < v2.x then vOut.x:= v1.x else vOut.x:= v2.x;
  if v1.y < v2.y then vOut.y:= v1.y else vOut.y:= v2.y;
  Result:= @vOut;
end;

// Maximize each component.  x = max(x1, x2), y = max(y1, y2)
function D3DXVec2Maximize(out vOut: TD3DXVector2; const v1, v2: TD3DXVector2): PD3DXVector2;
begin
  if v1.x > v2.x then vOut.x:= v1.x else vOut.x:= v2.x;
  if v1.y > v2.y then vOut.y:= v1.y else vOut.y:= v2.y;
  Result:= @vOut;
end;

function D3DXVec2Scale(out vOut: TD3DXVector2; const v: TD3DXVector2; s: Single): PD3DXVector2;
begin
  vOut.x:= v.x*s; vOut.y:= v.y*s;
  Result:= @vOut;
end;

// Linear interpolation. V1 + s(V2-V1)
function D3DXVec2Lerp(out vOut: TD3DXVector2; const v1, v2: TD3DXVector2; s: Single): PD3DXVector2;
begin
  vOut.x:= v1.x + s * (v2.x-v1.x);
  vOut.y:= v1.y + s * (v2.y-v1.y);
  Result:= @vOut;
end;


//--------------------------
// 3D Vector
//--------------------------
function D3DXVec3Length(const v: TD3DXVector3): Single;
begin
  with v do Result:= Sqrt(x*x + y*y + z*z);
end;

function D3DXVec3LengthSq(const v: TD3DXVector3): Single;
begin
  with v do Result:= x*x + y*y + z*z;
end;

function D3DXVec3Dot(const v1, v2: TD3DXVector3): Single;
begin
  Result:= v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
end;

function D3DXVec3Cross(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;
begin
  vOut.x:= v1.y * v2.z - v1.z * v2.y;
  vOut.y:= v1.z * v2.x - v1.x * v2.z;
  vOut.z:= v1.x * v2.y - v1.y * v2.x;
  Result:= @vOut;
end;

function D3DXVec3Add(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;
begin
  with vOut do
  begin
    x:= v1.x + v2.x;
    y:= v1.y + v2.y;
    z:= v1.z + v2.z;
  end;
  Result:= @vOut;
end;

function D3DXVec3Subtract(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;
begin
  with vOut do
  begin
    x:= v1.x - v2.x;
    y:= v1.y - v2.y;
    z:= v1.z - v2.z;
  end;
  Result:= @vOut;
end;

// Minimize each component.  x = min(x1, x2), y = min(y1, y2)
function D3DXVec3Minimize(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;
begin
  if v1.x < v2.x then vOut.x:= v1.x else vOut.x:= v2.x;
  if v1.y < v2.y then vOut.y:= v1.y else vOut.y:= v2.y;
  if v1.z < v2.z then vOut.z:= v1.z else vOut.z:= v2.z;
  Result:= @vOut;
end;

// Maximize each component.  x = max(x1, x2), y = max(y1, y2)
function D3DXVec3Maximize(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3): PD3DXVector3;
begin
  if v1.x > v2.x then vOut.x:= v1.x else vOut.x:= v2.x;
  if v1.y > v2.y then vOut.y:= v1.y else vOut.y:= v2.y;
  if v1.z > v2.z then vOut.z:= v1.z else vOut.z:= v2.z;
  Result:= @vOut;
end;

function D3DXVec3Scale(out vOut: TD3DXVector3; const v: TD3DXVector3; s: Single): PD3DXVector3;
begin
  with vOut do
  begin
    x:= v.x * s; y:= v.y * s; z:= v.z * s;
  end;
  Result:= @vOut;
end;

// Linear interpolation. V1 + s(V2-V1)
function D3DXVec3Lerp(out vOut: TD3DXVector3; const v1, v2: TD3DXVector3; s: Single): PD3DXVector3;
begin
  vOut.x:= v1.x + s * (v2.x-v1.x);
  vOut.y:= v1.y + s * (v2.y-v1.y);
  vOut.z:= v1.z + s * (v2.z-v1.z);
  Result:= @vOut;
end;


//--------------------------
// 4D Vector
//--------------------------

function D3DXVec4Length(const v: TD3DXVector4): Single;
begin
  with v do Result:= Sqrt(x*x + y*y + z*z + w*w);
end;

function D3DXVec4LengthSq(const v: TD3DXVector4): Single;
begin
  with v do Result:= x*x + y*y + z*z + w*w
end;

function D3DXVec4Dot(const v1, v2: TD3DXVector4): Single;
begin
  Result:= v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w;
end;

function D3DXVec4Add(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;
begin
  with vOut do
  begin
    x:= v1.x + v2.x;
    y:= v1.y + v2.y;
    z:= v1.z + v2.z;
    w:= v1.w + v2.w;
  end;
  Result:= @vOut;
end;

function D3DXVec4Subtract(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;
begin
  with vOut do
  begin
    x:= v1.x - v2.x;
    y:= v1.y - v2.y;
    z:= v1.z - v2.z;
    w:= v1.w - v2.w;
  end;
  Result:= @vOut;
end;


// Minimize each component.  x = min(x1, x2), y = min(y1, y2)
function D3DXVec4Minimize(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;
begin
  if v1.x < v2.x then vOut.x:= v1.x else vOut.x:= v2.x;
  if v1.y < v2.y then vOut.y:= v1.y else vOut.y:= v2.y;
  if v1.z < v2.z then vOut.z:= v1.z else vOut.z:= v2.z;
  if v1.w < v2.w then vOut.w:= v1.w else vOut.w:= v2.w;
  Result:= @vOut;
end;

// Maximize each component.  x = max(x1, x2), y = max(y1, y2)
function D3DXVec4Maximize(out vOut: TD3DXVector4; const v1, v2: TD3DXVector4): PD3DXVector4;
begin
  if v1.x > v2.x then vOut.x:= v1.x else vOut.x:= v2.x;
  if v1.y > v2.y then vOut.y:= v1.y else vOut.y:= v2.y;
  if v1.z > v2.z then vOut.z:= v1.z else vOut.z:= v2.z;
  if v1.w > v2.w then vOut.w:= v1.w else vOut.w:= v2.w;
  Result:= @vOut;
end;

function D3DXVec4Scale(out vOut: TD3DXVector4; const v: TD3DXVector4; s: Single): PD3DXVector4;
begin
  with vOut do
  begin
    x:= v.x * s; y:= v.y * s; z:= v.z * s; w:= v.w * s;
  end;
  Result:= @vOut;
end;

// Linear interpolation. V1 + s(V2-V1)
function D3DXVec4Lerp(out vOut: TD3DXVector4;
  const v1, v2: TD3DXVector4; s: Single): PD3DXVector4;
begin
  with vOut do
  begin
    x:= v1.x + s * (v2.x - v1.x);
    y:= v1.y + s * (v2.y - v1.y);
    z:= v1.z + s * (v2.z - v1.z);
    w:= v1.w + s * (v2.w - v1.w);
  end;
  Result:= @vOut;
end;

//--------------------------
// 4D Matrix
//--------------------------

// inline
function D3DXMatrixIdentity(out mOut: TD3DXMatrix): PD3DXMatrix;
begin
  FillChar(mOut, SizeOf(mOut), 0);
  mOut._11:= 1; mOut._22:= 1; mOut._33:= 1; mOut._44:= 1;
  Result:= @mOut;
end;

function D3DXMatrixIsIdentity(const m: TD3DXMatrix): BOOL;
begin
  with m do Result:=
    (_11 = 1) and (_12 = 0) and (_13 = 0) and (_14 = 0) and
    (_21 = 0) and (_22 = 1) and (_23 = 0) and (_24 = 0) and
    (_31 = 0) and (_32 = 0) and (_33 = 1) and (_34 = 0) and
    (_41 = 0) and (_42 = 0) and (_43 = 0) and (_44 = 1);
end;


//--------------------------
// Quaternion
//--------------------------

// inline

function D3DXQuaternionLength(const q: TD3DXQuaternion): Single;
begin
  with q do Result:= Sqrt(x*x + y*y + z*z + w*w);
end;

// Length squared, or "norm"
function D3DXQuaternionLengthSq(const q: TD3DXQuaternion): Single;
begin
  with q do Result:= x*x + y*y + z*z + w*w;
end;

function D3DXQuaternionDot(const q1, q2: TD3DXQuaternion): Single;
begin
  Result:= q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w;
end;

function D3DXQuaternionIdentity(out qOut: TD3DXQuaternion): PD3DXQuaternion;
begin
  with qOut do
  begin
    x:= 0; y:= 0; z:= 0; w:= 1.0;
  end;
  Result:= @qOut;
end;

function D3DXQuaternionIsIdentity(const q: TD3DXQuaternion): BOOL;
begin
  with q do Result:= (x = 0) and (y = 0) and (z = 0) and (w = 1);
end;

// (-x, -y, -z, w)
function D3DXQuaternionConjugate(out qOut: TD3DXQuaternion;
  const q: TD3DXQuaternion): PD3DXQuaternion;
begin
  with qOut do
  begin
    x:= -q.x; y:= -q.y; z:= -q.z; w:= q.w;
  end;
  Result:= @qOut;
end;


//--------------------------
// Plane
//--------------------------

// ax + by + cz + dw
function D3DXPlaneDot(const p: TD3DXPlane; const v: TD3DXVector4): Single;
begin
  with p,v do Result:= a*x + b*y + c*z + d*w;
end;

// ax + by + cz + d
function D3DXPlaneDotCoord(const p: TD3DXPlane; const v: TD3DXVector3): Single;
begin
  with p,v do Result:= a*x + b*y + c*z + d;
end;

// ax + by + cz
function D3DXPlaneDotNormal(const p: TD3DXPlane; const v: TD3DXVector3): Single;
begin
  with p,v do Result:= a*x + b*y + c*z;
end;


//--------------------------
// Color
//--------------------------

// inline

function D3DXColorNegative(out cOut: TD3DXColor; const c: TD3DXColor): PD3DXColor;
begin
 with cOut do
 begin
   r:= 1.0 - c.r; g:= 1.0 - c.g; b:= 1.0 - c.b;
   a:= c.a;
 end;
 Result:= @cOut;
end;

function D3DXColorAdd(out cOut: TD3DXColor; const c1,c2: TD3DXColor): PD3DXColor;
begin
  with cOut do
  begin
    r:= c1.r + c2.r; g:= c1.g + c2.g; b:= c1.b + c2.b;
    a:= c1.a + c2.a;
  end;
  Result:= @cOut;
end;

function D3DXColorSubtract(out cOut: TD3DXColor; const c1,c2: TD3DXColor): PD3DXColor;
begin
  with cOut do
  begin
    r:= c1.r - c2.r; g:= c1.g - c2.g; b:= c1.b - c2.b;
    a:= c1.a - c2.a;
  end;
  Result:= @cOut;
end;

function D3DXColorScale(out cOut: TD3DXColor; const c: TD3DXColor; s: Single): PD3DXColor;
begin
  with cOut do
  begin
    r:= c.r * s; g:= c.g * s;
    b:= c.b * s; a:= c.a * s;
  end;
  Result:= @cOut;
end;

// (r1*r2, g1*g2, b1*b2, a1*a2)
function D3DXColorModulate(out cOut: TD3DXColor; const c1,c2: TD3DXColor): PD3DXColor;
begin
  with cOut do
  begin
    r:= c1.r * c2.r; g:= c1.g * c2.g;
    b:= c1.b * c2.b; a:= c1.a * c2.a;
  end;
  Result:= @cOut;
end;

// Linear interpolation of r,g,b, and a. C1 + s(C2-C1)
function D3DXColorLerp(out cOut: TD3DXColor; const c1,c2: TD3DXColor; s: Single): PD3DXColor;
begin
  with cOut do
  begin
    r:= c1.r + s * (c2.r - c1.r);
    g:= c1.g + s * (c2.g - c1.g);
    b:= c1.b + s * (c2.b - c1.b);
    a:= c1.a + s * (c2.a - c1.a);
  end;
  Result:= @cOut;
end;




///////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx8core.h
//  Content:    D3DX core types and functions
//
///////////////////////////////////////////////////////////////////////////


// Object Pascal support functions for D3DXGetErrorString
function D3DXGetErrorStringA(hr: HResult): String; overload;
var
  Buffer: array [0..254] of Char;
begin
  _D3DXGetErrorString(hr, PAnsiChar(@Buffer), 255);
  SetLength(Result, StrLen(PAnsiChar(@Buffer)));
  Move(Buffer, Result[1], Length(Result));
end;

function D3DXGetErrorStringW(hr: HResult): WideString; overload;
 function WStrLen(Str: PWideChar): Integer;
 begin
   Result := 0;
   while Str[Result] <> #0 do Inc(Result);
 end;
begin
  SetLength(Result, 255);
  _D3DXGetErrorStringW(hr, PWideChar(Result), Length(Result));
  SetLength(Result, WStrLen(PWideChar(Result)));
end;

{$IFNDEF UNICODE}
function D3DXGetErrorString(hr: HResult): String; overload;
var
  Buffer: array [0..254] of Char;
begin
  _D3DXGetErrorString(hr, PAnsiChar(@Buffer), 255);
  SetLength(Result, StrLen(PAnsiChar(@Buffer)));
  Move(Buffer, Result[1], Length(Result));
end;
{$ELSE}
function D3DXGetErrorString(hr: HResult): WideString; overload;
 function WStrLen(Str: PWideChar): Integer;
 begin
   Result := 0;
   while Str[Result] <> #0 do Inc(Result);
 end;
begin
  SetLength(Result, 255);
  _D3DXGetErrorStringW(hr, PWideChar(Result), Length(Result));
  SetLength(Result, WStrLen(PWideChar(Result)));
end;
{$ENDIF}

// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= Smooth DLL IMPLEMENTATION =*=*=
// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSDllD3DX8 = class(TSDll)
			public
		class function SystemNames() : TSStringList; override;
		class function DllNames() : TSStringList; override;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;
		class procedure Free(); override;
		end;

class function TSDllD3DX8.SystemNames() : TSStringList;
begin
Result := 'Direct3DX8';
SAddStringToStringList(Result, 'D3DX8');
end;

class function TSDllD3DX8.DllNames() : TSStringList;
var
	i : TSUInt16;
begin
Result := d3dx8dll;
if d3dx8dll <> 'D3DX81ab.dll' then
	SAddStringToStringList(Result, 'D3DX81ab.dll');
if d3dx8dll <> 'd3dx8.dll' then
	SAddStringToStringList(Result, 'd3dx8.dll');
if d3dx8dll <> 'd3dx8d.dll' then
	SAddStringToStringList(Result, 'd3dx8d.dll');
SAddStringToStringList(Result, 'd3dx9_33.dll');
SAddStringToStringList(Result, 'd3dx9.dll');
for i := 43 downto 24 do
	if i <> 33 then
		SAddStringToStringList(Result, 'd3dx9_'+SStr(i)+'.dll');
for i := 43 downto 24 do
	if i <> 33 then
		SAddStringToStringList(Result, 'd3dx9d_'+SStr(i)+'.dll');
SAddStringToStringList(Result, 'd3dx9d_33.dll');
SAddStringToStringList(Result, 'd3dx9d.dll');
end;

class procedure TSDllD3DX8.Free();
begin
D3DXVec2Normalize := nil;
D3DXVec2Hermite := nil;
D3DXVec2CatmullRom := nil;
D3DXVec2BaryCentric := nil;
D3DXVec2Transform := nil;
D3DXVec2TransformCoord := nil;
D3DXVec2TransformNormal := nil;
D3DXVec3Normalize := nil;
D3DXVec3Hermite := nil;
D3DXVec3CatmullRom := nil;
D3DXVec3BaryCentric := nil;
D3DXVec3Transform := nil;
D3DXVec3TransformCoord := nil;
D3DXVec3TransformNormal := nil;
D3DXVec3Project := nil;
D3DXVec3Unproject := nil;
D3DXVec4Cross := nil;
D3DXVec4Normalize := nil;
D3DXVec4Hermite := nil;
D3DXVec4CatmullRom := nil;
D3DXVec4BaryCentric := nil;
D3DXVec4Transform := nil;
D3DXMatrixfDeterminant := nil;
D3DXMatrixTranspose := nil;
D3DXMatrixMultiply := nil;
D3DXMatrixMultiplyTranspose := nil;
D3DXMatrixInverse := nil;
D3DXMatrixScaling := nil;
D3DXMatrixTranslation := nil;
D3DXMatrixRotationX := nil;
D3DXMatrixRotationY := nil;
D3DXMatrixRotationZ := nil;
D3DXMatrixRotationAxis := nil;
D3DXMatrixRotationQuaternion := nil;
D3DXMatrixRotationYawPitchRoll := nil;
D3DXMatrixTransformation := nil;
D3DXMatrixAffineTransformation := nil;
D3DXMatrixLookAtRH := nil;
D3DXMatrixLookAtLH := nil;
D3DXMatrixPerspectiveRH := nil;
D3DXMatrixPerspectiveLH := nil;
D3DXMatrixPerspectiveFovRH := nil;
D3DXMatrixPerspectiveFovLH := nil;
D3DXMatrixPerspectiveOffCenterRH := nil;
D3DXMatrixPerspectiveOffCenterLH := nil;
D3DXMatrixOrthoRH := nil;
D3DXMatrixOrthoLH := nil;
D3DXMatrixOrthoOffCenterRH := nil;
D3DXMatrixOrthoOffCenterLH := nil;
D3DXMatrixShadow := nil;
D3DXMatrixReflect := nil;
D3DXQuaternionToAxisAngle := nil;
D3DXQuaternionRotationMatrix := nil;
D3DXQuaternionRotationAxis := nil;
D3DXQuaternionRotationYawPitchRoll := nil;
D3DXQuaternionMultiply := nil;
D3DXQuaternionNormalize := nil;
D3DXQuaternionInverse := nil;
D3DXQuaternionLn := nil;
D3DXQuaternionExp := nil;
D3DXQuaternionSlerp := nil;
D3DXQuaternionSquad := nil;
D3DXQuaternionSquadSetup := nil;
D3DXQuaternionBaryCentric := nil;
D3DXPlaneNormalize := nil;
D3DXPlaneIntersectLine := nil;
D3DXPlaneFromPointNormal := nil;
D3DXPlaneFromPoints := nil;
D3DXPlaneTransform := nil;
D3DXColorAdjustSaturation := nil;
D3DXColorAdjustContrast := nil;
D3DXFresnelTerm := nil;
D3DXCreateMatrixStack := nil;
D3DXCreateFont := nil;
D3DXCreateFontIndirect := nil;
D3DXCreateSprite := nil;
D3DXCreateRenderToSurface := nil;
D3DXCreateRenderToEnvMap := nil;
D3DXAssembleShaderFromFileA := nil;
D3DXAssembleShaderFromFileW := nil;
D3DXAssembleShaderFromFile := nil;
D3DXAssembleShaderFromResourceA := nil;
D3DXAssembleShaderFromResourceW := nil;
D3DXAssembleShaderFromResource := nil;
D3DXAssembleShader := nil;
_D3DXGetErrorStringA := nil;
_D3DXGetErrorStringW := nil;
_D3DXGetErrorString := nil;
D3DXCreateEffectFromFileA := nil;
D3DXCreateEffectFromFileW := nil;
D3DXCreateEffectFromFile := nil;
D3DXCreateEffectFromResourceA := nil;
D3DXCreateEffectFromResourceW := nil;
D3DXCreateEffectFromResource := nil;
D3DXCreateEffect := nil;
D3DXCreateMesh := nil;
D3DXCreateMeshFVF := nil;
D3DXCreateSPMesh := nil;
D3DXCleanMesh := nil;
D3DXValidMesh := nil;
D3DXGeneratePMesh := nil;
D3DXSimplifyMesh := nil;
D3DXComputeBoundingSphere := nil;
D3DXComputeBoundingBox := nil;
D3DXComputeNormals := nil;
D3DXCreateBuffer := nil;
D3DXLoadMeshFromX := nil;
D3DXLoadMeshFromXInMemory := nil;
D3DXLoadMeshFromXResource := nil;
D3DXSaveMeshToX := nil;
D3DXCreatePMeshFromStream := nil;
D3DXCreateSkinMesh := nil;
D3DXCreateSkinMeshFVF := nil;
D3DXCreateSkinMeshFromMesh := nil;
D3DXLoadMeshFromXof := nil;
D3DXLoadSkinMeshFromXof := nil;
D3DXTessellateNPatches := nil;
D3DXGetFVFVertexSize := nil;
D3DXDeclaratorFromFVF := nil;
D3DXFVFFromDeclarator := nil;
D3DXWeldVertices := nil;
D3DXIntersect := nil;
D3DXIntersectSubset := nil;
D3DXSplitMesh := nil;
D3DXIntersectTri := nil;
D3DXSphereBoundProbe := nil;
D3DXBoxBoundProbe := nil;
D3DXComputeTangent := nil;
D3DXConvertMeshSubsetToSingleStrip := nil;
D3DXConvertMeshSubsetToStrips := nil;
D3DXCreatePolygon := nil;
D3DXCreateBox := nil;
D3DXCreateCylinder := nil;
D3DXCreateSphere := nil;
D3DXCreateTorus := nil;
D3DXCreateTeapot := nil;
D3DXCreateTextA := nil;
D3DXCreateTextW := nil;
D3DXCreateText := nil;
D3DXGetImageInfoFromFileA := nil;
D3DXGetImageInfoFromFileW := nil;
D3DXGetImageInfoFromFile := nil;
D3DXGetImageInfoFromResourceA := nil;
D3DXGetImageInfoFromResourceW := nil;
D3DXGetImageInfoFromResource := nil;
D3DXGetImageInfoFromFileInMemory := nil;
D3DXLoadSurfaceFromFileA := nil;
D3DXLoadSurfaceFromFileW := nil;
D3DXLoadSurfaceFromFile := nil;
D3DXLoadSurfaceFromResourceA := nil;
D3DXLoadSurfaceFromResourceW := nil;
D3DXLoadSurfaceFromResource := nil;
D3DXLoadSurfaceFromFileInMemory := nil;
D3DXLoadSurfaceFromSurface := nil;
D3DXLoadSurfaceFromMemory := nil;
D3DXSaveSurfaceToFileA := nil;
D3DXSaveSurfaceToFileW := nil;
D3DXSaveSurfaceToFile := nil;
D3DXLoadVolumeFromFileA := nil;
D3DXLoadVolumeFromFileW := nil;
D3DXLoadVolumeFromFile := nil;
D3DXLoadVolumeFromResourceA := nil;
D3DXLoadVolumeFromResourceW := nil;
D3DXLoadVolumeFromResource := nil;
D3DXLoadVolumeFromFileInMemory := nil;
D3DXLoadVolumeFromVolume := nil;
D3DXLoadVolumeFromMemory := nil;
D3DXSaveVolumeToFileA := nil;
D3DXSaveVolumeToFileW := nil;
D3DXSaveVolumeToFile := nil;
D3DXCheckTextureRequirements := nil;
D3DXCheckCubeTextureRequirements := nil;
D3DXCheckVolumeTextureRequirements := nil;
D3DXCreateTexture := nil;
D3DXCreateCubeTexture := nil;
D3DXCreateVolumeTexture := nil;
D3DXCreateTextureFromFileA := nil;
D3DXCreateTextureFromFileW := nil;
D3DXCreateTextureFromFile := nil;
D3DXCreateCubeTextureFromFileA := nil;
D3DXCreateCubeTextureFromFileW := nil;
D3DXCreateCubeTextureFromFile := nil;
D3DXCreateVolumeTextureFromFileA := nil;
D3DXCreateVolumeTextureFromFileW := nil;
D3DXCreateVolumeTextureFromFile := nil;
D3DXCreateTextureFromResourceA := nil;
D3DXCreateTextureFromResourceW := nil;
D3DXCreateTextureFromResource := nil;
D3DXCreateCubeTextureFromResourceA := nil;
D3DXCreateCubeTextureFromResourceW := nil;
D3DXCreateCubeTextureFromResource := nil;
D3DXCreateVolumeTextureFromResourceA := nil;
D3DXCreateVolumeTextureFromResourceW := nil;
D3DXCreateVolumeTextureFromResource := nil;
D3DXCreateTextureFromFileExA := nil;
D3DXCreateTextureFromFileExW := nil;
D3DXCreateTextureFromFileEx := nil;
D3DXCreateCubeTextureFromFileExA := nil;
D3DXCreateCubeTextureFromFileExW := nil;
D3DXCreateCubeTextureFromFileEx := nil;
D3DXCreateVolumeTextureFromFileExA := nil;
D3DXCreateVolumeTextureFromFileExW := nil;
D3DXCreateVolumeTextureFromFileEx := nil;
D3DXCreateTextureFromResourceExA := nil;
D3DXCreateTextureFromResourceExW := nil;
D3DXCreateTextureFromResourceEx := nil;
D3DXCreateCubeTextureFromResourceExA := nil;
D3DXCreateCubeTextureFromResourceExW := nil;
D3DXCreateCubeTextureFromResourceEx := nil;
D3DXCreateVolumeTextureFromResourceExA := nil;
D3DXCreateVolumeTextureFromResourceExW := nil;
D3DXCreateVolumeTextureFromResourceEx := nil;
D3DXCreateTextureFromFileInMemory := nil;
D3DXCreateCubeTextureFromFileInMemory := nil;
D3DXCreateVolumeTextureFromFileInMemory := nil;
D3DXCreateTextureFromFileInMemoryEx := nil;
D3DXCreateCubeTextureFromFileInMemoryEx := nil;
D3DXCreateVolumeTextureFromFileInMemoryEx := nil;
D3DXSaveTextureToFileA := nil;
D3DXSaveTextureToFileW := nil;
D3DXSaveTextureToFile := nil;
D3DXFilterTexture := nil;
D3DXFilterCubeTexture := nil;
D3DXFilterVolumeTexture := nil;
D3DXFillTexture := nil;
D3DXFillCubeTexture := nil;
D3DXFillVolumeTexture := nil;
D3DXComputeNormalMap := nil;
end;

class function TSDllD3DX8.Load(const VDll : TSLibHandle) : TSDllLoadObject;
var
	LoadResult : PSDllLoadObject = nil;

function LoadProcedure(const Name : PChar) : Pointer;
begin
Result := GetProcAddress(VDll, Name);
if Result = nil then
	SAddStringToStringList(LoadResult^.FFunctionErrors, SPCharToString(Name))
else
	LoadResult^.FFunctionLoaded += 1;
end;

begin
Result.Clear();
Result.FFunctionCount := 228;
LoadResult := @Result;
D3DXVec2Normalize := LoadProcedure('D3DXVec2Normalize');
D3DXVec2Hermite := LoadProcedure('D3DXVec2Hermite');
D3DXVec2CatmullRom := LoadProcedure('D3DXVec2CatmullRom');
D3DXVec2BaryCentric := LoadProcedure('D3DXVec2BaryCentric');
D3DXVec2Transform := LoadProcedure('D3DXVec2Transform');
D3DXVec2TransformCoord := LoadProcedure('D3DXVec2TransformCoord');
D3DXVec2TransformNormal := LoadProcedure('D3DXVec2TransformNormal');
D3DXVec3Normalize := LoadProcedure('D3DXVec3Normalize');
D3DXVec3Hermite := LoadProcedure('D3DXVec3Hermite');
D3DXVec3CatmullRom := LoadProcedure('D3DXVec3CatmullRom');
D3DXVec3BaryCentric := LoadProcedure('D3DXVec3BaryCentric');
D3DXVec3Transform := LoadProcedure('D3DXVec3Transform');
D3DXVec3TransformCoord := LoadProcedure('D3DXVec3TransformCoord');
D3DXVec3TransformNormal := LoadProcedure('D3DXVec3TransformNormal');
D3DXVec3Project := LoadProcedure('D3DXVec3Project');
D3DXVec3Unproject := LoadProcedure('D3DXVec3Unproject');
D3DXVec4Cross := LoadProcedure('D3DXVec4Cross');
D3DXVec4Normalize := LoadProcedure('D3DXVec4Normalize');
D3DXVec4Hermite := LoadProcedure('D3DXVec4Hermite');
D3DXVec4CatmullRom := LoadProcedure('D3DXVec4CatmullRom');
D3DXVec4BaryCentric := LoadProcedure('D3DXVec4BaryCentric');
D3DXVec4Transform := LoadProcedure('D3DXVec4Transform');
D3DXMatrixfDeterminant := LoadProcedure('D3DXMatrixfDeterminant');
D3DXMatrixTranspose := LoadProcedure('D3DXMatrixTranspose');
D3DXMatrixMultiply := LoadProcedure('D3DXMatrixMultiply');
D3DXMatrixMultiplyTranspose := LoadProcedure('D3DXMatrixMultiplyTranspose');
D3DXMatrixInverse := LoadProcedure('D3DXMatrixInverse');
D3DXMatrixScaling := LoadProcedure('D3DXMatrixScaling');
D3DXMatrixTranslation := LoadProcedure('D3DXMatrixTranslation');
D3DXMatrixRotationX := LoadProcedure('D3DXMatrixRotationX');
D3DXMatrixRotationY := LoadProcedure('D3DXMatrixRotationY');
D3DXMatrixRotationZ := LoadProcedure('D3DXMatrixRotationZ');
D3DXMatrixRotationAxis := LoadProcedure('D3DXMatrixRotationAxis');
D3DXMatrixRotationQuaternion := LoadProcedure('D3DXMatrixRotationQuaternion');
D3DXMatrixRotationYawPitchRoll := LoadProcedure('D3DXMatrixRotationYawPitchRoll');
D3DXMatrixTransformation := LoadProcedure('D3DXMatrixTransformation');
D3DXMatrixAffineTransformation := LoadProcedure('D3DXMatrixAffineTransformation');
D3DXMatrixLookAtRH := LoadProcedure('D3DXMatrixLookAtRH');
D3DXMatrixLookAtLH := LoadProcedure('D3DXMatrixLookAtLH');
D3DXMatrixPerspectiveRH := LoadProcedure('D3DXMatrixPerspectiveRH');
D3DXMatrixPerspectiveLH := LoadProcedure('D3DXMatrixPerspectiveLH');
D3DXMatrixPerspectiveFovRH := LoadProcedure('D3DXMatrixPerspectiveFovRH');
D3DXMatrixPerspectiveFovLH := LoadProcedure('D3DXMatrixPerspectiveFovLH');
D3DXMatrixPerspectiveOffCenterRH := LoadProcedure('D3DXMatrixPerspectiveOffCenterRH');
D3DXMatrixPerspectiveOffCenterLH := LoadProcedure('D3DXMatrixPerspectiveOffCenterLH');
D3DXMatrixOrthoRH := LoadProcedure('D3DXMatrixOrthoRH');
D3DXMatrixOrthoLH := LoadProcedure('D3DXMatrixOrthoLH');
D3DXMatrixOrthoOffCenterRH := LoadProcedure('D3DXMatrixOrthoOffCenterRH');
D3DXMatrixOrthoOffCenterLH := LoadProcedure('D3DXMatrixOrthoOffCenterLH');
D3DXMatrixShadow := LoadProcedure('D3DXMatrixShadow');
D3DXMatrixReflect := LoadProcedure('D3DXMatrixReflect');
D3DXQuaternionToAxisAngle := LoadProcedure('D3DXQuaternionToAxisAngle');
D3DXQuaternionRotationMatrix := LoadProcedure('D3DXQuaternionRotationMatrix');
D3DXQuaternionRotationAxis := LoadProcedure('D3DXQuaternionRotationAxis');
D3DXQuaternionRotationYawPitchRoll := LoadProcedure('D3DXQuaternionRotationYawPitchRoll');
D3DXQuaternionMultiply := LoadProcedure('D3DXQuaternionMultiply');
D3DXQuaternionNormalize := LoadProcedure('D3DXQuaternionNormalize');
D3DXQuaternionInverse := LoadProcedure('D3DXQuaternionInverse');
D3DXQuaternionLn := LoadProcedure('D3DXQuaternionLn');
D3DXQuaternionExp := LoadProcedure('D3DXQuaternionExp');
D3DXQuaternionSlerp := LoadProcedure('D3DXQuaternionSlerp');
D3DXQuaternionSquad := LoadProcedure('D3DXQuaternionSquad');
D3DXQuaternionSquadSetup := LoadProcedure('D3DXQuaternionSquadSetup');
D3DXQuaternionBaryCentric := LoadProcedure('D3DXQuaternionBaryCentric');
D3DXPlaneNormalize := LoadProcedure('D3DXPlaneNormalize');
D3DXPlaneIntersectLine := LoadProcedure('D3DXPlaneIntersectLine');
D3DXPlaneFromPointNormal := LoadProcedure('D3DXPlaneFromPointNormal');
D3DXPlaneFromPoints := LoadProcedure('D3DXPlaneFromPoints');
D3DXPlaneTransform := LoadProcedure('D3DXPlaneTransform');
D3DXColorAdjustSaturation := LoadProcedure('D3DXColorAdjustSaturation');
D3DXColorAdjustContrast := LoadProcedure('D3DXColorAdjustContrast');
D3DXFresnelTerm := LoadProcedure('D3DXFresnelTerm');
D3DXCreateMatrixStack := LoadProcedure('D3DXCreateMatrixStack');
D3DXCreateFont := LoadProcedure('D3DXCreateFont');
D3DXCreateFontIndirect := LoadProcedure('D3DXCreateFontIndirect');
D3DXCreateSprite := LoadProcedure('D3DXCreateSprite');
D3DXCreateRenderToSurface := LoadProcedure('D3DXCreateRenderToSurface');
D3DXCreateRenderToEnvMap := LoadProcedure('D3DXCreateRenderToEnvMap');
D3DXAssembleShaderFromFileA := LoadProcedure('D3DXAssembleShaderFromFileA');
D3DXAssembleShaderFromFileW := LoadProcedure('D3DXAssembleShaderFromFileW');
D3DXAssembleShaderFromFile := LoadProcedure('D3DXAssembleShaderFromFileA');
D3DXAssembleShaderFromResourceA := LoadProcedure('D3DXAssembleShaderFromResourceA');
D3DXAssembleShaderFromResourceW := LoadProcedure('D3DXAssembleShaderFromResourceW');
D3DXAssembleShaderFromResource := LoadProcedure('D3DXAssembleShaderFromResourceA');
D3DXAssembleShader := LoadProcedure('D3DXAssembleShader');
_D3DXGetErrorStringA := LoadProcedure('D3DXGetErrorStringA');
_D3DXGetErrorStringW := LoadProcedure('D3DXGetErrorStringW');
_D3DXGetErrorString := LoadProcedure('D3DXGetErrorStringA');
D3DXCreateEffectFromFileA := LoadProcedure('D3DXCreateEffectFromFileA');
D3DXCreateEffectFromFileW := LoadProcedure('D3DXCreateEffectFromFileW');
D3DXCreateEffectFromFile := LoadProcedure('D3DXCreateEffectFromFileA');
D3DXCreateEffectFromResourceA := LoadProcedure('D3DXCreateEffectFromResourceA');
D3DXCreateEffectFromResourceW := LoadProcedure('D3DXCreateEffectFromResourceW');
D3DXCreateEffectFromResource := LoadProcedure('D3DXCreateEffectFromResourceA');
D3DXCreateEffect := LoadProcedure('D3DXCreateEffect');
D3DXCreateMesh := LoadProcedure('D3DXCreateMesh');
D3DXCreateMeshFVF := LoadProcedure('D3DXCreateMeshFVF');
D3DXCreateSPMesh := LoadProcedure('D3DXCreateSPMesh');
D3DXCleanMesh := LoadProcedure('D3DXCleanMesh');
D3DXValidMesh := LoadProcedure('D3DXValidMesh');
D3DXGeneratePMesh := LoadProcedure('D3DXGeneratePMesh');
D3DXSimplifyMesh := LoadProcedure('D3DXSimplifyMesh');
D3DXComputeBoundingSphere := LoadProcedure('D3DXComputeBoundingSphere');
D3DXComputeBoundingBox := LoadProcedure('D3DXComputeBoundingBox');
D3DXComputeNormals := LoadProcedure('D3DXComputeNormals');
D3DXCreateBuffer := LoadProcedure('D3DXCreateBuffer');
D3DXLoadMeshFromX := LoadProcedure('D3DXLoadMeshFromX');
D3DXLoadMeshFromXInMemory := LoadProcedure('D3DXLoadMeshFromXInMemory');
D3DXLoadMeshFromXResource := LoadProcedure('D3DXLoadMeshFromXResource');
D3DXSaveMeshToX := LoadProcedure('D3DXSaveMeshToX');
D3DXCreatePMeshFromStream := LoadProcedure('D3DXCreatePMeshFromStream');
D3DXCreateSkinMesh := LoadProcedure('D3DXCreateSkinMesh');
D3DXCreateSkinMeshFVF := LoadProcedure('D3DXCreateSkinMeshFVF');
D3DXCreateSkinMeshFromMesh := LoadProcedure('D3DXCreateSkinMeshFromMesh');
D3DXLoadMeshFromXof := LoadProcedure('D3DXLoadMeshFromXof');
D3DXLoadSkinMeshFromXof := LoadProcedure('D3DXLoadSkinMeshFromXof');
D3DXTessellateNPatches := LoadProcedure('D3DXTessellateNPatches');
D3DXGetFVFVertexSize := LoadProcedure('D3DXGetFVFVertexSize');
D3DXDeclaratorFromFVF := LoadProcedure('D3DXDeclaratorFromFVF');
D3DXFVFFromDeclarator := LoadProcedure('D3DXFVFFromDeclarator');
D3DXWeldVertices := LoadProcedure('D3DXWeldVertices');
D3DXIntersect := LoadProcedure('D3DXIntersect');
D3DXIntersectSubset := LoadProcedure('D3DXIntersectSubset');
D3DXSplitMesh := LoadProcedure('D3DXSplitMesh');
D3DXIntersectTri := LoadProcedure('D3DXIntersectTri');
D3DXSphereBoundProbe := LoadProcedure('D3DXSphereBoundProbe');
D3DXBoxBoundProbe := LoadProcedure('D3DXBoxBoundProbe');
D3DXComputeTangent := LoadProcedure('D3DXComputeTangent');
D3DXConvertMeshSubsetToSingleStrip := LoadProcedure('D3DXConvertMeshSubsetToSingleStrip');
D3DXConvertMeshSubsetToStrips := LoadProcedure('D3DXConvertMeshSubsetToStrips');
D3DXCreatePolygon := LoadProcedure('D3DXCreatePolygon');
D3DXCreateBox := LoadProcedure('D3DXCreateBox');
D3DXCreateCylinder := LoadProcedure('D3DXCreateCylinder');
D3DXCreateSphere := LoadProcedure('D3DXCreateSphere');
D3DXCreateTorus := LoadProcedure('D3DXCreateTorus');
D3DXCreateTeapot := LoadProcedure('D3DXCreateTeapot');
D3DXCreateTextA := LoadProcedure('D3DXCreateTextA');
D3DXCreateTextW := LoadProcedure('D3DXCreateTextW');
D3DXCreateText := LoadProcedure('D3DXCreateTextA');
D3DXGetImageInfoFromFileA := LoadProcedure('D3DXGetImageInfoFromFileA');
D3DXGetImageInfoFromFileW := LoadProcedure('D3DXGetImageInfoFromFileW');
D3DXGetImageInfoFromFile := LoadProcedure('D3DXGetImageInfoFromFileA');
D3DXGetImageInfoFromResourceA := LoadProcedure('D3DXGetImageInfoFromResourceA');
D3DXGetImageInfoFromResourceW := LoadProcedure('D3DXGetImageInfoFromResourceW');
D3DXGetImageInfoFromResource := LoadProcedure('D3DXGetImageInfoFromResourceA');
D3DXGetImageInfoFromFileInMemory := LoadProcedure('D3DXGetImageInfoFromFileInMemory');
D3DXLoadSurfaceFromFileA := LoadProcedure('D3DXLoadSurfaceFromFileA');
D3DXLoadSurfaceFromFileW := LoadProcedure('D3DXLoadSurfaceFromFileW');
D3DXLoadSurfaceFromFile := LoadProcedure('D3DXLoadSurfaceFromFileA');
D3DXLoadSurfaceFromResourceA := LoadProcedure('D3DXLoadSurfaceFromResourceA');
D3DXLoadSurfaceFromResourceW := LoadProcedure('D3DXLoadSurfaceFromResourceW');
D3DXLoadSurfaceFromResource := LoadProcedure('D3DXLoadSurfaceFromResourceA');
D3DXLoadSurfaceFromFileInMemory := LoadProcedure('D3DXLoadSurfaceFromFileInMemory');
D3DXLoadSurfaceFromSurface := LoadProcedure('D3DXLoadSurfaceFromSurface');
D3DXLoadSurfaceFromMemory := LoadProcedure('D3DXLoadSurfaceFromMemory');
D3DXSaveSurfaceToFileA := LoadProcedure('D3DXSaveSurfaceToFileA');
D3DXSaveSurfaceToFileW := LoadProcedure('D3DXSaveSurfaceToFileW');
D3DXSaveSurfaceToFile := LoadProcedure('D3DXSaveSurfaceToFileA');
D3DXLoadVolumeFromFileA := LoadProcedure('D3DXLoadVolumeFromFileA');
D3DXLoadVolumeFromFileW := LoadProcedure('D3DXLoadVolumeFromFileW');
D3DXLoadVolumeFromFile := LoadProcedure('D3DXLoadVolumeFromFileA');
D3DXLoadVolumeFromResourceA := LoadProcedure('D3DXLoadVolumeFromResourceA');
D3DXLoadVolumeFromResourceW := LoadProcedure('D3DXLoadVolumeFromResourceW');
D3DXLoadVolumeFromResource := LoadProcedure('D3DXLoadVolumeFromResourceA');
D3DXLoadVolumeFromFileInMemory := LoadProcedure('D3DXLoadVolumeFromFileInMemory');
D3DXLoadVolumeFromVolume := LoadProcedure('D3DXLoadVolumeFromVolume');
D3DXLoadVolumeFromMemory := LoadProcedure('D3DXLoadVolumeFromMemory');
D3DXSaveVolumeToFileA := LoadProcedure('D3DXSaveVolumeToFileA');
D3DXSaveVolumeToFileW := LoadProcedure('D3DXSaveVolumeToFileW');
D3DXSaveVolumeToFile := LoadProcedure('D3DXSaveVolumeToFileA');
D3DXCheckTextureRequirements := LoadProcedure('D3DXCheckTextureRequirements');
D3DXCheckCubeTextureRequirements := LoadProcedure('D3DXCheckCubeTextureRequirements');
D3DXCheckVolumeTextureRequirements := LoadProcedure('D3DXCheckVolumeTextureRequirements');
D3DXCreateTexture := LoadProcedure('D3DXCreateTexture');
D3DXCreateCubeTexture := LoadProcedure('D3DXCreateCubeTexture');
D3DXCreateVolumeTexture := LoadProcedure('D3DXCreateVolumeTexture');
D3DXCreateTextureFromFileA := LoadProcedure('D3DXCreateTextureFromFileA');
D3DXCreateTextureFromFileW := LoadProcedure('D3DXCreateTextureFromFileW');
D3DXCreateTextureFromFile := LoadProcedure('D3DXCreateTextureFromFileA');
D3DXCreateCubeTextureFromFileA := LoadProcedure('D3DXCreateCubeTextureFromFileA');
D3DXCreateCubeTextureFromFileW := LoadProcedure('D3DXCreateCubeTextureFromFileW');
D3DXCreateCubeTextureFromFile := LoadProcedure('D3DXCreateCubeTextureFromFileA');
D3DXCreateVolumeTextureFromFileA := LoadProcedure('D3DXCreateVolumeTextureFromFileA');
D3DXCreateVolumeTextureFromFileW := LoadProcedure('D3DXCreateVolumeTextureFromFileW');
D3DXCreateVolumeTextureFromFile := LoadProcedure('D3DXCreateVolumeTextureFromFileA');
D3DXCreateTextureFromResourceA := LoadProcedure('D3DXCreateTextureFromResourceA');
D3DXCreateTextureFromResourceW := LoadProcedure('D3DXCreateTextureFromResourceW');
D3DXCreateTextureFromResource := LoadProcedure('D3DXCreateTextureFromResourceA');
D3DXCreateCubeTextureFromResourceA := LoadProcedure('D3DXCreateCubeTextureFromResourceA');
D3DXCreateCubeTextureFromResourceW := LoadProcedure('D3DXCreateCubeTextureFromResourceW');
D3DXCreateCubeTextureFromResource := LoadProcedure('D3DXCreateCubeTextureFromResourceA');
D3DXCreateVolumeTextureFromResourceA := LoadProcedure('D3DXCreateVolumeTextureFromResourceA');
D3DXCreateVolumeTextureFromResourceW := LoadProcedure('D3DXCreateVolumeTextureFromResourceW');
D3DXCreateVolumeTextureFromResource := LoadProcedure('D3DXCreateVolumeTextureFromResourceA');
D3DXCreateTextureFromFileExA := LoadProcedure('D3DXCreateTextureFromFileExA');
D3DXCreateTextureFromFileExW := LoadProcedure('D3DXCreateTextureFromFileExW');
D3DXCreateTextureFromFileEx := LoadProcedure('D3DXCreateTextureFromFileExA');
D3DXCreateCubeTextureFromFileExA := LoadProcedure('D3DXCreateCubeTextureFromFileExA');
D3DXCreateCubeTextureFromFileExW := LoadProcedure('D3DXCreateCubeTextureFromFileExW');
D3DXCreateCubeTextureFromFileEx := LoadProcedure('D3DXCreateCubeTextureFromFileExA');
D3DXCreateVolumeTextureFromFileExA := LoadProcedure('D3DXCreateVolumeTextureFromFileExA');
D3DXCreateVolumeTextureFromFileExW := LoadProcedure('D3DXCreateVolumeTextureFromFileExW');
D3DXCreateVolumeTextureFromFileEx := LoadProcedure('D3DXCreateVolumeTextureFromFileExA');
D3DXCreateTextureFromResourceExA := LoadProcedure('D3DXCreateTextureFromResourceExA');
D3DXCreateTextureFromResourceExW := LoadProcedure('D3DXCreateTextureFromResourceExW');
D3DXCreateTextureFromResourceEx := LoadProcedure('D3DXCreateTextureFromResourceExA');
D3DXCreateCubeTextureFromResourceExA := LoadProcedure('D3DXCreateCubeTextureFromResourceExA');
D3DXCreateCubeTextureFromResourceExW := LoadProcedure('D3DXCreateCubeTextureFromResourceExW');
D3DXCreateCubeTextureFromResourceEx := LoadProcedure('D3DXCreateCubeTextureFromResourceExA');
D3DXCreateVolumeTextureFromResourceExA := LoadProcedure('D3DXCreateVolumeTextureFromResourceExA');
D3DXCreateVolumeTextureFromResourceExW := LoadProcedure('D3DXCreateVolumeTextureFromResourceExW');
D3DXCreateVolumeTextureFromResourceEx := LoadProcedure('D3DXCreateVolumeTextureFromResourceExA');
D3DXCreateTextureFromFileInMemory := LoadProcedure('D3DXCreateTextureFromFileInMemory');
D3DXCreateCubeTextureFromFileInMemory := LoadProcedure('D3DXCreateCubeTextureFromFileInMemory');
D3DXCreateVolumeTextureFromFileInMemory := LoadProcedure('D3DXCreateVolumeTextureFromFileInMemory');
D3DXCreateTextureFromFileInMemoryEx := LoadProcedure('D3DXCreateTextureFromFileInMemoryEx');
D3DXCreateCubeTextureFromFileInMemoryEx := LoadProcedure('D3DXCreateCubeTextureFromFileInMemoryEx');
D3DXCreateVolumeTextureFromFileInMemoryEx := LoadProcedure('D3DXCreateVolumeTextureFromFileInMemoryEx');
D3DXSaveTextureToFileA := LoadProcedure('D3DXSaveTextureToFileA');
D3DXSaveTextureToFileW := LoadProcedure('D3DXSaveTextureToFileW');
D3DXSaveTextureToFile := LoadProcedure('D3DXSaveTextureToFileA');
D3DXFilterTexture := LoadProcedure('D3DXFilterTexture');
D3DXFilterCubeTexture := LoadProcedure('D3DXFilterTexture');
D3DXFilterVolumeTexture := LoadProcedure('D3DXFilterTexture');
D3DXFillTexture := LoadProcedure('D3DXFillTexture');
D3DXFillCubeTexture := LoadProcedure('D3DXFillCubeTexture');
D3DXFillVolumeTexture := LoadProcedure('D3DXFillVolumeTexture');
D3DXComputeNormalMap := LoadProcedure('D3DXComputeNormalMap');
end;

initialization
begin
TSDllD3DX8.Create();
end;
end.
