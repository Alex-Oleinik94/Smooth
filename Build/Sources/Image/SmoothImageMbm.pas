{$INCLUDE Smooth.inc}

unit SmoothImageMbm;

interface

uses
	 SmoothBase
	,SmoothBitMap
	
	,Classes
	;

function SLoadMBMFromStream(const _Stream : TMemoryStream; const Position : TSUInt32 = 20) : TSBitMap; overload;
function SLoadMBMFromStream(const _Stream : TStream) : TSBitMap; overload;

implementation

uses
	 SmoothStreamUtils
	;

function SLoadMBMFromStream(const _Stream : TMemoryStream; const Position : TSUInt32 = 20) : TSBitMap; overload;
var
	I : TSUInt32;
	Compression : TSBoolean = False;
	BitsPerPixel : TSUInt32;

function GetLongWordBack(const FileBits:PByte;const Position:TSUInt32):TSUInt32;
begin
Result:=FileBits[Position+3]+FileBits[Position+2]*256+FileBits[Position+1]*256*256+FileBits[Position]*256*256*256;
end;

function GetLongWord(const FileBits:PByte;const Position:TSUInt32):TSUInt32;
begin
Result:=FileBits[Position]+FileBits[Position+1]*256+FileBits[Position+2]*256*256+FileBits[Position+3]*256*256*256;
end;

begin
Result := TSBitMap.Create();
try
	Result.Width:=GetLongWord(PByte(_Stream.Memory),Position+8);
	Result.Height:=GetLongWord(PByte(_Stream.Memory),Position+12);
	BitsPerPixel := GetLongWord(PByte(_Stream.Memory),Position+24);
	case BitsPerPixel of
	16:
		begin
		Result.ChannelSize:=4;
		Result.Channels:=4;
		end;
	24:
		begin
		Result.Channels:=3;
		Result.ChannelSize:=8;
		end;
	32:
		begin
		Result.Channels:=4;
		Result.ChannelSize:=8;
		end;
	else
		begin
		Result.Channels:=0;
		Result.ChannelSize:=0;
		end;
	end;
	Compression:=(GetLongWord(PByte(_Stream.Memory),Position+36)<>0);
	Result.ReAllocateMemory();
	case BitsPerPixel of
	24:
		begin
		if Compression then
			begin

			end
		else
			begin
			for i:=0 to Result.Width*Result.Height-1 do
				begin
				Result.Data[i*3+0]:=PByte(_Stream.Memory)[Position+40+i*3+2];
				Result.Data[i*3+1]:=PByte(_Stream.Memory)[Position+40+i*3+1];
				Result.Data[i*3+2]:=PByte(_Stream.Memory)[Position+40+i*3+0];
				end;
			end;
		end;
	16:
		begin

		end;
	8:
		begin

		end;
	end;
except
	Result.FreeData();
	end;

	{writeln(Width);
	writeln(Height);
	writeln(BitMapBits);}
end;

function SLoadMBMFromStream(const _Stream : TStream) : TSBitMap; overload;
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
_Stream.Position := 0;
SCopyPartStreamToStream(_Stream, Stream, _Stream.Size);
Stream.Position := 0;
Result := SLoadMBMFromStream(Stream);
SKill(Stream);
end;

end.
