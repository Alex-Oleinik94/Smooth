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
	SGWOWC_RL  = $10; // Realm list
type
	TSGWOWLogonComand = TSGUInt8;
	TSGWOWLogonError = TSGUInt8;
	TSGWOWLogonPacketSize = TSGUInt16;
	
	TSGWOW_Comand = packed object
			public
		Comand : TSGWOWLogonComand;
		end;
	
	TSGWOW_Error = packed object(TSGWOW_Comand)
			public
		Error : TSGWOWLogonError;
		end;
	
	TSGWOW_ALC_Client_HardData = packed object(TSGWOW_Error)
			public                            //	--> for example <--
		PacketSize : TSGWOWLogonPacketSize;   // 40
		GameName : TSGWOWSmallString;         // "WoW"
		Version  : TSGWOWVersion;             // 3 3 5, 12340
		Platform : TSGWOWSmallString;         // x86
		OperatingSystem : TSGWOWSmallString;  // "Win"
		Country  : TSGWOWSmallString;         // "ruRU"
		TimezoneBias : TSGUInt32;             // 180
		IPAddress : TSGIPv4Address;           // 192.168.0.5
		SRP_I_length : TSGUInt8;              // 10 ("LOGIN" string length); Next packet data is login, that size is this value
		end;
	
	TSGWOW_ALC_Client = packed object(TSGWOW_ALC_Client_HardData)
			public
		SRP_I : TSGString;                    // ("LOGIN")
		end;
	
	TSGWOW_Array32 = packed array[0..31] of TSGUInt8;
	TSGWOW_Array16 = packed array[0..15] of TSGUInt8;
	TSGWOW_Array20 = packed array[0..19] of TSGUInt8;
	
	TSGWOW_ALC_Server = packed object(TSGWOW_Error)
			public
		SRP_B : TSGWOW_Array32;
		SRP_g_length : TSGUInt8;
		SRP_g : PSGByte;
		SRP_N_length : TSGUInt8;
		SRP_N : PSGByte;
		SRP_s : TSGWOW_Array32;
		SRP_  : TSGWOW_Array16;
		end;
	
	TSGWOW_ALP_Client = packed object(TSGWOW_Comand)
			public
		SRP_A : TSGWOW_Array32;
		SRP_M1 : TSGWOW_Array20;
		CRC_hash : TSGWOW_Array20;
		Number_of_keys : TSGUInt8;
		end;
	
	TSGWOW_ALP_Server = packed object(TSGWOW_Error)
			public
		SRP_M2 : TSGWOW_Array20;
		end;
	
	TSGWOW_Realm = packed object
			public
		FType : TSGUInt8;
		Status : TSGUInt8;
		Color : TSGUInt8;
		Name : TSGString;
		Server_soket : TSGString;
		Population_level : TSGUInt32;
		Number_of_characters : TSGUInt8;
		Timezone : TSGUInt8;
		FSeparator : TSGUInt8;
		end;
	
	TSGWOW_Realms = packed array of TSGWOW_Realm;
	
	TSGWOW_RL = packed object(TSGWOW_Comand)
			public
		Packet_size : TSGUInt16;
		Number_of_realms : TSGUInt16;
		Realms : TSGWOW_Realms;
		end;

function SGIsAuthenticationLogonChallenge(const Stream : TStream) : TSGBoolean;
function SGReadAuthenticationLogonChallenge(const Stream : TStream) : TSGWOW_ALC_Client;
function SGStrSmallString(Text : TSGWOWSmallString) : TSGString; overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

function SGStrSmallString(Text : TSGWOWSmallString) : TSGString; overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSGUInt32;
	TempString : TSGString;
begin
TempString := Text;
Result := '';
for Index := Length(TempString) downto 1 do
	Result += TempString[Index];
TempString := '';
end;

function SGReadAuthenticationLogonChallenge(const Stream : TStream) : TSGWOW_ALC_Client;

function ReadString(const StringLength : TSGMaxEnum) : TSGString;
var
	Index : TSGMaxEnum;
	C : TSGChar;
begin
Result := '';
for Index := 1 to StringLength do
	begin
	Stream.Read(C, 1);
	Result += C;
	end;
end;

begin
FillChar(Result, SizeOf(Result), 0);
Stream.Position := 0;
Stream.Read(Result, SizeOf(TSGWOW_ALC_Client_HardData));
Result.SRP_I := ReadString(Result.SRP_I_length);
end;

function SGIsAuthenticationLogonChallenge(const Stream : TStream) : TSGBoolean;
var
	Packet : TSGWOW_ALC_Client_HardData;
	TotalSize : TSGMaxEnum;
begin
Result := False;
if (Stream.Size > SizeOf(TSGWOW_ALC_Client_HardData)) then
	begin
	Stream.Position := 0;
	FillChar(Packet, SizeOf(Packet), 0);
	Stream.Read(Packet, SizeOf(TSGWOW_ALC_Client_HardData));
	TotalSize := SizeOf(TSGWOW_ALC_Client_HardData) + Packet.SRP_I_length;
	Result := (Stream.Size = TotalSize);
	end;
end;

end.
