{$INCLUDE Smooth.inc}

unit SmoothEthernetPacketFrameBase;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothTextFileStream
	
	,Classes
	;

type
	// Base types
	TSEthernetPacketFrameStream = TStream;
	TSEthernetPacketFrameCreatedStream = TMemoryStream;
	TSEthernetPacketFrameSize = TSInt64;
	
	// Class types
	TSEthernetPacketDataFrame = class;
	TSEthernetPacketProtocolFrame = class;
	TSEthernetPacketProtocolFrameClass = class of TSEthernetPacketProtocolFrame;
	
	// Classes
	
	// ============================
	// =TSEthernetPacketDataFrame=
	// ============================
	
	TSEthernetPacketDataFrame = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FFrameName : TSString;
			private
		FPadded : TSEthernetPacketFrameStream; // todo
			public
		property FrameName : TSString read FFrameName;
			public
		procedure Read(const Stream : TSEthernetPacketFrameStream; const BlockSize : TSEthernetPacketFrameSize); virtual;
		procedure Write(const Stream : TSEthernetPacketFrameStream); virtual;
		procedure ExportInfo(const Stream : TSTextFileStream); virtual; abstract;
		function Size() : TSEthernetPacketFrameSize; virtual;
		function Data() : TSEthernetPacketFrameStream; virtual;
		function Description() : TSString; virtual;
		function CreateStream() : TSEthernetPacketFrameCreatedStream; virtual;
			public
		class procedure KillProtocol(var _Protocol : TSEthernetPacketProtocolFrame);
		class function ReadProtocolClass(
			const _ClassTypeVariable : TSEthernetPacketProtocolFrameClass;
			const _ClassSize : TSEthernetPacketFrameSize;
			var _Protocol : TSEthernetPacketProtocolFrame;
			const _Stream : TSEthernetPacketFrameStream) : TSBoolean;
		end;
	
	// ================================
	// =TSEthernetPacketProtocolFrame=
	// ================================
	
	TSEthernetPacketProtocolFrame = class(TSEthernetPacketDataFrame)
			public
		property ProtocolName : TSString read FFrameName;
			public
		procedure ExportInfo(const Stream : TSTextFileStream); override;
		function Size() : TSEthernetPacketFrameSize; override;
		procedure ExportOptionsInfo(const Stream : TSTextFileStream); virtual;
		end;

implementation

uses
	 SmoothStreamUtils
	;

// ============================
// =TSEthernetPacketDataFrame=
// ============================

function TSEthernetPacketDataFrame.CreateStream() : TSEthernetPacketFrameCreatedStream;
begin
Result := nil;
end;

function TSEthernetPacketDataFrame.Description() : TSString;
begin
Result := '';
end;

function TSEthernetPacketDataFrame.Data() : TSEthernetPacketFrameStream;
begin
Result := nil;
end;

procedure TSEthernetPacketDataFrame.Read(const Stream : TSEthernetPacketFrameStream; const BlockSize : TSEthernetPacketFrameSize);
begin
end;

procedure TSEthernetPacketDataFrame.Write(const Stream : TSEthernetPacketFrameStream);
begin
end;

constructor TSEthernetPacketDataFrame.Create();
begin
inherited;
FFrameName := '';
FPadded := nil;
end;

destructor TSEthernetPacketDataFrame.Destroy();
begin
SKill(FPadded);
FFrameName := '';
inherited;
end;

function TSEthernetPacketDataFrame.Size() : TSEthernetPacketFrameSize;
begin
Result := 0;
end;

class procedure TSEthernetPacketDataFrame.KillProtocol(var _Protocol : TSEthernetPacketProtocolFrame);
begin
if _Protocol <> nil then
	begin
	_Protocol.Destroy();
	_Protocol := nil;
	end;
end;

class function TSEthernetPacketDataFrame.ReadProtocolClass(
	const _ClassTypeVariable : TSEthernetPacketProtocolFrameClass;
	const _ClassSize : TSEthernetPacketFrameSize;
	var _Protocol : TSEthernetPacketProtocolFrame;
	const _Stream : TSEthernetPacketFrameStream) : TSBoolean;
begin
Result := False;
KillProtocol(_Protocol);
if (_ClassTypeVariable <> nil) and (_Stream <> nil) then
	begin
	_Protocol := _ClassTypeVariable.Create();
	_Protocol.Read(_Stream, _ClassSize);
	Result := True;
	end;
end;

// ================================
// =TSEthernetPacketProtocolFrame=
// ================================

procedure TSEthernetPacketProtocolFrame.ExportOptionsInfo(const Stream : TSTextFileStream);
begin
end;

function TSEthernetPacketProtocolFrame.Size() : TSEthernetPacketFrameSize;
begin
Result := inherited;
end;

procedure TSEthernetPacketProtocolFrame.ExportInfo(const Stream : TSTextFileStream);
begin
Stream.WriteLn(['[protocol]']);
end;

end.
