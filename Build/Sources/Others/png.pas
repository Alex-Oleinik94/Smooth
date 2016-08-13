{$ifndef NO_SMART_LINK}
{$smartlink on}
{$endif}
{$mode objfpc}
unit png;

interface

{ Automatically converted by H2Pas 0.99.15 from png.h }
{ The following command line parameters were used:
    png.h
}

{$PACKRECORDS C}

uses
 ctypes,
 zlib;

Const
{$ifdef windows}
  LibPng = 'libpng13'; // Library name
  { matching lib version for libpng13.dll, needed for initialization }
  PNG_LIBPNG_VER_STRING='1.2.12';
{$else windows}
  LibPng = 'png'; // Library name
  { matching lib version for libpng, needed for initialization }
  PNG_LIBPNG_VER_STRING='1.2.12';
  {$linklib png}
{$endif windows}

type
   time_t = longint;
   int = longint;
   z_stream = TZStream;
   voidp = pointer;

   png_uint_32 = dword;
   png_int_32 = longint;
   png_uint_16 = word;
   png_int_16 = smallint;
   png_byte = byte;
   ppng_uint_32 = ^png_uint_32;
   ppng_int_32 = ^png_int_32;
   ppng_uint_16 = ^png_uint_16;
   ppng_int_16 = ^png_int_16;
   ppng_byte = ^png_byte;
   pppng_uint_32 = ^ppng_uint_32;
   pppng_int_32 = ^ppng_int_32;
   pppng_uint_16 = ^ppng_uint_16;
   pppng_int_16 = ^ppng_int_16;
   pppng_byte = ^ppng_byte;
   png_size_t = csize_t;
   png_fixed_point = png_int_32;
   ppng_fixed_point = ^png_fixed_point;
   pppng_fixed_point = ^ppng_fixed_point;
   png_voidp = pointer;
   png_bytep = Ppng_byte;
   ppng_bytep = ^png_bytep;
   png_uint_32p = Ppng_uint_32;
   png_int_32p = Ppng_int_32;
   png_uint_16p = Ppng_uint_16;
   ppng_uint_16p = ^png_uint_16p;
   png_int_16p = Ppng_int_16;
(* Const before type ignored *)
   png_const_charp = Pchar;
   png_charp = Pchar;
   ppng_charp = ^png_charp;
   png_fixed_point_p = Ppng_fixed_point;
   TFile = Pointer;
   png_FILE_p = ^FILE;
   png_doublep = Pdouble;
   png_bytepp = PPpng_byte;
   png_uint_32pp = PPpng_uint_32;
   png_int_32pp = PPpng_int_32;
   png_uint_16pp = PPpng_uint_16;
   png_int_16pp = PPpng_int_16;
 (* Const before type ignored *)
   png_const_charpp = PPchar;
   png_charpp = PPchar;
   ppng_charpp = ^png_charpp;
   png_fixed_point_pp = PPpng_fixed_point;
   png_doublepp = PPdouble;
   png_charppp = PPPchar;
   Pcharf = Pchar;
   PPcharf = ^Pcharf;
   png_zcharp = Pcharf;
   png_zcharpp = PPcharf;
   png_zstreamp = Pzstream;


var
{$ifndef darwin}
  png_libpng_ver    : array[0..11] of char;   cvar; external;
  png_pass_start    : array[0..6] of longint; cvar; external;
  png_pass_inc      : array[0..6] of longint; cvar; external;
  png_pass_ystart   : array[0..6] of longint; cvar; external;
  png_pass_yinc     : array[0..6] of longint; cvar; external;
  png_pass_mask     : array[0..6] of longint; cvar; external;
  png_pass_dsp_mask : array[0..6] of longint; cvar; external;
{$else darwin}
  png_libpng_ver    : array[0..11] of char;   external LibPng name 'png_libpng_ver';
  png_pass_start    : array[0..6] of longint; external LibPng name 'png_pass_start';
  png_pass_inc      : array[0..6] of longint; external LibPng name 'png_pass_inc';
  png_pass_ystart   : array[0..6] of longint; external LibPng name 'png_pass_ystart';
  png_pass_yinc     : array[0..6] of longint; external LibPng name 'png_pass_yinc';
  png_pass_mask     : array[0..6] of longint; external LibPng name 'png_pass_mask';
  png_pass_dsp_mask : array[0..6] of longint; external LibPng name 'png_pass_dsp_mask';
{$endif darwin}

Type
  png_color = record
       red : png_byte;
       green : png_byte;
       blue : png_byte;
    end;
  ppng_color = ^png_color;
  pppng_color = ^ppng_color;

  png_color_struct = png_color;
  png_colorp = Ppng_color;
  ppng_colorp = ^png_colorp;
  png_colorpp = PPpng_color;
  png_color_16 = record
       index : png_byte;
       red : png_uint_16;
       green : png_uint_16;
       blue : png_uint_16;
       gray : png_uint_16;
    end;
  ppng_color_16 = ^png_color_16 ;
  pppng_color_16 = ^ppng_color_16 ;
  png_color_16_struct = png_color_16;
  png_color_16p = Ppng_color_16;
  ppng_color_16p = ^png_color_16p;
  png_color_16pp = PPpng_color_16;
  png_color_8 = record
       red : png_byte;
       green : png_byte;
       blue : png_byte;
       gray : png_byte;
       alpha : png_byte;
    end;
  ppng_color_8 = ^png_color_8;
  pppng_color_8 = ^ppng_color_8;
  png_color_8_struct = png_color_8;
  png_color_8p = Ppng_color_8;
  ppng_color_8p = ^png_color_8p;
  png_color_8pp = PPpng_color_8;
  png_sPLT_entry = record
       red : png_uint_16;
       green : png_uint_16;
       blue : png_uint_16;
       alpha : png_uint_16;
       frequency : png_uint_16;
    end;
  ppng_sPLT_entry = ^png_sPLT_entry;
  pppng_sPLT_entry = ^ppng_sPLT_entry;
  png_sPLT_entry_struct = png_sPLT_entry;
  png_sPLT_entryp = Ppng_sPLT_entry;
  png_sPLT_entrypp = PPpng_sPLT_entry;
  png_sPLT_t = record
       name : png_charp;
       depth : png_byte;
       entries : png_sPLT_entryp;
       nentries : png_int_32;
    end;
  ppng_sPLT_t = ^png_sPLT_t;
  pppng_sPLT_t = ^ppng_sPLT_t;
  png_sPLT_struct = png_sPLT_t;
  png_sPLT_tp = Ppng_sPLT_t;
  png_sPLT_tpp = PPpng_sPLT_t;
  png_text = record
       compression : longint;
       key : png_charp;
       text : png_charp;
       text_length : png_size_t;
    end;
  ppng_text = ^png_text;
  pppng_text = ^ppng_text;

  png_text_struct = png_text;
  png_textp = Ppng_text;
  ppng_textp = ^png_textp;
  png_textpp = PPpng_text;
  png_time = record
       year : png_uint_16;
       month : png_byte;
       day : png_byte;
       hour : png_byte;
       minute : png_byte;
       second : png_byte;
    end;
  ppng_time = ^png_time;
  pppng_time = ^ppng_time;

  png_time_struct = png_time;
  png_timep = Ppng_time;
  PPNG_TIMEP = ^PNG_TIMEP;
  png_timepp = PPpng_time;
  png_unknown_chunk = record
       name : array[0..4] of png_byte;
       data : Ppng_byte;
       size : png_size_t;
       location : png_byte;
    end;
  ppng_unknown_chunk = ^png_unknown_chunk;
  pppng_unknown_chunk = ^ppng_unknown_chunk;

  png_unknown_chunk_t = png_unknown_chunk;
  png_unknown_chunkp = Ppng_unknown_chunk;
  png_unknown_chunkpp = PPpng_unknown_chunk;
  png_info = record
       width : png_uint_32;
       height : png_uint_32;
       valid : png_uint_32;
       rowbytes : png_uint_32;
       palette : png_colorp;
       num_palette : png_uint_16;
       num_trans : png_uint_16;
       bit_depth : png_byte;
       color_type : png_byte;
       compression_type : png_byte;
       filter_type : png_byte;
       interlace_type : png_byte;
       channels : png_byte;
       pixel_depth : png_byte;
       spare_byte : png_byte;
       signature : array[0..7] of png_byte;
       gamma : double;
       srgb_intent : png_byte;
       num_text : longint;
       max_text : longint;
       text : png_textp;
       mod_time : png_time;
       sig_bit : png_color_8;
       trans : png_bytep;
       trans_values : png_color_16;
       background : png_color_16;
       x_offset : png_int_32;
       y_offset : png_int_32;
       offset_unit_type : png_byte;
       x_pixels_per_unit : png_uint_32;
       y_pixels_per_unit : png_uint_32;
       phys_unit_type : png_byte;
       hist : png_uint_16p;
       x_white : double;
       y_white : double;
       x_red : double;
       y_red : double;
       x_green : double;
       y_green : double;
       x_blue : double;
       y_blue : double;
       pcal_purpose : png_charp;
       pcal_X0 : png_int_32;
       pcal_X1 : png_int_32;
       pcal_units : png_charp;
       pcal_params : png_charpp;
       pcal_type : png_byte;
       pcal_nparams : png_byte;
       free_me : png_uint_32;
       unknown_chunks : png_unknown_chunkp;
       unknown_chunks_num : png_size_t;
       iccp_name : png_charp;
       iccp_profile : png_charp;
       iccp_proflen : png_uint_32;
       iccp_compression : png_byte;
       splt_palettes : png_sPLT_tp;
       splt_palettes_num : png_uint_32;
       scal_unit : png_byte;
       scal_pixel_width : double;
       scal_pixel_height : double;
       scal_s_width : png_charp;
       scal_s_height : png_charp;
       row_pointers : png_bytepp;
       int_gamma : png_fixed_point;
       int_x_white : png_fixed_point;
       int_y_white : png_fixed_point;
       int_x_red : png_fixed_point;
       int_y_red : png_fixed_point;
       int_x_green : png_fixed_point;
       int_y_green : png_fixed_point;
       int_x_blue : png_fixed_point;
       int_y_blue : png_fixed_point;
    end;
  ppng_info = ^png_info;
  pppng_info = ^ppng_info;

  png_info_struct = png_info;
  png_infop = Ppng_info;
  png_infopp = PPpng_info;
  png_row_info = record
       width : png_uint_32;
       rowbytes : png_uint_32;
       color_type : png_byte;
       bit_depth : png_byte;
       channels : png_byte;
       pixel_depth : png_byte;
    end;
  ppng_row_info = ^png_row_info;
  pppng_row_info = ^ppng_row_info;

  png_row_info_struct = png_row_info;
  png_row_infop = Ppng_row_info;
  png_row_infopp = PPpng_row_info;
//  png_struct_def = png_struct;
  png_structp = ^png_struct;



png_error_ptr = Procedure(Arg1 : png_structp; Arg2 : png_const_charp);cdecl;
png_rw_ptr = Procedure(Arg1 : png_structp; Arg2 : png_bytep; Arg3 : png_size_t);cdecl;
png_flush_ptr = procedure (Arg1 : png_structp) ;cdecl;
png_read_status_ptr = procedure (Arg1 : png_structp; Arg2 : png_uint_32; Arg3: int);cdecl;
png_write_status_ptr = Procedure (Arg1 : png_structp; Arg2:png_uint_32;Arg3 : int) ;cdecl;
png_progressive_info_ptr = Procedure (Arg1 : png_structp; Arg2 : png_infop) ;cdecl;
png_progressive_end_ptr = Procedure (Arg1 : png_structp; Arg2 : png_infop) ;cdecl;
png_progressive_row_ptr = Procedure (Arg1 : png_structp; Arg2 : png_bytep; Arg3 : png_uint_32; Arg4 : int) ;cdecl;
png_user_transform_ptr = Procedure (Arg1 : png_structp; Arg2 : png_row_infop; Arg3 : png_bytep) ;cdecl;
png_user_chunk_ptr = Function (Arg1 : png_structp; Arg2 : png_unknown_chunkp): longint;cdecl;
png_unknown_chunk_ptr = Procedure (Arg1 : png_structp);cdecl;
png_malloc_ptr = Function (Arg1 : png_structp; Arg2 : png_size_t) : png_voidp ;cdecl;
png_free_ptr = Procedure (Arg1 : png_structp; Arg2 : png_voidp) ; cdecl;

   png_struct_def = record
        jmpbuf : jmp_buf;
        error_fn : png_error_ptr;
        warning_fn : png_error_ptr;
        error_ptr : png_voidp;
        write_data_fn : png_rw_ptr;
        read_data_fn : png_rw_ptr;
        io_ptr : png_voidp;
        read_user_transform_fn : png_user_transform_ptr;
        write_user_transform_fn : png_user_transform_ptr;
        user_transform_ptr : png_voidp;
        user_transform_depth : png_byte;
        user_transform_channels : png_byte;
        mode : png_uint_32;
        flags : png_uint_32;
        transformations : png_uint_32;
        zstream : z_stream;
        zbuf : png_bytep;
        zbuf_size : png_size_t;
        zlib_level : longint;
        zlib_method : longint;
        zlib_window_bits : longint;
        zlib_mem_level : longint;
        zlib_strategy : longint;
        width : png_uint_32;
        height : png_uint_32;
        num_rows : png_uint_32;
        usr_width : png_uint_32;
        rowbytes : png_uint_32;
        irowbytes : png_uint_32;
        iwidth : png_uint_32;
        row_number : png_uint_32;
        prev_row : png_bytep;
        row_buf : png_bytep;
        sub_row : png_bytep;
        up_row : png_bytep;
        avg_row : png_bytep;
        paeth_row : png_bytep;
        row_info : png_row_info;
        idat_size : png_uint_32;
        crc : png_uint_32;
        palette : png_colorp;
        num_palette : png_uint_16;
        num_trans : png_uint_16;
        chunk_name : array[0..4] of png_byte;
        compression : png_byte;
        filter : png_byte;
        interlaced : png_byte;
        pass : png_byte;
        do_filter : png_byte;
        color_type : png_byte;
        bit_depth : png_byte;
        usr_bit_depth : png_byte;
        pixel_depth : png_byte;
        channels : png_byte;
        usr_channels : png_byte;
        sig_bytes : png_byte;
        filler : png_uint_16;
        background_gamma_type : png_byte;
        background_gamma : double;
        background : png_color_16;
        background_1 : png_color_16;
        output_flush_fn : png_flush_ptr;
        flush_dist : png_uint_32;
        flush_rows : png_uint_32;
        gamma_shift : longint;
        gamma : double;
        screen_gamma : double;
        gamma_table : png_bytep;
        gamma_from_1 : png_bytep;
        gamma_to_1 : png_bytep;
        gamma_16_table : png_uint_16pp;
        gamma_16_from_1 : png_uint_16pp;
        gamma_16_to_1 : png_uint_16pp;
        sig_bit : png_color_8;
        shift : png_color_8;
        trans : png_bytep;
        trans_values : png_color_16;
        read_row_fn : png_read_status_ptr;
        write_row_fn : png_write_status_ptr;
        info_fn : png_progressive_info_ptr;
        row_fn : png_progressive_row_ptr;
        end_fn : png_progressive_end_ptr;
        save_buffer_ptr : png_bytep;
        save_buffer : png_bytep;
        current_buffer_ptr : png_bytep;
        current_buffer : png_bytep;
        push_length : png_uint_32;
        skip_length : png_uint_32;
        save_buffer_size : png_size_t;
        save_buffer_max : png_size_t;
        buffer_size : png_size_t;
        current_buffer_size : png_size_t;
        process_mode : longint;
        cur_palette : longint;
        current_text_size : png_size_t;
        current_text_left : png_size_t;
        current_text : png_charp;
        current_text_ptr : png_charp;
        palette_lookup : png_bytep;
        dither_index : png_bytep;
        hist : png_uint_16p;
        heuristic_method : png_byte;
        num_prev_filters : png_byte;
        prev_filters : png_bytep;
        filter_weights : png_uint_16p;
        inv_filter_weights : png_uint_16p;
        filter_costs : png_uint_16p;
        inv_filter_costs : png_uint_16p;
        time_buffer : png_charp;
        free_me : png_uint_32;
        user_chunk_ptr : png_voidp;
        read_user_chunk_fn : png_user_chunk_ptr;
        num_chunk_list : longint;
        chunk_list : png_bytep;
        rgb_to_gray_status : png_byte;
        rgb_to_gray_red_coeff : png_uint_16;
        rgb_to_gray_green_coeff : png_uint_16;
        rgb_to_gray_blue_coeff : png_uint_16;
        empty_plte_permitted : png_byte;
        int_gamma : png_fixed_point;
     end;
   ppng_struct_def = ^png_struct_def;
   pppng_struct_def = ^ppng_struct_def;
   png_struct = png_struct_def;
   ppng_struct = ^png_struct;
   pppng_struct = ^ppng_struct;

   version_1_0_8 = png_structp;
   png_structpp = PPpng_struct;
(*

function png_access_version_number():png_uint_32;cdecl; external LibPng;
*)
var png_access_version_number : function( ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_sig_bytes(png_ptr:png_structp; num_bytes:longint);cdecl; external LibPng;
*)
var png_set_sig_bytes : procedure( png_ptr : png_structp ; num_bytes : longint ) ; cdecl ; 

(*
function png_sig_cmp(sig:png_bytep; start:png_size_t; num_to_check:png_size_t):longint;cdecl; external LibPng;
*)
var png_sig_cmp : function( sig : png_bytep ; start : png_size_t ; num_to_check : png_size_t ) : longint ; cdecl ; 

(*
function png_check_sig(sig:png_bytep; num:longint):longint;cdecl; external LibPng;
*)
var png_check_sig : function( sig : png_bytep ; num : longint ) : longint ; cdecl ; 

(*
function png_create_read_struct(user_png_ver:png_const_charp; error_ptr:png_voidp; error_fn:png_error_ptr; warn_fn:png_error_ptr):png_structp;cdecl; external LibPng;
*)
var png_create_read_struct : function( user_png_ver : png_const_charp ; error_ptr : png_voidp ; error_fn : png_error_ptr ; warn_fn : png_error_ptr ) : png_structp ; cdecl ; 

(*
function png_create_write_struct(user_png_ver:png_const_charp; error_ptr:png_voidp; error_fn:png_error_ptr; warn_fn:png_error_ptr):png_structp;cdecl; external LibPng;
*)
var png_create_write_struct : function( user_png_ver : png_const_charp ; error_ptr : png_voidp ; error_fn : png_error_ptr ; warn_fn : png_error_ptr ) : png_structp ; cdecl ; 

(*
function png_get_compression_buffer_size(png_ptr:png_structp):png_uint_32;cdecl; external LibPng;
*)
var png_get_compression_buffer_size : function( png_ptr : png_structp ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_compression_buffer_size(png_ptr:png_structp; size:png_uint_32);cdecl; external LibPng;
*)
var png_set_compression_buffer_size : procedure( png_ptr : png_structp ; size : png_uint_32 ) ; cdecl ; 

(*
function png_reset_zstream(png_ptr:png_structp):longint;cdecl; external LibPng;
*)
var png_reset_zstream : function( png_ptr : png_structp ) : longint ; cdecl ; 

(*
procedure png_write_chunk(png_ptr:png_structp; chunk_name:png_bytep; data:png_bytep; length:png_size_t);cdecl; external LibPng;
*)
var png_write_chunk : procedure( png_ptr : png_structp ; chunk_name : png_bytep ; data : png_bytep ; length : png_size_t ) ; cdecl ; 

(*
procedure png_write_chunk_start(png_ptr:png_structp; chunk_name:png_bytep; length:png_uint_32);cdecl; external LibPng;
*)
var png_write_chunk_start : procedure( png_ptr : png_structp ; chunk_name : png_bytep ; length : png_uint_32 ) ; cdecl ; 

(*
procedure png_write_chunk_data(png_ptr:png_structp; data:png_bytep; length:png_size_t);cdecl; external LibPng;
*)
var png_write_chunk_data : procedure( png_ptr : png_structp ; data : png_bytep ; length : png_size_t ) ; cdecl ; 

(*
procedure png_write_chunk_end(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_write_chunk_end : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
function png_create_info_struct(png_ptr:png_structp):png_infop;cdecl; external LibPng;
*)
var png_create_info_struct : function( png_ptr : png_structp ) : png_infop ; cdecl ; 

(*
procedure png_info_init(info_ptr:png_infop);cdecl; external LibPng;
*)
var png_info_init : procedure( info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_write_info_before_PLTE(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
*)
var png_write_info_before_PLTE : procedure( png_ptr : png_structp ; info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_write_info(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
*)
var png_write_info : procedure( png_ptr : png_structp ; info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_read_info(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
*)
var png_read_info : procedure( png_ptr : png_structp ; info_ptr : png_infop ) ; cdecl ; 

(*
function png_convert_to_rfc1123(png_ptr:png_structp; ptime:png_timep):png_charp;cdecl; external LibPng;
*)
var png_convert_to_rfc1123 : function( png_ptr : png_structp ; ptime : png_timep ) : png_charp ; cdecl ; 

(*
procedure png_convert_from_struct_tm(ptime:png_timep; ttime:Pointer);cdecl; external LibPng;
*)
var png_convert_from_struct_tm : procedure( ptime : png_timep ; ttime : Pointer ) ; cdecl ; 

(*
procedure png_convert_from_time_t(ptime:png_timep; ttime:time_t);cdecl; external LibPng;
*)
var png_convert_from_time_t : procedure( ptime : png_timep ; ttime : time_t ) ; cdecl ; 

(*
procedure png_set_expand(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_expand : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_gray_1_2_4_to_8(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_gray_1_2_4_to_8 : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_palette_to_rgb(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_palette_to_rgb : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_tRNS_to_alpha(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_tRNS_to_alpha : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_bgr(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_bgr : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_gray_to_rgb(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_gray_to_rgb : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_rgb_to_gray(png_ptr:png_structp; error_action:longint; red:double; green:double);cdecl; external LibPng;
*)
var png_set_rgb_to_gray : procedure( png_ptr : png_structp ; error_action : longint ; red : double ; green : double ) ; cdecl ; 

(*
procedure png_set_rgb_to_gray_fixed(png_ptr:png_structp; error_action:longint; red:png_fixed_point; green:png_fixed_point);cdecl; external LibPng;
*)
var png_set_rgb_to_gray_fixed : procedure( png_ptr : png_structp ; error_action : longint ; red : png_fixed_point ; green : png_fixed_point ) ; cdecl ; 

(*
function png_get_rgb_to_gray_status(png_ptr:png_structp):png_byte;cdecl; external LibPng;
*)
var png_get_rgb_to_gray_status : function( png_ptr : png_structp ) : png_byte ; cdecl ; 

(*
procedure png_build_grayscale_palette(bit_depth:longint; palette:png_colorp);cdecl; external LibPng;
*)
var png_build_grayscale_palette : procedure( bit_depth : longint ; palette : png_colorp ) ; cdecl ; 

(*
procedure png_set_strip_alpha(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_strip_alpha : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_swap_alpha(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_swap_alpha : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_invert_alpha(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_invert_alpha : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_filler(png_ptr:png_structp; filler:png_uint_32; flags:longint);cdecl; external LibPng;
*)
var png_set_filler : procedure( png_ptr : png_structp ; filler : png_uint_32 ; flags : longint ) ; cdecl ; 

(*
procedure png_set_swap(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_swap : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_packing(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_packing : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_packswap(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_packswap : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_shift(png_ptr:png_structp; true_bits:png_color_8p);cdecl; external LibPng;
*)
var png_set_shift : procedure( png_ptr : png_structp ; true_bits : png_color_8p ) ; cdecl ; 

(*
function png_set_interlace_handling(png_ptr:png_structp):longint;cdecl; external LibPng;
*)
var png_set_interlace_handling : function( png_ptr : png_structp ) : longint ; cdecl ; 

(*
procedure png_set_invert_mono(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_invert_mono : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_background(png_ptr:png_structp; background_color:png_color_16p; background_gamma_code:longint; need_expand:longint; background_gamma:double);cdecl; external LibPng;
*)
var png_set_background : procedure( png_ptr : png_structp ; background_color : png_color_16p ; background_gamma_code : longint ; need_expand : longint ; background_gamma : double ) ; cdecl ; 

(*
procedure png_set_strip_16(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_set_strip_16 : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_dither(png_ptr:png_structp; palette:png_colorp; num_palette:longint; maximum_colors:longint; histogram:png_uint_16p;
            full_dither:longint);cdecl; external LibPng;
*)
var png_set_dither : procedure( png_ptr : png_structp ; palette : png_colorp ; num_palette : longint ; maximum_colors : longint ; histogram : png_uint_16p ; full_dither : longint ) ; cdecl ; 

(*
procedure png_set_gamma(png_ptr:png_structp; screen_gamma:double; default_file_gamma:double);cdecl; external LibPng;
*)
var png_set_gamma : procedure( png_ptr : png_structp ; screen_gamma : double ; default_file_gamma : double ) ; cdecl ; 

(*
procedure png_permit_empty_plte(png_ptr:png_structp; empty_plte_permitted:longint);cdecl; external LibPng;
*)
var png_permit_empty_plte : procedure( png_ptr : png_structp ; empty_plte_permitted : longint ) ; cdecl ; 

(*
procedure png_set_flush(png_ptr:png_structp; nrows:longint);cdecl; external LibPng;
*)
var png_set_flush : procedure( png_ptr : png_structp ; nrows : longint ) ; cdecl ; 

(*
procedure png_write_flush(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_write_flush : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_start_read_image(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_start_read_image : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_read_update_info(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
*)
var png_read_update_info : procedure( png_ptr : png_structp ; info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_read_rows(png_ptr:png_structp; row:png_bytepp; display_row:png_bytepp; num_rows:png_uint_32);cdecl; external LibPng;
*)
var png_read_rows : procedure( png_ptr : png_structp ; row : png_bytepp ; display_row : png_bytepp ; num_rows : png_uint_32 ) ; cdecl ; 

(*
procedure png_read_row(png_ptr:png_structp; row:png_bytep; display_row:png_bytep);cdecl; external LibPng;
*)
var png_read_row : procedure( png_ptr : png_structp ; row : png_bytep ; display_row : png_bytep ) ; cdecl ; 

(*
procedure png_read_image(png_ptr:png_structp; image:png_bytepp);cdecl; external LibPng;
*)
var png_read_image : procedure( png_ptr : png_structp ; image : png_bytepp ) ; cdecl ; 

(*
procedure png_write_row(png_ptr:png_structp; row:png_bytep);cdecl; external LibPng;
*)
var png_write_row : procedure( png_ptr : png_structp ; row : png_bytep ) ; cdecl ; 

(*
procedure png_write_rows(png_ptr:png_structp; row:png_bytepp; num_rows:png_uint_32);cdecl; external LibPng;
*)
var png_write_rows : procedure( png_ptr : png_structp ; row : png_bytepp ; num_rows : png_uint_32 ) ; cdecl ; 

(*
procedure png_write_image(png_ptr:png_structp; image:png_bytepp);cdecl; external LibPng;
*)
var png_write_image : procedure( png_ptr : png_structp ; image : png_bytepp ) ; cdecl ; 

(*
procedure png_write_end(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
*)
var png_write_end : procedure( png_ptr : png_structp ; info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_read_end(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
*)
var png_read_end : procedure( png_ptr : png_structp ; info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_destroy_info_struct(png_ptr:png_structp; info_ptr_ptr:png_infopp);cdecl; external LibPng;
*)
var png_destroy_info_struct : procedure( png_ptr : png_structp ; info_ptr_ptr : png_infopp ) ; cdecl ; 

(*
procedure png_destroy_read_struct(png_ptr_ptr:png_structpp; info_ptr_ptr:png_infopp; end_info_ptr_ptr:png_infopp);cdecl; external LibPng;
*)
var png_destroy_read_struct : procedure( png_ptr_ptr : png_structpp ; info_ptr_ptr : png_infopp ; end_info_ptr_ptr : png_infopp ) ; cdecl ; 

(*
procedure png_read_destroy(png_ptr:png_structp; info_ptr:png_infop; end_info_ptr:png_infop);cdecl; external LibPng;
*)
var png_read_destroy : procedure( png_ptr : png_structp ; info_ptr : png_infop ; end_info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_destroy_write_struct(png_ptr_ptr:png_structpp; info_ptr_ptr:png_infopp);cdecl; external LibPng;
*)
var png_destroy_write_struct : procedure( png_ptr_ptr : png_structpp ; info_ptr_ptr : png_infopp ) ; cdecl ; 

(*
procedure png_write_destroy_info(info_ptr:png_infop);cdecl; external LibPng;
*)
var png_write_destroy_info : procedure( info_ptr : png_infop ) ; cdecl ; 

(*
procedure png_write_destroy(png_ptr:png_structp);cdecl; external LibPng;
*)
var png_write_destroy : procedure( png_ptr : png_structp ) ; cdecl ; 

(*
procedure png_set_crc_action(png_ptr:png_structp; crit_action:longint; ancil_action:longint);cdecl; external LibPng;
*)
var png_set_crc_action : procedure( png_ptr : png_structp ; crit_action : longint ; ancil_action : longint ) ; cdecl ; 

(*
procedure png_set_filter(png_ptr:png_structp; method:longint; filters:longint);cdecl; external LibPng;
*)
var png_set_filter : procedure( png_ptr : png_structp ; method : longint ; filters : longint ) ; cdecl ; 

(*
procedure png_set_filter_heuristics(png_ptr:png_structp; heuristic_method:longint; num_weights:longint; filter_weights:png_doublep; filter_costs:png_doublep);cdecl; external LibPng;
*)
var png_set_filter_heuristics : procedure( png_ptr : png_structp ; heuristic_method : longint ; num_weights : longint ; filter_weights : png_doublep ; filter_costs : png_doublep ) ; cdecl ; 

(*
procedure png_set_compression_level(png_ptr:png_structp; level:longint);cdecl; external LibPng;
*)
var png_set_compression_level : procedure( png_ptr : png_structp ; level : longint ) ; cdecl ; 

(*
procedure png_set_compression_mem_level(png_ptr:png_structp; mem_level:longint);cdecl; external LibPng;
*)
var png_set_compression_mem_level : procedure( png_ptr : png_structp ; mem_level : longint ) ; cdecl ; 

(*
procedure png_set_compression_strategy(png_ptr:png_structp; strategy:longint);cdecl; external LibPng;
*)
var png_set_compression_strategy : procedure( png_ptr : png_structp ; strategy : longint ) ; cdecl ; 

(*
procedure png_set_compression_window_bits(png_ptr:png_structp; window_bits:longint);cdecl; external LibPng;
*)
var png_set_compression_window_bits : procedure( png_ptr : png_structp ; window_bits : longint ) ; cdecl ; 

(*
procedure png_set_compression_method(png_ptr:png_structp; method:longint);cdecl; external LibPng;
*)
var png_set_compression_method : procedure( png_ptr : png_structp ; method : longint ) ; cdecl ; 

(*
procedure png_init_io(png_ptr:png_structp; fp:png_FILE_p);cdecl; external LibPng;
*)
var png_init_io : procedure( png_ptr : png_structp ; fp : png_FILE_p ) ; cdecl ; 

(*
procedure png_set_error_fn(png_ptr:png_structp; error_ptr:png_voidp; error_fn:png_error_ptr; warning_fn:png_error_ptr);cdecl; external LibPng;
*)
var png_set_error_fn : procedure( png_ptr : png_structp ; error_ptr : png_voidp ; error_fn : png_error_ptr ; warning_fn : png_error_ptr ) ; cdecl ; 

(*
function png_get_error_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
*)
var png_get_error_ptr : function( png_ptr : png_structp ) : png_voidp ; cdecl ; 

(*
procedure png_set_write_fn(png_ptr:png_structp; io_ptr:png_voidp; write_data_fn:png_rw_ptr; output_flush_fn:png_flush_ptr);cdecl; external LibPng;
*)
var png_set_write_fn : procedure( png_ptr : png_structp ; io_ptr : png_voidp ; write_data_fn : png_rw_ptr ; output_flush_fn : png_flush_ptr ) ; cdecl ; 

(*
procedure png_set_read_fn(png_ptr:png_structp; io_ptr:png_voidp; read_data_fn:png_rw_ptr);cdecl; external LibPng;
*)
var png_set_read_fn : procedure( png_ptr : png_structp ; io_ptr : png_voidp ; read_data_fn : png_rw_ptr ) ; cdecl ; 

(*
function png_get_io_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
*)
var png_get_io_ptr : function( png_ptr : png_structp ) : png_voidp ; cdecl ; 

(*
procedure png_set_read_status_fn(png_ptr:png_structp; read_row_fn:png_read_status_ptr);cdecl; external LibPng;
*)
var png_set_read_status_fn : procedure( png_ptr : png_structp ; read_row_fn : png_read_status_ptr ) ; cdecl ; 

(*
procedure png_set_write_status_fn(png_ptr:png_structp; write_row_fn:png_write_status_ptr);cdecl; external LibPng;
*)
var png_set_write_status_fn : procedure( png_ptr : png_structp ; write_row_fn : png_write_status_ptr ) ; cdecl ; 

(*
procedure png_set_read_user_transform_fn(png_ptr:png_structp; read_user_transform_fn:png_user_transform_ptr);cdecl; external LibPng;
*)
var png_set_read_user_transform_fn : procedure( png_ptr : png_structp ; read_user_transform_fn : png_user_transform_ptr ) ; cdecl ; 

(*
procedure png_set_write_user_transform_fn(png_ptr:png_structp; write_user_transform_fn:png_user_transform_ptr);cdecl; external LibPng;
*)
var png_set_write_user_transform_fn : procedure( png_ptr : png_structp ; write_user_transform_fn : png_user_transform_ptr ) ; cdecl ; 

(*
procedure png_set_user_transform_info(png_ptr:png_structp; user_transform_ptr:png_voidp; user_transform_depth:longint; user_transform_channels:longint);cdecl; external LibPng;
*)
var png_set_user_transform_info : procedure( png_ptr : png_structp ; user_transform_ptr : png_voidp ; user_transform_depth : longint ; user_transform_channels : longint ) ; cdecl ; 

(*
function png_get_user_transform_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
*)
var png_get_user_transform_ptr : function( png_ptr : png_structp ) : png_voidp ; cdecl ; 

(*
procedure png_set_read_user_chunk_fn(png_ptr:png_structp; user_chunk_ptr:png_voidp; read_user_chunk_fn:png_user_chunk_ptr);cdecl; external LibPng;
*)
var png_set_read_user_chunk_fn : procedure( png_ptr : png_structp ; user_chunk_ptr : png_voidp ; read_user_chunk_fn : png_user_chunk_ptr ) ; cdecl ; 

(*
function png_get_user_chunk_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
*)
var png_get_user_chunk_ptr : function( png_ptr : png_structp ) : png_voidp ; cdecl ; 

(*
procedure png_set_progressive_read_fn(png_ptr:png_structp; progressive_ptr:png_voidp; info_fn:png_progressive_info_ptr; row_fn:png_progressive_row_ptr; end_fn:png_progressive_end_ptr);cdecl; external LibPng;
*)
var png_set_progressive_read_fn : procedure( png_ptr : png_structp ; progressive_ptr : png_voidp ; info_fn : png_progressive_info_ptr ; row_fn : png_progressive_row_ptr ; end_fn : png_progressive_end_ptr ) ; cdecl ; 

(*
function png_get_progressive_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
*)
var png_get_progressive_ptr : function( png_ptr : png_structp ) : png_voidp ; cdecl ; 

(*
procedure png_process_data(png_ptr:png_structp; info_ptr:png_infop; buffer:png_bytep; buffer_size:png_size_t);cdecl; external LibPng;
*)
var png_process_data : procedure( png_ptr : png_structp ; info_ptr : png_infop ; buffer : png_bytep ; buffer_size : png_size_t ) ; cdecl ; 

(*
procedure png_progressive_combine_row(png_ptr:png_structp; old_row:png_bytep; new_row:png_bytep);cdecl; external LibPng;
*)
var png_progressive_combine_row : procedure( png_ptr : png_structp ; old_row : png_bytep ; new_row : png_bytep ) ; cdecl ; 

(*
function png_malloc(png_ptr:png_structp; size:png_uint_32):png_voidp;cdecl; external LibPng;
*)
var png_malloc : function( png_ptr : png_structp ; size : png_uint_32 ) : png_voidp ; cdecl ; 

(*
procedure png_free(png_ptr:png_structp; ptr:png_voidp);cdecl; external LibPng;
*)
var png_free : procedure( png_ptr : png_structp ; ptr : png_voidp ) ; cdecl ; 

(*
procedure png_free_data(png_ptr:png_structp; info_ptr:png_infop; free_me:png_uint_32; num:longint);cdecl; external LibPng;
*)
var png_free_data : procedure( png_ptr : png_structp ; info_ptr : png_infop ; free_me : png_uint_32 ; num : longint ) ; cdecl ; 

(*
procedure png_data_freer(png_ptr:png_structp; info_ptr:png_infop; freer:longint; mask:png_uint_32);cdecl; external LibPng;
*)
var png_data_freer : procedure( png_ptr : png_structp ; info_ptr : png_infop ; freer : longint ; mask : png_uint_32 ) ; cdecl ; 

(*
function png_memcpy_check(png_ptr:png_structp; s1:png_voidp; s2:png_voidp; size:png_uint_32):png_voidp;cdecl; external LibPng;
*)
var png_memcpy_check : function( png_ptr : png_structp ; s1 : png_voidp ; s2 : png_voidp ; size : png_uint_32 ) : png_voidp ; cdecl ; 

(*
function png_memset_check(png_ptr:png_structp; s1:png_voidp; value:longint; size:png_uint_32):png_voidp;cdecl; external LibPng;
*)
var png_memset_check : function( png_ptr : png_structp ; s1 : png_voidp ; value : longint ; size : png_uint_32 ) : png_voidp ; cdecl ; 

(*
procedure png_error(png_ptr:png_structp; error:png_const_charp);cdecl; external LibPng;
*)
var png_error : procedure( png_ptr : png_structp ; error : png_const_charp ) ; cdecl ; 

(*
procedure png_chunk_error(png_ptr:png_structp; error:png_const_charp);cdecl; external LibPng;
*)
var png_chunk_error : procedure( png_ptr : png_structp ; error : png_const_charp ) ; cdecl ; 

(*
procedure png_warning(png_ptr:png_structp; message:png_const_charp);cdecl; external LibPng;
*)
var png_warning : procedure( png_ptr : png_structp ; message : png_const_charp ) ; cdecl ; 

(*
procedure png_chunk_warning(png_ptr:png_structp; message:png_const_charp);cdecl; external LibPng;
*)
var png_chunk_warning : procedure( png_ptr : png_structp ; message : png_const_charp ) ; cdecl ; 

(*
function png_get_valid(png_ptr:png_structp; info_ptr:png_infop; flag:png_uint_32):png_uint_32;cdecl; external LibPng;
*)
var png_get_valid : function( png_ptr : png_structp ; info_ptr : png_infop ; flag : png_uint_32 ) : png_uint_32 ; cdecl ; 

(*
function png_get_rowbytes(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
*)
var png_get_rowbytes : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_uint_32 ; cdecl ; 

(*
function png_get_rows(png_ptr:png_structp; info_ptr:png_infop):png_bytepp;cdecl; external LibPng;
*)
var png_get_rows : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_bytepp ; cdecl ; 

(*
procedure png_set_rows(png_ptr:png_structp; info_ptr:png_infop; row_pointers:png_bytepp);cdecl; external LibPng;
*)
var png_set_rows : procedure( png_ptr : png_structp ; info_ptr : png_infop ; row_pointers : png_bytepp ) ; cdecl ; 

(*
function png_get_channels(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
*)
var png_get_channels : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_byte ; cdecl ; 

(*
function png_get_image_width(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
*)
var png_get_image_width : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_uint_32 ; cdecl ; 

(*
function png_get_image_height(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
*)
var png_get_image_height : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_uint_32 ; cdecl ; 

(*
function png_get_bit_depth(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
*)
var png_get_bit_depth : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_byte ; cdecl ; 

(*
function png_get_color_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
*)
var png_get_color_type : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_byte ; cdecl ; 

(*
function png_get_filter_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
*)
var png_get_filter_type : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_byte ; cdecl ; 

(*
function png_get_interlace_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
*)
var png_get_interlace_type : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_byte ; cdecl ; 

(*
function png_get_compression_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
*)
var png_get_compression_type : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_byte ; cdecl ; 

(*
function png_get_pixels_per_meter(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
*)
var png_get_pixels_per_meter : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_uint_32 ; cdecl ; 

(*
function png_get_x_pixels_per_meter(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
*)
var png_get_x_pixels_per_meter : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_uint_32 ; cdecl ; 

(*
function png_get_y_pixels_per_meter(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
*)
var png_get_y_pixels_per_meter : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_uint_32 ; cdecl ; 

(*
function png_get_pixel_aspect_ratio(png_ptr:png_structp; info_ptr:png_infop):double;cdecl; external LibPng;
*)
var png_get_pixel_aspect_ratio : function( png_ptr : png_structp ; info_ptr : png_infop ) : double ; cdecl ; 

(*
function png_get_x_offset_pixels(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
*)
var png_get_x_offset_pixels : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_int_32 ; cdecl ; 

(*
function png_get_y_offset_pixels(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
*)
var png_get_y_offset_pixels : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_int_32 ; cdecl ; 

(*
function png_get_x_offset_microns(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
*)
var png_get_x_offset_microns : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_int_32 ; cdecl ; 

(*
function png_get_y_offset_microns(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
*)
var png_get_y_offset_microns : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_int_32 ; cdecl ; 

(*
function png_get_signature(png_ptr:png_structp; info_ptr:png_infop):png_bytep;cdecl; external LibPng;
*)
var png_get_signature : function( png_ptr : png_structp ; info_ptr : png_infop ) : png_bytep ; cdecl ; 

(*
function png_get_bKGD(png_ptr:png_structp; info_ptr:png_infop; background:Ppng_color_16p):png_uint_32;cdecl; external LibPng;
*)
var png_get_bKGD : function( png_ptr : png_structp ; info_ptr : png_infop ; background : Ppng_color_16p ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_bKGD(png_ptr:png_structp; info_ptr:png_infop; background:png_color_16p);cdecl; external LibPng;
*)
var png_set_bKGD : procedure( png_ptr : png_structp ; info_ptr : png_infop ; background : png_color_16p ) ; cdecl ; 

(*
function png_get_cHRM(png_ptr:png_structp; info_ptr:png_infop; white_x:Pdouble; white_y:Pdouble; red_x:Pdouble;
           red_y:Pdouble; green_x:Pdouble; green_y:Pdouble; blue_x:Pdouble; blue_y:Pdouble):png_uint_32;cdecl; external LibPng;
*)
var png_get_cHRM : function( png_ptr : png_structp ; info_ptr : png_infop ; white_x : Pdouble ; white_y : Pdouble ; red_x : Pdouble ; red_y : Pdouble ; green_x : Pdouble ; green_y : Pdouble ; blue_x : Pdouble ; blue_y : Pdouble ) : png_uint_32 ; cdecl ; 

(*
function png_get_cHRM_fixed(png_ptr:png_structp; info_ptr:png_infop; int_white_x:Ppng_fixed_point; int_white_y:Ppng_fixed_point; int_red_x:Ppng_fixed_point;
           int_red_y:Ppng_fixed_point; int_green_x:Ppng_fixed_point; int_green_y:Ppng_fixed_point; int_blue_x:Ppng_fixed_point; int_blue_y:Ppng_fixed_point):png_uint_32;cdecl; external LibPng;
*)
var png_get_cHRM_fixed : function( png_ptr : png_structp ; info_ptr : png_infop ; int_white_x : Ppng_fixed_point ; int_white_y : Ppng_fixed_point ; int_red_x : Ppng_fixed_point ; int_red_y : Ppng_fixed_point ; int_green_x : Ppng_fixed_point ; int_green_y : Ppng_fixed_point ; int_blue_x : Ppng_fixed_point ; int_blue_y : Ppng_fixed_point ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_cHRM(png_ptr:png_structp; info_ptr:png_infop; white_x:double; white_y:double; red_x:double;
            red_y:double; green_x:double; green_y:double; blue_x:double; blue_y:double);cdecl; external LibPng;
*)
var png_set_cHRM : procedure( png_ptr : png_structp ; info_ptr : png_infop ; white_x : double ; white_y : double ; red_x : double ; red_y : double ; green_x : double ; green_y : double ; blue_x : double ; blue_y : double ) ; cdecl ; 

(*
procedure png_set_cHRM_fixed(png_ptr:png_structp; info_ptr:png_infop; int_white_x:png_fixed_point; int_white_y:png_fixed_point; int_red_x:png_fixed_point;
            int_red_y:png_fixed_point; int_green_x:png_fixed_point; int_green_y:png_fixed_point; int_blue_x:png_fixed_point; int_blue_y:png_fixed_point);cdecl; external LibPng;
*)
var png_set_cHRM_fixed : procedure( png_ptr : png_structp ; info_ptr : png_infop ; int_white_x : png_fixed_point ; int_white_y : png_fixed_point ; int_red_x : png_fixed_point ; int_red_y : png_fixed_point ; int_green_x : png_fixed_point ; int_green_y : png_fixed_point ; int_blue_x : png_fixed_point ; int_blue_y : png_fixed_point ) ; cdecl ; 

(*
function png_get_gAMA(png_ptr:png_structp; info_ptr:png_infop; file_gamma:Pdouble):png_uint_32;cdecl; external LibPng;
*)
var png_get_gAMA : function( png_ptr : png_structp ; info_ptr : png_infop ; file_gamma : Pdouble ) : png_uint_32 ; cdecl ; 

(*
function png_get_gAMA_fixed(png_ptr:png_structp; info_ptr:png_infop; int_file_gamma:Ppng_fixed_point):png_uint_32;cdecl; external LibPng;
*)
var png_get_gAMA_fixed : function( png_ptr : png_structp ; info_ptr : png_infop ; int_file_gamma : Ppng_fixed_point ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_gAMA(png_ptr:png_structp; info_ptr:png_infop; file_gamma:double);cdecl; external LibPng;
*)
var png_set_gAMA : procedure( png_ptr : png_structp ; info_ptr : png_infop ; file_gamma : double ) ; cdecl ; 

(*
procedure png_set_gAMA_fixed(png_ptr:png_structp; info_ptr:png_infop; int_file_gamma:png_fixed_point);cdecl; external LibPng;
*)
var png_set_gAMA_fixed : procedure( png_ptr : png_structp ; info_ptr : png_infop ; int_file_gamma : png_fixed_point ) ; cdecl ; 

(*
function png_get_hIST(png_ptr:png_structp; info_ptr:png_infop; hist:Ppng_uint_16p):png_uint_32;cdecl; external LibPng;
*)
var png_get_hIST : function( png_ptr : png_structp ; info_ptr : png_infop ; hist : Ppng_uint_16p ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_hIST(png_ptr:png_structp; info_ptr:png_infop; hist:png_uint_16p);cdecl; external LibPng;
*)
var png_set_hIST : procedure( png_ptr : png_structp ; info_ptr : png_infop ; hist : png_uint_16p ) ; cdecl ; 

(*
function png_get_IHDR(png_ptr:png_structp; info_ptr:png_infop; width:Ppng_uint_32; height:Ppng_uint_32; bit_depth:Plongint;
           color_type:Plongint; interlace_type:Plongint; compression_type:Plongint; filter_type:Plongint):png_uint_32;cdecl; external LibPng;
*)
var png_get_IHDR : function( png_ptr : png_structp ; info_ptr : png_infop ; width : Ppng_uint_32 ; height : Ppng_uint_32 ; bit_depth : Plongint ; color_type : Plongint ; interlace_type : Plongint ; compression_type : Plongint ; filter_type : Plongint ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_IHDR(png_ptr:png_structp; info_ptr:png_infop; width:png_uint_32; height:png_uint_32; bit_depth:longint;
            color_type:longint; interlace_type:longint; compression_type:longint; filter_type:longint);cdecl; external LibPng;
*)
var png_set_IHDR : procedure( png_ptr : png_structp ; info_ptr : png_infop ; width : png_uint_32 ; height : png_uint_32 ; bit_depth : longint ; color_type : longint ; interlace_type : longint ; compression_type : longint ; filter_type : longint ) ; cdecl ; 

(*
function png_get_oFFs(png_ptr:png_structp; info_ptr:png_infop; offset_x:Ppng_int_32; offset_y:Ppng_int_32; unit_type:Plongint):png_uint_32;cdecl; external LibPng;
*)
var png_get_oFFs : function( png_ptr : png_structp ; info_ptr : png_infop ; offset_x : Ppng_int_32 ; offset_y : Ppng_int_32 ; unit_type : Plongint ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_oFFs(png_ptr:png_structp; info_ptr:png_infop; offset_x:png_int_32; offset_y:png_int_32; unit_type:longint);cdecl; external LibPng;
*)
var png_set_oFFs : procedure( png_ptr : png_structp ; info_ptr : png_infop ; offset_x : png_int_32 ; offset_y : png_int_32 ; unit_type : longint ) ; cdecl ; 

(*
function png_get_pCAL(png_ptr:png_structp; info_ptr:png_infop; purpose:Ppng_charp; X0:Ppng_int_32; X1:Ppng_int_32;
           atype:Plongint; nparams:Plongint; units:Ppng_charp; params:Ppng_charpp):png_uint_32;cdecl; external LibPng;
*)
var png_get_pCAL : function( png_ptr : png_structp ; info_ptr : png_infop ; purpose : Ppng_charp ; X0 : Ppng_int_32 ; X1 : Ppng_int_32 ; atype : Plongint ; nparams : Plongint ; units : Ppng_charp ; params : Ppng_charpp ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_pCAL(png_ptr:png_structp; info_ptr:png_infop; purpose:png_charp; X0:png_int_32; X1:png_int_32;
            atype:longint; nparams:longint; units:png_charp; params:png_charpp);cdecl; external LibPng;
*)
var png_set_pCAL : procedure( png_ptr : png_structp ; info_ptr : png_infop ; purpose : png_charp ; X0 : png_int_32 ; X1 : png_int_32 ; atype : longint ; nparams : longint ; units : png_charp ; params : png_charpp ) ; cdecl ; 

(*
function png_get_pHYs(png_ptr:png_structp; info_ptr:png_infop; res_x:Ppng_uint_32; res_y:Ppng_uint_32; unit_type:Plongint):png_uint_32;cdecl; external LibPng;
*)
var png_get_pHYs : function( png_ptr : png_structp ; info_ptr : png_infop ; res_x : Ppng_uint_32 ; res_y : Ppng_uint_32 ; unit_type : Plongint ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_pHYs(png_ptr:png_structp; info_ptr:png_infop; res_x:png_uint_32; res_y:png_uint_32; unit_type:longint);cdecl; external LibPng;
*)
var png_set_pHYs : procedure( png_ptr : png_structp ; info_ptr : png_infop ; res_x : png_uint_32 ; res_y : png_uint_32 ; unit_type : longint ) ; cdecl ; 

(*
function png_get_PLTE(png_ptr:png_structp; info_ptr:png_infop; palette:Ppng_colorp; num_palette:Plongint):png_uint_32;cdecl; external LibPng;
*)
var png_get_PLTE : function( png_ptr : png_structp ; info_ptr : png_infop ; palette : Ppng_colorp ; num_palette : Plongint ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_PLTE(png_ptr:png_structp; info_ptr:png_infop; palette:png_colorp; num_palette:longint);cdecl; external LibPng;
*)
var png_set_PLTE : procedure( png_ptr : png_structp ; info_ptr : png_infop ; palette : png_colorp ; num_palette : longint ) ; cdecl ; 

(*
function png_get_sBIT(png_ptr:png_structp; info_ptr:png_infop; sig_bit:Ppng_color_8p):png_uint_32;cdecl; external LibPng;
*)
var png_get_sBIT : function( png_ptr : png_structp ; info_ptr : png_infop ; sig_bit : Ppng_color_8p ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_sBIT(png_ptr:png_structp; info_ptr:png_infop; sig_bit:png_color_8p);cdecl; external LibPng;
*)
var png_set_sBIT : procedure( png_ptr : png_structp ; info_ptr : png_infop ; sig_bit : png_color_8p ) ; cdecl ; 

(*
function png_get_sRGB(png_ptr:png_structp; info_ptr:png_infop; intent:Plongint):png_uint_32;cdecl; external LibPng;
*)
var png_get_sRGB : function( png_ptr : png_structp ; info_ptr : png_infop ; intent : Plongint ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_sRGB(png_ptr:png_structp; info_ptr:png_infop; intent:longint);cdecl; external LibPng;
*)
var png_set_sRGB : procedure( png_ptr : png_structp ; info_ptr : png_infop ; intent : longint ) ; cdecl ; 

(*
procedure png_set_sRGB_gAMA_and_cHRM(png_ptr:png_structp; info_ptr:png_infop; intent:longint);cdecl; external LibPng;
*)
var png_set_sRGB_gAMA_and_cHRM : procedure( png_ptr : png_structp ; info_ptr : png_infop ; intent : longint ) ; cdecl ; 

(*
function png_get_iCCP(png_ptr:png_structp; info_ptr:png_infop; name:png_charpp; compression_type:Plongint; profile:png_charpp;
           proflen:Ppng_uint_32):png_uint_32;cdecl; external LibPng;
*)
var png_get_iCCP : function( png_ptr : png_structp ; info_ptr : png_infop ; name : png_charpp ; compression_type : Plongint ; profile : png_charpp ; proflen : Ppng_uint_32 ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_iCCP(png_ptr:png_structp; info_ptr:png_infop; name:png_charp; compression_type:longint; profile:png_charp;
            proflen:png_uint_32);cdecl; external LibPng;
*)
var png_set_iCCP : procedure( png_ptr : png_structp ; info_ptr : png_infop ; name : png_charp ; compression_type : longint ; profile : png_charp ; proflen : png_uint_32 ) ; cdecl ; 

(*
function png_get_sPLT(png_ptr:png_structp; info_ptr:png_infop; entries:png_sPLT_tpp):png_uint_32;cdecl; external LibPng;
*)
var png_get_sPLT : function( png_ptr : png_structp ; info_ptr : png_infop ; entries : png_sPLT_tpp ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_sPLT(png_ptr:png_structp; info_ptr:png_infop; entries:png_sPLT_tp; nentries:longint);cdecl; external LibPng;
*)
var png_set_sPLT : procedure( png_ptr : png_structp ; info_ptr : png_infop ; entries : png_sPLT_tp ; nentries : longint ) ; cdecl ; 

(*
function png_get_text(png_ptr:png_structp; info_ptr:png_infop; text_ptr:Ppng_textp; num_text:Plongint):png_uint_32;cdecl; external LibPng;
*)
var png_get_text : function( png_ptr : png_structp ; info_ptr : png_infop ; text_ptr : Ppng_textp ; num_text : Plongint ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_text(png_ptr:png_structp; info_ptr:png_infop; text_ptr:png_textp; num_text:longint);cdecl; external LibPng;
*)
var png_set_text : procedure( png_ptr : png_structp ; info_ptr : png_infop ; text_ptr : png_textp ; num_text : longint ) ; cdecl ; 

(*
function png_get_tIME(png_ptr:png_structp; info_ptr:png_infop; mod_time:Ppng_timep):png_uint_32;cdecl; external LibPng;
*)
var png_get_tIME : function( png_ptr : png_structp ; info_ptr : png_infop ; mod_time : Ppng_timep ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_tIME(png_ptr:png_structp; info_ptr:png_infop; mod_time:png_timep);cdecl; external LibPng;
*)
var png_set_tIME : procedure( png_ptr : png_structp ; info_ptr : png_infop ; mod_time : png_timep ) ; cdecl ; 

(*
function png_get_tRNS(png_ptr:png_structp; info_ptr:png_infop; trans:Ppng_bytep; num_trans:Plongint; trans_values:Ppng_color_16p):png_uint_32;cdecl; external LibPng;
*)
var png_get_tRNS : function( png_ptr : png_structp ; info_ptr : png_infop ; trans : Ppng_bytep ; num_trans : Plongint ; trans_values : Ppng_color_16p ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_tRNS(png_ptr:png_structp; info_ptr:png_infop; trans:png_bytep; num_trans:longint; trans_values:png_color_16p);cdecl; external LibPng;
*)
var png_set_tRNS : procedure( png_ptr : png_structp ; info_ptr : png_infop ; trans : png_bytep ; num_trans : longint ; trans_values : png_color_16p ) ; cdecl ; 

(*
function png_get_sCAL(png_ptr:png_structp; info_ptr:png_infop; aunit:Plongint; width:Pdouble; height:Pdouble):png_uint_32;cdecl; external LibPng;
*)
var png_get_sCAL : function( png_ptr : png_structp ; info_ptr : png_infop ; aunit : Plongint ; width : Pdouble ; height : Pdouble ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_sCAL(png_ptr:png_structp; info_ptr:png_infop; aunit:longint; width:double; height:double);cdecl; external LibPng;
*)
var png_set_sCAL : procedure( png_ptr : png_structp ; info_ptr : png_infop ; aunit : longint ; width : double ; height : double ) ; cdecl ; 

(*
procedure png_set_sCAL_s(png_ptr:png_structp; info_ptr:png_infop; aunit:longint; swidth:png_charp; sheight:png_charp);cdecl; external LibPng;
*)
var png_set_sCAL_s : procedure( png_ptr : png_structp ; info_ptr : png_infop ; aunit : longint ; swidth : png_charp ; sheight : png_charp ) ; cdecl ; 

(*
procedure png_set_keep_unknown_chunks(png_ptr:png_structp; keep:longint; chunk_list:png_bytep; num_chunks:longint);cdecl; external LibPng;
*)
var png_set_keep_unknown_chunks : procedure( png_ptr : png_structp ; keep : longint ; chunk_list : png_bytep ; num_chunks : longint ) ; cdecl ; 

(*
procedure png_set_unknown_chunks(png_ptr:png_structp; info_ptr:png_infop; unknowns:png_unknown_chunkp; num_unknowns:longint);cdecl; external LibPng;
*)
var png_set_unknown_chunks : procedure( png_ptr : png_structp ; info_ptr : png_infop ; unknowns : png_unknown_chunkp ; num_unknowns : longint ) ; cdecl ; 

(*
procedure png_set_unknown_chunk_location(png_ptr:png_structp; info_ptr:png_infop; chunk:longint; location:longint);cdecl; external LibPng;
*)
var png_set_unknown_chunk_location : procedure( png_ptr : png_structp ; info_ptr : png_infop ; chunk : longint ; location : longint ) ; cdecl ; 

(*
function png_get_unknown_chunks(png_ptr:png_structp; info_ptr:png_infop; entries:png_unknown_chunkpp):png_uint_32;cdecl; external LibPng;
*)
var png_get_unknown_chunks : function( png_ptr : png_structp ; info_ptr : png_infop ; entries : png_unknown_chunkpp ) : png_uint_32 ; cdecl ; 

(*
procedure png_set_invalid(png_ptr:png_structp; info_ptr:png_infop; mask:longint);cdecl; external LibPng;
*)
var png_set_invalid : procedure( png_ptr : png_structp ; info_ptr : png_infop ; mask : longint ) ; cdecl ; 

(*
procedure png_read_png(png_ptr:png_structp; info_ptr:png_infop; transforms:longint; params:voidp);cdecl; external LibPng;
*)
var png_read_png : procedure( png_ptr : png_structp ; info_ptr : png_infop ; transforms : longint ; params : voidp ) ; cdecl ; 

(*
procedure png_write_png(png_ptr:png_structp; info_ptr:png_infop; transforms:longint; params:voidp);cdecl; external LibPng;
*)
var png_write_png : procedure( png_ptr : png_structp ; info_ptr : png_infop ; transforms : longint ; params : voidp ) ; cdecl ; 

(*
function png_get_header_ver(png_ptr:png_structp):png_charp;cdecl; external LibPng;
*)
var png_get_header_ver : function( png_ptr : png_structp ) : png_charp ; cdecl ; 

(*
function png_get_header_version(png_ptr:png_structp):png_charp;cdecl; external LibPng;
*)
var png_get_header_version : function( png_ptr : png_structp ) : png_charp ; cdecl ; 

(*
function png_get_libpng_ver(png_ptr:png_structp):png_charp;cdecl; external LibPng;
*)
var png_get_libpng_ver : function( png_ptr : png_structp ) : png_charp ; cdecl ; 

implementation

uses
	SaGeBase
	,SaGeBased
	,SaGeDllManager;

type
	TSGDllPNG = class(TSGDll)
			public
		class function SystemNames() : TSGStringList; override;
		class function DllNames() : TSGStringList; override;
		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; override;
		class procedure Free(); override;
		end;

class function TSGDllPNG.SystemNames() : TSGStringList; 
begin
Result := 'LibPng';
Result += 'Png';
end;

class function TSGDllPNG.DllNames() : TSGStringList;
const
	WinDllPrefix = {$IFDEF MSWINDOWS}'lib'{$ELSE}''{$ENDIF};
var
	i : TSGUInt32;
begin
Result := nil;
for i := {$IFDEF MSWINDOWS}12{$ELSE}13{$ENDIF} downto 1 do
	Result += WinDllPrefix + 'png' + SGStr(i);
{$IFDEF MSWINDOWS}Result += WinDllPrefix + 'png'; {$ENDIF}
end;

class procedure TSGDllPNG.Free(); 
begin
png_access_version_number := nil;
png_set_sig_bytes := nil;
png_sig_cmp := nil;
png_check_sig := nil;
png_create_read_struct := nil;
png_create_write_struct := nil;
png_get_compression_buffer_size := nil;
png_set_compression_buffer_size := nil;
png_reset_zstream := nil;
png_write_chunk := nil;
png_write_chunk_start := nil;
png_write_chunk_data := nil;
png_write_chunk_end := nil;
png_create_info_struct := nil;
png_info_init := nil;
png_write_info_before_PLTE := nil;
png_write_info := nil;
png_read_info := nil;
png_convert_to_rfc1123 := nil;
png_convert_from_struct_tm := nil;
png_convert_from_time_t := nil;
png_set_expand := nil;
png_set_gray_1_2_4_to_8 := nil;
png_set_palette_to_rgb := nil;
png_set_tRNS_to_alpha := nil;
png_set_bgr := nil;
png_set_gray_to_rgb := nil;
png_set_rgb_to_gray := nil;
png_set_rgb_to_gray_fixed := nil;
png_get_rgb_to_gray_status := nil;
png_build_grayscale_palette := nil;
png_set_strip_alpha := nil;
png_set_swap_alpha := nil;
png_set_invert_alpha := nil;
png_set_filler := nil;
png_set_swap := nil;
png_set_packing := nil;
png_set_packswap := nil;
png_set_shift := nil;
png_set_interlace_handling := nil;
png_set_invert_mono := nil;
png_set_background := nil;
png_set_strip_16 := nil;
png_set_dither := nil;
png_set_gamma := nil;
png_permit_empty_plte := nil;
png_set_flush := nil;
png_write_flush := nil;
png_start_read_image := nil;
png_read_update_info := nil;
png_read_rows := nil;
png_read_row := nil;
png_read_image := nil;
png_write_row := nil;
png_write_rows := nil;
png_write_image := nil;
png_write_end := nil;
png_read_end := nil;
png_destroy_info_struct := nil;
png_destroy_read_struct := nil;
png_read_destroy := nil;
png_destroy_write_struct := nil;
png_write_destroy_info := nil;
png_write_destroy := nil;
png_set_crc_action := nil;
png_set_filter := nil;
png_set_filter_heuristics := nil;
png_set_compression_level := nil;
png_set_compression_mem_level := nil;
png_set_compression_strategy := nil;
png_set_compression_window_bits := nil;
png_set_compression_method := nil;
png_init_io := nil;
png_set_error_fn := nil;
png_get_error_ptr := nil;
png_set_write_fn := nil;
png_set_read_fn := nil;
png_get_io_ptr := nil;
png_set_read_status_fn := nil;
png_set_write_status_fn := nil;
png_set_read_user_transform_fn := nil;
png_set_write_user_transform_fn := nil;
png_set_user_transform_info := nil;
png_get_user_transform_ptr := nil;
png_set_read_user_chunk_fn := nil;
png_get_user_chunk_ptr := nil;
png_set_progressive_read_fn := nil;
png_get_progressive_ptr := nil;
png_process_data := nil;
png_progressive_combine_row := nil;
png_malloc := nil;
png_free := nil;
png_free_data := nil;
png_data_freer := nil;
png_memcpy_check := nil;
png_memset_check := nil;
png_error := nil;
png_chunk_error := nil;
png_warning := nil;
png_chunk_warning := nil;
png_get_valid := nil;
png_get_rowbytes := nil;
png_get_rows := nil;
png_set_rows := nil;
png_get_channels := nil;
png_get_image_width := nil;
png_get_image_height := nil;
png_get_bit_depth := nil;
png_get_color_type := nil;
png_get_filter_type := nil;
png_get_interlace_type := nil;
png_get_compression_type := nil;
png_get_pixels_per_meter := nil;
png_get_x_pixels_per_meter := nil;
png_get_y_pixels_per_meter := nil;
png_get_pixel_aspect_ratio := nil;
png_get_x_offset_pixels := nil;
png_get_y_offset_pixels := nil;
png_get_x_offset_microns := nil;
png_get_y_offset_microns := nil;
png_get_signature := nil;
png_get_bKGD := nil;
png_set_bKGD := nil;
png_get_cHRM := nil;
png_get_cHRM_fixed := nil;
png_set_cHRM := nil;
png_set_cHRM_fixed := nil;
png_get_gAMA := nil;
png_get_gAMA_fixed := nil;
png_set_gAMA := nil;
png_set_gAMA_fixed := nil;
png_get_hIST := nil;
png_set_hIST := nil;
png_get_IHDR := nil;
png_set_IHDR := nil;
png_get_oFFs := nil;
png_set_oFFs := nil;
png_get_pCAL := nil;
png_set_pCAL := nil;
png_get_pHYs := nil;
png_set_pHYs := nil;
png_get_PLTE := nil;
png_set_PLTE := nil;
png_get_sBIT := nil;
png_set_sBIT := nil;
png_get_sRGB := nil;
png_set_sRGB := nil;
png_set_sRGB_gAMA_and_cHRM := nil;
png_get_iCCP := nil;
png_set_iCCP := nil;
png_get_sPLT := nil;
png_set_sPLT := nil;
png_get_text := nil;
png_set_text := nil;
png_get_tIME := nil;
png_set_tIME := nil;
png_get_tRNS := nil;
png_set_tRNS := nil;
png_get_sCAL := nil;
png_set_sCAL := nil;
png_set_sCAL_s := nil;
png_set_keep_unknown_chunks := nil;
png_set_unknown_chunks := nil;
png_set_unknown_chunk_location := nil;
png_get_unknown_chunks := nil;
png_set_invalid := nil;
png_read_png := nil;
png_write_png := nil;
png_get_header_ver := nil;
png_get_header_version := nil;
png_get_libpng_ver := nil;
end;

class function TSGDllPNG.Load(const VDll : TSGLibHandle) : TSGDllLoadObject;
var
	LoadResult : PSGDllLoadObject = nil;

function LoadProcedure(const Name : PChar) : Pointer;
begin
Result := GetProcAddress(VDll, Name);
if Result = nil then
	LoadResult^.FFunctionErrors += SGPCharToString(Name)
else
	LoadResult^.FFunctionLoaded += 1;
end;

begin
Result.Clear();
Result.FFunctionCount := 171;
LoadResult := @Result;
Pointer(png_access_version_number) := LoadProcedure('png_access_version_number');
Pointer(png_set_sig_bytes) := LoadProcedure('png_set_sig_bytes');
Pointer(png_sig_cmp) := LoadProcedure('png_sig_cmp');
Pointer(png_check_sig) := LoadProcedure('png_check_sig');
Pointer(png_create_read_struct) := LoadProcedure('png_create_read_struct');
Pointer(png_create_write_struct) := LoadProcedure('png_create_write_struct');
Pointer(png_get_compression_buffer_size) := LoadProcedure('png_get_compression_buffer_size');
Pointer(png_set_compression_buffer_size) := LoadProcedure('png_set_compression_buffer_size');
Pointer(png_reset_zstream) := LoadProcedure('png_reset_zstream');
Pointer(png_write_chunk) := LoadProcedure('png_write_chunk');
Pointer(png_write_chunk_start) := LoadProcedure('png_write_chunk_start');
Pointer(png_write_chunk_data) := LoadProcedure('png_write_chunk_data');
Pointer(png_write_chunk_end) := LoadProcedure('png_write_chunk_end');
Pointer(png_create_info_struct) := LoadProcedure('png_create_info_struct');
Pointer(png_info_init) := LoadProcedure('png_info_init');
Pointer(png_write_info_before_PLTE) := LoadProcedure('png_write_info_before_PLTE');
Pointer(png_write_info) := LoadProcedure('png_write_info');
Pointer(png_read_info) := LoadProcedure('png_read_info');
Pointer(png_convert_to_rfc1123) := LoadProcedure('png_convert_to_rfc1123');
Pointer(png_convert_from_struct_tm) := LoadProcedure('png_convert_from_struct_tm');
Pointer(png_convert_from_time_t) := LoadProcedure('png_convert_from_time_t');
Pointer(png_set_expand) := LoadProcedure('png_set_expand');
Pointer(png_set_gray_1_2_4_to_8) := LoadProcedure('png_set_gray_1_2_4_to_8');
Pointer(png_set_palette_to_rgb) := LoadProcedure('png_set_palette_to_rgb');
Pointer(png_set_tRNS_to_alpha) := LoadProcedure('png_set_tRNS_to_alpha');
Pointer(png_set_bgr) := LoadProcedure('png_set_bgr');
Pointer(png_set_gray_to_rgb) := LoadProcedure('png_set_gray_to_rgb');
Pointer(png_set_rgb_to_gray) := LoadProcedure('png_set_rgb_to_gray');
Pointer(png_set_rgb_to_gray_fixed) := LoadProcedure('png_set_rgb_to_gray_fixed');
Pointer(png_get_rgb_to_gray_status) := LoadProcedure('png_get_rgb_to_gray_status');
Pointer(png_build_grayscale_palette) := LoadProcedure('png_build_grayscale_palette');
Pointer(png_set_strip_alpha) := LoadProcedure('png_set_strip_alpha');
Pointer(png_set_swap_alpha) := LoadProcedure('png_set_swap_alpha');
Pointer(png_set_invert_alpha) := LoadProcedure('png_set_invert_alpha');
Pointer(png_set_filler) := LoadProcedure('png_set_filler');
Pointer(png_set_swap) := LoadProcedure('png_set_swap');
Pointer(png_set_packing) := LoadProcedure('png_set_packing');
Pointer(png_set_packswap) := LoadProcedure('png_set_packswap');
Pointer(png_set_shift) := LoadProcedure('png_set_shift');
Pointer(png_set_interlace_handling) := LoadProcedure('png_set_interlace_handling');
Pointer(png_set_invert_mono) := LoadProcedure('png_set_invert_mono');
Pointer(png_set_background) := LoadProcedure('png_set_background');
Pointer(png_set_strip_16) := LoadProcedure('png_set_strip_16');
Pointer(png_set_dither) := LoadProcedure('png_set_dither');
Pointer(png_set_gamma) := LoadProcedure('png_set_gamma');
Pointer(png_permit_empty_plte) := LoadProcedure('png_permit_empty_plte');
Pointer(png_set_flush) := LoadProcedure('png_set_flush');
Pointer(png_write_flush) := LoadProcedure('png_write_flush');
Pointer(png_start_read_image) := LoadProcedure('png_start_read_image');
Pointer(png_read_update_info) := LoadProcedure('png_read_update_info');
Pointer(png_read_rows) := LoadProcedure('png_read_rows');
Pointer(png_read_row) := LoadProcedure('png_read_row');
Pointer(png_read_image) := LoadProcedure('png_read_image');
Pointer(png_write_row) := LoadProcedure('png_write_row');
Pointer(png_write_rows) := LoadProcedure('png_write_rows');
Pointer(png_write_image) := LoadProcedure('png_write_image');
Pointer(png_write_end) := LoadProcedure('png_write_end');
Pointer(png_read_end) := LoadProcedure('png_read_end');
Pointer(png_destroy_info_struct) := LoadProcedure('png_destroy_info_struct');
Pointer(png_destroy_read_struct) := LoadProcedure('png_destroy_read_struct');
Pointer(png_read_destroy) := LoadProcedure('png_read_destroy');
Pointer(png_destroy_write_struct) := LoadProcedure('png_destroy_write_struct');
Pointer(png_write_destroy_info) := LoadProcedure('png_write_destroy_info');
Pointer(png_write_destroy) := LoadProcedure('png_write_destroy');
Pointer(png_set_crc_action) := LoadProcedure('png_set_crc_action');
Pointer(png_set_filter) := LoadProcedure('png_set_filter');
Pointer(png_set_filter_heuristics) := LoadProcedure('png_set_filter_heuristics');
Pointer(png_set_compression_level) := LoadProcedure('png_set_compression_level');
Pointer(png_set_compression_mem_level) := LoadProcedure('png_set_compression_mem_level');
Pointer(png_set_compression_strategy) := LoadProcedure('png_set_compression_strategy');
Pointer(png_set_compression_window_bits) := LoadProcedure('png_set_compression_window_bits');
Pointer(png_set_compression_method) := LoadProcedure('png_set_compression_method');
Pointer(png_init_io) := LoadProcedure('png_init_io');
Pointer(png_set_error_fn) := LoadProcedure('png_set_error_fn');
Pointer(png_get_error_ptr) := LoadProcedure('png_get_error_ptr');
Pointer(png_set_write_fn) := LoadProcedure('png_set_write_fn');
Pointer(png_set_read_fn) := LoadProcedure('png_set_read_fn');
Pointer(png_get_io_ptr) := LoadProcedure('png_get_io_ptr');
Pointer(png_set_read_status_fn) := LoadProcedure('png_set_read_status_fn');
Pointer(png_set_write_status_fn) := LoadProcedure('png_set_write_status_fn');
Pointer(png_set_read_user_transform_fn) := LoadProcedure('png_set_read_user_transform_fn');
Pointer(png_set_write_user_transform_fn) := LoadProcedure('png_set_write_user_transform_fn');
Pointer(png_set_user_transform_info) := LoadProcedure('png_set_user_transform_info');
Pointer(png_get_user_transform_ptr) := LoadProcedure('png_get_user_transform_ptr');
Pointer(png_set_read_user_chunk_fn) := LoadProcedure('png_set_read_user_chunk_fn');
Pointer(png_get_user_chunk_ptr) := LoadProcedure('png_get_user_chunk_ptr');
Pointer(png_set_progressive_read_fn) := LoadProcedure('png_set_progressive_read_fn');
Pointer(png_get_progressive_ptr) := LoadProcedure('png_get_progressive_ptr');
Pointer(png_process_data) := LoadProcedure('png_process_data');
Pointer(png_progressive_combine_row) := LoadProcedure('png_progressive_combine_row');
Pointer(png_malloc) := LoadProcedure('png_malloc');
Pointer(png_free) := LoadProcedure('png_free');
Pointer(png_free_data) := LoadProcedure('png_free_data');
Pointer(png_data_freer) := LoadProcedure('png_data_freer');
Pointer(png_memcpy_check) := LoadProcedure('png_memcpy_check');
Pointer(png_memset_check) := LoadProcedure('png_memset_check');
Pointer(png_error) := LoadProcedure('png_error');
Pointer(png_chunk_error) := LoadProcedure('png_chunk_error');
Pointer(png_warning) := LoadProcedure('png_warning');
Pointer(png_chunk_warning) := LoadProcedure('png_chunk_warning');
Pointer(png_get_valid) := LoadProcedure('png_get_valid');
Pointer(png_get_rowbytes) := LoadProcedure('png_get_rowbytes');
Pointer(png_get_rows) := LoadProcedure('png_get_rows');
Pointer(png_set_rows) := LoadProcedure('png_set_rows');
Pointer(png_get_channels) := LoadProcedure('png_get_channels');
Pointer(png_get_image_width) := LoadProcedure('png_get_image_width');
Pointer(png_get_image_height) := LoadProcedure('png_get_image_height');
Pointer(png_get_bit_depth) := LoadProcedure('png_get_bit_depth');
Pointer(png_get_color_type) := LoadProcedure('png_get_color_type');
Pointer(png_get_filter_type) := LoadProcedure('png_get_filter_type');
Pointer(png_get_interlace_type) := LoadProcedure('png_get_interlace_type');
Pointer(png_get_compression_type) := LoadProcedure('png_get_compression_type');
Pointer(png_get_pixels_per_meter) := LoadProcedure('png_get_pixels_per_meter');
Pointer(png_get_x_pixels_per_meter) := LoadProcedure('png_get_x_pixels_per_meter');
Pointer(png_get_y_pixels_per_meter) := LoadProcedure('png_get_y_pixels_per_meter');
Pointer(png_get_pixel_aspect_ratio) := LoadProcedure('png_get_pixel_aspect_ratio');
Pointer(png_get_x_offset_pixels) := LoadProcedure('png_get_x_offset_pixels');
Pointer(png_get_y_offset_pixels) := LoadProcedure('png_get_y_offset_pixels');
Pointer(png_get_x_offset_microns) := LoadProcedure('png_get_x_offset_microns');
Pointer(png_get_y_offset_microns) := LoadProcedure('png_get_y_offset_microns');
Pointer(png_get_signature) := LoadProcedure('png_get_signature');
Pointer(png_get_bKGD) := LoadProcedure('png_get_bKGD');
Pointer(png_set_bKGD) := LoadProcedure('png_set_bKGD');
Pointer(png_get_cHRM) := LoadProcedure('png_get_cHRM');
Pointer(png_get_cHRM_fixed) := LoadProcedure('png_get_cHRM_fixed');
Pointer(png_set_cHRM) := LoadProcedure('png_set_cHRM');
Pointer(png_set_cHRM_fixed) := LoadProcedure('png_set_cHRM_fixed');
Pointer(png_get_gAMA) := LoadProcedure('png_get_gAMA');
Pointer(png_get_gAMA_fixed) := LoadProcedure('png_get_gAMA_fixed');
Pointer(png_set_gAMA) := LoadProcedure('png_set_gAMA');
Pointer(png_set_gAMA_fixed) := LoadProcedure('png_set_gAMA_fixed');
Pointer(png_get_hIST) := LoadProcedure('png_get_hIST');
Pointer(png_set_hIST) := LoadProcedure('png_set_hIST');
Pointer(png_get_IHDR) := LoadProcedure('png_get_IHDR');
Pointer(png_set_IHDR) := LoadProcedure('png_set_IHDR');
Pointer(png_get_oFFs) := LoadProcedure('png_get_oFFs');
Pointer(png_set_oFFs) := LoadProcedure('png_set_oFFs');
Pointer(png_get_pCAL) := LoadProcedure('png_get_pCAL');
Pointer(png_set_pCAL) := LoadProcedure('png_set_pCAL');
Pointer(png_get_pHYs) := LoadProcedure('png_get_pHYs');
Pointer(png_set_pHYs) := LoadProcedure('png_set_pHYs');
Pointer(png_get_PLTE) := LoadProcedure('png_get_PLTE');
Pointer(png_set_PLTE) := LoadProcedure('png_set_PLTE');
Pointer(png_get_sBIT) := LoadProcedure('png_get_sBIT');
Pointer(png_set_sBIT) := LoadProcedure('png_set_sBIT');
Pointer(png_get_sRGB) := LoadProcedure('png_get_sRGB');
Pointer(png_set_sRGB) := LoadProcedure('png_set_sRGB');
Pointer(png_set_sRGB_gAMA_and_cHRM) := LoadProcedure('png_set_sRGB_gAMA_and_cHRM');
Pointer(png_get_iCCP) := LoadProcedure('png_get_iCCP');
Pointer(png_set_iCCP) := LoadProcedure('png_set_iCCP');
Pointer(png_get_sPLT) := LoadProcedure('png_get_sPLT');
Pointer(png_set_sPLT) := LoadProcedure('png_set_sPLT');
Pointer(png_get_text) := LoadProcedure('png_get_text');
Pointer(png_set_text) := LoadProcedure('png_set_text');
Pointer(png_get_tIME) := LoadProcedure('png_get_tIME');
Pointer(png_set_tIME) := LoadProcedure('png_set_tIME');
Pointer(png_get_tRNS) := LoadProcedure('png_get_tRNS');
Pointer(png_set_tRNS) := LoadProcedure('png_set_tRNS');
Pointer(png_get_sCAL) := LoadProcedure('png_get_sCAL');
Pointer(png_set_sCAL) := LoadProcedure('png_set_sCAL');
Pointer(png_set_sCAL_s) := LoadProcedure('png_set_sCAL_s');
Pointer(png_set_keep_unknown_chunks) := LoadProcedure('png_set_keep_unknown_chunks');
Pointer(png_set_unknown_chunks) := LoadProcedure('png_set_unknown_chunks');
Pointer(png_set_unknown_chunk_location) := LoadProcedure('png_set_unknown_chunk_location');
Pointer(png_get_unknown_chunks) := LoadProcedure('png_get_unknown_chunks');
Pointer(png_set_invalid) := LoadProcedure('png_set_invalid');
Pointer(png_read_png) := LoadProcedure('png_read_png');
Pointer(png_write_png) := LoadProcedure('png_write_png');
Pointer(png_get_header_ver) := LoadProcedure('png_get_header_ver');
Pointer(png_get_header_version) := LoadProcedure('png_get_header_version');
Pointer(png_get_libpng_ver) := LoadProcedure('png_get_libpng_ver');
end;

initialization
begin
TSGDllPNG.Create();
end;
end.
