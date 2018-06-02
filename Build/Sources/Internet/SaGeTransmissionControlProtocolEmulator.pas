{$INCLUDE SaGe.inc}
//{$DEFINE TCP_DEBUG}

unit SaGeTransmissionControlProtocolEmulator;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeClasses
	,SaGeInternetBase
	
	,Classes
	;
type
	TSGTCPReceivedSegment = object
			public
		class function Create(const _SegmentBegin, _SegmentEnd : TSGTcpSequence) : TSGTCPReceivedSegment;
		procedure Free();
		function ToString() : TSGString;
			protected
		FSegmentBegin, FSegmentEnd : TSGTcpSequence;
			public
		property SegmentBegin : TSGTcpSequence read FSegmentBegin write FSegmentBegin;
		property SegmentEnd : TSGTcpSequence read FSegmentEnd write FSegmentEnd;
		end;

operator = (const Segment1, Segment2 : TSGTCPReceivedSegment) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

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
{$DEFINE DATATYPE_LIST_HELPER := TSGTCPReceivedSegmentsHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPReceivedSegments}
{$DEFINE DATATYPE             := TSGTCPReceivedSegment}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGTCPSignificantNumbersHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPSignificantNumbers}
{$DEFINE DATATYPE             := TSGTCPSignificantNumber}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

const
	SG_TCP_BUFFER_SIZE = SG_TCP_WINDOW_SIZE * 3;
	SG_TCP_BUFFER_POSITION = SG_TCP_WINDOW_SIZE;
type
	TSGTCPBufferAddress = TSGInt32;
	TSGTransmissionControlProtocolEmulator = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FBuffer : TSGTcpSequenceBuffer;
		FFirstBufferElement : TSGTCPBufferAddress;
		FFirstBufferElementAddress : TSGTcpSequence;
		FSynchronized : TSGBoolean;
		FBufferInitialized : TSGBoolean;
		FBeginSequenceNumber : TSGTcpSequence;
		FAcknowledgement : TSGTcpSequence;
		FFinalized : TSGBoolean;
			protected
		FSignificantNumbers : TSGTCPSignificantNumbers;
		FReceivedSegments : TSGTCPReceivedSegments;
			protected
		FBufferCountReads, FBufferCountWrites, FCountDataHandles : TSGUInt64;
			public
		property Finalized : TSGBoolean read FFinalized;
			public
		procedure HandleData(const Data : TStream); virtual; abstract;
			public
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
		function ReceivedSegmentsIncludes(const Segment : TSGTCPReceivedSegment) : TSGBoolean;
		procedure ReceivedSegmentsExclude(const Segment : TSGTCPReceivedSegment);
		procedure MoveBuffer(const RemovedSegment : TSGTCPReceivedSegment);
			public
		procedure LogSegments(const StringValue : TSGString = '');
		procedure LogSynchronizing();
		procedure LogBufferInfo();
		procedure LogSignificantNumbers(const StringValue : TSGString = '');
		end;

procedure SGKill(var Emulator : TSGTransmissionControlProtocolEmulator);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

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

procedure TSGTransmissionControlProtocolEmulator.LogSignificantNumbers(const StringValue : TSGString = '');
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

procedure TSGTransmissionControlProtocolEmulator.LogSegments(const StringValue : TSGString = '');
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

procedure TSGTransmissionControlProtocolEmulator.LogBufferInfo();
begin
TSGLog.Source([Self, ' Buffer info: First buffer element         = ', FFirstBufferElement]);
TSGLog.Source([Self, ' Buffer info: First buffer element address = 0x', SGStr4BytesHex(FFirstBufferElementAddress, False)]);
end;

procedure TSGTransmissionControlProtocolEmulator.LogSynchronizing();
begin
TSGLog.Source([Self, ' Synchronize: Begin sequence number = 0x', SGStr4BytesHex(FBeginSequenceNumber, False)]);
LogBufferInfo();
end;

operator = (const Segment1, Segment2 : TSGTCPReceivedSegment) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Segment1.SegmentBegin = Segment2.SegmentBegin) and (Segment1.SegmentEnd = Segment2.SegmentEnd);
end;

function TSGTCPReceivedSegment.ToString() : TSGString;
begin
Result := '(0x' + SGStr4BytesHex(SegmentBegin, False) + ', 0x' + SGStr4BytesHex(SegmentEnd, False) + ')';
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
FBufferCountReads += 1;
Stream.Position := 0;
Stream.Read(FBuffer[FFirstBufferElement + (TcpSequencePointer - FFirstBufferElementAddress)], Stream.Size);
end;

function TSGTCPReceivedSegment_Comparison(var Segment1, Segment2) : TSGBoolean;
begin
Result := TSGTCPReceivedSegment(Segment1).SegmentBegin < TSGTCPReceivedSegment(Segment2).SegmentBegin;
end;

procedure TSGTransmissionControlProtocolEmulator.ConnectSegments();
var
	Index, I : TSGMaxEnum;
begin
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 1) then
	begin
	SGQuickSort(FReceivedSegments[0], Length(FReceivedSegments), SizeOf(TSGTCPReceivedSegment), @TSGTCPReceivedSegment_Comparison);
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

procedure TSGTransmissionControlProtocolEmulator.DataToBuffer(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin
if FBufferInitialized and (Stream.Size > 0) then
	begin
	if FSynchronized and (TcpSequencePointer = FBeginSequenceNumber + 1) and (FFirstBufferElementAddress = FBeginSequenceNumber) and (FReceivedSegments = nil) then
		FFirstBufferElementAddress := TcpSequencePointer;
	if (not (TSGTCPReceivedSegment.Create(TcpSequencePointer, TcpSequencePointer + Stream.Size - 1) in FReceivedSegments)) then
		FReceivedSegments += TSGTCPReceivedSegment.Create(TcpSequencePointer, TcpSequencePointer + Stream.Size - 1);
	ReadBuffer(TcpSequencePointer, Stream);
	//{$IFDEF TCP_DEBUG}LogBufferInfo();{$ENDIF}
	//{$IFDEF TCP_DEBUG}LogSegments('Before');{$ENDIF}
	ConnectSegments();
	//{$IFDEF TCP_DEBUG}LogSegments('After');{$ENDIF}
	end;
end;

function TSGTCPSignificantNumber_Comparison(var Number1, Number2) : TSGBoolean;
begin
Result := TSGTCPSignificantNumber(Number1).Number < TSGTCPSignificantNumber(Number2).Number;
end;

function TSGTransmissionControlProtocolEmulator.ReceivedSegmentsIncludes(const Segment : TSGTCPReceivedSegment) : TSGBoolean;
begin
Result := False;
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
	begin
	ConnectSegments();
	Result := 
		(FReceivedSegments[0].SegmentBegin <= Segment.SegmentBegin) and 
		(FReceivedSegments[0].SegmentEnd   >= Segment.SegmentEnd);
	end;
end;

procedure TSGTransmissionControlProtocolEmulator.MoveBuffer(const RemovedSegment : TSGTCPReceivedSegment);
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

procedure TSGTransmissionControlProtocolEmulator.ReceivedSegmentsExclude(const Segment : TSGTCPReceivedSegment);
var
	Index : TSGMaxEnum;
	RemovedSegment : TSGTCPReceivedSegment;
begin
if (FReceivedSegments <> nil) and (Length(FReceivedSegments) > 0) then
	begin
	ConnectSegments();
	Index := 0;
	while Index <= High(FReceivedSegments) do
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
		    RemovedSegment := TSGTCPReceivedSegment.Create(FReceivedSegments[Index].SegmentBegin, Segment.SegmentEnd);
			FReceivedSegments[Index] := TSGTCPReceivedSegment.Create(Segment.SegmentEnd + 1, FReceivedSegments[Index].SegmentEnd);
			MoveBuffer(RemovedSegment);
			end
		else if (FReceivedSegments[Index].SegmentBegin <= Segment.SegmentBegin) and 
		        (FReceivedSegments[Index].SegmentEnd >= Segment.SegmentEnd) then
		    begin
		    FReceivedSegments[Index] := TSGTCPReceivedSegment.Create(Segment.SegmentBegin, Segment.SegmentBegin - 1);
		    FReceivedSegments += TSGTCPReceivedSegment.Create(Segment.SegmentEnd + 1, FReceivedSegments[Index].SegmentEnd);
			ConnectSegments();
		    end
		else
			Index += 1;
	end;
end;

procedure TSGTransmissionControlProtocolEmulator.PushProcess();
var
	PushingNumber : TSGTcpSequence;
	ToExit : TSGBoolean = False;
begin
if (FSignificantNumbers <> nil) and (Length(FSignificantNumbers) > 0) then
	begin
	SGQuickSort(FSignificantNumbers[0], Length(FSignificantNumbers), SizeOf(TSGTCPSignificantNumbers), @TSGTCPSignificantNumber_Comparison);
	repeat
	PushingNumber := FSignificantNumbers[0].Number;
	if ReceivedSegmentsIncludes(TSGTCPReceivedSegment.Create(FFirstBufferElementAddress, PushingNumber)) then
		begin
		PushData(FFirstBufferElement, PushingNumber - FFirstBufferElementAddress + 1);
		ReceivedSegmentsExclude(TSGTCPReceivedSegment.Create(FFirstBufferElementAddress, PushingNumber));
		FSignificantNumbers -= TSGTCPSignificantNumber.Create(SGTCPSignificantPush, PushingNumber);
		end
	else
		ToExit := True;
	until ToExit or (FSignificantNumbers = nil) or (Length(FSignificantNumbers) = 0);
	end;
end;

procedure TSGTransmissionControlProtocolEmulator.PushData(const _DataAddress : TSGTCPBufferAddress; const _Size : TSGMaxEnum);
var
	Stream : TMemoryStream = nil;
begin
FBufferCountWrites += 1;
//TSGLog.Source([Self, ' Push data:  = 0x', SGStr4BytesHex(FBeginSequenceNumber, False)]);
Stream := TMemoryStream.Create();
Stream.Write(FBuffer[_DataAddress], _Size);
HandleData(Stream);
SGKill(Stream);
end;

procedure TSGTransmissionControlProtocolEmulator.Push(const PushNumber : TSGTcpSequence);
begin
if FBufferInitialized then
	begin
	if (not (TSGTCPSignificantNumber.Create(SGTCPSignificantPush, PushNumber) in FSignificantNumbers)) then
		FSignificantNumbers += TSGTCPSignificantNumber.Create(SGTCPSignificantPush, PushNumber);
	PushProcess();
	end;
end;

procedure TSGTransmissionControlProtocolEmulator.InitBuffer(const InitialBufferNumper : TSGTcpSequence);
begin
Reset();
FFirstBufferElement := SG_TCP_BUFFER_POSITION;
FFirstBufferElementAddress := InitialBufferNumper;
FBufferInitialized := True;
end;

procedure TSGTransmissionControlProtocolEmulator.Synchronize(const SynchronizeNumber : TSGTcpSequence);
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

procedure TSGTransmissionControlProtocolEmulator.HandleData(const Header : TSGTCPHeader; const Data : TStream);
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

procedure TSGTransmissionControlProtocolEmulator.Reset();
begin
FillChar(FBuffer^, SG_TCP_BUFFER_SIZE, 0);
FFirstBufferElement := SG_TCP_BUFFER_POSITION;
FFirstBufferElementAddress := 0;
FBufferInitialized := False;
end;

constructor TSGTransmissionControlProtocolEmulator.Create();
begin
inherited;
FCountDataHandles := 0;
FBufferCountReads := 0;
FBufferCountWrites := 0;
FSignificantNumbers := nil;
FReceivedSegments := nil;
FFinalized := False;
FAcknowledgement := 0;
FBuffer := GetMem(SG_TCP_BUFFER_SIZE);
FSynchronized := False;
FBeginSequenceNumber := 0;
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
SGKill(FSignificantNumbers);
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

{$DEFINE DATATYPE_LIST_HELPER := TSGTCPSignificantNumbersHelper}
{$DEFINE DATATYPE_LIST        := TSGTCPSignificantNumbers}
{$DEFINE DATATYPE             := TSGTCPSignificantNumber}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
