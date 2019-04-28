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
			public                //	--> for example <--
		SRP_B : TSGWOW_Array32;   // 0xcd:c5:75:bb:c0:af:8c:4b:02:54:88:97:0a:6d:9d:63:01:c8:8d:78:b3:2f:92:50:c7:f6:7d:c4:42:8a:59:53
		SRP_g_length : TSGUInt8;  // 1
		SRP_g : PSGByte;          // 0x07
		SRP_N_length : TSGUInt8;  // 32
		SRP_N : PSGByte;          // 0xb7:9b:3e:2a:87:82:3c:ab:8f:5e:bf:bf:8e:b1:01:08:53:50:06:29:8b:5b:ad:bd:5b:53:e1:89:5e:64:4b:89
		SRP_s : TSGWOW_Array32;   // 0xc3:f7:b2:50:e6:4b:69:80:66:d5:b3:b7:cc:b4:02:eb:3d:11:c6:c1:f6:04:bf:ef:13:cf:9c:22:58:0b:28:95
		SRP_  : TSGWOW_Array16;   // ?
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
function SGReadClientAuthenticationLogonChallenge(const Stream : TStream) : TSGWOW_ALC_Client;
function SGReadServerAuthenticationLogonChallenge(const Stream : TStream) : TSGWOW_ALC_Server;
function SGStrSmallString(Text : TSGWOWSmallString) : TSGString; overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStrWoWArray(const _Data : PByte; const _Length : TSGUInt8) : TSGString;

implementation

uses
	 SaGeStringUtils
	;

function SGStrWoWArray(const _Data : PByte; const _Length : TSGUInt8) : TSGString;
var
	Index : TSGMaxEnum;
begin
Result := '';
for Index := 0 to _Length - 1 do
	Result += SGStrByteHex(_Data[Index]);
end;

function SGReadServerAuthenticationLogonChallenge(const Stream : TStream) : TSGWOW_ALC_Server;

function ReadPByte(const _Length : TSGUInt8) : PSGByte;
begin
Result := GetMem(_Length);
Stream.Read(Result^, _Length);
end;

begin
FillChar(Result, SizeOf(Result), 0);
Stream.Position := 0;
Stream.Read(Result, SizeOf(TSGWOW_Error));
Stream.Read(Result.SRP_B, SizeOf(TSGWOW_Array32));
Stream.Read(Result.SRP_g_length, SizeOf(TSGUInt8));
Result.SRP_g := ReadPByte(Result.SRP_g_length);
Stream.Read(Result.SRP_N_length, SizeOf(TSGUInt8));
Result.SRP_N := ReadPByte(Result.SRP_N_length);
Stream.Read(Result.SRP_s, SizeOf(TSGWOW_Array32));
Stream.Read(Result.SRP_, SizeOf(TSGWOW_Array16));
end;

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

function SGReadClientAuthenticationLogonChallenge(const Stream : TStream) : TSGWOW_ALC_Client;

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
