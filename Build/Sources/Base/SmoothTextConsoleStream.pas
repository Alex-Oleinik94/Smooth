{$INCLUDE Smooth.inc}

unit SmoothTextConsoleStream;

interface

uses
	 SmoothBase
	,SmoothTextStream
	
	,Classes
	;

type
	TSTextConsoleStream = class(TSTextStream)
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSString); override;
		procedure TextColor(const Color : TSUInt8); override;
		procedure Clear(); override;
		end;

procedure SKill(var TextStream : TSTextConsoleStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	,SmoothEncodingUtils
	;

procedure SKill(var TextStream : TSTextConsoleStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSTextConsoleStream.Clear();
begin
Crt.ClrScr();
end;

procedure TSTextConsoleStream.TextColor(const Color : TSUInt8);
begin
Crt.TextColor(Color);
end;

procedure TSTextConsoleStream.WriteLn;
begin
System.WriteLn();
end;

procedure TSTextConsoleStream.Write(const StringToWrite : TSString);
begin
System.Write(SConvertString(StringToWrite, SEncodingCP866));
end;

end.
