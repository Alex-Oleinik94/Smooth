{$INCLUDE SaGe.inc}

unit SaGeTextLogStream;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeTextStream
	
	,Classes
	;

type
	TSGTextLogStream = class(TSGTextStream)
			public
		procedure WriteLn(); override;
		procedure Write(const StringToWrite : TSGString); override;
		end;

implementation

uses
	 SaGeStreamUtils
	,SaGeFileUtils
	,SaGeLog
	;

procedure TSGTextLogStream.WriteLn;
begin
SGLog.Source(SGWinEoln, False);
end;

procedure TSGTextLogStream.Write(const StringToWrite : TSGString);
begin
SGLog.Source(StringToWrite, False);
end;

end.
