{$INCLUDE Smooth.inc}

unit SmoothAudioFileOpener;

interface
uses
	 Classes
	
	,SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothFileOpener
	,SmoothContext
	//,SmoothLoading
	,SmoothFont
	,SmoothContextClasses
	,SmoothCommon
	;

type
	TSAudioFileOpener = class(TSFileOpener)
			public
		class function ClassName() : TSString; override;
		class function GetExtensions() : TSStringList; override;
		class procedure Execute(const VFiles : TSStringList);override;
		class function ExtensionsSupported(const VExtensions : TSStringList) : TSBool; override;
		end;

implementation

uses
	 SysUtils
	,Crt
	,Dos
	
	,SmoothAudioRender
	,SmoothAudioDecoder
	,SmoothDllManager
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	;

procedure ConsolePlayFile(const FileName : TSString);
var
	AudioRender : TSAudioRender = nil;
	BufferedSource : TSAudioBufferedSource = nil;
	FileExtension : TSString = '';

var
	ConsAll, ConsWr : TSUInt32;
	ConsSize : TSUInt64;
	i : TSUInt32;

procedure BeginConsole();
var
	i : TSUInt32;
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
	ConsPos : TSUInt64;
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
SHint('Playing "' + FileName + '".');
FileExtension := SFileExtension(FileName);
if TSCompatibleAudioRender = nil then
	begin
	SHint('Error! No audio renders suppored!');
	exit;
	end;
AudioRender := TSCompatibleAudioRender.Create();
AudioRender.Initialize();
BufferedSource := AudioRender.CreateBufferedSource();
if BufferedSource = nil then
	begin
	SHint('Error! Could not create buffered source!');
	AudioRender.Destroy();
	exit;
	end;
if TSCompatibleAudioDecoder(FileExtension) = nil then
	begin
	SHint('Error! No audio decoders suppored for ''' + FileExtension + '''!');
	BufferedSource.Destroy();
	AudioRender.Destroy();
	exit;
	end;
BufferedSource.Attach(TSCompatibleAudioDecoder(FileExtension).Create().SetInput(FileName));
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

class function TSAudioFileOpener.ExtensionsSupported(const VExtensions : TSStringList) : TSBool;
var
	S : TSString;
begin
Result := True;
for S in VExtensions do
	if TSCompatibleAudioDecoder(S) = nil then
		begin
		Result := False;
		break;
		end
end;

class procedure TSAudioFileOpener.Execute(const VFiles : TSStringList);
var
	i : TSUInt32;
begin
if Length(VFiles)>1 then
	begin
	SHint('Hint: Opening ' + SStr(Length(VFiles)) + ' files:');
	for i := 0 to High(VFiles) do
		SHint('  ' + VFiles[i]);
	SHint('Warning: Supported playing only one of files.');
	end;
ConsolePlayFile(VFiles[0]);
end;

class function TSAudioFileOpener.ClassName() : TSString;
begin
Result := 'TSAudioFileOpener';
end;

class function TSAudioFileOpener.GetExtensions() : TSStringList;
begin
Result := nil;
if TSCompatibleAudioRender <> nil then
	Result := TSCompatibleAudioFormats;
end;

initialization
begin
SRegistryFileOpener(TSAudioFileOpener);
end;

end.
