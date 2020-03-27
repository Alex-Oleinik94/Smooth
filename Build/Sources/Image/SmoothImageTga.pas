{$INCLUDE Smooth.inc}

unit SmoothImageTga;

interface

uses
		// System
	 SysUtils
	,Classes
		// Engine
	,SmoothBase
	,SmoothBitMap;

type
	TSTGAHeader = packed record
		FileType     : Byte;
		ColorMapType : Byte;
		ImageType    : Byte;
		ColorMapSpec : Array[0..4] of Byte;
		OrigX  : Array [0..1] of Byte;
		OrigY  : Array [0..1] of Byte;
		Width  : Array [0..1] of Byte;
		Height : Array [0..1] of Byte;
		BPP    : Byte;
		ImageInfo : Byte;
		end;

// Загрузка формата TGA
function LoadTGA(const Stream:TStream):TSBitmap;

implementation

function LoadTGA(const Stream:TStream):TSBitmap;

procedure TGACopySwapPixel(const Source, Destination: Pointer);
{$IF defined(WITHASMINC))}
	assembler;
	asm
	push eax
	push edx
	push ebx
	mov eax, source
	mov edx, destination
	mov bl,[eax+0]
	mov bh,[eax+1]
	mov [edx+2],bl
	mov [edx+1],bh
	mov bl,[eax+2]
	mov bh,[eax+3]
	mov [edx+0],bl
	mov [edx+3],bh
	pop ebx
	pop edx
	pop eax
	end;
{$ELSE}
	var
			bl,bh:byte;
	begin
	bl:=PByte(Source)[0];
	bh:=PByte(Source)[1];
	PByte(Destination)[2]:=bl;
	PByte(Destination)[1]:=bh;
	bl:=PByte(Source)[2];
	bh:=PByte(Source)[3];
	PByte(Destination)[0]:=bl;
	PByte(Destination)[3]:=bh;
	end;
	{$ENDIF}

var
	TGAHeader : TSTGAHeader;
	CompImage : TSPointer;
	ColorDepth    : Integer;
	ImageSize     : TSMaxEnum;
	BufferIndex : Integer;
	CurrentByte : Integer;
	CurrentPixel : Integer;
	I : Integer;
	Front: ^Byte;
	Back: ^Byte;
	Temp: Byte;

begin
try
	Result := TSBitmap.Create();
	Stream.ReadBuffer(TGAHeader, SizeOf(TGAHeader));
	if ((TGAHeader.ImageType <> 2) and (TGAHeader.ImageType <> 10)) or (TGAHeader.ColorMapType<>0) then  
		begin
		SKill(Result);
		Exit;
		end;
	Result.Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
	Result.Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
	Result.ChannelSize := 8;
	Result.Channels    := TGAHeader.BPP div 8;
	ImageSize := Result.DataSize;
	if (Result.Channels < 3) then  
		begin
		SKill(Result);
		Exit;
		end;
	Result.ReAllocateMemory();
	if TGAHeader.ImageType = 2 then
		begin
		if Stream.Size-Stream.Position < ImageSize then
			begin
			SKill(Result);
			Exit;
			end;
		Stream.ReadBuffer(Result.Data^, ImageSize);
		for I :=0 to Result.Width * Result.Height - 1 do
			begin
			Front := TSPointer(TSMaxEnum(Result.Data) + I * Result.Channels);
			Back := TSPointer(TSMaxEnum(Result.Data) + I * Result.Channels + 2);
			Temp := Front^;
			Front^ := Back^;
			Back^ := Temp;
			end;
		GetMem(CompImage, Result.Width * Result.Channels);
		for I :=0 to (Result.Height div 2) - 1 do
			begin
			Move(
				TSPointer(TSMaxEnum(Result.Data) + I * Result.Width * Result.Channels)^,
				CompImage^,
				Result.Width * Result.Channels);
			Move(
				TSPointer(TSMaxEnum(Result.Data) + (Result.Height - I) * Result.Width * Result.Channels)^,
				TSPointer(TSMaxEnum(Result.Data) + I * Result.Width * Result.Channels)^,
				Result.Width * Result.Channels);
			Move(
				CompImage^,
				TSPointer(TSMaxEnum(Result.Data) + (Result.Height - I) * Result.Width * Result.Channels)^,
				Result.Width * Result.Channels);
			end;
		FreeMem(CompImage);
		end
	else
		begin
		ColorDepth :=Result.Channels;
		CurrentByte :=0;
		CurrentPixel :=0;
		BufferIndex :=0;
		GetMem(CompImage,Stream.Size-SizeOf(TGAHeader));
		Stream.ReadBuffer(CompImage^,Stream.Size-SizeOf(TGAHeader));
		repeat
		Front := TSPointer(TSMaxEnum(CompImage) + BufferIndex);
		Inc(BufferIndex);
		if Front^ < 128 then
			begin
			For I := 0 to Front^ do
				begin
				TGACopySwapPixel(TSPointer(TSMaxEnum(CompImage)+BufferIndex+I*ColorDepth), TSPointer(TSMaxEnum(Result.Data)+CurrentByte));
				CurrentByte := CurrentByte + ColorDepth;
				Inc(CurrentPixel);
				end;
			BufferIndex :=BufferIndex + (Front^+1)*ColorDepth
			end
		else
			begin
			For I := 0 to Front^ -128 do
				begin
				TGACopySwapPixel(TSPointer(TSMaxEnum(CompImage)+BufferIndex), TSPointer(TSMaxEnum(Result.Data)+CurrentByte));
				CurrentByte := CurrentByte + ColorDepth;
				Inc(CurrentPixel);
				end;
			BufferIndex :=BufferIndex + ColorDepth
			end;
		until CurrentPixel >= Result.Width*Result.Height;
		end;
except
	if (Result <> nil) then
		SKill(Result);
end;
end;

end.
