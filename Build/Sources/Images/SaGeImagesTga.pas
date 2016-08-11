{$INCLUDE SaGe.inc}

unit SaGeImagesTga;

interface

uses
	 SysUtils
	,Classes
	,SaGeBase
	,SaGeBased
	,SaGeImagesBase;

// Загрузка формата TGA
function LoadTGA(const Stream:TStream):TSGBitmap;

implementation

function LoadTGA(const Stream:TStream):TSGBitmap;

procedure TGACopySwapPixel(const Source, Destination: Pointer);
{$IF defined(CPU32) and defined(CPU386))}
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
	TGAHeader : packed record
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
	CompImage : Pointer;
	ColorDepth    : Integer;
	ImageSize     : Integer;
	BufferIndex : Integer;
	CurrentByte : Integer;
	CurrentPixel : Integer;
	I : Integer;
	Front: ^Byte;
	Back: ^Byte;
	Temp: Byte;

begin
try
	Result:=TSGBitmap.Create;
	Stream.ReadBuffer(TGAHeader, SizeOf(TGAHeader));
	if ((TGAHeader.ImageType <> 2) and (TGAHeader.ImageType <> 10)) or (TGAHeader.ColorMapType<>0) then  
		begin
		Result.Destroy;
		Result:=nil;
		Exit;
		end;
	Result.Width:=TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
	Result.Height:=TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
	Result.FSizeChannel:=8;
	Result.FChannels:= TGAHeader.BPP div 8;
	ImageSize:=Result.Width*Result.Height*Result.FChannels;
	if (Result.FChannels<3) then  
		begin
		Result.Destroy;
		Result:=nil;
		Exit;
		end;
	GetMem(Result.FBitMap,ImageSize);
	if TGAHeader.ImageType = 2 then
		begin
		if Stream.Size-Stream.Position<ImageSize then
			begin
			FreeMem(Result.FBitMap,ImageSize);
			Result.FBitMap:=nil;
			Result.Destroy;
			Result:=nil;
			Exit;
			end;
		Stream.ReadBuffer(Result.FBitMap^,ImageSize);
		for I :=0 to Result.Width * Result.Height - 1 do
			begin
			{$WARNINGS OFF}
			Front := Pointer(LongWord(Result.FBitMap) + I * Result.FChannels);
			Back := Pointer(LongWord(Result.FBitMap) + I * Result.FChannels + 2);
			{$WARNINGS ON}
			Temp := Front^;
			Front^ := Back^;
			Back^ := Temp;
			end;
		end
	else
		begin
		ColorDepth :=Result.FChannels;
		CurrentByte :=0;
		CurrentPixel :=0;
		BufferIndex :=0;
		GetMem(CompImage,Stream.Size-SizeOf(TGAHeader));
		Stream.ReadBuffer(CompImage^,Stream.Size-SizeOf(TGAHeader));
		repeat
		{$WARNINGS OFF}
		Front := Pointer(LongWord(CompImage) + BufferIndex);
		Inc(BufferIndex);
		if Front^ < 128 then
			begin
			For I := 0 to Front^ do
				begin
				TGACopySwapPixel(Pointer(LongWord(CompImage)+BufferIndex+I*ColorDepth), Pointer(LongWord(Result.FBitMap)+CurrentByte));
				CurrentByte := CurrentByte + ColorDepth;
				Inc(CurrentPixel);
				end;
			BufferIndex :=BufferIndex + (Front^+1)*ColorDepth
			end
		else
			begin
			For I := 0 to Front^ -128 do
				begin
				TGACopySwapPixel(Pointer(LongWord(CompImage)+BufferIndex), Pointer(LongWord(Result.FBitMap)+CurrentByte));
				CurrentByte := CurrentByte + ColorDepth;
				Inc(CurrentPixel);
				end;
			BufferIndex :=BufferIndex + ColorDepth
			end;
		{$WARNINGS ON}
		until CurrentPixel >= Result.Width*Result.Height;
		end;
	Result.CreateTypes;
except
	if Result<>nil then
		begin
		if Result.FBitMap<>nil then
			begin
			FreeMem(Result.FBitMap);
			Result.FBitMap:=nil;
			end;
		Result.Destroy;
		Result:=nil;
		end;
	end;
end;

end.
