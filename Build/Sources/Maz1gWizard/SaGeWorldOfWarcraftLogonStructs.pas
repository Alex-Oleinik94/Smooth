{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftLogonStructs;

interface

uses
	 SaGeBase
	,SaGeInternetBase
	
	,Classes
	;
type
	TSGWOWSmallString = array[0..3] of TSGChar;
	TSGWOWVersion = object
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
	
	TSGWOW_ALC_Custom = object
			public
		Comand : TSGWOWLogonComand;
		Error : TSGWOWLogonError;
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
	
	TSGWOW_ALC = object(TSGWOW_ALC_Custom)
			public
		SRM_I : TSGString;
		end;

function SGIsAuthenticationLogonChallenge(const Stream : TStream) : TSGBoolean;

implementation

function SGIsAuthenticationLogonChallenge(const Stream : TStream) : TSGBoolean;
var
	Packet : TSGWOW_ALC;
begin
Result := False;
if (Stream.Size > SizeOf(TSGWOW_ALC_Custom)) then
	begin
	Stream.Position := 0;
	FillChar(Packet, SizeOf(Packet), 0);
	Stream.Read(Packet, SizeOf(TSGWOW_ALC_Custom));
	Result := Stream.Size = SizeOf(TSGWOW_ALC_Custom) + Packet.SRP_I_length;
	end;
end;

end.
