{ Handling JPEG files.
  This is a reorganized version of pasjpeg.pas unit from PasJPEG package. }

{
  Copyright 2002-2010 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}
{$MACRO ON}
{ This file defines many symbols that I use in my sources.

  I *do not* have to include it in all my units, I include it only when
  I use some particular symbol (e.g. DELPHI) in my unit. Then I want to include
  this file to make sure that such symbol is correctly defined
  (e.g. that DELPHI is defined if and only if I'm compiling with Delphi).

  This file does not define some basic compiler settings, like
  syntax things (hugestrings ? which FPC mode to use ? ...) or what
  checks to do (io checks ? range checks ? assertions ? ...).
  Instead I depend on the fact that all my units must be compiled with
  my ../kambi.cfg configuration file. That file defines such basic
  compiler options. That's because I can't control everything using
  include file, like this one. E.g. I can't say here to add HeapTrc
  and LineInfo at the beginning of "uses" clause of current unit/program.
  But I can say it easily in ../kambi.cfg using "-gl -gh" options.
}

{$ifndef KambiConf_ALREADY_INCLUDED}
{$define KambiConf_ALREADY_INCLUDED}

{ Configurable: define KAMBI_VRMLENGINE_LGPL to compile only
  components available on permissive LGPL (see
  http://vrmlengine.sourceforge.net/kambi_vrml_game_engine.php#section_license) }
{ $define KAMBI_VRMLENGINE_LGPL}

{ Define KAMBI_HAS_NURBS only when not defined KAMBI_VRMLENGINE_LGPL.
  NURBS implementatton uses GPL-only (strict) code from White Dune. }
{$define KAMBI_HAS_NURBS}
{$ifdef KAMBI_VRMLENGINE_LGPL}
  {$undef KAMBI_HAS_NURBS}
{$endif}

{ According to Borland starting from Delphi 6 MSWINDOWS
  is the preferred symbol to mark Windows-only code
  (that is not necessarily tied only to 32-bit Windows).
  But older Delphi and FPC 1.0.x did not define this symbol,
  I fix this below. }
{$ifdef WIN32} {$define MSWINDOWS} {$endif}

{ A hack to detect Kylix 1, that AFAIK does not define any VERxxx }
{$IFNDEF FPC} {$ifdef LINUX} {$define VER140} {$endif} {$endif}

{ Symbols to check that we're compiled with Delphi (DELPHI symbol)
  and Delphi version.

  Note that Delphi 6 = Kylix 1. To differentiate between Delphi on Windows
  and Kylix use MSWINDOWS / LINUX symbols. }
{$ifdef VER80}  {$define DELPHI}                                                                                     {$endif}
{$ifdef VER90}  {$define DELPHI}                                                                                     {$endif}
{$ifdef VER93}  {$define DELPHI}                                                                                     {$endif}
{$ifdef VER100} {$define DELPHI}                                                                                     {$endif}
{$ifdef VER110} {$define DELPHI}                                                                                     {$endif}
{$ifdef VER120} {$define DELPHI} {$define DELPHI4_UP}                                                                {$endif}
{$ifdef VER125} {$define DELPHI} {$define DELPHI4_UP}                                                                {$endif}
{$ifdef VER130} {$define DELPHI} {$define DELPHI4_UP} {$define DELPHI5_UP}                                           {$endif}
{$ifdef VER140} {$define DELPHI} {$define DELPHI4_UP} {$define DELPHI5_UP} {$define DELPHI6_UP}                      {$endif}
{$ifdef VER150} {$define DELPHI} {$define DELPHI4_UP} {$define DELPHI5_UP} {$define DELPHI6_UP} {$define DELPHI7_UP} {$endif}

{ Borland does not define UNIX symbol, but I often use it. }
{$ifdef DELPHI} {$ifdef LINUX} {$define UNIX} {$endif} {$endif}

{ Does compiler support various things ?
  DEFPARS - Default parameters,
  SUPPORTS_INTERFACE - interfaces }
{$ifdef DELPHI4_UP}
  {$define DEFPARS}
  {$define SUPPORTS_INTERFACE}
{$endif}
{$ifdef FPC}
  {$ifndef VER1_0}
    {$define DEFPARS}
    {$define SUPPORTS_INTERFACE}
  {$endif}
{$endif}

{ I don't like Delphi warnings that "faXxx is specific to platform" }
{$ifdef DELPHI} {$warn SYMBOL_PLATFORM OFF} {$endif}

{ Always define USE_LIBC under FPC 1.0.x under UNIX,
  see README.use_libc }
{$ifdef FPC} {$ifdef VER1_0} {$ifdef UNIX}
  {$define USE_LIBC}
{$endif} {$endif} {$endif}

(*EXTENDED_EQUALS_DOUBLE should be defined when Extended type is
  the same thing as Double type on this platform.

  One typical case when this is important is when you overload
  one procedure like
    p(single)
    p(double)
    p(extended)
  In such cases you must do it like this:
    p(single)
    p(double)
    {$ifndef EXTENDED_EQUALS_DOUBLE} p(extended) {$endif}

  According to FPC docs (Programmers Manual, 8.2.0: floating point types),
  there's no Extended (i.e. Extended = Double) for most of non-i386 architectures.
  Exception to the above is Linux on x86-64, that allows to use normal Extended.
  Maybe Darwin on x86-64 also?
*)
{$ifdef FPC}
  {$ifndef FPC_HAS_TYPE_EXTENDED}
    {$define EXTENDED_EQUALS_DOUBLE}
  {$endif}
{$endif}

{$ifdef FPC}
  { We do *not* define inline functions/methods when compiling from
    Lazarus package. This is to workaround FPC bug
    http://bugs.freepascal.org/view.php?id=12223 }
  {$ifndef KAMBI_FROM_LAZARUS_PACKAGE}
    {$define SUPPORTS_INLINE}
  {$endif}

  {$ifdef VER2_0}   {$define USE_KAMBI_XMLREAD} {$endif}
  {$ifdef VER2_2_0} {$define USE_KAMBI_XMLREAD} {$endif}
  {$ifdef VER2_2_2} {$define USE_KAMBI_XMLREAD} {$endif}

  { Do not use KambiXMLRead for FPC > 2.2.2, no need
    (http://bugs.freepascal.org/view.php?id=11957 already fixed there)
    and no way (not compatible, internal things in DOM unit changed). }

  {$ifndef USE_KAMBI_XMLREAD}
    {$define KambiXMLRead := XMLRead}
  {$endif}

  {$define TOBJECT_HAS_EQUALS}
  {$ifdef VER2_0}   {$undef TOBJECT_HAS_EQUALS} {$endif}
  {$ifdef VER2_2_0} {$undef TOBJECT_HAS_EQUALS} {$endif}
  {$ifdef VER2_2_2} {$undef TOBJECT_HAS_EQUALS} {$endif}
  {$ifdef VER2_2_4} {$undef TOBJECT_HAS_EQUALS} {$endif}
  {$ifdef VER2_4_0} {$undef TOBJECT_HAS_EQUALS} {$endif}
{$endif}

{$endif not KambiConf_ALREADY_INCLUDED}

{$MODE DELPHI}
unit SaGeImagesJpeg;

(*Look for string "Kambi" to find my changes.
  Mainly, stream and error managers were moved to separate units
  (and error manager changed greatly).
  Also {$I jconfig.inc} was removed (it is not needed for this unit)
  so this file can be used even if someone does not have pasjpeg sources
  with FPC (e.g. he has a precompiled FPC snapshot or install).

  TODO: I'm planning to hack this file even
  more some day so that I can make nice&clean implementation of
  Images_jpeg.inc
*)

{ Instead of including jconfig.inc I just always define here
  BITS_IN_JSAMPLE_IS_8 (but you must make sure that PasJPEG is really compiled
  with BITS_IN_JSAMPLE_IS_8 defined ! If you're using standard FPC pasjpeg
  package then this is valid.) }
{$define BITS_IN_JSAMPLE_IS_8}

{ Turned off some checks to be safe, I know that some units in pasjpeg
  require range/overflow checking OFF (i.e. it is sometimes legal for them
  to do some overflow and/or range error). I'm not sure whether this
  unit wants it. But I want to be safe so I turned it off. }
{$R-,Q-}

{ inmemory is always treated as false under Unix and / or FPC -
  because FPC+Linux / Kylix / FPC+Win32 compiled applications
  go crazy and crash when they try to handle large jpegs with
  inmemory=true. }
{$ifdef FPC}  {$define INMEMORY_FALSE} {$endif}
{$ifdef UNIX} {$define INMEMORY_FALSE} {$endif}

interface

uses
  Classes, SysUtils
	,SaGeBase
	,SaGeBased
	,SaGeImagesBmp
	,SaGeImagesBase;

type
  { }
  JPEG_ProgressMonitor = procedure(Percent: Integer);

{ }
procedure LoadJPEG(
  {streams:}
  const infile, outfile: TStream; inmemory: boolean;
  {decompression parameters:}
  numcolors: integer;
  {progress monitor}
  callback: JPEG_ProgressMonitor);

{ }
procedure StoreJPEG(
  {streams}
  const infile, outfile: TStream; inmemory: boolean;
  {compression parameters:}
  quality: integer;
  {progress monitor}
  callback: JPEG_ProgressMonitor);

procedure SaveJPEG(const infile, outfile: TStream);overload;

procedure LoadJPEGToBitMap(const FStream:TStream;var FBitMap:TSGBitMap);
procedure SaveJPEGFromBitMap(const FStream:TStream;var FBitMap:TSGBitMap);

implementation

uses
  {PASJPG10 library}
  jmorecfg,
  jpeglib,
  jerror,
  jdeferr,
  jdmarker,
  jdmaster,
  jdapimin,
  jdapistd,
  jcparam,
  jcapimin,
  jcapistd,
  jcomapi;

procedure SaveJPEGFromBitMap(const FStream:TStream;var FBitMap:TSGBitMap);
var
	Stream:TMemoryStream = nil;
begin
Stream:=TMemoryStream.Create();
SaveBMP(FBitMap,Stream);
Stream.Position:=0;
SaveJPEG(Stream,FStream);
Stream.Destroy();
end;

procedure LoadJPEGToBitMap(const FStream:TStream;var FBitMap:TSGBitMap);
var
	Stream:TMemoryStream = nil;
begin
Stream:=TMemoryStream.Create();
LoadJPEG(FStream,Stream, true, 0, nil);
Stream.Position:=0;
LoadBMP(Stream,FBitMap);
Stream.Destroy();
end;

 type
  { }
  passtream_source_mgr = record
    pub    : jpeg_source_mgr;   {< public fields}
    infile : TStream;           {< source stream}
    buffer : JOCTET_FIELD_PTR;  {< start of buffer}
    start_of_file : boolean;    {< have we gotten any data yet?}
  end;
  passtream_source_ptr = ^passtream_source_mgr;

  passtream_dest_mgr = record
    pub     : jpeg_destination_mgr;  {< public fields}
    outfile : TStream;               {< target stream}
    buffer  : JOCTET_FIELD_PTR;      {< start of buffer}
  end;
  passtream_dest_ptr = ^passtream_dest_mgr;
  
const
  INPUT_BUF_SIZE = 4096;

procedure init_source(cinfo : j_decompress_ptr);
var
  src : passtream_source_ptr;
begin
  src := passtream_source_ptr(cinfo^.src);
  src^.start_of_file := TRUE;
end;

function fill_input_buffer(cinfo : j_decompress_ptr) : boolean;
var
  src : passtream_source_ptr;
  nbytes : size_t;
begin
  src := passtream_source_ptr(cinfo^.src);
  nbytes := src^.infile.Read(src^.buffer^, INPUT_BUF_SIZE);
  if (nbytes <= 0) then begin
    if (src^.start_of_file) then   {Treat empty input file as fatal error}
      ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EMPTY);
    WARNMS(j_common_ptr(cinfo), JWRN_JPEG_EOF);
    {Insert a fake EOI marker}
    src^.buffer^[0] := JOCTET ($FF);
    src^.buffer^[1] := JOCTET (JPEG_EOI);
    nbytes := 2;
  end;
  src^.pub.next_input_byte := JOCTETptr(src^.buffer);
  src^.pub.bytes_in_buffer := nbytes;
  src^.start_of_file := FALSE;
  fill_input_buffer := TRUE;
end;

procedure skip_input_data(cinfo : j_decompress_ptr;
                      num_bytes : long);
var
  src : passtream_source_ptr;
begin
  src := passtream_source_ptr (cinfo^.src);
  if (num_bytes > 0) then begin
    while (num_bytes > long(src^.pub.bytes_in_buffer)) do begin
      Dec(num_bytes, long(src^.pub.bytes_in_buffer));
      fill_input_buffer(cinfo);
      { note we assume that fill_input_buffer will never return FALSE,
        so suspension need not be handled. }
    end;
    Inc( src^.pub.next_input_byte, size_t(num_bytes) );
    Dec( src^.pub.bytes_in_buffer, size_t(num_bytes) );
  end;
end;

procedure term_source(cinfo : j_decompress_ptr);
begin
  { no work necessary here }
end;

procedure jpeg_stream_source(cinfo : j_decompress_ptr; const infile: TStream);
var
  src : passtream_source_ptr;
begin
  if (cinfo^.src = nil) then begin {first time for this JPEG object?}
    cinfo^.src := jpeg_source_mgr_ptr(
      cinfo^.mem^.alloc_small (j_common_ptr(cinfo), JPOOL_PERMANENT,
                                  SIZEOF(passtream_source_mgr)) );
    src := passtream_source_ptr (cinfo^.src);
    src^.buffer := JOCTET_FIELD_PTR(
      cinfo^.mem^.alloc_small (j_common_ptr(cinfo), JPOOL_PERMANENT,
                                  INPUT_BUF_SIZE * SIZEOF(JOCTET)) );
  end;
  src := passtream_source_ptr (cinfo^.src);
  {override pub's method pointers}
  src^.pub.init_source := {$ifdef FPC_OBJFPC} @ {$endif} {$ifdef DELPHI} @ {$endif} init_source;
  src^.pub.fill_input_buffer := {$ifdef FPC_OBJFPC} @ {$endif} fill_input_buffer;
  src^.pub.skip_input_data := {$ifdef FPC_OBJFPC} @ {$endif} skip_input_data;
  src^.pub.resync_to_restart := {$ifdef FPC_OBJFPC} @ {$endif} jpeg_resync_to_restart; {use default method}
  src^.pub.term_source := {$ifdef FPC_OBJFPC} @ {$endif} term_source;
  {define our fields}
  src^.infile := infile;
  src^.pub.bytes_in_buffer := 0;   {forces fill_input_buffer on first read}
  src^.pub.next_input_byte := nil; {until buffer loaded}
end;

{ ---------------------------------------------------------------------- }
{   destination manager to write compressed data                         }
{   for reference: JDATADST.PAS in PASJPG10 library                      }
{
  Kambi notes : this code was originally in pasjpeg.pas written by Nomssi.
  I only changed name of manager from my_dest_mgr to
  passtream_dest_mgr since this is the purpose of this manager :
  write destination data to a pascal stream - that is, TStream class.
  Almost whole Nomsii code for this looks good, I did only minimal changes
  not worth noticing !
}
{ ---------------------------------------------------------------------- }

const
  OUTPUT_BUF_SIZE = 4096;

procedure init_destination(cinfo : j_compress_ptr);
var
  dest : passtream_dest_ptr;
begin
  dest := passtream_dest_ptr(cinfo^.dest);
  dest^.buffer := JOCTET_FIELD_PTR(
      cinfo^.mem^.alloc_small (j_common_ptr(cinfo), JPOOL_IMAGE,
                                  OUTPUT_BUF_SIZE * SIZEOF(JOCTET)) );
  dest^.pub.next_output_byte := JOCTETptr(dest^.buffer);
  dest^.pub.free_in_buffer := OUTPUT_BUF_SIZE;
end;

function empty_output_buffer(cinfo : j_compress_ptr) : boolean;
var
  dest : passtream_dest_ptr;
begin
  dest := passtream_dest_ptr(cinfo^.dest);
  if (dest^.outfile.Write(dest^.buffer^, OUTPUT_BUF_SIZE)
        <> size_t(OUTPUT_BUF_SIZE))
  then
    ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
  dest^.pub.next_output_byte := JOCTETptr(dest^.buffer);
  dest^.pub.free_in_buffer := OUTPUT_BUF_SIZE;
  empty_output_buffer := TRUE;
end;

procedure term_destination(cinfo : j_compress_ptr);
var
  dest : passtream_dest_ptr;
  datacount : size_t;
begin
  dest := passtream_dest_ptr (cinfo^.dest);
  datacount := OUTPUT_BUF_SIZE - dest^.pub.free_in_buffer;
  {write any data remaining in the buffer}
  if (datacount > 0) then
    if dest^.outfile.Write(dest^.buffer^, datacount) <> datacount then
      ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
end;

procedure jpeg_stream_dest(cinfo : j_compress_ptr; const outfile: TStream);
var
  dest : passtream_dest_ptr;
begin
  if (cinfo^.dest = nil) then begin {first time for this JPEG object?}
    cinfo^.dest := jpeg_destination_mgr_ptr(
      cinfo^.mem^.alloc_small (j_common_ptr(cinfo), JPOOL_PERMANENT,
                                  SIZEOF(passtream_dest_mgr)) );
  end;
  dest := passtream_dest_ptr (cinfo^.dest);
  {override pub's method pointers}
  dest^.pub.init_destination := {$ifdef FPC_OBJFPC} @ {$endif} init_destination;
  dest^.pub.empty_output_buffer := {$ifdef FPC_OBJFPC} @ {$endif} empty_output_buffer;
  dest^.pub.term_destination := {$ifdef FPC_OBJFPC} @ {$endif} term_destination;
  {define our fields}
  dest^.outfile := outfile;
end;

type
		EJPEG = class(Exception);

	pascal_error_mgr = record
		pub: jpeg_error_mgr;
		end;
	pascal_error_ptr = ^pascal_error_mgr;

procedure error_exit (cinfo : j_common_ptr);
var
  buffer : string;
begin
 cinfo^.err^.format_message(cinfo, buffer);
 raise EJPEG.Create(buffer);
end;

procedure output_message (cinfo : j_common_ptr);
var
 buffer : string;
begin
 cinfo^.err^.format_message (cinfo, buffer);

 { to nie jest dobre takie wypisywanie czegos na stdout/err w dowolnej chwili
   lub przerywanie programu zeby wyswietlic MessageBoxa. Pomijam juz nawet
   fakt ze pod Windowsem obydwie metody moga zawiesc (aplikacje GUI
   nie maja stdout a co do MessageBoxa to cos nienajlepiej sie wyswietla
   gdy mamy otwarte okno OpenGL'a fullscreen).
   Tym samym wiec rzeczy ponizej sa zakomentarzowane - nigdy nie wyswietlaj
   warningow czy czegos takiego. Moduly jpeg'a moga tylko zaladowac obrazek
   lub rzucic wyjatek. }

{ TODO: jak tylko bedzie potrzeba i okazja, zrobi sie jednak jakis mechanizm
  wypuszczania tych warningow na zewnatrz, np. zmienna OnJpegWarning }

(*
 { show message using WinAPI or Writeln }
 {$ifdef MSWINDOWS} if not IsConsole then MessageBox(0,PChar(buffer),'jpeg message',MB_OK) else
 {$else}            Writeln(ErrOutput, buffer);
 {$endif}
*)
end;

{ Kambi*: copied from jerror.pas to workaround a bug in pasjpeg (original
  PasJPEG from Nomssi pages and in FPC pasjpeg package) that defined
  NO_FORMAT symbol for FPC. This makes incorrect (unformatted, with
  things like '%d' left !) error messages.

  ALL below is exactly copied from jerror.format_message (it's just that
  NO_FORMAT is undefined here). }
procedure format_message (cinfo : j_common_ptr; var buffer : string);
var
  err : jpeg_error_mgr_ptr;
  msg_code : J_MESSAGE_CODE;
  msgtext : string;
  isstring : boolean;
begin
  err := cinfo^.err;
  msg_code := J_MESSAGE_CODE(err^.msg_code);
  msgtext := '';

  { Look up message string in proper table }
  if (msg_code > JMSG_NOMESSAGE)
    and (msg_code <= J_MESSAGE_CODE(err^.last_jpeg_message)) then
  begin
    msgtext := err^.jpeg_message_table^[msg_code];
  end
  else
  if (err^.addon_message_table <> NIL) and
     (msg_code >= err^.first_addon_message) and
     (msg_code <= err^.last_addon_message) then
  begin
    msgtext := err^.addon_message_table^[J_MESSAGE_CODE
           (ord(msg_code) - ord(err^.first_addon_message))];
  end;

  { Defend against bogus message number }
  if (msgtext = '') then
  begin
    err^.msg_parm.i[0] := int(msg_code);
    msgtext := err^.jpeg_message_table^[JMSG_NOMESSAGE];
  end;

  { Check for string parameter, as indicated by %s in the message text }
  isstring := Pos('%s', msgtext) > 0;

  { Format the message into the passed buffer }
  if (isstring) then
    buffer := Concat(msgtext, err^.msg_parm.s)
  else
  begin
 {$IFDEF VER70}
    FormatStr(buffer, msgtext, err^.msg_parm.i);
 {$ELSE}
   {$IFDEF NO_FORMAT}
   buffer := msgtext;
   {$ELSE}
   buffer := Format(msgtext, [
        err^.msg_parm.i[0], err^.msg_parm.i[1],
        err^.msg_parm.i[2], err^.msg_parm.i[3],
        err^.msg_parm.i[4], err^.msg_parm.i[5],
        err^.msg_parm.i[6], err^.msg_parm.i[7] ]);
   {$ENDIF}
 {$ENDIF}
  end;
end;

function jpeg_pascal_error (var err : pascal_error_mgr) : jpeg_error_mgr_ptr;
begin
 jpeg_std_error(err.pub);
 err.pub.error_exit := {$ifdef FPC_OBJFPC} @ {$endif} error_exit;
 err.pub.output_message := {$ifdef FPC_OBJFPC} @ {$endif} output_message;
 { Kambi+, register ours format_message }
 err.pub.format_message := {$ifdef FPC_OBJFPC} @ {$endif} format_message;
 result:=@err;
end;

{ Kambi+ : things from Windows unit (TbitmapXxx types),
  needed under other OSes }

type
  PBitmapFileHeader = ^TBitmapFileHeader;
  TBitmapFileHeader = packed record
    bfType: Word;
    bfSize: LongWord;
    bfReserved1: Word;
    bfReserved2: Word;
    bfOffBits: LongWord;
  end;

  PBitmapInfoHeader = ^TBitmapInfoHeader;
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

  PBitmapCoreHeader = ^TBitmapCoreHeader;
  TBitmapCoreHeader = packed record { structures for defining DIBs - used to get to color table }
    bcSize: LongWord;
    bcWidth: Word;
    bcHeight: Word;
    bcPlanes: Word;
    bcBitCount: Word;
  end;

{ ------------------------------------------------------------------------ }
{   Bitmap writing routines                                                }
{   for reference: WRBMP.PAS in PASJPG10 library                           }
{ ------------------------------------------------------------------------ }
{   NOTE: we always write BMP's in Windows format, no OS/2 formats!        }
{         however, we read all bitmap flavors (see bitmap reading)         }
{ ------------------------------------------------------------------------ }

{ To support 12-bit JPEG data, we'd have to scale output down to 8 bits.
  This is not yet implemented. }

{$ifndef BITS_IN_JSAMPLE_IS_8}
  Sorry, this code only copes with 8-bit JSAMPLEs. { deliberate syntax err }
{$endif}

type
  BGRptr = ^BGRtype;
  BGRtype = packed record
    b,g,r : byte;
  end;

  RGBptr = ^RGBtype;
  RGBtype = packed record
    r,g,b : JSAMPLE;
  end;

  bmp_dest_ptr = ^bmp_dest_struct;
  bmp_dest_struct = record
    outfile : TStream;              {Stream to write to}
    inmemory : boolean;             {keep whole image in memory}
    {image info}
    data_width : JDIMENSION;        {JSAMPLEs per row}
    row_width : JDIMENSION;         {physical width of one row in the BMP file}
    pad_bytes : INT;                {number of padding bytes needed per row}
    grayscale : boolean;            {grayscale or quantized color table ?}
    {pixelrow buffer}
    buffer : JSAMPARRAY;            {pixelrow buffer}
    buffer_height : JDIMENSION;     {normally, we'll use 1}
    {image buffer}
    image_buffer : jvirt_sarray_ptr;{needed to reverse row order BMP<>JPG}
    image_buffer_height : JDIMENSION;  { }
    cur_output_row : JDIMENSION;    {next row# to write to virtual array}
    row_offset : INT32;             {position of next row to write to BMP}
  end;

procedure write_bmp_header (cinfo : j_decompress_ptr;
                             dest : bmp_dest_ptr);
  {Write a Windows-style BMP file header, including colormap if needed}
var
  bmpfileheader : TBitmapFileHeader;
  bmpinfoheader : TBitmapInfoHeader;
  headersize    : INT32;
  bits_per_pixel, cmap_entries, num_colors, i : INT;
  output_ext_color_map : array[0..255] of record b,g,r,a: byte; end;
begin
  {colormap size and total file size}
  if (cinfo^.out_color_space = JCS_RGB) then begin
    if (cinfo^.quantize_colors) then begin {colormapped RGB}
      bits_per_pixel := 8;
      cmap_entries := 256;
    end else begin {unquantized, full color RGB}
      bits_per_pixel := 24;
      cmap_entries := 0;
    end;
  end else begin {grayscale output. We need to fake a 256-entry colormap.}
    bits_per_pixel := 8;
    cmap_entries := 256;
  end;
  headersize := SizeOf(TBitmapFileHeader)+SizeOf(TBitmapInfoHeader)+
                  cmap_entries * 4;
  {define headers}
  FillChar(bmpfileheader, SizeOf(bmpfileheader), $0);
  FillChar(bmpinfoheader, SizeOf(bmpinfoheader), $0);
  with bmpfileheader do begin
    bfType := $4D42; {BM}
    bfSize := headersize + INT32(dest^.row_width) * INT32(cinfo^.output_height);
    bfOffBits := headersize;
  end;
  with bmpinfoheader do begin
    biSize := SizeOf(TBitmapInfoHeader);
    biWidth := cinfo^.output_width;
    biHeight := cinfo^.output_height;
    biPlanes := 1;
    biBitCount := bits_per_pixel;
    if (cinfo^.density_unit = 2) then begin
      biXPelsPerMeter := INT32(cinfo^.X_density*100);
      biYPelsPerMeter := INT32(cinfo^.Y_density*100);
    end;
    biClrUsed := cmap_entries;
  end;
  if dest^.outfile.Write(bmpfileheader, SizeOf(bmpfileheader))
       <> size_t(SizeOf(bmpfileheader)) then
    ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
  if dest^.outfile.Write(bmpinfoheader, SizeOf(bmpinfoheader))
       <> size_t(SizeOf(bmpinfoheader)) then
    ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
  {colormap}
  if cmap_entries > 0 then begin
    num_colors := cinfo^.actual_number_of_colors;
    if cinfo^.colormap <> nil then begin
      if cinfo^.out_color_components = 3 then
        for i := 0 to pred(num_colors) do
          with output_ext_color_map[i] do begin
            b := GETJSAMPLE(cinfo^.colormap^[2]^[i]);
            g := GETJSAMPLE(cinfo^.colormap^[1]^[i]);
            r := GETJSAMPLE(cinfo^.colormap^[0]^[i]);
            a := 0;
          end
      else
        {grayscale colormap (only happens with grayscale quantization)}
        for i := 0 to pred(num_colors) do
          with output_ext_color_map[i] do begin
            b := GETJSAMPLE(cinfo^.colormap^[0]^[i]);
            g := GETJSAMPLE(cinfo^.colormap^[0]^[i]);
            r := GETJSAMPLE(cinfo^.colormap^[0]^[i]);
            a := 0;
          end;
      i := num_colors;
    end else begin
      {if no colormap, must be grayscale data. Generate a linear "map".}
      {Nomssi: do not use "num_colors" here, it should be 0}
      for i := 0 to pred(256) do
        with output_ext_color_map[i] do begin
          b := i;
          g := i;
          r := i;
          a := 0;
        end;
      i := 256;
    end;
    {pad colormap with zeros to ensure specified number of colormap entries}
    if i > cmap_entries then
      ERREXIT1(j_common_ptr(cinfo), JERR_TOO_MANY_COLORS, i);
    while i < cmap_entries do begin
      with output_ext_color_map[i] do begin
        b := 0;
        g := 0;
        r := 0;
        a := 0;
      end;
      Inc(i);
    end;
    if dest^.outfile.Write(output_ext_color_map, cmap_entries*4)
         <> cmap_entries*4 then
      ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
  end;
  dest^.row_offset := bmpfileheader.bfSize;
end;

procedure write_bmp_pixelrow (cinfo : j_decompress_ptr;
                               dest : bmp_dest_ptr;
                      rows_supplied : JDIMENSION);
var
  image_ptr : JSAMPARRAY;
  inptr, outptr : JSAMPLE_PTR;
  BGR : BGRptr;
  col,row : JDIMENSION;
  pad : int;
begin
  if dest^.inmemory then begin
    row := dest^.cur_output_row;
    Inc(dest^.cur_output_row);
  end else begin
    row := 0;
    Dec(dest^.row_offset, dest^.row_width);
  end;
  image_ptr := cinfo^.mem^.access_virt_sarray ( j_common_ptr(cinfo),
     dest^.image_buffer, row, JDIMENSION (1), TRUE);
  inptr := JSAMPLE_PTR(dest^.buffer^[0]);
  if not dest^.grayscale then begin
    BGR := BGRptr(image_ptr^[0]);
    for col := pred(cinfo^.output_width) downto 0 do begin
      BGR^.r := inptr^;
      Inc(inptr);
      BGR^.g := inptr^;
      Inc(inptr);
      BGR^.b := inptr^;
      Inc(inptr);
      Inc(BGR);
    end;
    outptr := JSAMPLE_PTR(BGR);
  end else begin
    outptr := JSAMPLE_PTR(image_ptr^[0]);
    for col := pred(cinfo^.output_width) downto 0 do begin
      outptr^ := inptr^;
      Inc(outptr);
      Inc(inptr);
    end;
  end;
  {zero out the pad bytes}
  pad := dest^.pad_bytes;
  while (pad > 0) do begin
    Dec(pad);
    outptr^ := 0;
    Inc(outptr);
  end;
  if not dest^.inmemory then begin
    {store row in output stream}
    image_ptr := cinfo^.mem^.access_virt_sarray ( j_common_ptr(cinfo),
         dest^.image_buffer, 0, JDIMENSION(1), FALSE);
    outptr := JSAMPLE_PTR(image_ptr^[0]);
    if dest^.outfile.Seek(dest^.row_offset, 0) <> dest^.row_offset then
      ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
    if dest^.outfile.Write(outptr^, dest^.row_width) <> dest^.row_width then
      ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
  end;
end;

procedure write_bmp_image (cinfo : j_decompress_ptr;
                            dest : bmp_dest_ptr);
var
  row  : JDIMENSION;
  image_ptr : JSAMPARRAY;
  data_ptr  : JSAMPLE_PTR;
begin
  if dest^.inmemory then {write the image data from our virtual array}
    for row := cinfo^.output_height downto 1 do begin
      image_ptr := cinfo^.mem^.access_virt_sarray( j_common_ptr(cinfo),
         dest^.image_buffer, row-1, JDIMENSION(1), FALSE);
      data_ptr := JSAMPLE_PTR(image_ptr^[0]);
      {Nomssi - This won't work for 12bit samples}
      if dest^.outfile.Write(data_ptr^, dest^.row_width) <> dest^.row_width then
        ERREXIT(j_common_ptr(cinfo), JERR_FILE_WRITE);
    end;
end;

function jinit_write_bmp (cinfo : j_decompress_ptr;
                        outfile : TStream;
                       inmemory : boolean) : bmp_dest_ptr;
var
  dest : bmp_dest_ptr;
begin
  dest := bmp_dest_ptr (
      cinfo^.mem^.alloc_small (j_common_ptr(cinfo), JPOOL_IMAGE,
                                  SIZEOF(bmp_dest_struct)) );
  dest^.outfile := outfile;
  dest^.inmemory := inmemory;
  {image info}
  jpeg_calc_output_dimensions(cinfo);
  dest^.data_width := cinfo^.output_width * cinfo^.output_components;
  dest^.row_width := dest^.data_width;
  while ((dest^.row_width and 3) <> 0) do
    Inc(dest^.row_width);
  dest^.pad_bytes := int(dest^.row_width-dest^.data_width);
  if (cinfo^.out_color_space = JCS_GRAYSCALE) then
    dest^.grayscale := True
  else if (cinfo^.out_color_space = JCS_RGB) then
    if (cinfo^.quantize_colors) then
      dest^.grayscale := True
    else
      dest^.grayscale := False
  else
    ERREXIT(j_common_ptr(cinfo), JERR_BMP_COLORSPACE);
  {decompress buffer}
  dest^.buffer := cinfo^.mem^.alloc_sarray
    (j_common_ptr(cinfo), JPOOL_IMAGE, dest^.row_width, JDIMENSION (1));
  dest^.buffer_height := 1;
  {image buffer}
  if inmemory then
    dest^.image_buffer_height := cinfo^.output_height
  else
    dest^.image_buffer_height := 1;
  dest^.image_buffer := cinfo^.mem^.request_virt_sarray (
     j_common_ptr(cinfo), JPOOL_IMAGE, FALSE, dest^.row_width,
     dest^.image_buffer_height, JDIMENSION (1) );
  dest^.cur_output_row := 0;
  {result}
  jinit_write_bmp := dest;
end;

{ ------------------------------------------------------------------------ }
{   Bitmap reading routines                                                }
{   for reference: RDBMP.PAS in PASJPG10 library                           }
{ ------------------------------------------------------------------------ }

type
  bmp_source_ptr = ^bmp_source_struct;
  bmp_source_struct = record
    infile : TStream;               {stream to read from}
    inmemory : boolean;             {keep whole image in memory}
    {image info}
    bits_per_pixel : INT;           {bit depth}
    colormap : JSAMPARRAY;          {BMP colormap (converted to my format)}
    row_width : JDIMENSION;         {physical width of one row in the BMP file}
    {pixelrow buffer}
    buffer : JSAMPARRAY;            {pixelrow buffer}
    buffer_height : JDIMENSION;     {normally, we'll use 1}
    {image buffer}
    image_buffer : jvirt_sarray_ptr;   {needed to reverse order BMP<>JPG}
    image_buffer_height : JDIMENSION;  {image_height}
    cur_input_row : JDIMENSION;        {current source row number}
    row_offset : INT32;             {position of next row to read from BMP}
  end;

procedure read_bmp_header (cinfo : j_compress_ptr;
                          source : bmp_source_ptr);
var
  bmpfileheader : TBitmapFileHeader;
  bmpcoreheader : TBitmapCoreHeader;
  bmpinfoheader : TBitmapInfoHeader;
  i, cmap_entrysize : INT;

  function read_byte: INT;
    {Read next byte from BMP file}
  var
    c: byte;
  begin
    if source^.infile.Read(c, 1) <> size_t(1) then
      ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
    read_byte  := c;
  end;

begin
  cmap_entrysize := 0;          { 0 indicates no colormap }

  {bitmap file header:}
  if source^.infile.Read(bmpfileheader, SizeOf(bmpfileheader))
       <> size_t(SizeOf(bmpfileheader)) then
    ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
  if bmpfileheader.bfType <> $4D42 then {'BM'}
    ERREXIT(j_common_ptr(cinfo), JERR_BMP_NOT);

  {bitmap infoheader: might be 12 bytes (OS/2 1.x), 40 bytes (Windows),
   or 64 bytes (OS/2 2.x).  Check the first 4 bytes to find out which}
  if source^.infile.Read(bmpinfoheader, SizeOf(INT32)) <> size_t(SizeOf(INT32)) then
    ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
  {OS/2 1.x format}
  if bmpinfoheader.biSize = SizeOf(TBitmapCoreHeader) then begin
    bmpcoreheader.bcSize := bmpinfoheader.biSize;
    if source^.infile.Read(bmpcoreheader.bcWidth, bmpcoreheader.bcSize-SizeOf(INT32))
         <> size_t (bmpcoreheader.bcSize-SizeOf(INT32)) then
      ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
    bmpinfoheader.biWidth := bmpcoreheader.bcWidth;
    bmpinfoheader.biHeight := bmpcoreheader.bcHeight;
    bmpinfoheader.biPlanes := bmpcoreheader.bcPlanes;
    bmpinfoheader.biBitCount := bmpcoreheader.bcBitCount;
    bmpinfoheader.biClrUsed := 0;
    source^.bits_per_pixel := bmpinfoheader.biBitCount;
    case source^.bits_per_pixel of
       8: begin {colormapped image}
            cmap_entrysize := 3;  {OS/2 uses RGBTRIPLE colormap}
            TRACEMS2( j_common_ptr(cinfo), 1, JTRC_BMP_OS2_MAPPED,
              int (bmpinfoheader.biWidth), int(bmpinfoheader.biHeight));
          end;
      24: { RGB image }
          TRACEMS2( j_common_ptr(cinfo), 1, JTRC_BMP_OS2,
            int (bmpinfoheader.biWidth), int(bmpinfoheader.biHeight) );
    else
      ERREXIT(j_common_ptr(cinfo), JERR_BMP_BADDEPTH);
    end;
    if bmpinfoheader.biPlanes <> 1 then
      ERREXIT(j_common_ptr(cinfo), JERR_BMP_BADPLANES);
  end else
  {Windows 3.x or OS/2 2.x header, which has additional fields that we ignore }
  if (bmpinfoheader.biSize = SizeOf(TBitmapInfoHeader)) or
     (bmpinfoheader.biSize = 64) then
  begin
    if source^.infile.Read(bmpinfoheader.biWidth, SizeOf(bmpinfoheader)-SizeOf(INT32))
         <> size_t (SizeOf(bmpinfoheader)-SizeOf(INT32)) then
      ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
    if bmpinfoheader.biSize = 64 then
      source^.infile.Seek(64-SizeOf(TBitmapInfoHeader), 1);
    source^.bits_per_pixel := bmpinfoheader.biBitCount;
    case source^.bits_per_pixel of
       8: begin {colormapped image}
            cmap_entrysize := 4;        {Windows uses RGBQUAD colormap}
            TRACEMS2( j_common_ptr(cinfo), 1, JTRC_BMP_MAPPED,
              int (bmpinfoheader.biWidth), int(bmpinfoheader.biHeight) );
          end;
      24: {RGB image}
          TRACEMS2( j_common_ptr(cinfo), 1, JTRC_BMP,
            int (bmpinfoheader.biWidth), int(bmpinfoheader.biHeight) );
    else
      ERREXIT(j_common_ptr(cinfo), JERR_BMP_BADDEPTH);
    end;
    if (bmpinfoheader.biPlanes <> 1) then
      ERREXIT(j_common_ptr(cinfo), JERR_BMP_BADPLANES);
    if (bmpinfoheader.biCompression <> 0) then
      ERREXIT(j_common_ptr(cinfo), JERR_BMP_COMPRESSED);
    if (bmpinfoheader.biXPelsPerMeter > 0) and (bmpinfoheader.biYPelsPerMeter > 0) then
    begin
      {Set JFIF density parameters from the BMP data}
      cinfo^.X_density := bmpinfoheader.biXPelsPerMeter div 100; {100 cm per meter}
      cinfo^.Y_density := bmpinfoheader.biYPelsPerMeter div 100;
      cinfo^.density_unit := 2; { dots/cm }
    end;
  end else
    ERREXIT(j_common_ptr(cinfo), JERR_BMP_BADHEADER);

  {colormap}
  if cmap_entrysize > 0 then begin
    if bmpinfoheader.biClrUsed <= 0 then
      bmpinfoheader.biClrUsed := 256 {assume it's 256}
    else
      if bmpinfoheader.biClrUsed > 256 then
        ERREXIT(j_common_ptr(cinfo), JERR_BMP_BADCMAP);
    {allocate colormap}
    source^.colormap := cinfo^.mem^.alloc_sarray( j_common_ptr (cinfo),
      JPOOL_IMAGE, JDIMENSION(bmpinfoheader.biClrUsed), JDIMENSION (3));
    {read it}
    case cmap_entrysize of
      3: {BGR format (occurs in OS/2 files)}
        for i := 0 to pred(bmpinfoheader.biClrUsed) do begin
          source^.colormap^[2]^[i] := JSAMPLE (read_byte);
          source^.colormap^[1]^[i] := JSAMPLE (read_byte);
          source^.colormap^[0]^[i] := JSAMPLE (read_byte);
        end;
      4: {BGR0 format (occurs in MS Windows files)}
        for i := 0 to pred(bmpinfoheader.biClrUsed) do begin
          source^.colormap^[2]^[i] := JSAMPLE (read_byte);
          source^.colormap^[1]^[i] := JSAMPLE (read_byte);
          source^.colormap^[0]^[i] := JSAMPLE (read_byte);
          read_byte;
        end;
    else
      ERREXIT(j_common_ptr(cinfo), JERR_BMP_BADCMAP);
    end;
  end;

  {initialize bmp_source_struc}

  {row width, including padding to 4-byte boundary}
  if source^.bits_per_pixel = 24 then
    source^.row_width := JDIMENSION(bmpinfoheader.biWidth*3)
  else
    source^.row_width := JDIMENSION (bmpinfoheader.biWidth);
  while ((source^.row_width and 3) <> 0) do
    Inc(source^.row_width);

  {allocate pixelrow buffer}
  source^.buffer := cinfo^.mem^.alloc_sarray( j_common_ptr (cinfo),
    JPOOL_IMAGE, JDIMENSION (bmpinfoheader.biWidth*3), JDIMENSION (1) );
  source^.buffer_height := 1;

  {allocate image buffer}
  if source^.inmemory then begin
    source^.image_buffer_height := bmpinfoheader.biHeight;
    source^.cur_input_row := bmpinfoheader.biHeight;
  end else begin
    source^.image_buffer_height := 1;
    source^.row_offset := bmpfileheader.bfSize;
  end;
  source^.image_buffer := cinfo^.mem^.request_virt_sarray (
    j_common_ptr (cinfo), JPOOL_IMAGE, FALSE, source^.row_width,
     JDIMENSION(source^.image_buffer_height), JDIMENSION (1) );

  {set decompress parameters}
  cinfo^.in_color_space := JCS_RGB;
  cinfo^.input_components := 3;
  cinfo^.data_precision := 8;
  cinfo^.image_width := JDIMENSION (bmpinfoheader.biWidth);
  cinfo^.image_height := JDIMENSION (bmpinfoheader.biHeight);
end;

function read_bmp_pixelrow (cinfo : j_compress_ptr;
                           source : bmp_source_ptr) : JDIMENSION;
  { Read one row of pixels:
    the image has been read into the image_buffer array, but is otherwise
    unprocessed.  we must read it out in top-to-bottom row order, and if
    it is an 8-bit image, we must expand colormapped pixels to 24bit format. }
var
  col, row : JDIMENSION;
  image_ptr : JSAMPARRAY;
  inptr, outptr : JSAMPLE_PTR;
  outptr24 : JSAMPROW;
  t : INT;
begin
  if source^.inmemory then begin
    Dec(source^.cur_input_row);
    row := source^.cur_input_row;
  end else begin
    Dec(source^.row_offset, source^.row_width);
    row := 0;
  end;
  if not source^.inmemory then begin
    image_ptr := cinfo^.mem^.access_virt_sarray ( j_common_ptr (cinfo),
       source^.image_buffer, row, JDIMENSION (1), TRUE);
    inptr := JSAMPLE_PTR(image_ptr^[0]);
    if source^.infile.Seek(source^.row_offset, 0) <> source^.row_offset then
      ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
    if source^.infile.Read(inptr^, source^.row_width)
         <> size_t(source^.row_width) then
      ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
  end;
  image_ptr := cinfo^.mem^.access_virt_sarray ( j_common_ptr (cinfo),
    source^.image_buffer, row, JDIMENSION (1), FALSE);

  inptr := JSAMPLE_PTR(image_ptr^[0]);
  case source^.bits_per_pixel of
     8: begin
          {expand the colormap indexes to real data}
          outptr := JSAMPLE_PTR(source^.buffer^[0]);
          for col := pred(cinfo^.image_width) downto 0 do begin
            t := GETJSAMPLE(inptr^);
            Inc(inptr);
            outptr^ := source^.colormap^[0]^[t];
            Inc(outptr);
            outptr^ := source^.colormap^[1]^[t];
            Inc(outptr);
            outptr^ := source^.colormap^[2]^[t];
            Inc(outptr);
          end;
        end;
    24: begin
          outptr24 := source^.buffer^[0];
          for col := pred(cinfo^.image_width) downto 0 do begin
            outptr24^[2] := inptr^;
            Inc(inptr);
            outptr24^[1] := inptr^;
            Inc(inptr);
            outptr24^[0] := inptr^;
            Inc(inptr);
            Inc(JSAMPLE_PTR(outptr24), 3);
          end;
        end;
  end;
  read_bmp_pixelrow := 1;
end;

procedure read_bmp_image(cinfo : j_compress_ptr;
                        source : bmp_source_ptr);
var
  row : JDIMENSION;
  image_ptr : JSAMPARRAY;
  inptr : JSAMPLE_PTR;
begin
  if source^.inmemory then
    for row := 0 to pred(cinfo^.image_height) do begin
      image_ptr := cinfo^.mem^.access_virt_sarray ( j_common_ptr (cinfo),
         source^.image_buffer, row, JDIMENSION (1), TRUE);
      inptr := JSAMPLE_PTR(image_ptr^[0]);
      if source^.infile.Read(inptr^, source^.row_width)
           <> size_t(source^.row_width)
      then
        ERREXIT(j_common_ptr(cinfo), JERR_INPUT_EOF);
    end;
end;

function jinit_read_bmp (cinfo : j_compress_ptr;
                        infile : TStream;
                      inmemory : boolean) : bmp_source_ptr;
var
  source : bmp_source_ptr;
begin
  source := bmp_source_ptr (
      cinfo^.mem^.alloc_small (j_common_ptr(cinfo), JPOOL_IMAGE,
                               SIZEOF(bmp_source_struct)) );
  source^.infile := infile;
  source^.inmemory := inmemory;
  jinit_read_bmp := source;
end;

{ ------------------------------------------------------------------------ }
{   JPEG progress monitor support                                          }
{   for reference: LIPJPEG.DOC in \JPEG\C directory                        }
{ ------------------------------------------------------------------------ }

type
  my_progress_ptr = ^my_progress_mgr;
  my_progress_mgr = record
    pub : jpeg_progress_mgr;
    proc : JPEG_ProgressMonitor;
    percent_done : INT;
    completed_extra_passes : INT;
    total_extra_passes : INT;
  end;

procedure progress_monitor(cinfo: j_common_ptr);
var
  progress : my_progress_ptr;
  total_passes : INT;
  percent_done : INT;
begin
  progress := my_progress_ptr(cinfo^.progress);
  total_passes :=
    progress^.pub.total_passes + progress^.total_extra_passes;
  percent_done :=
    ( ((progress^.pub.completed_passes+progress^.completed_extra_passes)*100) +
      ((progress^.pub.pass_counter*100) div progress^.pub.pass_limit)
    ) div total_passes;

  if percent_done <> progress^.percent_done then begin
    progress^.percent_done := percent_done;
    progress^.proc(percent_done);
  end;
end;

procedure jpeg_my_progress(cinfo : j_common_ptr;
                        progress : my_progress_ptr;
                        callback : JPEG_ProgressMonitor);
begin
  if {$ifndef FPC_OBJFPC} @ {$endif} callback = nil then
    Exit;
  {set method}
  progress^.pub.progress_monitor := {$ifdef FPC_OBJFPC} @ {$endif} progress_monitor;
  {set fields}
  progress^.proc := callback;
  progress^.percent_done := -1;
  progress^.completed_extra_passes := 0;
  progress^.total_extra_passes := 0;
  {link to cinfo}
  cinfo^.progress := @progress^.pub;
end;

procedure jpeg_finish_progress(cinfo : j_common_ptr);
var
  progress : my_progress_ptr;
begin
  progress := my_progress_ptr(cinfo^.progress);

  if progress = nil then exit;
   {Kambi+, progress may be not initialized if callback = nil in call to Store/LoadJPEG}

  if progress^.percent_done <> 100 then begin
    progress^.percent_done := 100;
    progress^.proc(progress^.percent_done);
  end;
end;

{ ------------------------------------------------------------------------ }
{   load JPEG stream and save as BITMAP stream                             }
{   for reference: DJPEG.PAS in PASJPG10 library                           }
{ ------------------------------------------------------------------------ }

procedure LoadJPEG(const infile, outfile: TStream; inmemory: boolean;
                   {decompression parameters:}
                   numcolors: integer;
                   {progress monitor}
                   callback: JPEG_ProgressMonitor);
var
  cinfo : jpeg_decompress_struct;
  err   : pascal_error_mgr;
  dest  : bmp_dest_ptr;
  progress : my_progress_mgr;
  num_scanlines : JDIMENSION;
begin
  {$ifdef INMEMORY_FALSE} inmemory:=false; {$endif}

  {initialize the JPEG decompression object with default error handling.}
  cinfo.err := jpeg_pascal_error(err);
  jpeg_create_decompress(@cinfo);
  try
    {specify the source of the compressed data}
      jpeg_stream_source(@cinfo, infile);
    {progress monitor}
      jpeg_my_progress(@cinfo, @progress, callback);
    {obtain image info from header, set default decompression parameters}
      jpeg_read_header(@cinfo, TRUE);
    {set parameters for decompression}
      if numcolors <> 0 then begin
        cinfo.desired_number_of_colors := numcolors;
        cinfo.quantize_colors := True;
      end;
      {...}
    {prepare for decompression, initialize internal state}
      dest := jinit_write_bmp(@cinfo, outfile, inmemory);
      jpeg_start_decompress(@cinfo);
    {process data}
      write_bmp_header(@cinfo, dest);
      while (cinfo.output_scanline < cinfo.output_height) do begin
        num_scanlines :=
          jpeg_read_scanlines(@cinfo, dest^.buffer, dest^.buffer_height);
        write_bmp_pixelrow(@cinfo, dest, num_scanlines);
      end;
      write_bmp_image(@cinfo, dest);
    {finish}
      jpeg_finish_decompress(@cinfo);
      jpeg_finish_progress(@cinfo);
  finally
    {destroy}
    jpeg_destroy_decompress(@cinfo);
  end;
end;

{ ------------------------------------------------------------------------ }
{   read BITMAP stream and save as JPEG                                    }
{   for reference: CJPEG.PAS in PASJPG10 library                           }
{ ------------------------------------------------------------------------ }

procedure StoreJPEG(const infile, outfile: TStream; inmemory: boolean;
                    {compression parameters:}
                    quality: integer;
                    {progress monitor}
                    callback: JPEG_ProgressMonitor);
var
  cinfo  : jpeg_compress_struct;
  err    : pascal_error_mgr;
  source : bmp_source_ptr;
  progress : my_progress_mgr;
  num_scanlines : JDIMENSION;
begin
  {$ifdef INMEMORY_FALSE} inmemory:=false; {$endif}

  {initialize the JPEG compression object with default error handling.}
  cinfo.err := jpeg_pascal_error(err);
  jpeg_create_compress(@cinfo);
  try
    {specify the destination for the compressed data}
      jpeg_stream_dest(@cinfo, outfile);
    {set jpeg defaults}
      cinfo.in_color_space := JCS_RGB; {arbitrary guess}
      jpeg_set_defaults(@cinfo);
    {progress monitor}
      jpeg_my_progress(@cinfo, @progress, callback);
    {obtain image info from bitmap header, set default compression parameters}
      source := jinit_read_bmp(@cinfo, infile, inmemory);
      read_bmp_header(@cinfo, source);
    {now we know input colorspace, fix colorspace-dependent defaults}
      jpeg_default_colorspace(@cinfo);
    {set parameters for compression (most likely only quality)}
      jpeg_set_quality(@cinfo, quality, TRUE);
      {...}
    {prepare for compression, initialize internal state}
      jpeg_start_compress(@cinfo, TRUE);
    {process data}
      read_bmp_image(@cinfo, source);
      while (cinfo.next_scanline < cinfo.image_height) do begin
        num_scanlines := read_bmp_pixelrow(@cinfo, source);
        jpeg_write_scanlines(@cinfo, source^.buffer, num_scanlines);
      end;
    {finish}
      jpeg_finish_compress(@cinfo);
      jpeg_finish_progress(@cinfo);
  finally
    {destroy}
    jpeg_destroy_compress(@cinfo);
  end;
end;


procedure SaveJPEG(const infile, outfile: TStream);overload;
begin
StoreJPEG(infile,outfile,False,90,nil);
end;

end.

