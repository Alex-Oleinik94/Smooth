{$INCLUDE Smooth.inc}

//{$DEFINE DLL_MANAGER_DEBUG}

unit SmoothDllManager;

interface

uses
	 SmoothCommon
	,SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothSysUtils
	;

const
	DllManagerProcentPrecision = 3;
	DllPrefix = SLibraryNameBegin;
	DllPostfix = SLibraryNameEnd;

type
	TSDllManager = class;

	PSDllLoadObject = ^ TSDllLoadObject;
	TSDllLoadObject = object
			public
		FFunctionLoaded : TSUInt32;
		FFunctionCount  : TSUInt32;
		FFunctionErrors : TSStringList;
			public
		procedure Clear();
		end;
	TSDllLoadObjectList = packed array of TSDllLoadObject;

	TSDllLoadExtensionsObject = object(TSDllLoadObject)
			public
		FExtensions : TSStringList;
			public
		procedure Clear();
		end;

	TSDllClass = class of TSDll;
	TSDll = class(TSNamed)
			public
		constructor Create(); override;
		destructor  Destroy(); override;
		class function ClassName() : TSString; override;
		class function ObjectName() : TSString; override;
			public
		procedure PrintStat(const Extended : TSBool = False);
		procedure LogStat();
		procedure LogExtStat();
		function StatString(const LoadObjectId : TSUInt32 = 0) : TSString;
		function ChunkName(const i : TSUInt32) : TSString;
		function ChunkCount() : TSUInt32;
			private
		FOwner         : TSDllManager;

		FLoadExecuted  : TSBool;
		FLoaded        : TSBool;

		FLoadObjects   : TSDllLoadObjectList;
		FErrorDllNames : TSStringList;

			// Extensions
		FLoadExtensionsExecuted : TSBool;
		FLoadedExtensions       : TSBool;
		FExtensionsLoadObject   : TSDllLoadExtensionsObject;
			protected
		FLibHandles    : TSLibHandleList;
		FDllFileNames  : TSStringList;
			public
		procedure UnLoad();
		function Loading() : TSBool;
		function CustomLoading() : TSBool;
		function ReLoading() : TSBool;
		procedure LoadingChilds();
			public
		class function ChildNames() : TSStringList; virtual;

		class function ChunkNames() : TSStringList; virtual;
		class function DllChunkNames(const ChunkIndex : TSUInt32) : TSStringList; virtual;
		class function LoadChunk(const VChunk : TSString;const VDll : TSLibHandle) : TSDllLoadObject; virtual;
		class function LoadChunks(const VDlls : TSLibHandleList) : TSDllLoadObjectList; virtual;
		class function ChunksLoadJointly() : TSBool; virtual;

		class function SystemNames() : TSStringList; virtual; abstract;
		class function DllNames() : TSStringList; virtual; abstract;
		class function Load(const VDll : TSLibHandle) : TSDllLoadObject; virtual; abstract;
		class procedure Free(); virtual; abstract;

		function LoadExtensions() : TSDllLoadExtensionsObject; virtual;
			protected
		function GetSupported() : TSBool;
		procedure SetOwner(const VOwner : TSDllManager);
		function TotalFunctions() : TSUInt32;
		function LoadedFunctions() : TSUInt32;
		class function FirstName() : TSString;
		class function JustifedFirstName() : TSString;
		function GenerateAllNotLoadedFunc() : TSStringList;
			public
		procedure ReadExtensions(); virtual;
			public
		property Supported     : TSBool read GetSupported;
		property Loaded       : TSBool read FLoaded write FLoaded;
		property LoadExecuted : TSBool read FLoadExecuted write FLoadExecuted;
		property Owner        : TSDllManager read FOwner write SetOwner;
		end;

	TSDllList = packed array of TSDll;

	TSDllManager = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FDlls : TSDllList;
			public
		function Loading(const VDll : TSDll) : TSBool;
		procedure PrintStat();
		procedure Add(const VDll : TSDll);
		procedure Del(const VDll : TSDll);
			public
		function Dll(const VSystemName : TSString) : TSDll;
		function Supported(const VSystemName : TSString) : TSBool;
		function MayUnloadDll(const VFileName : TSString): TSBool;
		function CountUsesLibrary(const VFileName : TSString) : TSUInt32;

		function GenerateMaxNameLength() : TSUInt32;
		function GenerateMaxChunkNameLength() : TSUInt32;
			public
		class function LibrariesDirectory() : TSString;
		class function OpenLibrary(const VLibName : TSString; var VFileName : TSString) : TSLibHandle;
		end;

var
	DllManager : TSDllManager = nil;

operator + (A, B : TSDllLoadObject):TSDllLoadObject; overload;

implementation

uses
	 SmoothVersion
	,SmoothLog
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothConsoleUtils
	,SmoothBaseUtils
	{$IFDEF WITHLEAKSDETECTOR}
	,SmoothLeaksDetector // not delete, for unit init/final procedures
	{$ENDIF}
	
	,StrMan
	,Crt
	,Dos
	;

operator + (A, B : TSDllLoadObject):TSDllLoadObject; overload;
var
	i, ii, lA, lB : TSUInt32;
begin
Result.Clear();
Result.FFunctionCount := A.FFunctionCount + B.FFunctionCount;
Result.FFunctionLoaded := A.FFunctionLoaded + B.FFunctionLoaded;
lA := 0;
lB := 0;
if A.FFunctionErrors <> nil then
	lA := Length(A.FFunctionErrors);
if B.FFunctionErrors <> nil then
	lB := Length(B.FFunctionErrors);
ii := lA + lB;
if ii > 0 then
	begin
	SetLength(Result.FFunctionErrors, ii);
	if lA > 0 then
		begin
		for i := 0 to lA - 1 do
			Result.FFunctionErrors[i] := A.FFunctionErrors[i];
		SetLength(A.FFunctionErrors, 0);
		end;
	if lB > 0 then
		begin
		for i := lA to ii - 1 do
			Result.FFunctionErrors[i] := B.FFunctionErrors[ii - lA];
		SetLength(B.FFunctionErrors, 0);
		end;
	end;
end;

function TSDll_Procent(const count, all : TSUInt32) : TSString;
begin
Result := SStr(count);
Result += '/';
if all = 0 then
	Result += '?'
else
	Result += SStr(all);
if all > 0 then
	begin
	Result += ', ' + SStrReal(count/all * 100, DllManagerProcentPrecision) + '%';
	end;
end;

procedure TSDllLoadExtensionsObject.Clear();
begin
SetLength(FExtensions, 0);
inherited;
end;

procedure TSDllLoadObject.Clear();
begin
SetLength(FFunctionErrors, 0);
FFunctionCount  := 0;
FFunctionLoaded := 0;
FFunctionErrors := nil;
end;

class function TSDllManager.ClassName() : TSString;
begin
Result := 'TSDllManager';
end;

class function TSDllManager.LibrariesDirectory() : TSString;
begin
Result := '..' + DirectorySeparator + 'Libraries' + DirectorySeparator + SEngineTarget();
end;

class function TSDllManager.OpenLibrary(const VLibName : TSString; var VFileName : TSString) : TSLibHandle;
var
	AbsoluteLibrariesDirectory : TSString;

function LL(const VIN : TSString; var VON : TSString):TSLibHandle;
begin
Result := LoadLibrary(VIN);
if Result <> 0 then
	VON := VIN;
end;

var
	DL : TSStringList = nil;
	i : TSUInt32;
begin
AbsoluteLibrariesDirectory := LibrariesDirectory;
if (not SExistsDirectory(AbsoluteLibrariesDirectory)) and (SAplicationFileDirectory() <> '') then
	AbsoluteLibrariesDirectory := SAplicationFileDirectory() + LibrariesDirectory;
Result := LL(AbsoluteLibrariesDirectory + DirectorySeparator + VLibName, VFileName);
if Result = 0 then
	begin
	DL := SDirectoryDirectories(AbsoluteLibrariesDirectory);
	if DL <> nil then
		begin
		if Length(DL) > 0 then
			begin
			for i := 0 to High(DL) do
				begin
				Result := LL(AbsoluteLibrariesDirectory + DirectorySeparator + DL[i] + DirectorySeparator + VLibName, VFileName);
				if Result <> 0 then
					break;
				end;
			SetLength(DL, 0);
			end;
		DL := nil;
		end;
	end;
if Result = 0 then
	Result := LL(VLibName, VFileName);
end;

function TSDllManager.MayUnloadDll(const VFileName : TSString): TSBool;
begin
Result := CountUsesLibrary(VFileName) = 0;
end;

function TSDllManager.CountUsesLibrary(const VFileName : TSString) : TSUInt32;
begin
Result := 0;
end;

constructor TSDllManager.Create();
begin
inherited;
FDlls := nil;
end;

destructor TSDllManager.Destroy();
begin
if FDlls <> nil then
	begin
	while Length(FDlls) > 0 do
		FDlls[High(FDlls)].Destroy();
	FDlls := nil;
	end;
inherited;
end;

procedure TSDllManager.Del(const VDll : TSDll);
var
	i, ii : TSUInt32;
begin
if FDlls <> nil then
	begin
	if Length(FDlls) > 0 then
		begin
		ii := Length(FDlls);
		for i := 0 to High(FDlls) do
			if FDlls[i] = VDll then
				begin
				ii := i;
				break;
				end;
		if ii <> Length(FDlls) then
			begin
			if Length(FDlls) - 1 <> ii then
				for i := ii to High(FDlls) - 1 do
					FDlls[i] := FDlls[i + 1];
			SetLength(FDlls, Length(FDlls) - 1);
			end;
		end;
	end;
end;

procedure TSDllManager.Add(const VDll : TSDll);
begin
if FDlls <> nil then
	SetLength(FDlls, Length(FDlls) + 1)
else
	SetLength(FDlls, 1);
FDlls[High(FDlls)] := VDll;
VDll.Owner := Self;
end;

function TSDllManager.GenerateMaxNameLength() : TSUInt32;
var
	i : TSUInt32;
begin
Result := 0;
if FDlls <> nil then
	if Length(FDlls) > 0 then
		for i := 0 to High(FDlls) do
			if Result < Length(FDlls[i].FirstName) then
				Result := Length(FDlls[i].FirstName);
end;

function TSDllManager.GenerateMaxChunkNameLength() : TSUInt32;
var
	i, ii : TSUInt32;
	SL : TSStringList;
begin
Result := 0;
if FDlls <> nil then
	if Length(FDlls) > 0 then
		for i := 0 to High(FDlls) do
			if FDlls[i].ChunkCount() <> 0 then
				begin
				SL := FDlls[i].ChunkNames();
				for ii := 0 to FDlls[i].ChunkCount() - 1 do
					begin
					if Length(SL[ii]) > Result then
						Result := Length(SL[ii]);
					end;
				SetLength(SL, 0);
				end;
end;

procedure TSDllManager.PrintStat();
var
	i : TSUInt32;
	DllCount : TSUInt32;
var
	LibLoaded, LibNotLoaded, FuncLoaded, FuncNotLoaded, AllFunc : TSUInt32;
begin
SPrintEngineVersion();
DllCount := 0;
if FDlls <> nil then
	DllCount := Length(FDlls);
if DllCount = 0 then
	WriteLn('Nothink to print!')
else
	begin
	SLogMakeSignificant();
	
	LibLoaded := 0;
	LibNotLoaded := 0;
	FuncLoaded := 0;
	FuncNotLoaded := 0;
	AllFunc := 0;

	for i := 0 to DllCount - 1 do
		begin
		FDlls[i].PrintStat();

		LibLoaded    += TSByte(FDlls[i].Supported);
		LibNotLoaded += TSByte(not FDlls[i].Supported);
		FuncLoaded += FDlls[i].LoadedFunctions();
		AllFunc += FDlls[i].TotalFunctions();
		FuncNotLoaded += FDlls[i].TotalFunctions() - FDlls[i].LoadedFunctions();
		end;

	SHint('Total     loaded functions : ' + TSDll_Procent(FuncLoaded, AllFunc));
	if FuncNotLoaded <> 0 then
		SHint('Total not loaded functions : ' + TSDll_Procent(FuncNotLoaded, AllFunc));
	SHint('Total     loaded libraries : ' + TSDll_Procent(LibLoaded, DllCount));
	if LibNotLoaded <> 0 then
		SHint('Total not loaded libraries : ' + TSDll_Procent(LibNotLoaded, DllCount));
	end;
end;

function TSDllManager.Supported(const VSystemName : TSString) : TSBool;
var
	DynLibrary : TSDll;
begin
Result := False;
DynLibrary := Dll(VSystemName);
if DynLibrary <> nil then
	Result := DynLibrary.Supported;
end;

function TSDllManager.Dll(const VSystemName : TSString) : TSDll;
var
	i : TSUInt32;
	StringList, UpCasedStringList : TSStringList;
begin
Result := nil;
if FDlls <> nil then
	if Length(FDlls) > 0 then
		for i := 0 to High(FDlls) do
			begin
			StringList := FDlls[i].SystemNames();
			UpCasedStringList := SUpCasedStringList(StringList);
			if SUpCaseString(VSystemName) in UpCasedStringList then
				Result := FDlls[i];
			SetLength(StringList, 0);
			SetLength(UpCasedStringList, 0);
			StringList := nil;
			if Result <> nil then
				break;
			end;
end;

function TSDllManager.Loading(const VDll : TSDll) : TSBool;
begin
Result := VDll.Loading();
end;

// ======================================== TSDll

class function TSDll.ObjectName() : TSString;
begin
Result := 'TSDll[*?]';
end;

class function TSDll.ClassName() : TSString;
begin
Result := 'TSDll';
end;

constructor TSDll.Create();
begin
inherited;
Free();
FExtensionsLoadObject.Clear();
FLoadedExtensions := False;
FLoadExtensionsExecuted := False;
FLoadObjects   := nil;
FLoadExecuted  := False;
FLoaded        := False;
FErrorDllNames := nil;
FLibHandles    := nil;
FOwner         := nil;
FDllFileNames  := nil;
if DllManager = nil then
	DllManager := TSDllManager.Create();
DllManager.Add(Self);
end;

destructor TSDll.Destroy();
begin
UnLoad();
if FOwner <> nil then
	begin
	FOwner.Del(Self);
	FOwner := nil;
	end;
inherited;
end;

procedure TSDll.UnLoad();
var
	i : TSUInt32;
begin
Free();
if FDllFileNames <> nil then
	begin
	if Length(FDllFileNames) > 0 then
		begin
		for i := 0 to High(FDllFileNames) do
			if Owner.MayUnloadDll(FDllFileNames[i]) then
				begin
				FDllFileNames[i] := '';
				if FLibHandles[i] <> 0 then
					begin
					UnLoadLibrary(FLibHandles[i]);
					FLibHandles[i] := 0;
					end;
				end;
		SetLength(FDllFileNames, 0);
		SetLength(FLibHandles, 0);
		end;
	FDllFileNames := nil;
	FLibHandles := nil;
	end;
end;

procedure TSDll.SetOwner(const VOwner : TSDllManager);
begin
FOwner := VOwner;
end;

class function TSDll.FirstName() : TSString;
var
	StringList : TSStringList;
begin
Result := '';
StringList := SystemNames();
if StringList <> nil then
	begin
	if Length(StringList) > 0 then
		begin
		Result := StringList[0];
		SetLength(StringList, 0);
		end;
	StringList := nil;
	end;
end;

function TSDll.ChunkCount() : TSUInt32;
var
	SL : TSStringList;
begin
Result := 0;
SL := ChunkNames();
if SL <> nil then
	begin
	if Length(SL) > 0 then
		begin
		Result := Length(SL);
		SetLength(SL, 0);
		end;
	SL := nil;
	end;
end;

function TSDll.ChunkName(const i : TSUInt32) : TSString;
var
	SL : TSStringList;
begin
Result := '';
SL := ChunkNames();
if SL <> nil then
	begin
	if Length(SL) > 0 then
		begin
		Result := SL[i];
		SetLength(SL, 0);
		end;
	SL := nil;
	end;
end;

class function TSDll.JustifedFirstName() : TSString;
begin
Result := FirstName();
if DllManager <> nil then
	Result := StringJustifyLeft(Result, DllManager.GenerateMaxNameLength() + 1, ' ');
end;

function TSDll.StatString(const LoadObjectId : TSUInt32 = 0) : TSString;
var
	MNL, MCNL, TF, LF : TSUInt32;
	LN : TSString = '';
begin
MNL  := FOwner.GenerateMaxNameLength();
Result := StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': ';
if LoadObjectId <> 0 then
	begin
	MCNL := FOwner.GenerateMaxChunkNameLength();
	Result += StringJustifyLeft(ChunkName(LoadObjectId - 1), MCNL + 1, ' ') + ': ';
	end;
LN := '';
TF := 0;
LF := 0;
if LoadObjectId = 0 then
	begin
	LF := LoadedFunctions();
	TF := TotalFunctions();
	if (FDllFileNames <> nil) then if (Length(FDllFileNames) = 1) then
		LN := FDllFileNames[0];
	end
else
	begin
	TF := FLoadObjects[LoadObjectId - 1].FFunctionCount;
	LF := FLoadObjects[LoadObjectId - 1].FFunctionLoaded;
	if (FDllFileNames <> nil) then if (Length(FDllFileNames) >= LoadObjectId) then if LoadObjectId >= 1 then
		LN := FDllFileNames[LoadObjectId - 1];
	end;
if LF = 0 then
	Result +=
		'Failed to load' +
		Iff(TF > 0, ' all of ' + SStr(TF) + ' functions', '')
else
	Result +=
		'Loaded ' +
		TSDll_Procent(LF, TF);
Result += Iff(LN <> '', ' from ''' + LN + '''','');
if LF = 0 then
	Result += '!'
else
	Result += '.';
end;

procedure TSDll.LogExtStat();
var
	MNL : TSUInt32;
begin
MNL  := FOwner.GenerateMaxNameLength();
SLog.Source(StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Extensions : Loaded ' + TSDll_Procent(FExtensionsLoadObject.FFunctionLoaded, FExtensionsLoadObject.FFunctionCount) + '.');
SLog.Source(FExtensionsLoadObject.FExtensions, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Extensions :');
end;

procedure TSDll.LogStat();

function IsSeparate() : TSBool;
begin
Result := False;
if FLoadObjects <> nil then
	Result := Length(FLoadObjects) > 1;
end;

procedure SourceSeparate();
var
	i : TSUInt32;
begin
for i := 0 to High(FLoadObjects) do
	SLog.Source(StatString(i + 1));
end;

var
	NotLoadedFunc : TSStringList;
	MNL : TSUInt32;
begin
MNL  := FOwner.GenerateMaxNameLength();
Loading();
if IsSeparate then
	SourceSeparate()
else
	SLog.Source(StatString());
SLog.Source(
	FErrorDllNames, 
	StringJustifyLeft(FirstName(), MNL + 1, ' ') + 
		': Can''t load from librar' + 
		Iff(Length(FErrorDllNames) > 1, 'ies', 'y') + 
		':'
	);
NotLoadedFunc := GenerateAllNotLoadedFunc();
SLog.Source(
	NotLoadedFunc, 
	StringJustifyLeft(FirstName(), MNL + 1, ' ') + 
		': Can''t load function' +
		Iff(Length(NotLoadedFunc) > 1, 's') + 
		':'
	);
SetLength(NotLoadedFunc, 0);
end;

function TSDll.GenerateAllNotLoadedFunc() : TSStringList;
var
	i, ii : TSUInt32;
begin
Result := nil;
if FLoadObjects <> nil then
	if Length(FLoadObjects) > 0 then
		for i := 0 to High(FLoadObjects) do
			if FLoadObjects[i].FFunctionErrors <> nil then
				if Length(FLoadObjects[i].FFunctionErrors) > 0 then
					for ii := 0 to High(FLoadObjects[i].FFunctionErrors) do
						Result += FLoadObjects[i].FFunctionErrors[ii];
end;

procedure TSDll.PrintStat(const Extended : TSBool = False);

function IsSeparate() : TSBool;
begin
Result := False;
if FLoadObjects <> nil then
	Result := Length(FLoadObjects) > 1;
end;

procedure WriteSeparate();
var
	i : TSUInt32;
begin
for i := 0 to High(FLoadObjects) do
	WriteLn(StatString(i + 1));
end;

var
	MNL : TSUInt32;
	NotLoadedFunc : TSStringList;
begin
{$IFDEF DLL_MANAGER_DEBUG}
SLog.Source('TSDll__PrintStat(' + SStr(Extended) + ')');
{$ENDIF}
SLogMakeSignificant();
MNL  := FOwner.GenerateMaxNameLength();
Loading();
if FLoaded then
	if TotalFunctions() = LoadedFunctions() then
		TextColor(10)
	else
		TextColor(14)
else
	TextColor(12);
if IsSeparate then
	WriteSeparate()
else
	WriteLn(StatString());
if Extended then
	begin
	TextColor(7);
	SPrintParams(FErrorDllNames, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Can''t load from this libraries :');
	NotLoadedFunc := GenerateAllNotLoadedFunc();
	SPrintParams(NotLoadedFunc, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Can''t load this functions :');
	SetLength(NotLoadedFunc, 0);
	end;
TextColor(7);
end;

function TSDll.TotalFunctions() : TSUInt32;
var
	i : TSUInt32;
begin
Result := 0;
if FLoadObjects <> nil then if Length(FLoadObjects) > 0 then
	for i := 0 to High(FLoadObjects) do
		Result += FLoadObjects[i].FFunctionCount;
end;

function TSDll.LoadedFunctions() : TSUInt32;
var
	i : TSUInt32;
begin
Result := 0;
if FLoadObjects <> nil then if Length(FLoadObjects) > 0 then
	for i := 0 to High(FLoadObjects) do
		Result += FLoadObjects[i].FFunctionLoaded;
end;

function TSDll.CustomLoading() : TSBool;

function LoadJointly() : TSBool;
var
	i, ii : TSUInt32;
	ChunckDllNames : TSStringList = nil;
begin
{$IFDEF DLL_MANAGER_DEBUG}
SLog.Source('TSDll__LoadJointly()');
{$ENDIF}
Result := False;
SetLength(FDllFileNames, ChunkCount());
for i := 0 to ChunkCount() - 1 do
	FDllFileNames[i] := '';
SetLength(FLibHandles, ChunkCount());
for i := 0 to ChunkCount() - 1 do
	begin
	ChunckDllNames := DllChunkNames(i);
	FLibHandles[i] := 0;
	if ChunckDllNames <> nil then
		if Length(ChunckDllNames) > 0 then
			for ii := 0 to High(ChunckDllNames) do
				begin
				FLibHandles[i] := DllManager.OpenLibrary(ChunckDllNames[ii], FDllFileNames[i]);
				if FLibHandles[i] <> 0 then
					break;
				end;
	SetLength(ChunckDllNames, 0);
	end;
FLoadObjects := LoadChunks(FLibHandles);
Result := True;
if FLoadObjects <> nil then
	if Length(FLoadObjects) > 0 then
		for i := 0 to High(FLoadObjects) do
			if FLoadObjects[i].FFunctionLoaded = 0 then
				begin
				Result := False;
				break;
				end;
end;

function LoadSeparate() : TSBool;
begin
{$IFDEF DLL_MANAGER_DEBUG}
SLog.Source('TSDll__LoadSeparate()');
{$ENDIF}
Result := False;
if ChunksLoadJointly() then
	Result := LoadJointly()
else
	begin

	end;
end;

function IsSeparate() : TSBool;
var
	SL : TSStringList;
begin
Result := False;
SL := ChunkNames();
if SL <> nil then
	begin
	if Length(SL) > 0 then
		begin
		Result := Length(SL) > 1;
		SetLength(SL, 0);
		end;
	SL := nil;
	end;
end;

function LoadNormal() : TSBool;
var
	DllFileNames : TSStringList;
	i : TSUInt32;
	TestLibHandle : TSLibHandle;
	TestLoadObject : TSDllLoadObject;
	TestFileName : TSString;

procedure FinalizeLoad(const Sucs : TSBool);
begin
{$IFDEF DLL_MANAGER_DEBUG}
SLog.Source('TSDll__FinalizeLoad(' + SStr(Sucs) + ') - Beging');
{$ENDIF}
SetLength(FLoadObjects, 1);
FLoadObjects[0] := TestLoadObject;
SetLength(FDllFileNames, 1);
FDllFileNames[0] := TestFileName;
SetLength(FLibHandles, 1);
FLibHandles[0] := TestLibHandle;

TestLibHandle := 0;
TestLoadObject.Clear();
Result := Sucs;
{$IFDEF DLL_MANAGER_DEBUG}
SLog.Source('TSDll.FinalizeLoad(' + SStr(Sucs) + ') - End');
{$ENDIF}
end;

begin
{$IFDEF DLL_MANAGER_DEBUG}
SLog.Source('TSDll__LoadNormal() - Begin');
{$ENDIF}
Result := False;
DllFileNames := DllNames();
if DllFileNames <> nil then if Length(DllFileNames) > 0 then
	for i := 0 to High(DllFileNames) do
		begin
		{$IFDEF DLL_MANAGER_DEBUG}
		SLog.Source('TSDll__LoadNormal() - Try load from ''' + DllFileNames[i] + '''');
		{$ENDIF}
		TestLibHandle := DllManager.OpenLibrary(DllFileNames[i], TestFileName);
		{$IFDEF DLL_MANAGER_DEBUG}
		SLog.Source('TSDll__LoadNormal() - LibHandle = ''' + SStr(TestLibHandle) + '''');
		{$ENDIF}
		if TestLibHandle <> 0 then
			begin
			TestLoadObject := Load(TestLibHandle);
			if TestLoadObject.FFunctionLoaded > 0 then
				FinalizeLoad(True)
			else if TestLoadObject.FFunctionCount > 0 then
				FinalizeLoad(False)
			else
				TestLoadObject.Clear();
			end;
		if not Result then
			begin
			FErrorDllNames += DllFileNames[i];
			if Owner.MayUnloadDll(DllFileNames[i]) and (TestLibHandle <> 0) then
				begin
				UnLoadLibrary(TestLibHandle);
				TestLibHandle := 0;
				end;
			end
		else
			break;
		end;
SetLength(DllFileNames, 0);
end;

begin
{$IFDEF DLL_MANAGER_DEBUG}
SLog.Source('TSDll__CustomLoading()');
{$ENDIF}
if not FLoaded then
	if IsSeparate() then
		FLoaded := LoadSeparate();
if not FLoaded then
	FLoaded := LoadNormal();
FLoadExecuted := True;
Result := FLoaded;
LogStat();
if FLoaded then
	LoadingChilds();
end;

procedure TSDll.LoadingChilds();
var
	Childs : TSStringList;
	i : TSUInt32;
begin
if FOwner <> nil then
	begin
	Childs := ChildNames();
	if Childs <> nil then
		begin
		if Length(Childs) > 0 then
			begin
			for i := 0 to High(Childs) do
				FOwner.Supported(Childs[i]);
			SetLength(Childs, 0);
			end;
		Childs := nil;
		end;
	end;
end;

procedure TSDll.ReadExtensions();

function ReadExt () : TSBool;
begin
Result := False;
FExtensionsLoadObject := LoadExtensions();
Result := FExtensionsLoadObject.FFunctionLoaded > 0;
end;

begin
if not FLoadExtensionsExecuted then
	begin
	FLoadedExtensions := ReadExt();
	FLoadExtensionsExecuted := True;
	LogExtStat();
	end;
end;

function TSDll.ReLoading() : TSBool;
begin
Result := CustomLoading();
end;

function TSDll.Loading() : TSBool;
begin
Result := FLoaded;
if not FLoadExecuted then
	Result := CustomLoading();
end;

function TSDll.GetSupported() : TSBool;
begin
Result := Loading();
end;

class function TSDll.ChildNames() : TSStringList;
begin
Result := nil;
end;

class function TSDll.ChunkNames() : TSStringList;
begin
Result := nil;
end;

class function TSDll.DllChunkNames(const ChunkIndex : TSUInt32) : TSStringList;
begin
Result := nil;
end;

class function TSDll.LoadChunk(const VChunk : TSString; const VDll : TSLibHandle) : TSDllLoadObject;
begin
Result.Clear();
end;

class function TSDll.LoadChunks(const VDlls : TSLibHandleList) : TSDllLoadObjectList;
begin
Result := nil;
end;

function TSDll.LoadExtensions() : TSDllLoadExtensionsObject;
begin
Result.Clear();
end;

class function TSDll.ChunksLoadJointly() : TSBool;
begin
Result := False;
end;

initialization
begin
if DllManager = nil then
	DllManager := TSDllManager.Create();
end;

finalization
begin
if DllManager <> nil then
	begin
	DllManager.Destroy();
	DllManager := nil;
	end;
end;

end.
