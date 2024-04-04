{$INCLUDE Smooth.inc}

unit SmoothConsolePaintableTools;

interface

uses
	 SmoothBase
	,SmoothConsoleHandler
	,SmoothContextClasses
	,SmoothContext
	,SmoothContextUtils
	;

type
	TSAllApplicationsDrawable = class(TSPaintableObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		procedure LoadRenderResources(); override;
		procedure DeleteRenderResources(); override;
		class function ClassName() : TSString; override;
		end;

procedure SConsoleShowAllApplications(const VParams : TSConsoleHandlerParams = nil);overload;
procedure SConsoleShowAllApplications();overload;
procedure SConsoleShowAllApplications(const VParams : TSConsoleHandlerParams = nil;  ContextSettings : TSContextSettings = nil);overload;
procedure SConsoleRunPaintable(const VPaintabeClass : TSPaintableObjectClass; const VParams : TSConsoleHandlerParams = nil; ContextSettings : TSContextSettings = nil);

implementation

uses
	StrMan
	
	// Aditional Engine includes
	,SmoothExtensionManager
	,SmoothLists
	,SmoothRender
	,SmoothAudioRender
	,SmoothPaintableObjectContainer
	,SmoothVersion
	,SmoothStringUtils
	,SmoothBaseUtils
	,SmoothLog
	,SmoothContextHandler
	
	// System-dependent includes
	{$IFDEF MSWINDOWS}
		,SmoothRenderDirectX12
		,SmoothRenderDirectX11
		//,SmoothRenderDirectX10
		,SmoothRenderDirectX9
		,SmoothRenderDirectX8
		{$ENDIF}
	,SmoothRenderOpenGL
	{$IFDEF WITH_GLUT}
		,SmoothContextGLUT
		{$ENDIF}
	{$IFNDEF MOBILE}
		,SmoothAudioRenderOpenAL
		{$ENDIF}
	
	// Aditiolnal includes
	,SmoothFullscreenLoading
	,SmoothModelRedactor
	,SmoothClientWeb
	//,SmoothTron ("deprecated")
	;

constructor TSAllApplicationsDrawable.Create();
begin
inherited;

with TSPaintableObjectContainer.Create(Context) do
	begin
	Add(TSLoading);
	
	Add(SGetRegisteredDrawClasses());
	//Add(TSMeshViever);
	//Add(TSExampleShader);
	//Add(TSModelRedactor);
	//Add(TSGameTron);
	//Add(TSClientWeb);

	Initialize();
	end;
end;

procedure SConsoleRunPaintable(const VPaintabeClass : TSPaintableObjectClass; const VParams : TSConsoleHandlerParams = nil; ContextSettings : TSContextSettings = nil);
var
	RenderClass   : TSRenderClass = nil;
	ContextClass  : TSContextClass = nil;
	AudioRenderClass : TSAudioRenderClass = nil;
	AudioDisabled : TSBool = False;

function ProccessFullscreen(const Comand : TSString):TSBool;
begin
Result := True;
if (SCFullscreenWindow in ContextSettings) then
	begin
	if SContextOptionFullscreen(False) in ContextSettings then
		begin
		ContextSettings -= SContextOptionFullscreen(False);
		ContextSettings += SContextOptionFullscreen(True);
		end
	else
		begin
		if SContextOptionFullscreen(True) in ContextSettings then
			begin
			ContextSettings -= SContextOptionFullscreen(True);
			end
		else
			Result := False;
		end;
	end
else
	ContextSettings += SContextOptionFullscreen(True);
end;

function IsGLUTSupported() : TSBool;
begin
{$IFDEF WITH_GLUT}
Result := TSContextGLUT.Supported();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX8Supported() : TSBool;
begin
{$IFDEF MSWINDOWS}
Result := TSRenderDirectX8.Supported();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX9Supported() : TSBool;
begin
{$IFDEF MSWINDOWS}
Result := TSRenderDirectX9.Supported();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX11Supported() : TSBool;
begin
{$IFDEF MSWINDOWS}
Result := TSRenderDirectX11.Supported();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX12Supported() : TSBool;
begin
{$IFDEF MSWINDOWS}
Result := TSRenderDirectX12.Supported();
{$ELSE}
Result := False;
{$ENDIF}
end;

function ProccessGLUT(const Comand : TSString):TSBool;
begin
Result := True;
if not IsGLUTSupported() then
	begin
	WriteLn('GLUT can''t be used in your system!');
	Result := False;
	end;
{$IFDEF WITH_GLUT}
if Result then
	ContextClass := TSContextGLUT;
{$ENDIF}
end;

function ProccessDirectX12(const Comand : TSString):TSBool;
begin
Result := True;
if not IsD3DX12Supported() then
	begin
	WriteLn('Direct3D X 12 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSRenderDirectX12;
{$ENDIF}
end;

function ProccessDirectX11(const Comand : TSString):TSBool;
begin
Result := True;
if not IsD3DX11Supported() then
	begin
	WriteLn('Direct3D X 11 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSRenderDirectX11;
{$ENDIF}
end;

function ProccessDirectX9(const Comand : TSString):TSBool;
begin
Result := True;
if not IsD3DX9Supported() then
	begin
	WriteLn('Direct3D X 9 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSRenderDirectX9;
{$ENDIF}
end;

function ProccessDirectX8(const Comand : TSString):TSBool;
begin
Result := True;
if not IsD3DX8Supported() then
	begin
	WriteLn('Direct3D X 8 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSRenderDirectX8;
{$ENDIF}
end;

function ProccessDirectX(const Comand : TSString):TSBool;
begin
Result := False;
if IsD3DX12Supported and (not Result) then
	Result := ProccessDirectX12('');
if IsD3DX11Supported and (not Result) then
	Result := ProccessDirectX11('');
if IsD3DX9Supported and (not Result) then
	Result := ProccessDirectX9('');
if IsD3DX8Supported and (not Result) then
	Result := ProccessDirectX8('');
end;

function ProccessOpenGL(const Comand : TSString):TSBool;
begin
Result := True;
if not TSRenderOpenGL.Supported() then
	begin
	WriteLn('OpenGL can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSRenderOpenGL;
{$ENDIF}
end;

function StringIsNumber(const S : TSString) : TSBool;
var
	i : TSLongWord;
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

function ProccessWidth(const Comand : TSString):TSBool;
var
	MustBeNumber : TSString;
begin
MustBeNumber := StringTrimLeft(Comand,'WIDTHwidth');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('WIDTH' in ContextSettings) then
		begin
		ContextSettings -= 'WIDTH';
		end;
	ContextSettings += SContextOptionWidth(SVal(MustBeNumber));
	end;
end;

function ProccessHeight(const Comand : TSString):TSBool;
var
	MustBeNumber : TSString;
begin
MustBeNumber := StringTrimLeft(Comand,'HEIGHTheight');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('HEIGHT' in ContextSettings) then
		begin
		ContextSettings -= 'HEIGHT';
		end;
	ContextSettings += SContextOptionHeight(SVal(MustBeNumber));
	end;
end;

function ProccessLeft(const Comand : TSString):TSBool;
var
	MustBeNumber : TSString;
begin
MustBeNumber := StringTrimLeft(Comand,'XLEFTxleft');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('LEFT' in ContextSettings) then
		begin
		ContextSettings -= 'LEFT';
		end;
	ContextSettings += SContextOptionLeft(SVal(MustBeNumber));
	end;
end;

function ProccessTop(const Comand : TSString):TSBool;
var
	MustBeNumber : TSString;
begin
MustBeNumber := StringTrimLeft(Comand,'YTOPytop');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('TOP' in ContextSettings) then
		begin
		ContextSettings -= 'TOP';
		end;
	ContextSettings += SContextOptionTop(SVal(MustBeNumber));
	end;
end;

function ProccessWH(const Comand : TSString):TSBool;
var
	C, X : TSChar;
	CountXX : TSLongWord = 0;
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
	ContextSettings += SContextOptionWidth (SVal(StringWordGet(Comand,X,1)));
	ContextSettings += SContextOptionHeight(SVal(StringWordGet(Comand,X,2)));
	end;
end;

const TitleQuote : TSChar = {$IFDEF MSWINDOWS}''''{$ELSE}'-'{$ENDIF};

function ProccessTitle(const Comand : TSString):TSBool;
begin
Result := True;
if ('TITLE' in ContextSettings) then
	begin
	ContextSettings -= 'TITLE';
	end;
ContextSettings += SContextOptionTitle(StringWordGet(Comand,TitleQuote,2));
end;

function ProccessMax(const Comand : TSString):TSBool;
begin
Result := True;
ContextSettings -= SCMaximizedWindow;
ContextSettings -= SCMinimizedWindow;
ContextSettings += SContextOptionMax();
end;

function ProccessMin(const Comand : TSString):TSBool;
begin
Result := True;
ContextSettings -= SCMaximizedWindow;
ContextSettings -= SCMinimizedWindow;
ContextSettings += SContextOptionMin();
end;

function ImposibleParam(const B : TSBool):TSString;
begin
Result := Iff(not B, ', but now it is impossible!')
end;

function HelpFuncGLUT() : TSString;
begin
Result := 'For use GLUT' + ImposibleParam(IsGLUTSupported());
end;

function HelpFuncDX8() : TSString;
begin
Result := 'For use Direct3D X 8' +  ImposibleParam(IsD3DX8Supported());
end;

function HelpFuncDX9() : TSString;
begin
Result := 'For use Direct3D X 9' +  ImposibleParam(IsD3DX9Supported());
end;

function HelpFuncDX12() : TSString;
begin
Result := 'For use Direct3D X 12' + ImposibleParam(IsD3DX12Supported());
end;

function HelpFuncDX11() : TSString;
begin
Result := 'For use Direct3D X 11' + ImposibleParam(IsD3DX11Supported());
end;

function HelpFuncDX() : TSString;
begin
Result := 'For use Direct3D X, with most highest version' + ImposibleParam(IsD3DX12Supported() or IsD3DX9Supported() or IsD3DX8Supported());
end;

function HelpFuncOGL() : TSString;
begin
Result := 'For use OpenGL' + ImposibleParam(TSRenderOpenGL.Supported());
end;

function IsOpenALSupported() : TSBoolean;
begin
Result :=
	{$IFDEF MOBILE}
	False
	{$ELSE}
	TSAudioRenderOpenAL.Supported()
	{$ENDIF}
	;
end;

function HelpFuncOAL() : TSString;
begin
Result := 'For use OpenAL' + ImposibleParam(IsOpenALSupported());
end;

function ProccessWA(const Comand : TSString):TSBool;
begin
Result := True;
AudioRenderClass := nil;
AudioDisabled := True;
end;

function ProccessOpenAL(const Comand : TSString):TSBool;
begin
Result := True;
if not IsOpenALSupported() then
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
	AudioRenderClass := TSAudioRenderOpenAL;
{$ENDIF}
end;

var
	Success : TSBool = True;
begin
SPrintEngineVersion();
if (VParams <> nil) and (Length(VParams) > 0) then
	with TSConsoleHandler.Create(VParams) do
		begin
		Category('Context settings');
		AddComand(@ProccessGLUT,      ['GLUT'],               @HelpFuncGLUT);
		Category('Render settings');
		AddComand(@ProccessDirectX,   ['D3D','D3DX'],         @HelpFuncDX);
		AddComand(@ProccessDirectX12, ['D3D12','D3DX12'],     @HelpFuncDX12);
		AddComand(@ProccessDirectX11, ['D3D11','D3DX11'],     @HelpFuncDX11);
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
	ContextClass := TSCompatibleContext;
if RenderClass = nil then
	RenderClass  := TSCompatibleRender;
if (AudioRenderClass = nil) and (not AudioDisabled) then
	AudioRenderClass := TSCompatibleAudioRender;
if (AudioRenderClass <> nil) then
	ContextSettings += SContextOptionAudioRender(AudioRenderClass);
if Success then
	if (ContextClass <> nil) and (RenderClass <> nil) then
		SRunPaintable(
			VPaintabeClass,
			ContextClass,
			RenderClass,
			ContextSettings)
	else
		begin
		if ContextClass = nil then
			SHint('Error : Not suppored contexts found!');
		if RenderClass = nil then
			SHint('Error : Not suppored renders found!');
		SHint('Fatal : Failed to run graphical user interface!');
		end;
end;

class function TSAllApplicationsDrawable.ClassName() : TSString;
begin
Result := 'Graphical applications';
end;

procedure TSAllApplicationsDrawable.LoadRenderResources();
begin
end;

procedure TSAllApplicationsDrawable.DeleteRenderResources();
begin
end;

destructor TSAllApplicationsDrawable.Destroy();
begin
inherited;
end;

procedure TSAllApplicationsDrawable.Paint();
begin
end;

procedure SConsoleShowAllApplications(const VParams : TSConsoleHandlerParams = nil;  ContextSettings : TSContextSettings = nil);overload;
begin
SConsoleRunPaintable(TSAllApplicationsDrawable, VParams, ContextSettings);
end;

procedure SConsoleShowAllApplications(const VParams : TSConsoleHandlerParams = nil);overload;
begin
SConsoleRunPaintable(TSAllApplicationsDrawable, VParams);
end;

procedure SConsoleShowAllApplications();overload;
begin
SConsoleRunPaintable(TSAllApplicationsDrawable);
end;

end.
