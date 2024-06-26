{$INCLUDE Smooth.inc}

unit SmoothImagePng;

interface

uses
	 SmoothBase
	;

function SupportedPNG() : TSBoolean;

implementation

uses
	 Crt
	,Classes
	
	,png
	
	,SmoothBitMap
	,SmoothLog
	,SmoothResourceManager
	,SmoothDllManager
	;

function SupportedPNG() : TSBoolean;
begin
Result := DllManager.Supported('zlib');
if Result then
	Result := DllManager.Supported('png');
end;

procedure LoadPNG(const Stream: TStream;const BitMap:TSBitMap);forward;
procedure SavePNG(const BitMap: TSBitMap;const Stream: TStream;const  Interlaced: boolean = false);forward;

type
	TSResourceManipulatorImagesPNG = class(TSResourceManipulator)
			public
		constructor Create();override;
		function LoadResourceFromStream(const VStream : TStream;const VExtension : TSString):TSResource;override;
		function SaveResourceToStream(const VStream : TStream;const VExtension : TSString;const VResource : TSResource):TSBoolean;override;
		end;

constructor TSResourceManipulatorImagesPNG.Create();
begin
inherited;
AddFileExtension('PNG', SupportedPNG(), SupportedPNG());
end;

function TSResourceManipulatorImagesPNG.LoadResourceFromStream(const VStream : TStream;const VExtension : TSString):TSResource;
begin
Result := TSBitMap.Create();
LoadPNG(VStream, Result as TSBitMap);
end;

function TSResourceManipulatorImagesPNG.SaveResourceToStream(const VStream : TStream;const VExtension : TSString;const VResource : TSResource):TSBoolean;
begin
if (VExtension <> 'PNG') or (not(VResource is TSBitMap)) then
	Result := False
else
	begin
	SavePNG(VResource as TSBitMap, VStream);
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

procedure ConvertGRAYToRGBA(const BitMap : TSBitMap);
var
	NewBitMap : TSBitMap;
	x, y : TSMaxEnum;

function MultiplyByte(const b : TSByte; const m : TSFloat32) : TSByte;
var
	z : TSMaxEnum;
begin
z := Trunc(b * m);
if z > 255 then
	Result := 255
else
	Result := z;
end;

begin
NewBitMap := TSBitMap.Create();
NewBitMap.Width := BitMap.Width;
NewBitMap.Height := BitMap.Height;
NewBitMap.Channels := 4;
NewBitMap.ChannelSize := 8;
NewBitMap.ReAllocateMemory();
for x := 0 to NewBitMap.Width - 1 do
	for y := 0 to NewBitMap.Height - 1 do
		begin
		NewBitMap.Data[(y + x * NewBitMap.Height) * 4 + 0] := BitMap.Data[(y + x * BitMap.Height) * 2 + 0];
		NewBitMap.Data[(y + x * NewBitMap.Height) * 4 + 1] := BitMap.Data[(y + x * BitMap.Height) * 2 + 0];
		NewBitMap.Data[(y + x * NewBitMap.Height) * 4 + 2] := BitMap.Data[(y + x * BitMap.Height) * 2 + 0];
		//NewBitMap.Data[(y + x * NewBitMap.Height) * 4 + 3] := MultiplyByte(BitMap.Data[(y + x * BitMap.Height) * 2 + 1], 3); 28 March 2020�. png ilpha channel for one image
		NewBitMap.Data[(y + x * NewBitMap.Height) * 4 + 3] := BitMap.Data[(y + x * BitMap.Height) * 2 + 1];
		end;

BitMap.Clear();
BitMap.Width := NewBitMap.Width;
BitMap.Height := NewBitMap.Height;
BitMap.Channels := 4;
BitMap.ChannelSize := 8;
BitMap.ReAllocateMemory();
Move(NewBitMap.Data^, BitMap.Data^, NewBitMap.DataSize());
SKill(NewBitMap);
end;

procedure LoadPNG(const Stream: TStream;const BitMap:TSBitMap);
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

	BitMap.Width := png_get_image_width(png_ptr, info_ptr);
	BitMap.Height := png_get_image_height(png_ptr, info_ptr);
	BitMap.Channels := png_get_channels(png_ptr, info_ptr);
	BitMap.ChannelSize := png_get_bit_depth(png_ptr, info_ptr);
	BitMap.ReAllocateMemory();

	png_read_update_info(png_ptr, info_ptr);

	SetLEngth(row_pointers,BitMap.Height);

	for i := 0 to BitMap.Height-1 do
		row_pointers[i] := @BitMap.Data[(BitMap.Height-1 -i )*(BitMap.Width)*BitMap.Channels];

	png_read_image(png_ptr, @row_pointers[0]);

	SetLength(row_pointers,0);

	png_read_end(png_ptr, nil);
	
	WarningsList := TDynStringArray(png_get_error_ptr(png_ptr));
	if (WarningsList<>nil) or (Length(WarningsList)<>0) then
		begin
		for i:= 0 to High(WarningsList) do
			SLog.Source('LoadPNG(TStream, TBitMap) WarningsList : '+WarningsList[i]);
		SetLength(WarningsList,0);
		end;
	
	if (png_ptr <> nil) then
		begin
		if info_ptr = nil then
			png_destroy_read_struct(@png_ptr, nil, nil)
		else
			png_destroy_read_struct(@png_ptr, @info_ptr, nil);
		end;
except
	SLog.Source('SmoothImagesPNG: Exeption while loading png!');
	BitMap.Clear();
	end;

//BitMap.WriteInfo();
if (BitMap.Channels = 2) then //PNG_COLOR_TYPE_GRAY
	ConvertGRAYToRGBA(BitMap);
end;

procedure SavePNG(const BitMap: TSBitMap; const Stream: TStream;const  Interlaced: boolean = false);
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
	case BitMap.Channels of
	4 : ColorType:=PNG_COLOR_TYPE_RGBA;
	3 : ColorType:=PNG_COLOR_MASK_COLOR;
	2 : ColorType:=PNG_COLOR_TYPE_GRAY;
	1 : ColorType:=PNG_COLOR_TYPE_GRAY_ALPHA;
	else ColorType:=0;
	end;
	if ColorType=0 then
		Exit;

	png_set_IHDR(png_ptr, info_ptr, BitMap.Width, BitMap.Height, 8, ColorType,
		interlaceType, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
	png_write_info(png_ptr, info_ptr);
	SetLength(row_pointers,BitMap.Height);
	try
		for i := 0 to BitMap.Height-1 do
			row_pointers[i] := @BitMap.Data[(BitMap.Height-1 -i )*(BitMap.Width)*BitMap.Channels];
		png_write_image(png_ptr, @row_pointers[0]);
	finally
		SetLength(row_pointers,0);
		end;

	png_write_end(png_ptr, nil);
finally
	WarningsList := TDynStringArray(png_get_error_ptr(png_ptr));
	if WarningsList<>nil then
		for i:= 0 to High(WarningsList) do
			SLog.Source('LoadPNG(TStream,TBitMap) WarningsList : '+WarningsList[i]);
	SetLength(warningslist,0);
	
	if png_ptr <> nil then
		begin
		if info_ptr <> nil then
		png_destroy_write_struct(@png_ptr, @info_ptr) else
		png_destroy_write_struct(@png_ptr, nil);
		end;
	end;
end;

initialization
begin
SResourceManager.AddManipulator(TSResourceManipulatorImagesPNG);
end;

end.
