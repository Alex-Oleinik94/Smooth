{$MODE DELPHI}
unit Pcap;

  { -*- Mode: c; tab-width: 8; indent-tabs-mode: 1; c-basic-offset: 8; -*-  }
  {
   * Copyright (c) 1993, 1994, 1995, 1996, 1997
   *	The Regents of the University of California.  All rights reserved.
   *
   * Redistribution and use in source and binary forms, with or without
   * modification, are permitted provided that the following conditions
   * are met:
   * 1. Redistributions of source code must retain the above copyright
   *    notice, this list of conditions and the following disclaimer.
   * 2. Redistributions in binary form must reproduce the above copyright
   *    notice, this list of conditions and the following disclaimer in the
   *    documentation and/or other materials provided with the distribution.
   * 3. All advertising materials mentioning features or use of this software
   *    must display the following acknowledgement:
   *	This product includes software developed by the Computer Systems
   *	Engineering Group at Lawrence Berkeley Laboratory.
   * 4. Neither the name of the University nor of the Laboratory may be used
   *    to endorse or promote products derived from this software without
   *    specific prior written permission.
   *
   * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
   * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
   * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
   * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
   * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
   * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
   * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
   * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
   * SUCH DAMAGE.
   *
   * $FreeBSD: src/contrib/libpcap/pcap.h,v 1.11 2005/07/11 03:43:25 sam Exp $
   * @(#) $Header: /tcpdump/master/libpcap/pcap.h,v 1.52 2004/12/18 08:52:11 guy Exp $ (LBL)
    }

interface

uses
  {$ifdef UNIX}
  UnixType,BaseUnix,
  {$endif}
  {$ifdef Windows}
  WinSock, Windows,
  {$endif}
  Types, Sockets;

{$IFDEF FPC}
  {$PACKRECORDS C}
  {$ifndef NO_SMART_LINK}
    {$smartlink on}
  {$endif}
{$ENDIF}

  const
     {$ifdef unix}
     {$linklib c}
     PCAP_LIB_NAME = 'libpcap';
     {$endif}
     {$ifdef WINDOWS}
     PCAP_LIB_NAME = 'wpcap';
     {$endif}
     PCAP_VERSION_MAJOR = 2;
     PCAP_VERSION_MINOR = 4;
     PCAP_ERRBUF_SIZE = 256;
  { interface is loopback  }
     PCAP_IF_LOOPBACK = $00000001;
  {
   * The first record in the file contains saved values for some
   * of the flags used in the printout phases of tcpdump.
   * Many fields here are 32 bit ints so compilers won't insert unwanted
   * padding; these files need to be interchangeable across architectures.
   *
   * Do not change the layout of this structure, in any way (this includes
   * changes that only affect the length of fields in this structure).
   *
   * Also, do not change the interpretation of any of the members of this
   * structure, in any way (this includes using values other than
   * LINKTYPE_ values, as defined in "savefile.c", in the "linktype"
   * field).
   *
   * Instead:
   *
   *	introduce a new structure for the new format, if the layout
   *	of the structure changed;
   *
   *	send mail to "tcpdump-workers@tcpdump.org", requesting a new
   *	magic number for your new capture file format, and, when
   *	you get the new magic number, put it in "savefile.c";
   *
   *	use that magic number for save files with the changed file
   *	header;
   *
   *	make the code in "savefile.c" capable of reading files with
   *	the old file header as well as files with the new file header
   *	(using the magic number to determine the header format).
   *
   * Then supply the changes to "patches@tcpdump.org", so that future
   * versions of libpcap and programs that use it (such as tcpdump) will
   * be able to read your new capture file format.
    }
  { gmt to local correction  }
  { accuracy of timestamps  }
  { max length saved portion of each pkt  }
  { data link type (LINKTYPE_ * )  }
  type
     PPLongint = ^PLongint;
     PPcap_File_Header = ^TPcap_File_Header;
     TPcap_File_Header = record
       magic : DWord;
       version_major : Word;
       version_minor : Word;
       thiszone : Longint;
       sigfigs : DWord;
       snaplen : DWord;
       linktype : DWord;
     end;
     PBPF_Insn = ^TBPF_Insn;
     TBPF_Insn = record
       code: Word;
       jt: Byte;
       jf: Byte;
       k: DWord;
     end;
     PBPF_Program = ^TBPF_Program;
     TBPF_Program = record
       bf_len: PtrInt;
       bf_insns: PBPF_Insn;
     end;
     PDirection = ^TDirection;
     TDirection = (D_INOUT, D_IN, D_OUT);
  {
   * Each packet in the dump file is prepended with this generic header.
   * This gets around the problem of different headers for different
   * packet interfaces.
    }
  { time stamp  }
  { length of portion present  }
  { length this packet (off wire)  }
     PPPcap_Pkthdr = ^PPcap_Pkthdr;
     PPcap_Pkthdr = ^TPcap_Pkthdr;
     TPcap_Pkthdr = record
       ts : TTimeVal;
       caplen : DWord;
       len : DWord;
     end;
  {
   * As returned by the pcap_stats()
    }
  { number of packets received  }
  { number of packets dropped  }
  { drops by interface XXX not yet supported  }
     PPcap_Stat = ^TPcap_Stat;
     TPcap_Stat = record
       ps_recv   : DWord;
       ps_drop   : DWord;
       ps_ifdrop : DWord;
       bs_capt   : DWord;
     end;
  {
   * Representation of an interface address.
    }
  { address  }
  { netmask for that address  }
  { broadcast address for that address  }
  { P2P destination address for that address  }
     PPcap_Addr = ^TPcap_Addr;
     TPcap_Addr = record
       next : PPcap_Addr;
       addr : PSockAddr;
       netmask : PSockAddr;
       broadaddr : PSockAddr;
       dstaddr : PSockAddr;
     end;
  {
   * Item in a list of interfaces.
    }
  { name to hand to "pcap_open_live()"  }
  { textual description of interface, or NULL  }
  { PCAP_IF_ interface flags  }
     PPPcap_If = ^PPcap_If;
     PPcap_If = ^TPcap_If;
     TPcap_If = record
       next : PPcap_If;
       name : PChar;
       description : PChar;
       addresses : PPcap_Addr;
       flags : DWord;
     end;
     
  { obfuscated C types }
     PPcap = ^TPcap;
     TPcap = record end;
     PPcapDumper = ^TPcapDumper;
     TPcapDumper = record end;
     TPcapHandler = procedure (para1: PChar; Header: PPcap_Pkthdr; Data: PChar); cdecl;
(*

  function pcap_lookupdev(ErrBuf: PChar): PChar; cdecl; external PCAP_LIB_NAME;
*)
var pcap_lookupdev : function( ErrBuf : PChar ) : PChar ; cdecl ; 

(*

  function pcap_lookupnet(Device: PChar; NetP: PDword;
                          MaskP: PDword; ErrBuf: PChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_lookupnet : function( Device : PChar ; NetP : PDword ; MaskP : PDword ; ErrBuf : PChar ) : Longint ; cdecl ; 

(*

  function pcap_open_live(Device : PChar; SnapLen: Longint; Promisc: Longint;
                          to_ms: Longint; ebuf: PChar): PPcap; cdecl; external PCAP_LIB_NAME;
*)
var pcap_open_live : function( Device : PChar ; SnapLen : Longint ; Promisc : Longint ; to_ms : Longint ; ebuf : PChar ) : PPcap ; cdecl ; 

(*

  function pcap_open_dead(LinkType: Longint; SnapLen: Longint): PPcap; cdecl; external PCAP_LIB_NAME;
*)
var pcap_open_dead : function( LinkType : Longint ; SnapLen : Longint ) : PPcap ; cdecl ; 

(*

  function pcap_open_offline(FileName: PChar; ErrBuf: PChar): PPcap; cdecl; external PCAP_LIB_NAME;
*)
var pcap_open_offline : function( FileName : PChar ; ErrBuf : PChar ) : PPcap ; cdecl ; 

//  function pcap_fopen_offline(para1:PFILE; para2:PChar): PPcap; cdecl; external PCAP_LIB_NAME;
(*

  procedure pcap_close(p :PPcap); cdecl; external PCAP_LIB_NAME;
*)
var pcap_close : procedure( p : PPcap ) ; cdecl ; 

(*

  function pcap_loop(p: PPcap; cnt: Longint; Callback: TPCapHandler; User: PChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_loop : function( p : PPcap ; cnt : Longint ; Callback : TPCapHandler ; User : PChar ) : Longint ; cdecl ; 

(*

  function pcap_dispatch(p: PPcap; cnt: Longint; Callback: TPCapHandler; User: PChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_dispatch : function( p : PPcap ; cnt : Longint ; Callback : TPCapHandler ; User : PChar ) : Longint ; cdecl ; 

(*

  function pcap_next(para1: PPcap; para2:PPcap_Pkthdr): PChar; cdecl; external PCAP_LIB_NAME;
*)
var pcap_next : function( para1 : PPcap ; para2 : PPcap_Pkthdr ) : PChar ; cdecl ; 

(*

  function pcap_next_ex(para1: PPcap; para2:PPPcap_Pkthdr; para3:PPChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_next_ex : function( para1 : PPcap ; para2 : PPPcap_Pkthdr ; para3 : PPChar ) : Longint ; cdecl ; 

(*

  procedure pcap_breakloop(para1:PPcap); cdecl; external PCAP_LIB_NAME;
*)
var pcap_breakloop : procedure( para1 : PPcap ) ; cdecl ; 

(*

  function pcap_stats(para1: PPcap; para2:PPcap_Stat): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_stats : function( para1 : PPcap ; para2 : PPcap_Stat ) : Longint ; cdecl ; 

(*

  function pcap_setfilter(para1: PPcap; para2:PBPF_Program): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_setfilter : function( para1 : PPcap ; para2 : PBPF_Program ) : Longint ; cdecl ; 

(*

  function pcap_setdirection(para1: PPcap; para2:TDirection): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_setdirection : function( para1 : PPcap ; para2 : TDirection ) : Longint ; cdecl ; 

(*

  function pcap_getnonblock(para1: PPcap; para2:PChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_getnonblock : function( para1 : PPcap ; para2 : PChar ) : Longint ; cdecl ; 

(*

  function pcap_setnonblock(para1: PPcap; para2: Longint; para3:PChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_setnonblock : function( para1 : PPcap ; para2 : Longint ; para3 : PChar ) : Longint ; cdecl ; 

(*

  procedure pcap_perror(para1: PPcap; para2:PChar); cdecl; external PCAP_LIB_NAME;
*)
var pcap_perror : procedure( para1 : PPcap ; para2 : PChar ) ; cdecl ; 

(*

  function pcap_inject(para1: PPcap; para2:pointer; para3: TSize): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_inject : function( para1 : PPcap ; para2 : pointer ; para3 : TSize ) : Longint ; cdecl ; 

(*

  function pcap_sendpacket(para1: PPcap; para2: PChar; para3:Longint): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_sendpacket : function( para1 : PPcap ; para2 : PChar ; para3 : Longint ) : Longint ; cdecl ; 

(*

  function pcap_strerror(para1:Longint): PChar; cdecl; external PCAP_LIB_NAME;
*)
var pcap_strerror : function( para1 : Longint ) : PChar ; cdecl ; 

(*

  function pcap_geterr(para1:PPcap): PChar; cdecl; external PCAP_LIB_NAME;
*)
var pcap_geterr : function( para1 : PPcap ) : PChar ; cdecl ; 

(*

  function pcap_compile(para1: PPcap; para2:PBPF_Program; para3: PChar; para4: Longint; para5:DWord): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_compile : function( para1 : PPcap ; para2 : PBPF_Program ; para3 : PChar ; para4 : Longint ; para5 : DWord ) : Longint ; cdecl ; 

(*

  function pcap_compile_nopcap(para1: Longint; para2: Longint; para3:PBPF_Program; para4: PChar; para5: Longint;
             para6:DWord): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_compile_nopcap : function( para1 : Longint ; para2 : Longint ; para3 : PBPF_Program ; para4 : PChar ; para5 : Longint ; para6 : DWord ) : Longint ; cdecl ; 

(*

  procedure pcap_freecode(para1:PBPF_Program); cdecl; external PCAP_LIB_NAME;
*)
var pcap_freecode : procedure( para1 : PBPF_Program ) ; cdecl ; 

(*

  function pcap_datalink(para1:PPcap): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_datalink : function( para1 : PPcap ) : Longint ; cdecl ; 

(*

  function pcap_list_datalinks(para1: PPcap; para2:PPLongint): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_list_datalinks : function( para1 : PPcap ; para2 : PPLongint ) : Longint ; cdecl ; 

(*

  function pcap_set_datalink(para1: PPcap; para2:Longint): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_set_datalink : function( para1 : PPcap ; para2 : Longint ) : Longint ; cdecl ; 

(*

  function pcap_datalink_name_to_val(para1:PChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_datalink_name_to_val : function( para1 : PChar ) : Longint ; cdecl ; 

(*

  function pcap_datalink_val_to_name(para1:Longint): PChar; cdecl; external PCAP_LIB_NAME;
*)
var pcap_datalink_val_to_name : function( para1 : Longint ) : PChar ; cdecl ; 

(*

  function pcap_datalink_val_to_description(para1:Longint): PChar; cdecl; external PCAP_LIB_NAME;
*)
var pcap_datalink_val_to_description : function( para1 : Longint ) : PChar ; cdecl ; 

(*

  function pcap_snapshot(para1:PPcap): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_snapshot : function( para1 : PPcap ) : Longint ; cdecl ; 

(*

  function pcap_is_swapped(para1:PPcap): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_is_swapped : function( para1 : PPcap ) : Longint ; cdecl ; 

(*

  function pcap_major_version(para1:PPcap): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_major_version : function( para1 : PPcap ) : Longint ; cdecl ; 

(*

  function pcap_minor_version(para1:PPcap): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_minor_version : function( para1 : PPcap ) : Longint ; cdecl ; 

  { XXX  }
//  function pcap_file(para1:PPcap):PFILE; cdecl; external PCAP_LIB_NAME;
(*

  function pcap_fileno(para1:PPcap): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_fileno : function( para1 : PPcap ) : Longint ; cdecl ; 

(*

  function pcap_dump_open(para1: PPcap; para2:PChar):PPCapDumper; cdecl; external PCAP_LIB_NAME;
*)
var pcap_dump_open : function( para1 : PPcap ; para2 : PChar ) : PPCapDumper ; cdecl ; 

//  function pcap_dump_fopen(para1: PPcap; fp:PFILE):PPCapDumper; cdecl; external PCAP_LIB_NAME;
//  function pcap_dump_file(para1:PPCapDumper):PFILE; cdecl; external PCAP_LIB_NAME;
(*

  function pcap_dump_ftell(para1:PPCapDumper): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_dump_ftell : function( para1 : PPCapDumper ) : Longint ; cdecl ; 

(*

  function pcap_dump_flush(para1:PPCapDumper): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_dump_flush : function( para1 : PPCapDumper ) : Longint ; cdecl ; 

(*

  procedure pcap_dump_close(para1:PPCapDumper); cdecl; external PCAP_LIB_NAME;
*)
var pcap_dump_close : procedure( para1 : PPCapDumper ) ; cdecl ; 

(*

  procedure pcap_dump(para1: PChar; para2:PPcap_Pkthdr; para3:PChar); cdecl; external PCAP_LIB_NAME;
*)
var pcap_dump : procedure( para1 : PChar ; para2 : PPcap_Pkthdr ; para3 : PChar ) ; cdecl ; 

(*

  function pcap_findalldevs(para1:PPPcap_If; para2:PChar): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_findalldevs : function( para1 : PPPcap_If ; para2 : PChar ) : Longint ; cdecl ; 

(*

  procedure pcap_freealldevs(para1:PPcap_If); cdecl; external PCAP_LIB_NAME;
*)
var pcap_freealldevs : procedure( para1 : PPcap_If ) ; cdecl ; 

(*

  function pcap_lib_version: PChar; cdecl; external PCAP_LIB_NAME;
*)
var pcap_lib_version : function: PChar ; cdecl ; 

  { XXX this guy lives in the bpf tree  }
(*

  function bpf_filter(para1:Pbpf_insn; para2: PChar; para3:PtrInt; para4:PtrInt):PtrInt; cdecl; external PCAP_LIB_NAME;
*)
var bpf_filter : function( para1 : Pbpf_insn ; para2 : PChar ; para3 : PtrInt ; para4 : PtrInt ) : PtrInt ; cdecl ; 

(*

  function bpf_validate(f:Pbpf_insn; len:Longint): Longint; cdecl; external PCAP_LIB_NAME;
*)
var bpf_validate : function( f : Pbpf_insn ; len : Longint ) : Longint ; cdecl ; 

(*

  function bpf_image(para1:Pbpf_insn; para2:Longint): PChar; cdecl; external PCAP_LIB_NAME;
*)
var bpf_image : function( para1 : Pbpf_insn ; para2 : Longint ) : PChar ; cdecl ; 

(*

  procedure bpf_dump(para1:PBPF_Program; para2:Longint); cdecl; external PCAP_LIB_NAME;
*)
var bpf_dump : procedure( para1 : PBPF_Program ; para2 : Longint ) ; cdecl ; 

{$ifdef WINDOWS}
(*

  function pcap_setbuff(p: PPcap; dim:Longint): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_setbuff : function( p : PPcap ; dim : Longint ) : Longint ; cdecl ; 

(*

  function pcap_setmode(p: PPcap; mode:Longint): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_setmode : function( p : PPcap ; mode : Longint ) : Longint ; cdecl ; 

(*

  function pcap_setmintocopy(p: PPcap; size:Longint): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_setmintocopy : function( p : PPcap ; size : Longint ) : Longint ; cdecl ; 

{$endif}
{$ifdef unix}
(*

  function pcap_get_selectable_fd(para1:PPcap): Longint; cdecl; external PCAP_LIB_NAME;
*)
var pcap_get_selectable_fd : function( para1 : PPcap ) : Longint ; cdecl ; 

{$endif}


implementation

uses 
	 SmoothBase
	,SmoothLists
	,SmoothDllManager
	,SmoothSysUtils
	,SmoothStringUtils
	;

// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= Smooth DLL IMPLEMENTATION =*=*=
// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSDllPcap = class(TSDll)
			public
		class function SystemNames() : TSStringList; override;
		class function DllNames() : TSStringList; override;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; override;
		class procedure Free(); override;
		end;
class procedure TSDllPcap.Free();
begin
pcap_lookupdev := nil;
pcap_lookupnet := nil;
pcap_open_live := nil;
pcap_open_dead := nil;
pcap_open_offline := nil;
pcap_close := nil;
pcap_loop := nil;
pcap_dispatch := nil;
pcap_next := nil;
pcap_next_ex := nil;
pcap_breakloop := nil;
pcap_stats := nil;
pcap_setfilter := nil;
pcap_setdirection := nil;
pcap_getnonblock := nil;
pcap_setnonblock := nil;
pcap_perror := nil;
pcap_inject := nil;
pcap_sendpacket := nil;
pcap_strerror := nil;
pcap_geterr := nil;
pcap_compile := nil;
pcap_compile_nopcap := nil;
pcap_freecode := nil;
pcap_datalink := nil;
pcap_list_datalinks := nil;
pcap_set_datalink := nil;
pcap_datalink_name_to_val := nil;
pcap_datalink_val_to_name := nil;
pcap_datalink_val_to_description := nil;
pcap_snapshot := nil;
pcap_is_swapped := nil;
pcap_major_version := nil;
pcap_minor_version := nil;
pcap_fileno := nil;
pcap_dump_open := nil;
pcap_dump_ftell := nil;
pcap_dump_flush := nil;
pcap_dump_close := nil;
pcap_dump := nil;
pcap_findalldevs := nil;
pcap_freealldevs := nil;
pcap_lib_version := nil;
bpf_filter := nil;
bpf_validate := nil;
bpf_image := nil;
bpf_dump := nil;
{$ifdef WINDOWS}
pcap_setbuff := nil;
pcap_setmode := nil;
pcap_setmintocopy := nil;
{$endif}
{$ifdef unix}
pcap_get_selectable_fd := nil;
{$endif}
end;
class function TSDllPcap.SystemNames() : TSStringList;
begin
Result := nil;
Result += 'Pcap';
end;
class function TSDllPcap.DllNames() : TSStringList;
begin
Result := nil;
Result += PCAP_LIB_NAME;
end;
class function TSDllPcap.Load(const VDll : TSLibHandle) : TSDllLoadObject;
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
Result.FFunctionCount := 51 - 4;
{$ifdef WINDOWS}
Result.FFunctionCount += 3;
{$endif}
{$ifdef unix}
Result.FFunctionCount += 1;
{$endif}
LoadResult := @Result;
pcap_lookupdev := LoadProcedure('pcap_lookupdev');
pcap_lookupnet := LoadProcedure('pcap_lookupnet');
pcap_open_live := LoadProcedure('pcap_open_live');
pcap_open_dead := LoadProcedure('pcap_open_dead');
pcap_open_offline := LoadProcedure('pcap_open_offline');
pcap_close := LoadProcedure('pcap_close');
pcap_loop := LoadProcedure('pcap_loop');
pcap_dispatch := LoadProcedure('pcap_dispatch');
pcap_next := LoadProcedure('pcap_next');
pcap_next_ex := LoadProcedure('pcap_next_ex');
pcap_breakloop := LoadProcedure('pcap_breakloop');
pcap_stats := LoadProcedure('pcap_stats');
pcap_setfilter := LoadProcedure('pcap_setfilter');
pcap_setdirection := LoadProcedure('pcap_setdirection');
pcap_getnonblock := LoadProcedure('pcap_getnonblock');
pcap_setnonblock := LoadProcedure('pcap_setnonblock');
pcap_perror := LoadProcedure('pcap_perror');
pcap_inject := LoadProcedure('pcap_inject');
pcap_sendpacket := LoadProcedure('pcap_sendpacket');
pcap_strerror := LoadProcedure('pcap_strerror');
pcap_geterr := LoadProcedure('pcap_geterr');
pcap_compile := LoadProcedure('pcap_compile');
pcap_compile_nopcap := LoadProcedure('pcap_compile_nopcap');
pcap_freecode := LoadProcedure('pcap_freecode');
pcap_datalink := LoadProcedure('pcap_datalink');
pcap_list_datalinks := LoadProcedure('pcap_list_datalinks');
pcap_set_datalink := LoadProcedure('pcap_set_datalink');
pcap_datalink_name_to_val := LoadProcedure('pcap_datalink_name_to_val');
pcap_datalink_val_to_name := LoadProcedure('pcap_datalink_val_to_name');
pcap_datalink_val_to_description := LoadProcedure('pcap_datalink_val_to_description');
pcap_snapshot := LoadProcedure('pcap_snapshot');
pcap_is_swapped := LoadProcedure('pcap_is_swapped');
pcap_major_version := LoadProcedure('pcap_major_version');
pcap_minor_version := LoadProcedure('pcap_minor_version');
pcap_fileno := LoadProcedure('pcap_fileno');
pcap_dump_open := LoadProcedure('pcap_dump_open');
pcap_dump_ftell := LoadProcedure('pcap_dump_ftell');
pcap_dump_flush := LoadProcedure('pcap_dump_flush');
pcap_dump_close := LoadProcedure('pcap_dump_close');
pcap_dump := LoadProcedure('pcap_dump');
pcap_findalldevs := LoadProcedure('pcap_findalldevs');
pcap_freealldevs := LoadProcedure('pcap_freealldevs');
pcap_lib_version := LoadProcedure('pcap_lib_version');
bpf_filter := LoadProcedure('bpf_filter');
bpf_validate := LoadProcedure('bpf_validate');
bpf_image := LoadProcedure('bpf_image');
bpf_dump := LoadProcedure('bpf_dump');
{$ifdef WINDOWS}
pcap_setbuff := LoadProcedure('pcap_setbuff');
pcap_setmode := LoadProcedure('pcap_setmode');
pcap_setmintocopy := LoadProcedure('pcap_setmintocopy');
{$endif}
{$ifdef unix}
pcap_get_selectable_fd := LoadProcedure('pcap_get_selectable_fd');
{$endif}
end;

initialization
	TSDllPcap.Create();
end.
