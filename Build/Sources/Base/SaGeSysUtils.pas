{$INCLUDE SaGe.inc}
{$DEFINE USE_uSMBIOS}

unit SaGeSysUtils;

interface

uses
	 SysUtils
	{$IFDEF MSWINDOWS}
		,Windows
		{$ENDIF}
	
	,SaGeBase
	,SaGeCasesOfPrint
	;

// Core
function SGCoreCount() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Libraries
const
	SGLibraryNameBegin = 
		{$IFDEF UNIX}
			'lib'
		{$ELSE}
			''
		{$ENDIF}
		;
	SGLibraryNameEnd =
		{$IFDEF UNIX}
			'.so'
		{$ELSE} {$IFDEF MSWINDOWS}
			'.dll'
		{$ELSE}
			''
		{$ENDIF} {$ENDIF}
		;

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
procedure SGPrintExceptionStackTrace(const e : TSGException; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog];const ViewTime : TSGBoolean = False);
procedure SGLogException(const Title : TSGString; const e : Exception);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Other
function SGShortIntToInt(Value : TSGShortInt) : TSGInteger; {$IFDEF WITHASMINC} assembler; register; {$ENDIF} overload;
procedure SGRunComand(const Comand : TSGString; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
function SGOperatingSystemVersion(): TSGString;

implementation

uses
	 Crt
	{$IFDEF USE_uSMBIOS}
		,uSMBIOS
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,dl
		{$ENDIF}
	,DynLibs
	,Process
	,Classes
	
	,SaGeLog
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeBaseUtils
	{$IFDEF MSWINDOWS}
		,SaGeWindowsUtils
	{$ELSE}
		,SaGeVersion
		{$ENDIF}
	;

procedure SGLogException(const Title : TSGString; const e : Exception);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGLog.Source([Title, ' --->']);
SGPrintExceptionStackTrace(e, [SGCaseLog]);
end;

function SGOperatingSystemVersion(): TSGString;
begin
Result := '';
{$IFDEF MSWINDOWS}
Result := SGWindowsVersion();
{$ELSE}
Result := SGEngineTargetVersion();
{$ENDIF}
end;

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

procedure SGRunComand(const Comand : TSGString; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
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

procedure WriteFromBytes(const SkipEolns : TSGBoolean = True);
const
	Eolns = [#13, #10];
var
	Error : TSGBoolean;
	C, lC, N : TSGChar;
	Str : TSGString = '';

procedure ProcessString();
begin
if Str <> '' then
	begin
	SGHint(Str, CasesOfPrint, False);
	Str := '';
	end;
end;

begin
Error := False;
if SkipEolns then
	begin
	lC  := ' ';
	C   := ' ';
	while AProcess.Active or (not Error) do
		begin
		Error := False;
		try
		N := TSGChar(AProcess.Output.ReadByte);
		if (N  in Eolns) and
		   (C  in Eolns) and
		   (lC in Eolns) then
		else
			begin
			lC := C;
			C := N;
			if C in Eolns then
				ProcessString()
			else
				Str += C;
			end;
		except
			Error := True;
		end;
		if Error then
			Sleep(10);
		end;
	ProcessString();
	end
else
	while AProcess.Active or (not Error) do
		begin
		Error := False;
		try
		Write(TSGChar(AProcess.Output.ReadByte));
		except
		Error := True;
		end;
		if Error then
			Sleep(10);
		end;
end;

procedure LogComand();
var
	StringList : TSGStringList = nil;
	Index : TSGUInt32;
begin
SGLog.Source(['SGRunComand(..). Executing comand ', Iff(Length(Comand) < 80, ': ' + Comand, '--->')]);
if Length(Comand) >= 80 then
	if Length(Comand) < 137 then
		SGLog.Source(['	Comand : ', Comand], False)
	else
		begin
		StringList := SGStringListFromString(Comand, ' ');
		SGLog.Source(['	Executable : ', Iff(Length(StringList) > 0, StringList[0], '???')], False);
		if Length(StringList) > 1 then
			begin
			for Index := 0 to High(StringList) - 1 do
				StringList[Index] := StringList[Index + 1];
			SetLength(StringList, Length(StringList) - 1);
			SGLog.Source(StringList, '	Params : ', False);
			end;
		SetLength(StringList, 0);
		end;
end;

begin
if SGCaseLog in CasesOfPrint then
	LogComand();
AProcess := TProcess.Create(nil);
AProcess.CommandLine := Comand;
AProcess.Options := AProcess.Options + [poUsePipes, poStderrToOutPut];
AProcess.Execute();

if (poUsePipes in AProcess.Options) and (CasesOfPrint <> []) then
	begin
	//WriteFromStringList();
	WriteFromBytes();
	end;

AProcess.Free();
end;

procedure SGPrintExceptionStackTrace(const e : TSGException; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog];const ViewTime : TSGBoolean = False);
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
SGHint(Report, CasesOfPrint, ViewTime);
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

function SGCoreCount() : TSGByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function SGShortIntToInt(Value : TSGShortInt) : TSGInteger; 
{$IFDEF WITHASMINC} assembler; register; {$ENDIF}  overload;
{$IFDEF WITHASMINC}
	asm
		cbw
		cwde
	end;
{$ELSE}
	begin
	Result := Value;
	end;
	{$ENDIF}

end.
