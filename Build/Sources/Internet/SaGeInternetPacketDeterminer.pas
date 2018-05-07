{$INCLUDE SaGe.inc}

unit SaGeInternetPacketDeterminer;

interface

uses
	 SaGeBase
	,SaGeInternetBase
	,SaGeTextFileStream
	;


procedure SGWritePacketInfo(const Stream : TSGTextFileStream; const Packet; const Length : TSGUInt64);

implementation

procedure SGWritePacketInfo(const Stream : TSGTextFileStream; const Packet; const Length : TSGUInt64);
begin

end;

end.
