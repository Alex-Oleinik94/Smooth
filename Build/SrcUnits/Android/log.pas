unit log;
{$ifdef fpc}
 {$mode delphi}
{$endif}

interface

(*uses
	SaGeBase;*)

const libname='liblog.so';

      ANDROID_LOG_UNKNOWN=0;
      ANDROID_LOG_DEFAULT=1;
      ANDROID_LOG_VERBOSE=2;
      ANDROID_LOG_DEBUG=3;
      ANDROID_LOG_INFO=4;
      ANDROID_LOG_WARN=5;
      ANDROID_LOG_ERROR=6;
      ANDROID_LOG_FATAL=7;
      ANDROID_LOG_SILENT=8;

type android_LogPriority=integer;

function __android_log_write(prio:longint;tag,text:pchar):longint; cdecl; external libname name '__android_log_write';
function LOGI(prio:longint;tag,text:pchar):longint; cdecl; varargs; external libname name '__android_log_print';

procedure LOGW(Text: pchar);
//function __android_log_print(prio:longint;tag,print:pchar;params:array of pchar):longint; cdecl; external libname name '__android_log_print';
  
implementation

(*function __android_log_write(prio:longint;tag,text:pchar):longint; cdecl;
begin
SGLog.Sourse(['Android log:"',Prio,' ',SGPCharToString(tag),' ',SGPCharToString(text),'".']);
end;*)

procedure LOGW(Text: pchar);
begin
__android_log_write(ANDROID_LOG_FATAL,'crap',text);
(*SGLog.Sourse(['Android log:"','ANDROID_LOG_FATAL ','crap',SGPCharToString(text),'".']);*)
end;

end.
