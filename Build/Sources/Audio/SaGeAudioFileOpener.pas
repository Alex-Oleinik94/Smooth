{$INCLUDE SaGe.inc}

unit SaGeAudioFileOpener;

interface
uses
	 Classes
	
	,SaGeBase
	,SaGeClasses
	,SaGeFileOpener
	,SaGeContext
	,SaGeLoading
	,SaGeUtils
	,SaGeCommonClasses
	,SaGeCommon
	;

type
	TSGAudioFileOpener = class(TSGFileOpener)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; override;
		class procedure Execute(const VFiles : TSGStringList);override;
		class function ExpansionsSuppored(const VExpansions : TSGStringList) : TSGBool; override;
		end;

implementation

uses
	 SysUtils
	,Crt
	,Dos
	
	,SaGeAudioRender
	,SaGeAudioDecoder
	,SaGeDllManager
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	;

procedure ConsolePlayFile(const FileName : TSGString);
var
	AudioRender : TSGAudioRender = nil;
	BufferedSource : TSGAudioBufferedSource = nil;
	FileExpansion : TSGString = '';

var
	ConsAll, ConsWr : TSGUInt32;
	ConsSize : TSGUInt64;
	i : TSGUInt32;

procedure BeginConsole();
var
	i : TSGUInt32;
begin
ConsAll := 50;
ConsWr := 0;
ConsSize := BufferedSource.Decoder.Size;
for i := 1 to ConsAll do
	Write('#');
WriteLn();
end;

procedure UpdateConsole();
var
	ConsPos : TSGUInt64;
begin
ConsPos := BufferedSource.Decoder.Position;
while Trunc(ConsPos / ConsSize * ConsAll) > ConsWr do
	begin
	Write('*');
	ConsWr += 1;
	ConsPos := BufferedSource.Decoder.Position;
	end;
end;

begin
SGHint('Playing "' + FileName + '".');
FileExpansion := SGFileExpansion(FileName);
if TSGCompatibleAudioRender = nil then
	begin
	SGHint('Error! No audio renders suppored!');
	exit;
	end;
AudioRender := TSGCompatibleAudioRender.Create();
AudioRender.Initialize();
BufferedSource := AudioRender.CreateBufferedSource();
if BufferedSource = nil then
	begin
	SGHint('Error! Could not create buffered source!');
	AudioRender.Destroy();
	exit;
	end;
if TSGCompatibleAudioDecoder(FileExpansion) = nil then
	begin
	SGHint('Error! No audio decoders suppored for ''' + FileExpansion + '''!');
	BufferedSource.Destroy();
	AudioRender.Destroy();
	exit;
	end;
BufferedSource.Attach(TSGCompatibleAudioDecoder(FileExpansion).Create().SetInput(FileName));
BufferedSource.Play();
BufferedSource.Relative := True;

BeginConsole();
while BufferedSource.Playing do
	begin
	UpdateConsole();
	if KeyPressed and (ReadKey = #27) then
		break;
	Sleep(20);
	end;

BufferedSource.Stop();
BufferedSource.Destroy();
AudioRender.Destroy();
end;

class function TSGAudioFileOpener.ExpansionsSuppored(const VExpansions : TSGStringList) : TSGBool;
var
	S : TSGString;
begin
Result := True;
for S in VExpansions do
	if TSGCompatibleAudioDecoder(S) = nil then
		begin
		Result := False;
		break;
		end
end;

class procedure TSGAudioFileOpener.Execute(const VFiles : TSGStringList);
var
	i : TSGUInt32;
begin
if Length(VFiles)>1 then
	begin
	SGHint('Hint: Opening ' + SGStr(Length(VFiles)) + ' files:');
	for i := 0 to High(VFiles) do
		SGHint('  ' + VFiles[i]);
	SGHint('Warning: Suppored playing only one of files.');
	end;
ConsolePlayFile(VFiles[0]);
end;

class function TSGAudioFileOpener.ClassName() : TSGString;
begin
Result := 'TSGAudioFileOpener';
end;

class function TSGAudioFileOpener.GetExpansions() : TSGStringList;
begin
Result := nil;
if TSGCompatibleAudioRender <> nil then
	Result := TSGCompatibleAudioFormats;
end;

initialization
begin
SGRegistryFileOpener(TSGAudioFileOpener);
end;

end.
