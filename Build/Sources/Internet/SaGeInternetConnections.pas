{$INCLUDE SaGe.inc}

unit SaGeInternetConnections;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetPacketCaptureHandler
	,SaGeInternetConnection
	,SaGeDateTime
	,SaGeEthernetPacketFrame
	
	,Classes
	;

type
	TSGInternetConnections = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FConnections : TSGInternetConnectionList;
		FSizeOutPackets : TSGUInt64;
			protected
		procedure HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime); override;
		procedure HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); override;
		function HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean; override;
			protected
		function HandleNewConnection(const ConnectionClass : TSGInternetConnectionClass; const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
		function HandlePacketNewConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
		function HandlePacketConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
		end;

procedure SGRegisterInternetConnectionClass(const ClassVariable : TSGInternetConnectionClass);

implementation

uses
	 SaGeInternetConnectionTCP
	;

var
	ConnectionClasses : TSGInternetConnectionClassList = nil;

procedure SGRegisterInternetConnectionClass(const ClassVariable : TSGInternetConnectionClass);
var
	Index : TSGMaxEnum;
	Add : TSGBoolean;
begin
Add := False;
if (ConnectionClasses = nil) or (Length(ConnectionClasses) = 0) then
	Add := True
else
	begin
	Add := True;
	for Index := 0 to High(ConnectionClasses) do
		if ConnectionClasses[Index] = ClassVariable then
			begin
			Add := False;
			break;
			end;
	end;
if Add then
	ConnectionClasses += ClassVariable;
end;

// ==================================
// ======TSGInternetConnections======
// ==================================

function TSGInternetConnections.HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean;
begin
Result := False;
end;

procedure TSGInternetConnections.HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); 
begin
end;

function TSGInternetConnections.HandleNewConnection(const ConnectionClass : TSGInternetConnectionClass; const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	NewConnection : TSGInternetConnection = nil;
begin
NewConnection := TSGInternetConnectionClass.Create();
Result := NewConnection.PacketPushed(Time, Date, Frame);
if not Result then
	SGKill(NewConnection)
else
	FConnections += NewConnection;
end;

function TSGInternetConnections.HandlePacketNewConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	Index : TSGMaxEnum;
begin
Result := False;
if (ConnectionClasses <> nil) and (Length(ConnectionClasses) > 0) then
	for Index := High(ConnectionClasses) downto 0 do
		if ConnectionClasses[Index].PacketComparable(Frame) then
			begin
			Result := HandleNewConnection(
				ConnectionClasses[Index],
				Identificator,
				Frame,
				Date,
				Time);
			if Result then
				break;
			end;
end;

function TSGInternetConnections.HandlePacketConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	Index : TSGMaxEnum;
begin
Result := False;
if (FConnections <> nil) and (Length(FConnections) > 0) then
	for Index := High(FConnections) downto 0 do
		if FConnections[Index].PacketPushed(Time, Date, Frame) then
			begin
			Result := True;
			break;
			end;
end;

procedure TSGInternetConnections.HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime);
var
	Frame : TSGEthernetPacketFrame;
	Date : TSGDateTime;
begin
Date.Get();
Frame := TSGEthernetPacketFrame.Create();
Stream.Position := 0;
Frame.Read(Stream, Stream.Size);
if not HandlePacketConnections(Identificator, Frame, Date, Time) then
	if not HandlePacketNewConnections(Identificator, Frame, Date, Time) then
		begin
		SGKill(Frame);
		FSizeOutPackets += Stream.Size;
		end;
end;

constructor TSGInternetConnections.Create();
begin
inherited;
FConnections := nil;
FSizeOutPackets := 0;
end;

destructor TSGInternetConnections.Destroy();
begin
SGKill(FConnections);
inherited;
end;

end.
