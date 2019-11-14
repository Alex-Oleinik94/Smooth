{$INCLUDE SaGe.inc}

unit SaGeTextStream;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeTextStreamInterface
	,SaGeLists
	
	,Classes
	;

type
	TSGTextStream = class(TSGNamed, ISGTextStream)
			public
		procedure WriteLn(); virtual; abstract; overload;
		procedure WriteLn(const StringToWrite : TSGString); virtual; overload;
		procedure WriteLn(const ValuesToWrite : array of const); virtual; overload;
		procedure Write(const StringToWrite : TSGString); virtual; abstract; overload;
		procedure Write(const Value : TSGUInt32); virtual; overload;
		procedure Write(const ValuesToWrite : array of const); virtual; overload;
		procedure TextColor(const Color : TSGUInt8); virtual; // not abstract because may be not supported
		procedure Clear(); virtual; // not abstract because may be not supported
			public
		procedure WriteLines(const Strings : TSGStringList); virtual; overload;
		procedure WriteLines(const Stream : TStream); virtual; overload;
		end;
	TSGTextStreamClass = class of TSGTextStream;

procedure SGKill(var TextStream : TSGTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGTextStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSGTextStreamList}
{$DEFINE DATATYPE             := TSGTextStream}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	;

procedure SGKill(var TextStream : TSGTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSGTextStream.TextColor(const Color : TSGUInt8);
begin
end;

procedure TSGTextStream.Clear();
begin
end;

procedure TSGTextStream.Write(const Value : TSGUInt32);
begin
Write(SGStr(Value));
end;

procedure TSGTextStream.Write(const ValuesToWrite : array of const);
begin
Write(SGStr(ValuesToWrite));
end;

procedure TSGTextStream.WriteLn(const ValuesToWrite : array of const);
begin
Write(SGStr(ValuesToWrite));
WriteLn();
end;

procedure TSGTextStream.WriteLines(const Strings : TSGStringList);
var
	Index : TSGMaxEnum;
begin
if (Strings <> nil) and (Length(Strings) > 0) then
	for Index := 0 to High(Strings) do
		WriteLn(Strings[Index]);
end;

procedure TSGTextStream.WriteLines(const Stream : TStream);
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	WriteLn(SGReadLnStringFromStream(Stream));
Stream.Position := 0;
end;

procedure TSGTextStream.WriteLn(const StringToWrite : TSGString);
begin
Write(StringToWrite);
WriteLn();
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGTextStreamListHelper}
{$DEFINE DATATYPE_LIST        := TSGTextStreamList}
{$DEFINE DATATYPE             := TSGTextStream}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
