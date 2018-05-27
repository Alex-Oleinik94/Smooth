{$INCLUDE SaGe.inc}

unit SaGeTextMultiStream;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeTextStream
	
	,Classes
	;

type
	TSGTextMultiStream = class(TSGTextStream)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FOutputs : TSGTextStreamList;
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSGString); override;
			public
		procedure AddLog();
		procedure AddConsole();
		procedure AddFile(const FileName : TSGString);
		end;

implementation

uses
	 SaGeTextLogStream
	,SaGeTextFileStream
	;

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
begin
SGKill(FOutputs);
inherited;
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
