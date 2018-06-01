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
	TSGTransmissionControlProtocolEmulator = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FBuffer : TSGTcpSequenceBuffer;
		FFirstBufferElement : TSGInt32;
		FFirstBufferElementAddress : TSGTcpSequence;
		FFirstBufferElementSeted : TSGBoolean;
		FAcknowledgement : TSGTcpSequence;
		FFinalized : TSGBoolean;
			public
		property Finalized : TSGBoolean read FFinalized;
			public
		procedure HandleData(const Data : TStream); virtual; abstract;
			public
		procedure Reset(); virtual;
		procedure HandleData(const Header : TSGTCPHeader; const Data : TStream); virtual;
		procedure HandleAcknowledgement(const AcknowledgementValue : TSGTcpSequence); virtual;
		procedure PutData(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream); virtual;
		procedure Push(const Number : TSGTcpSequence); virtual;
		end;

procedure SGKill(var Emulator : TSGTransmissionControlProtocolEmulator);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeStreamUtils
	;

procedure TSGTransmissionControlProtocolEmulator.HandleAcknowledgement(const AcknowledgementValue : TSGTcpSequence);
begin

end;

procedure TSGTransmissionControlProtocolEmulator.PutData(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin
if not FFirstBufferElementSeted then
	begin
	FFirstBufferElement := 0;
	FFirstBufferElementSeted := True;
	FFirstBufferElementAddress := TcpSequencePointer;
	end;
Stream.Position := 0;
Stream.Read(FBuffer[FFirstBufferElement + TcpSequencePointer - FFirstBufferElementAddress], Stream.Size);
end;

procedure TSGTransmissionControlProtocolEmulator.Push(const Number : TSGTcpSequence);
var
	Stream : TMemoryStream = nil;
begin
if FFirstBufferElementSeted and (Number - FFirstBufferElementAddress > 0) then
	begin
	Stream := TMemoryStream.Create();
	Stream.Write(FBuffer[FFirstBufferElement + Number - FFirstBufferElementAddress], Number - FFirstBufferElementAddress);
	FFirstBufferElement += Number - FFirstBufferElementAddress;
	FFirstBufferElementAddress := Number;
	
	HandleData(Stream);
	SGKill(Stream);
	end;
end;

procedure TSGTransmissionControlProtocolEmulator.HandleData(const Header : TSGTCPHeader; const Data : TStream);
begin
if Data <> nil then
	PutData(Header.SequenceNumber, Data);
if Header.Reset then
	Reset();
if Header.Push then
	Push(Header.SequenceNumber);
if Header.Final then
	FFinalized := True;
end;

procedure TSGTransmissionControlProtocolEmulator.Reset();
begin
FillChar(FBuffer^, SG_TCP_BUFFER_SIZE, 0);
FAcknowledgement := 0;
FFirstBufferElement := 0;
FFirstBufferElementSeted := False;
FFirstBufferElementAddress := 0;
end;

constructor TSGTransmissionControlProtocolEmulator.Create();
begin
inherited;
FFinalized := False;
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

end.
