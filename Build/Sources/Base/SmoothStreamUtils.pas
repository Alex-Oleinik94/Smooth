{$INCLUDE Smooth.inc}

unit SmoothStreamUtils;

interface

uses
	 SmoothBase
	,SmoothStringUtils
	
	,Classes
	;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSStreamList}
{$DEFINE DATATYPE             := TStream}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSMemoryStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSMemoryStreamList}
{$DEFINE DATATYPE             := TMemoryStream}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

function SStreamCopyMemory(const Stream : TStream) : TMemoryStream; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SCopyPartStreamToStream(const Source, Destination : TStream; const Size : TSUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SCopyPartStreamToStream(const Source : TStream; Destination : TMemoryStream; const Size : TSUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// TSString
function SReadStringInQuotesFromStream(const Stream : TStream; const Quote: TSChar = #39) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadPCharFromStream(const Stream : TStream) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadStringFromStream(const Stream : TStream; const Eolns : TSCharSet = [#0,#27,#13,#10]) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadLnStringFromStream(const Stream : TStream; const Eolns : TSCharSet = [#0,#27,#13,#10]) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SWriteStringToStream(const String1 : TSString; const Stream : TStream; const Stavit0 : TSBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStringToStream(const Str : TSString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SMatchingStreamString(const Stream : TStream; const Str : TSString; const DestroyingStream : TSBoolean = False) : TSBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SStreamToHexString(const Stream : TStream; const RegisterType : TSBoolean = False) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

type
	TSInputStreamType = (SInputFileStream, SInputMemoryStream);

function SCreateInputStream(const FileName : TSString; const InputStreamType : TSInputStreamType = SInputFileStream) : TStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SCreateMemoryStreamFromFile(const _FileName : TSString) : TMemoryStream;

procedure SKill(var Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
procedure SKill(var Stream : TMemoryStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
procedure SKill(var Stream : TFileStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;

implementation

uses
	 SmoothFileUtils
	;

function SCreateMemoryStreamFromFile(const _FileName : TSString) : TMemoryStream;
begin
if SFileExists(_FileName) then
	begin
	Result := TMemoryStream.Create();
	Result.LoadFromFile(_FileName);
	if (Result.Size > 0) then
		Result.Position := 0
	else
		SKill(Result);
	end
else
	Result := nil
end;

function SStreamCopyMemory(const Stream : TStream) : TMemoryStream; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Stream <> nil then
	begin
	Result := TMemoryStream.Create();
	Stream.Position := 0;
	SCopyPartStreamToStream(Stream, Result, Stream.Size);
	Result.Position := 0;
	end
else
	Result := nil;
end;

procedure SKill(var Stream : TStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
if Stream <> nil then
	begin
	Stream.Destroy();
	Stream := nil;
	end;
end;

procedure SKill(var Stream : TMemoryStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
if Stream <> nil then
	begin
	Stream.Destroy();
	Stream := nil;
	end;
end;

procedure SKill(var Stream : TFileStream); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
if Stream <> nil then
	begin
	Stream.Destroy();
	Stream := nil;
	end;
end;

function SCreateInputStream(const FileName : TSString; const InputStreamType : TSInputStreamType = SInputFileStream) : TStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

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
if SFileExists(FileName) then
	case InputStreamType of
	SInputFileStream   : Result := CreateInputFileStream();
	SInputMemoryStream : Result := CreateInputMemoryStream();
	end;
end;

procedure SCopyPartStreamToStream(const Source : TStream; Destination : TMemoryStream; const Size : TSUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	DestinationSizeBefore : TSUInt64;
	DestinationSizeAtfer : TSUInt64;
begin
if (Source <> nil) and (Destination <> nil) then
	begin
	DestinationSizeBefore := Destination.Size;
	DestinationSizeAtfer := Destination.Size + Size;
	Destination.Size := DestinationSizeAtfer;
	Source.ReadBuffer(PSByte(Destination.Memory)[DestinationSizeBefore], Size);
	Destination.Position := DestinationSizeAtfer;
	end;
end;

procedure SCopyPartStreamToStream(const Source, Destination : TStream; const Size : TSUInt64);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Point : PSByte;
begin
GetMem(Point, Size);
Source.ReadBuffer(Point^, Size);
Destination.WriteBuffer(Point^, Size);
FreeMem(Point, Size);
end;

// TSString

function SStreamToHexString(const Stream : TStream; const RegisterType : TSBoolean = False) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	ByteData : TSUInt8;
begin
Stream.Position := 0;
Result := '';
while Stream.Position <> Stream.Size do
	begin
	Stream.ReadBuffer(ByteData, 1);
	Result += SStrByteHex(ByteData, RegisterType);
	end;
Stream.Position := 0;
end;

function SMatchingStreamString(const Stream : TStream; const Str : TSString; const DestroyingStream : TSBoolean = False) : TSBool; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Str2 : TSString = '';
	C : TSChar;
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

function SStringToStream(const Str : TSString) : TMemoryStream; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := TMemoryStream.Create();
SWriteStringToStream(Str, Result, False);
end;

function SReadStringInQuotesFromStream(const Stream : TStream; const Quote: TSChar = #39) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar;
begin
Result := '';
Stream.ReadBuffer(C, SizeOf(C));
repeat
Stream.ReadBuffer(C, SizeOf(C));
if C <> Quote then
	Result += C;
until C = Quote;
end;

procedure SWriteStringToStream(const String1 : TSString; const Stream : TStream; const Stavit0 : TSBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar = #0;
begin
Stream.WriteBuffer(String1[1], Length(String1));
if Stavit0 then
	Stream.WriteBuffer(C, SizeOf(TSChar));
end;

function SReadLnStringFromStream(const Stream : TStream; const Eolns : TSCharSet = [#0,#27,#13,#10]) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar = #1;
	ToOut : TSBoolean = False;
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

function SReadPCharFromStream(const Stream : TStream) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar;
begin
Result := '';
repeat
Stream.Read(C, 1);
if C <> #0 then
	Result += C;
until C = #0;
end;

function SReadStringFromStream(const Stream : TStream; const Eolns : TSCharSet = [#0,#27,#13,#10]) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C : TSChar = #1;
	First : TSBool = True;
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
{$DEFINE DATATYPE_LIST_HELPER := TSStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSStreamList}
{$DEFINE DATATYPE             := TStream}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSMemoryStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSMemoryStreamList}
{$DEFINE DATATYPE             := TMemoryStream}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
