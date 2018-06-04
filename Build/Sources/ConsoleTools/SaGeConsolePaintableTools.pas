{$INCLUDE SaGe.inc}

unit SaGeConsolePaintableTools;

interface

uses
	 SaGeBase
	,SaGeConsoleCaller
	,SaGeCommonClasses
	,SaGeContext
	;

type
	TSGAllApplicationsDrawable = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		procedure LoadDeviceResources();override;
		procedure DeleteDeviceResources();override;
		class function ClassName() : TSGString;override;
		end;

procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil);overload;
procedure SGConsoleShowAllApplications();overload;
procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil;  ContextSettings : TSGContextSettings = nil);overload;
procedure SGConsoleRunPaintable(const VPaintabeClass : TSGDrawableClass; const VParams : TSGConcoleCallerParams = nil; ContextSettings : TSGContextSettings = nil);

implementation

uses
	StrMan
	
	// Aditional Engine includes
	,SaGePackages
	,SaGeLists
	,SaGeRender
	,SaGeAudioRender
	,SaGeDrawClasses
	,SaGeVersion
	,SaGeStringUtils
	,SaGeBaseUtils
	,SaGeLog
	
	// System-dependent includes
	{$IFDEF MSWINDOWS}
		,SaGeRenderDirectX9
		,SaGeRenderDirectX8
		,SaGeRenderDirectX12
		{$ENDIF}
	,SaGeRenderOpenGL
	{$IFDEF WITH_GLUT}
		,SaGeContextGLUT
		{$ENDIF}
	{$IFNDEF MOBILE}
		,SaGeAudioRenderOpenAL
		{$ENDIF}
	
	// Aditiolnal includes
	,SaGeLoading
	,SaGeModelRedactor
	,SaGeClientWeb
	,SaGeTron
	;

constructor TSGAllApplicationsDrawable.Create(const VContext : ISGContext);
begin
inherited Create(VContext);

with TSGDrawClasses.Create(Context) do
	begin
	Add(TSGLoading);
	
	Add(SGGetRegisteredDrawClasses());
	//Add(TSGMeshViever);
	//Add(TSGExampleShader);
	Add(TSGModelRedactor);
	Add(TSGGameTron);
	//Add(TSGClientWeb);

	Initialize();
	end;
end;

procedure SGConsoleRunPaintable(const VPaintabeClass : TSGDrawableClass; const VParams : TSGConcoleCallerParams = nil; ContextSettings : TSGContextSettings = nil);
var
	RenderClass   : TSGRenderClass = nil;
	ContextClass  : TSGContextClass = nil;
	AudioRenderClass : TSGAudioRenderClass = nil;
	AudioDisabled : TSGBool = False;

function ProccessFullscreen(const Comand : TSGString):TSGBool;
begin
Result := True;
if ('FULLSCREEN' in ContextSettings) then
	begin
	if SGContextOptionFullscreen(False) in ContextSettings then
		begin
		ContextSettings -= SGContextOptionFullscreen(False);
		ContextSettings += SGContextOptionFullscreen(True);
		end
	else
		begin
		if SGContextOptionFullscreen(True) in ContextSettings then
			begin
			ContextSettings -= SGContextOptionFullscreen(True);
			end
		else
			Result := False;
		end;
	end
else
	ContextSettings += SGContextOptionFullscreen(True);
end;

function IsGLUTSuppored() : TSGBool;
begin
{$IFDEF WITH_GLUT}
Result := TSGContextGLUT.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX8Suppored() : TSGBool;
begin
{$IFDEF MSWINDOWS}
Result := TSGRenderDirectX8.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX9Suppored() : TSGBool;
begin
{$IFDEF MSWINDOWS}
Result := TSGRenderDirectX9.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX12Suppored() : TSGBool;
begin
{$IFDEF MSWINDOWS}
Result := TSGRenderDirectX12.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function ProccessGLUT(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsGLUTSuppored() then
	begin
	WriteLn('GLUT can''t be used in your system!');
	Result := False;
	end;
{$IFDEF WITH_GLUT}
if Result then
	ContextClass := TSGContextGLUT;
{$ENDIF}
end;

function ProccessDirectX12(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsD3DX12Suppored() then
	begin
	WriteLn('Direct3D X 12 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderDirectX12;
{$ENDIF}
end;

function ProccessDirectX9(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsD3DX9Suppored() then
	begin
	WriteLn('Direct3D X 9 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderDirectX9;
{$ENDIF}
end;

function ProccessDirectX8(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsD3DX8Suppored() then
	begin
	WriteLn('Direct3D X 8 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderDirectX8;
{$ENDIF}
end;

function ProccessDirectX(const Comand : TSGString):TSGBool;
begin
Result := False;
if IsD3DX12Suppored and (not Result) then
	Result := ProccessDirectX12('');
if IsD3DX9Suppored and (not Result) then
	Result := ProccessDirectX9('');
if IsD3DX8Suppored and (not Result) then
	Result := ProccessDirectX8('');
end;

function ProccessOpenGL(const Comand : TSGString):TSGBool;
begin
Result := True;
if not TSGRenderOpenGL.Suppored() then
	begin
	WriteLn('OpenGL can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderOpenGL;
{$ENDIF}
end;

function StringIsNumber(const S : TSGString) : TSGBool;
var
	i : TSGLongWord;
begin
Result := Length(S) > 0;
for i := 1 to Length(S) do
	begin
	if not (S[i] in '0123456789') then
		begin
		Result := false;
		break;
		end;
	end;
end;

function ProccessWidth(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'WIDTHwidth');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('WIDTH' in ContextSettings) then
		begin
		ContextSettings -= 'WIDTH';
		end;
	ContextSettings += SGContextOptionWidth(SGVal(MustBeNumber));
	end;
end;

function ProccessHeight(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'HEIGHTheight');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('HEIGHT' in ContextSettings) then
		begin
		ContextSettings -= 'HEIGHT';
		end;
	ContextSettings += SGContextOptionHeight(SGVal(MustBeNumber));
	end;
end;

function ProccessLeft(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'XLEFTxleft');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('LEFT' in ContextSettings) then
		begin
		ContextSettings -= 'LEFT';
		end;
	ContextSettings += SGContextOptionLeft(SGVal(MustBeNumber));
	end;
end;

function ProccessTop(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'YTOPytop');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('TOP' in ContextSettings) then
		begin
		ContextSettings -= 'TOP';
		end;
	ContextSettings += SGContextOptionTop(SGVal(MustBeNumber));
	end;
end;

function ProccessWH(const Comand : TSGString):TSGBool;
var
	C, X : TSGChar;
	CountXX : TSGLongWord = 0;
begin
Result := Length(Comand) > 2;
for C in Comand do
	begin
	if not (C in '0123456789Xx') then
		begin
		Result := False;
		break;
		end;
	end;
if Result then
	begin
	CountXX := 0;
	for C in Comand do
		if C in 'xX' then
			begin
			X := C;
			CountXX += 1;
			end;
	Result := CountXX = 1;
	end;
if Result then
	begin
	Result := (Length(StringWordGet(Comand,X,1)) > 0) and (Length(StringWordGet(Comand,X,2))>0);
	end;
if Result then
	begin
	if ('WIDTH' in ContextSettings) then
		begin
		ContextSettings -= 'WIDTH';
		end;
	if ('HEIGHT' in ContextSettings) then
		begin
		ContextSettings -= 'HEIGHT';
		end;
	ContextSettings += SGContextOptionWidth (SGVal(StringWordGet(Comand,X,1)));
	ContextSettings += SGContextOptionHeight(SGVal(StringWordGet(Comand,X,2)));
	end;
end;

const TitleQuote : TSGChar = {$IFDEF MSWINDOWS}''''{$ELSE}'-'{$ENDIF};

function ProccessTitle(const Comand : TSGString):TSGBool;
begin
Result := True;
if ('TITLE' in ContextSettings) then
	begin
	ContextSettings -= 'TITLE';
	end;
ContextSettings += SGContextOptionTitle(StringWordGet(Comand,TitleQuote,2));
end;

function ProccessMax(const Comand : TSGString):TSGBool;
begin
Result := True;
ContextSettings -= 'MAX';
ContextSettings -= 'MIN';
ContextSettings += SGContextOptionMax();
end;

function ProccessMin(const Comand : TSGString):TSGBool;
begin
Result := True;
ContextSettings -= 'MAX';
ContextSettings -= 'MIN';
ContextSettings += SGContextOptionMin();
end;

function ImposibleParam(const B : TSGBool):TSGString;
begin
Result := Iff(not B, ', but now it is impossible!')
end;

function HelpFuncGLUT() : TSGString;
begin
Result := 'For use GLUT' + ImposibleParam(IsGLUTSuppored());
end;

function HelpFuncDX8() : TSGString;
begin
Result := 'For use Direct3D X 8' +  ImposibleParam(IsD3DX8Suppored());
end;

function HelpFuncDX9() : TSGString;
begin
Result := 'For use Direct3D X 9' +  ImposibleParam(IsD3DX9Suppored());
end;

function HelpFuncDX12() : TSGString;
begin
Result := 'For use Direct3D X 12' + ImposibleParam(IsD3DX12Suppored());
end;

function HelpFuncDX() : TSGString;
begin
Result := 'For use Direct3D X, with most highest version' + ImposibleParam(IsD3DX12Suppored() or IsD3DX9Suppored() or IsD3DX8Suppored());
end;

function HelpFuncOGL() : TSGString;
begin
Result := 'For use OpenGL' + ImposibleParam(TSGRenderOpenGL.Suppored());
end;

function IsOpenALSuppored() : TSGBoolean;
begin
Result :=
	{$IFDEF MOBILE}
	False
	{$ELSE}
	TSGAudioRenderOpenAL.Suppored()
	{$ENDIF}
	;
end;

function HelpFuncOAL() : TSGString;
begin
Result := 'For use OpenAL' + ImposibleParam(IsOpenALSuppored());
end;

function ProccessWA(const Comand : TSGString):TSGBool;
begin
Result := True;
AudioRenderClass := nil;
AudioDisabled := True;
end;

function ProccessOpenAL(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsOpenALSuppored() then
	begin
	WriteLn('OpenAL can''t be used in your system!');
	Result := False;
	end;
if AudioDisabled then
	begin
	WriteLn('Audio suppport allready disabled!');
	Result := False;
	end;
{$IFNDEF MOBILE}
if Result then
	AudioRenderClass := TSGAudioRenderOpenAL;
{$ENDIF}
end;

var
	Success : TSGBool = True;
begin
SGPrintEngineVersion();
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSGConsoleCaller.Create(VParams) do
		begin
		Category('Context settings');
		AddComand(@ProccessGLUT,      ['GLUT'],               @HelpFuncGLUT);
		Category('Render settings');
		AddComand(@ProccessDirectX,   ['D3D','D3DX'],         @HelpFuncDX);
		AddComand(@ProccessDirectX12, ['D3D12','D3DX12'],     @HelpFuncDX12);
		AddComand(@ProccessDirectX9,  ['D3D9', 'D3DX9'],      @HelpFuncDX9);
		AddComand(@ProccessDirectX8,  ['D3D8', 'D3DX8'],      @HelpFuncDX8);
		AddComand(@ProccessOpenGL  ,  ['ogl', 'OpenGL'],      @HelpFuncOGL);
		Category('Audio settings');
		AddComand(@ProccessOpenAL  ,  ['oal', 'OpenAL'],      @HelpFuncOAL);
		AddComand(@ProccessWA      ,  ['wa', 'WithoutAudio'], 'Disable audio support');
		Category('Window settings');
		AddComand(@ProccessFullscreen,['F','FULLSCREEN'],     'For set window fullscreen mode');
		AddComand(@ProccessMax,       ['MAX'],                'For maximize window arter initialization');
		AddComand(@ProccessMin,       ['MIN'],                'For minimize window arter initialization');
		AddComand(@ProccessWH,        ['?*X*?'],              'For set window width and height');
		AddComand(@ProccessTitle,     ['t' + TitleQuote + '*' + TitleQuote],   'For set window title');
		AddComand(@ProccessWidth,     ['W*?','WIDTH*?'],      'For set window width');
		AddComand(@ProccessHeight,    ['H*?','HEIGHT*?'],     'For set window height');
		AddComand(@ProccessLeft,      ['L*?','LEFT*?','X*?'], 'For set window x');
		AddComand(@ProccessTop,       ['T*?','TOP*?', 'Y*?'], 'For set window y');
		Success := Execute();
		Destroy();
		end;
if ContextClass = nil then
	ContextClass := TSGCompatibleContext;
if RenderClass = nil then
	RenderClass  := TSGCompatibleRender;
if (AudioRenderClass = nil) and (not AudioDisabled) then
	AudioRenderClass := TSGCompatibleAudioRender;
if (AudioRenderClass <> nil) then
	ContextSettings += SGContextOptionAudioRender(AudioRenderClass);
if Success then
	if (ContextClass <> nil) and (RenderClass <> nil) then
		SGRunPaintable(
			VPaintabeClass,
			ContextClass,
			RenderClass,
			ContextSettings)
	else
		begin
		if ContextClass = nil then
			SGHint('Error : Not suppored contexts found!');
		if RenderClass = nil then
			SGHint('Error : Not suppored renders found!');
		SGHint('Fatal : Failed to run graphical user interface!');
		end;
end;

class function TSGAllApplicationsDrawable.ClassName() : TSGString;
begin
Result := 'TSGAllApplicationsDrawable';
end;

procedure TSGAllApplicationsDrawable.LoadDeviceResources();
begin
end;

procedure TSGAllApplicationsDrawable.DeleteDeviceResources();
begin
end;

destructor TSGAllApplicationsDrawable.Destroy();
begin
inherited;
end;

procedure TSGAllApplicationsDrawable.Paint();
begin
end;

procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil;  ContextSettings : TSGContextSettings = nil);overload;
begin
SGConsoleRunPaintable(TSGAllApplicationsDrawable, VParams, ContextSettings);
end;

procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil);overload;
begin
SGConsoleRunPaintable(TSGAllApplicationsDrawable, VParams);
end;

procedure SGConsoleShowAllApplications();overload;
begin
SGConsoleRunPaintable(TSGAllApplicationsDrawable);
end;

end.
