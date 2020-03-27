//INC_WITHOUT_FORWARD
//INC_PLACE_INTERFACE
//INC_PLACE_IMPLEMENTATION
//INC_PLACE_RENDER_INTERFACE
//INC_PLACE_RENDER_CLASS
//INC_PLACE_RENDER_IMPLEMENTATION
//MACRO RENDER_CLASS
{$INCLUDE SmoothCommonStructUndef.inc}

(*====================================================================*)
(*============================32 bit, float===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2f}
{$DEFINE STRUCT_3     := TSVertex3f}
{$DEFINE STRUCT_4     := TSVertex4f}
{$DEFINE STRUCT_P_2   := PSVertex2f}
{$DEFINE STRUCT_P_3   := PSVertex3f}
{$DEFINE STRUCT_P_4   := PSVertex4f}
{$DEFINE STRUCT_TYPE  := TSFloat}
{$DEFINE STRUCT_PTYPE := PSFloat}
{$DEFINE STRUCT_2_LIST:= TSVertex2fList}
{$DEFINE STRUCT_3_LIST:= TSVertex3fList}
{$DEFINE STRUCT_4_LIST:= TSVertex4fList}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2fListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3fListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4fListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2fImport}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3fImport}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4fImport}
{$DEFINE STRUCT_IS_FLOAT}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2f  = TSVertex2f;
	TSVector2f = TSVertex2f;
	TSColor2f  = TSVertex2f;
	
	TSPoint3f  = TSVertex3f;
	TSVector3f = TSVertex3f;
	TSColor3f  = TSVertex3f;
	
	TSPoint4f  = TSVertex4f;
	TSVector4f = TSVertex4f;
	TSColor4f  = TSVertex4f;
	
	PSPoint2f  = PSVertex2f;
	PSVector2f = PSVertex2f;
	PSColor2f  = PSVertex2f;
	
	PSPoint3f  = PSVertex3f;
	PSVector3f = PSVertex3f;
	PSColor3f  = PSVertex3f;
	
	PSPoint4f  = PSVertex4f;
	PSVector4f = PSVertex4f;
	PSColor4f  = PSVertex4f;
{$ENDIF}

(*====================================================================*)
(*============================64 bit, float===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2d}
{$DEFINE STRUCT_3     := TSVertex3d}
{$DEFINE STRUCT_4     := TSVertex4d}
{$DEFINE STRUCT_P_2   := PSVertex2d}
{$DEFINE STRUCT_P_3   := PSVertex3d}
{$DEFINE STRUCT_P_4   := PSVertex4d}
{$DEFINE STRUCT_TYPE  := TSDouble}
{$DEFINE STRUCT_PTYPE := PSDouble}
{$DEFINE STRUCT_2_LIST:= TSVertex2dList}
{$DEFINE STRUCT_3_LIST:= TSVertex3dList}
{$DEFINE STRUCT_4_LIST:= TSVertex4dList}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2dListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3dListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4dListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2dImport}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3dImport}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4dImport}
{$DEFINE STRUCT_IS_FLOAT}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2d  = TSVertex2d;
	TSVector2d = TSVertex2d;
	TSColor2d  = TSVertex2d;
	
	TSPoint3d  = TSVertex3d;
	TSVector3d = TSVertex3d;
	TSColor3d  = TSVertex3d;
	
	TSPoint4d  = TSVertex4d;
	TSVector4d = TSVertex4d;
	TSColor4d  = TSVertex4d;
	
	PSPoint2d  = PSVertex2d;
	PSVector2d = PSVertex2d;
	PSColor2d  = PSVertex2d;
	
	PSPoint3d  = PSVertex3d;
	PSVector3d = PSVertex3d;
	PSColor3d  = PSVertex3d;
	
	PSPoint4d  = PSVertex4d;
	PSVector4d = PSVertex4d;
	PSColor4d  = PSVertex4d;
{$ENDIF}

{$IFNDEF WITHOUT_EXTENDED}
(*====================================================================*)
(*============================80 bit, float===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2e}
{$DEFINE STRUCT_3     := TSVertex3e}
{$DEFINE STRUCT_4     := TSVertex4e}
{$DEFINE STRUCT_P_2   := PSVertex2e}
{$DEFINE STRUCT_P_3   := PSVertex3e}
{$DEFINE STRUCT_P_4   := PSVertex4e}
{$DEFINE STRUCT_TYPE  := TSExtended}
{$DEFINE STRUCT_PTYPE := PSExtended}
{$DEFINE STRUCT_2_LIST:= TSVertex2eList}
{$DEFINE STRUCT_3_LIST:= TSVertex3eList}
{$DEFINE STRUCT_4_LIST:= TSVertex4eList}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2eListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3eListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4eListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2eImport}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3eImport}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4eImport}
{$DEFINE STRUCT_IS_FLOAT}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2e  = TSVertex2e;
	TSVector2e = TSVertex2e;
	TSColor2e  = TSVertex2e;
	
	TSPoint3e  = TSVertex3e;
	TSVector3e = TSVertex3e;
	TSColor3e  = TSVertex3e;
	
	TSPoint4e  = TSVertex4e;
	TSVector4e = TSVertex4e;
	TSColor4e  = TSVertex4e;
	
	PSPoint2e  = PSVertex2e;
	PSVector2e = PSVertex2e;
	PSColor2e  = PSVertex2e;
	
	PSPoint3e  = PSVertex3e;
	PSVector3e = PSVertex3e;
	PSColor3e  = PSVertex3e;
	
	PSPoint4e  = PSVertex4e;
	PSVector4e = PSVertex4e;
	PSColor4e  = PSVertex4e;
{$ENDIF}
{$ENDIF WITHOUT_EXTENDED}

(*====================================================================*)
(*=========================64 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2uint64}
{$DEFINE STRUCT_3     := TSVertex3uint64}
{$DEFINE STRUCT_4     := TSVertex4uint64}
{$DEFINE STRUCT_P_2   := PSVertex2uint64}
{$DEFINE STRUCT_P_3   := PSVertex3uint64}
{$DEFINE STRUCT_P_4   := PSVertex4uint64}
{$DEFINE STRUCT_TYPE  := TSQuadWord}
{$DEFINE STRUCT_PTYPE := PSQuadWord}
{$DEFINE STRUCT_2_LIST:= TSVertex2uint64List}
{$DEFINE STRUCT_3_LIST:= TSVertex3uint64List}
{$DEFINE STRUCT_4_LIST:= TSVertex4uint64List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2uint64ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3uint64ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4uint64ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2uint64Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3uint64Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4uint64Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2uint64  = TSVertex2uint64;
	TSVector2uint64 = TSVertex2uint64;
	TSColor2uint64  = TSVertex2uint64;
	
	TSVertex2ui64   = TSVertex2uint64;
	TSPoint2ui64    = TSVertex2uint64;
	TSVector2ui64   = TSVertex2uint64;
	TSColor2ui64    = TSVertex2uint64;
	
	TSPoint3uint64  = TSVertex3uint64;
	TSVector3uint64 = TSVertex3uint64;
	TSColor3uint64  = TSVertex3uint64;
	
	TSVertex3ui64   = TSVertex3uint64;
	TSPoint3ui64    = TSVertex3uint64;
	TSVector3ui64   = TSVertex3uint64;
	TSColor3ui64    = TSVertex3uint64;
	
	TSPoint4uint64  = TSVertex4uint64;
	TSVector4uint64 = TSVertex4uint64;
	TSColor4uint64  = TSVertex4uint64;
	
	TSVertex4ui64   = TSVertex4uint64;
	TSPoint4ui64    = TSVertex4uint64;
	TSVector4ui64   = TSVertex4uint64;
	TSColor4ui64    = TSVertex4uint64;
type
	PSPoint2uint64  = PSVertex2uint64;
	PSVector2uint64 = PSVertex2uint64;
	PSColor2uint64  = PSVertex2uint64;
	
	PSVertex2ui64   = PSVertex2uint64;
	PSPoint2ui64    = PSVertex2uint64;
	PSVector2ui64   = PSVertex2uint64;
	PSColor2ui64    = PSVertex2uint64;
	
	PSPoint3uint64  = PSVertex3uint64;
	PSVector3uint64 = PSVertex3uint64;
	PSColor3uint64  = PSVertex3uint64;
	
	PSVertex3ui64   = PSVertex3uint64;
	PSPoint3ui64    = PSVertex3uint64;
	PSVector3ui64   = PSVertex3uint64;
	PSColor3ui64    = PSVertex3uint64;
	
	PSPoint4uint64  = PSVertex4uint64;
	PSVector4uint64 = PSVertex4uint64;
	PSColor4uint64  = PSVertex4uint64;
	
	PSVertex4ui64   = PSVertex4uint64;
	PSPoint4ui64    = PSVertex4uint64;
	PSVector4ui64   = PSVertex4uint64;
	PSColor4ui64    = PSVertex4uint64;
{$ENDIF}

(*====================================================================*)
(*===========================64 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2int64}
{$DEFINE STRUCT_3     := TSVertex3int64}
{$DEFINE STRUCT_4     := TSVertex4int64}
{$DEFINE STRUCT_P_2   := PSVertex2int64}
{$DEFINE STRUCT_P_3   := PSVertex3int64}
{$DEFINE STRUCT_P_4   := PSVertex4int64}
{$DEFINE STRUCT_TYPE  := TSInt64}
{$DEFINE STRUCT_PTYPE := PSInt64}
{$DEFINE STRUCT_2_LIST:= TSVertex2int64List}
{$DEFINE STRUCT_3_LIST:= TSVertex3int64List}
{$DEFINE STRUCT_4_LIST:= TSVertex4int64List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2int64ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3int64ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4int64ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2int64Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3int64Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4int64Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2int64  = TSVertex2int64;
	TSVector2int64 = TSVertex2int64;
	TSColor2int64  = TSVertex2int64;
	
	TSVertex2i64   = TSVertex2int64;
	TSPoint2i64    = TSVertex2int64;
	TSVector2i64   = TSVertex2int64;
	TSColor2i64    = TSVertex2int64;
	
	TSPoint3int64  = TSVertex3int64;
	TSVector3int64 = TSVertex3int64;
	TSColor3int64  = TSVertex3int64;
	
	TSVertex3i64   = TSVertex3int64;
	TSPoint3i64    = TSVertex3int64;
	TSVector3i64   = TSVertex3int64;
	TSColor3i64    = TSVertex3int64;
	
	TSPoint4int64  = TSVertex4int64;
	TSVector4int64 = TSVertex4int64;
	TSColor4int64  = TSVertex4int64;
	
	TSVertex4i64   = TSVertex4int64;
	TSPoint4i64    = TSVertex4int64;
	TSVector4i64   = TSVertex4int64;
	TSColor4i64    = TSVertex4int64;
type
	PSPoint2int64  = PSVertex2int64;
	PSVector2int64 = PSVertex2int64;
	PSColor2int64  = PSVertex2int64;
	
	PSVertex2i64   = PSVertex2int64;
	PSPoint2i64    = PSVertex2int64;
	PSVector2i64   = PSVertex2int64;
	PSColor2i64    = PSVertex2int64;
	
	PSPoint3int64  = PSVertex3int64;
	PSVector3int64 = PSVertex3int64;
	PSColor3int64  = PSVertex3int64;
	
	PSVertex3i64   = PSVertex3int64;
	PSPoint3i64    = PSVertex3int64;
	PSVector3i64   = PSVertex3int64;
	PSColor3i64    = PSVertex3int64;
	
	PSPoint4int64  = PSVertex4int64;
	PSVector4int64 = PSVertex4int64;
	PSColor4int64  = PSVertex4int64;
	
	PSVertex4i64   = PSVertex4int64;
	PSPoint4i64    = PSVertex4int64;
	PSVector4i64   = PSVertex4int64;
	PSColor4i64    = PSVertex4int64;
{$ENDIF}

(*====================================================================*)
(*=========================32 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2uint32}
{$DEFINE STRUCT_3     := TSVertex3uint32}
{$DEFINE STRUCT_4     := TSVertex4uint32}
{$DEFINE STRUCT_P_2   := PSVertex2uint32}
{$DEFINE STRUCT_P_3   := PSVertex3uint32}
{$DEFINE STRUCT_P_4   := PSVertex4uint32}
{$DEFINE STRUCT_TYPE  := TSLongWord}
{$DEFINE STRUCT_PTYPE := PSLongWord}
{$DEFINE STRUCT_2_LIST:= TSVertex2uint32List}
{$DEFINE STRUCT_3_LIST:= TSVertex3uint32List}
{$DEFINE STRUCT_4_LIST:= TSVertex4uint32List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2uint32ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3uint32ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4uint32ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2uint32Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3uint32Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4uint32Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2uint32  = TSVertex2uint32;
	TSVector2uint32 = TSVertex2uint32;
	TSColor2uint32  = TSVertex2uint32;
	
	TSVertex2ui32   = TSVertex2uint32;
	TSPoint2ui32    = TSVertex2uint32;
	TSVector2ui32   = TSVertex2uint32;
	TSColor2ui32    = TSVertex2uint32;
	
	TSPoint3uint32  = TSVertex3uint32;
	TSVector3uint32 = TSVertex3uint32;
	TSColor3uint32  = TSVertex3uint32;
	
	TSVertex3ui32   = TSVertex3uint32;
	TSPoint3ui32    = TSVertex3uint32;
	TSVector3ui32   = TSVertex3uint32;
	TSColor3ui32    = TSVertex3uint32;
	
	TSPoint4uint32  = TSVertex4uint32;
	TSVector4uint32 = TSVertex4uint32;
	TSColor4uint32  = TSVertex4uint32;
	
	TSVertex4ui32   = TSVertex4uint32;
	TSPoint4ui32    = TSVertex4uint32;
	TSVector4ui32   = TSVertex4uint32;
	TSColor4ui32    = TSVertex4uint32;
type
	PSPoint2uint32  = PSVertex2uint32;
	PSVector2uint32 = PSVertex2uint32;
	PSColor2uint32  = PSVertex2uint32;
	
	PSVertex2ui32   = PSVertex2uint32;
	PSPoint2ui32    = PSVertex2uint32;
	PSVector2ui32   = PSVertex2uint32;
	PSColor2ui32    = PSVertex2uint32;
	
	PSPoint3uint32  = PSVertex3uint32;
	PSVector3uint32 = PSVertex3uint32;
	PSColor3uint32  = PSVertex3uint32;
	
	PSVertex3ui32   = PSVertex3uint32;
	PSPoint3ui32    = PSVertex3uint32;
	PSVector3ui32   = PSVertex3uint32;
	PSColor3ui32    = PSVertex3uint32;
	
	PSPoint4uint32  = PSVertex4uint32;
	PSVector4uint32 = PSVertex4uint32;
	PSColor4uint32  = PSVertex4uint32;
	
	PSVertex4ui32   = PSVertex4uint32;
	PSPoint4ui32    = PSVertex4uint32;
	PSVector4ui32   = PSVertex4uint32;
	PSColor4ui32    = PSVertex4uint32;
{$ENDIF}

(*====================================================================*)
(*===========================32 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2int32}
{$DEFINE STRUCT_3     := TSVertex3int32}
{$DEFINE STRUCT_4     := TSVertex4int32}
{$DEFINE STRUCT_P_2   := PSVertex2int32}
{$DEFINE STRUCT_P_3   := PSVertex3int32}
{$DEFINE STRUCT_P_4   := PSVertex4int32}
{$DEFINE STRUCT_TYPE  := TSLongInt}
{$DEFINE STRUCT_PTYPE := PSLongInt}
{$DEFINE STRUCT_2_LIST:= TSVertex2int32List}
{$DEFINE STRUCT_3_LIST:= TSVertex3int32List}
{$DEFINE STRUCT_4_LIST:= TSVertex4int32List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2int32ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3int32ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4int32ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2int32Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3int32Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4int32Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2int32  = TSVertex2int32;
	TSVector2int32 = TSVertex2int32;
	TSColor2int32  = TSVertex2int32;
	
	TSVertex2i32   = TSVertex2int32;
	TSPoint2i32    = TSVertex2int32;
	TSVector2i32   = TSVertex2int32;
	TSColor2i32    = TSVertex2int32;
	
	TSPoint3int32  = TSVertex3int32;
	TSVector3int32 = TSVertex3int32;
	TSColor3int32  = TSVertex3int32;
	
	TSVertex3i32   = TSVertex3int32;
	TSPoint3i32    = TSVertex3int32;
	TSVector3i32   = TSVertex3int32;
	TSColor3i32    = TSVertex3int32;
	
	TSPoint4int32  = TSVertex4int32;
	TSVector4int32 = TSVertex4int32;
	TSColor4int32  = TSVertex4int32;
	
	TSVertex4i32   = TSVertex4int32;
	TSPoint4i32    = TSVertex4int32;
	TSVector4i32   = TSVertex4int32;
	TSColor4i32    = TSVertex4int32;
type
	PSPoint2int32  = PSVertex2int32;
	PSVector2int32 = PSVertex2int32;
	PSColor2int32  = PSVertex2int32;
	
	PSVertex2i32   = PSVertex2int32;
	PSPoint2i32    = PSVertex2int32;
	PSVector2i32   = PSVertex2int32;
	PSColor2i32    = PSVertex2int32;
	
	PSPoint3int32  = PSVertex3int32;
	PSVector3int32 = PSVertex3int32;
	PSColor3int32  = PSVertex3int32;
	
	PSVertex3i32   = PSVertex3int32;
	PSPoint3i32    = PSVertex3int32;
	PSVector3i32   = PSVertex3int32;
	PSColor3i32    = PSVertex3int32;
	
	PSPoint4int32  = PSVertex4int32;
	PSVector4int32 = PSVertex4int32;
	PSColor4int32  = PSVertex4int32;
	
	PSVertex4i32   = PSVertex4int32;
	PSPoint4i32    = PSVertex4int32;
	PSVector4i32   = PSVertex4int32;
	PSColor4i32    = PSVertex4int32;
{$ENDIF}

(*====================================================================*)
(*=========================16 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2uint16}
{$DEFINE STRUCT_3     := TSVertex3uint16}
{$DEFINE STRUCT_4     := TSVertex4uint16}
{$DEFINE STRUCT_P_2   := PSVertex2uint16}
{$DEFINE STRUCT_P_3   := PSVertex3uint16}
{$DEFINE STRUCT_P_4   := PSVertex4uint16}
{$DEFINE STRUCT_TYPE  := TSWord}
{$DEFINE STRUCT_PTYPE := PSWord}
{$DEFINE STRUCT_2_LIST:= TSVertex2uint16List}
{$DEFINE STRUCT_3_LIST:= TSVertex3uint16List}
{$DEFINE STRUCT_4_LIST:= TSVertex4uint16List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2uint16ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3uint16ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4uint16ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2uint16Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3uint16Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4uint16Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2uint16  = TSVertex2uint16;
	TSVector2uint16 = TSVertex2uint16;
	TSColor2uint16  = TSVertex2uint16;
	
	TSVertex2ui16   = TSVertex2uint16;
	TSPoint2ui16    = TSVertex2uint16;
	TSVector2ui16   = TSVertex2uint16;
	TSColor2ui16    = TSVertex2uint16;
	
	TSPoint3uint16  = TSVertex3uint16;
	TSVector3uint16 = TSVertex3uint16;
	TSColor3uint16  = TSVertex3uint16;
	
	TSVertex3ui16   = TSVertex3uint16;
	TSPoint3ui16    = TSVertex3uint16;
	TSVector3ui16   = TSVertex3uint16;
	TSColor3ui16    = TSVertex3uint16;
	
	TSPoint4uint16  = TSVertex4uint16;
	TSVector4uint16 = TSVertex4uint16;
	TSColor4uint16  = TSVertex4uint16;
	
	TSVertex4ui16   = TSVertex4uint16;
	TSPoint4ui16    = TSVertex4uint16;
	TSVector4ui16   = TSVertex4uint16;
	TSColor4ui16    = TSVertex4uint16;
type
	PSPoint2uint16  = PSVertex2uint16;
	PSVector2uint16 = PSVertex2uint16;
	PSColor2uint16  = PSVertex2uint16;
	
	PSVertex2ui16   = PSVertex2uint16;
	PSPoint2ui16    = PSVertex2uint16;
	PSVector2ui16   = PSVertex2uint16;
	PSColor2ui16    = PSVertex2uint16;
	
	PSPoint3uint16  = PSVertex3uint16;
	PSVector3uint16 = PSVertex3uint16;
	PSColor3uint16  = PSVertex3uint16;
	
	PSVertex3ui16   = PSVertex3uint16;
	PSPoint3ui16    = PSVertex3uint16;
	PSVector3ui16   = PSVertex3uint16;
	PSColor3ui16    = PSVertex3uint16;
	
	PSPoint4uint16  = PSVertex4uint16;
	PSVector4uint16 = PSVertex4uint16;
	PSColor4uint16  = PSVertex4uint16;
	
	PSVertex4ui16   = PSVertex4uint16;
	PSPoint4ui16    = PSVertex4uint16;
	PSVector4ui16   = PSVertex4uint16;
	PSColor4ui16    = PSVertex4uint16;
{$ENDIF}

(*====================================================================*)
(*===========================16 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2int16}
{$DEFINE STRUCT_3     := TSVertex3int16}
{$DEFINE STRUCT_4     := TSVertex4int16}
{$DEFINE STRUCT_P_2   := PSVertex2int16}
{$DEFINE STRUCT_P_3   := PSVertex3int16}
{$DEFINE STRUCT_P_4   := PSVertex4int16}
{$DEFINE STRUCT_TYPE  := TSSmallInt}
{$DEFINE STRUCT_PTYPE := PSSmallInt}
{$DEFINE STRUCT_2_LIST:= TSVertex2int16List}
{$DEFINE STRUCT_3_LIST:= TSVertex3int16List}
{$DEFINE STRUCT_4_LIST:= TSVertex4int16List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2int16ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3int16ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4int16ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2int16Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3int16Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4int16Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2int16  = TSVertex2int16;
	TSVector2int16 = TSVertex2int16;
	TSColor2int16  = TSVertex2int16;
	
	TSVertex2i16   = TSVertex2int16;
	TSPoint2i16    = TSVertex2int16;
	TSVector2i16   = TSVertex2int16;
	TSColor2i16    = TSVertex2int16;
	
	TSPoint3int16  = TSVertex3int16;
	TSVector3int16 = TSVertex3int16;
	TSColor3int16  = TSVertex3int16;
	
	TSVertex3i16   = TSVertex3int16;
	TSPoint3i16    = TSVertex3int16;
	TSVector3i16   = TSVertex3int16;
	TSColor3i16    = TSVertex3int16;
	
	TSPoint4int16  = TSVertex4int16;
	TSVector4int16 = TSVertex4int16;
	TSColor4int16  = TSVertex4int16;
	
	TSVertex4i16   = TSVertex4int16;
	TSPoint4i16    = TSVertex4int16;
	TSVector4i16   = TSVertex4int16;
	TSColor4i16    = TSVertex4int16;
type
	PSPoint2int16  = PSVertex2int16;
	PSVector2int16 = PSVertex2int16;
	PSColor2int16  = PSVertex2int16;
	
	PSVertex2i16   = PSVertex2int16;
	PSPoint2i16    = PSVertex2int16;
	PSVector2i16   = PSVertex2int16;
	PSColor2i16    = PSVertex2int16;
	
	PSPoint3int16  = PSVertex3int16;
	PSVector3int16 = PSVertex3int16;
	PSColor3int16  = PSVertex3int16;
	
	PSVertex3i16   = PSVertex3int16;
	PSPoint3i16    = PSVertex3int16;
	PSVector3i16   = PSVertex3int16;
	PSColor3i16    = PSVertex3int16;
	
	PSPoint4int16  = PSVertex4int16;
	PSVector4int16 = PSVertex4int16;
	PSColor4int16  = PSVertex4int16;
	
	PSVertex4i16   = PSVertex4int16;
	PSPoint4i16    = PSVertex4int16;
	PSVector4i16   = PSVertex4int16;
	PSColor4i16    = PSVertex4int16;
{$ENDIF}

(*====================================================================*)
(*=========================8 bit, unsigned===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2uint8}
{$DEFINE STRUCT_3     := TSVertex3uint8}
{$DEFINE STRUCT_4     := TSVertex4uint8}
{$DEFINE STRUCT_P_2   := PSVertex2uint8}
{$DEFINE STRUCT_P_3   := PSVertex3uint8}
{$DEFINE STRUCT_P_4   := PSVertex4uint8}
{$DEFINE STRUCT_TYPE  := TSByte}
{$DEFINE STRUCT_PTYPE := PSByte}
{$DEFINE STRUCT_2_LIST:= TSVertex2uint8List}
{$DEFINE STRUCT_3_LIST:= TSVertex3uint8List}
{$DEFINE STRUCT_4_LIST:= TSVertex4uint8List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2uint8ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3uint8ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4uint8ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2uint8Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3uint8Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4uint8Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSVertex2b   = TSVertex2uint8;
	TSPoint2b    = TSVertex2uint8;
	TSVector2b   = TSVertex2uint8;
	TSColor2b    = TSVertex2uint8;
	
	TSVertex3b   = TSVertex3uint8;
	TSPoint3b    = TSVertex3uint8;
	TSVector3b   = TSVertex3uint8;
	TSColor3b    = TSVertex3uint8;
	
	TSVertex4b   = TSVertex4uint8;
	TSPoint4b    = TSVertex4uint8;
	TSVector4b   = TSVertex4uint8;
	TSColor4b    = TSVertex4uint8;
type
	
	PSVertex2b   = PSVertex2uint8;
	PSPoint2b    = PSVertex2uint8;
	PSVector2b   = PSVertex2uint8;
	PSColor2b    = PSVertex2uint8;
	
	
	PSVertex3b   = PSVertex3uint8;
	PSPoint3b    = PSVertex3uint8;
	PSVector3b   = PSVertex3uint8;
	PSColor3b    = PSVertex3uint8;
	
	PSVertex4b   = PSVertex4uint8;
	PSPoint4b    = PSVertex4uint8;
	PSVector4b   = PSVertex4uint8;
	PSColor4b    = PSVertex4uint8;
type
	TSPoint2uint8  = TSVertex2uint8;
	TSVector2uint8 = TSVertex2uint8;
	TSColor2uint8  = TSVertex2uint8;
	
	TSVertex2ui8   = TSVertex2uint8;
	TSPoint2ui8    = TSVertex2uint8;
	TSVector2ui8   = TSVertex2uint8;
	TSColor2ui8    = TSVertex2uint8;
	
	TSPoint3uint8  = TSVertex3uint8;
	TSVector3uint8 = TSVertex3uint8;
	TSColor3uint8  = TSVertex3uint8;
	
	TSVertex3ui8   = TSVertex3uint8;
	TSPoint3ui8    = TSVertex3uint8;
	TSVector3ui8   = TSVertex3uint8;
	TSColor3ui8    = TSVertex3uint8;
	
	TSPoint4uint8  = TSVertex4uint8;
	TSVector4uint8 = TSVertex4uint8;
	TSColor4uint8  = TSVertex4uint8;
	
	TSVertex4ui8   = TSVertex4uint8;
	TSPoint4ui8    = TSVertex4uint8;
	TSVector4ui8   = TSVertex4uint8;
	TSColor4ui8    = TSVertex4uint8;
type
	PSPoint2uint8  = PSVertex2uint8;
	PSVector2uint8 = PSVertex2uint8;
	PSColor2uint8  = PSVertex2uint8;
	
	PSVertex2ui8   = PSVertex2uint8;
	PSPoint2ui8    = PSVertex2uint8;
	PSVector2ui8   = PSVertex2uint8;
	PSColor2ui8    = PSVertex2uint8;
	
	PSPoint3uint8  = PSVertex3uint8;
	PSVector3uint8 = PSVertex3uint8;
	PSColor3uint8  = PSVertex3uint8;
	
	PSVertex3ui8   = PSVertex3uint8;
	PSPoint3ui8    = PSVertex3uint8;
	PSVector3ui8   = PSVertex3uint8;
	PSColor3ui8    = PSVertex3uint8;
	
	PSPoint4uint8  = PSVertex4uint8;
	PSVector4uint8 = PSVertex4uint8;
	PSColor4uint8  = PSVertex4uint8;
	
	PSVertex4ui8   = PSVertex4uint8;
	PSPoint4ui8    = PSVertex4uint8;
	PSVector4ui8   = PSVertex4uint8;
	PSColor4ui8    = PSVertex4uint8;
{$ENDIF}

(*====================================================================*)
(*===========================8 bit, signed===========================*)
(*====================================================================*)

{$DEFINE STRUCT_2     := TSVertex2int8}
{$DEFINE STRUCT_3     := TSVertex3int8}
{$DEFINE STRUCT_4     := TSVertex4int8}
{$DEFINE STRUCT_P_2   := PSVertex2int8}
{$DEFINE STRUCT_P_3   := PSVertex3int8}
{$DEFINE STRUCT_P_4   := PSVertex4int8}
{$DEFINE STRUCT_TYPE  := TSShortInt}
{$DEFINE STRUCT_PTYPE := PSShortInt}
{$DEFINE STRUCT_2_LIST:= TSVertex2int8List}
{$DEFINE STRUCT_3_LIST:= TSVertex3int8List}
{$DEFINE STRUCT_4_LIST:= TSVertex4int8List}
{$DEFINE STRUCT_2_LIST_HELPER := TSVertex2int8ListHelper}
{$DEFINE STRUCT_3_LIST_HELPER := TSVertex3int8ListHelper}
{$DEFINE STRUCT_4_LIST_HELPER := TSVertex4int8ListHelper}
{$DEFINE STRUCT_2_IMPORT_FUNC := SVertex2int8Import}
{$DEFINE STRUCT_3_IMPORT_FUNC := SVertex3int8Import}
{$DEFINE STRUCT_4_IMPORT_FUNC := SVertex4int8Import}
{$DEFINE STRUCT_IS_COLOR}
{$DEFINE STRUCT_IS_VERTEX}
{$DEFINE STRUCT_IS_TEX_VERTEX}
{$INCLUDE SmoothCommonStruct.inc}
{$INCLUDE SmoothCommonStructUndef.inc}
{$IFDEF INC_PLACE_INTERFACE}
type
	TSPoint2int8  = TSVertex2int8;
	TSVector2int8 = TSVertex2int8;
	TSColor2int8  = TSVertex2int8;
	
	TSVertex2i8   = TSVertex2int8;
	TSPoint2i8    = TSVertex2int8;
	TSVector2i8   = TSVertex2int8;
	TSColor2i8    = TSVertex2int8;
	
	TSPoint3int8  = TSVertex3int8;
	TSVector3int8 = TSVertex3int8;
	TSColor3int8  = TSVertex3int8;
	
	TSVertex3i8   = TSVertex3int8;
	TSPoint3i8    = TSVertex3int8;
	TSVector3i8   = TSVertex3int8;
	TSColor3i8    = TSVertex3int8;
	
	TSPoint4int8  = TSVertex4int8;
	TSVector4int8 = TSVertex4int8;
	TSColor4int8  = TSVertex4int8;
	
	TSVertex4i8   = TSVertex4int8;
	TSPoint4i8    = TSVertex4int8;
	TSVector4i8   = TSVertex4int8;
	TSColor4i8    = TSVertex4int8;
type
	PSPoint2int8  = PSVertex2int8;
	PSVector2int8 = PSVertex2int8;
	PSColor2int8  = PSVertex2int8;
	
	PSVertex2i8   = PSVertex2int8;
	PSPoint2i8    = PSVertex2int8;
	PSVector2i8   = PSVertex2int8;
	PSColor2i8    = PSVertex2int8;
	
	PSPoint3int8  = PSVertex3int8;
	PSVector3int8 = PSVertex3int8;
	PSColor3int8  = PSVertex3int8;
	
	PSVertex3i8   = PSVertex3int8;
	PSPoint3i8    = PSVertex3int8;
	PSVector3i8   = PSVertex3int8;
	PSColor3i8    = PSVertex3int8;
	
	PSPoint4int8  = PSVertex4int8;
	PSVector4int8 = PSVertex4int8;
	PSColor4int8  = PSVertex4int8;
	
	PSVertex4i8   = PSVertex4int8;
	PSPoint4i8    = PSVertex4int8;
	PSVector4i8   = PSVertex4int8;
	PSColor4i8    = PSVertex4int8;
{$ENDIF}
