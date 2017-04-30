{$INCLUDE SaGe.inc}

unit SaGeCodeFileReader;

interface

uses
	 SaGeBase
	,SaGeTextFileReader
	;

type
	TSGQuoteType = (SGQuoteTypeNull, SGQuoteTypeComment, SGQuoteTypeText);
	TSGQuoteInfo = packed record 
		FQuotes : array [0..1] of TSGString;
		FType : TSGQuoteType;
		end;

operator = (const A, B : TSGQuoteInfo) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGQuotesInfoHelper}
{$DEFINE DATATYPE_LIST        := TSGQuotesInfo}
{$DEFINE DATATYPE             := TSGQuoteInfo}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF INC_PLACE_INTERFACE}

type
	TSGCodeFileReader = class(TSGTextFileReader)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FSeparators : TSGStringList;
		FIdentifierContent : TSGString;
		FQuotesInfo : TSGQuotesInfo;
		FOneLineCommentIdentifiers : TSGStringList;
		FSkipComments : TSGBoolean;
			public
		procedure SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : array of const); overload;
		procedure SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : TSGStringList ); overload;
		procedure SetSeparators(const SeparatorsList : array of const); overload;
		procedure SetSeparators(const SeparatorsList : TSGStringList ); overload;
		procedure SetIdentifierContent(const VIdentifierContent : TSGString);
		function ReadIdentifier() : TSGString;
		function ReadCommentString(const CommentQuotes : array of const; const EndQuote : TSGString) : TSGString; overload;
		function ReadCommentString(const CommentQuotes : TSGStringList; const EndQuote : TSGString) : TSGString; overload;
			public
		property SkipComments : TSGBoolean read FSkipComments write FSkipComments;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeLog
	,SaGeFileUtils
	
	,StrMan
	;

operator = (const A, B : TSGQuoteInfo) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
	(A.FQuotes[0] = B.FQuotes[0]) and
	(A.FQuotes[1] = B.FQuotes[1]) and
	(A.FType      = B.FType);
end;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGQuotesInfoHelper}
{$DEFINE DATATYPE_LIST        := TSGQuotesInfo}
{$DEFINE DATATYPE             := TSGQuoteInfo}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

constructor TSGCodeFileReader.Create();
begin
inherited;
FSeparators := nil;
FIdentifierContent := '';
FQuotesInfo := nil;
FOneLineCommentIdentifiers := nil;
FSkipComments := False;
end;

destructor TSGCodeFileReader.Destroy();
begin
SGKill(FSeparators);
SGKill(FQuotesInfo);
SGKill(FOneLineCommentIdentifiers);
inherited;
end;

procedure TSGCodeFileReader.SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : array of const); overload;
var
	List : TSGStringList;
begin
List := SGArConstToArString(OneLineCommentIdentifiersList);
SetOneLineCommentIdentifiers(List);
SGKill(List);
end;

procedure TSGCodeFileReader.SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : TSGStringList ); overload;
begin
SGKill(FOneLineCommentIdentifiers);
FOneLineCommentIdentifiers := OneLineCommentIdentifiersList.Copy();
end;

procedure TSGCodeFileReader.SetSeparators(const SeparatorsList : array of const); overload;
var
	List : TSGStringList;
begin
List := SGArConstToArString(SeparatorsList);
SetOneLineCommentIdentifiers(List);
SGKill(List);
end;

procedure TSGCodeFileReader.SetSeparators(const SeparatorsList : TSGStringList); overload;
begin
SGKill(FSeparators);
FSeparators := SeparatorsList.Copy();
end;

procedure TSGCodeFileReader.SetIdentifierContent(const VIdentifierContent : TSGString);
begin
FIdentifierContent := VIdentifierContent;
end;

function TSGCodeFileReader.ReadIdentifier() : TSGString;
begin

end;

function TSGCodeFileReader.ReadCommentString(const CommentQuotes : array of const; const EndQuote : TSGString) : TSGString; overload;
var
	List : TSGStringList;
begin
List := SGArConstToArString(CommentQuotes);
Result := ReadCommentString(List, EndQuote);
SGKill(List);
end;

function TSGCodeFileReader.ReadCommentString(const CommentQuotes : TSGStringList; const EndQuote : TSGString) : TSGString; overload;
begin

end;


end.
