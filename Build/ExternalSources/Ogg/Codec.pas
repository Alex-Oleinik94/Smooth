unit Codec;

{************************************************************************}
{                                                                        }
{       Object Pascal Runtime Library                                    }
{       Vorbis interface unit                                            }
{                                                                        }
{ The original file is: vorbis/codec.h, released June 2001.              }
{ The original Pascal code is: Codec.pas, released 28 Jul 2001.          }
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
  {$MODE ObjFpc}
  {$IFDEF WIN32}
    {$PACKRECORDS C}
  {$ENDIF WIN32}
{$ENDIF FPC}

interface

uses OSTypes, Ogg;

const
{$IFDEF MSWINDOWS}
  VorbisLib = 'vorbis.dll';
{$ENDIF MSWINDOWS}

{$IFDEF UNIX}
  VorbisLib = 'libvorbis.so';
{$ENDIF UNIX}

{ vorbis/codec.h }

type
  p_vorbis_info = ^vorbis_info;
    vorbis_info = record
      version: int;
      channels: int;
      rate: long;

      (* The below bitrate declarations are *hints*.
         Combinations of the three values carry the following implications:

         all three set to the same value:
           implies a fixed rate bitstream
         only nominal set:
           implies a VBR stream that averages the nominal bitrate.  No hard
           upper/lower limit
         upper and or lower set:
           implies a VBR bitstream that obeys the bitrate limits. nominal
           may also be set to give a nominal rate.
         none set:
           the coder does not care to speculate.
      *)

      bitrate_upper: long;
      bitrate_nominal: long;
      bitrate_lower: long;
      bitrate_window: long;
      codec_setup: Pointer;
    end;

(* vorbis_dsp_state buffers the current vorbis audio
   analysis/synthesis state.  The DSP state belongs to a specific
   logical bitstream ****************************************************)
  p_vorbis_dsp_state = ^vorbis_dsp_state;
    vorbis_dsp_state = record
      analysisp: int;
      vi: p_vorbis_info;
      pcm: p_float_p_float_array;
      pcmret: p_float_p_float_array;
      pcm_storage: int;
      pcm_current: int;
      pcm_returned: int;
      preextrapolate: int;
      eofflag: int;
      lW: long;
      W: long;
      nW: long;
      centerW: long;
      granulepos: ogg_int64_t;
      sequence: ogg_int64_t;
      glue_bits: ogg_int64_t;
      time_bits: ogg_int64_t;
      floor_bits: ogg_int64_t;
      res_bits: ogg_int64_t;
      backend_state: Pointer;
    end;

  p_alloc_chain = ^alloc_chain;
    alloc_chain = record
      ptr: Pointer;
      next: p_alloc_chain;
    end;

(* vorbis_block is a single block of data to be processed as part of
the analysis/synthesis stream; it belongs to a specific logical
bitstream, but is independant from other vorbis_blocks belonging to
that logical bitstream. *************************************************)

  p_vorbis_block = ^vorbis_block;
    vorbis_block = record
      (* necessary stream state for linking to the framing abstraction *)
      pcm: p_float_p_float_array; (* this is a pointer into local storage *)
      opb: oggpack_buffer;
      lW: long;
      W: long;
      nW: long;
      pcmend: int;
      mode: int;

      eofflag: int;
      granulepos: ogg_int64_t;
      sequence: ogg_int64_t;
      vd: p_vorbis_dsp_state; (* For read-only access of configuration *)

      (* local storage to avoid remallocing; it's up to the mapping to
         structure it *)

      localstore: Pointer;
      localtop: long;
      localalloc: long;
      totaluse: long;
      reap: p_alloc_chain;

      (* bitmetrics for the frame *)
      glue_bits: long;
      time_bits: long;
      floor_bits: long;
      res_bits: long;

      internal: Pointer;
          end;

  p_vorbis_comment = ^vorbis_comment;
    vorbis_comment = record
      user_comments: p_pchar_array;
      comment_lengths: p_int_array;
      comments: int;
      vendor: PChar;
    end;

(* Vorbis PRIMITIVES: general ***************************************)
(*


procedure vorbis_info_init(var vi: vorbis_info); cdecl; external VorbisLib;
*)
var vorbis_info_init : procedure( var vi : vorbis_info ) ; cdecl ;

(*

procedure vorbis_info_clear(var vi: vorbis_info); cdecl; external VorbisLib;
*)
var vorbis_info_clear : procedure( var vi : vorbis_info ) ; cdecl ;

(*

procedure vorbis_comment_init(var vc: vorbis_comment); cdecl; external VorbisLib;
*)
var vorbis_comment_init : procedure( var vc : vorbis_comment ) ; cdecl ;

(*

procedure vorbis_comment_add(var vc: vorbis_comment; comment: PChar);  cdecl; external VorbisLib;
*)
var vorbis_comment_add : procedure( var vc : vorbis_comment ; comment : PChar ) ; cdecl ;

(*

procedure vorbis_comment_add_tag(var vc: vorbis_comment; tag: PChar; contents: PChar); cdecl; external VorbisLib;
*)
var vorbis_comment_add_tag : procedure( var vc : vorbis_comment ; tag : PChar ; contents : PChar ) ; cdecl ;

(*


function vorbis_comment_query(var vc: vorbis_comment; tag: PChar; count: int): PChar; cdecl; external VorbisLib;
*)
var vorbis_comment_query : function( var vc : vorbis_comment ; tag : PChar ; count : int ) : PChar ; cdecl ;

(*

function vorbis_comment_query_count(var vc: vorbis_comment; tag: PChar): int; cdecl; external VorbisLib;
*)
var vorbis_comment_query_count : function( var vc : vorbis_comment ; tag : PChar ) : int ; cdecl ;

(*

procedure vorbis_comment_clear(var vc: vorbis_comment); cdecl; external VorbisLib;
*)
var vorbis_comment_clear : procedure( var vc : vorbis_comment ) ; cdecl ;

(*


function vorbis_block_init(var v: vorbis_dsp_state; var vb: vorbis_block): int; cdecl; external VorbisLib;
*)
var vorbis_block_init : function( var v : vorbis_dsp_state ; var vb : vorbis_block ) : int ; cdecl ;

(*

function vorbis_block_clear(var vb: vorbis_block): int; cdecl; external VorbisLib;
*)
var vorbis_block_clear : function( var vb : vorbis_block ) : int ; cdecl ;

(*

procedure vorbis_dsp_clear(var v: vorbis_dsp_state); cdecl; external VorbisLib;
*)
var vorbis_dsp_clear : procedure( var v : vorbis_dsp_state ) ; cdecl ;


(* Vorbis PRIMITIVES: analysis/DSP layer ****************************)
(*


function vorbis_analysis_init(var v: vorbis_dsp_state; var vi: vorbis_info): int; cdecl; external VorbisLib;
*)
var vorbis_analysis_init : function( var v : vorbis_dsp_state ; var vi : vorbis_info ) : int ; cdecl ;

(*

function vorbis_commentheader_out(var vc: vorbis_comment; var op: ogg_packet): int; cdecl; external VorbisLib;
*)
var vorbis_commentheader_out : function( var vc : vorbis_comment ; var op : ogg_packet ) : int ; cdecl ;

(*

function vorbis_analysis_headerout(var v: vorbis_dsp_state; var vc: vorbis_comment; var op: ogg_packet; var op_comm: ogg_packet; var op_code: ogg_packet): int; cdecl; external VorbisLib;
*)
var vorbis_analysis_headerout : function( var v : vorbis_dsp_state ; var vc : vorbis_comment ; var op : ogg_packet ; var op_comm : ogg_packet ; var op_code : ogg_packet ) : int ; cdecl ;

(*

function vorbis_analysis_buffer(var v: vorbis_dsp_state; vals: int): p_float_p_float_array; cdecl; external VorbisLib;
*)
var vorbis_analysis_buffer : function( var v : vorbis_dsp_state ; vals : int ) : p_float_p_float_array ; cdecl ;

(*

function vorbis_analysis_wrote(var v: vorbis_dsp_state; vals: int): int; cdecl; external VorbisLib;
*)
var vorbis_analysis_wrote : function( var v : vorbis_dsp_state ; vals : int ) : int ; cdecl ;

(*

function vorbis_analysis_blockout(var v: vorbis_dsp_state; var vb: vorbis_block): int; cdecl; external VorbisLib;
*)
var vorbis_analysis_blockout : function( var v : vorbis_dsp_state ; var vb : vorbis_block ) : int ; cdecl ;

(*

function vorbis_analysis(var vb: vorbis_block; var op: ogg_packet): int; cdecl; external VorbisLib;
*)
var vorbis_analysis : function( var vb : vorbis_block ; var op : ogg_packet ) : int ; cdecl ;


(* Vorbis PRIMITIVES: synthesis layer *******************************)
(*


function vorbis_synthesis_headerin(var vi: vorbis_info; var vc: vorbis_comment; var op: ogg_packet): int; cdecl; external VorbisLib;
*)
var vorbis_synthesis_headerin : function( var vi : vorbis_info ; var vc : vorbis_comment ; var op : ogg_packet ) : int ; cdecl ;

(*

function vorbis_synthesis_init(var v: vorbis_dsp_state; var vi: vorbis_info): int; cdecl; external VorbisLib;
*)
var vorbis_synthesis_init : function( var v : vorbis_dsp_state ; var vi : vorbis_info ) : int ; cdecl ;

(*

function vorbis_synthesis(var vb: vorbis_block; var op: ogg_packet): int; cdecl; external VorbisLib;
*)
var vorbis_synthesis : function( var vb : vorbis_block ; var op : ogg_packet ) : int ; cdecl ;

(*

function vorbis_synthesis_blockin(var v: vorbis_dsp_state; var vb: vorbis_block): int; cdecl; external VorbisLib;
*)
var vorbis_synthesis_blockin : function( var v : vorbis_dsp_state ; var vb : vorbis_block ) : int ; cdecl ;

(*

function vorbis_synthesis_pcmout(var v: vorbis_dsp_state; pcm: p_p_float_p_float_array): int; cdecl; external VorbisLib;
*)
var vorbis_synthesis_pcmout : function( var v : vorbis_dsp_state ; pcm : p_p_float_p_float_array ) : int ; cdecl ;

(*

function vorbis_synthesis_read(var v: vorbis_dsp_state; samples: int): int; cdecl; external VorbisLib;
*)
var vorbis_synthesis_read : function( var v : vorbis_dsp_state ; samples : int ) : int ; cdecl ;

(*

function vorbis_packet_blocksize(var vi: vorbis_info; var op: ogg_packet): long; cdecl; external VorbisLib;
*)
var vorbis_packet_blocksize : function( var vi : vorbis_info ; var op : ogg_packet ) : long ; cdecl ;
 { New since RC1 }

(* Vorbis ERRORS and return codes ***********************************)

const
  OV_FALSE      = -1;
  OV_EOF        = -2;
  OV_HOLE       = -3;

  OV_EREAD      = -128;
  OV_EFAULT     = -129;
  OV_EIMPL      = -130;
  OV_EINVAL     = -131;
  OV_ENOTVORBIS = -132;
  OV_EBADHEADER = -133;
  OV_EVERSION   = -134;
  OV_ENOTAUDIO  = -135;
  OV_EBADPACKET = -136;
  OV_EBADLINK   = -137;
  OV_ENOSEEK    = -138;

{ Added }
function GetVorbisErrorName(ErrorCode: Integer): string;

implementation

uses
	 SmoothBase
	,SmoothDllManager
	,SmoothStringUtils
	,SmoothSysUtils
	,SmoothLists
	;

function GetVorbisErrorName(ErrorCode: Integer): string;
begin
  case ErrorCode of
    OV_FALSE:      Result := 'OV_FALSE';
    OV_EOF:        Result := 'OV_EOF';
    OV_HOLE:       Result := 'OV_HOLE';
    OV_EREAD:      Result := 'OV_EREAD';
    OV_EFAULT:     Result := 'OV_EFAULT';
    OV_EIMPL:      Result := 'OV_EIMPL';
    OV_EINVAL:     Result := 'OV_EINVAL';
    OV_ENOTVORBIS: Result := 'OV_ENOTVORBIS';
    OV_EBADHEADER: Result := 'OV_EBADHEADER';
    OV_EVERSION:   Result := 'OV_EVERSION';
    OV_ENOTAUDIO:  Result := 'OV_ENOTAUDIO';
    OV_EBADPACKET: Result := 'OV_EBADPACKET';
    OV_EBADLINK:   Result := 'OV_EBADLINK';
    OV_ENOSEEK:    Result := 'OV_ENOSEEK';
  else
    Result := 'Unknown';
  end;
end;

// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= Smooth DLL IMPLEMENTATION =*=*=
// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSDllCodec = class(TSDll)
			public
		class function SystemNames() : TSStringList; override;
		class function DllNames() : TSStringList; override;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;
		class procedure Free(); override;
		end;
class procedure TSDllCodec.Free();
begin
vorbis_info_init := nil;
vorbis_info_clear := nil;
vorbis_comment_init := nil;
vorbis_comment_add := nil;
vorbis_comment_add_tag := nil;
vorbis_comment_query := nil;
vorbis_comment_query_count := nil;
vorbis_comment_clear := nil;
vorbis_block_init := nil;
vorbis_block_clear := nil;
vorbis_dsp_clear := nil;
vorbis_analysis_init := nil;
vorbis_commentheader_out := nil;
vorbis_analysis_headerout := nil;
vorbis_analysis_buffer := nil;
vorbis_analysis_wrote := nil;
vorbis_analysis_blockout := nil;
vorbis_analysis := nil;
vorbis_synthesis_headerin := nil;
vorbis_synthesis_init := nil;
vorbis_synthesis := nil;
vorbis_synthesis_blockin := nil;
vorbis_synthesis_pcmout := nil;
vorbis_synthesis_read := nil;
vorbis_packet_blocksize := nil;
end;
class function TSDllCodec.SystemNames() : TSStringList;
begin
Result := nil;
Result += 'Vorbis';
Result += 'LibVorbis';
end;
class function TSDllCodec.DllNames() : TSStringList;
begin
Result := nil;
Result += VorbisLib;
end;
class function TSDllCodec.Load(const VDll : TSLibHandle) : TSDllLoadObject;
var
	LoadResult : PSDllLoadObject = nil;

function LoadProcedure(const Name : PChar) : Pointer;
begin
Result := GetProcAddress(VDll, Name);
if Result = nil then
LoadResult^.FFunctionErrors += SPCharToString(Name)
else
LoadResult^.FFunctionLoaded += 1;
end;

begin
Result.Clear();
Result.FFunctionCount := 25;
LoadResult := @Result;
Pointer(vorbis_info_init) := LoadProcedure('vorbis_info_init');
Pointer(vorbis_info_clear) := LoadProcedure('vorbis_info_clear');
Pointer(vorbis_comment_init) := LoadProcedure('vorbis_comment_init');
Pointer(vorbis_comment_add) := LoadProcedure('vorbis_comment_add');
Pointer(vorbis_comment_add_tag) := LoadProcedure('vorbis_comment_add_tag');
Pointer(vorbis_comment_query) := LoadProcedure('vorbis_comment_query');
Pointer(vorbis_comment_query_count) := LoadProcedure('vorbis_comment_query_count');
Pointer(vorbis_comment_clear) := LoadProcedure('vorbis_comment_clear');
Pointer(vorbis_block_init) := LoadProcedure('vorbis_block_init');
Pointer(vorbis_block_clear) := LoadProcedure('vorbis_block_clear');
Pointer(vorbis_dsp_clear) := LoadProcedure('vorbis_dsp_clear');
Pointer(vorbis_analysis_init) := LoadProcedure('vorbis_analysis_init');
Pointer(vorbis_commentheader_out) := LoadProcedure('vorbis_commentheader_out');
Pointer(vorbis_analysis_headerout) := LoadProcedure('vorbis_analysis_headerout');
Pointer(vorbis_analysis_buffer) := LoadProcedure('vorbis_analysis_buffer');
Pointer(vorbis_analysis_wrote) := LoadProcedure('vorbis_analysis_wrote');
Pointer(vorbis_analysis_blockout) := LoadProcedure('vorbis_analysis_blockout');
Pointer(vorbis_analysis) := LoadProcedure('vorbis_analysis');
Pointer(vorbis_synthesis_headerin) := LoadProcedure('vorbis_synthesis_headerin');
Pointer(vorbis_synthesis_init) := LoadProcedure('vorbis_synthesis_init');
Pointer(vorbis_synthesis) := LoadProcedure('vorbis_synthesis');
Pointer(vorbis_synthesis_blockin) := LoadProcedure('vorbis_synthesis_blockin');
Pointer(vorbis_synthesis_pcmout) := LoadProcedure('vorbis_synthesis_pcmout');
Pointer(vorbis_synthesis_read) := LoadProcedure('vorbis_synthesis_read');
Pointer(vorbis_packet_blocksize) := LoadProcedure('vorbis_packet_blocksize');
end;

initialization
	TSDllCodec.Create();
end.
