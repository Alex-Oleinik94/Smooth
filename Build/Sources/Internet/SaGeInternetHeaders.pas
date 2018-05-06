{$INCLUDE SaGe.inc}

unit SaGeInternetHeaders;

interface

uses
	 SaGeBase
	;

// Ethernet headers are always exactly 14 bytes
const SG_ETHERNET_SIZE = 14;

// Ethernet addresses are 6 bytes
const SG_ETHERNET_ADDRESS_LENGHT = 6;

type TSGEnthernetAddress = packed array[0..SG_ETHERNET_ADDRESS_LENGHT-1] of TSGUInt8;

// Ethernet header
type TSGEthernetHeader = object
		public
	ether_dhost : TSGEnthernetAddress; // Destination host address
	ether_shost : TSGEnthernetAddress; // Source host address
	ether_type : TSGUInt16; // IP? ARP? RARP? etc
	end;

// IPv4 address
type
	PSGIPv4Address = ^TSGIPv4Address;
	TSGIPv4Address = packed record
		case TSGBoolean of
		True: (s_addr  : TSGUInt32);
		False: (s_bytes : packed array[1..4] of TSGUInt8);
	end;

// IPv4 header
type TSGIPv4Header = object
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
const SG_ARP_REQUEST = 1;   // ARP Request              
const SG_ARP_REPLY = 2;     // ARP Reply                
type TSGARPIPv4Header = object 
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

// TCP Sequence
type TSGTcpSequence = TSGUInt16;

// TCP header
type TSGTcpHeader = object
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
type TSGUDPHeader = object
	uh_sport : TSGUInt16;
	uh_dport : TSGUInt16;
	uh_len   : TSGUInt16;
	uh_check : TSGUInt16;
	end;

implementation

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
