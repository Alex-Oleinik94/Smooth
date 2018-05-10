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
		FProtocol     : TSGEnthernetProtocolBytes; // IP? ARP? RARP? etc
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
		True : (Address     : TSGIPv4AddressValue);
		False: (AddressByte : TSGIPv4AddressBytes);
		end;

operator := (const AddressValue : TSGIPv4AddressValue) : TSGIPv4Address; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const Address : TSGIPv4Address; const AddressValue : TSGIPv4AddressValue) : TSGBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator <> (const Address : TSGIPv4Address; const AddressValue : TSGIPv4AddressValue) : TSGBoolean; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGIPv4AddressToString(const Address : TSGIPv4Address) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// IPv4 header
type
	TSGInternetProtocol = TSGUInt8;
	TSGIPv4Header = object
			public
		VersionAndHeaderLength : TSGUInt8;  // version | header length
		DifferentiatedServices : TSGUInt8;  // type of service
		FTotalLength           : TSGUInt16; // total length, Size(IPv4) + Size(IPv4.Protocol), without Ethernet header length
		FIdentification        : TSGUInt16; // identification
		FFragment              : TSGUInt16; // fragment offset field
		TimeToLive             : TSGUInt8;  // time to live
		Protocol               : TSGInternetProtocol; // protocol (TCP? UDP? etc)
		FChecksum              : TSGUInt16; // checksum
		Source, Destination    : TSGIPv4Address; // source and destination address
			public
		function Version()      : TSGUInt8;
		function HeaderLength() : TSGUInt8;
		function DifferentiatedServicesCodepoint() : TSGUInt8;
		function ExpilitCongestionNotification() : TSGUInt8;
		function TotalLength() : TSGUInt16;
		function Identification() : TSGUInt16;
		function ReservedBit() : TSGBoolean;
		function DontFragment() : TSGBoolean;
		function MoreFragments() : TSGBoolean;
		function FragmentOffset() : TSGUInt16;
		function Checksum() : TSGUInt16;
		end;

// Masks
const 
	SGIPVersionMask      = $f0; // 1111 .... version
	SGIPHeaderLengthMask = $0f; // .... 1111 header length
const
	SGIPDifferentiatedServicesCodepoint = $fc; // 1111 11.. 
	SGIPExpilitCongestionNotification   = $03; // .... ..11
const
	SGIPReservedBit    = $8000; // 1... .... .... .... reserved bit
	SGIPDontFragment   = $4000; // .1.. .... .... .... dont fragment flag
	SGIPMoreFragments  = $2000; // ..1. .... .... .... more fragments flag
	SGIPFragmentOffset = $1fff; // ...1 1111 1111 1111 mask for fragmenting bits

function SGInternetProtocolToString(const Protocol : TSGInternetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGInternetProtocolToStringExtended(const Protocol : TSGInternetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Internet protocols
const
	SGIP_HOPOPT = 0;     //IPv6 Hop-by-Hop Option
	SGIP_ICMP   = 1;     //Internet Control Message Protocol
	SGIP_IGMP   = 2;     //Internet Group Management Protocol
	SGIP_GGP    = 3;     //Gateway-to-Gateway Protocol
	SGIP_IPv4   = 4;     //IPv4 (encapsulation)
	SGIP_ST     = 5;     //Internet Stream Protocol
	SGIP_TCP    = 6;     //Transmission Control Protocol
	SGIP_CBT    = 7;     //Core-based trees
	SGIP_EGP    = 8;     //Exterior Gateway Protocol
	SGIP_IGP    = 9;     //Interior Gateway Protocol
	SGIP_BBN_RCC_MON = 10; //BBN RCC Monitoring
	SGIP_NVP_II = 11;    //Network Voice Protocol
	SGIP_PUP    = 12;    //Xerox PUP
	SGIP_ARGUS  = 13;    //ARGUS
	SGIP_EMCON  = 14;    //EMCON
	SGIP_XNET   = 15;    //Cross Net Debugger
	SGIP_CHAOS  = 16;    //Chaosnet
	SGIP_UDP    = 17;    //User Datagram Protocol
	SGIP_MUX    = 18;    //Multiplexing
	SGIP_DCN_MEAS = 19;  //DCN Measurement Subsystems
	SGIP_HMP    = 20;    //Host Monitoring Protocol
	SGIP_PRM    = 21;    //Packet Radio Measurement
	SGIP_XNS_IDP = 22;   //XEROX NS IDP
	SGIP_TRUNK_1 = 23;   //Trunk-1
	SGIP_TRUNK_2 = 24;   //Trunk-2
	SGIP_LEAF_1 = 25;    //Leaf-1
	SGIP_LEAF_2 = 26;    //Leaf-2
	SGIP_RDP    = 27;    //Reliable Datagram Protocol
	SGIP_IRTP   = 28;    //Internet Reliable Transaction Protocol
	SGIP_ISO_TP4 = 29;   //ISO Transport Protocol Class 4
	SGIP_NETBLT = 30;    //Bulk Data Transfer Protocol
	SGIP_MFE_NSP = 31;   //MFE Network Services Protocol
	SGIP_MERIT_INP = 32; //MERIT Internodal Protocol
	SGIP_DCCP   = 33;    //Datagram Congestion Control Protocol
	SGIP_3PC    = 34;    //Third Party Connect Protocol
	SGIP_IDPR   = 35;    //Inter-Domain Policy Routing Protocol    
	SGIP_XTP    = 36;    //Xpress Transport Protocol
	SGIP_DDP    = 37;    //Datagram Delivery Protocol
	SGIP_IDPR_CMTP = 38; //IDPR Control Message Transport Protocol
	SGIP_TPpp   = 39;    //TP++ Transport Protocol
	SGIP_IL     = 40;    //IL Protocol
	SGIP_IPv6   = 41;    //IPv6 (Encapsulation)
	SGIP_SDRP   = 42;    //Source Demand Routing Protocol
	SGIP_IPv6_Route = 43; //Routing Header for IPv6
	SGIP_IPv6_Frag = 44; //Fragment Header for IPv6
	SGIP_IDRP   = 45;    //Inter-Domain Routing Protocol
	SGIP_RSVP   = 46;    //Resource Reservation Protocol
	SGIP_GRE    = 47;    //Generic Routing Encapsulation
	SGIP_MHRP   = 48;    //Mobile Host Routing Protocol
	SGIP_BNA    = 49;    //BNA    
	SGIP_ESP    = 50;    //Encapsulating Security Payload
	SGIP_AH     = 51;    //Authentication Header
	SGIP_I_NLSP = 52;    //Integrated Net Layer Security Protocol
	SGIP_SWIPE  = 53;    //SwIPe
	SGIP_NARP   = 54;    //NBMA Address Resolution Protocol
	SGIP_MOBILE = 55;    //Mobile IP (Min Encap)
	SGIP_TLSP   = 56;    //Transport Layer Security Protocol (using Kryptonet key management)
	SGIP_SKIP   = 57;    //Simple Key-Management for Internet Protocol
	SGIP_IPv6_ICMP = 58; //ICMP for IPv6
	SGIP_IPv6_NoNxt = 59; //No Next Header for IPv6
	SGIP_IPv6_Opts = 60; //Destination Options for IPv6
	SGIP__AHIP  = 61;    //Any host internal protocol
	SGIP_CFTP   = 62;    //CFTP
	SGIP__ALN   = 63;    //Any local network
	SGIP_SAT_EXPAK = 64; //SATNET and Backroom EXPAK
	SGIP_KRYPTOLAN = 65; //Kryptolan
	SGIP_RVD    = 66;    //Remote Virtual Disk Protocol
	SGIP_IPPC   = 67;    //Internet Pluribus Packet Core
	SGIP__ADFS  = 68;    //Any distributed file system
	SGIP_SAT_MON = 69;   //SATNET Monitoring
	SGIP_VISA   = 70;    //VISA Protocol
	SGIP_IPCV   = 71;    //Internet Packet Core Utility
	SGIP_CPNX   = 72;    //Computer Protocol Network Executive
	SGIP_CPHB   = 73;    //Computer Protocol Heart Beat
	SGIP_WSN    = 74;    //Wang Span Network
	SGIP_PVP    = 75;    //Packet Video Protocol
	SGIP_BR_SAT_MON = 76; //Backroom SATNET Monitoring
	SGIP_SUN_ND = 77;    //SUN ND PROTOCOL-Temporary
	SGIP_WB_MON = 78;    //WIDEBAND Monitoring
	SGIP_WB_EXPAK = 79;  //WIDEBAND EXPAK
	SGIP_ISO_IP = 80;    //International Organization for Standardization Internet Protocol
	SGIP_VMTP   = 81;    //Versatile Message Transaction Protocol
	SGIP_SECURE_VMTP = 82; //Secure Versatile Message Transaction Protocol
	SGIP_VINES  = 83;    //VINES
	SGIP_TTP    = 84;    //TTP
	SGIP_IPTM   = 84;    //Internet Protocol Traffic Manager
	SGIP_NSFNET_IGP = 85; //NSFNET-IGP
	SGIP_DGP    = 86;    //Dissimilar Gateway Protocol
	SGIP_TCF    = 87;    //TCF
	SGIP_EIGRP  = 88;    //EIGRP
	SGIP_OSPF   = 89;    //Open Shortest Path First
	SGIP_Sprite_RPC = 90; //Sprite RPC Protocol
	SGIP_LARP   = 91;    //Locus Address Resolution Protocol
	SGIP_MTP    = 92;    //Multicast Transport Protocol
	SGIP_AX_25  = 93;    //AX.25
	SGIP_IPIP   = 94;    //IP-within-IP Encapsulation Protocol
	SGIP_MICP   = 95;    //Mobile Internetworking Control Protocol
	SGIP_SCC_SP = 96;    //Semaphore Communications Sec. Pro
	SGIP_ETHERIP = 97;   //Ethernet-within-IP Encapsulation
	SGIP_ENCAP  = 98;    //Encapsulation Header
	SGIP__APES  = 99;    //Any private encryption scheme
	SGIP_GMTP   = 100;   //GMTP
	SGIP_IFMP   = 101;   //Ipsilon Flow Management Protocol
	SGIP_PNNI   = 102;   //PNNI over IP
	SGIP_PIM    = 103;   //Protocol Independent Multicast
	SGIP_ARIS   = 104;   //IBM''s ARIS (Aggregate Route IP Switching) Protocol    
	SGIP_SCPS   = 105;   //SCPS (Space Communications Protocol Standards)]
	SGIP_AN     = 107;   //Active Networks
	SGIP_IPComp = 108;   //IP Payload Compression Protocol
	SGIP_SNP    = 109;   //Sitara Networks Protocol
	SGIP_Compaq_Peer = 110; //Compaq Peer Protocol
	SGIP_IPX_in_IP = 111; //IPX in IP
	SGIP_VRRP   = 112;   //Virtual Router Redundancy Protocol
	SGIP_PGM    = 113;   //PGM Reliable Transport Protocol
	SGIP__A0LP  = 114;   //Any 0-hop protocol
	SGIP_L2TP   = 115;   //Layer Two Tunneling Protocol Version 3
	SGIP_DDX    = 116;   //D-II Data Exchange (DDX)
	SGIP_IATP   = 117;   //Interactive Agent Transfer Protocol
	SGIP_STP    = 118;   //Schedule Transfer Protocol
	SGIP_SRP    = 119;   //SpectraLink Radio Protocol
	SGIP_UTI    = 120;   //UTI
	SGIP_SMP    = 121;   //Simple Message Protocol
	SGIP_SM     = 122;   //SM
	SGIP_PTP    = 123;   //Performance Transparency Protocol
	SGIP_IS_ISoIPv4 = 124; //IS-IS over IPv4
	SGIP_FIRE   = 125;   //Flexible Intra-AS Routing Environment
	SGIP_CRTP   = 126;   //Combat Radio Transport Protocol
	SGIP_CRUDP  = 127;   //Combat Radio User Datagram
	SGIP_SSCOPMCE = 128; //Service-Specific Connection-Oriented Protocol in a Multilink and Connectionless Environment
	SGIP_IPLT   = 129;
	SGIP_SPS    = 130;   //Secure Packet Shield
	SGIP_PIPE   = 131;   //Private IP Encapsulation within IP
	SGIP_SCTP   = 132;   //Stream Control Transmission Protocol 
	SGIP_FC     = 133;   //Fibre Channel
	SGIP_RSVP_E2E_IGNORE = 134; //Reservation Protocol (RSVP) End-to-End Ignore
	SGIP__MH    = 135;   //Mobility Header
	SGIP_UDPL   = 136;   //UDP Lite
	SGIP_MPLS_in_IP = 137; //MPLS-in-IP
	SGIP_manet  = 138;   //MANET Protocols
	SGIP_HIP    = 139;   //Host Identity Protocol
	SGIP_Shim6  = 140;   //Site Multihoming by IPv6 Intermediation
	SGIP_WESP   = 141;   //Wrapped Encapsulating Security Payload
	SGIP_ROHC   = 142;   //Robust Header Compression
	SGIP__empty : TSGSetOfByte = [143..252]; // UNASSIGNED
	SGIP__TEST  : TSGSetOfByte = [253..254]; // Use for experimentation and testing
	SGIP__255   = 255;   // Reserved for extra.

// ARP Header, (assuming Ethernet + IPv4)
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

function SGInternetProtocolToStringExtended(const Protocol : TSGInternetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=  SGInternetProtocolToString(Protocol);
if Result = '' then
	Result := 'Unknown Internet Protocol';
Result := '(0x' + SGStrByteHex(Protocol, False) + '[hex], ' + SGStr(Protocol) + '[dec]) ' + Result;
end;

function SGInternetProtocolToString(const Protocol : TSGInternetProtocol) : TSGString; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Protocol of
SGIP_HOPOPT : Result := 'IPv6 Hop-by-Hop Option';
SGIP_ICMP   : Result := 'Internet Control Message Protocol';
SGIP_IGMP   : Result := 'Internet Group Management Protocol';
SGIP_GGP    : Result := 'Gateway-to-Gateway Protocol';
SGIP_IPv4   : Result := 'IPv4 (encapsulation)';
SGIP_ST     : Result := 'Internet Stream Protocol';
SGIP_TCP    : Result := 'Transmission Control Protocol';
SGIP_CBT    : Result := 'Core-based trees';
SGIP_EGP    : Result := 'Exterior Gateway Protocol';
SGIP_IGP    : Result := 'Interior Gateway Protocol';
SGIP_BBN_RCC_MON : Result := 'BBN RCC Monitoring';
SGIP_NVP_II : Result := 'Network Voice Protocol';
SGIP_PUP    : Result := 'Xerox PUP';
SGIP_ARGUS  : Result := 'ARGUS';
SGIP_EMCON  : Result := 'EMCON';
SGIP_XNET   : Result := 'Cross Net Debugger';
SGIP_CHAOS  : Result := 'Chaosnet';
SGIP_UDP    : Result := 'User Datagram Protocol';
SGIP_MUX    : Result := 'Multiplexing';
SGIP_DCN_MEAS : Result := 'DCN Measurement Subsystems';
SGIP_HMP    : Result := 'Host Monitoring Protocol';
SGIP_PRM    : Result := 'Packet Radio Measurement';
SGIP_XNS_IDP : Result := 'XEROX NS IDP';
SGIP_TRUNK_1 : Result := 'Trunk-1';
SGIP_TRUNK_2 : Result := 'Trunk-2';
SGIP_LEAF_1 : Result := 'Leaf-1';
SGIP_LEAF_2 : Result := 'Leaf-2';
SGIP_RDP    : Result := 'Reliable Datagram Protocol';
SGIP_IRTP   : Result := 'Internet Reliable Transaction Protocol';
SGIP_ISO_TP4 : Result := 'ISO Transport Protocol Class 4';
SGIP_NETBLT : Result := 'Bulk Data Transfer Protocol';
SGIP_MFE_NSP : Result := 'MFE Network Services Protocol';
SGIP_MERIT_INP : Result := 'MERIT Internodal Protocol';
SGIP_DCCP   : Result := 'Datagram Congestion Control Protocol';
SGIP_3PC    : Result := 'Third Party Connect Protocol';
SGIP_IDPR   : Result := 'Inter-Domain Policy Routing Protocol';
SGIP_XTP    : Result := 'Xpress Transport Protocol';
SGIP_DDP    : Result := 'Datagram Delivery Protocol';
SGIP_IDPR_CMTP: Result := 'IDPR Control Message Transport Protocol';
SGIP_TPpp   : Result := 'TP++ Transport Protocol';
SGIP_IL     : Result := 'IL Protocol';
SGIP_IPv6   : Result := 'IPv6 (Encapsulation)';
SGIP_SDRP   : Result := 'Source Demand Routing Protocol';
SGIP_IPv6_Route: Result := 'Routing Header for IPv6';
SGIP_IPv6_Frag : Result := 'Fragment Header for IPv6';
SGIP_IDRP   : Result := 'Inter-Domain Routing Protocol';
SGIP_RSVP   : Result := 'Resource Reservation Protocol';
SGIP_GRE    : Result := 'Generic Routing Encapsulation';
SGIP_MHRP   : Result := 'Mobile Host Routing Protocol';
SGIP_BNA    : Result := 'Burroughs Network Architecture';
SGIP_ESP    : Result := 'Encapsulating Security Payload';
SGIP_AH     : Result := 'Authentication Header';
SGIP_I_NLSP : Result := 'Integrated Net Layer Security Protocol';
SGIP_SWIPE  : Result := 'SwIPe';
SGIP_NARP   : Result := 'NBMA Address Resolution Protocol';
SGIP_MOBILE: Result := 'Mobile IP (Min Encap)';
SGIP_TLSP   : Result := 'Transport Layer Security Protocol (using Kryptonet key management)';
SGIP_SKIP   : Result := 'Simple Key-Management for Internet Protocol';
SGIP_IPv6_ICMP : Result := 'ICMP for IPv6';
SGIP_IPv6_NoNxt : Result := 'No Next Header for IPv6';
SGIP_IPv6_Opts : Result := 'Destination Options for IPv6';
SGIP__AHIP  : Result := 'Any host internal protocol';
SGIP_CFTP   : Result := 'CFTP';
SGIP__ALN   : Result := 'Any local network';
SGIP_SAT_EXPAK : Result := 'SATNET and Backroom EXPAK';
SGIP_KRYPTOLAN : Result := 'Kryptolan';
SGIP_RVD    : Result := 'Remote Virtual Disk Protocol';
SGIP_IPPC   : Result := 'Internet Pluribus Packet Core';
SGIP__ADFS  : Result := 'Any distributed file system';
SGIP_SAT_MON : Result := 'SATNET Monitoring';
SGIP_VISA   : Result := 'VISA Protocol';
SGIP_IPCV   : Result := 'Internet Packet Core Utility';
SGIP_CPNX   : Result := 'Computer Protocol Network Executive';
SGIP_CPHB   : Result := 'Computer Protocol Heart Beat';
SGIP_WSN    : Result := 'Wang Span Network';
SGIP_PVP    : Result := 'Packet Video Protocol';
SGIP_BR_SAT_MON : Result := 'Backroom SATNET Monitoring';
SGIP_SUN_ND : Result := 'SUN ND PROTOCOL-Temporary';
SGIP_WB_MON : Result := 'WIDEBAND Monitoring';
SGIP_WB_EXPAK : Result := 'WIDEBAND EXPAK';
SGIP_ISO_IP : Result := 'International Organization for Standardization Internet Protocol';
SGIP_VMTP   : Result := 'Versatile Message Transaction Protocol';
SGIP_SECURE_VMTP : Result := 'Secure Versatile Message Transaction Protocol';
SGIP_VINES  : Result := 'VINES';
SGIP_TTP{=SGIP_IPTM} : Result := '(TTP) or (Internet Protocol Traffic Manager)';
SGIP_NSFNET_IGP: Result := 'NSFNET-IGP';
SGIP_DGP    : Result := 'Dissimilar Gateway Protocol';
SGIP_TCF    : Result := 'TCF';
SGIP_EIGRP  : Result := 'EIGRP';
SGIP_OSPF   : Result := 'Open Shortest Path First';
SGIP_Sprite_RPC : Result := 'Sprite RPC Protocol';
SGIP_LARP   : Result := 'Locus Address Resolution Protocol';
SGIP_MTP    : Result := 'Multicast Transport Protocol';
SGIP_AX_25  : Result := 'AX.25';
SGIP_IPIP   : Result := 'IP-within-IP Encapsulation Protocol';
SGIP_MICP   : Result := 'Mobile Internetworking Control Protocol';
SGIP_SCC_SP : Result := 'Semaphore Communications Sec. Pro';
SGIP_ETHERIP : Result := 'Ethernet-within-IP Encapsulation';
SGIP_ENCAP  : Result := 'Encapsulation Header';
SGIP__APES  : Result := 'Any private encryption scheme';
SGIP_GMTP   : Result := 'GMTP';
SGIP_IFMP   : Result := 'Ipsilon Flow Management Protocol';
SGIP_PNNI   : Result := 'PNNI over IP';
SGIP_PIM    : Result := 'Protocol Independent Multicast';
SGIP_ARIS   : Result := 'IBM''s ARIS (Aggregate Route IP Switching) Protocol';
SGIP_SCPS   : Result := 'SCPS (Space Communications Protocol Standards)]';
SGIP_AN     : Result := 'Active Networks';
SGIP_IPComp : Result := 'IP Payload Compression Protocol';
SGIP_SNP    : Result := 'Sitara Networks Protocol';
SGIP_Compaq_Peer : Result := 'Compaq Peer Protocol';
SGIP_IPX_in_IP : Result := 'IPX in IP';
SGIP_VRRP   : Result := 'Virtual Router Redundancy Protocol';
SGIP_PGM    : Result := 'PGM Reliable Transport Protocol';
SGIP__A0LP  : Result := 'Any 0-hop protocol';
SGIP_L2TP   : Result := 'Layer Two Tunneling Protocol Version 3';
SGIP_DDX    : Result := 'D-II Data Exchange (DDX)';
SGIP_IATP   : Result := 'Interactive Agent Transfer Protocol';
SGIP_STP    : Result := 'Schedule Transfer Protocol';
SGIP_SRP    : Result := 'SpectraLink Radio Protocol';
SGIP_UTI    : Result := 'Universal Transport Interface Protocol';
SGIP_SMP    : Result := 'Simple Message Protocol';
SGIP_SM     : Result := 'Simple Multicast Protocol';
SGIP_PTP    : Result := 'Performance Transparency Protocol';
SGIP_IS_ISoIPv4 : Result := 'IS-IS over IPv4';
SGIP_FIRE   : Result := 'Flexible Intra-AS Routing Environment';
SGIP_CRTP   : Result := 'Combat Radio Transport Protocol';
SGIP_CRUDP  : Result := 'Combat Radio User Datagram';
SGIP_SSCOPMCE : Result := 'Service-Specific Connection-Oriented Protocol in a Multilink and Connectionless Environment';
SGIP_IPLT   : Result := 'IPLT';
SGIP_SPS    : Result := 'Secure Packet Shield';
SGIP_PIPE   : Result := 'Private IP Encapsulation within IP';
SGIP_SCTP   : Result := 'Stream Control Transmission Protocol';
SGIP_FC     : Result := 'Fibre Channel';
SGIP_RSVP_E2E_IGNORE : Result := 'Reservation Protocol (RSVP) End-to-End Ignore';
SGIP__MH    : Result := 'Mobility Header';
SGIP_UDPL   : Result := 'UDP Lite';
SGIP_MPLS_in_IP : Result := 'MPLS-in-IP';
SGIP_manet  : Result := 'MANET Protocols';
SGIP_HIP    : Result := 'Host Identity Protocol';
SGIP_Shim6  : Result := 'Site Multihoming by IPv6 Intermediation';
SGIP_WESP   : Result := 'Wrapped Encapsulating Security Payload';
SGIP_ROHC   : Result := 'Robust Header Compression';
SGIP__255   : Result := 'Protocol wich reserved for extra';
else if Protocol in SGIP__TEST then Result := 'Protocol wich uses for experimentation and testing'
else Result := '';
end;
end;

function TSGEthernetHeader.GetProtocol() : TSGEnthernetProtocol;
begin
Result := TSGEnthernetProtocol(FProtocol);
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
	Result := 'Unknown Ethernet Protocol';
Result := '(0x' + SGStr2BytesHex(Protocol, False) + '[hex], ' + SGStr(Protocol) + '[dec]) ' + Result;
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

function TSGIPv4Header.ReservedBit() : TSGBoolean;
var
	Flags : TSGUInt16;
begin
Flags := FFragment;
SwapBytes(Flags);
Result := (Flags and SGIPReservedBit) > 0;
end;

function TSGIPv4Header.DontFragment() : TSGBoolean;
var
	Flags : TSGUInt16;
begin
Flags := FFragment;
SwapBytes(Flags);
Result := (Flags and SGIPDontFragment) > 0;
end;

function TSGIPv4Header.MoreFragments() : TSGBoolean;
var
	Flags : TSGUInt16;
begin
Result := (Flags and SGIPMoreFragments) > 0;
end;

function TSGIPv4Header.FragmentOffset() : TSGUInt16;
begin
Result := FFragment;
SwapBytes(Result);
Result := Result and SGIPFragmentOffset;
end;

function TSGIPv4Header.Checksum() : TSGUInt16;
begin
Result := FChecksum;
SwapBytes(Result);
end;

function TSGIPv4Header.Identification() : TSGUInt16;
begin
Result := FIdentification;
SwapBytes(Result);
end;

function TSGIPv4Header.TotalLength() : TSGUInt16;
begin
Result := FTotalLength;
SwapBytes(Result);
end;

function TSGIPv4Header.DifferentiatedServicesCodepoint() : TSGUInt8;
begin
Result := (DifferentiatedServices and SGIPDifferentiatedServicesCodepoint) shr 2;
end;

function TSGIPv4Header.ExpilitCongestionNotification() : TSGUInt8;
begin
Result := DifferentiatedServices and SGIPExpilitCongestionNotification;
end;

function TSGIPv4Header.HeaderLength() : TSGUInt8;
begin
Result := (VersionAndHeaderLength and SGIPHeaderLengthMask) * 4;
end;

function TSGIPv4Header.Version() : TSGUInt8;
begin
Result := (VersionAndHeaderLength and SGIPVersionMask) shr 4;
end;

end.
