{$INCLUDE SaGe.inc}

unit SaGeTextStream;

interface

uses
	 SaGeBase
	,SaGeClasses
	
	,Classes
	;

type
	ISGTextStream = interface(ISGInterface)
		['{9bf4a36d-9767-4a2e-8a97-6cb95bb1ecef}']
		procedure WriteLn();
		procedure Write(const StringToWrite : TSGString);
		procedure TextColor(const Color : TSGUInt8);
		end;
	
	TSGTextStream = class(TSGNamed, ISGTextStream)
			public
		procedure WriteLn(); virtual; abstract; overload;
		procedure WriteLn(const StringToWrite : TSGString); virtual; overload;
		procedure WriteLn(const ValuesToWrite : array of const); virtual; overload;
		procedure Write(const StringToWrite : TSGString); virtual; abstract; overload;
		procedure Write(const ValuesToWrite : array of const); virtual; overload;
		procedure TextColor(const Color : TSGUInt8); virtual; overload; // not abstract becouse may be not suported
			public
		procedure WriteLines(const Strings : TSGStringList); virtual; overload;
		procedure WriteLines(const Stream : TStream); virtual; overload;
		end;

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

procedure TSGTextStream.TextColor(const Color : TSGUInt8);
begin
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
