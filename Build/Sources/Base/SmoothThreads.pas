{$INCLUDE Smooth.inc}

unit SmoothThreads;

interface

uses
	 Classes
	{$IFDEF MSWINDOWS}
		,Windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		{$ENDIF}
	,SysUtils
	{$IFDEF ANDROID}
		,ctypes
		,cmem
		,unixtype
		,android_native_app_glue
		{$ENDIF}
	
	,SmoothBase
	,SmoothSysUtils
	,SmoothBaseClasses
	;

{$IFDEF ANDROID}
				{*========POSIX Thread=========*}
	const
		PTHREAD_CREATE_JOINABLE = 0;
		PTHREAD_CREATE_DETACHED = 1;
	type
		ppthread_t = ^pthread_t;
		ppthread_attr_t = ^pthread_attr_t;
		ppthread_mutex_t = ^pthread_mutex_t;
		ppthread_cond_t = ^pthread_cond_t;
		ppthread_mutexattr_t = ^pthread_mutexattr_t;
		ppthread_condattr_t = ^pthread_condattr_t;

	 __start_routine_t = pointer;
	function pthread_create(__thread:ppthread_t; __attr:ppthread_attr_t;__start_routine: __start_routine_t;__arg:pointer):longint;cdecl;external 'libc.so';
	function pthread_attr_init(__attr:ppthread_attr_t):longint;cdecl;external 'libc.so';
	function pthread_attr_setdetachstate(__attr:ppthread_attr_t; __detachstate:longint):longint;cdecl;external 'libc.so';
	function pthread_mutex_init(__mutex:ppthread_mutex_t; __mutex_attr:ppthread_mutexattr_t):longint;cdecl;external 'libc.so';
	function pthread_mutex_destroy(__mutex:ppthread_mutex_t):longint;cdecl;external 'libc.so';
	function pthread_mutex_lock(__mutex: ppthread_mutex_t):longint;cdecl;external 'libc.so';
	function pthread_mutex_unlock(__mutex: ppthread_mutex_t):longint;cdecl;external 'libc.so';
	function pthread_cond_init(__cond:ppthread_cond_t; __cond_attr:ppthread_condattr_t):longint;cdecl;external 'libc.so';
	function pthread_cond_destroy(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
	function pthread_cond_signal(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
	function pthread_cond_broadcast(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
	function pthread_cond_wait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t):longint;cdecl;external 'libc.so';
	//procedure pthread_exit(value : Pointer);cdecl;external 'libc.so';
	function  pthread_attr_destroy(__attr:ppthread_attr_t):longint;cdecl;external 'libc.so';
	//function pthread_cancel(__thread:pthread_t):LongInt;cdecl;external 'libc.so';
	function pthread_join(thread:pthread_t; a:pointer):LongInt;cdecl;external 'libc.so';
	{$ENDIF}
type
	//Это для потоков
	TSThreadProcedure     = procedure ( p : Pointer );

	TSThreadFunctionResult =
		{$IFDEF         ANDROID}
			TSPointer
		{$ELSE} {$IFDEF MSWINDOWS}
			TSUInt32
		{$ELSE} {$IFDEF UNIX}
			{$IFDEF CPU64}
				TSInt64
			{$ELSE} {$IFDEF CPU32}
				TSInt32
			{$ENDIF} {$ENDIF}
		{$ENDIF}{$ENDIF}{$ENDIF}
		;

	TSThreadHandle = 
		{$IFDEF ANDROID}
			pthread_t
		{$ELSE} {$IFDEF DARWIN}
			TThreadID
		{$ELSE}
			TSUInt32
		{$ENDIF}{$ENDIF}
		;
	
	TSThreadFunction = function ( p : TSPointer ): TSThreadFunctionResult;
		{$IFDEF ANDROID}cdecl;{$ELSE} {$IF defined(MSWINDOWS)}stdcall;{$ENDIF}{$ENDIF}
	
	TSThread = class(TSNamed)
			public
		constructor Create(const Proc : TSThreadProcedure; const Para : TSPointer = nil; const QuickStart : TSBoolean = True);
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			public
		FHandle    : TSThreadHandle;
		FFinished  : TSBoolean;
		FProcedure : TSThreadProcedure;
		FParametr  : Pointer;
		FThreadID  : TSUInt32;
		FCrashed   : TSBoolean;
		{$IFDEF ANDROID}
			attr : pthread_attr_t;
			mutex : pthread_mutex_t;
			cond : pthread_cond_t;
			{$ENDIF}
		procedure Execute();virtual;
		procedure Start();virtual;
		procedure SetProcedure(const Proc:TSThreadProcedure);
		procedure SetParametr(const Pointer:Pointer);
		procedure PreExecuting();
		procedure PostExecuting();
			public
		property Finished : TSBoolean read FFinished write FFinished;
		property Crashed  : TSBoolean read FCrashed write FCrashed;
		end;
	TSThreadList = packed array of TSThread;

procedure SKill(var Thread : TSThread); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothLog
	,SmoothCasesOfPrint
	,SmoothStringUtils
	;

procedure SKill(var Thread : TSThread); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (Thread <> nil) then
	begin
	Thread.Destroy();
	Thread := nil;
	end;
end;

// =========================
// ========TSThread========
// =========================

class function TSThread.ClassName() : TSString;
begin
Result := 'TSThread';
end;

constructor TSThread.Create(const Proc : TSThreadProcedure; const Para : TSPointer = nil; const QuickStart : TSBoolean = True);
begin
inherited Create();
FFinished := True;
FCrashed := False;
FParametr := Para;
FProcedure := Proc;
FillChar(FHandle, SizeOf(FHandle), 0);
FThreadID := 0;
{$IFDEF ANDROID}
	fillchar(attr, sizeof(attr), 0);
	fillchar(cond, sizeof(cond), 0);
	fillchar(mutex, sizeof(mutex), 0);
	{$ENDIF}
if QuickStart then
	Start();
end;

procedure TSThread.SetProcedure(const Proc:TSThreadProcedure);
begin
FProcedure:=Proc;
end;

procedure TSThread.SetParametr(const Pointer:Pointer);
begin
FParametr:=Pointer;
end;

procedure TSThread.PreExecuting();
begin
{$IFDEF ANDROID}
	pthread_mutex_lock(@mutex);
	{$ENDIF}
FFinished := False;
{$IFDEF ANDROID}
	pthread_cond_broadcast(@cond);
	pthread_mutex_unlock(@mutex);
	{$ENDIF}
end;

procedure TSThread.PostExecuting();
begin
{$IFDEF ANDROID}
	pthread_mutex_lock(@mutex);
	{$ENDIF}
FFinished := True;
{$IFDEF ANDROID}
	pthread_mutex_unlock(@mutex);
	{$ENDIF}
end;

procedure TSThread.Execute();
begin
if Pointer(FProcedure)<>nil then
	FProcedure(FParametr);
end;

function TSThreadStart(ThreadClass : TSThread) : TSThreadFunctionResult;
{$IFDEF ANDROID}cdecl;{$ELSE}{$IF defined(MSWINDOWS)}stdcall;{$ENDIF}{$ENDIF}
begin
Result := {$IFDEF ANDROID}nil{$ELSE}0{$ENDIF};
try
	ThreadClass.PreExecuting();
	ThreadClass.Execute();
	ThreadClass.PostExecuting();
except on e : TSException do
	begin
	SLogMakeSignificant();
	SLog.Source(['TSThread_Run(). While executing ',ThreadClass.ClassName(), '(', SAddrStr(ThreadClass), ') raised exception --->']);
	SPrintExceptionStackTrace(e, SCasesOfPrintLog);
	ThreadClass.Crashed := True;
	end;
end;
{$IFDEF ANDROID}
	while True do Sleep(10000);
	{$ENDIF}
end;

destructor TSThread.Destroy();
{$IFDEF MSWINDOWS}
	var
		TerminateResult : TSBoolean;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	if (not FFinished) and (not FCrashed) then
		begin
		TerminateResult := TerminateThread(FHandle, 0);
		SLog.Source([Self, '__Destroy(). Handle=', FHandle, ', Thread ID=', FThreadID, ', Terminate Result=', TerminateResult, '.']);
		end;
	if FHandle <> 0 then
		CloseHandle(FHandle);
{$ELSE}
	{$IFDEF ANDROID}
		{if not FFinished then
			pthread_cancel(FHandle);}
		pthread_cond_destroy(@cond);
		pthread_mutex_destroy(@mutex);
		pthread_attr_destroy(@attr);
	{$ELSE}
	if not FFinished then
		KillThread(FHandle);
		{$ENDIF}
	{$ENDIF}
FillChar(FHandle,SizeOf(FHandle),0);
FThreadID:=0;
inherited;
end;

procedure TSThread.Start();
begin
{$IFDEF MSWINDOWS}
	FHandle := CreateThread(nil, 0, @TSThreadStart, Self, 0, FThreadID);
{$ELSE} {$IFDEF ANDROID}
	SLog.Source('Start thread');
	pthread_mutex_init(@mutex, nil);
	pthread_cond_init(@cond, nil);
	pthread_attr_init(@attr);
	pthread_attr_setdetachstate(@attr, PTHREAD_CREATE_DETACHED);
	FThreadID := pthread_create(@FHandle, @attr, TSThreadFunction(@TSThreadStart), Self);
	pthread_mutex_lock(@mutex);
	while FFinished do
		pthread_cond_wait(@cond, @mutex);
	pthread_mutex_unlock(@mutex);
	SLog.Source('End start thread : FHandle = '+SStr(LongWord(FHandle))+', FThreadID = '+SStr(FThreadID)+', Self = '+SStr(TSLongWord(Self))+'.');
{$ELSE}
	FHandle := BeginThread(TSThreadFunction(@TSThreadStart), Self);
{$ENDIF} {$ENDIF}
end;

end.
