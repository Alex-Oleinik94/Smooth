{$INCLUDE SaGe.inc}

unit SaGeTextFileStream;

interface

uses
	 SaGeBase
	,SaGeCriticalSection
	,SaGeClasses
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

implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	,SaGeFileUtils
	;

procedure TSGTextFileStream.WriteLn();
begin
Write(FEoln);
end;

procedure TSGTextFileStream.Write(const StringToWrite : TSGString);
begin
FCriticalSection.Enter();
SGWriteStringToStream(StringToWrite, FStream, False);
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
