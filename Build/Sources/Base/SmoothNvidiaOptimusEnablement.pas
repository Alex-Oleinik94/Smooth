{$INCLUDE Smooth.inc}

unit SmoothNvidiaOptimusEnablement;

interface

uses
	 SmoothBase
	;

// Method That Enable NVIDIA High Performance Graphics Rendering on Optimus Systems
// Global Variable NvOptimusEnablement (new in Driver Release 302)
var
	NvOptimusEnablement : TSUInt32 = $00000001; cvar;

implementation

exports NvOptimusEnablement;

initialization
begin
NvOptimusEnablement :=  $00000001;
end;

end.
