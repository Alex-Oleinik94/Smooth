unit VorbisEnc;

{************************************************************************}
{                                                                        }
{       Object Pascal Runtime Library                                    }
{       VorbisEnc interface unit                                         }
{                                                                        }
{ The original file is: vorbis/vorbisenc.h, released June 2001.          }
{ The original Pascal code is: VorbisEnc.pas, released 28 Jul 2001.      }
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
	{$MODE OBJFPC}
	{$ENDIF}

interface

uses OSTypes, Codec;

(*
const
{$IFDEF MSWINDOWS}
  VorbisEncLib = 'vorbisenc.dll';
{$ENDIF MSWINDOWS}

{$IFDEF UNIX}
  VorbisEncLib = 'libvorbisenc.so';
{$ENDIF UNIX}
*)

{ vorbis/vorbisenc.h }
(*


function vorbis_encode_init(var vi: vorbis_info; channels: long; rate: long; max_bitrate: long; nominal_bitrate: long; min_bitrate: long): int; cdecl; external VorbisEncLib;
*)
var vorbis_encode_init : function( var vi : vorbis_info ; channels : long ; rate : long ; max_bitrate : long ; nominal_bitrate : long ; min_bitrate : long ) : int ; cdecl ;

{
function vorbis_encode_init_vbr(var vi: vorbis_info; channels: long; rate: long; quality: float (* quality level from 0. (lo) to 1. (hi) *) ): int; cdecl; external VorbisEncLib;
}
var vorbis_encode_init_vbr : function( var vi : vorbis_info ; channels : long ; rate : long ; quality : float ) : int ; cdecl ;

(*
function vorbis_encode_ctl(var vi: vorbis_info; number: int; arg: Pointer): int; cdecl; external VorbisEncLib;
*)
var vorbis_encode_ctl : function( var vi : vorbis_info ; number : int ; arg : Pointer ) : int ; cdecl ;


implementation

uses
	 SaGeBase
	,SaGeDllManager
	,SaGeStringUtils
	,SaGeSysUtils
	;


// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
// =*=*= SaGe DLL IMPLEMENTATION =*=*=*=
// =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

type
	TSGDllVorbisEnc = class(TSGDll)
			public
		class function SystemNames() : TSGStringList; override;
		class function DllNames() : TSGStringList; override;
		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; override;
		class procedure Free(); override;
		end;
class procedure TSGDllVorbisEnc.Free();
begin
vorbis_encode_init := nil;
vorbis_encode_init_vbr := nil;
vorbis_encode_ctl := nil;
end;
class function TSGDllVorbisEnc.SystemNames() : TSGStringList;
begin
Result := nil;
Result += 'VorbisEnc';
Result += 'LibVorbisEnc';
end;
class function TSGDllVorbisEnc.DllNames() : TSGStringList;
begin
Result := nil;
Result += DllPrefix + 'vorbisenc' + DllPostfix;
{$IFDEF MSWINDOWS}
Result += DllPrefix + 'libvorbisenc' + DllPostfix;
{$ENDIF}
end;
class function TSGDllVorbisEnc.Load(const VDll : TSGLibHandle) : TSGDllLoadObject;
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
Result.FFunctionCount := 3;
LoadResult := @Result;
Pointer(vorbis_encode_init) := LoadProcedure('vorbis_encode_init');
Pointer(vorbis_encode_init_vbr) := LoadProcedure('vorbis_encode_init_vbr');
Pointer(vorbis_encode_ctl) := LoadProcedure('vorbis_encode_ctl');
end;

initialization
	TSGDllVorbisEnc.Create();
end.
