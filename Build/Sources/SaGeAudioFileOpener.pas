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
	,SaGeDllManager
	;

procedure PlayFiles(const Files : TSGStringList);
var
	AudioRender : TSGAudioRender = nil;
	AudioRenderFileSource : TSGAudioRenderFileSource = nil;

procedure UpdateScreen();
begin

end;

begin
AudioRender := TSGCompatibleAudioRender.Create();
AudioRender.Initialize();
AudioRenderFileSource := AudioRender.CreateFileSource(Files[0]);
AudioRenderFileSource.Play();
while not AudioRenderFileSource.Ended do
	begin
	UpdateScreen();
	Sleep(10);
	end;
AudioRenderFileSource.Destroy();
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
