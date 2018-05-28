{$INCLUDE SaGe.inc}

unit SaGeNvidiaOptimusEnablement;

interface

uses
	 SaGeBase
	;

// Method That Enable NVIDIA High Performance Graphics Rendering on Optimus Systems
// Global Variable NvOptimusEnablement (new in Driver Release 302)
var
	NvOptimusEnablement : TSGUInt32 = $00000001; cvar;

implementation

exports NvOptimusEnablement;

initialization
begin
NvOptimusEnablement :=  $00000001;
end;

end.
