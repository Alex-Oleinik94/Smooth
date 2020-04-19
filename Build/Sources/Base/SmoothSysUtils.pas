{$INCLUDE Smooth.inc}
//{$DEFINE USE_uSMBIOS} ("deprecated")

unit SmoothSysUtils;

interface

uses
	 SysUtils
	{$IFDEF MSWINDOWS}
		,Windows
		{$ENDIF}
	
	,SmoothBase
	,SmoothCasesOfPrint
	;

// Core
function SCoreCount() : TSByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Libraries
const
	SLibraryNameBegin = 
		{$IFDEF UNIX}
			'lib'
		{$ELSE}
			''
		{$ENDIF}
		;
	SLibraryNameEnd =
		{$IFDEF UNIX}
			'.so'
		{$ELSE} {$IFDEF MSWINDOWS}
			'.dll'
		{$ELSE}
			''
		{$ENDIF} {$ENDIF}
		;

type
	TSLibHandle = type TSMaxEnum;
	TSLibHandleList = type packed array of TSLibHandle;
	TSLibraryHandle = TSLibHandle;
	TSLibraryHandleList = TSLibHandleList;
	TSLibrary = class
			public
		constructor Create(const VLibraryName : TSString);
		destructor Destroy();override;
			private
		FLibrary : TSLibHandle;
			public
		function GetProcedureAddress(const VProcedureName : TSString) : TSPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property LibHandle : TSLibHandle read FLibrary;
		property LibraryHandle : TSLibHandle read FLibrary;
		end;

function LoadLibrary(const AName : PSChar): TSLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function LoadLibrary(const AName : TSString): TSLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function UnloadLibrary(const VLib : TSLibHandle) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function GetProcAddress(const Lib : TSLibHandle; const VPChar : PSChar) : TSPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function GetProcAddress(const Lib : TSLibHandle; const VPChar : TSString) : TSPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

// Stack Trace
type
	TSException = Exception;
procedure SPrintStackTrace();
procedure SPrintExceptionStackTrace(const e : TSException; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog];const ViewTime : TSBoolean = False);
procedure SLogException(const Title : TSString; const e : Exception);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Other
function SShortIntToInt(Value : TSShortInt) : TSInteger; {$IFDEF WITHASMINC} assembler; register; {$ENDIF} overload;
procedure SRunComand(const Comand : TSString; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
function SOperatingSystemVersion(): TSString;

implementation

uses
	 Crt
	{$IFDEF USE_uSMBIOS}
		,uSMBIO
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,dl
		{$ENDIF}
	,DynLibs
	,Process
	,Classes
	
	,SmoothLog
	,SmoothLists
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothBaseUtils
	{$IFDEF MSWINDOWS}
		,SmoothWinAPIUtils
	{$ELSE}
		,SmoothVersion
		{$ENDIF}
	;

procedure SLogException(const Title : TSString; const e : Exception);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SLog.Source([Title, ' --->']);
SPrintExceptionStackTrace(e, [SCaseLog]);
end;

function SOperatingSystemVersion(): TSString;
begin
Result := '';
{$IFDEF MSWINDOWS}
Result := SWinAPISystemVersion();
{$ELSE}
Result := SEngineTargetVersion();
{$ENDIF}
end;

destructor TSLibrary.Destroy;
begin
if FLibrary <> 0 then
	begin
	UnloadLibrary(FLibrary);
	FLibrary := 0;
	end;
inherited;
end;

constructor TSLibrary.Create(const VLibraryName : TSString);
begin
inherited Create();
FLibrary := LoadLibrary(VLibraryName);
end;

function TSLibrary.GetProcedureAddress(const VProcedureName : TSString) : Pointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := GetProcAddress(FLibrary, VProcedureName);
end;

procedure SRunComand(const Comand : TSString; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
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

procedure WriteFromBytes(const SkipEolns : TSBoolean = True);
const
	Eolns = [#13, #10];
var
	Error : TSBoolean;
	C, lC, N : TSChar;
	Str : TSString = '';

procedure ProcessString();
begin
if Str <> '' then
	begin
	SHint(Str, CasesOfPrint, False);
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
		N := TSChar(AProcess.Output.ReadByte);
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
		Write(TSChar(AProcess.Output.ReadByte));
		except
		Error := True;
		end;
		if Error then
			Sleep(10);
		end;
end;

procedure LogComand();
var
	StringList : TSStringList = nil;
	Index : TSUInt32;
begin
SLog.Source(['SRunComand(..). Executing comand ', Iff(Length(Comand) < 80, ': ' + Comand, '--->')]);
if Length(Comand) >= 80 then
	if Length(Comand) < 137 then
		SLog.Source(['	Comand : ', Comand], False)
	else
		begin
		StringList := SStringListFromString(Comand, ' ');
		SLog.Source(['	Executable : ', Iff(Length(StringList) > 0, StringList[0], '???')], False);
		if Length(StringList) > 1 then
			begin
			for Index := 0 to High(StringList) - 1 do
				StringList[Index] := StringList[Index + 1];
			SetLength(StringList, Length(StringList) - 1);
			SLog.Source(StringList, '	Params : ', False);
			end;
		SetLength(StringList, 0);
		end;
end;

begin
if SCaseLog in CasesOfPrint then
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

procedure SPrintExceptionStackTrace(const e : TSException; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog];const ViewTime : TSBoolean = False);
var
	I, H   : Integer;
	Frames : PPointer;
	Report : TSString;
	{Frame  : Pointer;   // How to get long stack trace
	OldFrame : Pointer;}
begin
Report := 'An unhandled exception occurred at ' + SAddrStr(ExceptAddr) + ':' + DefaultEndOfLine;
if E <> nil then
	Report += E.ClassName + ': ' + E.Message + DefaultEndOfLine;
Report += BackTraceStrFunc(ExceptAddr) + DefaultEndOfLine;
if (ExceptFrameCount > 0) then
	begin
	H := ExceptFrameCount - 1;
	Frames := ExceptFrames;
	for I := 0 to H do
		begin
		Report += BackTraceStrFunc(Frames[I]);
		if I <> H then
			Report += DefaultEndOfLine;
		end;
	{Frame := get_caller_frame(Frames[H], get_caller_addr(Frames[H]));
	while (Frame <> nil) do
		begin
		Report += BackTraceStrFunc(get_caller_addr(Frame));
		OldFrame := Frame;
		Frame := get_caller_frame(Frame);
		if (Frame <= OldFrame) then
			Frame := nil;
		end;}
	end;
SHint(Report, CasesOfPrint, ViewTime);
Report := '';
end;

procedure SPrintStackTrace();
var
	bp: Pointer;
	addr: Pointer;
	oldbp: Pointer;
begin
bp := get_caller_frame(get_frame);
while bp<>nil do
	begin
	addr := get_caller_addr(bp);
	SHint(BackTraceStrFunc(addr));
	oldbp := bp;
	bp := get_caller_frame(bp);
	if (bp <= oldbp) or (bp > (StackBottom + StackLength)) then
		bp := nil;
	end;
end;

function UnloadLibrary(const VLib : TSLibHandle) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := dynlibs.UnloadLibrary(VLib);
end;

function GetProcAddress(const Lib : TSLibHandle; const VPChar : PSChar):TSPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
{$IFDEF WINDOWS}
	Result := Windows.GetProcAddress(Lib, VPChar);
{$ELSE}
	Result := GetProcedureAddress(Lib, VPChar);
	{$ENDIF}
end;

function GetProcAddress(const Lib : TSLibHandle; const VPChar : TSString) : TSPointer;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PC : PSChar;
begin
PC := SStringToPChar(VPChar);
Result := GetProcAddress(Lib, PC);
SPCharFree(PC, True);
end;

function LoadLibrary(const AName : TSString) : TSLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	PC : PSChar;
begin
PC := SStringToPChar(AName);
Result := LoadLibrary(PC);
SPCharFree(PC, True);
end;

function LoadLibrary(const AName: PSChar) : TSLibHandle;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result:=
	{$ifdef UNIX}
		TSLibHandle( dlopen(AName, RTLD_LAZY or RTLD_GLOBAL));
	{$else}
		Windows.LoadLibrary(AName);
		{$endif}
end;

function SCoreCount() : TSByte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function SShortIntToInt(Value : TSShortInt) : TSInteger; 
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
