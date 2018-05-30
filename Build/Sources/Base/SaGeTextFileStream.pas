{$INCLUDE SaGe.inc}

unit SaGeTextFileStream;

interface

uses
	 SaGeBase
	,SaGeCriticalSection
	,SaGeTextStream
	
	,Classes
	;

type
	TSGTextFileStream = class(TSGTextStream)
			public
		constructor Create(const FileName : TSGString);
		destructor Destroy(); override;
		constructor Create(); override;
			private
		FFileName : TSGString;
		FCriticalSection : TSGCriticalSection;
		FStream : TFileStream;
		FEoln : TSGString;
		FEof : TSGString;
			public
		procedure Write(const StringToWrite : TSGString); override;
		procedure WriteLn(); override;
			public
		property FileStream : TFileStream read FStream;
		property Stream : TFileStream read FStream;
		property CriticalSection : TSGCriticalSection read FCriticalSection;
		property FileName : TSGString read FFileName;
		end;

procedure SGKill( var TextStream : TSGTextFileStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeEncodingUtils
	;

procedure SGKill( var TextStream : TSGTextFileStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSGTextFileStream.WriteLn();
begin
Write(FEoln);
end;

procedure TSGTextFileStream.Write(const StringToWrite : TSGString);
begin
FCriticalSection.Enter();
SGWriteStringToStream(SGConvertString(StringToWrite, SGEncodingWindows1251), FStream, False);
FCriticalSection.Leave();
end;

constructor TSGTextFileStream.Create(const FileName : TSGString);
begin
Create();
FFileName := FileName;
FStream := TFileStream.Create(FFileName, fmCreate);
FCriticalSection := TSGCriticalSection.Create();
end;

destructor TSGTextFileStream.Destroy();
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

constructor TSGTextFileStream.Create();
begin
inherited;
FStream := nil;
FCriticalSection := nil;
FFileName := '';
FEof := SGEof;
FEoln := SGWinEoln;
end;

end.
