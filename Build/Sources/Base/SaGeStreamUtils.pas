{$INCLUDE SaGe.inc}

unit SaGeStreamUtils;

interface

uses
	 SaGeBase
	,SaGeStringUtils
	
	,Classes
	;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSGStreamList}
{$DEFINE DATATYPE             := TStream}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGMemoryStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSGMemoryStreamList}
{$DEFINE DATATYPE             := TMemoryStream}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

function SGStreamCopyMemory(const Stream : TStream) : TMemoryStream; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGCopyPartStreamToStream(const Source, Destination : TStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGCopyPartStreamToStream(const Source : TStream; Destination : TMemoryStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// TSGString
function SGReadStringInQuotesFromStream(const Stream : TStream; const Quote: TSGChar = #39) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadPCharFromStream(const Stream : TStream) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGReadLnStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGWriteStringToStream(const String1 : TSGString; const Stream : TStream; const Stavit0 : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStringToStream(const Str : TSGString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGMatchingStreamString(const Stream : TStream; const Str : TSGString; const DestroyingStream : TSGBoolean = False) : TSGBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGStreamToHexString(const Stream : TStream; const RegisterType : TSGBoolean = False) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

type
	TSGInputStreamType = (SGInputFileStream, SGInputMemoryStream);

function SGCreateInputStream(const FileName : TSGString; const InputStreamType : TSGInputStreamType = SGInputFileStream) : TStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGCreateMemoryStreamFromFile(const _FileName : TSGString) : TMemoryStream;

procedure SGKill(var Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
procedure SGKill(var Stream : TMemoryStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
procedure SGKill(var Stream : TFileStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;

implementation

uses
	 SaGeFileUtils
	;

function SGCreateMemoryStreamFromFile(const _FileName : TSGString) : TMemoryStream;
begin
if SGFileExists(_FileName) then
	begin
	Result := TMemoryStream.Create();
	Result.LoadFromFile(_FileName);
	if (Result.Size > 0) then
		Result.Position := 0
	else
		SGKill(Result);
	end
else
	Result := nil
end;

function SGStreamCopyMemory(const Stream : TStream) : TMemoryStream; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Stream <> nil then
	begin
	Result := TMemoryStream.Create();
	Stream.Position := 0;
	SGCopyPartStreamToStream(Stream, Result, Stream.Size);
	Result.Position := 0;
	end
else
	Result := nil;
end;

procedure SGKill(var Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
if Stream <> nil then
	begin
	Stream.Destroy();
	Stream := nil;
	end;
end;

procedure SGKill(var Stream : TMemoryStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
if Stream <> nil then
	begin
	Stream.Destroy();
	Stream := nil;
	end;
end;

procedure SGKill(var Stream : TFileStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
if Stream <> nil then
	begin
	Stream.Destroy();
	Stream := nil;
	end;
end;

function SGCreateInputStream(const FileName : TSGString; const InputStreamType : TSGInputStreamType = SGInputFileStream) : TStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

function CreateInputFileStream() : TFileStream;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := TFileStream.Create(FileName, fmOpenRead);
end;

function CreateInputMemoryStream() : TMemoryStream;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := TMemoryStream.Create();
Result.LoadFromFile(FileName);
Result.Position := 0;
end;

begin
Result := nil;
if SGFileExists(FileName) then
	case InputStreamType of
	SGInputFileStream   : Result := CreateInputFileStream();
	SGInputMemoryStream : Result := CreateInputMemoryStream();
	end;
end;

procedure SGCopyPartStreamToStream(const Source : TStream; Destination : TMemoryStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	DestinationSizeBefore : TSGUInt64;
	DestinationSizeAtfer : TSGUInt64;
begin
if (Source <> nil) and (Destination <> nil) then
	begin
	DestinationSizeBefore := Destination.Size;
	DestinationSizeAtfer := Destination.Size + Size;
	Destination.Size := DestinationSizeAtfer;
	Source.ReadBuffer(PSGByte(Destination.Memory)[DestinationSizeBefore], Size);
	Destination.Position := DestinationSizeAtfer;
	end;
end;

procedure SGCopyPartStreamToStream(const Source, Destination : TStream; const Size : TSGUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Point : PSGByte;
begin
GetMem(Point, Size);
Source.ReadBuffer(Point^, Size);
Destination.WriteBuffer(Point^, Size);
FreeMem(Point, Size);
end;

// TSGString

function SGStreamToHexString(const Stream : TStream; const RegisterType : TSGBoolean = False) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	ByteData : TSGUInt8;
begin
Stream.Position := 0;
Result := '';
while Stream.Position <> Stream.Size do
	begin
	Stream.ReadBuffer(ByteData, 1);
	Result += SGStrByteHex(ByteData, RegisterType);
	end;
Stream.Position := 0;
end;

function SGMatchingStreamString(const Stream : TStream; const Str : TSGString; const DestroyingStream : TSGBoolean = False) : TSGBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Str2 : TSGString = '';
	C : TSGChar;
begin
Result := False;
while (Stream.Size <> Stream.Position) and (Length(Str2) < Length(Str)) do
	begin
	Stream.Read(C, 1);
	Str2 += C;
	end;
Result := Str2 = Str;
if DestroyingStream then
	Stream.Destroy();
end;

function SGStringToStream(const Str : TSGString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := TMemoryStream.Create();
SGWriteStringToStream(Str, Result, False);
end;

function SGReadStringInQuotesFromStream(const Stream : TStream; const Quote: TSGChar = #39) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar;
begin
Result := '';
Stream.ReadBuffer(C, SizeOf(C));
repeat
Stream.ReadBuffer(C, SizeOf(C));
if C <> Quote then
	Result += C;
until C = Quote;
end;

procedure SGWriteStringToStream(const String1 : TSGString; const Stream : TStream; const Stavit0 : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #0;
begin
Stream.WriteBuffer(String1[1], Length(String1));
if Stavit0 then
	Stream.WriteBuffer(C, SizeOf(TSGChar));
end;

function SGReadLnStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #1;
	ToOut : TSGBoolean = False;
begin
Result:='';
while (Stream.Position < Stream.Size) and ((not ToOut) or (C in Eolns))  do
	begin
	Stream.ReadBuffer(c, 1);
	if (C in Eolns) then
		ToOut := True
	else if (not ToOut) then
		Result += c;
	end;
if Stream.Position <> Stream.Size then
	Stream.Position := Stream.Position - 1;
end;

function SGReadPCharFromStream(const Stream : TStream) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar;
begin
Result := '';
repeat
Stream.Read(C, 1);
if C <> #0 then
	Result += C;
until C = #0;
end;

function SGReadStringFromStream(const Stream : TStream; const Eolns : TSGCharSet = [#0,#27,#13,#10]) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSGChar = #1;
	First : TSGBool = True;
begin
Result:='';
while ((not (C in Eolns)) or First) and (Stream.Position <> Stream.Size) do
	begin
	Stream.ReadBuffer(C, 1);
	if not (C in Eolns) then
		Result += C;
	First := False;
	end;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSGStreamList}
{$DEFINE DATATYPE             := TStream}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGMemoryStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSGMemoryStreamList}
{$DEFINE DATATYPE             := TMemoryStream}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
