{$INCLUDE SaGe.inc}

unit SaGeInternetBase;

interface

uses
	 SaGeBase
	;


const
	// Ethernet headers are always exactly 14 bytes
	SG_ETHERNET_HEADER_SIZE = 14;
	// Ethernet addresses are 6 bytes
	SG_ETHERNET_ADDRESS_SIZE = 6;

// Ethernet header
type 
	TSGEnthernetAddress = packed array[0..SG_ETHERNET_ADDRESS_SIZE-1] of TSGUInt8;
	TSGEnthernetProtocol = TSGUInt16;
	PSGEnthernetProtocolBytes = ^ TSGEnthernetProtocolBytes;
	TSGEnthernetProtocolBytes = packed array [0..1] of TSGUInt8;
	
	PSGEthernetHeader = ^ TSGEthernetHeader;
	TSGEthernetHeader = object
			public
		Destination   : TSGEnthernetAddress;       // Destination host address
		Source        : TSGEnthernetAddress;       // Source host address
		ProtocolBytes : TSGEnthernetProtocolBytes; // IP? ARP? RARP? etc
			private
		function GetProtocol() : TSGEnthernetProtocol;
			public
		property Protocol : TSGEnthernetProtocol read GetProtocol;
		end;

function SGEthernetProtocolToString(const Protocol : TSGEnthernetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGEthernetAddesssToString(const Address : TSGEnthernetAddress) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGEthernetProtocolToStringExtended(const Protocol : TSGEnthernetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Ethernet protocols
const
	SGEP_IPv4      = $0800; //Internet Protocol version 4 (IPv4)
	SGEP_ARP       = $0806; //Address Resolution Protocol (ARP)
	SGEP_WoL       = $0842; //Wake-on-LAN
	SGEP_TRILL     = $22F3; //IETF TRILL Protocol
	SGEP_SRP       = $22EA; //Stream Reservation Protocol
	SGEP_DECnet    = $6003; //DECnet Phase IV
	SGEP_RARP      = $8035; //Reverse Address Resolution Protocol
	SGEP_AT        = $809B; //AppleTalk (Ethertalk)
	SGEP_AARP      = $80F3; //AppleTalk Address Resolution Protocol (AARP)
	SGEP_IEEE_VLAN_NNI = $8100; //VLAN-tagged frame (IEEE 802.1Q) and Shortest Path Bridging IEEE 802.1aq with NNI compatibility
	SGEP_IPX       = $8137; //Internetwork Packet Exchange (IPX)
	SGEP_QNX       = $8204; //QNX Qnet
	SGEP_IPv6      = $86DD; //Internet Protocol Version 6 (IPv6)
	SGEP_Efc       = $8808; //Ethernet flow control
	SGEP_ESP       = $8809; //Ethernet Slow Protocols
	SGEP_CN        = $8819; //CobraNet
	SGEP_MPLSu     = $8847; //MPLS unicast
	SGEP_MPLSm     = $8848; //MPLS multicast
	SGEP_PPPoE_DS  = $8863; //PPPoE Discovery Stage
	SGEP_PPPoE_SS  = $8864; //PPPoE Session Stage
	SGEP_IANS      = $886D; //Intel Advanced Networking Services
	SGEP_JF        = $8870; //Jumbo Frames (Obsoleted draft-ietf-isis-ext-eth-01)
	SGEP_HPv1      = $887B; //HomePlug 1.0 MME
	SGEP_EAPoL     = $888E; //EAP over LAN (IEEE 802.1X)
	SGEP_PI        = $8892; //PROFINET Protocol
	SGEP_HSCSI     = $889A; //HyperSCSI (SCSI over Ethernet)
	SGEP_ATAoE     = $88A2; //ATA over Ethernet
	SGEP_EC        = $88A4; //EtherCAT Protocol
	SGEP_IEEE_PB   = $88A8; //Provider Bridging (IEEE 802.1ad) & Shortest Path Bridging IEEE 802.1aq
	SGEP_EP        = $88AB; //Ethernet Powerlink
	SGEP_GOOSE     = $88B8; //GOOSE (Generic Object Oriented Substation event)
	SGEP_GSEMS     = $88B9; //GSE (Generic Substation Events) Management Services
	SGEP_SVT       = $88BA; //SV (Sampled Value Transmission)
	SGEP_LLDP      = $88CC; //Link Layer Discovery Protocol (LLDP)
	SGEP_SERCOS3   = $88CD; //SERCOS III
	SGEP_WSMP      = $88DC; //WSMP, WAVE Short Message Protocol
	SGEP_HP_AV     = $88E1; //HomePlug AV MME
	SGEP_MRP       = $88E3; //Media Redundancy Protocol (IEC62439-2)
	SGEP_IEEE_MACs = $88E5; //MAC security (IEEE 802.1AE)
	SGEP_PBB       = $88E7; //Provider Backbone Bridges (PBB) (IEEE 802.1ah)
	SGEP_PTP       = $88F7; //Precision Time Protocol (PTP) over Ethernet (IEEE 1588)
	SGEP_NC_SI     = $88F8; //NC-SI
	SGEP_PRP       = $88FB; //Parallel Redundancy Protocol (PRP)
	SGEP_IEEE_CFM  = $8902; //IEEE 802.1ag Connectivity Fault Management (CFM) Protocol / ITU-T Recommendation Y.1731 (OAM)
	SGEP_FCoE      = $8906; //Fibre Channel over Ethernet (FCoE)
	SGEP_FCoE_IP   = $8914; //FCoE Initialization Protocol
	SGEP_RoCE      = $8915; //RDMA over Converged Ethernet (RoCE)
	SGEP_TTE       = $891D; //TTEthernet Protocol Control Frame (TTE)
	SGEP_HSR       = $892F; //High-availability Seamless Redundancy (HSR)
	SGEP_ECTP      = $9000; //Ethernet Configuration Testing Protocol
	SGEP_IEEE_VLAN = $9100; //VLAN-tagged (IEEE 802.1Q) frame with double tagging

// IPv4 address
type
	TSGIPv4AddressBytes = packed array[0..3] of TSGUInt8;
	TSGIPv4AddressValue = TSGUInt32;
	PSGIPv4Address = ^TSGIPv4Address;
	TSGIPv4Address = packed record
		case TSGBoolean of
		True: (Address  : TSGIPv4AddressValue);
		False: (AddressByte : TSGIPv4AddressBytes);
		end;

operator := (const AddressValue : TSGIPv4AddressValue) : TSGIPv4Address; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const Address : TSGIPv4Address; const AddressValue : TSGIPv4AddressValue) : TSGBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator <> (const Address : TSGIPv4Address; const AddressValue : TSGIPv4AddressValue) : TSGBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGIPv4AddressToString(const Address : TSGIPv4Address) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// IPv4 header
type
	TSGIPv4Header = object
			public
		ip_vhl : TSGUInt8; // version << 4 | header length >> 2
		ip_tos : TSGUInt8; // type of service
		ip_len : TSGUInt16; // total length
		ip_id : TSGUInt16; // identification
		ip_off : TSGUInt16; // fragment offset field
		ip_ttl : TSGUInt8; // time to live
		ip_p : TSGUInt8; // protocol
		ip_sum : TSGUInt16; // checksum
		ip_src, ip_dst : TSGIPv4Address; // source and dest address
			public
		function ip_hl() : TSGUInt16;
		function ip_v() : TSGUInt16;
		end;

const SG_IP_RF = $8000; // reserved fragment flag
const SG_IP_DF = $4000; // dont fragment flag
const SG_IP_MF = $2000; // more fragments flag
const SG_IP_OFFMASK = $1fff; // mask for fragmenting bits

// ARP Header, (assuming Ethernet+IPv4)             
const
	SG_ARP_REQUEST = 1;   // ARP Request              
	SG_ARP_REPLY   = 2;   // ARP Reply                
type
	TSGARPIPv4Header = object
			public
		htype : TSGUInt16;    // Hardware Type            
		ptype : TSGUInt16;    // Protocol Type            
		hlen : TSGUInt8;      // Hardware Address Length  
		plen : TSGUInt8;      // Protocol Address Length  
		oper : TSGUInt16;     // Operation Code           
		sha : TSGEnthernetAddress; // Sender hardware address  
		spa : TSGIPv4Address;      // Sender IP address        
		tha : TSGEnthernetAddress; // Target hardware address  
		tpa : TSGIPv4Address;      // Target IP address        
		end;

type
	// TCP Sequence
	TSGTcpSequence = TSGUInt16;
	
	// TCP header
	TSGTcpHeader = object
			public
		th_sport : TSGUInt16;	// source port
		th_dport : TSGUInt16;	// destination port
		th_seq : TSGTcpSequence; // sequence number
		th_ack : TSGTcpSequence; // acknowledgement number
		th_offx2 : TSGUInt8;	// data offset, rsvd
		th_flags : TSGUInt8;
		th_win : TSGUInt16; // window
		th_sum : TSGUInt16; // checksum
		th_urp : TSGUInt16; // urgent pointer
			public
		function th_off() : TSGUInt16;
		end;
const 
	SG_TH_FIN = $01;
	SG_TH_SYN = $02;
	SG_TH_RST = $04;
	SG_TH_PUSH = $08;
	SG_TH_ACK = $10;
	SG_TH_URG = $20;
	SG_TH_ECE = $40;
	SG_TH_CWR = $80;
	SG_TH_FLAGS = SG_TH_FIN or SG_TH_SYN or SG_TH_RST or SG_TH_ACK or SG_TH_URG or SG_TH_ECE or SG_TH_CWR;

// UDP header
// total udp header length: 8 bytes (=64 bits)
type
	TSGUDPHeader = object
			public
		uh_sport : TSGUInt16;
		uh_dport : TSGUInt16;
		uh_len   : TSGUInt16;
		uh_check : TSGUInt16;
		end;

implementation

uses
	 SaGeBaseUtils
	,SaGeStringUtils
	;

function TSGEthernetHeader.GetProtocol() : TSGEnthernetProtocol;
begin
PSGEnthernetProtocolBytes(@Result)^ := ProtocolBytes;
SwapBytes(Result);
end;

function SGEthernetAddesssToString(const Address : TSGEnthernetAddress) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSGMaxEnum;
begin
Result := '';
for Index := 0 to SG_ETHERNET_ADDRESS_SIZE - 1 do
	begin
	Result += SGStrByteHex(Address[Index], False);
	if Index <> SG_ETHERNET_ADDRESS_SIZE - 1 then
		Result += ':';
	end;
end;

function SGEthernetProtocolToStringExtended(const Protocol : TSGEnthernetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGEthernetProtocolToString(Protocol);
if Result = '' then
	Result := 'Unknown Internet Protocol';
Result := '(0x' + SGStr2BytesHex(Protocol) + ') ' + Result;
end;

function SGEthernetProtocolToString(const Protocol : TSGEnthernetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Protocol of
SGEP_IPv4           : Result := 'Internet Protocol version 4';
SGEP_ARP            : Result := 'Address Resolution Protocol (ARP)';
SGEP_WoL            : Result := 'Wake-on-LAN';
SGEP_TRILL          : Result := 'IETF TRILL Protocol';
SGEP_SRP            : Result := 'Stream Reservation Protocol';
SGEP_DECnet         : Result := 'DECnet Phase IV';
SGEP_RARP           : Result := 'Reverse Address Resolution Protocol';
SGEP_AT             : Result := 'AppleTalk (Ethertalk)';
SGEP_AARP           : Result := 'AppleTalk Address Resolution Protocol (AARP)';
SGEP_IEEE_VLAN_NNI  : Result := 'VLAN-tagged frame (IEEE 802.1Q) and Shortest Path Bridging IEEE 802.1aq with NNI compatibility';
SGEP_IPX            : Result := 'Internetwork Packet Exchange (IPX)';
SGEP_QNX            : Result := 'QNX Qnet';
SGEP_IPv6           : Result := 'Internet Protocol Version 6 (IPv6)';
SGEP_Efc            : Result := 'Ethernet flow control';
SGEP_ESP            : Result := 'Ethernet Slow Protocols';
SGEP_CN             : Result := 'CobraNet';
SGEP_MPLSu          : Result := 'MPLS unicast';
SGEP_MPLSm          : Result := 'MPLS multicast';
SGEP_PPPoE_DS       : Result := 'PPPoE Discovery Stage';
SGEP_PPPoE_SS       : Result := 'PPPoE Session Stage';
SGEP_IANS           : Result := 'Intel Advanced Networking Services';
SGEP_JF             : Result := 'Jumbo Frames (Obsoleted draft-ietf-isis-ext-eth-01)';
SGEP_HPv1           : Result := 'HomePlug 1.0 MME';
SGEP_EAPoL          : Result := 'EAP over LAN (IEEE 802.1X)';
SGEP_PI             : Result := 'PROFINET Protocol';
SGEP_HSCSI          : Result := 'HyperSCSI (SCSI over Ethernet)';
SGEP_ATAoE          : Result := 'ATA over Ethernet';
SGEP_EC             : Result := 'EtherCAT Protocol';
SGEP_IEEE_PB        : Result := 'Provider Bridging (IEEE 802.1ad) & Shortest Path Bridging IEEE 802.1aq';
SGEP_EP             : Result := 'Ethernet Powerlink';
SGEP_GOOSE          : Result := 'GOOSE (Generic Object Oriented Substation event)';
SGEP_GSEMS          : Result := 'GSE (Generic Substation Events) Management Services';
SGEP_SVT            : Result := 'SV (Sampled Value Transmission)';
SGEP_LLDP           : Result := 'Link Layer Discovery Protocol (LLDP)';
SGEP_SERCOS3        : Result := 'SERCOS III';
SGEP_WSMP           : Result := 'WSMP, WAVE Short Message Protocol';
SGEP_HP_AV          : Result := 'HomePlug AV MME';
SGEP_MRP            : Result := 'Media Redundancy Protocol (IEC62439-2)';
SGEP_IEEE_MACs      : Result := 'MAC security (IEEE 802.1AE)';
SGEP_PBB            : Result := 'Provider Backbone Bridges (PBB) (IEEE 802.1ah)';
SGEP_PTP            : Result := 'Precision Time Protocol (PTP) over Ethernet (IEEE 1588)';
SGEP_NC_SI          : Result := 'NC-SI';
SGEP_PRP            : Result := 'Parallel Redundancy Protocol (PRP)';
SGEP_IEEE_CFM       : Result := 'IEEE 802.1ag Connectivity Fault Management (CFM) Protocol / ITU-T Recommendation Y.1731 (OAM)';
SGEP_FCoE           : Result := 'Fibre Channel over Ethernet (FCoE)';
SGEP_FCoE_IP        : Result := 'FCoE Initialization Protocol';
SGEP_RoCE           : Result := 'RDMA over Converged Ethernet (RoCE)';
SGEP_TTE            : Result := 'TTEthernet Protocol Control Frame (TTE)';
SGEP_HSR            : Result := 'High-availability Seamless Redundancy (HSR)';
SGEP_ECTP           : Result := 'Ethernet Configuration Testing Protocol';
SGEP_IEEE_VLAN      : Result := 'VLAN-tagged (IEEE 802.1Q) frame with double tagging';
else                  Result := '';
end;
end;

operator := (const AddressValue : TSGIPv4AddressValue) : TSGIPv4Address; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Address := AddressValue;
end;

operator = (const Address : TSGIPv4Address; const AddressValue : TSGIPv4AddressValue) : TSGBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Address.Address = AddressValue;
end;

operator <> (const Address : TSGIPv4Address; const AddressValue : TSGIPv4AddressValue) : TSGBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Address.Address <> AddressValue;
end;

function SGIPv4AddressToString(const Address : TSGIPv4Address) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 
	SGStr(Address.AddressByte[0]) + '.' +
	SGStr(Address.AddressByte[1]) + '.' +
	SGStr(Address.AddressByte[2]) + '.' +
	SGStr(Address.AddressByte[3]) ;
end;

function TSGTcpHeader.th_off() : TSGUInt16;
begin
Result := (th_offx2 and $f0) shl 4;
end;

function TSGIPv4Header.ip_hl() : TSGUInt16;
begin
Result := ip_vhl and $0f;
end;

function TSGIPv4Header.ip_v() : TSGUInt16;
begin
Result := ip_vhl shl 4;
end;

end.
