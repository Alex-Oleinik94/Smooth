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
	TSGEthernetPacketDataFrameStream = TStream;
	TSGEthernetPacketDataFrame = class(TSGNamed)
			public
		procedure Read(const Stream : TSGEthernetPacketDataFrameStream); virtual; abstract;
		procedure Write(const Stream : TSGEthernetPacketDataFrameStream); virtual; abstract;
		procedure ExportInfo(const Stream : TSGTextFileStream); virtual; abstract;
		end;
	
	TSGEthernetPacketProtocolFrame = class(TSGEthernetPacketDataFrame) 
			public
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
		end;
	TSGEthernetPacketProtocolFrameClass = class of TSGEthernetPacketProtocolFrame;

implementation

procedure TSGEthernetPacketProtocolFrame.ExportInfo(const Stream : TSGTextFileStream);
begin
Stream.WriteLn(['[protocol]']);
end;

end.
