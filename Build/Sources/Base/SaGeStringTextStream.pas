{$INCLUDE SaGe.inc}

unit SaGeStringTextStream;

interface

uses
	 SaGeBase
	,SaGeTextStream
	
	,Classes
	;

type
	TSGStringTextStream = class(TSGTextStream)
			public
		constructor Create(); override;
			protected
		FString : TSGString;
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSGString); override;
		procedure Clear(); override;
			public
		property Value : TSGString read FString;
		end;

procedure SGKill( var TextStream : TSGStringTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeEncodingUtils
	;

procedure SGKill( var TextStream : TSGStringTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSGStringTextStream.Clear();
begin
FString := '';
end;

constructor TSGStringTextStream.Create();
begin
inherited;
Clear();
end;

procedure TSGStringTextStream.WriteLn;
begin
end;

procedure TSGStringTextStream.Write(const StringToWrite : TSGString);
begin
FString += SGConvertString(StringToWrite, SGEncodingWIN1251);
end;

end.
