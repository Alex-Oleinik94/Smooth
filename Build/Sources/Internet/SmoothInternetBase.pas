{$INCLUDE Smooth.inc}

unit SmoothInternetBase;

interface

uses
	 SmoothBase
	,SmoothTextStream
	
	,Classes
	;


const
	// Ethernet headers are always exactly 14 bytes
	S_ETHERNET_HEADER_SIZE = 14;
	// Ethernet addresses are 6 bytes
	S_ETHERNET_ADDRESS_SIZE = 6;

// Ethernet header
type 
	TSEnthernetAddress = packed array[0..S_ETHERNET_ADDRESS_SIZE-1] of TSUInt8;
	TSEnthernetProtocol = TSUInt16;
	PSEnthernetProtocolBytes = ^ TSEnthernetProtocolBytes;
	TSEnthernetProtocolBytes = packed array [0..1] of TSUInt8;
	
	PSEthernetHeader = ^ TSEthernetHeader;
	TSEthernetHeader = object
			protected
		FDestination   : TSEnthernetAddress;       // Destination host address
		FSource        : TSEnthernetAddress;       // Source host address
		FProtocol      : TSEnthernetProtocolBytes; // IP? ARP? RARP? etc
			private
		function GetProtocol() : TSEnthernetProtocol;
			public
		property Protocol : TSEnthernetProtocol read GetProtocol;
		property Destination : TSEnthernetAddress read FDestination;
		property Source : TSEnthernetAddress read FSource;
		end;

function SEthernetProtocolToString(const Protocol : TSEnthernetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SEthernetAddesssToString(const Address : TSEnthernetAddress) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SEthernetProtocolToStringExtended(const Protocol : TSEnthernetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Ethernet protocols
const
	SEP_IPv4      = $0800; //Internet Protocol version 4 (IPv4)
	SEP_ARP       = $0806; //Address Resolution Protocol (ARP)
	SEP_WoL       = $0842; //Wake-on-LAN
	SEP_TRILL     = $22F3; //IETF TRILL Protocol
	SEP_SRP       = $22EA; //Stream Reservation Protocol
	SEP_DECnet    = $6003; //DECnet Phase IV
	SEP_RARP      = $8035; //Reverse Address Resolution Protocol
	SEP_AT        = $809B; //AppleTalk (Ethertalk)
	SEP_AARP      = $80F3; //AppleTalk Address Resolution Protocol (AARP)
	SEP_IEEE_VLAN_NNI = $8100; //VLAN-tagged frame (IEEE 802.1Q) and Shortest Path Bridging IEEE 802.1aq with NNI compatibility
	SEP_IPX       = $8137; //Internetwork Packet Exchange (IPX)
	SEP_QNX       = $8204; //QNX Qnet
	SEP_IPv6      = $86DD; //Internet Protocol Version 6 (IPv6)
	SEP_Efc       = $8808; //Ethernet flow control
	SEP_ESP       = $8809; //Ethernet Slow Protocols
	SEP_CN        = $8819; //CobraNet
	SEP_MPLSu     = $8847; //MPLS unicast
	SEP_MPLSm     = $8848; //MPLS multicast
	SEP_PPPoE_DS  = $8863; //PPPoE Discovery Stage
	SEP_PPPoE_SS  = $8864; //PPPoE Session Stage
	SEP_IANS      = $886D; //Intel Advanced Networking Services
	SEP_JF        = $8870; //Jumbo Frames (Obsoleted draft-ietf-isis-ext-eth-01)
	SEP_HPv1      = $887B; //HomePlug 1.0 MME
	SEP_EAPoL     = $888E; //EAP over LAN (IEEE 802.1X)
	SEP_PI        = $8892; //PROFINET Protocol
	SEP_HSCSI     = $889A; //HyperSCSI (SCSI over Ethernet)
	SEP_ATAoE     = $88A2; //ATA over Ethernet
	SEP_EC        = $88A4; //EtherCAT Protocol
	SEP_IEEE_PB   = $88A8; //Provider Bridging (IEEE 802.1ad) & Shortest Path Bridging IEEE 802.1aq
	SEP_EP        = $88AB; //Ethernet Powerlink
	SEP_GOOSE     = $88B8; //GOOSE (Generic Object Oriented Substation event)
	SEP_GSEMS     = $88B9; //GSE (Generic Substation Events) Management Services
	SEP_SVT       = $88BA; //SV (Sampled Value Transmission)
	SEP_LLDP      = $88CC; //Link Layer Discovery Protocol (LLDP)
	SEP_SERCOS3   = $88CD; //SERCOS III
	SEP_WSMP      = $88DC; //WSMP, WAVE Short Message Protocol
	SEP_HP_AV     = $88E1; //HomePlug AV MME
	SEP_MRP       = $88E3; //Media Redundancy Protocol (IEC62439-2)
	SEP_IEEE_MACs = $88E5; //MAC security (IEEE 802.1AE)
	SEP_PBB       = $88E7; //Provider Backbone Bridges (PBB) (IEEE 802.1ah)
	SEP_PTP       = $88F7; //Precision Time Protocol (PTP) over Ethernet (IEEE 1588)
	SEP_NC_SI     = $88F8; //NC-SI
	SEP_PRP       = $88FB; //Parallel Redundancy Protocol (PRP)
	SEP_IEEE_CFM  = $8902; //IEEE 802.1ag Connectivity Fault Management (CFM) Protocol / ITU-T Recommendation Y.1731 (OAM)
	SEP_FCoE      = $8906; //Fibre Channel over Ethernet (FCoE)
	SEP_FCoE_IP   = $8914; //FCoE Initialization Protocol
	SEP_RoCE      = $8915; //RDMA over Converged Ethernet (RoCE)
	SEP_TTE       = $891D; //TTEthernet Protocol Control Frame (TTE)
	SEP_HSR       = $892F; //High-availability Seamless Redundancy (HSR)
	SEP_ECTP      = $9000; //Ethernet Configuration Testing Protocol
	SEP_IEEE_VLAN = $9100; //VLAN-tagged (IEEE 802.1Q) frame with double tagging

// Protocol options
type
	TSProtocolOptions = TMemoryStream;
function SProtocolOptions(const Stream : TStream; const OptionsSize : TSUInt64) : TSProtocolOptions; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SProtocolOptions(const Source : TSProtocolOptions; const Destination : TStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// IPv4 address
type
	TSIPv4AddressBytes = packed array[0..3] of TSUInt8;
	TSIPv4AddressValue = TSUInt32;
	PSIPv4Address = ^TSIPv4Address;
	TSIPv4Address = packed record
		case TSBoolean of
		True : (Address     : TSIPv4AddressValue);
		False: (AddressByte : TSIPv4AddressBytes);
		end;

operator := (const AddressValue : TSIPv4AddressValue) : TSIPv4Address; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const Address : TSIPv4Address; const AddressValue : TSIPv4AddressValue) : TSBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const Address1, Address2 : TSIPv4Address) : TSBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator <> (const Address : TSIPv4Address; const AddressValue : TSIPv4AddressValue) : TSBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SIPv4AddressView(const Address : TSIPv4Address; const TextStream : TSTextStream; const ColorNumber, ColorPoint : TSUInt8); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SIPv4AddressToString(const Address : TSIPv4Address) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SIPv4StringToAddress(const Address : TSString) : TSIPv4Address; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure Swap(var Address1, Address2 : TSIPv4Address); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// IPv4 header
const
	S_IPv4_HEADER_SIZE = 20;
type
	TSInternetProtocol = TSUInt8;
	PSIPv4Header = ^ TSIPv4Header;
	TSIPv4Header = object
			protected
		FVersionAndHeaderLength : TSUInt8;  // version | header length
		FDifferentiatedServices : TSUInt8;  // type of service
		FTotalLength            : TSUInt16; // total length, Size(IPv4) + Size(IPv4.Protocol), without Ethernet header length
		FIdentification         : TSUInt16; // identification
		FFragment               : TSUInt16; // fragment offset field
		FTimeToLive             : TSUInt8;  // time to live
		FProtocol               : TSInternetProtocol; // protocol (TCP? UDP? etc)
		FChecksum               : TSUInt16; // checksum
		FSource, FDestination   : TSIPv4Address; // source and destination address
			public
		function Version()      : TSUInt8;
		function HeaderSize()   : TSUInt8;
		function DifferentiatedServicesCodepoint() : TSUInt8;
		function ExpilitCongestionNotification() : TSUInt8;
		function TotalSize()    : TSUInt16;
		function Identification() : TSUInt16;
		function ReservedBit()  : TSBoolean;
		function DontFragment() : TSBoolean;
		function MoreFragments() : TSBoolean;
		function FragmentOffset() : TSUInt16;
		function Checksum() : TSUInt16;
			public
		property TimeToLive : TSUInt8 read FTimeToLive;
		property Protocol : TSInternetProtocol read FProtocol;
		property Source : TSIPv4Address read FSource;
		property Destination : TSIPv4Address read FDestination;
		end;
	TSIPv4Options = TSProtocolOptions;

// Masks
const 
	SIPVersionMask      = $f0; // 1111 .... Version
	SIPHeaderLengthMask = $0f; // .... 1111 Header length
const
	SIPDifferentiatedServicesCodepoint = $fc; // 1111 11.. 
	SIPExpilitCongestionNotification   = $03; // .... ..11
const
	SIPReservedBit    = $8000; // 1... .... .... .... Reserved bit
	SIPDontFragment   = $4000; // .1.. .... .... .... Dont fragment flag
	SIPMoreFragments  = $2000; // ..1. .... .... .... More fragments flag
	SIPFragmentOffset = $1fff; // ...1 1111 1111 1111 Fragmenting bits

function SInternetProtocolToString(const Protocol : TSInternetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SInternetProtocolToStringExtended(const Protocol : TSInternetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Internet protocols
const
	SIP_HOPOPT = 0;     //IPv6 Hop-by-Hop Option
	SIP_ICMP   = 1;     //Internet Control Message Protocol
	SIP_IGMP   = 2;     //Internet Group Management Protocol
	SIP_GGP    = 3;     //Gateway-to-Gateway Protocol
	SIP_IPv4   = 4;     //IPv4 (encapsulation)
	SIP_ST     = 5;     //Internet Stream Protocol
	SIP_TCP    = 6;     //Transmission Control Protocol
	SIP_CBT    = 7;     //Core-based trees
	SIP_EGP    = 8;     //Exterior Gateway Protocol
	SIP_IGP    = 9;     //Interior Gateway Protocol
	SIP_BBN_RCC_MON = 10; //BBN RCC Monitoring
	SIP_NVP_II = 11;    //Network Voice Protocol
	SIP_PUP    = 12;    //Xerox PUP
	SIP_ARGUS  = 13;    //ARGU
	SIP_EMCON  = 14;    //EMCON
	SIP_XNET   = 15;    //Cross Net Debugger
	SIP_CHAOS  = 16;    //Chaosnet
	SIP_UDP    = 17;    //User Datagram Protocol
	SIP_MUX    = 18;    //Multiplexing
	SIP_DCN_MEAS = 19;  //DCN Measurement Subsystems
	SIP_HMP    = 20;    //Host Monitoring Protocol
	SIP_PRM    = 21;    //Packet Radio Measurement
	SIP_XNS_IDP = 22;   //XEROX NS IDP
	SIP_TRUNK_1 = 23;   //Trunk-1
	SIP_TRUNK_2 = 24;   //Trunk-2
	SIP_LEAF_1 = 25;    //Leaf-1
	SIP_LEAF_2 = 26;    //Leaf-2
	SIP_RDP    = 27;    //Reliable Datagram Protocol
	SIP_IRTP   = 28;    //Internet Reliable Transaction Protocol
	SIP_ISO_TP4 = 29;   //ISO Transport Protocol Class 4
	SIP_NETBLT = 30;    //Bulk Data Transfer Protocol
	SIP_MFE_NSP = 31;   //MFE Network Services Protocol
	SIP_MERIT_INP = 32; //MERIT Internodal Protocol
	SIP_DCCP   = 33;    //Datagram Congestion Control Protocol
	SIP_3PC    = 34;    //Third Party Connect Protocol
	SIP_IDPR   = 35;    //Inter-Domain Policy Routing Protocol    
	SIP_XTP    = 36;    //Xpress Transport Protocol
	SIP_DDP    = 37;    //Datagram Delivery Protocol
	SIP_IDPR_CMTP = 38; //IDPR Control Message Transport Protocol
	SIP_TPpp   = 39;    //TP++ Transport Protocol
	SIP_IL     = 40;    //IL Protocol
	SIP_IPv6   = 41;    //IPv6 (Encapsulation)
	SIP_SDRP   = 42;    //Source Demand Routing Protocol
	SIP_IPv6_Route = 43; //Routing Header for IPv6
	SIP_IPv6_Frag = 44; //Fragment Header for IPv6
	SIP_IDRP   = 45;    //Inter-Domain Routing Protocol
	SIP_RSVP   = 46;    //Resource Reservation Protocol
	SIP_GRE    = 47;    //Generic Routing Encapsulation
	SIP_MHRP   = 48;    //Mobile Host Routing Protocol
	SIP_BNA    = 49;    //BNA    
	SIP_ESP    = 50;    //Encapsulating Security Payload
	SIP_AH     = 51;    //Authentication Header
	SIP_I_NLSP = 52;    //Integrated Net Layer Security Protocol
	SIP_SWIPE  = 53;    //SwIPe
	SIP_NARP   = 54;    //NBMA Address Resolution Protocol
	SIP_MOBILE = 55;    //Mobile IP (Min Encap)
	SIP_TLSP   = 56;    //Transport Layer Security Protocol (using Kryptonet key management)
	SIP_SKIP   = 57;    //Simple Key-Management for Internet Protocol
	SIP_IPv6_ICMP = 58; //ICMP for IPv6
	SIP_IPv6_NoNxt = 59; //No Next Header for IPv6
	SIP_IPv6_Opts = 60; //Destination Options for IPv6
	SIP__AHIP  = 61;    //Any host internal protocol
	SIP_CFTP   = 62;    //CFTP
	SIP__ALN   = 63;    //Any local network
	SIP_SAT_EXPAK = 64; //SATNET and Backroom EXPAK
	SIP_KRYPTOLAN = 65; //Kryptolan
	SIP_RVD    = 66;    //Remote Virtual Disk Protocol
	SIP_IPPC   = 67;    //Internet Pluribus Packet Core
	SIP__ADFS  = 68;    //Any distributed file system
	SIP_SAT_MON = 69;   //SATNET Monitoring
	SIP_VISA   = 70;    //VISA Protocol
	SIP_IPCV   = 71;    //Internet Packet Core Utility
	SIP_CPNX   = 72;    //Computer Protocol Network Executive
	SIP_CPHB   = 73;    //Computer Protocol Heart Beat
	SIP_WSN    = 74;    //Wang Span Network
	SIP_PVP    = 75;    //Packet Video Protocol
	SIP_BR_SAT_MON = 76; //Backroom SATNET Monitoring
	SIP_SUN_ND = 77;    //SUN ND PROTOCOL-Temporary
	SIP_WB_MON = 78;    //WIDEBAND Monitoring
	SIP_WB_EXPAK = 79;  //WIDEBAND EXPAK
	SIP_ISO_IP = 80;    //International Organization for Standardization Internet Protocol
	SIP_VMTP   = 81;    //Versatile Message Transaction Protocol
	SIP_SECURE_VMTP = 82; //Secure Versatile Message Transaction Protocol
	SIP_VINES  = 83;    //VINE
	SIP_TTP    = 84;    //TTP
	SIP_IPTM   = 84;    //Internet Protocol Traffic Manager
	SIP_NSFNET_IGP = 85; //NSFNET-IGP
	SIP_DGP    = 86;    //Dissimilar Gateway Protocol
	SIP_TCF    = 87;    //TCF
	SIP_EIGRP  = 88;    //EIGRP
	SIP_OSPF   = 89;    //Open Shortest Path First
	SIP_Sprite_RPC = 90; //Sprite RPC Protocol
	SIP_LARP   = 91;    //Locus Address Resolution Protocol
	SIP_MTP    = 92;    //Multicast Transport Protocol
	SIP_AX_25  = 93;    //AX.25
	SIP_IPIP   = 94;    //IP-within-IP Encapsulation Protocol
	SIP_MICP   = 95;    //Mobile Internetworking Control Protocol
	SIP_SCC_SP = 96;    //Semaphore Communications Sec. Pro
	SIP_ETHERIP = 97;   //Ethernet-within-IP Encapsulation
	SIP_ENCAP  = 98;    //Encapsulation Header
	SIP__APES  = 99;    //Any private encryption scheme
	SIP_GMTP   = 100;   //GMTP
	SIP_IFMP   = 101;   //Ipsilon Flow Management Protocol
	SIP_PNNI   = 102;   //PNNI over IP
	SIP_PIM    = 103;   //Protocol Independent Multicast
	SIP_ARIS   = 104;   //IBM''s ARIS (Aggregate Route IP Switching) Protocol    
	SIP_SCPS   = 105;   //SCPS (Space Communications Protocol Standards)]
	SIP_AN     = 107;   //Active Networks
	SIP_IPComp = 108;   //IP Payload Compression Protocol
	SIP_SNP    = 109;   //Sitara Networks Protocol
	SIP_Compaq_Peer = 110; //Compaq Peer Protocol
	SIP_IPX_in_IP = 111; //IPX in IP
	SIP_VRRP   = 112;   //Virtual Router Redundancy Protocol
	SIP_PGM    = 113;   //PGM Reliable Transport Protocol
	SIP__A0LP  = 114;   //Any 0-hop protocol
	SIP_L2TP   = 115;   //Layer Two Tunneling Protocol Version 3
	SIP_DDX    = 116;   //D-II Data Exchange (DDX)
	SIP_IATP   = 117;   //Interactive Agent Transfer Protocol
	SIP_STP    = 118;   //Schedule Transfer Protocol
	SIP_SRP    = 119;   //SpectraLink Radio Protocol
	SIP_UTI    = 120;   //UTI
	SIP_SMP    = 121;   //Simple Message Protocol
	SIP_SM     = 122;   //SM
	SIP_PTP    = 123;   //Performance Transparency Protocol
	SIP_IS_ISoIPv4 = 124; //IS-IS over IPv4
	SIP_FIRE   = 125;   //Flexible Intra-AS Routing Environment
	SIP_CRTP   = 126;   //Combat Radio Transport Protocol
	SIP_CRUDP  = 127;   //Combat Radio User Datagram
	SIP_SSCOPMCE = 128; //Service-Specific Connection-Oriented Protocol in a Multilink and Connectionless Environment
	SIP_IPLT   = 129;
	SIP_SPS    = 130;   //Secure Packet Shield
	SIP_PIPE   = 131;   //Private IP Encapsulation within IP
	SIP_SCTP   = 132;   //Stream Control Transmission Protocol 
	SIP_FC     = 133;   //Fibre Channel
	SIP_RSVP_E2E_IGNORE = 134; //Reservation Protocol (RSVP) End-to-End Ignore
	SIP__MH    = 135;   //Mobility Header
	SIP_UDPL   = 136;   //UDP Lite
	SIP_MPLS_in_IP = 137; //MPLS-in-IP
	SIP_manet  = 138;   //MANET Protocols
	SIP_HIP    = 139;   //Host Identity Protocol
	SIP_Shim6  = 140;   //Site Multihoming by IPv6 Intermediation
	SIP_WESP   = 141;   //Wrapped Encapsulating Security Payload
	SIP_ROHC   = 142;   //Robust Header Compression
	SIP__empty : TSSetOfByte = [143..252]; // UNASSIGNED
	SIP__TEST  : TSSetOfByte = [253..254]; // Use for experimentation and testing
	SIP__255   = 255;   // Reserved for extra.

// ARP Header, (assuming Ethernet + IPv4)
const
	S_ARP_REQUEST = 1;   // ARP Request
	S_ARP_REPLY   = 2;   // ARP Reply
type
	TSARPIPv4Header = object
			public
		htype : TSUInt16;    // Hardware Type
		ptype : TSUInt16;    // Protocol Type
		hlen : TSUInt8;      // Hardware Address Length
		plen : TSUInt8;      // Protocol Address Length
		oper : TSUInt16;     // Operation Code
		sha : TSEnthernetAddress; // Sender hardware address
		spa : TSIPv4Address;      // Sender IP address
		tha : TSEnthernetAddress; // Target hardware address
		tpa : TSIPv4Address;      // Target IP address
		end;

const
	S_TCP_WINDOW_SIZE = $10000;
type
	// TCP Sequence
	TSTcpSequence = TSUInt32;
	TSTcpSequenceBuffer = PSUInt8;
	
	// TCP header
	PSTCPHeader = ^ TSTCPHeader;
	TSTCPHeader = object
			private
		FSourcePort            : TSUInt16;       // Порт источника,      Source Port 
		FDestinationPort       : TSUInt16;       // Порт назначения,     Destination Port
		FSequenceNumber        : TSTcpSequence;  // Порядковый номер,    Sequence Number (SN)
		FAcknowledgementNumber : TSTcpSequence;  // Номер подтверждения, Acknowledgment Number (ACK SN)
		FHeaderLenghtAndFlags  : TSUInt16;       // Длина заголовка, Зарезервированные биты, Флаги; Data Offset, Reserved bites, Flags.
		FWindowSize            : TSUInt16;       // Размер Окна,         Window Size Value
		FChecksum              : TSUInt16;       // Контрольная сумма,   Checksum
		FUrgentPointer         : TSUInt16;       // Указатель важности,  Urgent Pointer
			public
		function ReservedBitsAsBoolString() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		function GetSourcePort() : TSUInt16;
		function GetDestinationPort() : TSUInt16;
		function GetSequenceNumber() : TSTcpSequence;
		function GetAcknowledgementNumber() : TSTcpSequence;
		function GetHeaderSize() : TSUInt8;
		function GetReservedBits() : TSUInt8;
		function GetECN_Nonce() : TSBoolean;
		function GetCWR() : TSBoolean;
		function GetECN_Echo() : TSBoolean;
		function GetUrgent() : TSBoolean;
		function GetAcknowledgement() : TSBoolean;
		function GetPush() : TSBoolean;
		function GetReset() : TSBoolean;
		function GetSynchronize() : TSBoolean;
		function GetFinal() : TSBoolean;
		function IsFlagsEmpty() : TSBoolean;
		function GetWindowSize() : TSUInt16;
		function GetChecksum() : TSUInt16;
		function GetUrgentPointer() : TSUInt16;
			public
		property SourcePort  : TSUInt16 read GetSourcePort;
		property DestinationPort : TSUInt16 read GetDestinationPort;
		property SequenceNumber : TSTcpSequence read GetSequenceNumber;
		property AcknowledgementNumber : TSTcpSequence read GetAcknowledgementNumber;
		property HeaderSize  : TSUInt8 read GetHeaderSize;
		property ReservedBits : TSUInt8 read GetReservedBits;
		property ECN_Nonce   : TSBoolean read GetECN_Nonce;
		property CWR         : TSBoolean read GetCWR;
		property ECN_Echo    : TSBoolean read GetECN_Echo;
		property Urgent      : TSBoolean read GetUrgent;
		property Acknowledgement : TSBoolean read GetAcknowledgement;
		property Push        : TSBoolean read GetPush;
		property Reset       : TSBoolean read GetReset;
		property Synchronize : TSBoolean read GetSynchronize;
		property Final       : TSBoolean read GetFinal;
		property FlagsEmpty  : TSBoolean read IsFlagsEmpty;
		property WindowSize  : TSUInt16 read GetWindowSize;
		property Checksum  : TSUInt16 read GetChecksum;
		property UrgentPointer  : TSUInt16 read GetUrgentPointer;
		end;
	TSTCPOptions = TSProtocolOptions;

// Masks
const 
	STCPFinal           = $0001; // .... .... .... ...1 Final bit used for connection termination
	STCPSynchronize     = $0002; // .... .... .... ..1. Synchronize sequence numbers
	STCPReset           = $0004; // .... .... .... .1.. Reset the connection
	STCPPush            = $0008; // .... .... .... 1... Push function
	STCPAcknowledgement = $0010; // .... .... ...1 .... Acknowledgement field is significant
	STCPUrgent          = $0020; // .... .... ..1. .... Urgent pointer field is significant
	STCPECN_Echo        = $0040; // .... .... .1.. .... ECN-Echo 
	STCPCWR             = $0080; // .... .... 1... .... Congestion Window Reduced
	STCPECN_Nonce       = $0100; // .... ...1 .... .... ECN-Nonce - concealment protection
	STCPReserved        = $0e00; // .... 111. .... .... Reserved bits
	STCPHeaderLength    = $f000; // 1111 .... .... .... Header length mask
	STCPFlags           = $01ff; // .... ...1 1111 1111 All TCP flags

// UDP header
// total udp header length: 8 bytes (=64 bits)
type
	TSUDPHeader = object
			public
		uh_sport : TSUInt16;
		uh_dport : TSUInt16;
		uh_len   : TSUInt16;
		uh_check : TSUInt16;
		end;

implementation

uses
	 SmoothBaseUtils
	,SmoothStreamUtils
	,SmoothStringUtils
	
	,StrMan
	;

procedure SProtocolOptions(const Source : TSProtocolOptions; const Destination : TStream); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Source <> nil) and (Destination <> nil) and (Source.Size > 0) then
	begin
	Source.Position := 0;
	SCopyPartStreamToStream(Source, Destination, Source.Size);
	Source.Position := 0;
	end;
end;

function SProtocolOptions(const Stream : TStream; const OptionsSize : TSUInt64) : TSProtocolOptions; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;
if OptionsSize > 0 then
	begin
	Result := TSProtocolOptions.Create();
	SCopyPartStreamToStream(Stream, Result, OptionsSize);
	Result.Position := 0;
	end;
end;

function SInternetProtocolToStringExtended(const Protocol : TSInternetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=  SInternetProtocolToString(Protocol);
if Result = '' then
	Result := 'Unknown Internet Protocol';
Result := '(0x' + SStrByteHex(Protocol, False) + '[hex], ' + SStr(Protocol) + '[dec]) ' + Result;
end;

function SInternetProtocolToString(const Protocol : TSInternetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Protocol of
SIP_HOPOPT : Result := 'IPv6 Hop-by-Hop Option';
SIP_ICMP   : Result := 'Internet Control Message Protocol';
SIP_IGMP   : Result := 'Internet Group Management Protocol';
SIP_GGP    : Result := 'Gateway-to-Gateway Protocol';
SIP_IPv4   : Result := 'IPv4 (encapsulation)';
SIP_ST     : Result := 'Internet Stream Protocol';
SIP_TCP    : Result := 'Transmission Control Protocol';
SIP_CBT    : Result := 'Core-based trees';
SIP_EGP    : Result := 'Exterior Gateway Protocol';
SIP_IGP    : Result := 'Interior Gateway Protocol';
SIP_BBN_RCC_MON : Result := 'BBN RCC Monitoring';
SIP_NVP_II : Result := 'Network Voice Protocol';
SIP_PUP    : Result := 'Xerox PUP';
SIP_ARGUS  : Result := 'ARGUS';
SIP_EMCON  : Result := 'EMCON';
SIP_XNET   : Result := 'Cross Net Debugger';
SIP_CHAOS  : Result := 'Chaosnet';
SIP_UDP    : Result := 'User Datagram Protocol';
SIP_MUX    : Result := 'Multiplexing';
SIP_DCN_MEAS : Result := 'DCN Measurement Subsystems';
SIP_HMP    : Result := 'Host Monitoring Protocol';
SIP_PRM    : Result := 'Packet Radio Measurement';
SIP_XNS_IDP : Result := 'XEROX NS IDP';
SIP_TRUNK_1 : Result := 'Trunk-1';
SIP_TRUNK_2 : Result := 'Trunk-2';
SIP_LEAF_1 : Result := 'Leaf-1';
SIP_LEAF_2 : Result := 'Leaf-2';
SIP_RDP    : Result := 'Reliable Datagram Protocol';
SIP_IRTP   : Result := 'Internet Reliable Transaction Protocol';
SIP_ISO_TP4 : Result := 'ISO Transport Protocol Class 4';
SIP_NETBLT : Result := 'Bulk Data Transfer Protocol';
SIP_MFE_NSP : Result := 'MFE Network Services Protocol';
SIP_MERIT_INP : Result := 'MERIT Internodal Protocol';
SIP_DCCP   : Result := 'Datagram Congestion Control Protocol';
SIP_3PC    : Result := 'Third Party Connect Protocol';
SIP_IDPR   : Result := 'Inter-Domain Policy Routing Protocol';
SIP_XTP    : Result := 'Xpress Transport Protocol';
SIP_DDP    : Result := 'Datagram Delivery Protocol';
SIP_IDPR_CMTP: Result := 'IDPR Control Message Transport Protocol';
SIP_TPpp   : Result := 'TP++ Transport Protocol';
SIP_IL     : Result := 'IL Protocol';
SIP_IPv6   : Result := 'IPv6 (Encapsulation)';
SIP_SDRP   : Result := 'Source Demand Routing Protocol';
SIP_IPv6_Route: Result := 'Routing Header for IPv6';
SIP_IPv6_Frag : Result := 'Fragment Header for IPv6';
SIP_IDRP   : Result := 'Inter-Domain Routing Protocol';
SIP_RSVP   : Result := 'Resource Reservation Protocol';
SIP_GRE    : Result := 'Generic Routing Encapsulation';
SIP_MHRP   : Result := 'Mobile Host Routing Protocol';
SIP_BNA    : Result := 'Burroughs Network Architecture';
SIP_ESP    : Result := 'Encapsulating Security Payload';
SIP_AH     : Result := 'Authentication Header';
SIP_I_NLSP : Result := 'Integrated Net Layer Security Protocol';
SIP_SWIPE  : Result := 'SwIPe';
SIP_NARP   : Result := 'NBMA Address Resolution Protocol';
SIP_MOBILE: Result := 'Mobile IP (Min Encap)';
SIP_TLSP   : Result := 'Transport Layer Security Protocol (using Kryptonet key management)';
SIP_SKIP   : Result := 'Simple Key-Management for Internet Protocol';
SIP_IPv6_ICMP : Result := 'ICMP for IPv6';
SIP_IPv6_NoNxt : Result := 'No Next Header for IPv6';
SIP_IPv6_Opts : Result := 'Destination Options for IPv6';
SIP__AHIP  : Result := 'Any host internal protocol';
SIP_CFTP   : Result := 'CFTP';
SIP__ALN   : Result := 'Any local network';
SIP_SAT_EXPAK : Result := 'SATNET and Backroom EXPAK';
SIP_KRYPTOLAN : Result := 'Kryptolan';
SIP_RVD    : Result := 'Remote Virtual Disk Protocol';
SIP_IPPC   : Result := 'Internet Pluribus Packet Core';
SIP__ADFS  : Result := 'Any distributed file system';
SIP_SAT_MON : Result := 'SATNET Monitoring';
SIP_VISA   : Result := 'VISA Protocol';
SIP_IPCV   : Result := 'Internet Packet Core Utility';
SIP_CPNX   : Result := 'Computer Protocol Network Executive';
SIP_CPHB   : Result := 'Computer Protocol Heart Beat';
SIP_WSN    : Result := 'Wang Span Network';
SIP_PVP    : Result := 'Packet Video Protocol';
SIP_BR_SAT_MON : Result := 'Backroom SATNET Monitoring';
SIP_SUN_ND : Result := 'SUN ND PROTOCOL-Temporary';
SIP_WB_MON : Result := 'WIDEBAND Monitoring';
SIP_WB_EXPAK : Result := 'WIDEBAND EXPAK';
SIP_ISO_IP : Result := 'International Organization for Standardization Internet Protocol';
SIP_VMTP   : Result := 'Versatile Message Transaction Protocol';
SIP_SECURE_VMTP : Result := 'Secure Versatile Message Transaction Protocol';
SIP_VINES  : Result := 'VINES';
SIP_TTP{=SIP_IPTM} : Result := '(TTP) or (Internet Protocol Traffic Manager)';
SIP_NSFNET_IGP: Result := 'NSFNET-IGP';
SIP_DGP    : Result := 'Dissimilar Gateway Protocol';
SIP_TCF    : Result := 'TCF';
SIP_EIGRP  : Result := 'EIGRP';
SIP_OSPF   : Result := 'Open Shortest Path First';
SIP_Sprite_RPC : Result := 'Sprite RPC Protocol';
SIP_LARP   : Result := 'Locus Address Resolution Protocol';
SIP_MTP    : Result := 'Multicast Transport Protocol';
SIP_AX_25  : Result := 'AX.25';
SIP_IPIP   : Result := 'IP-within-IP Encapsulation Protocol';
SIP_MICP   : Result := 'Mobile Internetworking Control Protocol';
SIP_SCC_SP : Result := 'Semaphore Communications Sec. Pro';
SIP_ETHERIP : Result := 'Ethernet-within-IP Encapsulation';
SIP_ENCAP  : Result := 'Encapsulation Header';
SIP__APES  : Result := 'Any private encryption scheme';
SIP_GMTP   : Result := 'GMTP';
SIP_IFMP   : Result := 'Ipsilon Flow Management Protocol';
SIP_PNNI   : Result := 'PNNI over IP';
SIP_PIM    : Result := 'Protocol Independent Multicast';
SIP_ARIS   : Result := 'IBM''s ARIS (Aggregate Route IP Switching) Protocol';
SIP_SCPS   : Result := 'SCPS (Space Communications Protocol Standards)]';
SIP_AN     : Result := 'Active Networks';
SIP_IPComp : Result := 'IP Payload Compression Protocol';
SIP_SNP    : Result := 'Sitara Networks Protocol';
SIP_Compaq_Peer : Result := 'Compaq Peer Protocol';
SIP_IPX_in_IP : Result := 'IPX in IP';
SIP_VRRP   : Result := 'Virtual Router Redundancy Protocol';
SIP_PGM    : Result := 'PGM Reliable Transport Protocol';
SIP__A0LP  : Result := 'Any 0-hop protocol';
SIP_L2TP   : Result := 'Layer Two Tunneling Protocol Version 3';
SIP_DDX    : Result := 'D-II Data Exchange (DDX)';
SIP_IATP   : Result := 'Interactive Agent Transfer Protocol';
SIP_STP    : Result := 'Schedule Transfer Protocol';
SIP_SRP    : Result := 'SpectraLink Radio Protocol';
SIP_UTI    : Result := 'Universal Transport Interface Protocol';
SIP_SMP    : Result := 'Simple Message Protocol';
SIP_SM     : Result := 'Simple Multicast Protocol';
SIP_PTP    : Result := 'Performance Transparency Protocol';
SIP_IS_ISoIPv4 : Result := 'IS-IS over IPv4';
SIP_FIRE   : Result := 'Flexible Intra-AS Routing Environment';
SIP_CRTP   : Result := 'Combat Radio Transport Protocol';
SIP_CRUDP  : Result := 'Combat Radio User Datagram';
SIP_SSCOPMCE : Result := 'Service-Specific Connection-Oriented Protocol in a Multilink and Connectionless Environment';
SIP_IPLT   : Result := 'IPLT';
SIP_SPS    : Result := 'Secure Packet Shield';
SIP_PIPE   : Result := 'Private IP Encapsulation within IP';
SIP_SCTP   : Result := 'Stream Control Transmission Protocol';
SIP_FC     : Result := 'Fibre Channel';
SIP_RSVP_E2E_IGNORE : Result := 'Reservation Protocol (RSVP) End-to-End Ignore';
SIP__MH    : Result := 'Mobility Header';
SIP_UDPL   : Result := 'UDP Lite';
SIP_MPLS_in_IP : Result := 'MPLS-in-IP';
SIP_manet  : Result := 'MANET Protocols';
SIP_HIP    : Result := 'Host Identity Protocol';
SIP_Shim6  : Result := 'Site Multihoming by IPv6 Intermediation';
SIP_WESP   : Result := 'Wrapped Encapsulating Security Payload';
SIP_ROHC   : Result := 'Robust Header Compression';
SIP__255   : Result := 'Protocol wich reserved for extra';
else if Protocol in SIP__TEST then Result := 'Protocol wich uses for experimentation and testing'
else Result := '';
end;
end;

function TSEthernetHeader.GetProtocol() : TSEnthernetProtocol;
begin
Result := TSEnthernetProtocol(FProtocol);
SwapBytes(Result);
end;

function SEthernetAddesssToString(const Address : TSEnthernetAddress) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSMaxEnum;
begin
Result := '';
for Index := 0 to S_ETHERNET_ADDRESS_SIZE - 1 do
	begin
	Result += SStrByteHex(Address[Index], False);
	if Index <> S_ETHERNET_ADDRESS_SIZE - 1 then
		Result += ':';
	end;
end;

function SEthernetProtocolToStringExtended(const Protocol : TSEnthernetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SEthernetProtocolToString(Protocol);
if Result = '' then
	Result := 'Unknown Ethernet Protocol';
Result := '(0x' + SStr2BytesHex(Protocol, False) + '[hex], ' + SStr(Protocol) + '[dec]) ' + Result;
end;

function SEthernetProtocolToString(const Protocol : TSEnthernetProtocol) : TSString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Protocol of
SEP_IPv4           : Result := 'Internet Protocol version 4';
SEP_ARP            : Result := 'Address Resolution Protocol (ARP)';
SEP_WoL            : Result := 'Wake-on-LAN';
SEP_TRILL          : Result := 'IETF TRILL Protocol';
SEP_SRP            : Result := 'Stream Reservation Protocol';
SEP_DECnet         : Result := 'DECnet Phase IV';
SEP_RARP           : Result := 'Reverse Address Resolution Protocol';
SEP_AT             : Result := 'AppleTalk (Ethertalk)';
SEP_AARP           : Result := 'AppleTalk Address Resolution Protocol (AARP)';
SEP_IEEE_VLAN_NNI  : Result := 'VLAN-tagged frame (IEEE 802.1Q) and Shortest Path Bridging IEEE 802.1aq with NNI compatibility';
SEP_IPX            : Result := 'Internetwork Packet Exchange (IPX)';
SEP_QNX            : Result := 'QNX Qnet';
SEP_IPv6           : Result := 'Internet Protocol Version 6 (IPv6)';
SEP_Efc            : Result := 'Ethernet flow control';
SEP_ESP            : Result := 'Ethernet Slow Protocols';
SEP_CN             : Result := 'CobraNet';
SEP_MPLSu          : Result := 'MPLS unicast';
SEP_MPLSm          : Result := 'MPLS multicast';
SEP_PPPoE_DS       : Result := 'PPPoE Discovery Stage';
SEP_PPPoE_SS       : Result := 'PPPoE Session Stage';
SEP_IANS           : Result := 'Intel Advanced Networking Services';
SEP_JF             : Result := 'Jumbo Frames (Obsoleted draft-ietf-isis-ext-eth-01)';
SEP_HPv1           : Result := 'HomePlug 1.0 MME';
SEP_EAPoL          : Result := 'EAP over LAN (IEEE 802.1X)';
SEP_PI             : Result := 'PROFINET Protocol';
SEP_HSCSI          : Result := 'HyperSCSI (SCSI over Ethernet)';
SEP_ATAoE          : Result := 'ATA over Ethernet';
SEP_EC             : Result := 'EtherCAT Protocol';
SEP_IEEE_PB        : Result := 'Provider Bridging (IEEE 802.1ad) & Shortest Path Bridging IEEE 802.1aq';
SEP_EP             : Result := 'Ethernet Powerlink';
SEP_GOOSE          : Result := 'GOOSE (Generic Object Oriented Substation event)';
SEP_GSEMS          : Result := 'GSE (Generic Substation Events) Management Services';
SEP_SVT            : Result := 'SV (Sampled Value Transmission)';
SEP_LLDP           : Result := 'Link Layer Discovery Protocol (LLDP)';
SEP_SERCOS3        : Result := 'SERCOS III';
SEP_WSMP           : Result := 'WSMP, WAVE Short Message Protocol';
SEP_HP_AV          : Result := 'HomePlug AV MME';
SEP_MRP            : Result := 'Media Redundancy Protocol (IEC62439-2)';
SEP_IEEE_MACs      : Result := 'MAC security (IEEE 802.1AE)';
SEP_PBB            : Result := 'Provider Backbone Bridges (PBB) (IEEE 802.1ah)';
SEP_PTP            : Result := 'Precision Time Protocol (PTP) over Ethernet (IEEE 1588)';
SEP_NC_SI          : Result := 'NC-SI';
SEP_PRP            : Result := 'Parallel Redundancy Protocol (PRP)';
SEP_IEEE_CFM       : Result := 'IEEE 802.1ag Connectivity Fault Management (CFM) Protocol / ITU-T Recommendation Y.1731 (OAM)';
SEP_FCoE           : Result := 'Fibre Channel over Ethernet (FCoE)';
SEP_FCoE_IP        : Result := 'FCoE Initialization Protocol';
SEP_RoCE           : Result := 'RDMA over Converged Ethernet (RoCE)';
SEP_TTE            : Result := 'TTEthernet Protocol Control Frame (TTE)';
SEP_HSR            : Result := 'High-availability Seamless Redundancy (HSR)';
SEP_ECTP           : Result := 'Ethernet Configuration Testing Protocol';
SEP_IEEE_VLAN      : Result := 'VLAN-tagged (IEEE 802.1Q) frame with double tagging';
else                  Result := '';
end;
end;

function TSTCPHeader.ReservedBitsAsBoolString() : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	Mask001 = $1;
	Mask010 = $2;
	Mask100 = $4;
var
	ReservedBitsValue : TSUInt8;
begin
ReservedBitsValue := ReservedBits;
Result := 
	SStr((ReservedBitsValue and Mask100) > 0) + ', ' +
	SStr((ReservedBitsValue and Mask010) > 0) + ', ' +
	SStr((ReservedBitsValue and Mask001) > 0);
end;

function TSTCPHeader.GetWindowSize() : TSUInt16;
begin
Result := FWindowSize;
SwapBytes(Result);
end;

function TSTCPHeader.GetChecksum() : TSUInt16;
begin
Result := FChecksum;
SwapBytes(Result);
end;

function TSTCPHeader.GetUrgentPointer() : TSUInt16;
begin
Result := FUrgentPointer;
SwapBytes(Result);
end;

function TSTCPHeader.GetSourcePort() : TSUInt16;
begin
Result := FSourcePort;
SwapBytes(Result);
end;

function TSTCPHeader.GetDestinationPort() : TSUInt16;
begin
Result := FDestinationPort;
SwapBytes(Result);
end;

function TSTCPHeader.GetSequenceNumber() : TSTcpSequence;
begin
Result := FSequenceNumber;
ReverseBytes(Result);
end;

function TSTCPHeader.GetAcknowledgementNumber() : TSTcpSequence;
begin
Result := FAcknowledgementNumber;
ReverseBytes(Result);
end;

function TSTCPHeader.GetHeaderSize() : TSUInt8;
var
	HeaderLenght : TSUInt16;
begin
HeaderLenght := FHeaderLenghtAndFlags;
SwapBytes(HeaderLenght);
HeaderLenght := HeaderLenght and STCPHeaderLength;
HeaderLenght := HeaderLenght shr 12;
Result := HeaderLenght * 4;
end;

function TSTCPHeader.GetReservedBits() : TSUInt8;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPReserved;
Flags := Flags shr 9;
Result := Flags;
end;

function TSTCPHeader.GetECN_Nonce() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPECN_Nonce;
Result := Flags > 0;
end;

function TSTCPHeader.GetCWR() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPCWR;
Result := Flags > 0;
end;

function TSTCPHeader.GetECN_Echo() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPECN_Echo;
Result := Flags > 0;
end;

function TSTCPHeader.GetUrgent() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPUrgent;
Result := Flags > 0;
end;

function TSTCPHeader.GetAcknowledgement() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPAcknowledgement;
Result := Flags > 0;
end;

function TSTCPHeader.GetPush() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPPush;
Result := Flags > 0;
end;

function TSTCPHeader.GetReset() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPReset;
Result := Flags > 0;
end;

function TSTCPHeader.GetSynchronize() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPSynchronize;
Result := Flags > 0;
end;

function TSTCPHeader.GetFinal() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPFinal;
Result := Flags > 0;
end;

function TSTCPHeader.IsFlagsEmpty() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FHeaderLenghtAndFlags;
SwapBytes(Flags);
Flags := Flags and STCPFlags;
Result := Flags = 0;
end;

operator := (const AddressValue : TSIPv4AddressValue) : TSIPv4Address; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Address := AddressValue;
end;

operator = (const Address1, Address2 : TSIPv4Address) : TSBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Address1.Address = Address2.Address;
end;

operator = (const Address : TSIPv4Address; const AddressValue : TSIPv4AddressValue) : TSBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Address.Address = AddressValue;
end;

operator <> (const Address : TSIPv4Address; const AddressValue : TSIPv4AddressValue) : TSBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Address.Address <> AddressValue;
end;

procedure Swap(var Address1, Address2 : TSIPv4Address); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Address : TSIPv4Address;
begin
Address := Address1;
Address1 := Address2;
Address2 := Address;
end;

procedure SIPv4AddressView(const Address : TSIPv4Address; const TextStream : TSTextStream; const ColorNumber, ColorPoint : TSUInt8);
begin
TextStream.TextColor(ColorNumber);
TextStream.Write(StringJustifyRight(SStr(Address.AddressByte[0]), 3, ' '));
TextStream.TextColor(ColorPoint);
TextStream.Write('.');
TextStream.TextColor(ColorNumber);
TextStream.Write(StringJustifyRight(SStr(Address.AddressByte[1]), 3, ' '));
TextStream.TextColor(ColorPoint);
TextStream.Write('.');
TextStream.TextColor(ColorNumber);
TextStream.Write(StringJustifyRight(SStr(Address.AddressByte[2]), 3, ' '));
TextStream.TextColor(ColorPoint);
TextStream.Write('.');
TextStream.TextColor(ColorNumber);
TextStream.Write(StringJustifyRight(SStr(Address.AddressByte[3]), 3, ' '));
TextStream.TextColor(ColorPoint);
end;

function SIPv4StringToAddress(const Address : TSString) : TSIPv4Address; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 0;
if (Address <> '') and (StringWordCount(Address, '.') = 4) then
	begin
	Result.AddressByte[0] := SVal(StringWordGet(Address, '.' ,1));
	Result.AddressByte[1] := SVal(StringWordGet(Address, '.' ,2));
	Result.AddressByte[2] := SVal(StringWordGet(Address, '.' ,3));
	Result.AddressByte[3] := SVal(StringWordGet(Address, '.' ,4));
	end;
end;

function SIPv4AddressToString(const Address : TSIPv4Address) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 
	SStr(Address.AddressByte[0]) + '.' +
	SStr(Address.AddressByte[1]) + '.' +
	SStr(Address.AddressByte[2]) + '.' +
	SStr(Address.AddressByte[3]) ;
end;

function TSIPv4Header.ReservedBit() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FFragment;
SwapBytes(Flags);
Result := (Flags and SIPReservedBit) > 0;
end;

function TSIPv4Header.DontFragment() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FFragment;
SwapBytes(Flags);
Result := (Flags and SIPDontFragment) > 0;
end;

function TSIPv4Header.MoreFragments() : TSBoolean;
var
	Flags : TSUInt16;
begin
Flags := FFragment;
SwapBytes(Flags);
Result := (Flags and SIPMoreFragments) > 0;
end;

function TSIPv4Header.FragmentOffset() : TSUInt16;
begin
Result := FFragment;
SwapBytes(Result);
Result := Result and SIPFragmentOffset;
end;

function TSIPv4Header.Checksum() : TSUInt16;
begin
Result := FChecksum;
SwapBytes(Result);
end;

function TSIPv4Header.Identification() : TSUInt16;
begin
Result := FIdentification;
SwapBytes(Result);
end;

function TSIPv4Header.TotalSize() : TSUInt16;
begin
Result := FTotalLength;
SwapBytes(Result);
end;

function TSIPv4Header.DifferentiatedServicesCodepoint() : TSUInt8;
begin
Result := (FDifferentiatedServices and SIPDifferentiatedServicesCodepoint) shr 2;
end;

function TSIPv4Header.ExpilitCongestionNotification() : TSUInt8;
begin
Result := FDifferentiatedServices and SIPExpilitCongestionNotification;
end;

function TSIPv4Header.HeaderSize() : TSUInt8;
begin
Result := (FVersionAndHeaderLength and SIPHeaderLengthMask) * 4;
end;

function TSIPv4Header.Version() : TSUInt8;
begin
Result := (FVersionAndHeaderLength and SIPVersionMask) shr 4;
end;

end.
