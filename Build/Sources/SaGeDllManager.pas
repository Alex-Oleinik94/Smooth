{$INCLUDE SaGe.inc}

//{$DEFINE DLL_MANAGER_DEBUG}

unit SaGeDllManager;

interface

uses
	SaGeCommon
	, SaGeBase
	, SaGeBased
	, SaGeClasses
	;

const
	DllManagerProcentPrecision = 3;
	DllPrefix = SGLibraryNameBegin;
	DllPostfix = SGLibraryNameEnd;

type
	TSGDllManager = class;

	PSGDllLoadObject = ^ TSGDllLoadObject;
	TSGDllLoadObject = object
			public
		FFunctionLoaded : TSGUInt32;
		FFunctionCount  : TSGUInt32;
		FFunctionErrors : TSGStringList;
			public
		procedure Clear();
		end;
	TSGDllLoadObjectList = packed array of TSGDllLoadObject;

	TSGDllLoadExtensionsObject = object(TSGDllLoadObject)
			public
		FExtensions : TSGStringList;
			public
		procedure Clear();
		end;

	TSGDllClass = class of TSGDll;
	TSGDll = class(TSGNamed)
			public
		constructor Create(); override;
		destructor  Destroy(); override;
		class function ClassName() : TSGString; override;
			public
		procedure PrintStat(const Extended : TSGBool = False);
		procedure LogStat();
		procedure LogExtStat();
		function StatString(const LoadObjectId : TSGUInt32 = 0) : TSGString;
		function ChunkName(const i : TSGUInt32) : TSGString;
			private
		FOwner         : TSGDllManager;

		FLoadExecuted  : TSGBool;
		FLoaded        : TSGBool;

		FLoadObjects   : TSGDllLoadObjectList;
		FErrorDllNames : TSGStringList;

			// Extensions
		FLoadExtensionsExecuted : TSGBool;
		FLoadedExtensions       : TSGBool;
		FExtensionsLoadObject   : TSGDllLoadExtensionsObject;
			protected
		FLibHandles    : TSGLibHandleList;
		FDllFileNames  : TSGStringList;
			public
		procedure UnLoad();
		function Loading() : TSGBool;
		function CustomLoading() : TSGBool;
		function ReLoading() : TSGBool;
		procedure LoadingChilds();
			public
		class function ChildNames() : TSGStringList; virtual;

		class function ChunkNames() : TSGStringList; virtual;
		class function DllChunkNames() : TSGStringList; virtual;
		class function LoadChunk(const VChunk : TSGString;const VDll : TSGLibHandle) : TSGDllLoadObject; virtual;
		class function LoadChunks(const VDll : TSGLibHandleList) : TSGDllLoadObjectList; virtual;
		class function ChunksLoadJointly() : TSGBool; virtual;

		class function SystemNames() : TSGStringList; virtual; abstract;
		class function DllNames() : TSGStringList; virtual; abstract;
		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; virtual; abstract;
		class procedure Free(); virtual; abstract;

		function LoadExtensions() : TSGDllLoadExtensionsObject; virtual;
			protected
		function GetSuppored() : TSGBool;
		procedure SetOwner(const VOwner : TSGDllManager);
		function TotalFunctions() : TSGUInt32;
		function LoadedFunctions() : TSGUInt32;
		class function FirstName() : TSGString;
		class function JustifedFirstName() : TSGString;
		function GenerateAllNotLoadedFunc() : TSGStringList;
			public
		procedure ReadExtensions(); virtual;
			public
		property Suppored     : TSGBool read GetSuppored;
		property Loaded       : TSGBool read FLoaded write FLoaded;
		property LoadExecuted : TSGBool read FLoadExecuted write FLoadExecuted;
		property Owner        : TSGDllManager read FOwner write SetOwner;
		end;

	TSGDllList = packed array of TSGDll;

	TSGDllManager = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			protected
		FDlls : TSGDllList;
			public
		function Loading(const VDll : TSGDll) : TSGBool;
		procedure PrintStat();
		procedure Add(const VDll : TSGDll);
		procedure Del(const VDll : TSGDll);
			public
		function Dll(const VSystemName : TSGString) : TSGDll;
		function Suppored(const VSystemName : TSGString) : TSGBool;
		function MayUnloadDll(const VFileName : TSGString): TSGBool;
		function CountUsesLibrary(const VFileName : TSGString) : TSGUInt32;

		function GenerateMaxNameLength() : TSGUInt32;
		function GenerateMaxChunkNameLength() : TSGUInt32;
			public
		class function LibrariesDirectory() : TSGString;
		class function OpenLibrary(const VLibName : TSGString; var VFileName : TSGString) : TSGLibHandle;
		end;

var
	DllManager : TSGDllManager = nil;

operator + (A, B : TSGDllLoadObject):TSGDllLoadObject; overload;

implementation

uses
	SaGeVersion
	,StrMan
	,crt
	,dos
	;

operator + (A, B : TSGDllLoadObject):TSGDllLoadObject; overload;
var
	i, ii, lA, lB : TSGUInt32;
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

function TSGDll_Procent(const count, all : TSGUInt32) : TSGString;
begin
Result := SGStr(count);
Result += '/';
if all = 0 then
	Result += '?'
else
	Result += SGStr(all);
if all > 0 then
	begin
	Result += ', ' + SGStrReal(count/all * 100, DllManagerProcentPrecision) + '%';
	end;
end;

procedure TSGDllLoadExtensionsObject.Clear();
begin
SetLength(FExtensions, 0);
inherited;
end;

procedure TSGDllLoadObject.Clear();
begin
SetLength(FFunctionErrors, 0);
FFunctionCount  := 0;
FFunctionLoaded := 0;
FFunctionErrors := nil;
end;

class function TSGDllManager.ClassName() : TSGString;
begin
Result := 'TSGDllManager';
end;

class function TSGDllManager.LibrariesDirectory() : TSGString;
begin
Result := '.'+Slash+'..'+Slash+'Libraries' + Slash + SGEngineTarget();
end;

class function TSGDllManager.OpenLibrary(const VLibName : TSGString; var VFileName : TSGString) : TSGLibHandle;

function GetDirectoryList() : TSGStringList;
var
	sr:dos.searchrec;
begin
Result := nil;
if not SGExistsDirectory(LibrariesDirectory) then
	exit;
dos.findfirst(LibrariesDirectory + Slash + '*',$10,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and (not(SGFileExists(LibrariesDirectory + Slash + sr.name))) then
		Result += TSGString(LibrariesDirectory + Slash + sr.name);
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

function LL(const VIN : TSGString; var VON : TSGString):TSGLibHandle;
begin
Result := LoadLibrary(VIN);
if Result <> 0 then
	VON := VIN;
end;

var
	DL : TSGStringList = nil;
	i : TSGUInt32;
begin
Result := LL(LibrariesDirectory + Slash + VLibName, VFileName);
if Result = 0 then
	begin
	DL := GetDirectoryList();
	if DL <> nil then
		begin
		if Length(DL) > 0 then
			begin
			for i := 0 to High(DL) do
				begin
				Result := LL(DL[i] + Slash + VLibName, VFileName);
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

function TSGDllManager.MayUnloadDll(const VFileName : TSGString): TSGBool;
begin
Result := CountUsesLibrary(VFileName) = 0;
end;

function TSGDllManager.CountUsesLibrary(const VFileName : TSGString) : TSGUInt32;
begin
Result := 0;
end;

constructor TSGDllManager.Create();
begin
inherited;
FDlls := nil;
end;

destructor TSGDllManager.Destroy();
begin
if FDlls <> nil then
	begin
	while Length(FDlls) > 0 do
		FDlls[High(FDlls)].Destroy();
	FDlls := nil;
	end;
inherited;
end;

procedure TSGDllManager.Del(const VDll : TSGDll);
var
	i, ii : TSGUInt32;
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

procedure TSGDllManager.Add(const VDll : TSGDll);
begin
if FDlls <> nil then
	SetLength(FDlls, Length(FDlls) + 1)
else
	SetLength(FDlls, 1);
FDlls[High(FDlls)] := VDll;
VDll.Owner := Self;
end;

function TSGDllManager.GenerateMaxNameLength() : TSGUInt32;
var
	i : TSGUInt32;
begin
Result := 0;
if FDlls <> nil then
	if Length(FDlls) > 0 then
		for i := 0 to High(FDlls) do
			if Result < Length(FDlls[i].FirstName) then
				Result := Length(FDlls[i].FirstName);
end;

function TSGDllManager.GenerateMaxChunkNameLength() : TSGUInt32;
var
	i, ii : TSGUInt32;
	SL : TSGStringList;
begin
Result := 0;
if FDlls <> nil then
	if Length(FDlls) > 0 then
		for i := 0 to High(FDlls) do
			begin
			SL := FDlls[i].ChunkNames();
			if SL <> nil then
				begin
				if Length(SL) > 0 then
					begin
					for ii := 0 to High(SL) do
						if Length(SL[i]) > Result then
							Result := Length(SL[i]);
					SetLength(SL, 0);
					end;
				SL := nil;
				end;
			end;
end;

procedure TSGDllManager.PrintStat();
var
	i : TSGUInt32;
	DllCount : TSGUInt32;
var
	LibLoaded, LibNotLoaded, FuncLoaded, FuncNotLoaded, AllFunc : TSGUInt32;
begin
SGPrintEngineVersion();
DllCount := 0;
if FDlls <> nil then
	DllCount := Length(FDlls);
if DllCount = 0 then
	WriteLn('Nothink to print!')
else
	begin
	LibLoaded := 0;
	LibNotLoaded := 0;
	FuncLoaded := 0;
	FuncNotLoaded := 0;
	AllFunc := 0;

	for i := 0 to DllCount - 1 do
		begin
		FDlls[i].PrintStat();

		LibLoaded    += TSGByte(FDlls[i].Suppored);
		LibNotLoaded += TSGByte(not FDlls[i].Suppored);
		FuncLoaded += FDlls[i].LoadedFunctions();
		AllFunc += FDlls[i].TotalFunctions();
		FuncNotLoaded += FDlls[i].TotalFunctions() - FDlls[i].LoadedFunctions();
		end;

	SGHint('Total     loaded functions : ' + TSGDll_Procent(FuncLoaded, AllFunc));
	if FuncNotLoaded <> 0 then
		SGHint('Total not loaded functions : ' + TSGDll_Procent(FuncNotLoaded, AllFunc));
	SGHint('Total     loaded libraries : ' + TSGDll_Procent(LibLoaded, DllCount));
	if LibNotLoaded <> 0 then
		SGHint('Total not loaded libraries : ' + TSGDll_Procent(LibNotLoaded, DllCount));
	end;
end;

function TSGDllManager.Suppored(const VSystemName : TSGString) : TSGBool;
var
	DynLibrary : TSGDll;
begin
Result := False;
DynLibrary := Dll(VSystemName);
if DynLibrary <> nil then
	Result := DynLibrary.Suppored;
end;

function TSGDllManager.Dll(const VSystemName : TSGString) : TSGDll;
var
	i : TSGUInt32;
	StringList, UpCasedStringList : TSGStringList;
begin
Result := nil;
if FDlls <> nil then
	if Length(FDlls) > 0 then
		for i := 0 to High(FDlls) do
			begin
			StringList := FDlls[i].SystemNames();
			UpCasedStringList := SGUpCaseStringList(StringList);
			if SGUpCaseString(VSystemName) in UpCasedStringList then
				Result := FDlls[i];
			SetLength(StringList, 0);
			SetLength(UpCasedStringList, 0);
			StringList := nil;
			if Result <> nil then
				break;
			end;
end;

function TSGDllManager.Loading(const VDll : TSGDll) : TSGBool;
begin
Result := VDll.Loading();
end;

// ======================================== TSGDll

class function TSGDll.ClassName() : TSGString;
begin
Result := 'TSGDll';
end;

constructor TSGDll.Create();
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
if DllManager <> nil then
	DllManager.Add(Self);
end;

destructor TSGDll.Destroy();
begin
UnLoad();
if FOwner <> nil then
	begin
	FOwner.Del(Self);
	FOwner := nil;
	end;
inherited;
end;

procedure TSGDll.UnLoad();
var
	i : TSGUInt32;
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

procedure TSGDll.SetOwner(const VOwner : TSGDllManager);
begin
FOwner := VOwner;
end;

class function TSGDll.FirstName() : TSGString;
var
	StringList : TSGStringList;
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

function TSGDll.ChunkName(const i : TSGUInt32) : TSGString;
var
	SL : TSGStringList;
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

class function TSGDll.JustifedFirstName() : TSGString;
begin
Result := FirstName();
if DllManager <> nil then
	Result := StringJustifyLeft(Result, DllManager.GenerateMaxNameLength() + 1, ' ');
end;

function TSGDll.StatString(const LoadObjectId : TSGUInt32 = 0) : TSGString;
var
	MNL, MCNL, TF, LF : TSGUInt32;
	LN : TSGString = '';
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
		Iff(TF > 0,' all of ' + SGStr(TF) + ' functions','')
else
	Result +=
		'Loaded ' +
		TSGDll_Procent(LF, TF);
Result += Iff(LN <> '', ' from ''' + LN + '''','');
if LF = 0 then
	Result += '!'
else
	Result += '.';
end;

procedure TSGDll.LogExtStat();
var
	MNL : TSGUInt32;
begin
MNL  := FOwner.GenerateMaxNameLength();
SGLog.Sourse(StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Extensions : Loaded ' + TSGDll_Procent(FExtensionsLoadObject.FFunctionLoaded, FExtensionsLoadObject.FFunctionCount) + '.');
SGLog.Sourse(FExtensionsLoadObject.FExtensions, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Extensions :');
end;

procedure TSGDll.LogStat();

function IsSeparate() : TSGBool;
begin
Result := False;
if FLoadObjects <> nil then
	Result := Length(FLoadObjects) > 1;
end;

procedure SourceSeparate();
var
	i : TSGUInt32;
begin
for i := 0 to High(FLoadObjects) do
	SGLog.Sourse(StatString(i + 1));
end;

var
	NotLoadedFunc : TSGStringList;
	MNL : TSGUInt32;
begin
MNL  := FOwner.GenerateMaxNameLength();
Loading();
if IsSeparate then
	SourceSeparate()
else
	SGLog.Sourse(StatString());
SGLog.Sourse(FErrorDllNames, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Can''t load from this libraries :');
NotLoadedFunc := GenerateAllNotLoadedFunc();
SGLog.Sourse(NotLoadedFunc, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Can''t load this functions :');
SetLength(NotLoadedFunc, 0);
end;

function TSGDll.GenerateAllNotLoadedFunc() : TSGStringList;
var
	i, ii : TSGUInt32;
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

procedure TSGDll.PrintStat(const Extended : TSGBool = False);

function IsSeparate() : TSGBool;
begin
Result := False;
if FLoadObjects <> nil then
	Result := Length(FLoadObjects) > 1;
end;

procedure WriteSeparate();
var
	i : TSGUInt32;
begin
for i := 0 to High(FLoadObjects) do
	WriteLn(StatString(i + 1));
end;

var
	MNL : TSGUInt32;
	NotLoadedFunc : TSGStringList;
begin
{$IFDEF DLL_MANAGER_DEBUG}
SGLog.Sourse('TSGDll.PrintStat(' + SGStr(Extended) + ')');
{$ENDIF}
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
	SGPrintParams(FErrorDllNames, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Can''t load from this libraries :');
	NotLoadedFunc := GenerateAllNotLoadedFunc();
	SGPrintParams(NotLoadedFunc, StringJustifyLeft(FirstName(), MNL + 1, ' ') + ': Can''t load this functions :');
	SetLength(NotLoadedFunc, 0);
	end;
TextColor(7);
end;

function TSGDll.TotalFunctions() : TSGUInt32;
var
	i : TSGUInt32;
begin
Result := 0;
if FLoadObjects <> nil then if Length(FLoadObjects) > 0 then
	for i := 0 to High(FLoadObjects) do
		Result += FLoadObjects[i].FFunctionCount;
end;

function TSGDll.LoadedFunctions() : TSGUInt32;
var
	i : TSGUInt32;
begin
Result := 0;
if FLoadObjects <> nil then if Length(FLoadObjects) > 0 then
	for i := 0 to High(FLoadObjects) do
		Result += FLoadObjects[i].FFunctionLoaded;
end;

function TSGDll.CustomLoading() : TSGBool;

function LoadJointly() : TSGBool;
var
	i : TSGUInt32;
begin
{$IFDEF DLL_MANAGER_DEBUG}
SGLog.Sourse('TSGDll.LoadJointly()');
{$ENDIF}
Result := False;
FDllFileNames := DllChunkNames();
SetLength(FLibHandles, Length(FDllFileNames));
for i := 0 to High(FLibHandles) do
	FLibHandles[i] := DllManager.OpenLibrary(FDllFileNames[i], FDllFileNames[i]);
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

function LoadSeparate() : TSGBool;
begin
{$IFDEF DLL_MANAGER_DEBUG}
SGLog.Sourse('TSGDll.LoadSeparate()');
{$ENDIF}
Result := False;
if ChunksLoadJointly() then
	Result := LoadJointly()
else
	begin

	end;
end;

function IsSeparate() : TSGBool;
var
	SL : TSGStringList;
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

function LoadNormal() : TSGBool;
var
	DllFileNames : TSGStringList;
	i : TSGUInt32;
	TestLibHandle : TSGLibHandle;
	TestLoadObject : TSGDllLoadObject;
	TestFileName : TSGString;

procedure FinalizeLoad(const Sucs : TSGBool);
begin
{$IFDEF DLL_MANAGER_DEBUG}
SGLog.Sourse('TSGDll.FinalizeLoad(' + SGStr(Sucs) + ') - Beging');
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
SGLog.Sourse('TSGDll.FinalizeLoad(' + SGStr(Sucs) + ') - End');
{$ENDIF}
end;

begin
{$IFDEF DLL_MANAGER_DEBUG}
SGLog.Sourse('TSGDll.LoadNormal() - Begin');
{$ENDIF}
Result := False;
DllFileNames := DllNames();
if DllFileNames <> nil then if Length(DllFileNames) > 0 then
	for i := 0 to High(DllFileNames) do
		begin
		{$IFDEF DLL_MANAGER_DEBUG}
		SGLog.Sourse('TSGDll.LoadNormal() - Try load from ''' + DllFileNames[i] + '''');
		{$ENDIF}
		TestLibHandle := DllManager.OpenLibrary(DllFileNames[i], TestFileName);
		{$IFDEF DLL_MANAGER_DEBUG}
		SGLog.Sourse('TSGDll.LoadNormal() - LibHandle = ''' + SGStr(TestLibHandle) + '''');
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
SGLog.Sourse('TSGDll.CustomLoading()');
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

procedure TSGDll.LoadingChilds();
var
	Childs : TSGStringList;
	i : TSGUInt32;
begin
if FOwner <> nil then
	begin
	Childs := ChildNames();
	if Childs <> nil then
		begin
		if Length(Childs) > 0 then
			begin
			for i := 0 to High(Childs) do
				FOwner.Suppored(Childs[i]);
			SetLength(Childs, 0);
			end;
		Childs := nil;
		end;
	end;
end;

procedure TSGDll.ReadExtensions();

function ReadExt () : TSGBool;
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

function TSGDll.ReLoading() : TSGBool;
begin
Result := CustomLoading();
end;

function TSGDll.Loading() : TSGBool;
begin
Result := FLoaded;
if not FLoadExecuted then
	Result := CustomLoading();
end;

function TSGDll.GetSuppored() : TSGBool;
begin
Result := Loading();
end;

class function TSGDll.ChildNames() : TSGStringList;
begin
Result := nil;
end;

class function TSGDll.ChunkNames() : TSGStringList;
begin
Result := nil;
end;

class function TSGDll.DllChunkNames() : TSGStringList;
begin
Result := nil;
end;

class function TSGDll.LoadChunk(const VChunk : TSGString; const VDll : TSGLibHandle) : TSGDllLoadObject;
begin
Result.Clear();
end;

class function TSGDll.LoadChunks(const VDll : TSGLibHandleList) : TSGDllLoadObjectList;
begin
Result := nil;
end;

function TSGDll.LoadExtensions() : TSGDllLoadExtensionsObject;
begin
Result.Clear();
end;

class function TSGDll.ChunksLoadJointly() : TSGBool;
begin
Result := False;
end;

initialization
begin
DllManager := TSGDllManager.Create();
end;

finalization
begin
DllManager.Destroy();
DllManager := nil;
end;

end.
