unit VCEdit;

{************************************************************************}
{                                                                        }
{       Object Pascal Runtime Library                                    }
{       Vorbis Comment interface unit                                    }
{                                                                        }
{ The original file is: vorbis-tools/vorbiscomment/vcedit.h,             }
{                                                 released October 2001. }
{ The original Pascal code is: VCEdit.pas, released Nov 2001             }
{ The initial developer of the Pascal code is Matthijs Laan              }
{ <matthijsln@xs4all.nl>                                                 }
{                                                                        }
{ Portions created by Matthijs Laan are                                  }
{ Copyright (C) 2001 Matthijs Laan.                                      }
{                                                                        }
{ Portions created by Michael Smith are                                  }
{ Copyright (C) 2000-2001 Michael Smith <msmith@labyrinth.net.au>        }
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

uses OSTypes, Ogg, Codec;

const
{$IFDEF MSWINDOWS}
  VCEditLib = 'vcedit.dll';
{$ENDIF MSWINDOWS}

{$IFDEF UNIX}
  OggLib = 'libvcedit.so';
{$ENDIF UNIX}

{$IFDEF FPC}
  {$IFDEF WIN32}
    {$PACKRECORDS C}
  {$ENDIF WIN32}
{$ENDIF FPC}

type

  vcedit_read_func = function(var ptr; size: size_t; nmemb: size_t; const datasource): size_t; cdecl;
  vcedit_write_func = function(var buffer; size: size_t; count: size_t; const stream): size_t; cdecl;

  p_vcedit_state = ^vcedit_state;
    vcedit_state = record
      oy: p_ogg_sync_state;
      os: p_ogg_stream_state;

      vc: p_vorbis_comment;
      vi: vorbis_info;

      read: vcedit_read_func;
      write: vcedit_write_func;

      in_: Pointer;
      serial: long;
      mainbuf: PChar;
      bookbuf: PChar;
      mainlen: int;
      booklen: int;
      lasterror: PChar;
      vendor: PChar;
      prevW: int;
    end;
(*


function vcedit_new_state(): p_vcedit_state; cdecl; external VCEditLib;
*)
var vcedit_new_state : function( ) : p_vcedit_state ; cdecl ;

(*

procedure vcedit_clear(state: p_vcedit_state); cdecl; external VCEditLib;
*)
var vcedit_clear : procedure( state : p_vcedit_state ) ; cdecl ;

(*

function vcedit_comments(state: p_vcedit_state): p_vorbis_comment; cdecl; external VCEditLib;
*)
var vcedit_comments : function( state : p_vcedit_state ) : p_vorbis_comment ; cdecl ;

{ Do not use "vcedit_open" in Object Pascal }
// function vcedit_open(state: p_vcedit_state; var in_: FILE): int; cdecl; external VCEditLib;

(*

function vcedit_open_callbacks(state: p_vcedit_state; const in_; read_func: vcedit_read_func; write_func: vcedit_write_func): int; cdecl; external VCEditLib;
*)
var vcedit_open_callbacks : function( state : p_vcedit_state ; const in_ ; read_func : vcedit_read_func ; write_func : vcedit_write_func ) : int ; cdecl ;

(*

function vcedit_write(state: p_vcedit_state; const out_): int; cdecl; external VCEditLib;
*)
var vcedit_write : function( state : p_vcedit_state ; const out_ ) : int ; cdecl ;

(*

function vcedit_error(state: p_vcedit_state): PChar; cdecl; external VCEditLib;
*)
var vcedit_error : function( state : p_vcedit_state ) : PChar ; cdecl ;


{ The following is added and not found in the original .h file }

{ The vcedit callback for Object Pascal TStreams, vcedit_read_func is compatible
  with ops_read_func in VorbisFile.pas }
function ops_write_func(var buffer; size: size_t; count: size_t; const stream): size_t; cdecl;

implementation

uses
	 SaGeBase
	,SaGeBased
	,SaGeDllManager
	,SaGeStringUtils
	,SaGeSysUtils
	
	,Classes
	;

function ops_write_func(var buffer; size: size_t; count: size_t; const stream): size_t; cdecl;
{ Returns amount of items successfully written }
begin
  if size = 0 then
  begin
    result := $FFFFFFFF; { Value is implementation dependant,
                           as long as it is not zero (which would be ambiguous) }
    exit;
  end;

  try
    result := Int64(TStream(stream).Write(buffer, size * count)) div Int64(size);
  except
    result := 0; { Assume nothing was written. No way to be sure of TStreams }
  end;
end;

// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= SaGe DLL IMPLEMENTATION =*=*=*=
// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSGDllVCEdit = class(TSGDll)
			public
		class function SystemNames() : TSGStringList; override;
		class function DllNames() : TSGStringList; override;
		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; override;
		class procedure Free(); override;
		end;
class procedure TSGDllVCEdit.Free();
begin
vcedit_new_state := nil;
vcedit_clear := nil;
vcedit_comments := nil;
vcedit_open_callbacks := nil;
vcedit_write := nil;
vcedit_error := nil;
end;
class function TSGDllVCEdit.SystemNames() : TSGStringList;
begin
Result := nil;
Result += 'VCEdit';
Result += 'LibVCEdit';
end;
class function TSGDllVCEdit.DllNames() : TSGStringList;
begin
Result := nil;
Result += VCEditLib;
end;
class function TSGDllVCEdit.Load(const VDll : TSGLibHandle) : TSGDllLoadObject;
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
Result.FFunctionCount := 6;
LoadResult := @Result;
Pointer(vcedit_new_state) := LoadProcedure('vcedit_new_state');
Pointer(vcedit_clear) := LoadProcedure('vcedit_clear');
Pointer(vcedit_comments) := LoadProcedure('vcedit_comments');
Pointer(vcedit_open_callbacks) := LoadProcedure('vcedit_open_callbacks');
Pointer(vcedit_write) := LoadProcedure('vcedit_write');
Pointer(vcedit_error) := LoadProcedure('vcedit_error');
end;

initialization
	TSGDllVCEdit.Create();
end.
