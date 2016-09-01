{$INCLUDE SaGe.inc}

unit SaGeImagesPng;

interface

function SupporedPNG() : Boolean;

implementation

uses
	crt
	,png
	,Classes
	,SaGeImagesBase
	,SaGeBase
	,SaGeBased
	,SaGeRenderConstants
	,SaGeResourseManager
	,SaGeDllManager
	;

function SupporedPNG() : Boolean;
begin
Result := DllManager.Suppored('png');
end;

procedure LoadPNG(const Stream: TStream;const BitMap:TSGBitMap);forward;
procedure SavePNG(const BitMap: TSGBitMap;const Stream: TStream;const  Interlaced: boolean = false);forward;

type
	TSGResourseManipulatorImagesPNG=class(TSGResourseManipulator)
			public
		constructor Create();override;
		function LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;override;
		function SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;override;
		end;

constructor TSGResourseManipulatorImagesPNG.Create();
begin
inherited;
AddExpansion('PNG',True,True);
end;

function TSGResourseManipulatorImagesPNG.LoadResourseFromStream(const VStream : TStream;const VExpansion : TSGString):TSGResourse;
begin
Result := TSGBitMap.Create();
LoadPNG(VStream,Result as TSGBitMap);
end;

function TSGResourseManipulatorImagesPNG.SaveResourseToStream(const VStream : TStream;const VExpansion : TSGString;const VResourse : TSGResourse):TSGBoolean;
begin
if (VExpansion<>'PNG') or (not(VResourse is TSGBitMap)) then
	Result:=False
else
	begin
	SavePNG(VResourse as TSGBitMap,VStream);
	Result:=True;
	end;
end;

type
	TDynStringArray = packed array of string;
const
	PNG_COLOR_MASK_PALETTE = 1;
	PNG_COLOR_MASK_COLOR = 2;
	PNG_COLOR_MASK_ALPHA = 4;

	PNG_COLOR_TYPE_GRAY = 0;
	PNG_COLOR_TYPE_PALETTE = (PNG_COLOR_MASK_COLOR or PNG_COLOR_MASK_PALETTE);
	PNG_COLOR_TYPE_RGB = (PNG_COLOR_MASK_COLOR);
	PNG_COLOR_TYPE_RGB_ALPHA = (PNG_COLOR_MASK_COLOR or PNG_COLOR_MASK_ALPHA);
	PNG_COLOR_TYPE_GRAY_ALPHA = (PNG_COLOR_MASK_ALPHA);

	PNG_COLOR_TYPE_RGBA = PNG_COLOR_TYPE_RGB_ALPHA;
	PNG_COLOR_TYPE_GA = PNG_COLOR_TYPE_GRAY_ALPHA;

	PNG_COMPRESSION_TYPE_BASE = 0;
	PNG_COMPRESSION_TYPE_DEFAULT = PNG_COMPRESSION_TYPE_BASE;

	PNG_FILTER_TYPE_BASE = 0;
	PNG_INTRAPIXEL_DIFFERENCING = 64;
	PNG_FILTER_TYPE_DEFAULT = PNG_FILTER_TYPE_BASE;

	PNG_INTERLACE_NONE = 0;
	PNG_INTERLACE_ADAM7 = 1;
	PNG_INTERLACE_LAST = 2;

{$DEFINE LIBPNG_CDECL}

procedure our_png_error_fn(png_ptr : png_structp; s : png_const_charp); {$ifndef LIBPNG_CDECL} stdcall {$else} cdecl {$endif};
var
	warnings: TDynStringArray;
begin
Warnings := TDynStringArray(png_get_error_ptr(png_ptr));
SetLength(warnings,Length(warnings)+1);
Warnings[High(warnings)]:='     Png error - libpng returned error :';
SetLength(warnings,Length(warnings)+1);
Warnings[High(warnings)]:=s;
end;

procedure our_png_warning_fn(png_ptr : png_structp; s : png_const_charp); {$ifndef LIBPNG_CDECL} stdcall {$else} cdecl {$endif};
var
	warnings: TDynStringArray = nil;
begin
warnings := TDynStringArray(png_get_error_ptr(png_ptr));
if (Warnings= nil) or (Length(Warnings)=0) then
	begin
	SetLength(warnings,Length(warnings)+1);
	Warnings[High(warnings)]:='     There were libpng warnings :';
	end;
SetLength(warnings,Length(warnings)+1);
Warnings[High(warnings)]:=s;
end;

{$checkpointer off}

procedure our_png_read_fn(png_ptr: png_structp; data: png_bytep; len: png_size_t);
  {$ifndef LIBPNG_CDECL} stdcall {$else} cdecl {$endif};
begin
 TStream(png_get_io_ptr(png_ptr)).ReadBuffer(data^, len);
end;

procedure our_png_write_fn(png_ptr: png_structp; data: png_bytep; len: png_size_t);
  {$ifndef LIBPNG_CDECL} stdcall {$else} cdecl {$endif};
begin
 TStream(png_get_io_ptr(png_ptr)).WriteBuffer(data^, len);
end;

procedure our_png_flush_fn(png_ptr: png_structp);
  {$ifndef LIBPNG_CDECL} stdcall {$else} cdecl {$endif};
begin
 {we would like to do here something like TStream(png_get_io_ptr(png_ptr)).Flush;
  but there is no "flush" method in TStream or any of its descendant; }
end;

procedure LoadPNG(const Stream: TStream;const BitMap:TSGBitMap);

var
  png_ptr: png_structp;
  info_ptr: png_infop;
var
	row_pointers: packed array of pointer = nil;
	i: Cardinal;
	warningslist: TDynStringArray;
begin
SetLength(warningslist,0);
png_ptr := nil;
try
	png_ptr := png_create_read_struct(PNG_LIBPNG_VER_STRING, Pointer(WarningsList),@our_png_error_fn,@our_png_warning_fn);

	info_ptr := png_create_info_struct(png_ptr);

	png_set_read_fn(png_ptr, Stream,@our_png_read_fn);

	png_read_info(png_ptr, info_ptr);

	BitMap.FWidth := png_get_image_width(png_ptr, info_ptr);
	BitMap.FHeight := png_get_image_height(png_ptr, info_ptr);
	BitMap.FChannels:=png_get_channels(png_ptr, info_ptr);
	BitMap.FSizeChannel:=png_get_bit_depth(png_ptr, info_ptr);
	BitMap.CreateTypes();

	png_read_update_info(png_ptr, info_ptr);

	SetLEngth(row_pointers,BitMap.FHeight);
	GetMem(BitMap.FBitMap,BitMap.FWidth*BitMap.FHeight*BitMap.FChannels);

	for i := 0 to BitMap.FHeight-1 do
		row_pointers[i] := @BitMap.FBitMap[(BitMap.FHeight-1 -i )*(BitMap.FWidth)*BitMap.FChannels];

	png_read_image(png_ptr, @row_pointers[0]);

	SetLength(row_pointers,0);

	png_read_end(png_ptr, nil);
	if (png_ptr <> nil) then
		begin
		if info_ptr = nil then
			png_destroy_read_struct(@png_ptr, nil, nil)
		else
			png_destroy_read_struct(@png_ptr, @info_ptr, nil);
		end;
except
	SGLog.Sourse('SaGeImagesPNG : Exeption while loading png!');
	BitMap.Clear();
	end;

if (WarningsList<>nil) or (Length(WarningsList)<>0) then
	begin
	for i:= 0 to High(WarningsList) do
		SGLog.Sourse('LoadPNG(TStream,TBitMap) WarningsList : '+WarningsList[i]);
	SetLength(WarningsList,0);
	end;
end;

procedure SavePNG(const BitMap: TSGBitMap; const Stream: TStream;const  Interlaced: boolean = false);
var png_ptr: png_structp;
    info_ptr: png_infop;
    warningslist: TDynStringArray = nil;
    InterlaceType: LongWord;
    row_pointers: packed array of pointer = nil;
    i: Cardinal;
    ColorType: LongInt;
begin
png_ptr := nil;
if interlaced then
interlaceType := PNG_INTERLACE_ADAM7 else
interlaceType := PNG_INTERLACE_NONE;
try
	png_ptr := png_create_write_struct(PNG_LIBPNG_VER_STRING,Pointer(WarningsList),@our_png_error_fn,@our_png_warning_fn);
	info_ptr := png_create_info_struct(png_ptr);
	png_set_write_fn(png_ptr, Stream,@our_png_write_fn,@our_png_flush_fn);
	BitMap.CreateTypes;
	if BitMap.PixelFormat=SGR_RGB then
		ColorType:=PNG_COLOR_MASK_COLOR
	else
		if BitMap.PixelFormat=SGR_RGBA then
			ColorType:=PNG_COLOR_TYPE_RGBA
		else
			if BitMap.PixelFormat=SGR_LUMINANCE then
				ColorType:=PNG_COLOR_TYPE_GRAY
			else
				if BitMap.PixelFormat=SGR_LUMINANCE_ALPHA then
					ColorType:=PNG_COLOR_TYPE_GRAY_ALPHA
				else
					ColorType:=0;
	if ColorType=0 then
		Exit;

	png_set_IHDR(png_ptr, info_ptr, BitMap.Width, BitMap.Height, 8, ColorType,
		interlaceType, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
	png_write_info(png_ptr, info_ptr);
	SetLength(row_pointers,BitMap.Height);
	try
		for i := 0 to BitMap.FHeight-1 do
			row_pointers[i] := @BitMap.FBitMap[(BitMap.FHeight-1 -i )*(BitMap.FWidth)*BitMap.FChannels];
		png_write_image(png_ptr, @row_pointers[0]);
	finally
		SetLength(row_pointers,0);
		end;

	png_write_end(png_ptr, nil);
finally
	if png_ptr <> nil then
		begin
		if info_ptr <> nil then
		png_destroy_write_struct(@png_ptr, @info_ptr) else
		png_destroy_write_struct(@png_ptr, nil);
		end;
	if WarningsList<>nil then
		for i:= 0 to High(WarningsList) do
			SGLog.Sourse('LoadPNG(TStream,TBitMap) WarningsList : '+WarningsList[i]);
	SetLength(warningslist,0);
	end;
end;

initialization
begin
SGResourseManager.AddManipulator(TSGResourseManipulatorImagesPNG);
end;

end.
