unit CommentUtils;

{************************************************************************}
{                                                                        }
{       Vorbis comment handling utility unit                             }
{                                                                        }
{ Copyright (C) 2001 Matthijs Laan.                                      }
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
  {$IFDEF MSWINDOWS}
    {$PACKRECORDS C}
  {$ENDIF MSWINDOWS}
{$ENDIF FPC}

interface

uses Codec, Classes;

const
  ASCIIReplaceChar = '?';

type
  PStrComment = ^TStrComment;
  TStrComment = record
    Name, Value, FullStr: string;
  end;

  TStrComments = class(TList)
  public
    procedure FreeComments;
  end;

  TCharset = (csASCII {$IFDEF MSWINDOWS}, csLatin1, csWindowsConsole, csUnicode2 {$ENDIF});

function GetVorbisComments(pvc: p_vorbis_comment; var CharsReplaced: boolean; Charset: TCharset): TStrComments; overload;
function GetVorbisComments(pvc: p_vorbis_comment; Charset: TCharset): TStrComments; overload;

{$IFDEF MSWINDOWS}
function UTF8ToWideString(const s: string): string;
function WideStringToUTF8(const s: string): string;
function WideStringToLatin1(const s: string): string;
function WideStringToWindowsConsole(const s: string): string;
function Latin1ToWideString(const s: string): string;
{$ENDIF}

implementation

{$IFDEF MSWINDOWS}
uses Windows, SysUtils;

const
  CP_UTF8 = 65001;

{$ENDIF}

procedure TStrComments.FreeComments;
var
  i: integer;
  p: PStrComment;
begin
  for i := 0 to Count - 1 do
  begin
    // fpc can't handle this without the p variable
    p := PStrComment(Items[i]);
    Dispose(p);
  end;
  Free;
end;

function GetVorbisComments(pvc: p_vorbis_comment; Charset: TCharset): TStrComments;
var
  b: boolean;
begin
  result := GetVorbisComments(pvc, b, Charset);
end;

function GetVorbisComments(pvc: p_vorbis_comment; var CharsReplaced: boolean; Charset: TCharset): TStrComments;
  procedure ChopUTF8ToASCII(var s: string);
  var
    i: integer;
  begin
    // Only allow the ASCII subset of UTF8
    for i := 1 to Length(s) do
      if (Ord(s[i]) and $80) <> 0 then
      begin
        CharsReplaced := true;
        s[i] := ASCIIReplaceChar;
      end;
  end;
var
  i, j, p: integer;
  s: string;
  pc: PStrComment;
label
  no_valid_name;
begin
  result := TStrComments.Create;
  for i := 0 to pvc^.comments - 1 do
  begin
    SetLength(s, pvc^.comment_lengths^[i]);
    Move(pvc^.user_comments^[i][0], s[1], Length(s));

    New(pc);
    result.add(pc);
    pc^.Name := '';
    p := Pos('=', s);
    if p = 0 then
      pc^.Value := s
    else
    begin
      for j := 1 to p - 1 do
        if not (s[j] in [#$20..#$3c, #$3e..#$7d]) then
        begin
          pc^.Value := s;
          goto no_valid_name;
        end;
      pc^.Name := Copy(s, 1, p-1);
      pc^.Value := Copy(s, p+1, Length(s)-p);
no_valid_name:
    end;

    case Charset of
      csASCII: ChopUTF8ToASCII(pc^.Value);
{$IFDEF MSWINDOWS}
      csLatin1: pc^.Value := WideStringToLatin1(UTF8ToWideString(pc^.Value));
      csWindowsConsole: pc^.Value := WideStringToWindowsConsole(UTF8ToWideString(pc^.Value));
      csUnicode2: pc^.Value := UTF8ToWideString(pc^.Value);
{$ENDIF}
    end;
    if pc^.Name <> '' then
      pc^.FullStr := pc^.Name + '=' + pc^.Value
    else
      pc^.FullStr := pc^.Value;
  end;
end;

function UTF8ToWideString(const s: string): string;
begin
  SetLength(result, SizeOf(WCHAR) * (MultiByteToWideChar(CP_UTF8,0,@s[1],Length(s),nil,0)+1));
  MultiByteToWideChar(CP_UTF8,0,@s[1],Length(s),@result[1],Length(result) div SizeOf(WCHAR));
{$IFDEF FPC}
  PWCHAR(@result[Length(result)+1-SizeOf(WCHAR)])^ := #0;
{$ELSE}
  PWord(@result[Length(result)+1-SizeOf(WCHAR)])^ := 0;
{$ENDIF}
end;

function WideStringToUTF8(const s: string): string;
begin
  SetLength(result,WideCharToMultiByte(CP_UTF8,0,@s[1],Length(s) div SizeOf(WCHAR),nil,0,nil,nil));
  WideCharToMultiByte(CP_UTF8,0,@s[1],Length(s) div SizeOf(WCHAR),@result[1],Length(result),nil,nil);
end;

function WideStringToLatin1(const s: string): string;
begin
  SetLength(result,WideCharToMultiByte(CP_ACP,0,@s[1],Length(s) div SizeOf(WCHAR),nil,0,nil,nil));
  WideCharToMultiByte(CP_ACP,0,@s[1],Length(s) div SizeOf(WCHAR),@result[1],Length(result),nil,nil);
  if Length(result) > 0 then
    if result[Length(result)] = #0 then
      SetLength(result, Length(result)-1);
end;

function WideStringToWindowsConsole(const s: string): string;
begin
  SetLength(result,WideCharToMultiByte(CP_OEMCP,0,@s[1],Length(s) div SizeOf(WCHAR),nil,0,nil,nil));
  WideCharToMultiByte(CP_OEMCP,0,@s[1],Length(s) div SizeOf(WCHAR),@result[1],Length(result),nil,nil);
  if Length(result) > 0 then
    if result[Length(result)] = #0 then
      SetLength(result, Length(result)-1);
end;

function Latin1ToWideString(const s: string): string;
begin
  SetLength(result, SizeOf(WCHAR) * (MultiByteToWideChar(CP_ACP,0,@s[1],Length(s),nil,0)+1));
  MultiByteToWideChar(CP_ACP,0,@s[1],Length(s),@result[1],Length(result)  div SizeOf(WCHAR));
{$IFDEF FPC}
  PWCHAR(@result[Length(result)+1-SizeOf(WCHAR)])^ := #0;
{$ELSE}
  PWord(@result[Length(result)+1-SizeOf(WCHAR)])^ := 0;
{$ENDIF}
end;

end.
