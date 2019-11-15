{$INCLUDE SaGe.inc}

unit SaGeFileOpener;

interface

uses
	 Classes
	
	,SaGeBase
	,SaGeLists
	,SaGeBaseClasses
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeStringUtils
	;

type
	TSGFileOpenerDrawable = class;
	TSGFileOpenerDrawableClass = class of TSGFileOpenerDrawable;

	TSGFileOpener = class;
	TSGFileOpenerClass = class of TSGFileOpener;
	TSGFileOpener = class(TSGNamed)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; virtual;
		class procedure Execute(const VFiles : TSGStringList);virtual;
		class function GetDrawableClass() : TSGFileOpenerDrawableClass;virtual;
		class function ExpansionsSupported(const VExpansions : TSGStringList) : TSGBool; virtual;
		end;

	TSGFileOpenerDrawable = class(TSGPaintableObject)
			protected
		FFiles : TSGStringList;
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);override;
		end;

var
	FileOpenerConsoleMenuEnabled : TSGBoolean = False; //Выключено по умолчанию из-за неправильного функционирования

procedure SGRegistryFileOpener(const VClass : TSGFileOpenerClass);
procedure SGTryOpenFiles(const VFiles : TSGStringList);
procedure SGWriteOpenableExpansions();
procedure SGOpenFilesWithMenu(const VFiles : TSGStringList);

implementation

uses
	 SaGeVersion
	,SaGeContext
	,SaGeContextHandler
	,SaGeLog
	,SaGeFileUtils
	,SaGeBaseUtils
	,SaGeConsoleUtils
	,SaGeContextUtils
	{$IFDEF MSWINDOWS}
		,SaGeWinAPIUtils
		{$ENDIF}
	
	// Openers :
	,SaGeImageFileOpener
	,SaGeAudioFileOpener
	;

var
	SGFileOpeners : packed array of TSGFileOpenerClass = nil;

procedure SGOpenFilesWithMenu(const VFiles : TSGStringList);

procedure ExecuteFileOpener(const Index : TSGConsoleRecordIndex);
begin
SGFileOpeners[Index].Execute(VFiles);
end;

var
	ConsoleList : TSGConsoleMenuList = nil;
	i : TSGUInt32;
begin
if (SGFileOpeners <> nil) and (Length(SGFileOpeners) > 0) then
	begin
	for i := 0 to High(SGFileOpeners) do
		ConsoleList += SGConsoleRecord(SGFileOpeners[i].ClassName(), @ExecuteFileOpener);
	SGConsoleMenu(ConsoleList,
		SGConsoleMenuDefaultBackGroundColor,
		SGConsoleMenuDefaultTextColor,
		SGConsoleMenuDefaultActiveBackGroundColor,
		SGConsoleMenuDefaultActiveTextColor,
		SGConsoleMenuDefaultKoima,
		True);
	SetLength(ConsoleList, 0);
	end;
end;

procedure SGWriteOpenableExpansions();
var
	SL : TSGStringList = nil;
	SL2 : TSGStringList = nil;
	i, ii : TSGLongWord;
	Len : TSGUInt32 = 0;

begin
SGPrintEngineVersion();
if SGFileOpeners <> nil then if Length(SGFileOpeners) > 0 then
	for i := 0 to High(SGFileOpeners) do
		begin
		SL2 := SGFileOpeners[i].GetExpansions();
		if SL2 <> nil then if Length(SL2) > 0 then
			begin
			for ii := 0 to High(SL2) do
				SL *= SL2[ii];
			SetLength(SL2, 0);
			end;
		end;
Len := Length(SL);
if Len <> 0 then
	begin
	ii := Length(SGFileOpeners);
	SGHint(['Supported expansion', Iff(Len > 1, 's'), ' (', Len, '), file opener list (', ii, ') :']);
	if SGFileOpeners <> nil then if Length(SGFileOpeners) > 0 then
		for i := 0 to High(SGFileOpeners) do
			begin
			SL2 := SGFileOpeners[i].GetExpansions();
			if (SL2 <> nil) and (Length(SL2) > 0) then
				begin
				Len := Length(SL2);
				SGHint(['  ', SGFileOpeners[i].ClassName(), ' (', Len, ') : ', SGDownCaseString(SGStringFromStringList(SL2, ', ')), '.']);
				SetLength(SL2, 0);
				end
			else
				SGHint(['  ', SGFileOpeners[i].ClassName(), ' not suppored!']);
			end;
	end
else
	SGHint('No suppored to open expansions found!');
SetLength(SL, 0);
end;

procedure SGTryOpenFiles(const VFiles : TSGStringList);

procedure FindFileOpenerAndOpenFiles();
var
	C, EC : TSGFileOpenerClass;
	SL1 : TSGStringList;
	i : TSGLongWord;
begin
EC := nil;
SL1 := nil;
for i := 0 to High(VFiles) do
	SL1 *= SGUpCaseString(SGFileExpansion(VFiles[i]));
for C in SGFileOpeners do
	if C.ExpansionsSupported(SL1) then
		begin
		EC := C;
		break;
		end;
if EC <> nil then
	EC.Execute(VFiles)
else
	begin
	SGHint(['Can''t open file' + Iff(Length(VFiles) > 1, 's') + ':']);
	for i := 0 to High(VFiles) do
		SGHint('    ' + VFiles[i]);
	SGHint(['Which expansion' + Iff(Length(SL1) > 1, 's') + ' is ', SGStringFromStringList(SL1,','),'.']);
	SGHint(['Error : Class which can open' + Iff(Length(SL1) > 1, ' all of') + ' this expansion' + Iff(Length(SL1) > 1, 's') + ' is missing!']);
	{$IFDEF MSWINDOWS}
	if SGIsConsole() then
		begin
		Write('Press Enter to exit...');
		ReadLn();
		end;
	{$ENDIF}
	end;
SetLength(SL1, 0);
end;

begin
if VFiles = nil then
	Exit;
if Length(VFiles) = 0 then
	Exit;
{$IFDEF MSWINDOWS}
	if SGIsConsole() and SGSystemKeyPressed(17){CTRL} and FileOpenerConsoleMenuEnabled then
		SGOpenFilesWithMenu(VFiles)
	else
	{$ENDIF}
		FindFileOpenerAndOpenFiles();
end;

procedure SGRegistryFileOpener(const VClass : TSGFileOpenerClass);
begin
if SGFileOpeners = nil then
	SetLength(SGFileOpeners, 1)
else
	SetLength(SGFileOpeners, Length(SGFileOpeners) + 1);
SGFileOpeners[High(SGFileOpeners)] := VClass;
end;

class function TSGFileOpener.ExpansionsSupported(const VExpansions : TSGStringList) : TSGBool;
begin
Result := False;
end;

class function TSGFileOpener.GetDrawableClass() : TSGFileOpenerDrawableClass;
begin
Result := nil;
end;

procedure TSGFileOpenerDrawable.SetOption(const VName : TSGString; const VValue : TSGPointer);
begin
if VName = 'FILES TO OPEN' then
	FFiles := TSGStringList(VValue)
else
	inherited;
end;

destructor TSGFileOpenerDrawable.Destroy();
begin
SetLength(FFiles, 0);
inherited;
end;

constructor TSGFileOpenerDrawable.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FFiles := nil;
end;

class function TSGFileOpenerDrawable.ClassName() : TSGString;
begin
Result := 'TSGFileOpenerDrawable';
end;

class function TSGFileOpener.ClassName() : TSGString;
begin
Result := 'TSGFileOpener';
end;

class procedure TSGFileOpener.Execute(const VFiles : TSGStringList);
begin
SGCompatibleRunPaintable(GetDrawableClass(), SGContextOptionImport('FILES TO OPEN', TSGPointer(VFiles)) + SGContextOptionMax());
end;

class function TSGFileOpener.GetExpansions() : TSGStringList;
begin
Result := nil;
end;

finalization
begin
SetLength(SGFileOpeners, 0);
end;

end.
