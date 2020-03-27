{$INCLUDE Smooth.inc}

unit SmoothCodeFileReader;

interface

uses
	 SmoothBase
	,SmoothTextFileReader
	;

type
	TSQuoteType = (SQuoteTypeNull, SQuoteTypeComment, SQuoteTypeText);
	TSQuoteInfo = packed record 
		FQuotes : array [0..1] of TSString;
		FType : TSQuoteType;
		end;

operator = (const A, B : TSQuoteInfo) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

{$DEFINE INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSQuotesInfoHelper}
{$DEFINE DATATYPE_LIST        := TSQuotesInfo}
{$DEFINE DATATYPE             := TSQuoteInfo}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_INTERFACE}

type
	TSCodeFileReader = class(TSTextFileReader)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FSeparators : TSStringList;
		FIdentifierContent : TSString;
		FQuotesInfo : TSQuotesInfo;
		FOneLineCommentIdentifiers : TSStringList;
		FSkipComments : TSBoolean;
			public
		procedure SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : array of const); overload;
		procedure SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : TSStringList ); overload;
		procedure SetSeparators(const SeparatorsList : array of const); overload;
		procedure SetSeparators(const SeparatorsList : TSStringList ); overload;
		procedure SetIdentifierContent(const VIdentifierContent : TSString);
		function ReadIdentifier() : TSString;
		function ReadCommentString(const CommentQuotes : array of const; const EndQuote : TSString) : TSString; overload;
		function ReadCommentString(const CommentQuotes : TSStringList; const EndQuote : TSString) : TSString; overload;
			public
		property SkipComments : TSBoolean read FSkipComments write FSkipComments;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	,SmoothFileUtils
	
	,StrMan
	;

operator = (const A, B : TSQuoteInfo) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := 
	(A.FQuotes[0] = B.FQuotes[0]) and
	(A.FQuotes[1] = B.FQuotes[1]) and
	(A.FType      = B.FType);
end;

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSQuotesInfoHelper}
{$DEFINE DATATYPE_LIST        := TSQuotesInfo}
{$DEFINE DATATYPE             := TSQuoteInfo}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

constructor TSCodeFileReader.Create();
begin
inherited;
FSeparators := nil;
FIdentifierContent := '';
FQuotesInfo := nil;
FOneLineCommentIdentifiers := nil;
FSkipComments := False;
end;

destructor TSCodeFileReader.Destroy();
begin
SKill(FSeparators);
SKill(FQuotesInfo);
SKill(FOneLineCommentIdentifiers);
inherited;
end;

procedure TSCodeFileReader.SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : array of const); overload;
var
	List : TSStringList;
begin
List := SArConstToArString(OneLineCommentIdentifiersList);
SetOneLineCommentIdentifiers(List);
SKill(List);
end;

procedure TSCodeFileReader.SetOneLineCommentIdentifiers(const OneLineCommentIdentifiersList : TSStringList ); overload;
begin
SKill(FOneLineCommentIdentifiers);
FOneLineCommentIdentifiers := OneLineCommentIdentifiersList.Copy();
end;

procedure TSCodeFileReader.SetSeparators(const SeparatorsList : array of const); overload;
var
	List : TSStringList;
begin
List := SArConstToArString(SeparatorsList);
SetOneLineCommentIdentifiers(List);
SKill(List);
end;

procedure TSCodeFileReader.SetSeparators(const SeparatorsList : TSStringList); overload;
begin
SKill(FSeparators);
FSeparators := SeparatorsList.Copy();
end;

procedure TSCodeFileReader.SetIdentifierContent(const VIdentifierContent : TSString);
begin
FIdentifierContent := VIdentifierContent;
end;

function TSCodeFileReader.ReadIdentifier() : TSString;
begin

end;

function TSCodeFileReader.ReadCommentString(const CommentQuotes : array of const; const EndQuote : TSString) : TSString; overload;
var
	List : TSStringList;
begin
List := SArConstToArString(CommentQuotes);
Result := ReadCommentString(List, EndQuote);
SKill(List);
end;

function TSCodeFileReader.ReadCommentString(const CommentQuotes : TSStringList; const EndQuote : TSString) : TSString; overload;
begin

end;


end.
