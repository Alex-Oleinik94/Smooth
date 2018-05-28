{$INCLUDE SaGe.inc}

unit SaGeTextLogStream;

interface

uses
	 SaGeBase
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
	 SaGeLog
	;

procedure TSGTextLogStream.WriteLn;
begin
SGLog.Source('', False);
end;

procedure TSGTextLogStream.Write(const StringToWrite : TSGString);
begin
SGLog.Source(StringToWrite, False, False);
end;

end.
