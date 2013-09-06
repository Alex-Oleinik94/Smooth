{$MODE OBJFPC}
unit SaGeImagesBmp;
interface
uses
	crt
	,SaGeBase
	,SaGeImagesBase
	,Classes
	,SysUtils
	,dos
	;

procedure LoadBMP(Stream: TStream; BitMap: TSGBitMap);
procedure SaveBMP(BitMap: TSGBitMap; Stream: TStream);

implementation


type
  TBitmapFileHeader = packed record
    bfType: array[0..1]of char;
    bfSize: LongWord;
    bfReserved1: Word;
    bfReserved2: Word;
    bfOffBits: LongWord;
  end;

  TBitmapInfoHeader = packed record
    biSize: LongWord;
    biWidth: Longint;
    biHeight: Longint;
    biPlanes: Word;
    biBitCount: Word;
    biCompression: LongWord;
    biSizeImage: LongWord;
    biXPelsPerMeter: Longint;
    biYPelsPerMeter: Longint;
    biClrUsed: LongWord;
    biClrImportant: LongWord;
  end;
  TVector3Byte = packed array [0..2] of Byte;         PVector3Byte = ^TVector3Byte;     
  TVector4Byte = packed array [0..3] of Byte;         PVector4Byte = ^TVector4Byte;    
  
  TArray_Vector3Byte = packed array[0..MaxInt div SizeOf(TVector3Byte)-1]of TVector3Byte;
  PArray_Vector3Byte = ^TArray_Vector3Byte;
  TArray_Vector4Byte = packed array[0..MaxInt div SizeOf(TVector4Byte)-1]of TVector4Byte;
  PArray_Vector4Byte = ^TArray_Vector4Byte;  
  
  TRGBQuad = packed record blue, green, red, reserved : byte end;
  PRGBQuad = ^TRGBQuad;
  TArray_RGBQuad = packed array[0..MaxInt div SizeOf(TRGBQuad)-1]of TRGBQuad;
  PArray_RGBQuad = ^TArray_RGBQuad;
  TArray_Word = packed array [0..MaxInt div SizeOf(Word)-1] of Word;
  PArray_Word = ^TArray_Word;
  TRGB_BMP24 = packed record b, g, r: byte end; { trojka RGB w zapisie danych 24 bitowej bitmapy }
  PRGB_BMP24 = ^TRGB_BMP24;
  TArray_RGB_BMP24 = array[0..MaxInt div SizeOf(TRGB_BMP24)-1] of TRGB_BMP24;
  PArray_RGB_BMP24 = ^TArray_RGB_BMP24;
  

const
  BI_RGB = 0;
  BI_RLE8 = 1;
  BI_RLE4 = 2;
  BI_BITFIELDS = 3;

procedure LoadBMP(Stream: TStream; BitMap: TSGBitMap);
var fhead: TBitmapFileHeader;
    ihead: TBitmapInfoHeader;
    paletteSize: integer;    { rozmiar palety (0 jesli brak) }
    palette: PArray_RGBQuad; { odczytana paleta (nil jesli paletteSize = 0) }
    rowLength: integer;      { dlugosc wiersza (bez 32bit padding !) }
    rownum: integer;

  procedure PutPaletteColor(paletteIndex: integer; var rgb3: TVector3Byte);
  { ustaw rgb3 na kolor numer paletteIndex wziety z palety }
  begin
   rgb3[0] := palette^[paletteIndex].red;
   rgb3[1] := palette^[paletteIndex].green;
   rgb3[2] := palette^[paletteIndex].blue;
  end;

  procedure WriteRow(Row: Pointer; bmprow: PByteArray);
  { przepisz wiersz bitmapy bmprow na wiersz strukturek TVector3Byte. }

    function FiveBitsToByte(fivebits: Word): byte;
    begin
     {liczbe z zkaresu 0..31 (1111 binarnie) (ale podana jako typ Word -
      ponizej bezdiemy chcieli ja mnozyc przez 255 !) mapuje na zakres 0..255}
     result := fivebits*255 div 31;
    end;

  var
    bmpi, rgbi: integer;  { bmpi iteruje po bmprow, rgbi iteruje po rgbrow }
    rgbrow: PArray_Vector3Byte absolute Row;
    rgbarow: PArray_Vector4Byte absolute Row;
  begin
   bmpi := 0;
   rgbi := 0;
   case ihead.biBitCount of
    1: for rgbi := 0 to ihead.biWidth-1 do
       begin
        PutPaletteColor((bmprow^[bmpi] shr (7-(rgbi mod 8)) ) and 1, rgbrow^[rgbi]);
        if (rgbi+1) mod 8 = 0 then Inc(bmpi);
       end;
    4: begin
        for bmpi := 0 to rowLength-2 do
        begin
         PutPaletteColor(bmprow^[bmpi] and $F0 shr 4, rgbrow^[bmpi*2]);
         PutPaletteColor(bmprow^[bmpi] and $F, rgbrow^[bmpi*2+1]);
        end;
        { gdy bmpi = rowLength - 1 musimy uwazac : kolumna bmpi*2 na pewno
          jest w bitmapie, ale kolumna bmp*2+1 moze byc juz poza bitmapa }
        bmpi := rowLength-1;
        PutPaletteColor(bmprow^[bmpi] and $F0 shr 4, rgbrow^[bmpi*2]);
        if bmpi*2+1 < ihead.biWidth then
         PutPaletteColor(bmprow^[bmpi] and $F, rgbrow^[bmpi*2+1]);
       end;
    8: for bmpi := 0 to rowLength-1 do
        PutPaletteColor(bmprow^[bmpi], rgbrow^[bmpi]);
    16:for rgbi := 0 to ihead.biWidth-1 do
       begin
        rgbrow^[rgbi, 0] := FiveBitsToByte((PArray_Word(bmprow)^[rgbi] and $7C00) shr 10);
        rgbrow^[rgbi, 1] := FiveBitsToByte((PArray_Word(bmprow)^[rgbi] and $03E0) shr 5);
        rgbrow^[rgbi, 2] := FiveBitsToByte(PArray_Word(bmprow)^[rgbi] and $001F);
       end;
    24:{ bmprow in 24 bit bitmap have almost the same format as rgbrow  -
         we only have to swap bgr to rgb }
       for rgbi := 0 to ihead.biWidth-1 do
       begin
        rgbrow^[rgbi, 0] := PArray_RGB_BMP24(bmprow)^[rgbi].r;
        rgbrow^[rgbi, 1] := PArray_RGB_BMP24(bmprow)^[rgbi].g;
        rgbrow^[rgbi, 2] := PArray_RGB_BMP24(bmprow)^[rgbi].b;
       end;
    32:for rgbi := 0 to ihead.biWidth-1 do
       begin
         { We know that for 32, we have TRGBAlphaImage, so we use rgbarow }
         (*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Assert(Result is TRGBAlphaImage);*)

         rgbarow^[rgbi, 0] := PArray_RGBQuad(bmprow)^[rgbi].red;
         rgbarow^[rgbi, 1] := PArray_RGBQuad(bmprow)^[rgbi].green;
         rgbarow^[rgbi, 2] := PArray_RGBQuad(bmprow)^[rgbi].blue;
         { At least GIMP treats the 4th component as alpha value. }
         rgbarow^[rgbi, 3] := PArray_RGBQuad(bmprow)^[rgbi].reserved;
       end;
   end;
  end;

  { ClassAllowed is only shortcut to global utility. }{
  function ClassAllowed(ImageClass: TImageClass): boolean;
  begin
    Result := Images.ClassAllowed(ImageClass, AllowedImageClasses);
  end;}

var i: integer;
    rowsGoingUp: boolean;
    rowdata: PByteArray;
    (*NewResult: TImage;*)
begin

 try
  { read and check headers }
  Stream.ReadBuffer(fhead, SizeOf(fhead));
  Stream.ReadBuffer(ihead, SizeOf(ihead));
  (*with fhead do
   Check( (bfType[0]='B') and (bfType[1]='M'), 'not a bitmap file (first two bytes <> BM)');*)
  with ihead do
  begin
   { check removed - ImageMagick can write such wrong bitmaps (but they are
     really wrong !
     - TotalCommander's internal view
     - and Windows2k code to show bmps on desktop
     - and GIMP
     all fail trying to open them.) }
   (*if biSize <> SizeOf(TBitmapInfoHeader) then
      DataWarning(Format(
        'Wrong size of a bitmap header --- should be %d, is %d',
        [SizeOf(TBitmapInfoHeader), biSize]));*)

   { height can be negative - it means rows are written from up to down }
   rowsGoingUp := biHeight > 0;
   biHeight := Abs(biHeight);

   PaletteSize := 0;
   case biBitCount of
    1: begin PaletteSize := 2; rowLength := Trunc(biWidth/ 8)+1 end;
    4: begin PaletteSize := 16; rowLength := Trunc(biWidth/ 2)+1 end;
    8: begin PaletteSize := 256; rowLength := biWidth end;
    16: begin rowLength := biWidth * 2 end;
    24: begin rowLength := biWidth * 3 end;
    32: begin rowLength := biWidth * 4 end;
    (*!!!!!!!!!!!!else raise EInvalidBMP.Create('Wrong bitmap : biBitCount doesn''t match any allowed value');*)
   end;

   if (paletteSize <> 0 {paletted format}) and (biClrUsed <> 0) then
    paletteSize := biClrUsed;

   (*!!!!!!!!!!!!!!!!!!!!!if biCompression <> BI_RGB then
    raise EInvalidBMP.Create('TODO: RLE compressed and bitfields bitmaps not implemented yet');*)

   palette := nil;
   rowdata := nil;
   BitMap.BitMap := nil;
   
   try
    try
     { optionally read palette }
     if paletteSize <> 0 then
     begin
      palette := GetMem(paletteSize * SizeOf(TRGBQuad));
      Stream.ReadBuffer(palette[0], paletteSize * SizeOf(TRGBQuad));
     end;

     { read data }
     { we have to use here Stream.Position, we can't be sure we're standing
       in the right place - because sometimes when the palette is not fully
       used image can be written earlier in the file - it's simple, for example
       we are writing 8 bit bitmap with only 200 colors. We're writing 200 colors
       and than we're immediately start writing pixel-data (even though
       documentation states we have to provide 256 colors).
       And we're setting bfOffBits 56*4 bytes earlier than SizeOf(fileheader) +
       SizeOf(infoheader) + SizeOf(palette with 256 entries). This way we
       don't waste place. This is what bitmap writers like Corel do. And it's ok.

       Besides we (the bitmap Reader) want to use that feature bacause we're
       using biClrUsed so we don't waste time for readind usused colors.
       Ans no one said that bitmap writer HAS to use that trick with setting
       bfOffBits earlier - it can just fill unused palette space with shit,
       and write always 256 color palette event when he doesn't use so many colors.
       So we have to use bfOffBits. }

     Stream.Position := fhead.bfOffBits;
     rowdata := GetMem(rowLength);

     { We always allocate Result most matching to file format
       (biBitCount = 32 is RGBA, else RGB).

       We also check AllowedImageClasses and ForbiddenConvs, to see if they can
       be satisfied. There's no point in loading if we would later
       be unable to convert to requested class.

       However, actual conversion to satisfy AllowedImageClasses, ForbiddenConvs
       (adding/stripping alpha channel) will be done (if needed) later,
       after reading BMP file. }
       BitMap.Width:=biWidth;
       BitMap.Height:=biHeight;
       if biBitCount=32 then
         BitMap.Channels:=4
       else
         BitMap.FSizeChannel:=3;
       BitMap.BitDepth:=biBitCount div BitMap.Channels;
       GetMem(BitMap.FBitMap,biWidth*biHeight*BitMap.Channels);
       BitMap.CreateTypes;
       
     for i := 0 to biHeight - 1 do
     begin
      Stream.ReadBuffer(rowdata[0], rowLength);
      { skip row 32bit padding }
      with Stream do Position := Position + Round(rowLength/ 4)*4 - rowLength;
      if rowsGoingUp then rownum := i else rownum := biHeight-i-1;
      WriteRow(@BitMap.FBitMap[rownum*(BitMap.FWidth)*BitMap.FChannels], rowData);
     end;
     
    finally
     FreeMem(pointer(rowdata));
     FreeMem(pointer(palette));
    end;
   except BitMap.Clear; raise end;
  end;

 except
{  // EReadError is thrown by Stream.ReadBuffer when it can't read
   // specified number of bytes 
  on E: EReadError do raise EInvalidBMP.Create('Read error: ' + E.Message);
  on E: ECheckFailed do raise EInvalidBMP.Create('Wrong bitmap: ' + E.Message);}
  BitMap.Clear;
 end;
end;

procedure SaveBMP(BitMap: TSGBitMap; Stream: TStream);
var fhead: TBitmapFileHeader;
    ihead: TBitmapInfoHeader;
    i, j, rowPaddedLength, PadSize: cardinal;
    p :PVector3Byte;
    row, rowdata :PRGB_BMP24;
begin
 rowPaddedLength := BitMap.Width*SizeOf(TRGB_BMP24);
 if rowPaddedLength mod 4 <> 0 then
  padsize := 4-rowPaddedLength mod 4 else
  padsize := 0;
 rowPaddedLength := rowPaddedLength + padsize;

 fhead.bfType[0] := 'B';
 fhead.bfType[1] := 'M';
 fhead.bfSize := SizeOf(TBitmapFileHeader) + SizeOf(TBitmapInfoHeader) + rowPaddedLength*BitMap.Height;
 fhead.bfReserved1 := 0;
 fhead.bfReserved2 := 0;
 fhead.bfOffBits := SizeOf(TBitmapFileHeader) + SizeOf(TBitmapInfoHeader);

 ihead.biSize := SizeOf(TBitmapInfoHeader);
 ihead.biWidth := BitMap.Width;
 ihead.biHeight := BitMap.Height;
 ihead.biPlanes := 1;
 ihead.biBitCount := BitMap.Channels*BitMap.BitDepth;
 ihead.biCompression := BI_RGB;
 ihead.biSizeImage := 0;
 ihead.biXPelsPerMeter := 3779;
 ihead.biYPelsPerMeter := 3779;
 ihead.biClrUsed := 0;
 ihead.biClrImportant := 0;

 Stream.WriteBuffer(fhead, SizeOf(fhead));
 Stream.WriteBuffer(ihead, SizeOf(ihead));

 rowdata := GetMem(rowPaddedLength);
 try
  for j := 0 to BitMap.Height-1 do
  begin
   p := PVector3Byte(@BitMap.FBitMap[j*(BitMap.FWidth)*BitMap.FChannels]);
   row := rowdata;
   for i := 0 to BitMap.Width - 1 do
   begin
    row^.r := p^[0];
    row^.g := p^[1];
    row^.b := p^[2];
    Inc(p);
    Inc(row);
   end;
   FillChar(row^, padsize, 0);
   Stream.WriteBuffer(rowdata^, rowPaddedLength);
  end;
 finally FreeMem(rowdata) end;
end;


end.
