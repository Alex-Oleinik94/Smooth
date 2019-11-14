{$INCLUDE SaGe.inc}

unit SaGeTextMultiStream;

interface

uses
	 SaGeBase
	,SaGeTextStream
	,SaGeCasesOfPrint
	
	,Classes
	;

type
	TSGTextMultiStream = class(TSGTextStream)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		constructor Create(const CasesOfPrint : TSGCasesOfPrint);
			protected
		FOutputs : TSGTextStreamList;
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSGString); override;
		procedure TextColor(const Color : TSGUInt8); override;
			public
		procedure AddLog();
		procedure AddConsole();
		procedure AddFile(const FileName : TSGString);
		procedure Add(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]);
		function Get(const StreamClass : TSGTextStreamClass) : TSGTextStream;
		end;

procedure SGKill(var TextStream : TSGTextMultiStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeTextLogStream
	,SaGeTextFileStream
	,SaGeTextConsoleStream
	;

procedure SGKill(var TextStream : TSGTextMultiStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

function TSGTextMultiStream.Get(const StreamClass : TSGTextStreamClass) : TSGTextStream;
var
	Index : TSGMaxEnum;
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

constructor TSGTextMultiStream.Create(const CasesOfPrint : TSGCasesOfPrint);
begin
Create();
Add(CasesOfPrint);
end;

procedure TSGTextMultiStream.Add(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]);
begin
if SGCaseLog in CasesOfPrint then
	AddLog();
if SGCasePrint in CasesOfPrint then
	AddConsole();
end;

procedure TSGTextMultiStream.AddConsole();
begin
FOutputs += TSGTextConsoleStream.Create();
end;

procedure TSGTextMultiStream.AddFile(const FileName : TSGString);
begin
FOutputs += TSGTextFileStream.Create(FileName);
end;

procedure TSGTextMultiStream.AddLog();
begin
FOutputs += TSGTextLogStream.Create();
end;

constructor TSGTextMultiStream.Create();
begin
inherited;
FOutputs := nil;
end;

destructor TSGTextMultiStream.Destroy();
var
	Index : TSGMaxEnum;
begin
if (FOutputs <> nil) and (Length(FOutputs) > 0) then
	for Index := 0 to High(FOutputs) do
		if FOutputs[Index] <> nil then
			begin
			FOutputs[Index].Destroy();
			FOutputs[Index] := nil;
			end;
SGKill(FOutputs);
inherited;
end;

procedure TSGTextMultiStream.TextColor(const Color : TSGUInt8);
var
	TextStream : TSGTextStream;
begin
for TextStream in FOutputs do
	TextStream.TextColor(Color);
end;

procedure TSGTextMultiStream.WriteLn();
var
	TextStream : TSGTextStream;
begin
for TextStream in FOutputs do
	TextStream.WriteLn();
end;

procedure TSGTextMultiStream.Write(const StringToWrite : TSGString);
var
	TextStream : TSGTextStream;
begin
for TextStream in FOutputs do
	TextStream.Write(StringToWrite);
end;

end.
