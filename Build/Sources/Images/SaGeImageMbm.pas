{$INCLUDE SaGe.inc}

unit SaGeImageMbm;

interface

uses
	 SaGeBase
	,SaGeBitMap
	
	,Classes
	;

function SGLoadMBMFromStream(const _Stream : TMemoryStream; const Position : TSGUInt32 = 20) : TSGBitMap; overload;
function SGLoadMBMFromStream(const _Stream : TStream) : TSGBitMap; overload;

implementation

uses
	 SaGeStreamUtils
	;

function SGLoadMBMFromStream(const _Stream : TMemoryStream; const Position : TSGUInt32 = 20) : TSGBitMap; overload;
var
	I : TSGUInt32;
	Compression : TSGBoolean = False;
	BitsPerPixel : TSGUInt32;

function GetLongWordBack(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
begin
Result:=FileBits[Position+3]+FileBits[Position+2]*256+FileBits[Position+1]*256*256+FileBits[Position]*256*256*256;
end;

function GetLongWord(const FileBits:PByte;const Position:TSGUInt32):TSGUInt32;
begin
Result:=FileBits[Position]+FileBits[Position+1]*256+FileBits[Position+2]*256*256+FileBits[Position+3]*256*256*256;
end;

begin
Result := TSGBitMap.Create();
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
	Result.CreateTypes();
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
				Result.BitMap[i*3+0]:=PByte(_Stream.Memory)[Position+40+i*3+2];
				Result.BitMap[i*3+1]:=PByte(_Stream.Memory)[Position+40+i*3+1];
				Result.BitMap[i*3+2]:=PByte(_Stream.Memory)[Position+40+i*3+0];
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
	Result.ClearBitMapBits();
	end;

	{writeln(Width);
	writeln(Height);
	writeln(BitMapBits);}
end;

function SGLoadMBMFromStream(const _Stream : TStream) : TSGBitMap; overload;
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
_Stream.Position := 0;
SGCopyPartStreamToStream(_Stream, Stream, _Stream.Size);
Stream.Position := 0;
Result := SGLoadMBMFromStream(Stream);
SGKill(Stream);
end;

end.
