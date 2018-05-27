{$INCLUDE SaGe.inc}

unit SaGeEthernetPacketFrameBase;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeTextFileStream
	
	,Classes
	;

type
	// Base types
	TSGEthernetPacketFrameStream = TStream;
	TSGEthernetPacketFrameSize = TSGUInt64;
	
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
			public
		class procedure KillProtocol(var Protocol : TSGEthernetPacketProtocolFrame);
		class function ReadProtocolClass(
			const ClassTypeVariable : TSGEthernetPacketProtocolFrameClass;
			const ClassSize : TSGEthernetPacketFrameSize;
			var Protocol : TSGEthernetPacketProtocolFrame;
			const Stream : TSGEthernetPacketFrameStream) : TSGBoolean;
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

class procedure TSGEthernetPacketDataFrame.KillProtocol(var Protocol : TSGEthernetPacketProtocolFrame);
begin
if Protocol <> nil then
	begin
	Protocol.Destroy();
	Protocol := nil;
	end;
end;

class function TSGEthernetPacketDataFrame.ReadProtocolClass(
	const ClassTypeVariable : TSGEthernetPacketProtocolFrameClass;
	const ClassSize : TSGEthernetPacketFrameSize;
	var Protocol : TSGEthernetPacketProtocolFrame;
	const Stream : TSGEthernetPacketFrameStream) : TSGBoolean;
begin
Result := False;
KillProtocol(Protocol);
if (ClassTypeVariable <> nil) and (Stream <> nil) then
	begin
	Protocol := ClassTypeVariable.Create();
	Protocol.Read(Stream, ClassSize);
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
