{$INCLUDE SaGe.inc}

unit SaGeThreads;

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
	
	,SaGeBase
	,SaGeSysUtils
	,SaGeClasses
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
	TSGThreadProcedure     = procedure ( p : Pointer );

	TSGThreadFunctionResult =
		{$IFDEF         ANDROID}
			TSGPointer
		{$ELSE} {$IFDEF MSWINDOWS}
			TSGUInt32
		{$ELSE} {$IFDEF UNIX}
			{$IFDEF CPU64}
				TSGInt64
			{$ELSE} {$IFDEF CPU32}
				TSGInt32
			{$ENDIF} {$ENDIF}
		{$ENDIF}{$ENDIF}{$ENDIF}
		;

	TSGThreadHandle = 
		{$IFDEF ANDROID}
			pthread_t
		{$ELSE} {$IFDEF DARWIN}
			TThreadID
		{$ELSE}
			TSGUInt32
		{$ENDIF}{$ENDIF}
		;
	
	TSGThreadFunction = function ( p : TSGPointer ): TSGThreadFunctionResult;
		{$IFDEF ANDROID}cdecl;{$ELSE} {$IF defined(MSWINDOWS)}stdcall;{$ENDIF}{$ENDIF}
	
	TSGThread = class(TSGNamed)
			public
		constructor Create(const Proc : TSGThreadProcedure; const Para : TSGPointer = nil; const QuickStart : TSGBoolean = True);
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			public
		FHandle    : TSGThreadHandle;
		FFinished  : Boolean;
		FProcedure : TSGThreadProcedure;
		FParametr  : Pointer;
		FThreadID  : TSGUInt32;
		{$IFDEF ANDROID}
			attr : pthread_attr_t;
			mutex : pthread_mutex_t;
			cond : pthread_cond_t;
			{$ENDIF}
		procedure Execute();virtual;
		procedure Start();virtual;
		procedure SetProcedure(const Proc:TSGThreadProcedure);
		procedure SetParametr(const Pointer:Pointer);
		procedure PreExecuting();
		procedure PostExecuting();
			public
		property Finished: boolean read FFinished write FFinished;
		end;
	TSGThreadList = packed array of TSGThread;

implementation

uses
	 SaGeLog
	,SaGeCasesOfPrint
	,SaGeStringUtils
	;

// =========================
// ========TSGThread========
// =========================

class function TSGThread.ClassName() : TSGString;
begin
Result := 'TSGThread';
end;

constructor TSGThread.Create(const Proc : TSGThreadProcedure; const Para : TSGPointer = nil; const QuickStart : TSGBoolean = True);
begin
inherited Create;
FFinished:=True;
FParametr:=Para;
FProcedure:=Proc;
FillChar(FHandle,SizeOf(FHandle),0);
FThreadID:=0;
{$IFDEF ANDROID}
	fillchar(attr,sizeof(attr),0);
	fillchar(cond,sizeof(cond),0);
	fillchar(mutex,sizeof(mutex),0);
	{$ENDIF}
if QuickStart then
	Start();
end;

procedure TSGThread.SetProcedure(const Proc:TSGThreadProcedure);
begin
FProcedure:=Proc;
end;

procedure TSGThread.SetParametr(const Pointer:Pointer);
begin
FParametr:=Pointer;
end;

procedure TSGThread.PreExecuting();
begin
{$IFDEF ANDROID}
	pthread_mutex_lock(@mutex);
	{$ENDIF}
FFinished:=False;
{$IFDEF ANDROID}
	pthread_cond_broadcast(@cond);
	pthread_mutex_unlock(@mutex);
	{$ENDIF}
end;

procedure TSGThread.PostExecuting();
begin
{$IFDEF ANDROID}
	pthread_mutex_lock(@mutex);
	{$ENDIF}
FFinished:=True;
{$IFDEF ANDROID}
	pthread_mutex_unlock(@mutex);
	{$ENDIF}
end;

procedure TSGThread.Execute();
begin
if Pointer(FProcedure)<>nil then
	FProcedure(FParametr);
end;

function TSGThreadStart(ThreadClass:TSGThread):TSGThreadFunctionResult;
{$IFDEF ANDROID}cdecl;{$ELSE}{$IF defined(MSWINDOWS)}stdcall;{$ENDIF}{$ENDIF}
begin
Result:={$IFDEF ANDROID}nil{$ELSE}0{$ENDIF};
try
	ThreadClass.PreExecuting();
	ThreadClass.Execute();
	ThreadClass.PostExecuting();
except on e : TSGException do
	begin
	SGLog.Source(['TSGThread_Run(). While executing ',ThreadClass.ClassName(), '(', SGAddrStr(ThreadClass), ') raised exception --->']);
	SGPrintExceptionStackTrace(e, SGCasesOfPrintLog);
	end;
end;
{$IFDEF ANDROID}
	while True do Sleep(10000);
	{$ENDIF}
end;

destructor TSGThread.Destroy();
{$IFDEF MSWINDOWS}
	var
		TerminateResult : TSGBoolean;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	if not FFinished then
		begin
		TerminateResult := TerminateThread(FHandle, 0);
		SGLog.Source(['TSGThread__Destroy(). Handle=', FHandle, ', Thread ID=', FThreadID, ', Terminate Result=', TerminateResult, '.']);
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

procedure TSGThread.Start();
begin
{$IFDEF MSWINDOWS}
	FHandle := CreateThread(nil, 0, @TSGThreadStart, Self, 0, FThreadID);
{$ELSE} {$IFDEF ANDROID}
	SGLog.Source('Start thread');
	pthread_mutex_init(@mutex, nil);
	pthread_cond_init(@cond, nil);
	pthread_attr_init(@attr);
	pthread_attr_setdetachstate(@attr, PTHREAD_CREATE_DETACHED);
	FThreadID := pthread_create(@FHandle, @attr, TSGThreadFunction(@TSGThreadStart), Self);
	pthread_mutex_lock(@mutex);
	while FFinished do
		pthread_cond_wait(@cond, @mutex);
	pthread_mutex_unlock(@mutex);
	SGLog.Source('End start thread : FHandle = '+SGStr(LongWord(FHandle))+', FThreadID = '+SGStr(FThreadID)+', Self = '+SGStr(TSGLongWord(Self))+'.');
{$ELSE}
	FHandle := BeginThread(TSGThreadFunction(@TSGThreadStart), Self);
{$ENDIF} {$ENDIF}
end;

end.
