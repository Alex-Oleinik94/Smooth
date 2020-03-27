{$INCLUDE Smooth.inc}

unit SmoothTextStream;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothTextStreamInterface
	,SmoothLists
	
	,Classes
	;

type
	TSTextStream = class(TSNamed, ISTextStream)
			public
		procedure WriteLn(); virtual; abstract; overload;
		procedure WriteLn(const StringToWrite : TSString); virtual; overload;
		procedure WriteLn(const ValuesToWrite : array of const); virtual; overload;
		procedure Write(const StringToWrite : TSString); virtual; abstract; overload;
		procedure Write(const Value : TSUInt32); virtual; overload;
		procedure Write(const ValuesToWrite : array of const); virtual; overload;
		procedure TextColor(const Color : TSUInt8); virtual; // not abstract because may be not supported
		procedure Clear(); virtual; // not abstract because may be not supported
			public
		procedure WriteLines(const Strings : TSStringList); virtual; overload;
		procedure WriteLines(const Stream : TStream); virtual; overload;
		end;
	TSTextStreamClass = class of TSTextStream;

procedure SKill(var TextStream : TSTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSTextStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSTextStreamList}
{$DEFINE DATATYPE             := TSTextStream}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	;

procedure SKill(var TextStream : TSTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSTextStream.TextColor(const Color : TSUInt8);
begin
end;

procedure TSTextStream.Clear();
begin
end;

procedure TSTextStream.Write(const Value : TSUInt32);
begin
Write(SStr(Value));
end;

procedure TSTextStream.Write(const ValuesToWrite : array of const);
begin
Write(SStr(ValuesToWrite));
end;

procedure TSTextStream.WriteLn(const ValuesToWrite : array of const);
begin
Write(SStr(ValuesToWrite));
WriteLn();
end;

procedure TSTextStream.WriteLines(const Strings : TSStringList);
var
	Index : TSMaxEnum;
begin
if (Strings <> nil) and (Length(Strings) > 0) then
	for Index := 0 to High(Strings) do
		WriteLn(Strings[Index]);
end;

procedure TSTextStream.WriteLines(const Stream : TStream);
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	WriteLn(SReadLnStringFromStream(Stream));
Stream.Position := 0;
end;

procedure TSTextStream.WriteLn(const StringToWrite : TSString);
begin
Write(StringToWrite);
WriteLn();
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSTextStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSTextStreamList}
{$DEFINE DATATYPE             := TSTextStream}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
