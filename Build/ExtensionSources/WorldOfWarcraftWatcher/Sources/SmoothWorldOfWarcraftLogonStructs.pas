//DEPRECATED

{$INCLUDE Smooth.inc}

unit SmoothWorldOfWarcraftLogonStructs;

interface

uses
	 SmoothBase
	,SmoothInternetBase
	
	,Classes
	;
type
	TSWOWSmallString = packed array[0..3] of TSChar;
	TSWOWVersion = packed object
			public
		FVersion : array[0..2] of TSUInt8;
		FBuildVersion : TSUInt16;
		end;
const
	SWOWC_ALC = $00; // Authentication Logon Challenge
	SWOWC_ALP = $01; // Authentication Logon Proof
	SWOWC_RL  = $10; // Realm list
type
	TSWOWLogonComand = TSUInt8;
	TSWOWLogonError = TSUInt8;
	TSWOWLogonPacketSize = TSUInt16;
	
	TSWOW_Comand = packed object
			public
		Comand : TSWOWLogonComand;
		end;
	
	TSWOW_Error = packed object(TSWOW_Comand)
			public
		Error : TSWOWLogonError;
		end;
	
	TSWOW_ALC_Client_HardData = packed object(TSWOW_Error)
			public                            //	--> for example <--
		PacketSize : TSWOWLogonPacketSize;   // 40
		GameName : TSWOWSmallString;         // "WoW"
		Version  : TSWOWVersion;             // 3 3 5, 12340
		Platform : TSWOWSmallString;         // x86
		OperatingSystem : TSWOWSmallString;  // "Win"
		Country  : TSWOWSmallString;         // "ruRU"
		TimezoneBias : TSUInt32;             // 180
		IPAddress : TSIPv4Address;           // 192.168.0.5
		SRP_I_length : TSUInt8;              // 10 ("LOGIN" string length); Next packet data is login, that size is this value
		end;
	
	TSWOW_ALC_Client = packed object(TSWOW_ALC_Client_HardData)
			public
		SRP_I : TSString;                    // ("LOGIN")
		end;
	
	TSWOW_Array32 = packed array[0..31] of TSUInt8;
	TSWOW_Array16 = packed array[0..15] of TSUInt8;
	TSWOW_Array20 = packed array[0..19] of TSUInt8;
	
	TSWOW_ALC_Server = packed object(TSWOW_Error)
			public                //	--> for example <--
		SRP_B : TSWOW_Array32;   // 0xcd:c5:75:bb:c0:af:8c:4b:02:54:88:97:0a:6d:9d:63:01:c8:8d:78:b3:2f:92:50:c7:f6:7d:c4:42:8a:59:53
		SRP_g_length : TSUInt8;  // 1
		SRP_g : PSByte;          // 0x07
		SRP_N_length : TSUInt8;  // 32
		SRP_N : PSByte;          // 0xb7:9b:3e:2a:87:82:3c:ab:8f:5e:bf:bf:8e:b1:01:08:53:50:06:29:8b:5b:ad:bd:5b:53:e1:89:5e:64:4b:89
		SRP_s : TSWOW_Array32;   // 0xc3:f7:b2:50:e6:4b:69:80:66:d5:b3:b7:cc:b4:02:eb:3d:11:c6:c1:f6:04:bf:ef:13:cf:9c:22:58:0b:28:95
		SRP_  : TSWOW_Array16;   // ?
		end;
	
	TSWOW_ALP_Client = packed object(TSWOW_Comand)
			public
		SRP_A : TSWOW_Array32;
		SRP_M1 : TSWOW_Array20;
		CRC_hash : TSWOW_Array20;
		Number_of_keys : TSUInt8;
		end;
	
	TSWOW_ALP_Server = packed object(TSWOW_Error)
			public
		SRP_M2 : TSWOW_Array20;
		end;
	
	TSWOW_Realm = packed object
			public
		FType : TSUInt8;
		Status : TSUInt8;
		Color : TSUInt8;
		Name : TSString;
		Server_soket : TSString;
		Population_level : TSUInt32;
		Number_of_characters : TSUInt8;
		Timezone : TSUInt8;
		FSeparator : TSUInt8;
		end;
	
	TSWOW_Realms = packed array of TSWOW_Realm;
	
	TSWOW_RL = packed object(TSWOW_Comand)
			public
		Packet_size : TSUInt16;
		Number_of_realms : TSUInt16;
		Realms : TSWOW_Realms;
		end;

function SIsAuthenticationLogonChallenge(const Stream : TStream) : TSBoolean;
function SReadClientAuthenticationLogonChallenge(const Stream : TStream) : TSWOW_ALC_Client;
function SReadServerAuthenticationLogonChallenge(const Stream : TStream) : TSWOW_ALC_Server;
function SStrSmallString(Text : TSWOWSmallString) : TSString; overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStrWoWArray(const _Data : PByte; const _Length : TSUInt8) : TSString;

implementation

uses
	 SmoothStringUtils
	;

function SStrWoWArray(const _Data : PByte; const _Length : TSUInt8) : TSString;
var
	Index : TSMaxEnum;
begin
Result := '';
for Index := 0 to _Length - 1 do
	Result += SStrByteHex(_Data[Index]);
end;

function SReadServerAuthenticationLogonChallenge(const Stream : TStream) : TSWOW_ALC_Server;

function ReadPByte(const _Length : TSUInt8) : PSByte;
begin
Result := GetMem(_Length);
Stream.Read(Result^, _Length);
end;

begin
FillChar(Result, SizeOf(Result), 0);
Stream.Position := 0;
Stream.Read(Result, SizeOf(TSWOW_Error));
Stream.Read(Result.SRP_B, SizeOf(TSWOW_Array32));
Stream.Read(Result.SRP_g_length, SizeOf(TSUInt8));
Result.SRP_g := ReadPByte(Result.SRP_g_length);
Stream.Read(Result.SRP_N_length, SizeOf(TSUInt8));
Result.SRP_N := ReadPByte(Result.SRP_N_length);
Stream.Read(Result.SRP_s, SizeOf(TSWOW_Array32));
Stream.Read(Result.SRP_, SizeOf(TSWOW_Array16));
end;

function SStrSmallString(Text : TSWOWSmallString) : TSString; overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSUInt32;
	TempString : TSString;
begin
TempString := Text;
Result := '';
for Index := Length(TempString) downto 1 do
	Result += TempString[Index];
TempString := '';
end;

function SReadClientAuthenticationLogonChallenge(const Stream : TStream) : TSWOW_ALC_Client;

function ReadString(const StringLength : TSMaxEnum) : TSString;
var
	Index : TSMaxEnum;
	C : TSChar;
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
Stream.Read(Result, SizeOf(TSWOW_ALC_Client_HardData));
Result.SRP_I := ReadString(Result.SRP_I_length);
end;

function SIsAuthenticationLogonChallenge(const Stream : TStream) : TSBoolean;
var
	Packet : TSWOW_ALC_Client_HardData;
	TotalSize : TSMaxEnum;
begin
Result := False;
if (Stream.Size > SizeOf(TSWOW_ALC_Client_HardData)) then
	begin
	Stream.Position := 0;
	FillChar(Packet, SizeOf(Packet), 0);
	Stream.Read(Packet, SizeOf(TSWOW_ALC_Client_HardData));
	TotalSize := SizeOf(TSWOW_ALC_Client_HardData) + Packet.SRP_I_length;
	Result := (Stream.Size = TotalSize);
	end;
end;

end.
