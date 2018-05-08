// SaGe Common lists initialization

{$DEFINE DATATYPE_LIST_HELPER := TSGStringListHelper}
{$DEFINE DATATYPE_LIST        := TSGStringList}
{$DEFINE DATATYPE             := TSGString}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGCharListHelper}
{$DEFINE DATATYPE_LIST        := TSGCharList}
{$DEFINE DATATYPE             := TSGChar}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGPointerListHelper}
{$DEFINE DATATYPE_LIST        := TSGPointerList}
{$DEFINE DATATYPE             := TSGPointer}
{$DEFINE WITHOUT_ASSIGNMENT}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGBooleanListHelper}
{$DEFINE DATATYPE_LIST        := TSGBooleanList}
{$DEFINE DATATYPE             := TSGBoolean}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$IFNDEF WITHOUT_EXTENDED}
{$DEFINE DATATYPE_LIST_HELPER := TSGFloat80ListHelper}
{$DEFINE DATATYPE_LIST        := TSGFloat80List}
{$DEFINE DATATYPE             := TSGFloat80}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$ENDIF WITHOUT_EXTENDED}

{$DEFINE DATATYPE_LIST_HELPER := TSGFloat64ListHelper}
{$DEFINE DATATYPE_LIST        := TSGFloat64List}
{$DEFINE DATATYPE             := TSGFloat64}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$IFDEF  INC_PLACE_INTERFACE}
type
	TSGMaxEnumList =
		{$IFNDEF WITHOUT_EXTENDED}
			TSGFloat80List
		{$ELSE WITHOUT_EXTENDED}
			TSGFloat64List
		{$ENDIF WITHOUT_EXTENDED}
		;
{$ENDIF  INC_PLACE_INTERFACE}

{$DEFINE DATATYPE_LIST_HELPER := TSGFloat32ListHelper}
{$DEFINE DATATYPE_LIST        := TSGFloat32List}
{$DEFINE DATATYPE             := TSGFloat32}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGUInt8ListHelper}
{$DEFINE DATATYPE_LIST        := TSGUInt8List}
{$DEFINE DATATYPE             := TSGUInt8}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInt8ListHelper}
{$DEFINE DATATYPE_LIST        := TSGInt8List}
{$DEFINE DATATYPE             := TSGInt8}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInt16ListHelper}
{$DEFINE DATATYPE_LIST        := TSGInt16List}
{$DEFINE DATATYPE             := TSGInt16}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGUInt16ListHelper}
{$DEFINE DATATYPE_LIST        := TSGUInt16List}
{$DEFINE DATATYPE             := TSGUInt16}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGUInt32ListHelper}
{$DEFINE DATATYPE_LIST        := TSGUInt32List}
{$DEFINE DATATYPE             := TSGUInt32}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInt32ListHelper}
{$DEFINE DATATYPE_LIST        := TSGInt32List}
{$DEFINE DATATYPE             := TSGInt32}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGUInt64ListHelper}
{$DEFINE DATATYPE_LIST        := TSGUInt64List}
{$DEFINE DATATYPE             := TSGUInt64}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInt64ListHelper}
{$DEFINE DATATYPE_LIST        := TSGInt64List}
{$DEFINE DATATYPE             := TSGInt64}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGSettingsHelper}
{$DEFINE DATATYPE_LIST        := TSGSettings}
{$DEFINE DATATYPE             := TSGOption}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGDoubleStringHelper}
{$DEFINE DATATYPE_LIST        := TSGDoubleStrings}
{$DEFINE DATATYPE             := TSGDoubleString}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}



