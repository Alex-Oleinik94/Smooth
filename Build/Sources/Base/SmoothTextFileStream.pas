{$INCLUDE Smooth.inc}

unit SmoothTextFileStream;

interface

uses
	 SmoothBase
	,SmoothCriticalSection
	,SmoothTextStream
	
	,Classes
	;

type
	TSTextFileStream = class(TSTextStream)
			public
		constructor Create(const FileName : TSString);
		destructor Destroy(); override;
		constructor Create(); override;
			private
		FFileName : TSString;
		FCriticalSection : TSCriticalSection;
		FStream : TFileStream;
		FEoln : TSString;
		FEof : TSString;
			public
		procedure Write(const StringToWrite : TSString); override;
		procedure WriteLn(); override;
			public
		property FileStream : TFileStream read FStream;
		property Stream : TFileStream read FStream;
		property CriticalSection : TSCriticalSection read FCriticalSection;
		property FileName : TSString read FFileName;
		end;

procedure SKill(var TextStream : TSTextFileStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothEncodingUtils
	;

procedure SKill(var TextStream : TSTextFileStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSTextFileStream.WriteLn();
begin
Write(FEoln);
end;

procedure TSTextFileStream.Write(const StringToWrite : TSString);
begin
FCriticalSection.Enter();
SWriteStringToStream(SConvertString(StringToWrite, SEncodingWindows1251), FStream, False);
FCriticalSection.Leave();
end;

constructor TSTextFileStream.Create(const FileName : TSString);
begin
Create();
FFileName := FileName;
FStream := TFileStream.Create(FFileName, fmCreate);
FCriticalSection := TSCriticalSection.Create();
end;

destructor TSTextFileStream.Destroy();
begin
if FStream <> nil then
	begin
	Write(FEof);
	FStream.Destroy();
	FStream := nil;
	end;
if FCriticalSection <> nil then
	begin
	FCriticalSection.Destroy();
	FCriticalSection := nil;
	end;
FFileName := '';
FEof := '';
FEoln := '';
inherited;
end;

constructor TSTextFileStream.Create();
begin
inherited;
FStream := nil;
FCriticalSection := nil;
FFileName := '';
FEof := SEof;
FEoln := SWinEoln;
end;

end.
