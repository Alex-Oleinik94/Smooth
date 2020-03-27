{$INCLUDE Smooth.inc}

unit SmoothTextMultiStream;

interface

uses
	 SmoothBase
	,SmoothTextStream
	,SmoothCasesOfPrint
	
	,Classes
	;

type
	TSTextMultiStream = class(TSTextStream)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		constructor Create(const CasesOfPrint : TSCasesOfPrint);
			protected
		FOutputs : TSTextStreamList;
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSString); override;
		procedure TextColor(const Color : TSUInt8); override;
			public
		procedure AddLog();
		procedure AddConsole();
		procedure AddFile(const FileName : TSString);
		procedure Add(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);
		function Get(const StreamClass : TSTextStreamClass) : TSTextStream;
		end;

procedure SKill(var TextStream : TSTextMultiStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothTextLogStream
	,SmoothTextFileStream
	,SmoothTextConsoleStream
	;

procedure SKill(var TextStream : TSTextMultiStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

function TSTextMultiStream.Get(const StreamClass : TSTextStreamClass) : TSTextStream;
var
	Index : TSMaxEnum;
begin
Result := nil;
if (FOutputs <> nil) and (Length(FOutputs) > 0) then
	for Index := 0 to High(FOutputs) do
		if (FOutputs[Index] is StreamClass) then
			begin
			Result := FOutputs[Index];
			break;
			end;
end;

constructor TSTextMultiStream.Create(const CasesOfPrint : TSCasesOfPrint);
begin
Create();
Add(CasesOfPrint);
end;

procedure TSTextMultiStream.Add(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);
begin
if SCaseLog in CasesOfPrint then
	AddLog();
if SCasePrint in CasesOfPrint then
	AddConsole();
end;

procedure TSTextMultiStream.AddConsole();
begin
FOutputs += TSTextConsoleStream.Create();
end;

procedure TSTextMultiStream.AddFile(const FileName : TSString);
begin
FOutputs += TSTextFileStream.Create(FileName);
end;

procedure TSTextMultiStream.AddLog();
begin
FOutputs += TSTextLogStream.Create();
end;

constructor TSTextMultiStream.Create();
begin
inherited;
FOutputs := nil;
end;

destructor TSTextMultiStream.Destroy();
var
	Index : TSMaxEnum;
begin
if (FOutputs <> nil) and (Length(FOutputs) > 0) then
	for Index := 0 to High(FOutputs) do
		if FOutputs[Index] <> nil then
			begin
			FOutputs[Index].Destroy();
			FOutputs[Index] := nil;
			end;
SKill(FOutputs);
inherited;
end;

procedure TSTextMultiStream.TextColor(const Color : TSUInt8);
var
	TextStream : TSTextStream;
begin
for TextStream in FOutputs do
	TextStream.TextColor(Color);
end;

procedure TSTextMultiStream.WriteLn();
var
	TextStream : TSTextStream;
begin
for TextStream in FOutputs do
	TextStream.WriteLn();
end;

procedure TSTextMultiStream.Write(const StringToWrite : TSString);
var
	TextStream : TSTextStream;
begin
for TextStream in FOutputs do
	TextStream.Write(StringToWrite);
end;

end.
