{$INCLUDE Smooth.inc}

unit SmoothFileOpener;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothStringUtils
	;

type
	TSFileOpenerDrawable = class;
	TSFileOpenerDrawableClass = class of TSFileOpenerDrawable;

	TSFileOpener = class;
	TSFileOpenerClass = class of TSFileOpener;
	TSFileOpener = class(TSNamed)
			public
		class function ClassName() : TSString; override;
		class function GetExtensions() : TSStringList; virtual;
		class procedure Execute(const VFiles : TSStringList);virtual;
		class function GetDrawableClass() : TSFileOpenerDrawableClass;virtual;
		class function ExtensionsSupported(const VExtensions : TSStringList) : TSBool; virtual;
		end;

	TSFileOpenerDrawable = class(TSPaintableObject)
			protected
		FFiles : TSStringList;
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
		procedure SetOption(const VName : TSString; const VValue : TSPointer);override;
		end;

var
	FileOpenerConsoleMenuEnabled : TSBoolean = False; //Выключено по умолчанию из-за неправильного функционирования

procedure SRegistryFileOpener(const VClass : TSFileOpenerClass);
procedure STryOpenFiles(const VFiles : TSStringList);
procedure SWriteOpenableExtensions();
procedure SOpenFilesWithMenu(const VFiles : TSStringList);

implementation

uses
	 SmoothVersion
	,SmoothContext
	,SmoothContextHandler
	,SmoothLog
	,SmoothFileUtils
	,SmoothBaseUtils
	,SmoothConsoleUtils
	,SmoothContextUtils
	{$IFDEF MSWINDOWS}
		,SmoothWinAPIUtils
		{$ENDIF}
	
	// Openers :
	,SmoothImageFileOpener
	,SmoothAudioFileOpener
	;

var
	SFileOpeners : packed array of TSFileOpenerClass = nil;

procedure SOpenFilesWithMenu(const VFiles : TSStringList);

procedure ExecuteFileOpener(const Index : TSConsoleRecordIndex);
begin
SFileOpeners[Index].Execute(VFiles);
end;

var
	ConsoleList : TSConsoleMenuList = nil;
	i : TSUInt32;
begin
if (SFileOpeners <> nil) and (Length(SFileOpeners) > 0) then
	begin
	for i := 0 to High(SFileOpeners) do
		ConsoleList += SConsoleRecord(SFileOpeners[i].ClassName(), @ExecuteFileOpener);
	SConsoleMenu(ConsoleList,
		SConsoleMenuDefaultBackGroundColor,
		SConsoleMenuDefaultTextColor,
		SConsoleMenuDefaultActiveBackGroundColor,
		SConsoleMenuDefaultActiveTextColor,
		SConsoleMenuDefaultKoima,
		True);
	SetLength(ConsoleList, 0);
	end;
end;

procedure SWriteOpenableExtensions();
var
	SL : TSStringList = nil;
	SL2 : TSStringList = nil;
	i, ii : TSLongWord;
	Len : TSUInt32 = 0;

begin
SPrintEngineVersion();
if SFileOpeners <> nil then if Length(SFileOpeners) > 0 then
	for i := 0 to High(SFileOpeners) do
		begin
		SL2 := SFileOpeners[i].GetExtensions();
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
	ii := Length(SFileOpeners);
	SHint(['Supported Extension', Iff(Len > 1, 's'), ' (', Len, '), file opener list (', ii, ') :']);
	if SFileOpeners <> nil then if Length(SFileOpeners) > 0 then
		for i := 0 to High(SFileOpeners) do
			begin
			SL2 := SFileOpeners[i].GetExtensions();
			if (SL2 <> nil) and (Length(SL2) > 0) then
				begin
				Len := Length(SL2);
				SHint(['  ', SFileOpeners[i].ClassName(), ' (', Len, ') : ', SDownCaseString(SStringFromStringList(SL2, ', ')), '.']);
				SetLength(SL2, 0);
				end
			else
				SHint(['  ', SFileOpeners[i].ClassName(), ' not suppored!']);
			end;
	end
else
	SHint('No suppored to open Extensions found!');
SetLength(SL, 0);
end;

procedure STryOpenFiles(const VFiles : TSStringList);

procedure FindFileOpenerAndOpenFiles();
var
	C, EC : TSFileOpenerClass;
	SL1 : TSStringList;
	i : TSLongWord;
begin
EC := nil;
SL1 := nil;
for i := 0 to High(VFiles) do
	SL1 *= SFileExtension(VFiles[i], True);
for C in SFileOpeners do
	if C.ExtensionsSupported(SL1) then
		begin
		EC := C;
		break;
		end;
if EC <> nil then
	EC.Execute(VFiles)
else
	begin
	SHint(['Can''t open file' + Iff(Length(VFiles) > 1, 's') + ':']);
	for i := 0 to High(VFiles) do
		SHint('    ' + VFiles[i]);
	SHint(['Which Extension' + Iff(Length(SL1) > 1, 's') + ' is ', SStringFromStringList(SL1,','),'.']);
	SHint(['Error : Class which can open' + Iff(Length(SL1) > 1, ' all of') + ' this Extension' + Iff(Length(SL1) > 1, 's') + ' is missing!']);
	{$IFDEF MSWINDOWS}
	if SIsConsole() then
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
	if SIsConsole() and SSystemKeyPressed(17){CTRL} and FileOpenerConsoleMenuEnabled then
		SOpenFilesWithMenu(VFiles)
	else
	{$ENDIF}
		FindFileOpenerAndOpenFiles();
end;

procedure SRegistryFileOpener(const VClass : TSFileOpenerClass);
begin
if SFileOpeners = nil then
	SetLength(SFileOpeners, 1)
else
	SetLength(SFileOpeners, Length(SFileOpeners) + 1);
SFileOpeners[High(SFileOpeners)] := VClass;
end;

class function TSFileOpener.ExtensionsSupported(const VExtensions : TSStringList) : TSBool;
begin
Result := False;
end;

class function TSFileOpener.GetDrawableClass() : TSFileOpenerDrawableClass;
begin
Result := nil;
end;

procedure TSFileOpenerDrawable.SetOption(const VName : TSString; const VValue : TSPointer);
begin
if VName = 'FILES TO OPEN' then
	FFiles := TSStringList(VValue)
else
	inherited;
end;

destructor TSFileOpenerDrawable.Destroy();
begin
SetLength(FFiles, 0);
inherited;
end;

constructor TSFileOpenerDrawable.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FFiles := nil;
end;

class function TSFileOpenerDrawable.ClassName() : TSString;
begin
Result := 'TSFileOpenerDrawable';
end;

class function TSFileOpener.ClassName() : TSString;
begin
Result := 'TSFileOpener';
end;

class procedure TSFileOpener.Execute(const VFiles : TSStringList);
begin
SCompatibleRunPaintable(GetDrawableClass(), SContextOptionImport('FILES TO OPEN', TSPointer(VFiles)) + SContextOptionMax());
end;

class function TSFileOpener.GetExtensions() : TSStringList;
begin
Result := nil;
end;

finalization
begin
SetLength(SFileOpeners, 0);
end;

end.
