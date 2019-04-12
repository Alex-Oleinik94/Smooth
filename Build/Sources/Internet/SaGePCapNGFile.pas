{$INCLUDE SaGe.inc}

// =====================================
// PCap Next Generation Dump File Format
// =====================================
// CaptureFileFormat

unit SaGePCapNGFile;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeStreamUtils
	
	,Classes
	;

type
	TSGPCapNGDefaultNumber    = TSGUInt32;
	TSGPCapNGBlockType        = TSGPCapNGDefaultNumber;
	TSGPCapNGBlockTotalLength = TSGPCapNGDefaultNumber;

// Standardized Block Type Codes
const
	SGPCapNG_Null    = $00000000; // Reserved ???
	SGPCapNG_IDB     = $00000001; // Interface Description Block
	SGPCapNG_PB      = $00000002; // Packet Block
	SGPCapNG_SPB     = $00000003; // Simple Packet Block
	SGPCapNG_NRB     = $00000004; // Name Resolution Block
	SGPCapNG_ISB     = $00000005; // Interface Statistics Block
	SGPCapNG_EPB     = $00000006; // Enhanced Packet Block
	SGPCapNG_TB      = $00000007; //     IRIG Timestamp Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC); 
	                              // code also used for Socket Aggregation Event Block
	SGPCapNG_EIB     = $00000008; //     ARINC 429 in AFDX Encapsulation Information Block 
	                              // (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)
	SGPCapNG_HP_MIB  = $00000101; // Hone Project Machine Info Block (see also Google version)
	SGPCapNG_HP_CEB  = $00000102; // Hone Project Connection Event Block (see also Google version)
	SGPCapNG_S_MIB   = $00000201; // Sysdig Machine Info Block
	SGPCapNG_S_PIBv1 = $00000202; // Sysdig Process Info Block, version 1
	SGPCapNG_S_FDLB  = $00000203; // Sysdig FD List Block
	SGPCapNG_S_EB    = $00000204; // Sysdig Event Block
	SGPCapNG_S_ILB   = $00000205; // Sysdig Interface List Block
	SGPCapNG_S_ULB   = $00000206; // Sysdig User List Block
	SGPCapNG_S_PIBv2 = $00000207; // Sysdig Process Info Block, version 2
	SGPCapNG_S_EBwf  = $00000208; // Sysdig Event Block with flags
	SGPCapNG_S_PIBv3 = $00000209; // Sysdig Process Info Block, version 3
	SGPCapNG_S_PIBv4 = $00000210; // Sysdig Process Info Block, version 4
	SGPCapNG_S_PIBv5 = $00000211; // Sysdig Process Info Block, version 5
	SGPCapNG_S_PIBv6 = $00000212; // Sysdig Process Info Block, version 6
	SGPCapNG_S_PIBv7 = $00000213; // Sysdig Process Info Block, version 7
	SGPCapNG_CBc     = $00000BAD; // Custom Block that rewriters can copy into new files
	SGPCapNG_CBnc    = $40000BAD; // Custom Block that rewriters should not copy into new files
	SGPCapNG_SHB     = $0A0D0D0A; // Section Header Block

// Reserved Block Type Codes
const
	// Reserved. Used to detect trace files corrupted because of file transfers using the HTTP protocol in text mode.
	SGPCapNG_R_DTFhttp1_b = $0A0D0A00; // beginning of the set
	SGPCapNG_R_DTFhttp1_e = $0A0D0AFF; // end of set
	SGPCapNG_R_DTFhttp2_b = $000A0D0A; // beginning of the set
	SGPCapNG_R_DTFhttp2_e = $FF0A0D0A; // end of set
	SGPCapNG_R_DTFhttp3_b = $000A0D0D; // beginning of the set
	SGPCapNG_R_DTFhttp3_e = $FF0A0D0D; // end of set
	// Reserved. Used to detect trace files corrupted because of file transfers using the FTP protocol in text mode.
	SGPCapNG_R_DTFftp_b   = $0D0D0A00; // beginning of the set
	SGPCapNG_R_DTFftp_e   = $0D0D0AFF; // end of set
	// Reserved for local use.
	SGPCapNG_R_LU_b       = $80000000; // beginning of the set
	SGPCapNG_R_LU_e       = $FFFFFFFF; // end of set

type
	TSGPCapNGEnhancedPacketBlock = object
			public
		FInterfaceIdentifier : TSGPCapNGDefaultNumber;
		FTimestampHign       : TSGPCapNGDefaultNumber;
		FTimestampLow        : TSGPCapNGDefaultNumber;
		FCapturedLength      : TSGPCapNGDefaultNumber;
		FPacketLength        : TSGPCapNGDefaultNumber;
		end;

type
	TSGPCapNGFile = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FFileName : TSGString;
		FStream : TStream;
			public
		property FileName : TSGString read FFileName write FFileName;
			protected
		procedure KillStream();
			public
		function CreateInput(const InputType : TSGInputStreamType = SGInputMemoryStream) : TSGBoolean;
		procedure ParseStructure();
		procedure OpenFile();
		function FindNextPacketData() : TStream;
		function FindBlock(const BlockType : TSGPCapNGBlockType) : TSGBoolean;
		end;

function SGStrPCapNGBlock(const BlockType : TSGPCapNGBlockType) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGStrPCapNGBlockExtended(const BlockType : TSGPCapNGBlockType) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

implementation

uses
	 SaGeStringUtils
	,SaGeLog
	;

function SGStrPCapNGBlockExtended(const BlockType : TSGPCapNGBlockType) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := SGStrPCapNGBlock(BlockType);
if Result = '' then
	Result := 'Unknown Block Type';
Result := '(0x' + SGStr4BytesHex(BlockType, True) + ') ' + Result;
end;

function SGStrPCapNGBlock(const BlockType : TSGPCapNGBlockType) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case BlockType of
SGPCapNG_Null    : Result := 'Reserved ???';
SGPCapNG_IDB     : Result := 'Interface Description Block';
SGPCapNG_PB      : Result := 'Packet Block';
SGPCapNG_SPB     : Result := 'Simple Packet Block';
SGPCapNG_NRB     : Result := 'Name Resolution Block';
SGPCapNG_ISB     : Result := 'Interface Statistics Block';
SGPCapNG_EPB     : Result := 'Enhanced Packet Block';
SGPCapNG_TB      : Result := 'IRIG Timestamp Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC); code also used for Socket Aggregation Event Block';
SGPCapNG_EIB     : Result := 'ARINC 429 in AFDX Encapsulation Information Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)';
SGPCapNG_HP_MIB  : Result := 'Hone Project Machine Info Block (see also Google version)';
SGPCapNG_HP_CEB  : Result := 'Hone Project Connection Event Block (see also Google version)';
SGPCapNG_S_MIB   : Result := 'Sysdig Machine Info Block';
SGPCapNG_S_PIBv1 : Result := 'Sysdig Process Info Block, version 1';
SGPCapNG_S_FDLB  : Result := 'Sysdig FD List Block';
SGPCapNG_S_EB    : Result := 'Sysdig Event Block';
SGPCapNG_S_ILB   : Result := 'Sysdig Interface List Block';
SGPCapNG_S_ULB   : Result := 'Sysdig User List Block';
SGPCapNG_S_PIBv2 : Result := 'Sysdig Process Info Block, version 2';
SGPCapNG_S_EBwf  : Result := 'Sysdig Event Block with flags';
SGPCapNG_S_PIBv3 : Result := 'Sysdig Process Info Block, version 3';
SGPCapNG_S_PIBv4 : Result := 'Sysdig Process Info Block, version 4';
SGPCapNG_S_PIBv5 : Result := 'Sysdig Process Info Block, version 5';
SGPCapNG_S_PIBv6 : Result := 'Sysdig Process Info Block, version 6';
SGPCapNG_S_PIBv7 : Result := 'Sysdig Process Info Block, version 7';
SGPCapNG_CBc     : Result := 'Custom Block that rewriters can copy into new files';
SGPCapNG_CBnc    : Result := 'Custom Block that rewriters should not copy into new files';
SGPCapNG_SHB     : Result := 'Section Header Block';
else if ((BlockType >= SGPCapNG_R_DTFhttp1_b) and (BlockType <= SGPCapNG_R_DTFhttp1_e)) or
	    ((BlockType >= SGPCapNG_R_DTFhttp2_b) and (BlockType <= SGPCapNG_R_DTFhttp2_e)) or 
	    ((BlockType >= SGPCapNG_R_DTFhttp3_b) and (BlockType <= SGPCapNG_R_DTFhttp3_e)) then
	Result := 'Reserved. Used to detect trace files corrupted because of file transfers using the HTTP protocol in text mode.'
else if ((BlockType >= SGPCapNG_R_DTFftp_b) and (BlockType <= SGPCapNG_R_DTFftp_e)) then
	Result := 'Reserved. Used to detect trace files corrupted because of file transfers using the FTP protocol in text mode.'
else if ((BlockType >= SGPCapNG_R_LU_b) and (BlockType <= SGPCapNG_R_LU_e)) then
	Result := 'Reserved for local use.'
else
	Result := '';
end;
end;

procedure TSGPCapNGFile.KillStream();
begin
if FStream <> nil then
	begin
	FStream.Destroy();
	FStream := nil;
	end;
end;

function TSGPCapNGFile.CreateInput(const InputType : TSGInputStreamType = SGInputMemoryStream) : TSGBoolean;
begin
KillStream();
if FFileName <> '' then
	FStream := SGCreateInputStream(FFileName, InputType);
Result := FStream <> nil;
end;

procedure TSGPCapNGFile.OpenFile();
begin
CreateInput();
end;

function TSGPCapNGFile.FindNextPacketData() : TStream;
var
	BlockSize : TSGPCapNGDefaultNumber = 0;
	EndPosition : TSGUInt64 = 0;
	PacketBlock : TSGPCapNGEnhancedPacketBlock;
begin
Result := nil;
if not FindBlock(SGPCapNG_EPB) then
	exit;
FStream.ReadBuffer(BlockSize, SizeOf(BlockSize));
EndPosition := FStream.Position + BlockSize - 8;
FStream.ReadBuffer(PacketBlock, SizeOf(PacketBlock));
Result := TMemoryStream.Create();
SGCopyPartStreamToStream(FStream, Result, PacketBlock.FCapturedLength);
Result.Position := 0;
FStream.Position := EndPosition;
end;

function TSGPCapNGFile.FindBlock(const BlockType : TSGPCapNGBlockType) : TSGBoolean;
var
	Block : TSGPCapNGBlockType;
	BlockLength : TSGPCapNGBlockType;
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

procedure TSGPCapNGFile.ParseStructure();

function ReadBlock() : TSGBoolean;
var
	BlockType : TSGPCapNGBlockType;
	BlockSize : TSGPCapNGBlockType;
	NextBlockPosition : TSGPCapNGBlockType;
begin
Result := False;
if FStream.Position + 8 >= FStream.Size then
	begin
	SGHint(['PCapNG__ParseStructure : End of file.']);
	exit;
	end;
FStream.ReadBuffer(BlockType, SizeOf(BlockType));
FStream.ReadBuffer(BlockSize, SizeOf(BlockSize));
SGHint(['PCapNG__ParseStructure : BlockType = ', SGStrPCapNGBlockExtended(BlockType)]);
SGHint(['PCapNG__ParseStructure : BlockTotalLength = ', BlockSize]);
NextBlockPosition := FStream.Position + BlockSize - 8;
if NextBlockPosition > FStream.Size then
	begin
	SGHint(['PCapNG__ParseStructure : Calc next header error.']);
	exit;
	end;
FStream.Position := NextBlockPosition;
Result := True;
end;
var
	BlocksCount : TSGMaxEnum = 0;
begin
FStream.Position := 0;
while ReadBlock() do 
	BlocksCount += 1;
FStream.Position := 0;
SGHint(['PCapNG__ParseStructure : Blocks count = ', BlocksCount]);
end;

constructor TSGPCapNGFile.Create();
begin
inherited;
FFileName := '';
FStream := nil;
end;

destructor TSGPCapNGFile.Destroy();
begin
FFileName := '';
KillStream();
inherited;
end;

end.
