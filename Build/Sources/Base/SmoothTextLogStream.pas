{$INCLUDE Smooth.inc}

unit SmoothTextLogStream;

interface

uses
	 SmoothBase
	,SmoothTextStream
	
	,Classes
	;

type
	TSTextLogStream = class(TSTextStream)
			public
		procedure WriteLn(); override;
		procedure Write(const S : TSString); override;
		end;

procedure SKill(var TextStream : TSTextLogStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothLog
	;

procedure SKill(var TextStream : TSTextLogStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextStream <> nil then
	begin
	TextStream.Destroy();
	TextStream := nil;
	end;
end;

procedure TSTextLogStream.WriteLn;
begin
SLog.Source('', False);
end;

procedure TSTextLogStream.Write(const S : TSString);
begin
SLog.Source(S, False, False);
end;

end.
