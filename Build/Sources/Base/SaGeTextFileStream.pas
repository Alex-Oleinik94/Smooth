{$INCLUDE SaGe.inc}

unit SaGeTextFileStream;

interface

uses
	 SaGeBase
	,SaGeCriticalSection
	,SaGeClasses
	
	,Classes
	;

type
	TSGTextFileStream = class(TSGNamed)
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
		procedure Write(const StringToWrite : TSGString);
		procedure WriteLn(const StringToWrite : TSGString);
		procedure Write(const ValuesToWrite : array of const);
		procedure WriteLn(const ValuesToWrite : array of const);
		procedure WriteLn();
			public
		procedure WriteLines(const Strings : TSGStringList);
		procedure WriteLines(const Stream : TStream);
			public
		property Stream : TFileStream read FStream;
		property CriticalSection : TSGCriticalSection read FCriticalSection;
		property FileName : TSGString read FFileName;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	;

procedure TSGTextFileStream.WriteLn();
begin
Write(FEoln);
end;

procedure TSGTextFileStream.Write(const ValuesToWrite : array of const);
begin
Write(SGStr(ValuesToWrite));
end;

procedure TSGTextFileStream.WriteLn(const ValuesToWrite : array of const);
begin
Write(SGStr(ValuesToWrite) + FEoln);
end;

procedure TSGTextFileStream.WriteLines(const Strings : TSGStringList);
var
	Index : TSGMaxEnum;
begin
if (Strings <> nil) and (Length(Strings) > 0) then
	for Index := 0 to High(Strings) do
		WriteLn(Strings[Index]);
end;

procedure TSGTextFileStream.WriteLines(const Stream : TStream);
begin
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	WriteLn(SGReadLnStringFromStream(Stream));
Stream.Position := 0;
end;

procedure TSGTextFileStream.Write(const StringToWrite : TSGString);
begin
FCriticalSection.Enter();
SGWriteStringToStream(StringToWrite, FStream, False);
FCriticalSection.Leave();
end;

procedure TSGTextFileStream.WriteLn(const StringToWrite : TSGString);
begin
Write(StringToWrite + FEoln);
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
