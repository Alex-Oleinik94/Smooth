{$INCLUDE Smooth.inc}

// =====================================
// PCap Next Generation Dump File Format
// =====================================
// CaptureFileFormat

unit SmoothPCapNGFile;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothStreamUtils
	
	,Classes
	;

type
	TSPCapNGDefaultNumber    = TSUInt32;
	TSPCapNGBlockType        = TSPCapNGDefaultNumber;
	TSPCapNGBlockTotalLength = TSPCapNGDefaultNumber;

// Standardized Block Type Codes
const
	SPCapNG_Null    = $00000000; // Reserved ???
	SPCapNG_IDB     = $00000001; // Interface Description Block
	SPCapNG_PB      = $00000002; // Packet Block
	SPCapNG_SPB     = $00000003; // Simple Packet Block
	SPCapNG_NRB     = $00000004; // Name Resolution Block
	SPCapNG_ISB     = $00000005; // Interface Statistics Block
	SPCapNG_EPB     = $00000006; // Enhanced Packet Block
	SPCapNG_TB      = $00000007; //     IRIG Timestamp Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC); 
	                              // code also used for Socket Aggregation Event Block
	SPCapNG_EIB     = $00000008; //     ARINC 429 in AFDX Encapsulation Information Block 
	                              // (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)
	SPCapNG_HP_MIB  = $00000101; // Hone Project Machine Info Block (see also Google version)
	SPCapNG_HP_CEB  = $00000102; // Hone Project Connection Event Block (see also Google version)
	SPCapNG_S_MIB   = $00000201; // Sysdig Machine Info Block
	SPCapNG_S_PIBv1 = $00000202; // Sysdig Process Info Block, version 1
	SPCapNG_S_FDLB  = $00000203; // Sysdig FD List Block
	SPCapNG_S_EB    = $00000204; // Sysdig Event Block
	SPCapNG_S_ILB   = $00000205; // Sysdig Interface List Block
	SPCapNG_S_ULB   = $00000206; // Sysdig User List Block
	SPCapNG_S_PIBv2 = $00000207; // Sysdig Process Info Block, version 2
	SPCapNG_S_EBwf  = $00000208; // Sysdig Event Block with flags
	SPCapNG_S_PIBv3 = $00000209; // Sysdig Process Info Block, version 3
	SPCapNG_S_PIBv4 = $00000210; // Sysdig Process Info Block, version 4
	SPCapNG_S_PIBv5 = $00000211; // Sysdig Process Info Block, version 5
	SPCapNG_S_PIBv6 = $00000212; // Sysdig Process Info Block, version 6
	SPCapNG_S_PIBv7 = $00000213; // Sysdig Process Info Block, version 7
	SPCapNG_CBc     = $00000BAD; // Custom Block that rewriters can copy into new files
	SPCapNG_CBnc    = $40000BAD; // Custom Block that rewriters should not copy into new files
	SPCapNG_SHB     = $0A0D0D0A; // Section Header Block

// Reserved Block Type Codes
const
	// Reserved. Used to detect trace files corrupted because of file transfers using the HTTP protocol in text mode.
	SPCapNG_R_DTFhttp1_b = $0A0D0A00; // beginning of the set
	SPCapNG_R_DTFhttp1_e = $0A0D0AFF; // end of set
	SPCapNG_R_DTFhttp2_b = $000A0D0A; // beginning of the set
	SPCapNG_R_DTFhttp2_e = $FF0A0D0A; // end of set
	SPCapNG_R_DTFhttp3_b = $000A0D0D; // beginning of the set
	SPCapNG_R_DTFhttp3_e = $FF0A0D0D; // end of set
	// Reserved. Used to detect trace files corrupted because of file transfers using the FTP protocol in text mode.
	SPCapNG_R_DTFftp_b   = $0D0D0A00; // beginning of the set
	SPCapNG_R_DTFftp_e   = $0D0D0AFF; // end of set
	// Reserved for local use.
	SPCapNG_R_LU_b       = $80000000; // beginning of the set
	SPCapNG_R_LU_e       = $FFFFFFFF; // end of set

type
	TSPCapNGEnhancedPacketBlock = object
			public
		FInterfaceIdentifier : TSPCapNGDefaultNumber;
		FTimestampHign       : TSPCapNGDefaultNumber;
		FTimestampLow        : TSPCapNGDefaultNumber;
		FCapturedLength      : TSPCapNGDefaultNumber;
		FPacketLength        : TSPCapNGDefaultNumber;
		end;

type
	TSPCapNGFile = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FFileName : TSString;
		FStream : TStream;
			public
		property FileName : TSString read FFileName write FFileName;
			protected
		procedure KillStream();
			public
		function CreateInput(const InputType : TSInputStreamType = SInputMemoryStream) : TSBoolean;
		procedure ParseStructure();
		procedure OpenFile();
		function FindNextPacketData() : TStream;
		function FindBlock(const BlockType : TSPCapNGBlockType) : TSBoolean;
		end;

function SStrPCapNGBlock(const BlockType : TSPCapNGBlockType) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SStrPCapNGBlockExtended(const BlockType : TSPCapNGBlockType) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	;

function SStrPCapNGBlockExtended(const BlockType : TSPCapNGBlockType) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := SStrPCapNGBlock(BlockType);
if Result = '' then
	Result := 'Unknown Block Type';
Result := '(0x' + SStr4BytesHex(BlockType, True) + ') ' + Result;
end;

function SStrPCapNGBlock(const BlockType : TSPCapNGBlockType) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case BlockType of
SPCapNG_Null    : Result := 'Reserved ???';
SPCapNG_IDB     : Result := 'Interface Description Block';
SPCapNG_PB      : Result := 'Packet Block';
SPCapNG_SPB     : Result := 'Simple Packet Block';
SPCapNG_NRB     : Result := 'Name Resolution Block';
SPCapNG_ISB     : Result := 'Interface Statistics Block';
SPCapNG_EPB     : Result := 'Enhanced Packet Block';
SPCapNG_TB      : Result := 'IRIG Timestamp Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC); code also used for Socket Aggregation Event Block';
SPCapNG_EIB     : Result := 'ARINC 429 in AFDX Encapsulation Information Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)';
SPCapNG_HP_MIB  : Result := 'Hone Project Machine Info Block (see also Google version)';
SPCapNG_HP_CEB  : Result := 'Hone Project Connection Event Block (see also Google version)';
SPCapNG_S_MIB   : Result := 'Sysdig Machine Info Block';
SPCapNG_S_PIBv1 : Result := 'Sysdig Process Info Block, version 1';
SPCapNG_S_FDLB  : Result := 'Sysdig FD List Block';
SPCapNG_S_EB    : Result := 'Sysdig Event Block';
SPCapNG_S_ILB   : Result := 'Sysdig Interface List Block';
SPCapNG_S_ULB   : Result := 'Sysdig User List Block';
SPCapNG_S_PIBv2 : Result := 'Sysdig Process Info Block, version 2';
SPCapNG_S_EBwf  : Result := 'Sysdig Event Block with flags';
SPCapNG_S_PIBv3 : Result := 'Sysdig Process Info Block, version 3';
SPCapNG_S_PIBv4 : Result := 'Sysdig Process Info Block, version 4';
SPCapNG_S_PIBv5 : Result := 'Sysdig Process Info Block, version 5';
SPCapNG_S_PIBv6 : Result := 'Sysdig Process Info Block, version 6';
SPCapNG_S_PIBv7 : Result := 'Sysdig Process Info Block, version 7';
SPCapNG_CBc     : Result := 'Custom Block that rewriters can copy into new files';
SPCapNG_CBnc    : Result := 'Custom Block that rewriters should not copy into new files';
SPCapNG_SHB     : Result := 'Section Header Block';
else if ((BlockType >= SPCapNG_R_DTFhttp1_b) and (BlockType <= SPCapNG_R_DTFhttp1_e)) or
	    ((BlockType >= SPCapNG_R_DTFhttp2_b) and (BlockType <= SPCapNG_R_DTFhttp2_e)) or 
	    ((BlockType >= SPCapNG_R_DTFhttp3_b) and (BlockType <= SPCapNG_R_DTFhttp3_e)) then
	Result := 'Reserved. Used to detect trace files corrupted because of file transfers using the HTTP protocol in text mode.'
else if ((BlockType >= SPCapNG_R_DTFftp_b) and (BlockType <= SPCapNG_R_DTFftp_e)) then
	Result := 'Reserved. Used to detect trace files corrupted because of file transfers using the FTP protocol in text mode.'
else if ((BlockType >= SPCapNG_R_LU_b) and (BlockType <= SPCapNG_R_LU_e)) then
	Result := 'Reserved for local use.'
else
	Result := '';
end;
end;

procedure TSPCapNGFile.KillStream();
begin
if FStream <> nil then
	begin
	FStream.Destroy();
	FStream := nil;
	end;
end;

function TSPCapNGFile.CreateInput(const InputType : TSInputStreamType = SInputMemoryStream) : TSBoolean;
begin
KillStream();
if FFileName <> '' then
	FStream := SCreateInputStream(FFileName, InputType);
Result := FStream <> nil;
end;

procedure TSPCapNGFile.OpenFile();
begin
CreateInput();
end;

function TSPCapNGFile.FindNextPacketData() : TStream;
var
	BlockSize : TSPCapNGDefaultNumber = 0;
	EndPosition : TSUInt64 = 0;
	PacketBlock : TSPCapNGEnhancedPacketBlock;
begin
Result := nil;
if not FindBlock(SPCapNG_EPB) then
	exit;
FStream.ReadBuffer(BlockSize, SizeOf(BlockSize));
EndPosition := FStream.Position + BlockSize - 8;
FStream.ReadBuffer(PacketBlock, SizeOf(PacketBlock));
Result := TMemoryStream.Create();
SCopyPartStreamToStream(FStream, Result, PacketBlock.FCapturedLength);
Result.Position := 0;
FStream.Position := EndPosition;
end;

function TSPCapNGFile.FindBlock(const BlockType : TSPCapNGBlockType) : TSBoolean;
var
	Block : TSPCapNGBlockType;
	BlockLength : TSPCapNGBlockType;
begin
Result := False;
if (FStream = nil) or (FStream.Position + 12 > FStream.Size) then
	exit;
repeat
FStream.ReadBuffer(Block, SizeOf(Block));
if BlockType = Block then
	begin
	Result := True;
	break;
	end
else
	begin
	FStream.ReadBuffer(BlockLength, SizeOf(BlockLength));
	FStream.Position := FStream.Position + BlockLength - 8;
	end;
until FStream.Position + 8 >= FStream.Size;
end;

procedure TSPCapNGFile.ParseStructure();

function ReadBlock() : TSBoolean;
var
	BlockType : TSPCapNGBlockType;
	BlockSize : TSPCapNGBlockType;
	NextBlockPosition : TSPCapNGBlockType;
begin
Result := False;
if FStream.Position + 8 >= FStream.Size then
	begin
	SHint(['PCapNG__ParseStructure : End of file.']);
	exit;
	end;
FStream.ReadBuffer(BlockType, SizeOf(BlockType));
FStream.ReadBuffer(BlockSize, SizeOf(BlockSize));
SHint(['PCapNG__ParseStructure : BlockType = ', SStrPCapNGBlockExtended(BlockType)]);
SHint(['PCapNG__ParseStructure : BlockTotalLength = ', BlockSize]);
NextBlockPosition := FStream.Position + BlockSize - 8;
if NextBlockPosition > FStream.Size then
	begin
	SHint(['PCapNG__ParseStructure : Calc next header error.']);
	exit;
	end;
FStream.Position := NextBlockPosition;
Result := True;
end;
var
	BlocksCount : TSMaxEnum = 0;
begin
FStream.Position := 0;
while ReadBlock() do 
	BlocksCount += 1;
FStream.Position := 0;
SHint(['PCapNG__ParseStructure : Blocks count = ', BlocksCount]);
end;

constructor TSPCapNGFile.Create();
begin
inherited;
FFileName := '';
FStream := nil;
end;

destructor TSPCapNGFile.Destroy();
begin
FFileName := '';
KillStream();
inherited;
end;

end.
