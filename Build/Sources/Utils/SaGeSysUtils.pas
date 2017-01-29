{$INCLUDE SaGe.inc}
{$DEFINE USE_uSMBIOS}

unit SaGeSysUtils;

interface

uses
	 Classes
	,SysUtils
	
	,SaGeBase
	,SaGeBased
	;

function SGGetCoreCount() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	{$IFDEF USE_uSMBIOS}
		,uSMBIOS
		{$ENDIF}
	;

function SGGetCoreCount() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFDEF USE_uSMBIOS}
Var
  SMBios             : TSMBios;
  LProcessorInfo     : TProcessorInformation;
{$ENDIF}
begin
Result:=0;
{$IFDEF USE_uSMBIOS}
try
	SMBios:=TSMBios.Create();
	if SMBios.HasProcessorInfo then
		for LProcessorInfo in SMBios.ProcessorInfo do
			if SMBios.SmbiosVersion >= '2.5' then
				Result:=LProcessorInfo.RAWProcessorInformation^.CoreCount;
finally
	SMBios.Free;
	end;
{$ENDIF}
end;

end.
