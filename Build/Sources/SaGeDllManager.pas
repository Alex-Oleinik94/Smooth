{$INCLUDE SaGe.inc}

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

	TSGDllClass = class of TSGDll;
	TSGDll = class(TSGNamed)
			public
		constructor Create(); override;
		destructor  Destroy(); override;
			public
		procedure PrintStat(const Extended : TSGBool = False);
		procedure LogStat();
		function StatString() : TSGString;
			private
		FOwner         : TSGDllManager;
		FLoadExecuted  : TSGBool;
		FLoaded        : TSGBool;
		FLoadObjects   : TSGDllLoadObjectList;
		FErrorDllNames : TSGStringList;
		FLibHandle     : TSGLibHandle;
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

		class function SystemNames() : TSGStringList; virtual; abstract;
		class function DllNames() : TSGStringList; virtual; abstract;
		class function Load(const VDll : TSGLibHandle) : TSGDllLoadObject; virtual; abstract;
		class procedure Free(); virtual; abstract;
			protected
		function GetSuppored() : TSGBool;
		procedure SetOwner(const VOwner : TSGDllManager);
		function TotalFunctions() : TSGUInt32;
		function LoadedFunctions() : TSGUInt32;
		class function FirstName() : TSGString;
		function GenerateAllNotLoadedFunc() : TSGStringList;
			public
		property Suppored : TSGBool read GetSuppored;
		property Loaded   : TSGBool read FLoaded write FLoaded;
		property LoadExecuted : TSGBool read FLoadExecuted write FLoadExecuted;
		property Owner    : TSGDllManager read FOwner write SetOwner;
		end;

	TSGDllList = packed array of TSGDll;

	TSGDllManager = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FDlls : TSGDllList;
			public
		function Loading(const VDll : TSGDll) : TSGBool;
		procedure PrintStat();
		procedure Add(const VDll : TSGDll);
		procedure Del(const VDll : TSGDll);
			public
		function Dll(const VSystemName : TSGString) : TSGDll;
		function DllSuppored(const VSystemName : TSGString) : TSGBool;
		function MayUnloadDll(const VFileName : TSGString): TSGBool;
		function CountUsesLibrary(const VFileName : TSGString) : TSGUInt32;
		end;

var
	DllManager : TSGDllManager = nil;

operator + (A, B : TSGDllLoadObject):TSGDllLoadObject; overload;

implementation

uses
	SaGeVersion
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

procedure TSGDllLoadObject.Clear();
begin
SetLength(FFunctionErrors, 0);
FFunctionCount  := 0;
FFunctionLoaded := 0;
FFunctionErrors := nil;
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

	WriteLn('Total     loaded functions : ', TSGDll_Procent(FuncLoaded, AllFunc));
	if FuncNotLoaded <> 0 then
		WriteLn('Total not loaded functions : ', TSGDll_Procent(FuncNotLoaded, AllFunc));
	WriteLn('Total     loaded libraries : ', TSGDll_Procent(LibLoaded, DllCount));
	if LibNotLoaded <> 0 then
		WriteLn('Total not loaded libraries : ', TSGDll_Procent(LibNotLoaded, DllCount));
	end;
end;

function TSGDllManager.DllSuppored(const VSystemName : TSGString) : TSGBool;
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

constructor TSGDll.Create();
begin
inherited;
Free();
FLoadObjects   := nil;
FLoadExecuted  := False;
FLoaded        := False;
FErrorDllNames := nil;
FLibHandle     := 0;
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
				UnLoadLibrary(FLibHandle);
				FDllFileNames[i] := '';
				FLibHandle := 0;
				end;
		SetLength(FDllFileNames, 0);
		end;
	FDllFileNames := nil;
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

function TSGDll.StatString() : TSGString;
begin
Result := FirstName() + ': ';
if LoadedFunctions() = 0 then
	begin
	Result += 'Failed to load' + Iff(TotalFunctions() > 0,' all of ' + SGStr(TotalFunctions()) + ' functions','') + '!';
	end
else
	Result +=
		'Loaded ' +
		TSGDll_Procent(LoadedFunctions(), TotalFunctions()) +
		Iff(FDllFileNames <> nil,' from ''' + FDllFileNames[0] + '''','') +
		'.';
end;

procedure TSGDll.LogStat();
var
	NotLoadedFunc : TSGStringList;
begin
Loading();
SGLog.Sourse([StatString()]);
SGLog.Sourse(FErrorDllNames, FirstName() + ': Can''t load from this libraries :');
NotLoadedFunc := GenerateAllNotLoadedFunc();
SGLog.Sourse(NotLoadedFunc, FirstName() + ': Can''t load this functions :');
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
var
	NotLoadedFunc : TSGStringList;
begin
Loading();
WriteLn(StatString());
if Extended then
	begin
	SGPrintParams(FErrorDllNames, FirstName() + ': Can''t load from this libraries :');
	NotLoadedFunc := GenerateAllNotLoadedFunc();
	SGPrintParams(NotLoadedFunc, FirstName() + ': Can''t load this functions :');
	SetLength(NotLoadedFunc, 0);
	end;
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

function LoadSeparate() : TSGBool;
begin
Result := False;
end;

function IsSeparate() : TSGBool;
begin
Result := False;
end;

function LoadNormal() : TSGBool;
var
	DllFileNames : TSGStringList;
	i : TSGUInt32;
	TestLibHandle : TSGLibHandle;
	TestLoadObject : TSGDllLoadObject;
begin
Result := False;
DllFileNames := DllNames();
if DllFileNames <> nil then if Length(DllFileNames) > 0 then
	for i := 0 to High(DllFileNames) do
		begin
		TestLibHandle := LoadLibrary(DllFileNames[i]);
		if TestLibHandle <> 0 then
			begin
			TestLoadObject := Load(TestLibHandle);
			if TestLoadObject.FFunctionCount > 0 then
				begin
				SetLength(FLoadObjects, 1);
				FLoadObjects[0] := TestLoadObject;
				SetLength(FDllFileNames, 1);
				FDllFileNames[0] := DllFileNames[i];
				FLibHandle := TestLibHandle;

				TestLibHandle := 0;
				fillchar(TestLoadObject, SizeOf(TestLoadObject), 0);
				Result := True;
				end
			else
				TestLoadObject.Clear();
			end;
		if not Result then
			begin
			FErrorDllNames += DllFileNames[i];
			if Owner.MayUnloadDll(DllFileNames[i]) then
				UnLoadLibrary(TestLibHandle);
			TestLibHandle := 0;
			end
		else
			break;
		end;
SetLength(DllFileNames, 0);
end;

begin
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
				FOwner.DllSuppored(Childs[i]);
			SetLength(Childs, 0);
			end;
		Childs := nil;
		end;
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
