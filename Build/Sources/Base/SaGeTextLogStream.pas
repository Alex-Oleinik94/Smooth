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

procedure SGKill( var TextStream : TSGTextLogStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeLog
	;

procedure SGKill( var TextStream : TSGTextLogStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSGTextLogStream.WriteLn;
begin
SGLog.Source('', False);
end;

procedure TSGTextLogStream.Write(const StringToWrite : TSGString);
begin
SGLog.Source(StringToWrite, False, False);
end;

end.
