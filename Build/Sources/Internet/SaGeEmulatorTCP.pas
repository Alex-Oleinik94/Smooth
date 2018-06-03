{$INCLUDE SaGe.inc}
{$DEFINE TCP_DEBUG}

unit SaGeEmulatorTCP;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeClasses
	,SaGeInternetBase
	
	,Classes
	;
type
	TSGTCPSegment = object
			public
		class function Create(const _SegmentBegin, _SegmentEnd : TSGTcpSequence) : TSGTCPSegment;
		procedure Free();
		function ToString() : TSGString;
			protected
		FSegmentBegin, FSegmentEnd : TSGTcpSequence;
			public
		property SegmentBegin : TSGTcpSequence read FSegmentBegin write FSegmentBegin;
		property SegmentEnd : TSGTcpSequence read FSegmentEnd write FSegmentEnd;
		end;

operator = (const Segment1, Segment2 : TSGTCPSegment) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

type
	TSGTCPSignificantNumberType = (
		SGTCPSignificantEmpty, 
		SGTCPSignificantSynchronize, 
		SGTCPSignificantPush);
	TSGTCPSignificantNumber = object
			public
		class function Create(const _NumberType : TSGTCPSignificantNumberType; const _Number : TSGTcpSequence) : TSGTCPSignificantNumber;
		procedure Free();
		function ToString() : TSGString;
			protected
		FNumberType : TSGTCPSignificantNumberType;
		FNumber : TSGTcpSequence;
			public
		property NumberType : TSGTCPSignificantNumberType read FNumberType write FNumberType;
		property Number : TSGTcpSequence read FNumber write FNumber;
		end;

function SGTCPSignificantNumberTypeToString(const _SignificantType : TSGTCPSignificantNumberType) : TSGString;
operator = (const Number1, Number2 : TSGTCPSignificantNumber) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGTCPSegmentsHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPSegments}
{$DEFINE DATATYPE             := TSGTCPSegment}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGTCPSignificantNumbersHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPSignificantNumbers}
{$DEFINE DATATYPE             := TSGTCPSignificantNumber}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

const
	// SG_TCP_WINDOW_SIZE = 64 KByte
	// SG_TCP_BUFFER_SIZE = 256 KByte
	SG_TCP_BUFFER_SIZE = SG_TCP_WINDOW_SIZE * (4 + 1);
	SG_TCP_BUFFER_POSITION = SG_TCP_WINDOW_SIZE;
type
	TSGTCPBufferAddress = TSGInt32;
	TSGEmulatorTransmissionControlProtocol = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FBuffer : TSGTcpSequenceBuffer;
		FBufferSize : TSGUInt64;
		FFirstBufferElement : TSGTCPBufferAddress;
		FFirstBufferElementAddress : TSGTcpSequence;
		FSynchronized : TSGBoolean;
		FBufferInitialized : TSGBoolean;
		FBeginSequenceNumber : TSGTcpSequence;
		FAcknowledgement : TSGTcpSequence;
		FFinalized : TSGBoolean;
			protected
		FSignificantNumbers : TSGTCPSignificantNumbers;
		FReceivedSegments : TSGTCPSegments;
			protected
		FBufferCountReads, FBufferCountWrites, FCountDataHandles : TSGUInt64;
			public
		property Finalized : TSGBoolean read FFinalized;
			public
		procedure HandleData(const Data : TStream); virtual; abstract;
			public
		procedure AddSegment(const NewSegment : TSGTCPSegment);
		procedure KillBuffer();
		procedure InitBuffer(const InitialBufferNumper : TSGTcpSequence);
		procedure Reset(); virtual;
		procedure HandleData(const Header : TSGTCPHeader; const Data : TStream); virtual;
		procedure HandleAcknowledgement(const AcknowledgementValue : TSGTcpSequence); virtual;
		procedure DataToBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream); virtual;
		procedure Push(const PushNumber : TSGTcpSequence); virtual;
		procedure PushProcess(); virtual;
		procedure PushData(const _DataAddress : TSGTCPBufferAddress; const _Size : TSGMaxEnum); virtual;
		procedure ReadBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream); virtual;
		procedure ConnectSegments();
		procedure Synchronize(const SynchronizeNumber : TSGTcpSequence);
		function ReceivedSegmentsIncludes(const Segment : TSGTCPSegment) : TSGBoolean;
		procedure ReceivedSegmentsExclude(const Segment : TSGTCPSegment);
		procedure MoveBuffer(const RemovedSegment : TSGTCPSegment);
			public
		procedure LogSegments(const StringValue : TSGString = '');
		procedure LogSynchronizing();
		procedure LogBufferInfo();
		procedure LogSignificantNumbers(const StringValue : TSGString = '');
		end;

procedure SGKill(var Emulator : TSGEmulatorTransmissionControlProtocol);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeStreamUtils
	,SaGeBaseUtils
	,SaGeStringUtils
	,SaGeLog
	;

operator = (const Number1, Number2 : TSGTCPSignificantNumber) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Number1.Number = Number2.Number) and (Number1.NumberType = Number2.NumberType);
end;

function SGTCPSignificantNumberTypeToString(const _SignificantType : TSGTCPSignificantNumberType) : TSGString;
begin
case _SignificantType of
SGTCPSignificantEmpty : Result := 'Empty';
SGTCPSignificantSynchronize : Result := 'Synchronize';
SGTCPSignificantPush : Result := 'Push';
else Result := '';
end;
end;

class function TSGTCPSignificantNumber.Create(const _NumberType : TSGTCPSignificantNumberType; const _Number : TSGTcpSequence) : TSGTCPSignificantNumber;
begin
Result.Free();
Result.NumberType := _NumberType;
Result.Number := _Number;
end;

procedure TSGTCPSignificantNumber.Free();
begin
FillChar(Self, SizeOf(TSGTCPSignificantNumber), 0);
end;

function TSGTCPSignificantNumber.ToString() : TSGString;
begin
Result := '(' + SGTCPSignificantNumberTypeToString(FNumberType) + ', 0x' + SGStr4BytesHex(FNumber, False) + ')';
end;

procedure TSGEmulatorTransmissionControlProtocol.LogSignificantNumbers(const StringValue : TSGString = '');
var
	Index : TSGMaxEnum;
	Numbers : TSGString = '';
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
TSGLog.Source([Self, ' Significant numbers: ', Iff(StringValue <> '', '{' + StringValue + '}: '), Numbers]);
end;

procedure TSGEmulatorTransmissionControlProtocol.LogSegments(const StringValue : TSGString = '');
var
	Index : TSGMaxEnum;
	Segments : TSGString = '';
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
TSGLog.Source([Self, ' Segments: ', Iff(StringValue <> '', '{' + StringValue + '}: '), Segments]);
end;

procedure TSGEmulatorTransmissionControlProtocol.LogBufferInfo();
begin
TSGLog.Source([Self, ' Buffer info: First buffer element         = ', FFirstBufferElement]);
TSGLog.Source([Self, ' Buffer info: First buffer element address = 0x', SGStr4BytesHex(FFirstBufferElementAddress, False)]);
end;

procedure TSGEmulatorTransmissionControlProtocol.LogSynchronizing();
begin
TSGLog.Source([Self, ' Synchronize: Begin sequence number = 0x', SGStr4BytesHex(FBeginSequenceNumber, False)]);
LogBufferInfo();
end;

operator = (const Segment1, Segment2 : TSGTCPSegment) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Segment1.SegmentBegin = Segment2.SegmentBegin) and (Segment1.SegmentEnd = Segment2.SegmentEnd);
end;

function TSGTCPSegment.ToString() : TSGString;
begin
Result := '(0x' + SGStr4BytesHex(SegmentBegin, False) + ', 0x' + SGStr4BytesHex(SegmentEnd, False) + ', ' + SGGetSizeString(SegmentEnd - SegmentBegin + 1) + ')';
end;

class function TSGTCPSegment.Create(const _SegmentBegin, _SegmentEnd : TSGTcpSequence) : TSGTCPSegment;
begin
Result.Free();
Result.FSegmentBegin := _SegmentBegin;
Result.FSegmentEnd := _SegmentEnd;
end;

procedure TSGTCPSegment.Free();
begin
FillChar(Self, SizeOf(Self), 0);
end;

procedure TSGEmulatorTransmissionControlProtocol.HandleAcknowledgement(const AcknowledgementValue : TSGTcpSequence);
begin
FAcknowledgement := AcknowledgementValue;
end;

procedure TSGEmulatorTransmissionControlProtocol.ReadBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin
FBufferCountReads += 1;
Stream.Position := 0;
Stream.Read(FBuffer[FFirstBufferElement + (TcpSequencePointer - FFirstBufferElementAddress)], Stream.Size);
end;

function TSGTCPSegment_Comparison(var Segment1, Segment2) : TSGBoolean;
begin
Result := TSGTCPSegment(Segment1).SegmentBegin < TSGTCPSegment(Segment2).SegmentBegin;
end;

procedure TSGEmulatorTransmissionControlProtocol.ConnectSegments();
var
	Index, I : TSGMaxEnum;
begin
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 1) then
	begin
	SGQuickSort(FReceivedSegments[0], Length(FReceivedSegments), SizeOf(TSGTCPSegment), @TSGTCPSegment_Comparison);
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

procedure TSGEmulatorTransmissionControlProtocol.AddSegment(const NewSegment : TSGTCPSegment);
begin
if (FBufferSize - FFirstBufferElement  < NewSegment.SegmentEnd - FFirstBufferElementAddress + 1) then
	begin
	FBufferSize += SG_TCP_WINDOW_SIZE;
	ReAllocMem(FBuffer, FBufferSize);
	end;
if (not (NewSegment in FReceivedSegments)) then
	FReceivedSegments += NewSegment;
ConnectSegments();
end;

procedure TSGEmulatorTransmissionControlProtocol.DataToBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin
if FBufferInitialized and (Stream.Size > 0) then
	begin
	if FSynchronized and (TcpSequencePointer = FBeginSequenceNumber + 1) and (FFirstBufferElementAddress = FBeginSequenceNumber) and (FReceivedSegments = nil) then
		FFirstBufferElementAddress := TcpSequencePointer;
	AddSegment(TSGTCPSegment.Create(TcpSequencePointer, TcpSequencePointer + Stream.Size - 1));
	ReadBuffer(TcpSequencePointer, Stream);
	end;
end;

function TSGTCPSignificantNumber_Comparison(var Number1, Number2) : TSGBoolean;
begin
Result := TSGTCPSignificantNumber(Number1).Number < TSGTCPSignificantNumber(Number2).Number;
end;

function TSGEmulatorTransmissionControlProtocol.ReceivedSegmentsIncludes(const Segment : TSGTCPSegment) : TSGBoolean;
var
	FirstElementIndex : TSGMaxEnum;
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

procedure TSGEmulatorTransmissionControlProtocol.MoveBuffer(const RemovedSegment : TSGTCPSegment);
var
	RemovedSegmentSize : TSGInt64;
	Index, Index2 : TSGMaxEnum;
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

procedure TSGEmulatorTransmissionControlProtocol.ReceivedSegmentsExclude(const Segment : TSGTCPSegment);
var
	Index : TSGMaxEnum;
	RemovedSegment : TSGTCPSegment;
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
		RemovedSegment := TSGTCPSegment.Create(FReceivedSegments[Index].SegmentBegin, Segment.SegmentEnd);
		FReceivedSegments[Index] := TSGTCPSegment.Create(Segment.SegmentEnd + 1, FReceivedSegments[Index].SegmentEnd);
		MoveBuffer(RemovedSegment);
		end
	else if (FReceivedSegments[Index].SegmentBegin <= Segment.SegmentBegin) and 
			(FReceivedSegments[Index].SegmentEnd >= Segment.SegmentEnd) then
		begin
		FReceivedSegments[Index] := TSGTCPSegment.Create(Segment.SegmentBegin, Segment.SegmentBegin - 1);
		FReceivedSegments += TSGTCPSegment.Create(Segment.SegmentEnd + 1, FReceivedSegments[Index].SegmentEnd);
		ConnectSegments();
		end;
	end;
end;

procedure TSGEmulatorTransmissionControlProtocol.PushProcess();
var
	PushingNumber : TSGTcpSequence;
	BreakCircleFlag : TSGBoolean = False;
	Index : TSGMaxEnum;
begin
if (FSignificantNumbers <> nil) and (Length(FSignificantNumbers) > 0) then
	SGQuickSort(FSignificantNumbers[0], Length(FSignificantNumbers), SizeOf(TSGTCPSignificantNumbers), @TSGTCPSignificantNumber_Comparison);
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
	begin
	{$IFDEF TCP_DEBUG}TSGLog.Source([Self, ' First element: {(1)}: ', FFirstBufferElement]);{$ENDIF}
	{$IFDEF TCP_DEBUG}LogSegments('Before(1)');{$ENDIF}
	BreakCircleFlag := False;
	Index := 0;
	while ((FSignificantNumbers <> nil) and (Length(FSignificantNumbers) > 0)) and (not BreakCircleFlag) do
		begin
		PushingNumber := FSignificantNumbers[Index].Number;
		if ReceivedSegmentsIncludes(TSGTCPSegment.Create(FFirstBufferElementAddress, PushingNumber)) then
			begin
			PushData(FFirstBufferElement, PushingNumber - FFirstBufferElementAddress + 1);
			ReceivedSegmentsExclude(TSGTCPSegment.Create(FFirstBufferElementAddress, PushingNumber));
			FSignificantNumbers -= TSGTCPSignificantNumber.Create(SGTCPSignificantPush, PushingNumber);
			end
		else
			BreakCircleFlag := True;
		end;
	{$IFDEF TCP_DEBUG}LogSegments('After(1)');{$ENDIF}
	end;
end;

procedure TSGEmulatorTransmissionControlProtocol.PushData(const _DataAddress : TSGTCPBufferAddress; const _Size : TSGMaxEnum);
var
	Stream : TMemoryStream = nil;
begin
if _Size > 0 then
	begin
	FBufferCountWrites += 1;
	//TSGLog.Source([Self, ' Push data:  = 0x', SGStr4BytesHex(FBeginSequenceNumber, False)]);
	Stream := TMemoryStream.Create();
	Stream.Write(FBuffer[_DataAddress], _Size);
	HandleData(Stream);
	SGKill(Stream);
	end;
end;

procedure TSGEmulatorTransmissionControlProtocol.Push(const PushNumber : TSGTcpSequence);
begin
if FBufferInitialized then
	begin
	if (not (TSGTCPSignificantNumber.Create(SGTCPSignificantPush, PushNumber) in FSignificantNumbers)) then
		FSignificantNumbers += TSGTCPSignificantNumber.Create(SGTCPSignificantPush, PushNumber);
	PushProcess();
	end;
end;

procedure TSGEmulatorTransmissionControlProtocol.InitBuffer(const InitialBufferNumper : TSGTcpSequence);
begin
Reset();
FFirstBufferElement := SG_TCP_BUFFER_POSITION;
FFirstBufferElementAddress := InitialBufferNumper;
FBufferInitialized := True;
end;

procedure TSGEmulatorTransmissionControlProtocol.Synchronize(const SynchronizeNumber : TSGTcpSequence);
begin
FBeginSequenceNumber := SynchronizeNumber;
SGKIll(FSignificantNumbers);
SGKIll(FReceivedSegments);
//if not (TSGTCPSignificantNumber.Create(SGTCPSignificantSynchronize, FBeginSequenceNumber) in FSignificantNumbers) then
//	FSignificantNumbers += TSGTCPSignificantNumber.Create(SGTCPSignificantSynchronize, FBeginSequenceNumber);
InitBuffer(FBeginSequenceNumber);
FSynchronized := True;
{$IFDEF TCP_DEBUG}LogSynchronizing();{$ENDIF}
end;

procedure TSGEmulatorTransmissionControlProtocol.HandleData(const Header : TSGTCPHeader; const Data : TStream);
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

procedure TSGEmulatorTransmissionControlProtocol.Reset();
begin
if FBuffer = nil then
	begin
	FBufferSize := SG_TCP_BUFFER_SIZE;
	FBuffer := GetMem(FBufferSize);
	end;
FillChar(FBuffer^, FBufferSize, 0);
FFirstBufferElement := SG_TCP_BUFFER_POSITION;
FFirstBufferElementAddress := 0;
FBufferInitialized := False;
end;

constructor TSGEmulatorTransmissionControlProtocol.Create();
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

procedure TSGEmulatorTransmissionControlProtocol.KillBuffer();
begin
if (FBuffer <> nil) then
	begin
	FreeMem(FBuffer, FBufferSize);
	FBuffer := nil;
	FBufferSize := 0;
	end;
end;

destructor TSGEmulatorTransmissionControlProtocol.Destroy();
begin
KillBuffer();
SGKill(FReceivedSegments);
SGKill(FSignificantNumbers);
inherited;
end;

procedure SGKill(var Emulator : TSGEmulatorTransmissionControlProtocol);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Emulator <> nil then
	begin
	Emulator.Destroy();
	Emulator := nil;
	end;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGTCPSegmentsHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPSegments}
{$DEFINE DATATYPE             := TSGTCPSegment}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGTCPSignificantNumbersHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPSignificantNumbers}
{$DEFINE DATATYPE             := TSGTCPSignificantNumber}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
