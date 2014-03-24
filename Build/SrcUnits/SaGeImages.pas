{$INCLUDE Includes\SaGe.inc}
unit SaGeImages;
interface
uses 
	crt
	,dos
	{$IFDEF MSWINDOWS}
		,windows
		,MMSystem
		{$ENDIF}
	,SysUtils
	,Classes
	,SaGeBase
	,SaGeBased
	,SaGeImagesBase
	,SaGeRender
	,SaGeContext
	,SaGeCommon
	,SaGeResourseManager
		// formats
	,SaGeImagesJpeg
	,SaGeImagesBmp
	{$IFNDEF MOBILE},SaGeImagesPng{$ENDIF}
	,SaGeImagesTga
	,SaGeImagesSgia
	;
type
	TSGIByte = type TSGExByte;
	
	PSGImage  = ^ TSGImage;
	PTSGImage = PSGImage;
	// ����� ����������� � ��������
	TSGImage = class(TSGContextObject)
			public
		constructor Create(const NewWay:string = '');
		destructor Destroy;override;
			public
		// � ��� ���� ����������� ( � ����������� ������, � ���� ������������������ ������, � ������� ����������� )
		// � ����� ��� BitMap (������� �����)
		FImage   : TSGBitMap;
		
		// �����, � ������ ������������ �����������, ��� ��� ��������. 
		// ������� MemoryStream ����� ����� ������ ���������.
		FStream  : TMemoryStream;
		
		// ������������� ��������
		FTexture : SGUInt;
		
		// ����������, ��������� ����������� � ����������� ������ � ���� TSGBitMap, ��� ���
		FReadyToGoToTexture : TSGBoolean;
		//���� � �����
		FWay                : TSGString;
		//������, � ������� ���������� ������������ ���� ��� ����������
		FSaveFormat:TSGIByte;
		
		//��� �����������/��������� � �� 
		FName : TSGString;
			protected
		procedure LoadMBMToBitMap(const Position:LongWord = 20);
		procedure LoadToMemory();virtual;
		function LoadToBitMap():TSGBoolean;virtual;
		function GetBitMapBits():TSGCardinal;
		procedure SetBitMapBits(const Value:TSGCardinal);
		class function IsBMP(const FileBits:Pbyte;const FileBitsLength:TSGLongInt):boolean;
		class function IsMBM(const FileBits:Pbyte;const FileBitsLength:TSGLongInt):boolean;
		class function IsPNG(const FileBits:Pbyte;const FileBitsLength:TSGLongInt):boolean;
		class function IsJPEG(const FileBits:Pbyte;const FileBitsLength:TSGLongInt):boolean;
		class function IsSGIA(const FileBits:Pbyte;const FileBitsLength:TSGLongInt):boolean;
		class function GetLongWord(const FileBits:PByte;const Position:TSGLongInt):LongWord;
		class function GetLongWordBack(const FileBits:PByte;const Position:TSGLongInt):LongWord;
			public
		procedure Saveing(const Format:TSGExByte = SGI_DEFAULT);
		function Loading():TSGBoolean;virtual;
		procedure SaveToStream(const Stream:TStream);
		procedure ToTexture();virtual;
		procedure BindTexture();
		procedure DisableTexture();
		function ReadyTexture():TSGBoolean;
		procedure FreeSream();
		procedure FreeBits();
		procedure FreeSome();
		procedure FreeTexture();
		procedure FreeAll();
		function Ready():TSGBoolean;virtual;
			public 
		property FormatType         : TSGCardinal read FImage.FFormatType  write FImage.FFormatType;
		property DataType           : TSGCardinal read FImage.FDataType    write FImage.FDataType;
		property Channels           : TSGCardinal read FImage.FChannels    write FImage.FChannels;
		property BitDepth           : TSGCardinal read FImage.FSizeChannel write FImage.FSizeChannel;
		property Texture            : SGUint      read FTexture            write FTexture;
		property Height             : TSGCardinal read FImage.FHeight      write FImage.FHeight;
		property Width              : TSGCardinal read FImage.FWidth       write FImage.FWidth;
		property Bits               : TSGCardinal read GetBitMapBits       write SetBitMapBits;
		property BitMap             : PByte       read FImage.FBitMap      write FImage.FBitMap;
		property Image              : TSGBitMap   read FImage;
		property Way                : TSGString   read FWay                write FWay;
		property ReadyToGoToTexture : TSGBoolean  read FReadyToGoToTexture write FReadyToGoToTexture;
		property ReadyGoToTexture   : TSGBoolean  read FReadyToGoToTexture write FReadyToGoToTexture;
		property ReadyToTexture     : TSGBoolean  read FReadyToGoToTexture write FReadyToGoToTexture;
		property Name               : TSGString   read FName               write FName;
			public //Render Functions:
		procedure DrawImageFromTwoVertex2f(Vertex1,Vertex2:SGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGExByte = SG_3D;const Rotation:Byte = 0);
		procedure DrawImageFromTwoPoint2f(Vertex1,Vertex2:SGPoint2f;const RePlace:Boolean = True;const RePlaceY:TSGExByte = SG_3D;const Rotation:Byte = 0);
		procedure ImportFromDispley(const Point1,Point2:SGPoint;const NeedAlpha:Boolean = True);
		procedure ImportFromDispley(const NeedAlpha:Boolean = True);
		class function UnProjectShift:TSGPoint2f;
		procedure DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);inline;
		procedure RePlacVertex(var Vertex1,Vertex2:SGVertex2f;const RePlaceY:TSGExByte = SG_3D);inline;
		end;
	SGImage     = TSGImage;
	ArTSGImage  = type packed array of TSGImage;
	TArTSGImage = ArTSGImage;

implementation

(****************************)
(*RENDER FUNCTIONS FOR IMAGE*)
(****************************)


procedure TSGImage.DrawImageFromTwoPoint2f(Vertex1,Vertex2:SGPoint2f;const RePlace:Boolean = True;const RePlaceY:TSGExByte = SG_3D;const Rotation:Byte = 0);
begin
DrawImageFromTwoVertex2f(SGPoint2fToVertex2f(Vertex1),SGPoint2fToVertex2f(Vertex2),RePlace,RePlaceY,Rotation);
end;

procedure TSGImage.DrawImageFromTwoVertex2f(Vertex1,Vertex2:SGVertex2f;const RePlace:Boolean = True;const RePlaceY:TSGExByte = SG_3D;const Rotation:Byte = 0);
procedure DoTexCoord(const NowRotation:Byte);inline;
begin
case (NowRotation mod 4) of
0:Render.TexCoord2f(0,1);
1:Render.TexCoord2f(1,1);
2:Render.TexCoord2f(1,0);
3:Render.TexCoord2f(0,0);
end;
end;
begin
if RePlace then
	begin
	RePlacVertex(Vertex1,Vertex2,rePlaceY);
	end;
BindTexture();
Render.BeginScene(SGR_QUADS);
DoTexCoord(Rotation);
Vertex1.Vertex(Render);
DoTexCoord(Rotation+1);
Render.Vertex2f(Vertex2.x,Vertex1.y);
DoTexCoord(Rotation+2);
Vertex2.Vertex(Render);
DoTexCoord(Rotation+3);
Render.Vertex2f(Vertex1.x,Vertex2.y);
Render.EndScene();
DisableTexture();
end;

procedure TSGImage.DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);inline;
begin
if RePlace then
	RePlacVertex(Vertex1,Vertex2,SG_2D);
DrawImageFromTwoVertex2f(
	SGVertex2fImport(
		Vertex1.x+abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex1.y+abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	SGVertex2fImport(
		Vertex2.x-abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex2.y-abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	RePlace,SG_2D);
end;

procedure TSGImage.RePlacVertex(var Vertex1,Vertex2:SGVertex2f;const RePlaceY:TSGExByte = SG_3D);inline;
begin
if Vertex1.x>Vertex2.x then
	SGQuickRePlaceVertexType(Vertex1.x,Vertex2.x);
case RePlaceY of
SG_2D:
	begin
	if Vertex1.y>Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
else
	begin
	if Vertex1.y<Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
end;
end;

class function TSGImage.UnProjectShift:TSGPoint2f;
begin
//Result:=TSGViewportObject.Smezhenie;
	//onu:{$}
	Result.Import();
end;

procedure TSGImage.ImportFromDispley(const NeedAlpha:Boolean = True);
begin
ImportFromDispley(
	SGPointImport(1,1),
	SGPointImport(Render.Width,Render.Height),
	NeedAlpha);
end;

procedure TSGImage.ImportFromDispley(const Point1,Point2:SGPoint;const NeedAlpha:Boolean = True);
begin
if Self<>nil then
	FreeAll
else
	Self:=TSGImage.Create;
if NeedAlpha then
	begin
	GetMem(FImage.FBitMap,(Point2.x-Point1.x+1)*(Point2.y-Point1.y+1)*4);
	Render.ReadPixels(
		Point1.x-1,//+ReadPixelsShift.x,
		Point1.y-1,//+ReadPixelsShift.y,
		Point2.x-Point1.x+1, 
		Point2.y-Point1.y+1, 
		SGR_RGBA, 
		SGR_UNSIGNED_BYTE, 
		FImage.FBitMap);
	Bits:=32;
	end
else
	begin
	GetMem(FImage.FBitMap,(Point2.x-Point1.x+1)*(Point2.y-Point1.y+1)*3);
	Render.ReadPixels(
		Point1.x-1,//+ReadPixelsShift.x,
		Point1.y-1,//+ReadPixelsShift.y,
		Point2.x-Point1.x+1, 
		Point2.y-Point1.y+1, 
		SGR_RGB, 
		SGR_UNSIGNED_BYTE, 
		FImage.FBitMap);
	Bits:=24;
	end;
Height:=Point2.y-Point1.y+1;
Width:=Point2.x-Point1.x+1;
FReadyToGoToTexture:=True;
end;

(****************************)
(*OTHERS FUNCTIONS FOR IMAGE*)
(****************************)

procedure TSGImage.SaveToStream(const Stream:TStream);
var
	Stream2:TMemoryStream = nil;
begin
if (FImage<>nil) and (FImage.FBitMap<>nil) then
	begin
	if SGResourseManager.SaveingIsSuppored('PNG') then
		SGResourseManager.SaveResourseToStream(Stream,'PNG',FImage)
	else
		if SGResourseManager.SaveingIsSuppored('BMP') then
			SGResourseManager.SaveResourseToStream(Stream,'BMP',FImage);
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

procedure TSGImage.Saveing(const Format:TSGExByte = SGI_DEFAULT);
var
	SaveFormat : TSGExByte;
	Stream:TMemoryStream = nil;
procedure SaveJpg();
var
	BmpStream:TMemoryStream = nil;
begin
BmpStream:=TMemoryStream.Create;
SaveBMP(FImage,BmpStream);
BmpStream.Position:=0;
SaveJPEG(BmpStream,Stream);
BmpStream.Destroy();
end;
begin
if (FImage=nil) or (FImage.BitMap=nil) then
	Exit;
if Format=SGI_DEFAULT then
	if Channels=3 then
		SaveFormat:={$IFDEF MOBILE}SGI_JPEG{$ELSE}SGI_PNG{$ENDIF}
	else if Channels=4 then
		SaveFormat:={$IFDEF MOBILE}SGI_SGIA{$ELSE}SGI_PNG{$ENDIF}
	else 
		SaveFormat:=SGI_JPEG
else
	SaveFormat:=Format;
Stream:=TMemoryStream.Create();
case SaveFormat of
SGI_SGIA:
	begin
	SaveSGIA(Stream,FImage);
	end;
SGI_PNG:
	begin
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Saveing "'+FWay+'" as PNG');
		{$ENDIF}
	if SGResourseManager.SaveingIsSuppored('PNG') then
		SGResourseManager.SaveResourseToStream(Stream,'PNG',FImage)
	else
		if SGResourseManager.SaveingIsSuppored('BMP') then
			SGResourseManager.SaveResourseToStream(Stream,'BMP',FImage);
	end;
SGI_JPEG:
	begin
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Saveing "'+FWay+'" as JPEG');
		{$ENDIF}
	SaveJpg();
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
	Stream.Position:=0;
	Stream.SaveToFile(SGSetExpansionToFileName(Way,SGGetExpansionFromImageFormat(SaveFormat)));
	Stream.Destroy();
	end;
end;

function TSGImage.Loading():TSGBoolean;
begin
Result:=False;
LoadToMemory();
if (FStream<>nil) and (FStream.Size<>0) then
	LoadToBitMap()
else
	Exit;
Result:=ReadyToGoToTexture;
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

class function TSGImage.IsSGIA(const FileBits:Pbyte;const FileBitsLength:TSGLongInt):boolean;
begin
Result:=(
	(FileBits[0]=$53) and
	(FileBits[1]=$47) and
	(FileBits[2]=$49) and
	(FileBits[3]=$41));
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
if (FTexture<>0) and (FCOntext<>nil) and (Context<>nil) and (Render<>nil) then
	Render.DeleteTextures(1,@FTexture);
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

procedure TSGImage.DisableTexture;inline;
begin
Render.Disable(SGR_TEXTURE_2D);
end;

procedure TSGImage.BindTexture;inline;
begin
if (FTexture=0) and (FReadyToGoToTexture) then
	begin
	ToTexture();
	FreeBits();
	end;
Render.Enable(SGR_TEXTURE_2D);
Render.BindTexture(SGR_TEXTURE_2D,FTexture);
end;

class function TSGImage.GetLongWordBack(const FileBits:PByte;const Position:LongInt):LongWord;
begin
Result:=FileBits[Position+3]+FileBits[Position+2]*256+FileBits[Position+1]*256*256+FileBits[Position]*256*256*256;
end;

class function TSGImage.GetLongWord(const FileBits:PByte;const Position:LongInt):LongWord;
begin
Result:=FileBits[Position]+FileBits[Position+1]*256+FileBits[Position+2]*256*256+FileBits[Position+3]*256*256*256;
end;

function TSGImage.LoadToBitMap:TSGBoolean;
begin
Result:=False;
FStream.Position:=0;
if (FStream.Size<2) then
	exit;
if (not Result) and IsBMP(FStream.Memory,FStream.Size) then
	begin
	LoadBMP(FStream,FImage);
	Result:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as BMP is "'+SGStr(Result)+'"');
		{$ENDIF}
	end;
if (not Result) and IsSGIA(FStream.Memory,FStream.Size) then
	begin
	LoadSGIAToBitMap(FStream,FImage);
	Result:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as SGIA is "'+SGStr(Result)+'"');
		{$ENDIF}
	end;
if (not Result) and IsMBM(FStream.Memory,FStream.Size) then
	begin
	LoadMBMToBitMap;
	Result:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as MBM is "'+SGStr(Result)+'"');
		{$ENDIF}
	end;
if (not Result) and IsJPEG(FStream.Memory,FStream.Size) then
	begin
	LoadJPEGToBitMap(FStream,FImage);
	Result:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as JPEG is "'+SGStr(Result)+'"');
		{$ENDIF}
	end;
if (not Result) and IsPNG(FStream.Memory,FStream.Size) then
	begin
	if SGResourseManager.LoadingIsSuppored('PNG') then
		FImage:=SGResourseManager.LoadResourseFromStream(FStream,'PNG') as TSGBitMap;
	Result:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as PNG is "'+SGStr(Result)+'"');
		{$ENDIF}
	end;
if (not Result) and (SGUpCaseString(SGGetFileExpansion(Way))='TGA') then
	begin
	if FImage<>nil then
		FImage.Destroy;
	FImage:=LoadTGA(FStream);
	if FImage=nil then
		FImage:=TSGBitMap.Create;
	Result:=FImage.FBitMap<>nil;
	{$IFDEF SGDebuging}
		SGLog.Sourse('TSGImage  : Loaded "'+FWay+'" as TGA is "'+SGStr(Result)+'"');
		{$ENDIF}
	end;
FReadyToGoToTexture:=Result;
end;

procedure TSGImage.FreeSream();
begin
if FStream<>nil then
	begin
	FStream.Destroy();
	FStream:=nil;
	end;
end;

procedure TSGImage.FreeBits();
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

procedure TSGImage.LoadToMemory();
begin
if FStream=nil then
	FStream:=TMemoryStream.Create()
else
	begin
	FStream.Free();
	FStream:=TMemoryStream.Create();
	end;
FStream.LoadFromFile(Way);
end;

procedure TSGImage.ToTexture();
begin
if FTexture<>0 then
	FreeTexture();

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
FName:='';
end;


initialization 
begin

end;

end.
