{$INCLUDE Smooth.inc}

unit SmoothStringTextStream;

interface

uses
	 SmoothBase
	,SmoothTextStream
	
	,Classes
	;

type
	TSStringTextStream = class(TSTextStream)
			public
		constructor Create(); override;
			protected
		FString : TSString;
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSString); override;
		procedure Clear(); override;
			public
		property Value : TSString read FString;
		end;

procedure SKill( var TextStream : TSStringTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothEncodingUtils
	;

procedure SKill( var TextStream : TSStringTextStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSStringTextStream.Clear();
begin
FString := '';
end;

constructor TSStringTextStream.Create();
begin
inherited;
Clear();
end;

procedure TSStringTextStream.WriteLn;
begin
end;

procedure TSStringTextStream.Write(const StringToWrite : TSString);
begin
FString += SConvertString(StringToWrite, SEncodingWIN1251);
end;

end.
