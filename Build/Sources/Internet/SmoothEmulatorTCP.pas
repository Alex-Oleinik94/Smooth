{$INCLUDE Smooth.inc}
//{$DEFINE TCP_DEBUG}

unit SmoothEmulatorTCP;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothInternetBase
	
	,Classes
	;
type
	TSTCPSegment = object
			public
		class function Create(const _SegmentBegin, _SegmentEnd : TSTcpSequence) : TSTCPSegment;
		procedure Free();
		function ToString() : TSString;
			protected
		FSegmentBegin, FSegmentEnd : TSTcpSequence;
			public
		property SegmentBegin : TSTcpSequence read FSegmentBegin write FSegmentBegin;
		property SegmentEnd : TSTcpSequence read FSegmentEnd write FSegmentEnd;
		end;

operator = (const Segment1, Segment2 : TSTCPSegment) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

type
	TSTCPSignificantNumberType = (
		STCPSignificantEmpty, 
		STCPSignificantSynchronize, 
		STCPSignificantPush);
	TSTCPSignificantNumber = object
			public
		class function Create(const _NumberType : TSTCPSignificantNumberType; const _Number : TSTcpSequence) : TSTCPSignificantNumber;
		procedure Free();
		function ToString() : TSString;
			protected
		FNumberType : TSTCPSignificantNumberType;
		FNumber : TSTcpSequence;
			public
		property NumberType : TSTCPSignificantNumberType read FNumberType write FNumberType;
		property Number : TSTcpSequence read FNumber write FNumber;
		end;

function STCPSignificantNumberTypeToString(const _SignificantType : TSTCPSignificantNumberType) : TSString;
operator = (const Number1, Number2 : TSTCPSignificantNumber) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSTCPSegmentsHelper}
{$DEFINE DATATYPE_LIST        := TSTCPSegments}
{$DEFINE DATATYPE             := TSTCPSegment}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSTCPSignificantNumbersHelper}
{$DEFINE DATATYPE_LIST        := TSTCPSignificantNumbers}
{$DEFINE DATATYPE             := TSTCPSignificantNumber}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

const
	// S_TCP_WINDOW_SIZE = 64 KByte
	// S_TCP_BUFFER_SIZE = 256 KByte
	S_TCP_BUFFER_SIZE = S_TCP_WINDOW_SIZE * (4 + 1);
	S_TCP_BUFFER_POSITION = S_TCP_WINDOW_SIZE;
type
	TSTCPBufferAddress = TSInt32;
	TSEmulatorTransmissionControlProtocol = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FBuffer : TSTcpSequenceBuffer;
		FBufferSize : TSUInt64;
		FFirstBufferElement : TSTCPBufferAddress;
		FFirstBufferElementAddress : TSTcpSequence;
		FSynchronized : TSBoolean;
		FBufferInitialized : TSBoolean;
		FBeginSequenceNumber : TSTcpSequence;
		FAcknowledgement : TSTcpSequence;
		FFinalized : TSBoolean;
			protected
		FSignificantNumbers : TSTCPSignificantNumbers;
		FReceivedSegments : TSTCPSegments;
			protected
		FBufferCountReads, FBufferCountWrites, FCountDataHandles : TSUInt64;
			public
		property Finalized : TSBoolean read FFinalized;
			public
		procedure HandleData(const Data : TStream); virtual; abstract;
			public
		procedure AddSegment(const NewSegment : TSTCPSegment);
		procedure KillBuffer();
		procedure InitBuffer(const InitialBufferNumper : TSTcpSequence);
		procedure Reset(); virtual;
		procedure HandleData(const Header : TSTCPHeader; const Data : TStream); virtual;
		procedure HandleAcknowledgement(const AcknowledgementValue : TSTcpSequence); virtual;
		procedure DataToBuffer(const TcpSequencePointer : TSTcpSequence; const Stream : TStream); virtual;
		procedure Push(const PushNumber : TSTcpSequence); virtual;
		procedure PushProcess(); virtual;
		procedure PushData(const _DataAddress : TSTCPBufferAddress; const _Size : TSMaxEnum); virtual;
		procedure ReadBuffer(const TcpSequencePointer : TSTcpSequence; const Stream : TStream); virtual;
		procedure ConnectSegments();
		procedure Synchronize(const SynchronizeNumber : TSTcpSequence);
		function ReceivedSegmentsIncludes(const Segment : TSTCPSegment) : TSBoolean;
		procedure ReceivedSegmentsExclude(const Segment : TSTCPSegment);
		procedure MoveBuffer(const RemovedSegment : TSTCPSegment);
			public
		procedure LogSegments(const StringValue : TSString = '');
		procedure LogSynchronizing();
		procedure LogBufferInfo();
		procedure LogSignificantNumbers(const StringValue : TSString = '');
		end;

procedure SKill(var Emulator : TSEmulatorTransmissionControlProtocol);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SmoothStreamUtils
	,SmoothBaseUtils
	,SmoothStringUtils
	,SmoothLog
	;

operator = (const Number1, Number2 : TSTCPSignificantNumber) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Number1.Number = Number2.Number) and (Number1.NumberType = Number2.NumberType);
end;

function STCPSignificantNumberTypeToString(const _SignificantType : TSTCPSignificantNumberType) : TSString;
begin
case _SignificantType of
STCPSignificantEmpty : Result := 'Empty';
STCPSignificantSynchronize : Result := 'Synchronize';
STCPSignificantPush : Result := 'Push';
else Result := '';
end;
end;

class function TSTCPSignificantNumber.Create(const _NumberType : TSTCPSignificantNumberType; const _Number : TSTcpSequence) : TSTCPSignificantNumber;
begin
Result.Free();
Result.NumberType := _NumberType;
Result.Number := _Number;
end;

procedure TSTCPSignificantNumber.Free();
begin
FillChar(Self, SizeOf(TSTCPSignificantNumber), 0);
end;

function TSTCPSignificantNumber.ToString() : TSString;
begin
Result := '(' + STCPSignificantNumberTypeToString(FNumberType) + ', 0x' + SStr4BytesHex(FNumber, False) + ')';
end;

procedure TSEmulatorTransmissionControlProtocol.LogSignificantNumbers(const StringValue : TSString = '');
var
	Index : TSMaxEnum;
	Numbers : TSString = '';
begin
if (FSignificantNumbers <> nil) and (Length(FSignificantNumbers) > 0) then
	for Index := 0 to High(FSignificantNumbers) do
		begin
		if Index <> 0 then
			Numbers += ' ';
		Numbers += FSignificantNumbers[Index].ToString();
		if Index < High(FSignificantNumbers) then
			Numbers += ',';
		end;
TSLog.Source([Self, ' Significant numbers: ', Iff(StringValue <> '', '{' + StringValue + '}: '), Numbers]);
end;

procedure TSEmulatorTransmissionControlProtocol.LogSegments(const StringValue : TSString = '');
var
	Index : TSMaxEnum;
	Segments : TSString = '';
begin
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
	for Index := 0 to High(FReceivedSegments) do
		begin
		if Index <> 0 then
			Segments += ' ';
		Segments += FReceivedSegments[Index].ToString();
		if Index < High(FReceivedSegments) then
			Segments += ',';
		end;
TSLog.Source([Self, ' Segments: ', Iff(StringValue <> '', '{' + StringValue + '}: '), Segments]);
end;

procedure TSEmulatorTransmissionControlProtocol.LogBufferInfo();
begin
TSLog.Source([Self, ' Buffer info: First buffer element         = ', FFirstBufferElement]);
TSLog.Source([Self, ' Buffer info: First buffer element address = 0x', SStr4BytesHex(FFirstBufferElementAddress, False)]);
end;

procedure TSEmulatorTransmissionControlProtocol.LogSynchronizing();
begin
TSLog.Source([Self, ' Synchronize: Begin sequence number = 0x', SStr4BytesHex(FBeginSequenceNumber, False)]);
LogBufferInfo();
end;

operator = (const Segment1, Segment2 : TSTCPSegment) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Segment1.SegmentBegin = Segment2.SegmentBegin) and (Segment1.SegmentEnd = Segment2.SegmentEnd);
end;

function TSTCPSegment.ToString() : TSString;
begin
Result := '(0x' + SStr4BytesHex(SegmentBegin, False) + ', 0x' + SStr4BytesHex(SegmentEnd, False) + ', ' + SGetSizeString(SegmentEnd - SegmentBegin + 1) + ')';
end;

class function TSTCPSegment.Create(const _SegmentBegin, _SegmentEnd : TSTcpSequence) : TSTCPSegment;
begin
Result.Free();
Result.FSegmentBegin := _SegmentBegin;
Result.FSegmentEnd := _SegmentEnd;
end;

procedure TSTCPSegment.Free();
begin
FillChar(Self, SizeOf(Self), 0);
end;

procedure TSEmulatorTransmissionControlProtocol.HandleAcknowledgement(const AcknowledgementValue : TSTcpSequence);
begin
FAcknowledgement := AcknowledgementValue;
end;

procedure TSEmulatorTransmissionControlProtocol.ReadBuffer(const TcpSequencePointer : TSTcpSequence; const Stream : TStream);
begin
if (Stream <> nil) then
	begin
	FBufferCountReads += 1;
	Stream.Position := 0;
	Stream.Read(FBuffer[FFirstBufferElement + (TcpSequencePointer - FFirstBufferElementAddress)], Stream.Size);
	end;
end;

function TSTCPSegment_Comparison(var Segment1, Segment2) : TSBoolean;
begin
Result := TSTCPSegment(Segment1).SegmentBegin < TSTCPSegment(Segment2).SegmentBegin;
end;

procedure TSEmulatorTransmissionControlProtocol.ConnectSegments();
var
	Index, I : TSMaxEnum;
begin
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 1) then
	begin
	SQuickSort(FReceivedSegments[0], Length(FReceivedSegments), SizeOf(TSTCPSegment), @TSTCPSegment_Comparison);
	Index := 0;
	while (Index < High(FReceivedSegments)) do
		begin
		if (FReceivedSegments[Index].SegmentEnd + 1 >= FReceivedSegments[Index + 1].SegmentBegin) then
			begin
			FReceivedSegments[Index].SegmentEnd := 
				Max(FReceivedSegments[Index    ].SegmentEnd,
					FReceivedSegments[Index + 1].SegmentEnd);
			for I := Index + 1 to High(FReceivedSegments) - 1 do
				FReceivedSegments[I] := FReceivedSegments[I + 1];
			SetLength(FReceivedSegments, Length(FReceivedSegments) - 1)
			end
		else
			Index += 1;
		end;
	end;
end;

procedure TSEmulatorTransmissionControlProtocol.AddSegment(const NewSegment : TSTCPSegment);
begin
if (FBufferSize < FFirstBufferElement + NewSegment.SegmentEnd - FFirstBufferElementAddress) then
	begin
	FBufferSize += S_TCP_WINDOW_SIZE;
	FBuffer := ReAllocMemory(FBuffer, FBufferSize);
	end;
if (not (NewSegment in FReceivedSegments)) then
	FReceivedSegments += NewSegment;
ConnectSegments();
end;

procedure TSEmulatorTransmissionControlProtocol.DataToBuffer(const TcpSequencePointer : TSTcpSequence; const Stream : TStream);
begin
if FBufferInitialized and (Stream.Size > 0) then
	begin
	if FSynchronized and (TcpSequencePointer = FBeginSequenceNumber + 1) and (FFirstBufferElementAddress = FBeginSequenceNumber) and (FReceivedSegments = nil) then
		FFirstBufferElementAddress := TcpSequencePointer;
	AddSegment(TSTCPSegment.Create(TcpSequencePointer, TcpSequencePointer + Stream.Size - 1));
	ReadBuffer(TcpSequencePointer, Stream);
	end;
end;

function TSTCPSignificantNumber_Comparison(var Number1, Number2) : TSBoolean;
begin
Result := TSTCPSignificantNumber(Number1).Number < TSTCPSignificantNumber(Number2).Number;
end;

function TSEmulatorTransmissionControlProtocol.ReceivedSegmentsIncludes(const Segment : TSTCPSegment) : TSBoolean;
var
	FirstElementIndex : TSMaxEnum;
begin
Result := False;
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
	begin
	ConnectSegments();
	FirstElementIndex := 0;
	Result := 
		(FReceivedSegments[FirstElementIndex].SegmentBegin <= Segment.SegmentBegin) and 
		(FReceivedSegments[FirstElementIndex].SegmentEnd   >= Segment.SegmentEnd);
	end;
end;

procedure TSEmulatorTransmissionControlProtocol.MoveBuffer(const RemovedSegment : TSTCPSegment);
var
	RemovedSegmentSize : TSInt64;
	Index, Index2 : TSMaxEnum;
begin
RemovedSegmentSize := RemovedSegment.SegmentEnd - RemovedSegment.SegmentBegin + 1;
if (FFirstBufferElementAddress = RemovedSegment.SegmentBegin) and (RemovedSegmentSize > 0) then
	begin
	if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
		for Index := 0 to High(FReceivedSegments) do
			for Index2 := FReceivedSegments[Index].SegmentBegin to FReceivedSegments[Index].SegmentEnd do
				FBuffer[FFirstBufferElement + (Index2 - FFirstBufferElementAddress) - RemovedSegmentSize] := 
					FBuffer[FFirstBufferElement + (Index2 - FFirstBufferElementAddress)] ;
	FFirstBufferElementAddress := RemovedSegment.SegmentEnd + 1;
	end;
end;

procedure TSEmulatorTransmissionControlProtocol.ReceivedSegmentsExclude(const Segment : TSTCPSegment);
var
	Index : TSMaxEnum;
	RemovedSegment : TSTCPSegment;
begin
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
	begin
	ConnectSegments();
	Index := 0;
	if (FReceivedSegments[Index].SegmentBegin = Segment.SegmentBegin) and 
	   (FReceivedSegments[Index].SegmentEnd = Segment.SegmentEnd) then
		begin
		RemovedSegment := FReceivedSegments[Index];
		FReceivedSegments -= FReceivedSegments[Index];
		MoveBuffer(RemovedSegment);
		end
	else if (FReceivedSegments[Index].SegmentBegin = Segment.SegmentBegin) and 
			(FReceivedSegments[Index].SegmentEnd >= Segment.SegmentEnd) then
		begin
		RemovedSegment := TSTCPSegment.Create(FReceivedSegments[Index].SegmentBegin, Segment.SegmentEnd);
		FReceivedSegments[Index] := TSTCPSegment.Create(Segment.SegmentEnd + 1, FReceivedSegments[Index].SegmentEnd);
		MoveBuffer(RemovedSegment);
		end
	else if (FReceivedSegments[Index].SegmentBegin <= Segment.SegmentBegin) and 
			(FReceivedSegments[Index].SegmentEnd >= Segment.SegmentEnd) then
		begin
		FReceivedSegments[Index] := TSTCPSegment.Create(Segment.SegmentBegin, Segment.SegmentBegin - 1);
		FReceivedSegments += TSTCPSegment.Create(Segment.SegmentEnd + 1, FReceivedSegments[Index].SegmentEnd);
		ConnectSegments();
		end;
	end;
end;

procedure TSEmulatorTransmissionControlProtocol.PushProcess();
var
	PushingNumber : TSTcpSequence;
	BreakCircleFlag : TSBoolean = False;
	Index : TSMaxEnum;
begin
if (FSignificantNumbers <> nil) and (Length(FSignificantNumbers) > 0) then
	SQuickSort(FSignificantNumbers[0], Length(FSignificantNumbers), SizeOf(TSTCPSignificantNumbers), @TSTCPSignificantNumber_Comparison);
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
	begin
	{$IFDEF TCP_DEBUG}TSLog.Source([Self, ' First element: {(1)}: ', FFirstBufferElement]);{$ENDIF}
	{$IFDEF TCP_DEBUG}TSLog.Source([Self, ' First element address: {(1)}: ', FFirstBufferElementAddress]);{$ENDIF}
	{$IFDEF TCP_DEBUG}LogSegments('Before(1)');{$ENDIF}
	BreakCircleFlag := False;
	Index := 0;
	while ((FSignificantNumbers <> nil) and (Length(FSignificantNumbers) > 0)) and (not BreakCircleFlag) do
		begin
		PushingNumber := FSignificantNumbers[Index].Number;
		if ReceivedSegmentsIncludes(TSTCPSegment.Create(FFirstBufferElementAddress, PushingNumber)) then
			begin
			PushData(FFirstBufferElement, PushingNumber - FFirstBufferElementAddress + 1);
			ReceivedSegmentsExclude(TSTCPSegment.Create(FFirstBufferElementAddress, PushingNumber));
			FSignificantNumbers -= TSTCPSignificantNumber.Create(STCPSignificantPush, PushingNumber);
			end
		else
			BreakCircleFlag := True;
		end;
	{$IFDEF TCP_DEBUG}LogSegments('After(1)');{$ENDIF}
	end;
end;

procedure TSEmulatorTransmissionControlProtocol.PushData(const _DataAddress : TSTCPBufferAddress; const _Size : TSMaxEnum);
var
	Stream : TMemoryStream = nil;
begin
if _Size > 0 then
	begin
	FBufferCountWrites += 1;
	//TSLog.Source([Self, ' Push data:  = 0x', SStr4BytesHex(FBeginSequenceNumber, False)]);
	Stream := TMemoryStream.Create();
	Stream.Write(FBuffer[_DataAddress], _Size);
	HandleData(Stream);
	SKill(Stream);
	end;
end;

procedure TSEmulatorTransmissionControlProtocol.Push(const PushNumber : TSTcpSequence);
begin
if FBufferInitialized then
	begin
	if (not (TSTCPSignificantNumber.Create(STCPSignificantPush, PushNumber) in FSignificantNumbers)) then
		FSignificantNumbers += TSTCPSignificantNumber.Create(STCPSignificantPush, PushNumber);
	PushProcess();
	end;
end;

procedure TSEmulatorTransmissionControlProtocol.InitBuffer(const InitialBufferNumper : TSTcpSequence);
begin
Reset();
FFirstBufferElement := S_TCP_BUFFER_POSITION;
FFirstBufferElementAddress := InitialBufferNumper;
FBufferInitialized := True;
end;

procedure TSEmulatorTransmissionControlProtocol.Synchronize(const SynchronizeNumber : TSTcpSequence);
begin
FBeginSequenceNumber := SynchronizeNumber;
SKIll(FSignificantNumbers);
SKIll(FReceivedSegments);
//if not (TSTCPSignificantNumber.Create(STCPSignificantSynchronize, FBeginSequenceNumber) in FSignificantNumbers) then
//	FSignificantNumbers += TSTCPSignificantNumber.Create(STCPSignificantSynchronize, FBeginSequenceNumber);
InitBuffer(FBeginSequenceNumber);
FSynchronized := True;
{$IFDEF TCP_DEBUG}LogSynchronizing();{$ENDIF}
end;

procedure TSEmulatorTransmissionControlProtocol.HandleData(const Header : TSTCPHeader; const Data : TStream);
begin
FCountDataHandles += 1;
if Header.Synchronize then
	Synchronize(Header.SequenceNumber)
else if (not FSynchronized) and (not FBufferInitialized) then
	InitBuffer(Header.SequenceNumber);
if (Data <> nil) then
	DataToBuffer(Header.SequenceNumber, Data);
if Header.Push then
	if (Data = nil) then
		Push(Header.SequenceNumber - 1)
	else
		Push(Header.SequenceNumber + Data.Size - 1);
if Header.Reset then
	Reset();
if Header.Final then
	FFinalized := True;
end;

procedure TSEmulatorTransmissionControlProtocol.Reset();
begin
if FBuffer = nil then
	begin
	FBufferSize := S_TCP_BUFFER_SIZE;
	FBuffer := GetMem(FBufferSize);
	end;
FillChar(FBuffer^, FBufferSize, 0);
FFirstBufferElement := S_TCP_BUFFER_POSITION;
FFirstBufferElementAddress := 0;
FBufferInitialized := False;
end;

constructor TSEmulatorTransmissionControlProtocol.Create();
begin
inherited;
FCountDataHandles := 0;
FBufferCountReads := 0;
FBufferCountWrites := 0;
FSignificantNumbers := nil;
FReceivedSegments := nil;
FFinalized := False;
FAcknowledgement := 0;
FBuffer := nil;
FBufferSize := 0;
FSynchronized := False;
FBeginSequenceNumber := 0;
Reset();
end;

procedure TSEmulatorTransmissionControlProtocol.KillBuffer();
begin
if (FBuffer <> nil) then
	begin
	FreeMem(FBuffer, FBufferSize);
	FBuffer := nil;
	FBufferSize := 0;
	end;
end;

destructor TSEmulatorTransmissionControlProtocol.Destroy();
begin
KillBuffer();
SKill(FReceivedSegments);
SKill(FSignificantNumbers);
inherited;
end;

procedure SKill(var Emulator : TSEmulatorTransmissionControlProtocol);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Emulator <> nil then
	begin
	Emulator.Destroy();
	Emulator := nil;
	end;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSTCPSegmentsHelper}
{$DEFINE DATATYPE_LIST        := TSTCPSegments}
{$DEFINE DATATYPE             := TSTCPSegment}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSTCPSignificantNumbersHelper}
{$DEFINE DATATYPE_LIST        := TSTCPSignificantNumbers}
{$DEFINE DATATYPE             := TSTCPSignificantNumber}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
