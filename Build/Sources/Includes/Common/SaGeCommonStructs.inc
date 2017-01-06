//INC_WITHOUT_FORWARD
//INC_PLACE_INTERFACE
//INC_PLACE_IMPLEMENTATION
//INC_PLACE_RENDER_INTERFACE
//INC_PLACE_RENDER_CLASS
//INC_PLACE_RENDER_IMPLEMENTATION
//MACRO RENDER_CLASS
{$INCLUDE SaGeCommonStructUndef.inc}

(*====================================================================*)
(*============================32 bit, float===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2f}
{$DEFINE STRUCT_3     := TSGVertex3f}
{$DEFINE STRUCT_4     := TSGVertex4f}
{$DEFINE STRUCT_P_2   := PSGVertex2f}
{$DEFINE STRUCT_P_3   := PSGVertex3f}
{$DEFINE STRUCT_P_4   := PSGVertex4f}
{$DEFINE STRUCT_TYPE  := TSGFloat}
{$DEFINE STRUCT_PTYPE := PSGFloat}
{$DEFINE STRUCT_2_LIST:= TSGVertex2fList}
{$DEFINE STRUCT_3_LIST:= TSGVertex3fList}
{$DEFINE STRUCT_4_LIST:= TSGVertex4fList}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2fImport}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3fImport}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4fImport}
{$DEFINE STRUCT_IS_FLOAT}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2f  = TSGVertex2f;
	TSGVector2f = TSGVertex2f;
	TSGColor2f  = TSGVertex2f;
	
	TSGPoint3f  = TSGVertex3f;
	TSGVector3f = TSGVertex3f;
	TSGColor3f  = TSGVertex3f;
	
	TSGPoint4f  = TSGVertex4f;
	TSGVector4f = TSGVertex4f;
	TSGColor4f  = TSGVertex4f;
	
	PSGPoint2f  = PSGVertex2f;
	PSGVector2f = PSGVertex2f;
	PSGColor2f  = PSGVertex2f;
	
	PSGPoint3f  = PSGVertex3f;
	PSGVector3f = PSGVertex3f;
	PSGColor3f  = PSGVertex3f;
	
	PSGPoint4f  = PSGVertex4f;
	PSGVector4f = PSGVertex4f;
	PSGColor4f  = PSGVertex4f;
{$ENDIF}

(*====================================================================*)
(*============================64 bit, float===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2d}
{$DEFINE STRUCT_3     := TSGVertex3d}
{$DEFINE STRUCT_4     := TSGVertex4d}
{$DEFINE STRUCT_P_2   := PSGVertex2d}
{$DEFINE STRUCT_P_3   := PSGVertex3d}
{$DEFINE STRUCT_P_4   := PSGVertex4d}
{$DEFINE STRUCT_TYPE  := TSGDouble}
{$DEFINE STRUCT_PTYPE := PSGDouble}
{$DEFINE STRUCT_2_LIST:= TSGVertex2dList}
{$DEFINE STRUCT_3_LIST:= TSGVertex3dList}
{$DEFINE STRUCT_4_LIST:= TSGVertex4dList}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2dImport}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3dImport}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4dImport}
{$DEFINE STRUCT_IS_FLOAT}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2d  = TSGVertex2d;
	TSGVector2d = TSGVertex2d;
	TSGColor2d  = TSGVertex2d;
	
	TSGPoint3d  = TSGVertex3d;
	TSGVector3d = TSGVertex3d;
	TSGColor3d  = TSGVertex3d;
	
	TSGPoint4d  = TSGVertex4d;
	TSGVector4d = TSGVertex4d;
	TSGColor4d  = TSGVertex4d;
	
	PSGPoint2d  = PSGVertex2d;
	PSGVector2d = PSGVertex2d;
	PSGColor2d  = PSGVertex2d;
	
	PSGPoint3d  = PSGVertex3d;
	PSGVector3d = PSGVertex3d;
	PSGColor3d  = PSGVertex3d;
	
	PSGPoint4d  = PSGVertex4d;
	PSGVector4d = PSGVertex4d;
	PSGColor4d  = PSGVertex4d;
{$ENDIF}

{$IFNDEF WITHOUT_EXTENDED}
(*====================================================================*)
(*============================80 bit, float===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2e}
{$DEFINE STRUCT_3     := TSGVertex3e}
{$DEFINE STRUCT_4     := TSGVertex4e}
{$DEFINE STRUCT_P_2   := PSGVertex2e}
{$DEFINE STRUCT_P_3   := PSGVertex3e}
{$DEFINE STRUCT_P_4   := PSGVertex4e}
{$DEFINE STRUCT_TYPE  := TSGExtended}
{$DEFINE STRUCT_PTYPE := PSGExtended}
{$DEFINE STRUCT_2_LIST:= TSGVertex2eList}
{$DEFINE STRUCT_3_LIST:= TSGVertex3eList}
{$DEFINE STRUCT_4_LIST:= TSGVertex4eList}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2eImport}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3eImport}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4eImport}
{$DEFINE STRUCT_IS_FLOAT}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2e  = TSGVertex2e;
	TSGVector2e = TSGVertex2e;
	TSGColor2e  = TSGVertex2e;
	
	TSGPoint3e  = TSGVertex3e;
	TSGVector3e = TSGVertex3e;
	TSGColor3e  = TSGVertex3e;
	
	TSGPoint4e  = TSGVertex4e;
	TSGVector4e = TSGVertex4e;
	TSGColor4e  = TSGVertex4e;
	
	PSGPoint2e  = PSGVertex2e;
	PSGVector2e = PSGVertex2e;
	PSGColor2e  = PSGVertex2e;
	
	PSGPoint3e  = PSGVertex3e;
	PSGVector3e = PSGVertex3e;
	PSGColor3e  = PSGVertex3e;
	
	PSGPoint4e  = PSGVertex4e;
	PSGVector4e = PSGVertex4e;
	PSGColor4e  = PSGVertex4e;
{$ENDIF}
{$ENDIF WITHOUT_EXTENDED}

(*====================================================================*)
(*=========================64 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2uint64}
{$DEFINE STRUCT_3     := TSGVertex3uint64}
{$DEFINE STRUCT_4     := TSGVertex4uint64}
{$DEFINE STRUCT_P_2   := PSGVertex2uint64}
{$DEFINE STRUCT_P_3   := PSGVertex3uint64}
{$DEFINE STRUCT_P_4   := PSGVertex4uint64}
{$DEFINE STRUCT_TYPE  := TSGQuadWord}
{$DEFINE STRUCT_PTYPE := PSGQuadWord}
{$DEFINE STRUCT_2_LIST:= TSGVertex2uint64List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3uint64List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4uint64List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2uint64Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3uint64Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4uint64Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2uint64  = TSGVertex2uint64;
	TSGVector2uint64 = TSGVertex2uint64;
	TSGColor2uint64  = TSGVertex2uint64;
	
	TSGVertex2ui64   = TSGVertex2uint64;
	TSGPoint2ui64    = TSGVertex2uint64;
	TSGVector2ui64   = TSGVertex2uint64;
	TSGColor2ui64    = TSGVertex2uint64;
	
	TSGPoint3uint64  = TSGVertex3uint64;
	TSGVector3uint64 = TSGVertex3uint64;
	TSGColor3uint64  = TSGVertex3uint64;
	
	TSGVertex3ui64   = TSGVertex3uint64;
	TSGPoint3ui64    = TSGVertex3uint64;
	TSGVector3ui64   = TSGVertex3uint64;
	TSGColor3ui64    = TSGVertex3uint64;
	
	TSGPoint4uint64  = TSGVertex4uint64;
	TSGVector4uint64 = TSGVertex4uint64;
	TSGColor4uint64  = TSGVertex4uint64;
	
	TSGVertex4ui64   = TSGVertex4uint64;
	TSGPoint4ui64    = TSGVertex4uint64;
	TSGVector4ui64   = TSGVertex4uint64;
	TSGColor4ui64    = TSGVertex4uint64;
type
	PSGPoint2uint64  = PSGVertex2uint64;
	PSGVector2uint64 = PSGVertex2uint64;
	PSGColor2uint64  = PSGVertex2uint64;
	
	PSGVertex2ui64   = PSGVertex2uint64;
	PSGPoint2ui64    = PSGVertex2uint64;
	PSGVector2ui64   = PSGVertex2uint64;
	PSGColor2ui64    = PSGVertex2uint64;
	
	PSGPoint3uint64  = PSGVertex3uint64;
	PSGVector3uint64 = PSGVertex3uint64;
	PSGColor3uint64  = PSGVertex3uint64;
	
	PSGVertex3ui64   = PSGVertex3uint64;
	PSGPoint3ui64    = PSGVertex3uint64;
	PSGVector3ui64   = PSGVertex3uint64;
	PSGColor3ui64    = PSGVertex3uint64;
	
	PSGPoint4uint64  = PSGVertex4uint64;
	PSGVector4uint64 = PSGVertex4uint64;
	PSGColor4uint64  = PSGVertex4uint64;
	
	PSGVertex4ui64   = PSGVertex4uint64;
	PSGPoint4ui64    = PSGVertex4uint64;
	PSGVector4ui64   = PSGVertex4uint64;
	PSGColor4ui64    = PSGVertex4uint64;
{$ENDIF}

(*====================================================================*)
(*===========================64 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2int64}
{$DEFINE STRUCT_3     := TSGVertex3int64}
{$DEFINE STRUCT_4     := TSGVertex4int64}
{$DEFINE STRUCT_P_2   := PSGVertex2int64}
{$DEFINE STRUCT_P_3   := PSGVertex3int64}
{$DEFINE STRUCT_P_4   := PSGVertex4int64}
{$DEFINE STRUCT_TYPE  := TSGInt64}
{$DEFINE STRUCT_PTYPE := PSGInt64}
{$DEFINE STRUCT_2_LIST:= TSGVertex2int64List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3int64List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4int64List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2int64Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3int64Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4int64Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2int64  = TSGVertex2int64;
	TSGVector2int64 = TSGVertex2int64;
	TSGColor2int64  = TSGVertex2int64;
	
	TSGVertex2i64   = TSGVertex2int64;
	TSGPoint2i64    = TSGVertex2int64;
	TSGVector2i64   = TSGVertex2int64;
	TSGColor2i64    = TSGVertex2int64;
	
	TSGPoint3int64  = TSGVertex3int64;
	TSGVector3int64 = TSGVertex3int64;
	TSGColor3int64  = TSGVertex3int64;
	
	TSGVertex3i64   = TSGVertex3int64;
	TSGPoint3i64    = TSGVertex3int64;
	TSGVector3i64   = TSGVertex3int64;
	TSGColor3i64    = TSGVertex3int64;
	
	TSGPoint4int64  = TSGVertex4int64;
	TSGVector4int64 = TSGVertex4int64;
	TSGColor4int64  = TSGVertex4int64;
	
	TSGVertex4i64   = TSGVertex4int64;
	TSGPoint4i64    = TSGVertex4int64;
	TSGVector4i64   = TSGVertex4int64;
	TSGColor4i64    = TSGVertex4int64;
type
	PSGPoint2int64  = PSGVertex2int64;
	PSGVector2int64 = PSGVertex2int64;
	PSGColor2int64  = PSGVertex2int64;
	
	PSGVertex2i64   = PSGVertex2int64;
	PSGPoint2i64    = PSGVertex2int64;
	PSGVector2i64   = PSGVertex2int64;
	PSGColor2i64    = PSGVertex2int64;
	
	PSGPoint3int64  = PSGVertex3int64;
	PSGVector3int64 = PSGVertex3int64;
	PSGColor3int64  = PSGVertex3int64;
	
	PSGVertex3i64   = PSGVertex3int64;
	PSGPoint3i64    = PSGVertex3int64;
	PSGVector3i64   = PSGVertex3int64;
	PSGColor3i64    = PSGVertex3int64;
	
	PSGPoint4int64  = PSGVertex4int64;
	PSGVector4int64 = PSGVertex4int64;
	PSGColor4int64  = PSGVertex4int64;
	
	PSGVertex4i64   = PSGVertex4int64;
	PSGPoint4i64    = PSGVertex4int64;
	PSGVector4i64   = PSGVertex4int64;
	PSGColor4i64    = PSGVertex4int64;
{$ENDIF}

(*====================================================================*)
(*=========================32 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2uint32}
{$DEFINE STRUCT_3     := TSGVertex3uint32}
{$DEFINE STRUCT_4     := TSGVertex4uint32}
{$DEFINE STRUCT_P_2   := PSGVertex2uint32}
{$DEFINE STRUCT_P_3   := PSGVertex3uint32}
{$DEFINE STRUCT_P_4   := PSGVertex4uint32}
{$DEFINE STRUCT_TYPE  := TSGLongWord}
{$DEFINE STRUCT_PTYPE := PSGLongWord}
{$DEFINE STRUCT_2_LIST:= TSGVertex2uint32List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3uint32List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4uint32List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2uint32Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3uint32Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4uint32Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2uint32  = TSGVertex2uint32;
	TSGVector2uint32 = TSGVertex2uint32;
	TSGColor2uint32  = TSGVertex2uint32;
	
	TSGVertex2ui32   = TSGVertex2uint32;
	TSGPoint2ui32    = TSGVertex2uint32;
	TSGVector2ui32   = TSGVertex2uint32;
	TSGColor2ui32    = TSGVertex2uint32;
	
	TSGPoint3uint32  = TSGVertex3uint32;
	TSGVector3uint32 = TSGVertex3uint32;
	TSGColor3uint32  = TSGVertex3uint32;
	
	TSGVertex3ui32   = TSGVertex3uint32;
	TSGPoint3ui32    = TSGVertex3uint32;
	TSGVector3ui32   = TSGVertex3uint32;
	TSGColor3ui32    = TSGVertex3uint32;
	
	TSGPoint4uint32  = TSGVertex4uint32;
	TSGVector4uint32 = TSGVertex4uint32;
	TSGColor4uint32  = TSGVertex4uint32;
	
	TSGVertex4ui32   = TSGVertex4uint32;
	TSGPoint4ui32    = TSGVertex4uint32;
	TSGVector4ui32   = TSGVertex4uint32;
	TSGColor4ui32    = TSGVertex4uint32;
type
	PSGPoint2uint32  = PSGVertex2uint32;
	PSGVector2uint32 = PSGVertex2uint32;
	PSGColor2uint32  = PSGVertex2uint32;
	
	PSGVertex2ui32   = PSGVertex2uint32;
	PSGPoint2ui32    = PSGVertex2uint32;
	PSGVector2ui32   = PSGVertex2uint32;
	PSGColor2ui32    = PSGVertex2uint32;
	
	PSGPoint3uint32  = PSGVertex3uint32;
	PSGVector3uint32 = PSGVertex3uint32;
	PSGColor3uint32  = PSGVertex3uint32;
	
	PSGVertex3ui32   = PSGVertex3uint32;
	PSGPoint3ui32    = PSGVertex3uint32;
	PSGVector3ui32   = PSGVertex3uint32;
	PSGColor3ui32    = PSGVertex3uint32;
	
	PSGPoint4uint32  = PSGVertex4uint32;
	PSGVector4uint32 = PSGVertex4uint32;
	PSGColor4uint32  = PSGVertex4uint32;
	
	PSGVertex4ui32   = PSGVertex4uint32;
	PSGPoint4ui32    = PSGVertex4uint32;
	PSGVector4ui32   = PSGVertex4uint32;
	PSGColor4ui32    = PSGVertex4uint32;
{$ENDIF}

(*====================================================================*)
(*===========================32 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2int32}
{$DEFINE STRUCT_3     := TSGVertex3int32}
{$DEFINE STRUCT_4     := TSGVertex4int32}
{$DEFINE STRUCT_P_2   := PSGVertex2int32}
{$DEFINE STRUCT_P_3   := PSGVertex3int32}
{$DEFINE STRUCT_P_4   := PSGVertex4int32}
{$DEFINE STRUCT_TYPE  := TSGLongInt}
{$DEFINE STRUCT_PTYPE := PSGLongInt}
{$DEFINE STRUCT_2_LIST:= TSGVertex2int32List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3int32List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4int32List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2int32Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3int32Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4int32Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2int32  = TSGVertex2int32;
	TSGVector2int32 = TSGVertex2int32;
	TSGColor2int32  = TSGVertex2int32;
	
	TSGVertex2i32   = TSGVertex2int32;
	TSGPoint2i32    = TSGVertex2int32;
	TSGVector2i32   = TSGVertex2int32;
	TSGColor2i32    = TSGVertex2int32;
	
	TSGPoint3int32  = TSGVertex3int32;
	TSGVector3int32 = TSGVertex3int32;
	TSGColor3int32  = TSGVertex3int32;
	
	TSGVertex3i32   = TSGVertex3int32;
	TSGPoint3i32    = TSGVertex3int32;
	TSGVector3i32   = TSGVertex3int32;
	TSGColor3i32    = TSGVertex3int32;
	
	TSGPoint4int32  = TSGVertex4int32;
	TSGVector4int32 = TSGVertex4int32;
	TSGColor4int32  = TSGVertex4int32;
	
	TSGVertex4i32   = TSGVertex4int32;
	TSGPoint4i32    = TSGVertex4int32;
	TSGVector4i32   = TSGVertex4int32;
	TSGColor4i32    = TSGVertex4int32;
type
	PSGPoint2int32  = PSGVertex2int32;
	PSGVector2int32 = PSGVertex2int32;
	PSGColor2int32  = PSGVertex2int32;
	
	PSGVertex2i32   = PSGVertex2int32;
	PSGPoint2i32    = PSGVertex2int32;
	PSGVector2i32   = PSGVertex2int32;
	PSGColor2i32    = PSGVertex2int32;
	
	PSGPoint3int32  = PSGVertex3int32;
	PSGVector3int32 = PSGVertex3int32;
	PSGColor3int32  = PSGVertex3int32;
	
	PSGVertex3i32   = PSGVertex3int32;
	PSGPoint3i32    = PSGVertex3int32;
	PSGVector3i32   = PSGVertex3int32;
	PSGColor3i32    = PSGVertex3int32;
	
	PSGPoint4int32  = PSGVertex4int32;
	PSGVector4int32 = PSGVertex4int32;
	PSGColor4int32  = PSGVertex4int32;
	
	PSGVertex4i32   = PSGVertex4int32;
	PSGPoint4i32    = PSGVertex4int32;
	PSGVector4i32   = PSGVertex4int32;
	PSGColor4i32    = PSGVertex4int32;
{$ENDIF}

(*====================================================================*)
(*=========================16 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2uint16}
{$DEFINE STRUCT_3     := TSGVertex3uint16}
{$DEFINE STRUCT_4     := TSGVertex4uint16}
{$DEFINE STRUCT_P_2   := PSGVertex2uint16}
{$DEFINE STRUCT_P_3   := PSGVertex3uint16}
{$DEFINE STRUCT_P_4   := PSGVertex4uint16}
{$DEFINE STRUCT_TYPE  := TSGWord}
{$DEFINE STRUCT_PTYPE := PSGWord}
{$DEFINE STRUCT_2_LIST:= TSGVertex2uint16List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3uint16List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4uint16List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2uint16Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3uint16Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4uint16Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2uint16  = TSGVertex2uint16;
	TSGVector2uint16 = TSGVertex2uint16;
	TSGColor2uint16  = TSGVertex2uint16;
	
	TSGVertex2ui16   = TSGVertex2uint16;
	TSGPoint2ui16    = TSGVertex2uint16;
	TSGVector2ui16   = TSGVertex2uint16;
	TSGColor2ui16    = TSGVertex2uint16;
	
	TSGPoint3uint16  = TSGVertex3uint16;
	TSGVector3uint16 = TSGVertex3uint16;
	TSGColor3uint16  = TSGVertex3uint16;
	
	TSGVertex3ui16   = TSGVertex3uint16;
	TSGPoint3ui16    = TSGVertex3uint16;
	TSGVector3ui16   = TSGVertex3uint16;
	TSGColor3ui16    = TSGVertex3uint16;
	
	TSGPoint4uint16  = TSGVertex4uint16;
	TSGVector4uint16 = TSGVertex4uint16;
	TSGColor4uint16  = TSGVertex4uint16;
	
	TSGVertex4ui16   = TSGVertex4uint16;
	TSGPoint4ui16    = TSGVertex4uint16;
	TSGVector4ui16   = TSGVertex4uint16;
	TSGColor4ui16    = TSGVertex4uint16;
type
	PSGPoint2uint16  = PSGVertex2uint16;
	PSGVector2uint16 = PSGVertex2uint16;
	PSGColor2uint16  = PSGVertex2uint16;
	
	PSGVertex2ui16   = PSGVertex2uint16;
	PSGPoint2ui16    = PSGVertex2uint16;
	PSGVector2ui16   = PSGVertex2uint16;
	PSGColor2ui16    = PSGVertex2uint16;
	
	PSGPoint3uint16  = PSGVertex3uint16;
	PSGVector3uint16 = PSGVertex3uint16;
	PSGColor3uint16  = PSGVertex3uint16;
	
	PSGVertex3ui16   = PSGVertex3uint16;
	PSGPoint3ui16    = PSGVertex3uint16;
	PSGVector3ui16   = PSGVertex3uint16;
	PSGColor3ui16    = PSGVertex3uint16;
	
	PSGPoint4uint16  = PSGVertex4uint16;
	PSGVector4uint16 = PSGVertex4uint16;
	PSGColor4uint16  = PSGVertex4uint16;
	
	PSGVertex4ui16   = PSGVertex4uint16;
	PSGPoint4ui16    = PSGVertex4uint16;
	PSGVector4ui16   = PSGVertex4uint16;
	PSGColor4ui16    = PSGVertex4uint16;
{$ENDIF}

(*====================================================================*)
(*===========================16 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2int16}
{$DEFINE STRUCT_3     := TSGVertex3int16}
{$DEFINE STRUCT_4     := TSGVertex4int16}
{$DEFINE STRUCT_P_2   := PSGVertex2int16}
{$DEFINE STRUCT_P_3   := PSGVertex3int16}
{$DEFINE STRUCT_P_4   := PSGVertex4int16}
{$DEFINE STRUCT_TYPE  := TSGSmallInt}
{$DEFINE STRUCT_PTYPE := PSGSmallInt}
{$DEFINE STRUCT_2_LIST:= TSGVertex2int16List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3int16List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4int16List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2int16Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3int16Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4int16Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2int16  = TSGVertex2int16;
	TSGVector2int16 = TSGVertex2int16;
	TSGColor2int16  = TSGVertex2int16;
	
	TSGVertex2i16   = TSGVertex2int16;
	TSGPoint2i16    = TSGVertex2int16;
	TSGVector2i16   = TSGVertex2int16;
	TSGColor2i16    = TSGVertex2int16;
	
	TSGPoint3int16  = TSGVertex3int16;
	TSGVector3int16 = TSGVertex3int16;
	TSGColor3int16  = TSGVertex3int16;
	
	TSGVertex3i16   = TSGVertex3int16;
	TSGPoint3i16    = TSGVertex3int16;
	TSGVector3i16   = TSGVertex3int16;
	TSGColor3i16    = TSGVertex3int16;
	
	TSGPoint4int16  = TSGVertex4int16;
	TSGVector4int16 = TSGVertex4int16;
	TSGColor4int16  = TSGVertex4int16;
	
	TSGVertex4i16   = TSGVertex4int16;
	TSGPoint4i16    = TSGVertex4int16;
	TSGVector4i16   = TSGVertex4int16;
	TSGColor4i16    = TSGVertex4int16;
type
	PSGPoint2int16  = PSGVertex2int16;
	PSGVector2int16 = PSGVertex2int16;
	PSGColor2int16  = PSGVertex2int16;
	
	PSGVertex2i16   = PSGVertex2int16;
	PSGPoint2i16    = PSGVertex2int16;
	PSGVector2i16   = PSGVertex2int16;
	PSGColor2i16    = PSGVertex2int16;
	
	PSGPoint3int16  = PSGVertex3int16;
	PSGVector3int16 = PSGVertex3int16;
	PSGColor3int16  = PSGVertex3int16;
	
	PSGVertex3i16   = PSGVertex3int16;
	PSGPoint3i16    = PSGVertex3int16;
	PSGVector3i16   = PSGVertex3int16;
	PSGColor3i16    = PSGVertex3int16;
	
	PSGPoint4int16  = PSGVertex4int16;
	PSGVector4int16 = PSGVertex4int16;
	PSGColor4int16  = PSGVertex4int16;
	
	PSGVertex4i16   = PSGVertex4int16;
	PSGPoint4i16    = PSGVertex4int16;
	PSGVector4i16   = PSGVertex4int16;
	PSGColor4i16    = PSGVertex4int16;
{$ENDIF}

(*====================================================================*)
(*=========================8 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2uint8}
{$DEFINE STRUCT_3     := TSGVertex3uint8}
{$DEFINE STRUCT_4     := TSGVertex4uint8}
{$DEFINE STRUCT_P_2   := PSGVertex2uint8}
{$DEFINE STRUCT_P_3   := PSGVertex3uint8}
{$DEFINE STRUCT_P_4   := PSGVertex4uint8}
{$DEFINE STRUCT_TYPE  := TSGByte}
{$DEFINE STRUCT_PTYPE := PSGByte}
{$DEFINE STRUCT_2_LIST:= TSGVertex2uint8List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3uint8List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4uint8List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2uint8Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3uint8Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4uint8Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGVertex2b   = TSGVertex2uint8;
	TSGPoint2b    = TSGVertex2uint8;
	TSGVector2b   = TSGVertex2uint8;
	TSGColor2b    = TSGVertex2uint8;
	
	TSGVertex3b   = TSGVertex3uint8;
	TSGPoint3b    = TSGVertex3uint8;
	TSGVector3b   = TSGVertex3uint8;
	TSGColor3b    = TSGVertex3uint8;
	
	TSGVertex4b   = TSGVertex4uint8;
	TSGPoint4b    = TSGVertex4uint8;
	TSGVector4b   = TSGVertex4uint8;
	TSGColor4b    = TSGVertex4uint8;
type
	
	PSGVertex2b   = PSGVertex2uint8;
	PSGPoint2b    = PSGVertex2uint8;
	PSGVector2b   = PSGVertex2uint8;
	PSGColor2b    = PSGVertex2uint8;
	
	
	PSGVertex3b   = PSGVertex3uint8;
	PSGPoint3b    = PSGVertex3uint8;
	PSGVector3b   = PSGVertex3uint8;
	PSGColor3b    = PSGVertex3uint8;
	
	PSGVertex4b   = PSGVertex4uint8;
	PSGPoint4b    = PSGVertex4uint8;
	PSGVector4b   = PSGVertex4uint8;
	PSGColor4b    = PSGVertex4uint8;
type
	TSGPoint2uint8  = TSGVertex2uint8;
	TSGVector2uint8 = TSGVertex2uint8;
	TSGColor2uint8  = TSGVertex2uint8;
	
	TSGVertex2ui8   = TSGVertex2uint8;
	TSGPoint2ui8    = TSGVertex2uint8;
	TSGVector2ui8   = TSGVertex2uint8;
	TSGColor2ui8    = TSGVertex2uint8;
	
	TSGPoint3uint8  = TSGVertex3uint8;
	TSGVector3uint8 = TSGVertex3uint8;
	TSGColor3uint8  = TSGVertex3uint8;
	
	TSGVertex3ui8   = TSGVertex3uint8;
	TSGPoint3ui8    = TSGVertex3uint8;
	TSGVector3ui8   = TSGVertex3uint8;
	TSGColor3ui8    = TSGVertex3uint8;
	
	TSGPoint4uint8  = TSGVertex4uint8;
	TSGVector4uint8 = TSGVertex4uint8;
	TSGColor4uint8  = TSGVertex4uint8;
	
	TSGVertex4ui8   = TSGVertex4uint8;
	TSGPoint4ui8    = TSGVertex4uint8;
	TSGVector4ui8   = TSGVertex4uint8;
	TSGColor4ui8    = TSGVertex4uint8;
type
	PSGPoint2uint8  = PSGVertex2uint8;
	PSGVector2uint8 = PSGVertex2uint8;
	PSGColor2uint8  = PSGVertex2uint8;
	
	PSGVertex2ui8   = PSGVertex2uint8;
	PSGPoint2ui8    = PSGVertex2uint8;
	PSGVector2ui8   = PSGVertex2uint8;
	PSGColor2ui8    = PSGVertex2uint8;
	
	PSGPoint3uint8  = PSGVertex3uint8;
	PSGVector3uint8 = PSGVertex3uint8;
	PSGColor3uint8  = PSGVertex3uint8;
	
	PSGVertex3ui8   = PSGVertex3uint8;
	PSGPoint3ui8    = PSGVertex3uint8;
	PSGVector3ui8   = PSGVertex3uint8;
	PSGColor3ui8    = PSGVertex3uint8;
	
	PSGPoint4uint8  = PSGVertex4uint8;
	PSGVector4uint8 = PSGVertex4uint8;
	PSGColor4uint8  = PSGVertex4uint8;
	
	PSGVertex4ui8   = PSGVertex4uint8;
	PSGPoint4ui8    = PSGVertex4uint8;
	PSGVector4ui8   = PSGVertex4uint8;
	PSGColor4ui8    = PSGVertex4uint8;
{$ENDIF}

(*====================================================================*)
(*===========================8 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSGVertex2int8}
{$DEFINE STRUCT_3     := TSGVertex3int8}
{$DEFINE STRUCT_4     := TSGVertex4int8}
{$DEFINE STRUCT_P_2   := PSGVertex2int8}
{$DEFINE STRUCT_P_3   := PSGVertex3int8}
{$DEFINE STRUCT_P_4   := PSGVertex4int8}
{$DEFINE STRUCT_TYPE  := TSGShortInt}
{$DEFINE STRUCT_PTYPE := PSGShortInt}
{$DEFINE STRUCT_2_LIST:= TSGVertex2int8List}
{$DEFINE STRUCT_3_LIST:= TSGVertex3int8List}
{$DEFINE STRUCT_4_LIST:= TSGVertex4int8List}
{$DEFINE STRUCT_2_IMPORT_FUNC := SGVertex2int8Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SGVertex3int8Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SGVertex4int8Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SaGeCommonStruct.inc}
{$INCLUDE SaGeCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSGPoint2int8  = TSGVertex2int8;
	TSGVector2int8 = TSGVertex2int8;
	TSGColor2int8  = TSGVertex2int8;
	
	TSGVertex2i8   = TSGVertex2int8;
	TSGPoint2i8    = TSGVertex2int8;
	TSGVector2i8   = TSGVertex2int8;
	TSGColor2i8    = TSGVertex2int8;
	
	TSGPoint3int8  = TSGVertex3int8;
	TSGVector3int8 = TSGVertex3int8;
	TSGColor3int8  = TSGVertex3int8;
	
	TSGVertex3i8   = TSGVertex3int8;
	TSGPoint3i8    = TSGVertex3int8;
	TSGVector3i8   = TSGVertex3int8;
	TSGColor3i8    = TSGVertex3int8;
	
	TSGPoint4int8  = TSGVertex4int8;
	TSGVector4int8 = TSGVertex4int8;
	TSGColor4int8  = TSGVertex4int8;
	
	TSGVertex4i8   = TSGVertex4int8;
	TSGPoint4i8    = TSGVertex4int8;
	TSGVector4i8   = TSGVertex4int8;
	TSGColor4i8    = TSGVertex4int8;
type
	PSGPoint2int8  = PSGVertex2int8;
	PSGVector2int8 = PSGVertex2int8;
	PSGColor2int8  = PSGVertex2int8;
	
	PSGVertex2i8   = PSGVertex2int8;
	PSGPoint2i8    = PSGVertex2int8;
	PSGVector2i8   = PSGVertex2int8;
	PSGColor2i8    = PSGVertex2int8;
	
	PSGPoint3int8  = PSGVertex3int8;
	PSGVector3int8 = PSGVertex3int8;
	PSGColor3int8  = PSGVertex3int8;
	
	PSGVertex3i8   = PSGVertex3int8;
	PSGPoint3i8    = PSGVertex3int8;
	PSGVector3i8   = PSGVertex3int8;
	PSGColor3i8    = PSGVertex3int8;
	
	PSGPoint4int8  = PSGVertex4int8;
	PSGVector4int8 = PSGVertex4int8;
	PSGColor4int8  = PSGVertex4int8;
	
	PSGVertex4i8   = PSGVertex4int8;
	PSGPoint4i8    = PSGVertex4int8;
	PSGVector4i8   = PSGVertex4int8;
	PSGColor4i8    = PSGVertex4int8;
{$ENDIF}
