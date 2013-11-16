{$i Includes\SaGe.inc}
unit SaGeImages;
interface
uses 
	crt
	,dos
	{$IFDEF MSWINDOWS}
		,windows
		,MMSystem
		{$ENDIF}
	,Classes
	,SysUtils
	,SaGeBase, SaGeBased
	,SaGeImagesBase
	,SaGeImagesJpeg
	,SaGeImagesPng
	,SaGeImagesBmp
	,SaGeRender
	,SaGeContext
	;
type
	SGIByte = type byte;
	
	PSGImage = ^TSGImage;
	PTSGImage = PSGImage;
	TSGImage=class(TSGContextObject)
			public
		constructor Create(const NewWay:string = '');
		destructor Destroy;override;
			public
		FImage:TSGBitMap;
		
		FStream:TMemoryStream;
		
		FTexture : SGUint;
		
		FReadyToGoToTexture:boolean;
		FWay:string;
		
		FSaveFormat:SGIByte;
		
		procedure LoadBMPToBitMap;
		procedure LoadJPEGToBitMap;
		procedure LoadMBMToBitMap(const Position:LongWord = 20);
		procedure LoadPNGToBitMap;
		procedure Saveing(const Format:SGByte = SGI_PNG);
			public
		procedure LoadToMemory;virtual;
		function LoadToBitMap:Boolean;virtual;
		procedure Loading;
		procedure ToTexture;virtual;
		procedure LoadTextureMainThread;
		procedure SaveToStream(const Stream:TStream);
		class function IsBMP(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
		class function IsMBM(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
		class function IsPNG(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
		class function IsJPEG(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
		class function GetLongWord(const FileBits:PByte;const Position:LongInt):LongWord;
		class function GetLongWordBack(const FileBits:PByte;const Position:LongInt):LongWord;
		procedure BindTexture;
		procedure DisableTexture;
		function ReadyTexture:Boolean;
		procedure FreeSream;
		procedure FreeBits;
		procedure FreeSome;
		procedure FreeTexture;
		procedure FreeAll;
		function Ready:Boolean;virtual;
		function GetBitMapBits:Cardinal;
		procedure SetBitMapBits(const Value:Cardinal);
			public 
		property FormatType : Cardinal read FImage.FFormatType write FImage.FFormatType;
		property DataType : Cardinal read FImage.FDataType write FImage.FDataType;
		property Channels : Cardinal read FImage.FChannels write FImage.FChannels;
		property BitDepth: Cardinal read FImage.FSizeChannel write FImage.FSizeChannel;
		property Texture : SGUint read FTexture write FTexture;
		property Height : Cardinal read FImage.FHeight write FImage.FHeight;
		property Width : Cardinal read FImage.FWidth write FImage.FWidth;
		property Bits : Cardinal read GetBitMapBits write SetBitMapBits;
		property BitMap : PByte read FImage.FBitMap write FImage.FBitMap;
		property Image : TSGBitMap read FImage;
		property Way:string read FWay write FWay;
		property ReadyToGoToTexture:boolean read FReadyToGoToTexture write FReadyToGoToTexture;
		property ReadyGoToTexture:boolean read FReadyToGoToTexture write FReadyToGoToTexture;
		property ReadyToTexture:boolean read FReadyToGoToTexture write FReadyToGoToTexture;
		end;
	SGImage=TSGImage;
	ArTSGImage = type packed array of TSGImage;
	TArTSGImage = ArTSGImage;

var
	ArWaitImages:TArTSGImage = nil;
	WhisImageNowLoading:SGImage = nil;

procedure SGIIdleFunction;
function LoadTGA(const Stream:TStream):TSGBitmap;

implementation

procedure TSGImage.SaveToStream(const Stream:TStream);
var
	Stream2:TMemoryStream = nil;
begin
if (FImage<>nil) and (FImage.FBitMap<>nil) then
	begin
	SavePNG(FImage,Stream);
	end
else
	if (FWay<>'') and FileExists(FWay) then
		begin
		Stream2:=TMemoryStream.Create;
		Stream2.LoadFromFile(FWay);
		Stream2.SaveToStream(Stream);
		Stream2.Destroy;
		end;
end;

procedure TSGImage.LoadTextureMainThread;
begin
if WhisImageNowLoading = nil then
	WhisImageNowLoading:=Self
else
	begin
	SetLength(ArWaitImages,Length(ArWaitImages)+1);
	ArWaitImages[High(ArWaitImages)]:=Self;
	end;
end;

procedure TGACopySwapPixel(const Source, Destination: Pointer);
{$IFNDEF CPU32}
	var
		bl,bh:byte;
	{$ENDIF}
begin
{$IFDEF CPU32}
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
	bl:=PByte(Source)[0];
	bh:=PByte(Source)[1];
	PByte(Destination)[2]:=bl;
	PByte(Destination)[1]:=bh;
	bl:=PByte(Source)[2];
	bh:=PByte(Source)[3];
	PByte(Destination)[0]:=bl;
	PByte(Destination)[3]:=bh;
	{$ENDIF}
end;

function LoadTGA(const Stream:TStream):TSGBitmap;
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

procedure TSGImage.Saveing(const Format:SGByte = SGI_PNG);
var
	Stream:TMemoryStream = nil;
	BmpStream:TMemoryStream = nil;
begin

Stream:=TMemoryStream.Create;
case Format of
SGI_PNG:
	begin
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Saveing "'+FWay+'" as PNG');
		{$ENDIF}
	SavePNG(FImage,Stream);
	end;
SGI_JPEG:
	begin
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Saveing "'+FWay+'" as JPEG');
		{$ENDIF}
	BmpStream:=TMemoryStream.Create;
	SaveBMP(FImage,BmpStream);
	SaveJPEG(BmpStream,Stream);
	BmpStream.Destroy;
	end;
SGI_BMP:
	begin
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Saveing "'+FWay+'" as BMP');
		{$ENDIF}
	SaveBMP(FImage,Stream);
	end;
else
	begin
	Stream.Destroy;
	Stream:=nil;
	end;
end;
if Stream<>nil then
	begin
	Stream.SaveToFile(Way);
	Stream.Destroy;
	end;
end;

procedure TSGImage.LoadPNGToBitMap;
begin
SaGeImagesPng.LoadPNG(FStream,FImage);
end;

procedure TSGImage.LoadJPEGToBitMap;
var
	BMPStream:TMemoryStream = nil;
begin
BMPStream:=TMemoryStream.Create;
try
LoadJPEG(FStream,BMPStream, true, 0, nil);
BMPStream.Position := 0;
finally
FStream.Destroy;
FStream:=BMPStream;
BMPStream:=nil;
LoadBMPToBitMap;
end;
end;

procedure TSGImage.Loading;
begin
LoadToMemory;
LoadToBitMap;
ToTexture;
end;

procedure TSGImage.SetBitMapBits(const Value:Cardinal);
begin
case Value of
16:
	begin
	FImage.FSizeChannel:=4;
	FImage.FChannels:=4;
	end;
24:
	begin
	FImage.FChannels:=3;
	FImage.FSizeChannel:=8;
	end;
32:
	begin
	FImage.FChannels:=4;
	FImage.FSizeChannel:=8;
	end;
else
	begin
	FImage.FChannels:=0;
	FImage.FSizeChannel:=0;
	end;
end;
FImage.CreateTypes;
end;

function TSGImage.GetBitMapBits:Cardinal;
begin
Result:=FImage.FSizeChannel*FImage.FChannels;
end;

function TSGImage.Ready:Boolean;
begin
Result:=ReadyTexture;
end;



procedure TSGImage.LoadMBMToBitMap(const Position:LongWord = 20);
var
	I:LongWord;
	Compression:Boolean = False;
begin
try
	FImage.FWidth:=GetLongWord(PByte(FStream.Memory),Position+8);
	FImage.FHeight:=GetLongWord(PByte(FStream.Memory),Position+12);
	Bits:=GetLongWord(PByte(FStream.Memory),Position+24);
	Compression:=(GetLongWord(PByte(FStream.Memory),Position+36)<>0);
	GetMem(FImage.FBitMap,FImage.FWidth*FImage.FHeight*FImage.FChannels);
	case Bits of
	24:
		begin
		if Compression then
			begin
			
			end
		else
			begin
			for i:=0 to Width*Height-1 do
				begin
				FImage.FBitMap[i*3+0]:=PByte(FStream.Memory)[Position+40+i*3+2];
				FImage.FBitMap[i*3+1]:=PByte(FStream.Memory)[Position+40+i*3+1];
				FImage.FBitMap[i*3+2]:=PByte(FStream.Memory)[Position+40+i*3+0];
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
	FreeBits;
	end;

	{writeln(Width);
	writeln(Height);
	writeln(BitMapBits);}
end;

class function TSGImage.IsPNG(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
begin
Result:=
	(FileBits[0]=$89) and
	(FileBits[1]=$50) and
	(FileBits[2]=$4E) and
	(FileBits[3]=$47) and
	(FileBits[4]=$0D) and
	(FileBits[5]=$0A) and
	(FileBits[6]=$1A) and
	(FileBits[7]=$0A);
end;

class function TSGImage.IsJPEG(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
begin
Result:=
    ((FileBits[0]=$FF)and
	(FileBits[1]=$D8) and
	(FileBits[2]=$FF) );
end;

class function TSGImage.IsMBM(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
begin
Result:=(FileBits[0]=$37) and (FileBits[1]=$0) and (FileBits[2]=$0) and (FileBits[3]=$10);
end;

procedure TSGImage.FreeTexture;
begin
Render.DeleteTextures(1,@FTexture);
//glDeleteTextures(1,@FTexture);
FTexture:=0;
end;

destructor TSGImage.Destroy;
begin
FreeAll;
FImage.Destroy;
inherited;
end;

procedure TSGImage.FreeSome;
begin
FreeBits;
FreeSream;
end;

procedure TSGImage.FreeAll;
begin
FreeSome;
FreeTexture;
FImage.Clear;
end;

procedure SGImageThreadProcedure(P:Pointer);
begin
while true do
	begin
	if (WhisImageNowLoading <> nil) and (WhisImageNowLoading.ReadyToGoToTexture=False) then
		begin
		WhisImageNowLoading.LoadToMemory;
		WhisImageNowLoading.LoadToBitMap;
		end
	else
		Delay(100);
	end;
end;


procedure TSGImage.DisableTexture;inline;
begin
Render.Disable(SGR_TEXTURE_2D);
//glDisable(GL_TEXTURE_2D);
end;

procedure TSGImage.BindTexture;inline;
begin
Render.Enable(SGR_TEXTURE_2D);
Render.BindTexture(SGR_TEXTURE_2D,FTexture);
{glEnable(GL_TEXTURE_2D);
glBindTexture(GL_TEXTURE_2D,FTexture);}
end;

procedure TSGImage.LoadBMPToBitMap;
begin
LoadBMP(FStream,FImage);
end;

class function TSGImage.GetLongWordBack(const FileBits:PByte;const Position:LongInt):LongWord;
begin
Result:=FileBits[Position+3]+FileBits[Position+2]*256+FileBits[Position+1]*256*256+FileBits[Position]*256*256*256;
end;

class function TSGImage.GetLongWord(const FileBits:PByte;const Position:LongInt):LongWord;
begin
Result:=FileBits[Position]+FileBits[Position+1]*256+FileBits[Position+2]*256*256+FileBits[Position+3]*256*256*256;
end;

function TSGImage.LoadToBitMap:Boolean;
var
	Loaded:Boolean = False;
begin
FStream.Position:=0;
if (FStream.Size<2) then
	exit;
if (not Loaded) and IsBMP(FStream.Memory,FStream.Size) then
	begin
	LoadBMPToBitMap;
	Loaded:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as BMP is "'+SGStr(Loaded)+'"');
		{$ENDIF}
	end;
if (not Loaded) and IsMBM(FStream.Memory,FStream.Size) then
	begin
	LoadMBMToBitMap;
	Loaded:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as MBM is "'+SGStr(Loaded)+'"');
		{$ENDIF}
	end;
if (not Loaded) and IsJPEG(FStream.Memory,FStream.Size) then
	begin
	LoadJPEGToBitMap;
	Loaded:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as JPEG is "'+SGStr(Loaded)+'"');
		{$ENDIF}
	end;
if (not Loaded) and IsPNG(FStream.Memory,FStream.Size) then
	begin
	LoadPNGToBitMap;
	Loaded:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as PNG is "'+SGStr(Loaded)+'"');
		{$ENDIF}
	end;
if (not Loaded) and (SGUpCaseString(SGGetFileExpansion(Way))='TGA') then
	begin
	if FImage<>nil then
		FImage.Destroy;
	FImage:=LoadTGA(FStream);
	if FImage=nil then
		FImage:=TSGBitMap.Create;
	Loaded:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as TGA is "'+SGStr(Loaded)+'"');
		{$ENDIF}
	end;
FReadyToGoToTexture:=Loaded;
Result:=Loaded;
end;

procedure TSGImage.FreeSream;
begin
if FStream<>nil then
	begin
	FStream.Destroy;
	FStream:=nil;
	end;
end;

procedure TSGImage.FreeBits;
begin
if FImage.FBitMap<>nil then
	begin
	FreeMem(FImage.FBitMap,FImage.FWidth*FImage.FHeight*FImage.FChannels);
	FImage.FBitMap:=nil;
	end;
end;

class function TSGImage.IsBMP(const FileBits:Pbyte;const FileBitsLength:LongInt):boolean;
begin
Result:=(FileBits[0]=66) and (FileBits[1]=77);
end;

procedure TSGImage.LoadToMemory;
begin
if FStream=nil then
	FStream:=TMemoryStream.Create
else
	begin
	FStream.Free;
	FStream:=TMemoryStream.Create;
	end;
FStream.LoadFromFile(Way);
end;

procedure TSGImage.ToTexture;
begin
if FTexture<>0 then
	FreeTexture;

Render.Enable(SGR_TEXTURE_2D);
Render.GenTextures(1, @FTexture);
Render.BindTexture(SGR_TEXTURE_2D, FTexture);
Render.PixelStorei(SGR_UNPACK_ALIGNMENT, 4);
Render.PixelStorei(SGR_UNPACK_ROW_LENGTH, 0);
Render.PixelStorei(SGR_UNPACK_SKIP_ROWS, 0);
Render.PixelStorei(SGR_UNPACK_SKIP_PIXELS, 0);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MIN_FILTER, SGR_LINEAR);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_S, SGR_REPEAT);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_T, SGR_REPEAT);
Render.TexEnvi(SGR_TEXTURE_ENV, SGR_TEXTURE_ENV_MODE, SGR_MODULATE);
Render.TexImage2D(SGR_TEXTURE_2D, 0, Channels, Width, Height, 0, FormatType, DataType, FImage.FBitMap);
Render.BindTexture(SGR_TEXTURE_2D, FTexture);
Render.Disable(SGR_TEXTURE_2D);
FReadyToGoToTexture:=False;
{$IFDEF SGDebuging}
	SGLog.Sourse('TSGImage  : Loaded to texture "'+FWay+'" is "'+SGStr(FTexture<>0)+'"("'+SGStr(FTexture)+'").');
	{$ENDIF}
end;

procedure SGIIdleFunction;
begin
if WhisImageNowLoading <> nil then
	if WhisImageNowLoading.ReadyToGoToTexture then
		begin
		WhisImageNowLoading.ToTexture;
		WhisImageNowLoading.FreeSome;
		Pointer(WhisImageNowLoading):=nil;
		end;
if WhisImageNowLoading = nil then
	begin
	if Length(ArWaitImages)>0 then
		begin
		WhisImageNowLoading:=ArWaitImages[High(ArWaitImages)];
		SetLength(ArWaitImages,Length(ArWaitImages)-1);
		end;
	end;
end;


function TSGImage.ReadyTexture:Boolean;
begin
Result:=FTexture<>0;
end;

constructor TSGImage.Create(const NewWay:string = '');
begin
FTexture:=0;
FReadyToGoToTexture:=False;
Way:=NewWay;
FImage:=TSGBitMap.Create;
FStream:=nil;
end;


initialization 
begin

end;

end.
