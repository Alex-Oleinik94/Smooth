{$INCLUDE SaGe.inc}

unit SaGeAudioDecoderOGGCommon;

interface

uses
	 SaGeBase
	
	,Classes
	
	,OSTypes
	,VorbisFile
	;
var
	StreamCallBacks: ov_callbacks;
	MemoryStreamCallBacks: ov_callbacks;

const
  { Constants taken from the MSVC++6 ANSI C library. These values may be
    different for other C libraries! }
  SEEK_SET = 0;
  SEEK_CUR = 1;
  SEEK_END = 2;

implementation

function stream_read_func(var ptr; size, nmemb: size_t; const datasource): size_t;
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

function stream_seek_func (const datasource; offset: ogg_int64_t; whence: int_t): int_t;
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

function stream_close_func(const datasource): int_t;
{ Returns zero when device was successfully closed, EOF on error. }
begin
result := 0;
end;

function stream_tell_func(const datasource): long;
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

initialization
begin
StreamCallBacks.read_func := read_func_t(@stream_read_func);
StreamCallBacks.seek_func := seek_func_t(@stream_seek_func);
StreamCallBacks.close_func := close_func_t(@stream_close_func);
StreamCallBacks.tell_func := tell_func_t(@stream_tell_func);
end;

end.
