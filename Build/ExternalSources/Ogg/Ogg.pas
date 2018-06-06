unit Ogg;

{************************************************************************}
{                                                                        }
{       Object Pascal Runtime Library                                    }
{       Ogg interface unit                                               }
{                                                                        }
{ The original file is: ogg/ogg.h, released June 2001.                   }
{ The original Pascal code is: Ogg.pas, released 28 Jul 2001.            }
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
  {$MODE DELPHI}
  {$IFDEF WIN32}
    {$PACKRECORDS C}
  {$ENDIF WIN32}
{$ENDIF FPC}

interface

uses OSTypes;

(*
const
{$IFDEF MSWINDOWS}
  OggLib = 'ogg.dll';
{$ENDIF MSWINDOWS}

{$IFDEF UNIX}
  OggLib = 'libogg.so';
{$ENDIF UNIX}
*)

{ ogg/ogg.h }

type
  p_oggpack_buffer = ^oggpack_buffer;
    oggpack_buffer = record
      endbyte: long;
      endbit: int;
      buffer: PChar;
      ptr: PChar;
      storage: long;
    end;

(* ogg_page is used to encapsulate the data in one Ogg bitstream page *****)

  p_ogg_page = ^ogg_page;
    ogg_page = record
      header: Pointer;
      header_len: long;
      body: Pointer;
      body_len: long;
    end;

(* ogg_stream_state contains the current encode/decode state of a logical
   Ogg bitstream **********************************************************)

  p_ogg_stream_state = ^ogg_stream_state;
    ogg_stream_state = record
      body_data: PChar;          (* bytes from packet bodies *)
      body_storage: long;        (* storage elements allocated *)
      body_fill: long;           (* elements stored; fill mark *)
      body_returned: long;       (* elements of fill returned *)

      lacing_vals: p_int_array;                (* The values that will go to the segment table *)
      granule_vals: Pointer; { ogg_int64_t * } (* granulepos values for headers. Not compact
                                                  this way, but it is simple coupled to the
                                                  lacing fifo *)
      lacing_storage: long;
      lacing_fill: long;
      lacing_packet: long;
      lacing_returned: long;

      header: array[0..282] of Char;   (* working space for header encode *)
      header_fill: int;
      e_o_s: int;                      (* set when we have buffered the last packet in the
                                          logical bitstream *)
      b_o_s: int;                      (* set after we've written the initial page
                                          of a logical bitstream *)
      serialno: long;
      pageno: long;
      packetno: ogg_int64_t;           (* sequence number for decode; the framing
                                          knows where there's a hole in the data,
                                          but we need coupling so that the codec
                                          (which is in a seperate abstraction
                                          layer) also knows about the gap *)
      granulepos: ogg_int64_t;
    end;

(* ogg_packet is used to encapsulate the data and metadata belonging
   to a single raw Ogg/Vorbis packet *************************************)

  p_ogg_packet = ^ogg_packet;
    ogg_packet = record
      packet: PChar;
      bytes: long;
      b_o_s: long;
      e_o_s: long;

      granulepos: ogg_int64_t;

      packetno: ogg_int64_t;        (* sequence number for decode; the framing
                                       knows where there's a hole in the data,
                                       but we need coupling so that the codec
                                       (which is in a seperate abstraction
                                       layer) also knows about the gap *)
    end;

  p_ogg_sync_state = ^ogg_sync_state;
    ogg_sync_state = record
      data: PChar;
      storage: int;
      fill: int;
      returned: int;

      unsynced: int;
      headerbytes: int;
      bodybytes: int;
    end;

(* Ogg BITSTREAM PRIMITIVES: bitstream ************************)
(*


procedure oggpack_writeinit(var b: oggpack_buffer); cdecl; external OggLib;
*)
var oggpack_writeinit : procedure( var b : oggpack_buffer ) ; cdecl ;

(*

procedure oggpack_reset(var b: oggpack_buffer); cdecl; external OggLib;
*)
var oggpack_reset : procedure( var b : oggpack_buffer ) ; cdecl ;

(*

procedure oggpack_writeclear(var b: oggpack_buffer); cdecl; external OggLib;
*)
var oggpack_writeclear : procedure( var b : oggpack_buffer ) ; cdecl ;

(*

procedure oggpack_readinit(var b: oggpack_buffer; buf: PChar; bytes: int); cdecl; external OggLib;
*)
var oggpack_readinit : procedure( var b : oggpack_buffer ; buf : PChar ; bytes : int ) ; cdecl ;

(*

procedure oggpack_write(var b: oggpack_buffer; value: unsigned_long; bits: int); cdecl; external OggLib;
*)
var oggpack_write : procedure( var b : oggpack_buffer ; value : unsigned_long ; bits : int ) ; cdecl ;

(*

function oggpack_look(var b: oggpack_buffer; bits: int): long; cdecl; external OggLib;
*)
var oggpack_look : function( var b : oggpack_buffer ; bits : int ) : long ; cdecl ;

(*

function oggpack_look_huff(var b: oggpack_buffer; bits: int): long; cdecl; external OggLib;
*)
var oggpack_look_huff : function( var b : oggpack_buffer ; bits : int ) : long ; cdecl ;

(*

function oggpack_look1(var b: oggpack_buffer): long; cdecl; external OggLib;
*)
var oggpack_look1 : function( var b : oggpack_buffer ) : long ; cdecl ;

(*

procedure oggpack_adv(var b: oggpack_buffer; bits: int); cdecl; external OggLib;
*)
var oggpack_adv : procedure( var b : oggpack_buffer ; bits : int ) ; cdecl ;

(*

function oggpack_adv_huff(var b: oggpack_buffer; bits: int): int; cdecl; external OggLib;
*)
var oggpack_adv_huff : function( var b : oggpack_buffer ; bits : int ) : int ; cdecl ;

(*

procedure oggpack_adv1(var b: oggpack_buffer); cdecl; external OggLib;
*)
var oggpack_adv1 : procedure( var b : oggpack_buffer ) ; cdecl ;

(*

function oggpack_read(var b: oggpack_buffer; bits: int): long; cdecl; external OggLib;
*)
var oggpack_read : function( var b : oggpack_buffer ; bits : int ) : long ; cdecl ;

(*

function oggpack_read1(var b: oggpack_buffer): long; cdecl; external OggLib;
*)
var oggpack_read1 : function( var b : oggpack_buffer ) : long ; cdecl ;

(*

function oggpack_bytes(var b: oggpack_buffer): long; cdecl; external OggLib;
*)
var oggpack_bytes : function( var b : oggpack_buffer ) : long ; cdecl ;

(*

function oggpack_bits(var b: oggpack_buffer): long; cdecl; external OggLib;
*)
var oggpack_bits : function( var b : oggpack_buffer ) : long ; cdecl ;

(*

function oggpack_get_buffer(var b: oggpack_buffer): PChar; cdecl; external OggLib;
*)
var oggpack_get_buffer : function( var b : oggpack_buffer ) : PChar ; cdecl ;



(* Ogg BITSTREAM PRIMITIVES: encoding **************************)
(*


function ogg_stream_packetin(var os: ogg_stream_state; var op: ogg_packet): int; cdecl; external OggLib;
*)
var ogg_stream_packetin : function( var os : ogg_stream_state ; var op : ogg_packet ) : int ; cdecl ;

(*

function ogg_stream_pageout(var os: ogg_stream_state; var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_stream_pageout : function( var os : ogg_stream_state ; var og : ogg_page ) : int ; cdecl ;

(*

function ogg_stream_flush(var os: ogg_stream_state; var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_stream_flush : function( var os : ogg_stream_state ; var og : ogg_page ) : int ; cdecl ;


(* Ogg BITSTREAM PRIMITIVES: decoding **************************)
(*


function ogg_sync_init(var oy: ogg_sync_state): int; cdecl; external OggLib;
*)
var ogg_sync_init : function( var oy : ogg_sync_state ) : int ; cdecl ;

(*

function ogg_sync_clear(var oy: ogg_sync_state): int; cdecl; external OggLib;
*)
var ogg_sync_clear : function( var oy : ogg_sync_state ) : int ; cdecl ;

(*

function ogg_sync_reset(var oy: ogg_sync_state): int; cdecl; external OggLib;
*)
var ogg_sync_reset : function( var oy : ogg_sync_state ) : int ; cdecl ;

(*

function ogg_sync_destroy(var oy: ogg_sync_state): int; cdecl; external OggLib;
*)
var ogg_sync_destroy : function( var oy : ogg_sync_state ) : int ; cdecl ;

(*


function ogg_sync_buffer(var oy: ogg_sync_state; size: long): PChar; cdecl; external OggLib;
*)
var ogg_sync_buffer : function( var oy : ogg_sync_state ; size : long ) : PChar ; cdecl ;

(*

function ogg_sync_wrote(var oy: ogg_sync_state; bytes: long): int; cdecl; external OggLib;
*)
var ogg_sync_wrote : function( var oy : ogg_sync_state ; bytes : long ) : int ; cdecl ;

(*

function ogg_sync_pageseek(var oy: ogg_sync_state; var og: ogg_page): long; cdecl; external OggLib;
*)
var ogg_sync_pageseek : function( var oy : ogg_sync_state ; var og : ogg_page ) : long ; cdecl ;

(*

function ogg_sync_pageout(var oy: ogg_sync_state; var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_sync_pageout : function( var oy : ogg_sync_state ; var og : ogg_page ) : int ; cdecl ;

(*

function ogg_stream_pagein(var os: ogg_stream_state; var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_stream_pagein : function( var os : ogg_stream_state ; var og : ogg_page ) : int ; cdecl ;

(*

function ogg_stream_packetout(var os: ogg_stream_state; var op: ogg_packet): int; cdecl; external OggLib;
*)
var ogg_stream_packetout : function( var os : ogg_stream_state ; var op : ogg_packet ) : int ; cdecl ;

(*

function ogg_stream_packetpeek(var os: ogg_stream_state; var op: ogg_packet): int; cdecl; external OggLib; { New since RC1 }
*)
var ogg_stream_packetpeek : function( var os : ogg_stream_state ; var op : ogg_packet ) : int ; cdecl ;

(* Ogg BITSTREAM PRIMITIVES: general ***************************)
(*


function ogg_stream_init(var os: ogg_stream_state; serialno: int): int; cdecl; external OggLib;
*)
var ogg_stream_init : function( var os : ogg_stream_state ; serialno : int ) : int ; cdecl ;

(*

function ogg_stream_clear(var os: ogg_stream_state): int; cdecl; external OggLib;
*)
var ogg_stream_clear : function( var os : ogg_stream_state ) : int ; cdecl ;

(*

function ogg_stream_reset(var os: ogg_stream_state): int; cdecl; external OggLib;
*)
var ogg_stream_reset : function( var os : ogg_stream_state ) : int ; cdecl ;

(*

function ogg_stream_destroy(var os: ogg_stream_state): int; cdecl; external OggLib;
*)
var ogg_stream_destroy : function( var os : ogg_stream_state ) : int ; cdecl ;

(*

function ogg_stream_eos(var os: ogg_stream_state): int; cdecl; external OggLib;
*)
var ogg_stream_eos : function( var os : ogg_stream_state ) : int ; cdecl ;

(*


function ogg_page_version(var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_page_version : function( var og : ogg_page ) : int ; cdecl ;

(*

function ogg_page_continued(var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_page_continued : function( var og : ogg_page ) : int ; cdecl ;

(*

function ogg_page_bos(var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_page_bos : function( var og : ogg_page ) : int ; cdecl ;

(*

function ogg_page_eos(var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_page_eos : function( var og : ogg_page ) : int ; cdecl ;

(*

function ogg_page_granulepos(var og: ogg_page): ogg_int64_t; cdecl; external OggLib;
*)
var ogg_page_granulepos : function( var og : ogg_page ) : ogg_int64_t ; cdecl ;

(*

function ogg_page_serialno(var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_page_serialno : function( var og : ogg_page ) : int ; cdecl ;

(*

function ogg_page_pageno(var og: ogg_page): long; cdecl; external OggLib;
*)
var ogg_page_pageno : function( var og : ogg_page ) : long ; cdecl ;

(*

function ogg_page_packets(var og: ogg_page): int; cdecl; external OggLib;
*)
var ogg_page_packets : function( var og : ogg_page ) : int ; cdecl ;

(*


procedure ogg_packet_clear(var op: ogg_packet); cdecl; external OggLib;
*)
var ogg_packet_clear : procedure( var op : ogg_packet ) ; cdecl ;


implementation

uses
	 SaGeBase
	,SaGeDllManager
	,SaGeStringUtils
	,SaGeSysUtils
	,SaGeLists
	;

// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= SaGe DLL IMPLEMENTATION =*=*=*=
// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSGDllOGG = class(TSGDll)
			public
		class function SystemNames() : TSGStringList; override;
		class function DllNames() : TSGStringList; override;
		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; override;
		class procedure Free(); override;
		end;

class function TSGDllOGG.SystemNames() : TSGStringList;
begin
Result := 'Ogg';
Result += 'LibOgg';
end;

class function TSGDllOGG.DllNames() : TSGStringList;
begin
Result := DllPrefix + 'ogg' + DllPostfix;
{$IFDEF MSWINDOWS}
Result += DllPrefix + 'libogg' + DllPostfix;
{$ENDIF}
end;

class procedure TSGDllOGG.Free();
begin
oggpack_writeinit := nil;
oggpack_reset := nil;
oggpack_writeclear := nil;
oggpack_readinit := nil;
oggpack_write := nil;
oggpack_look := nil;
oggpack_look_huff := nil;
oggpack_look1 := nil;
oggpack_adv := nil;
oggpack_adv_huff := nil;
oggpack_adv1 := nil;
oggpack_read := nil;
oggpack_read1 := nil;
oggpack_bytes := nil;
oggpack_bits := nil;
oggpack_get_buffer := nil;
ogg_stream_packetin := nil;
ogg_stream_pageout := nil;
ogg_stream_flush := nil;
ogg_sync_init := nil;
ogg_sync_clear := nil;
ogg_sync_reset := nil;
ogg_sync_destroy := nil;
ogg_sync_buffer := nil;
ogg_sync_wrote := nil;
ogg_sync_pageseek := nil;
ogg_sync_pageout := nil;
ogg_stream_pagein := nil;
ogg_stream_packetout := nil;
ogg_stream_packetpeek := nil;
ogg_stream_init := nil;
ogg_stream_clear := nil;
ogg_stream_reset := nil;
ogg_stream_destroy := nil;
ogg_stream_eos := nil;
ogg_page_version := nil;
ogg_page_continued := nil;
ogg_page_bos := nil;
ogg_page_eos := nil;
ogg_page_granulepos := nil;
ogg_page_serialno := nil;
ogg_page_pageno := nil;
ogg_page_packets := nil;
ogg_packet_clear := nil;
end;

class function TSGDllOGG.Load(const VDll : TSGLibHandle) : TSGDllLoadObject;
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
Result.FFunctionCount := 44;
LoadResult := @Result;
oggpack_writeinit := LoadProcedure('oggpack_writeinit');
oggpack_reset := LoadProcedure('oggpack_reset');
oggpack_writeclear := LoadProcedure('oggpack_writeclear');
oggpack_readinit := LoadProcedure('oggpack_readinit');
oggpack_write := LoadProcedure('oggpack_write');
oggpack_look := LoadProcedure('oggpack_look');
oggpack_look_huff := LoadProcedure('oggpack_look_huff');
oggpack_look1 := LoadProcedure('oggpack_look1');
oggpack_adv := LoadProcedure('oggpack_adv');
oggpack_adv_huff := LoadProcedure('oggpack_adv_huff');
oggpack_adv1 := LoadProcedure('oggpack_adv1');
oggpack_read := LoadProcedure('oggpack_read');
oggpack_read1 := LoadProcedure('oggpack_read1');
oggpack_bytes := LoadProcedure('oggpack_bytes');
oggpack_bits := LoadProcedure('oggpack_bits');
oggpack_get_buffer := LoadProcedure('oggpack_get_buffer');
ogg_stream_packetin := LoadProcedure('ogg_stream_packetin');
ogg_stream_pageout := LoadProcedure('ogg_stream_pageout');
ogg_stream_flush := LoadProcedure('ogg_stream_flush');
ogg_sync_init := LoadProcedure('ogg_sync_init');
ogg_sync_clear := LoadProcedure('ogg_sync_clear');
ogg_sync_reset := LoadProcedure('ogg_sync_reset');
ogg_sync_destroy := LoadProcedure('ogg_sync_destroy');
ogg_sync_buffer := LoadProcedure('ogg_sync_buffer');
ogg_sync_wrote := LoadProcedure('ogg_sync_wrote');
ogg_sync_pageseek := LoadProcedure('ogg_sync_pageseek');
ogg_sync_pageout := LoadProcedure('ogg_sync_pageout');
ogg_stream_pagein := LoadProcedure('ogg_stream_pagein');
ogg_stream_packetout := LoadProcedure('ogg_stream_packetout');
ogg_stream_packetpeek := LoadProcedure('ogg_stream_packetpeek');
ogg_stream_init := LoadProcedure('ogg_stream_init');
ogg_stream_clear := LoadProcedure('ogg_stream_clear');
ogg_stream_reset := LoadProcedure('ogg_stream_reset');
ogg_stream_destroy := LoadProcedure('ogg_stream_destroy');
ogg_stream_eos := LoadProcedure('ogg_stream_eos');
ogg_page_version := LoadProcedure('ogg_page_version');
ogg_page_continued := LoadProcedure('ogg_page_continued');
ogg_page_bos := LoadProcedure('ogg_page_bos');
ogg_page_eos := LoadProcedure('ogg_page_eos');
ogg_page_granulepos := LoadProcedure('ogg_page_granulepos');
ogg_page_serialno := LoadProcedure('ogg_page_serialno');
ogg_page_pageno := LoadProcedure('ogg_page_pageno');
ogg_page_packets := LoadProcedure('ogg_page_packets');
ogg_packet_clear := LoadProcedure('ogg_packet_clear');
end;

initialization
	TSGDllOGG.Create();
end.
