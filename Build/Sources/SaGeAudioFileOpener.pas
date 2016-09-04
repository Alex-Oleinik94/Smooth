{$INCLUDE SaGe.inc}

unit SaGeAudioFileOpener;

interface
uses
	  Classes
	, SaGeBase
	, SaGeBased
	, SaGeClasses
	, SaGeFileOpener
	, SaGeContext
	, SaGeLoading
	, SaGeUtils
	, SaGeCommonClasses
	, SaGeCommon
	;

type
	TSGAudioFileOpener = class(TSGFileOpener)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; override;
		class procedure Execute(const VFiles : TSGStringList);override;
		end;

implementation

uses
	SysUtils
	,SaGeAudioRender
	,SaGeAudioDecoder
	,SaGeDllManager
	;

procedure PlayFiles(const Files : TSGStringList);
var
	AudioRender : TSGAudioRender = nil;
	BufferedSource : TSGAudioBufferedSource = nil;
	FileExpansion : TSGString = '';
begin
FileExpansion := SGGetFileExpansion(Files[0]);
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
BufferedSource.Attach(TSGCompatibleAudioDecoder(FileExpansion).Create().SetInput(Files[0]));
BufferedSource.Play();
while BufferedSource.Playing do
	begin
	Sleep(100);
	end;
BufferedSource.Destroy();
AudioRender.Destroy();
end;

class procedure TSGAudioFileOpener.Execute(const VFiles : TSGStringList);
begin
PlayFiles(VFiles);
end;

class function TSGAudioFileOpener.ClassName() : TSGString;
begin
Result := 'TSGAudioFileOpener';
end;

class function TSGAudioFileOpener.GetExpansions() : TSGStringList;
begin
Result := nil;
if TSGCompatibleAudioRender <> nil then
	Result := TSGCompatibleAudioRender.SupporedAudioFormats();
end;

initialization
begin
SGRegistryFileOpener(TSGAudioFileOpener);
end;

end.
