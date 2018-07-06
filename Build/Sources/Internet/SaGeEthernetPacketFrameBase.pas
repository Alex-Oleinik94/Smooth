{$INCLUDE SaGe.inc}

unit SaGeEthernetPacketFrameBase;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeTextFileStream
	
	,Classes
	;

type
	// Base types
	TSGEthernetPacketFrameStream = TStream;
	TSGEthernetPacketFrameCreatedStream = TMemoryStream;
	TSGEthernetPacketFrameSize = TSGInt64;
	
	// Class types
	TSGEthernetPacketDataFrame = class;
	TSGEthernetPacketProtocolFrame = class;
	TSGEthernetPacketProtocolFrameClass = class of TSGEthernetPacketProtocolFrame;
	
	// Classes
	
	// ============================
	// =TSGEthernetPacketDataFrame=
	// ============================
	
	TSGEthernetPacketDataFrame = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FFrameName : TSGString;
			private
		FPadded : TSGEthernetPacketFrameStream; // todo
			public
		property FrameName : TSGString read FFrameName;
			public
		procedure Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize); virtual;
		procedure Write(const Stream : TSGEthernetPacketFrameStream); virtual;
		procedure ExportInfo(const Stream : TSGTextFileStream); virtual; abstract;
		function Size() : TSGEthernetPacketFrameSize; virtual;
		function Data() : TSGEthernetPacketFrameStream; virtual;
		function Description() : TSGString; virtual;
		function CreateStream() : TSGEthernetPacketFrameCreatedStream; virtual;
			public
		class procedure KillProtocol(var _Protocol : TSGEthernetPacketProtocolFrame);
		class function ReadProtocolClass(
			const _ClassTypeVariable : TSGEthernetPacketProtocolFrameClass;
			const _ClassSize : TSGEthernetPacketFrameSize;
			var _Protocol : TSGEthernetPacketProtocolFrame;
			const _Stream : TSGEthernetPacketFrameStream) : TSGBoolean;
		end;
	
	// ================================
	// =TSGEthernetPacketProtocolFrame=
	// ================================
	
	TSGEthernetPacketProtocolFrame = class(TSGEthernetPacketDataFrame)
			public
		property ProtocolName : TSGString read FFrameName;
			public
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
		function Size() : TSGEthernetPacketFrameSize; override;
		procedure ExportOptionsInfo(const Stream : TSGTextFileStream); virtual;
		end;

implementation

uses
	 SaGeStreamUtils
	;

// ============================
// =TSGEthernetPacketDataFrame=
// ============================

function TSGEthernetPacketDataFrame.CreateStream() : TSGEthernetPacketFrameCreatedStream;
begin
Result := nil;
end;

function TSGEthernetPacketDataFrame.Description() : TSGString;
begin
Result := '';
end;

function TSGEthernetPacketDataFrame.Data() : TSGEthernetPacketFrameStream;
begin
Result := nil;
end;

procedure TSGEthernetPacketDataFrame.Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize);
begin
end;

procedure TSGEthernetPacketDataFrame.Write(const Stream : TSGEthernetPacketFrameStream);
begin
end;

constructor TSGEthernetPacketDataFrame.Create();
begin
inherited;
FFrameName := '';
FPadded := nil;
end;

destructor TSGEthernetPacketDataFrame.Destroy();
begin
SGKill(FPadded);
FFrameName := '';
inherited;
end;

function TSGEthernetPacketDataFrame.Size() : TSGEthernetPacketFrameSize;
begin
Result := 0;
end;

class procedure TSGEthernetPacketDataFrame.KillProtocol(var _Protocol : TSGEthernetPacketProtocolFrame);
begin
if _Protocol <> nil then
	begin
	_Protocol.Destroy();
	_Protocol := nil;
	end;
end;

class function TSGEthernetPacketDataFrame.ReadProtocolClass(
	const _ClassTypeVariable : TSGEthernetPacketProtocolFrameClass;
	const _ClassSize : TSGEthernetPacketFrameSize;
	var _Protocol : TSGEthernetPacketProtocolFrame;
	const _Stream : TSGEthernetPacketFrameStream) : TSGBoolean;
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
// =TSGEthernetPacketProtocolFrame=
// ================================

procedure TSGEthernetPacketProtocolFrame.ExportOptionsInfo(const Stream : TSGTextFileStream);
begin
end;

function TSGEthernetPacketProtocolFrame.Size() : TSGEthernetPacketFrameSize;
begin
Result := inherited;
end;

procedure TSGEthernetPacketProtocolFrame.ExportInfo(const Stream : TSGTextFileStream);
begin
Stream.WriteLn(['[protocol]']);
end;

end.
