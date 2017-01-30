{$INCLUDE SaGe.inc}
{$DEFINE USE_uSMBIOS}

unit SaGeSysUtils;

interface

uses
	 Classes
	,SysUtils
	
	,SaGeBase
	,SaGeBased
	;

// Core
function SGGetCoreCount() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Libraries
type
	TSGLibHandle = type TSGMaxEnum;
	TSGLibHandleList = type packed array of TSGLibHandle;
	TSGLibraryHandle = TSGLibHandle;
	TSGLibraryHandleList = TSGLibHandleList;
	TSGLibrary = class
			public
		constructor Create(const VLibraryName : TSGString);
		destructor Destroy();override;
			private
		FLibrary : TSGLibHandle;
			public
		function GetProcedureAddress(const VProcedureName : TSGString) : TSGPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property LibHandle : TSGLibHandle read FLibrary;
		property LibraryHandle : TSGLibHandle read FLibrary;
		end;

function LoadLibrary(const AName : PSGChar): TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function LoadLibrary(const AName : TSGString): TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function UnloadLibrary(const VLib : TSGLibHandle) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function GetProcAddress(const Lib : TSGLibHandle; const VPChar : PSGChar) : TSGPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function GetProcAddress(const Lib : TSGLibHandle; const VPChar : TSGString) : TSGPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

// Stack Trace
type
	TSGException = Exception;
procedure SGPrintStackTrace();
procedure SGPrintExceptionStackTrace(const e : TSGException);

// Other
procedure SGRunComand(const Comand : TSGString; const ViewOutput : TSGBoolean = True);

implementation

uses
	 Crt
	{$IFDEF USE_uSMBIOS}
		,uSMBIOS
		{$ENDIF}
	{$IFDEF MSWINDOWS}
		,Windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,dl
		{$ENDIF}
	,DynLibs
	,Process
	
	,SaGeStringUtils
	,SaGeLog
	,SaGeFileUtils
	;


destructor TSGLibrary.Destroy;
begin
if FLibrary <> 0 then
	begin
	UnloadLibrary(FLibrary);
	FLibrary := 0;
	end;
inherited;
end;

constructor TSGLibrary.Create(const VLibraryName : TSGString);
begin
inherited Create();
FLibrary := LoadLibrary(VLibraryName);
end;

function TSGLibrary.GetProcedureAddress(const VProcedureName : TSGString) : Pointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := GetProcAddress(FLibrary, VProcedureName);
end;

procedure SGRunComand(const Comand : TSGString; const ViewOutput : TSGBoolean = True);
var
	AProcess: TProcess;

procedure WriteFromStringList();
var
	AStringList: TStringList;
	i : LongInt;
begin
AProcess.WaitOnExit();
AStringList := TStringList.Create;
AStringList.LoadFromStream(AProcess.Output);
for i := 0 to AStringList.Count - 1 do
	begin
	WriteLn(AStringList[i]);
	end;
AStringList.Free;
end;

procedure WriteFromBytes();
var
	Error : TSGBoolean;
begin
Error := False;
while AProcess.Active or (not Error) do
	begin
	Error := False;
	try
	Write(Char(AProcess.Output.ReadByte));
	except
	Error := True;
	end;
	if Error then
		Sleep(10);
	end;
end;

begin
AProcess := TProcess.Create(nil);
AProcess.CommandLine := Comand;
AProcess.Options := AProcess.Options + [poUsePipes, poStderrToOutPut];
AProcess.Execute();

if (poUsePipes in AProcess.Options) and ViewOutput then
	begin
	//WriteFromStringList();
	WriteFromBytes();
	end;

AProcess.Free();
end;

procedure SGPrintExceptionStackTrace(const e : TSGException);
var
	I, H   : Integer;
	Frames : PPointer;
	Report : TSGString;
begin
Report := 'An unhandled exception occurred at ' + SGAddrStr(ExceptAddr) + ':' + SGWinEoln;
if E <> nil then
	Report += E.ClassName + ': ' + E.Message + SGWinEoln;
Report += BackTraceStrFunc(ExceptAddr) + SGWinEoln;
Frames := ExceptFrames;
H := ExceptFrameCount - 1;
for I := 0 to H do
	begin
	Report += BackTraceStrFunc(Frames[I]);
	if I <> H then
		Report += SGWinEoln;
	end;
SGHint(Report);
Report := '';
end;

procedure SGPrintStackTrace();
var
	bp: Pointer;
	addr: Pointer;
	oldbp: Pointer;
begin
bp := get_caller_frame(get_frame);
while bp<>nil do
	begin
	addr := get_caller_addr(bp);
	SGHint(BackTraceStrFunc(addr));
	oldbp := bp;
	bp := get_caller_frame(bp);
	if (bp <= oldbp) or (bp > (StackBottom + StackLength)) then
		bp := nil;
	end;
end;

function UnloadLibrary(const VLib : TSGLibHandle) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := dynlibs.UnloadLibrary(VLib);
end;

function GetProcAddress(const Lib : TSGLibHandle; const VPChar : PSGChar):TSGPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
{$IFDEF WINDOWS}
	Result := Windows.GetProcAddress(Lib, VPChar);
{$ELSE}
	Result := GetProcedureAddress(Lib, VPChar);
	{$ENDIF}
end;

function GetProcAddress(const Lib : TSGLibHandle; const VPChar : TSGString) : TSGPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PC : PSGChar;
begin
PC := SGStringToPChar(VPChar);
Result := GetProcAddress(Lib, PC);
SGPCharFree(PC, True);
end;

function LoadLibrary(const AName : TSGString) : TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PC : PSGChar;
begin
PC := SGStringToPChar(AName);
Result := LoadLibrary(PC);
SGPCharFree(PC, True);
end;

function LoadLibrary(const AName: PSGChar) : TSGLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result:=
	{$ifdef UNIX}
		TSGLibHandle( dlopen(AName, RTLD_LAZY or RTLD_GLOBAL));
	{$else}
		Windows.LoadLibrary(AName);
		{$endif}
end;

function SGGetCoreCount() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFDEF USE_uSMBIOS}
Var
  SMBios             : TSMBios;
  LProcessorInfo     : TProcessorInformation;
{$ENDIF}
begin
Result:=0;
{$IFDEF USE_uSMBIOS}
try
	SMBios:=TSMBios.Create();
	if SMBios.HasProcessorInfo then
		for LProcessorInfo in SMBios.ProcessorInfo do
			if SMBios.SmbiosVersion >= '2.5' then
				Result:=LProcessorInfo.RAWProcessorInformation^.CoreCount;
finally
	SMBios.Free;
	end;
{$ENDIF}
end;

end.
