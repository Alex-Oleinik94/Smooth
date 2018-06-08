{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftLogonStructs;

interface

uses
	 SaGeBase
	,SaGeInternetBase
	
	,Classes
	;
type
	TSGWOWSmallString = packed array[0..3] of TSGChar;
	TSGWOWVersion = packed object
			public
		FVersion : array[0..2] of TSGUInt8;
		FBuildVersion : TSGUInt16;
		end;
const
	SGWOWC_ALC = $00; // Authentication Logon Challenge
	SGWOWC_ALP = $01; // Authentication Logon Proof
type
	TSGWOWLogonComand = TSGUInt8;
	TSGWOWLogonError = TSGUInt8;
	TSGWOWLogonPacketSize = TSGUInt16;
	
	TSGWOW_Comand = packed object
			public
		Comand : TSGWOWLogonComand;
		end;
	
	TSGWOW_ALC = packed object(TSGWOW_Comand)
			public
		Error : TSGWOWLogonError;
		end;
	
	TSGWOW_ALC_Client = packed object(TSGWOW_ALC)
			public
		PacketSize : TSGWOWLogonPacketSize;
		GameName : TSGWOWSmallString;
		Version  : TSGWOWVersion;
		Platform : TSGWOWSmallString;
		OperatingSystem : TSGWOWSmallString;
		Country  : TSGWOWSmallString;
		TimezoneBias : TSGUInt32;
		IPAddress : TSGIPv4Address;
		SRP_I_length : TSGUInt8;
		end;
	
	TSGWOW_ALC_Client_Full = packed object(TSGWOW_ALC_Client)
			public
		SRP_I : TSGString;
		end;
	
	TSGWOW_ALC_Array = packed array[0..31] of TSGUInt8;
	
	TSGWOW_ALC_Server = packed object(TSGWOW_ALC)
			public
		
		end;

function SGIsAuthenticationLogonChallenge(const Stream : TStream) : TSGBoolean;

implementation

function SGIsAuthenticationLogonChallenge(const Stream : TStream) : TSGBoolean;
var
	Packet : TSGWOW_ALC_Client;
	TotalSize : TSGMaxEnum;
begin
Result := False;
if (Stream.Size > SizeOf(TSGWOW_ALC_Client)) then
	begin
	Stream.Position := 0;
	FillChar(Packet, SizeOf(Packet), 0);
	Stream.Read(Packet, SizeOf(TSGWOW_ALC_Client));
	TotalSize := SizeOf(TSGWOW_ALC_Client) + Packet.SRP_I_length;
	Result := (Stream.Size = TotalSize);
	end;
end;

end.
