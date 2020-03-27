// Smooth Common lists initialization

{$DEFINE DATATYPE_LIST_HELPER := TSStringListHelper}
{$DEFINE DATATYPE_LIST        := TSStringList}
{$DEFINE DATATYPE             := TSString}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSCharListHelper}
{$DEFINE DATATYPE_LIST        := TSCharList}
{$DEFINE DATATYPE             := TSChar}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSPointerListHelper}
{$DEFINE DATATYPE_LIST        := TSPointerList}
{$DEFINE DATATYPE             := TSPointer}
{$DEFINE WITHOUT_ASSIGNMENT}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSBooleanListHelper}
{$DEFINE DATATYPE_LIST        := TSBooleanList}
{$DEFINE DATATYPE             := TSBoolean}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$IFNDEF WITHOUT_EXTENDED}
{$DEFINE DATATYPE_LIST_HELPER := TSFloat80ListHelper}
{$DEFINE DATATYPE_LIST        := TSFloat80List}
{$DEFINE DATATYPE             := TSFloat80}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$ENDIF WITHOUT_EXTENDED}

{$DEFINE DATATYPE_LIST_HELPER := TSFloat64ListHelper}
{$DEFINE DATATYPE_LIST        := TSFloat64List}
{$DEFINE DATATYPE             := TSFloat64}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$IFDEF  INC_PLACE_INTERFACE}
type
	TSMaxFloatList =
		{$IFNDEF WITHOUT_EXTENDED}
			TSFloat80List
		{$ELSE WITHOUT_EXTENDED}
			TSFloat64List
		{$ENDIF WITHOUT_EXTENDED}
		;
{$ENDIF  INC_PLACE_INTERFACE}

{$DEFINE DATATYPE_LIST_HELPER := TSFloat32ListHelper}
{$DEFINE DATATYPE_LIST        := TSFloat32List}
{$DEFINE DATATYPE             := TSFloat32}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSUInt8ListHelper}
{$DEFINE DATATYPE_LIST        := TSUInt8List}
{$DEFINE DATATYPE             := TSUInt8}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSInt8ListHelper}
{$DEFINE DATATYPE_LIST        := TSInt8List}
{$DEFINE DATATYPE             := TSInt8}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSInt16ListHelper}
{$DEFINE DATATYPE_LIST        := TSInt16List}
{$DEFINE DATATYPE             := TSInt16}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSUInt16ListHelper}
{$DEFINE DATATYPE_LIST        := TSUInt16List}
{$DEFINE DATATYPE             := TSUInt16}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSUInt32ListHelper}
{$DEFINE DATATYPE_LIST        := TSUInt32List}
{$DEFINE DATATYPE             := TSUInt32}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSInt32ListHelper}
{$DEFINE DATATYPE_LIST        := TSInt32List}
{$DEFINE DATATYPE             := TSInt32}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSUInt64ListHelper}
{$DEFINE DATATYPE_LIST        := TSUInt64List}
{$DEFINE DATATYPE             := TSUInt64}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSInt64ListHelper}
{$DEFINE DATATYPE_LIST        := TSInt64List}
{$DEFINE DATATYPE             := TSInt64}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$IFDEF  INC_PLACE_INTERFACE}
type
	TSMaxEnumList =
		{$IFDEF CPU64}
			TSUInt64List
		{$ELSE} {$IFDEF CPU32}
			TSUInt32List
		{$ELSE} {$IFDEF CPU16}
			TSUInt16List
		{$ENDIF}{$ENDIF}{$ENDIF}
		;
	TSMaxSignedEnumList =
		{$IFDEF CPU64}
			TSInt64List
		{$ELSE} {$IFDEF CPU32}
			TSInt32List
		{$ELSE} {$IFDEF CPU16}
			TSInt16List
		{$ENDIF}{$ENDIF}{$ENDIF}
		;
{$ENDIF  INC_PLACE_INTERFACE}

{$DEFINE DATATYPE_LIST_HELPER := TSSettingsHelper}
{$DEFINE DATATYPE_LIST        := TSSettings}
{$DEFINE DATATYPE             := TSOption}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSDoubleStringHelper}
{$DEFINE DATATYPE_LIST        := TSDoubleStrings}
{$DEFINE DATATYPE             := TSDoubleString}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}



