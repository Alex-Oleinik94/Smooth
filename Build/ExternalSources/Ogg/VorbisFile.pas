unit VorbisFile;

{************************************************************************}
{                                                                        }
{       Object Pascal Runtime Library                                    }
{       Vorbisfile interface unit                                        }
{                                                                        }
{ The original file is: vorbis/vorbisfile.h, released July 2001.         }
{ The original Pascal code is: VorbisFile.pas, released 28 Jul 2001.     }
{ The initial developer of the Pascal code is Matthijs Laan              }
{ (matthijsln@xs4all.nl).                                                }
{                                                                        }
{ Portions created by Matthijs Laan are                                  }
{ Copyright (C) 2001 Matthijs Laan.                                      }
{                                                                        }
{ Portions created by Xiph.org are                                       }
{ Copyright (C) 1994-2001 by Xiph.org http://www.xiph.org/               }
{                                                                        }
{       Obtained through:                                                }
{                                                                        }
{       Joint Endeavour of Delphi Innovators (Project JEDI)              }
{                                                                        }
{ You may retrieve the latest version of this file at the Project        }
{ JEDI home page, located at http://delphi-jedi.org                      }
{                                                                        }
{ The contents of this file are used with permission, subject to         }
{ the Mozilla Public License Version 1.1 (the "License"); you may        }
{ not use this file except in compliance with the License. You may       }
{ obtain a copy of the License at                                        }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                }
{                                                                        }
{ Software distributed under the License is distributed on an            }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or         }
{ implied. See the License for the specific language governing           }
{ rights and limitations under the License.                              }
{                                                                        }
{************************************************************************}

{$IFDEF FPC}
  {$MODE Delphi}
  {$IFDEF WIN32}
    {$PACKRECORDS C}
  {$ENDIF WIN32}
{$ENDIF FPC}

interface

{ Callbacks for Object Pascal streams added }

uses OSTypes, Ogg, Codec;

const
{$IFDEF MSWINDOWS}
  VorbisfileLib = 'vorbisfile.dll';
{$ENDIF MSWINDOWS}

{$IFDEF UNIX}
  VorbisfileLib = 'libvorbisfile.so';
{$ENDIF UNIX}

{ vorbis/vorbisfile.h }

type
  (* The function prototypes for the callbacks are basically the same as for
   * the stdio functions fread, fseek, fclose, ftell.
   * The one difference is that the FILE * arguments have been replaced with
   * a void * - this is to be used as a pointer to whatever internal data these
   * functions might need. In the stdio case, it's just a FILE * cast to a void *
   *
   * If you use other functions, check the docs for these functions and return
   * the right values. For seek_func(), you *MUST* return -1 if the stream is
   * unseekable
   *)
  read_func_t  = function(var ptr; size: size_t; nmemb: size_t; const datasource): size_t; cdecl;
  seek_func_t  = function(const datasource; offset: ogg_int64_t; whence: int): int; cdecl;
  close_func_t = function(const datasource): int; cdecl;
  tell_func_t  = function(const datasource): long; cdecl;

  p_ov_callbacks = ^ov_callbacks;
    ov_callbacks = record
      read_func:  read_func_t;
      seek_func:  seek_func_t;
      close_func: close_func_t;
      tell_func:  tell_func_t;
    end;

const
  NOTOPEN   = 0;
  PARTOPEN  = 1;
  OPENED    = 2;
  STREAMSET = 3;
  INITSET   = 4;

type
  POggVorbis_File = ^OggVorbis_File;
   OggVorbis_File = record
      datasource: Pointer; (* Pointer to a FILE *, etc. *)
      seekable: int;
      offset: ogg_int64_t;
      end_v: ogg_int64_t; { "end" is a reserved word in Pascal }
      oy: ogg_sync_state;

      (* If the FILE handle isn't seekable (eg, a pipe), only the current
         stream appears *)
      links: int;
      offsets: Pointer;
      dataoffsets: Pointer;
      serialnos: Pointer;
      pcmlengths: Pointer;
      vi: p_vorbis_info;
      vc: p_vorbis_comment;

      (* Decoding working state local storage *)
      pcm_offset: ogg_int64_t;
      ready_state: int;
      current_serialno: long;
      current_link: int;

      bittrack: double;
      samptrack: double;

      os: ogg_stream_state;  (* take physical pages, weld into a logical
              stream of packets *)
      vd: vorbis_dsp_state;  (* central working state for the packet->PCM decoder *)
      vb: vorbis_block;      (* local working space for packet->PCM decode *)

      callbacks: ov_callbacks;
         end;
(*


function ov_clear(var vf: OggVorbis_File): int; cdecl; external VorbisfileLib;
*)
var ov_clear : function( var vf : OggVorbis_File ) : int ; cdecl ;

{ Do not use "ov_open" in Object Pascal }
(*

function ov_open(var f: FILE; var vf: OggVorbis_File; initial: PChar; ibytes: long): int; cdecl; external VorbisfileLib;
*)
var ov_open : function( var f : FILE ; var vf : OggVorbis_File ; initial : PChar ; ibytes : long ) : int ; cdecl ;

(*

function ov_open_callbacks(const datasource; var vf: OggVorbis_File; initial: PChar; ibytes: long; callbacks: ov_callbacks): int; cdecl; external VorbisfileLib;
*)
var ov_open_callbacks : function( const datasource ; var vf : OggVorbis_File ; initial : PChar ; ibytes : long ; callbacks : ov_callbacks ) : int ; cdecl ;


{ Do not use "ov_test" in Object Pascal }
(*

function ov_test(var f: FILE; var vf: OggVorbis_File; initial: PChar; ibytes: long): int; cdecl; external VorbisfileLib;
*)
var ov_test : function( var f : FILE ; var vf : OggVorbis_File ; initial : PChar ; ibytes : long ) : int ; cdecl ;

(*

function ov_test_callbacks(const datasource; var vf: OggVorbis_File; initial: PChar; ibytes: long; callbacks: ov_callbacks): int; cdecl; external VorbisfileLib;
*)
var ov_test_callbacks : function( const datasource ; var vf : OggVorbis_File ; initial : PChar ; ibytes : long ; callbacks : ov_callbacks ) : int ; cdecl ;

(*

function ov_test_open(var vf: OggVorbis_File): int; cdecl; external VorbisfileLib;
*)
var ov_test_open : function( var vf : OggVorbis_File ) : int ; cdecl ;

(*


function ov_bitrate(var vf: OggVorbis_File; i: int): long; cdecl; external VorbisfileLib;
*)
var ov_bitrate : function( var vf : OggVorbis_File ; i : int ) : long ; cdecl ;

(*

function ov_bitrate_instant(var vf: OggVorbis_File): long; cdecl; external VorbisfileLib;
*)
var ov_bitrate_instant : function( var vf : OggVorbis_File ) : long ; cdecl ;

(*

function ov_streams(var vf: OggVorbis_File): long; cdecl; external VorbisfileLib;
*)
var ov_streams : function( var vf : OggVorbis_File ) : long ; cdecl ;

(*

function ov_seekable(var vf: OggVorbis_File): long; cdecl; external VorbisfileLib;
*)
var ov_seekable : function( var vf : OggVorbis_File ) : long ; cdecl ;

(*

function ov_serialnumber(var vf: OggVorbis_File; i: int): long; cdecl; external VorbisfileLib;
*)
var ov_serialnumber : function( var vf : OggVorbis_File ; i : int ) : long ; cdecl ;

(*


function ov_raw_total(var vf: OggVorbis_File; i: int): ogg_int64_t; cdecl; external VorbisfileLib;
*)
var ov_raw_total : function( var vf : OggVorbis_File ; i : int ) : ogg_int64_t ; cdecl ;

(*

function ov_pcm_total(var vf: OggVorbis_File; i: int): ogg_int64_t; cdecl; external VorbisfileLib;
*)
var ov_pcm_total : function( var vf : OggVorbis_File ; i : int ) : ogg_int64_t ; cdecl ;

(*

function ov_time_total(var vf: OggVorbis_File; i: int): double; cdecl; external VorbisfileLib;
*)
var ov_time_total : function( var vf : OggVorbis_File ; i : int ) : double ; cdecl ;

(*


function ov_raw_seek(var vf: OggVorbis_File; pos: long): int; cdecl; external VorbisfileLib;
*)
var ov_raw_seek : function( var vf : OggVorbis_File ; pos : long ) : int ; cdecl ;

(*

function ov_pcm_seek(var vf: OggVorbis_File; pos: ogg_int64_t): int; cdecl; external VorbisfileLib;
*)
var ov_pcm_seek : function( var vf : OggVorbis_File ; pos : ogg_int64_t ) : int ; cdecl ;

(*

function ov_pcm_seek_page(var vf: OggVorbis_File; pos: ogg_int64_t): int; cdecl; external VorbisfileLib;
*)
var ov_pcm_seek_page : function( var vf : OggVorbis_File ; pos : ogg_int64_t ) : int ; cdecl ;

(*

function ov_time_seek(var vf: OggVorbis_File; pos: double): int; cdecl; external VorbisfileLib;
*)
var ov_time_seek : function( var vf : OggVorbis_File ; pos : double ) : int ; cdecl ;

(*

function ov_time_seek_page(var vf: OggVorbis_File; pos: double): int; cdecl; external VorbisfileLib;
*)
var ov_time_seek_page : function( var vf : OggVorbis_File ; pos : double ) : int ; cdecl ;

(*


function ov_raw_tell(var vf: OggVorbis_File): ogg_int64_t; cdecl; external VorbisfileLib;
*)
var ov_raw_tell : function( var vf : OggVorbis_File ) : ogg_int64_t ; cdecl ;

(*

function ov_pcm_tell(var vf: OggVorbis_File): ogg_int64_t; cdecl; external VorbisfileLib;
*)
var ov_pcm_tell : function( var vf : OggVorbis_File ) : ogg_int64_t ; cdecl ;

(*

function ov_time_tell(var vf: OggVorbis_File): double; cdecl; external VorbisfileLib;
*)
var ov_time_tell : function( var vf : OggVorbis_File ) : double ; cdecl ;

(*


function ov_info(var vf: OggVorbis_File; link: int): p_vorbis_info; cdecl; external VorbisfileLib;
*)
var ov_info : function( var vf : OggVorbis_File ; link : int ) : p_vorbis_info ; cdecl ;

(*

function ov_comment(var vf: OggVorbis_File; link: int): p_vorbis_comment; cdecl; external VorbisfileLib;
*)
var ov_comment : function( var vf : OggVorbis_File ; link : int ) : p_vorbis_comment ; cdecl ;

(*


function ov_read(var vf: OggVorbis_File; const buffer; length: int; bigendianp: int; word: int; sgned: int; bitstream: p_int): int; cdecl; external VorbisfileLib;
*)
var ov_read : function( var vf : OggVorbis_File ; const buffer ; length : int ; bigendianp : int ; word : int ; sgned : int ; bitstream : p_int ) : int ; cdecl ;


{ The following is added and not found in the original .h file }
type
	int_t = int;

{ The vorbisfile callbacks for Object Pascal TStreams }
function ops_read_func(var ptr; size, nmemb: size_t; const datasource): size_t; cdecl;
function ops_seek_func(const datasource; offset: ogg_int64_t; whence: int_t): int_t; cdecl;
function ops_close_func(const datasource): int_t; cdecl;
function ops_tell_func(const datasource): long; cdecl;

var
  ops_callbacks: ov_callbacks;

implementation

uses
	 SmoothBase
	,SmoothDllManager
	,SmoothStringUtils
	,SmoothLists
	,SmoothSysUtils
	
	,Classes
	;

const
  { Constants taken from the MSVC++6 ANSI C library. These values may be
    different for other C libraries! }
  SEEK_SET = 0;
  SEEK_CUR = 1;
  SEEK_END = 2;

  EOF = -1;

function ops_read_func(var ptr; size, nmemb: size_t; const datasource): size_t;
{ Returns amount of items completely read successfully, returns indeterminate
  value on error. The value of a partially read item cannot be determined. Does
  not lead to valid feof or ferror responses, because they are not possible to
  supply to VorbisFile }
begin
  if (size = 0) or (nmemb = 0) then
  begin
    result := 0;
    exit;
  end;

  try
    result := Int64(TStream(datasource).Read(ptr, size * nmemb)) div Int64(size);
  except
    result := 0; { Assume nothing was read. No way to be sure of TStreams }
  end;
end;

function ops_seek_func (const datasource; offset: ogg_int64_t; whence: int_t): int_t;
{ Returns zero on success, returns a non-zero value on error, result is undefined
  when device is unseekable. }
begin
  try
    case whence of
      SEEK_CUR: TStream(datasource).Seek(offset, soFromCurrent);
      SEEK_END: TStream(datasource).Seek(offset, soFromEnd);
      SEEK_SET: TStream(datasource).Seek(offset, soFromBeginning);
    end;
    result := 0;
  except
    result := -1;
  end;
end;

function ops_close_func(const datasource): int_t;
{ Returns zero when device was successfully closed, EOF on error. }
begin
  try
    TStream(datasource).Free;
    result := 0;
  except
    result := EOF;
  end;
end;

function ops_tell_func(const datasource): long;
{ Returns the current position of the file pointer on success, returns -1 on
  error, result is undefined when device is unseekable, does not set 'errno',
  does not perform linebreak conversion. }
begin
  try
    result := TStream(datasource).Position;
  except
    result := -1;
  end;
end;

// *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= Smooth DLL IMPLEMENTATION =*=*=*
// *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSDllVorbisFile = class(TSDll)
			public
		class function SystemNames() : TSStringList; override;
		class function DllNames() : TSStringList; override;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;
		class procedure Free(); override;
		end;
class procedure TSDllVorbisFile.Free();
begin
ov_clear := nil;
ov_open := nil;
ov_open_callbacks := nil;
ov_test := nil;
ov_test_callbacks := nil;
ov_test_open := nil;
ov_bitrate := nil;
ov_bitrate_instant := nil;
ov_streams := nil;
ov_seekable := nil;
ov_serialnumber := nil;
ov_raw_total := nil;
ov_pcm_total := nil;
ov_time_total := nil;
ov_raw_seek := nil;
ov_pcm_seek := nil;
ov_pcm_seek_page := nil;
ov_time_seek := nil;
ov_time_seek_page := nil;
ov_raw_tell := nil;
ov_pcm_tell := nil;
ov_time_tell := nil;
ov_info := nil;
ov_comment := nil;
ov_read := nil;
end;
class function TSDllVorbisFile.SystemNames() : TSStringList;
begin
Result := nil;
SAddStringToStringList(Result, 'VorbisFile');
SAddStringToStringList(Result, 'LibVorbisFile');
end;
class function TSDllVorbisFile.DllNames() : TSStringList;
begin
Result := VorbisfileLib;
end;
class function TSDllVorbisFile.Load(const VDll : TSLibHandle) : TSDllLoadObject;
var
	LoadResult : PSDllLoadObject = nil;

function LoadProcedure(const Name : PChar) : Pointer;
begin
Result := GetProcAddress(VDll, Name);
if Result = nil then
	SAddStringToStringList(LoadResult^.FFunctionErrors, SPCharToString(Name))
else
	LoadResult^.FFunctionLoaded += 1;
end;

begin
Result.Clear();
Result.FFunctionCount := 25;
LoadResult := @Result;
ov_clear := LoadProcedure('ov_clear');
ov_open := LoadProcedure('ov_open');
ov_open_callbacks := LoadProcedure('ov_open_callbacks');
ov_test := LoadProcedure('ov_test');
ov_test_callbacks := LoadProcedure('ov_test_callbacks');
ov_test_open := LoadProcedure('ov_test_open');
ov_bitrate := LoadProcedure('ov_bitrate');
ov_bitrate_instant := LoadProcedure('ov_bitrate_instant');
ov_streams := LoadProcedure('ov_streams');
ov_seekable := LoadProcedure('ov_seekable');
ov_serialnumber := LoadProcedure('ov_serialnumber');
ov_raw_total := LoadProcedure('ov_raw_total');
ov_pcm_total := LoadProcedure('ov_pcm_total');
ov_time_total := LoadProcedure('ov_time_total');
ov_raw_seek := LoadProcedure('ov_raw_seek');
ov_pcm_seek := LoadProcedure('ov_pcm_seek');
ov_pcm_seek_page := LoadProcedure('ov_pcm_seek_page');
ov_time_seek := LoadProcedure('ov_time_seek');
ov_time_seek_page := LoadProcedure('ov_time_seek_page');
ov_raw_tell := LoadProcedure('ov_raw_tell');
ov_pcm_tell := LoadProcedure('ov_pcm_tell');
ov_time_tell := LoadProcedure('ov_time_tell');
ov_info := LoadProcedure('ov_info');
ov_comment := LoadProcedure('ov_comment');
ov_read := LoadProcedure('ov_read');
end;

initialization
	ops_callbacks.read_func := ops_read_func;
	ops_callbacks.seek_func := ops_seek_func;
	ops_callbacks.close_func := ops_close_func;
	ops_callbacks.tell_func := ops_tell_func;
	TSDllVorbisFile.Create();
end.
