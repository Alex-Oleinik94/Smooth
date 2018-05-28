{$INCLUDE SaGe.inc}

unit SaGeTextConsoleStream;

interface

uses
	 SaGeBase
	,SaGeTextStream
	
	,Classes
	;

type
	TSGTextConsoleStream = class(TSGTextStream)
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSGString); override;
		procedure TextColor(const Color : TSGUInt8); override;
		end;

implementation

uses
	 Crt
	,SaGeEncodingUtils
	;

procedure TSGTextConsoleStream.TextColor(const Color : TSGUInt8);
begin
Crt.TextColor(Color);
end;

procedure TSGTextConsoleStream.WriteLn;
begin
System.WriteLn();
end;

procedure TSGTextConsoleStream.Write(const StringToWrite : TSGString);
begin
System.Write(SGConvertString(StringToWrite, SGEncodingCP866));
end;

end.
