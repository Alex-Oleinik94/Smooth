{$INCLUDE SaGe.inc}

unit SaGeTransmissionControlProtocolEmulator;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	
	,Classes
	;
const
	SG_TCP_BUFFER_SIZE = SG_TCP_WINDOW_SIZE * 3;
type
	TSGTCPReceivedSegment = object
			public
		class function Create(const _SegmentBegin, _SegmentEnd : TSGTcpSequence) : TSGTCPReceivedSegment;
		procedure Free();
			protected
		FSegmentBegin, FSegmentEnd : TSGTcpSequence;
			public
		property SegmentBegin : TSGTcpSequence read FSegmentBegin;
		property SegmentEnd : TSGTcpSequence read FSegmentEnd;
		end;

operator = (const Segment1, Segment2 : TSGTCPReceivedSegment) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGTCPReceivedSegmentsHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPReceivedSegments}
{$DEFINE DATATYPE             := TSGTCPReceivedSegment}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

type
	TSGTransmissionControlProtocolEmulator = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FBuffer : TSGTcpSequenceBuffer;
		FFirstBufferElement : TSGInt32;
		FFirstBufferElementAddress : TSGTcpSequence;
		FSynchronized : TSGBoolean;
		FBeginSequenceNumber : TSGTcpSequence;
		FAcknowledgement : TSGTcpSequence;
		FFinalized : TSGBoolean;
			protected
		FPushNumbers : TSGUInt32List;
		FReceivedSegments : TSGTCPReceivedSegments;
			public
		property Finalized : TSGBoolean read FFinalized;
			public
		procedure HandleData(const Data : TStream); virtual; abstract;
			public
		procedure Reset(); virtual;
		procedure HandleData(const Header : TSGTCPHeader; const Data : TStream); virtual;
		procedure HandleAcknowledgement(const AcknowledgementValue : TSGTcpSequence); virtual;
		procedure DataToBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream); virtual;
		procedure Push(const PushNumber : TSGTcpSequence); virtual;
		procedure ReadBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream); virtual;
		procedure ConnectSegments();
		end;

procedure SGKill(var Emulator : TSGTransmissionControlProtocolEmulator);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeStreamUtils
	;

operator = (const Segment1, Segment2 : TSGTCPReceivedSegment) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Segment1.SegmentBegin = Segment2.SegmentBegin) and (Segment1.SegmentEnd = Segment2.SegmentEnd);
end;

class function TSGTCPReceivedSegment.Create(const _SegmentBegin, _SegmentEnd : TSGTcpSequence) : TSGTCPReceivedSegment;
begin
Result.Free();
Result.FSegmentBegin := _SegmentBegin;
Result.FSegmentEnd := _SegmentEnd;
end;

procedure TSGTCPReceivedSegment.Free();
begin
FillChar(Self, SizeOf(Self), 0);
end;

procedure TSGTransmissionControlProtocolEmulator.HandleAcknowledgement(const AcknowledgementValue : TSGTcpSequence);
begin
FAcknowledgement := AcknowledgementValue;
end;

procedure TSGTransmissionControlProtocolEmulator.ReadBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin
Stream.Position := 0;
Stream.Read(FBuffer[FFirstBufferElement + (TcpSequencePointer - FFirstBufferElementAddress)], Stream.Size);
end;

procedure TSGTransmissionControlProtocolEmulator.ConnectSegments();
begin

end;

procedure TSGTransmissionControlProtocolEmulator.DataToBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin
if FSynchronized then
	begin
	if (not (TSGTCPReceivedSegment.Create(TcpSequencePointer, TcpSequencePointer + Stream.Size) in FReceivedSegments)) then
		FReceivedSegments += TSGTCPReceivedSegment.Create(TcpSequencePointer, TcpSequencePointer + Stream.Size);
	ReadBuffer(TcpSequencePointer, Stream);
	ConnectSegments();
	end;
end;

procedure TSGTransmissionControlProtocolEmulator.Push(const PushNumber : TSGTcpSequence);
var
	Stream : TMemoryStream = nil;
begin
if FSynchronized then
	if (not (PushNumber in FPushNumbers)) then
		FPushNumbers += PushNumber;
if FSynchronized and (PushNumber - FFirstBufferElementAddress > 0) then
	begin
	Stream := TMemoryStream.Create();
	Stream.Write(FBuffer[FFirstBufferElement + PushNumber - FFirstBufferElementAddress], PushNumber - FFirstBufferElementAddress);
	FFirstBufferElement += PushNumber - FFirstBufferElementAddress;
	FFirstBufferElementAddress := PushNumber;
	
	HandleData(Stream);
	SGKill(Stream);
	end;
end;

procedure TSGTransmissionControlProtocolEmulator.HandleData(const Header : TSGTCPHeader; const Data : TStream);
begin
if Header.Synchronize then
	begin
	FFirstBufferElement := 0;
	FBeginSequenceNumber := Header.SequenceNumber;
	FFirstBufferElementAddress := FBeginSequenceNumber;
	FSynchronized := True;
	end;
if Data <> nil then
	DataToBuffer(Header.SequenceNumber, Data);
if Header.Push then
	if (Data = nil) then
		Push(Header.SequenceNumber)
	else
		Push(Header.SequenceNumber + Data.Size);
if Header.Reset then
	Reset();
if Header.Final then
	FFinalized := True;
end;

procedure TSGTransmissionControlProtocolEmulator.Reset();
begin
FillChar(FBuffer^, SG_TCP_BUFFER_SIZE, 0);
FFirstBufferElement := 0;
FSynchronized := False;
FFirstBufferElementAddress := 0;
end;

constructor TSGTransmissionControlProtocolEmulator.Create();
begin
inherited;
FPushNumbers := nil;
FReceivedSegments := nil;
FFinalized := False;
FAcknowledgement := 0;
FBuffer := GetMem(SG_TCP_BUFFER_SIZE);
Reset();
end;

destructor TSGTransmissionControlProtocolEmulator.Destroy();
begin
if FBuffer <> nil then
	begin
	FreeMem(FBuffer, SG_TCP_BUFFER_SIZE);
	FBuffer := nil;
	end;
SGKill(FReceivedSegments);
SGKill(FPushNumbers);
inherited;
end;

procedure SGKill(var Emulator : TSGTransmissionControlProtocolEmulator);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Emulator <> nil then
	begin
	Emulator.Destroy();
	Emulator := nil;
	end;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGTCPReceivedSegmentsHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPReceivedSegments}
{$DEFINE DATATYPE             := TSGTCPReceivedSegment}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
