{$INCLUDE Smooth.inc}

unit SmoothContextInterface;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothBaseContextInterface
	,SmoothBitMap
	,SmoothCursor
	,SmoothCommonStructs
	,SmoothAudioRenderInterface
	,SmoothRenderInterface
	,SmoothContextUtils
	,SmoothScreenCustomComponent
	;
type
	ISContextHandler = interface(ISBaseContext)
		['{a886fa59-2fe5-4ac7-a2ae-829df4b8a911}']
		function KeysPressed(const  Index : TSInteger ) : TSBoolean;overload;
		function KeysPressed(const  Index : TSChar ) : TSBoolean;overload;
		function KeyPressed():TSBoolean;
		function KeyPressedType():TSCursorButtonType;
		function KeyPressedChar():TSChar;
		function KeyPressedByte():TSLongWord;
		function CursorKeyPressed():TSCursorButton;
		function CursorKeyPressedType():TSCursorButtonType;
		function CursorKeysPressed(const Index : TSCursorButton):TSBoolean;
		function CursorWheel():TSCursorWheel;
		function CursorPosition(const Index : TSCursorPosition = SNowCursorPosition ) : TSPoint2int32;
		procedure ClearKeys();
		procedure SetKey(ButtonType:TSCursorButtonType;Key:TSLongInt);
		procedure SetCursorKey(ButtonType : TSCursorButtonType; Key : TSCursorButton);
		procedure SetCursorWheel(const VCursorWheel : TSCursorWheel);
		
		property Left : TSAreaInt read GetLeft write SetLeft;
		property Top : TSAreaInt read GetTop write SetTop;
		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		property Title : TSString read GetTitle write SetTitle;
		property Device : TSPointer read GetDevice;
		property Window : TSPointer read GetWindow;
		property ClientWidth : TSAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSAreaInt read GetClientHeight write SetClientHeight;
		property ElapsedTime : TSTimerInt read GetElapsedTime;
		end;

	ISCustomContext = interface(ISContextHandler)
		['{b55c5aea-0250-4e89-8889-8f5eae820eb0}']
		procedure Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);
		procedure Run();
		procedure Messages();
		procedure SwapBuffers();
		procedure Close();
		procedure ShowCursor(const VShowing : TSBoolean);
		procedure ReinitializeRender();
		function GetRender() : ISRender;
		
		function  GetFullscreen() : TSBoolean;
		procedure InitFullscreen(const VFullscreen : TSBoolean);

		procedure SetActive(const VActive : TSBoolean);
		function  GetActive():TSBoolean;
		procedure SetVisible(const _Visible : TSBoolean);
		function  GetVisible() : TSBoolean;
		procedure SetForeground();
		
		procedure SetCursorCentered(const VCentered : TSBoolean);
		function GetCursorCentered() : TSBoolean;

		function GetCursorPosition():TSPoint2int32;
		procedure SetCursorPosition(const VPosition : TSPoint2int32);
		function GetWindowArea():TSPoint2int32;
		function GetScreenArea():TSPoint2int32;
		function GetClientArea():TSPoint2int32;
		function ShiftClientArea() : TSPoint2int32;
		function GetClientAreaShift() : TSPoint2int32;

		function FileOpenDialog(const VTittle: TSString; const VFilter : TSString) : TSString;
		function FileSaveDialog(const VTittle: TSString; const VFilter : TSString;const Extension : TSString) : TSString;

		function GetCursor():TSCursor;
		procedure SetCursor(const VCursor : TSCursor);
		function GetIcon():TSBitMap;
		procedure SetIcon(const VIcon : TSBitMap);

		property Fullscreen : TSBoolean read GetFullscreen write InitFullscreen;
		property Active : TSBoolean read GetActive write SetActive;
		property Cursor : TSCursor read GetCursor write SetCursor;
		property Icon : TSBitMap read GetIcon write SetIcon;
		property Left : TSAreaInt read GetLeft write SetLeft;
		property Top : TSAreaInt read GetTop write SetTop;
		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		property Title : TSString read GetTitle write SetTitle;
		property Device : TSPointer read GetDevice;
		property Window : TSPointer read GetWindow;
		property ClientWidth : TSAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSAreaInt read GetClientHeight write SetClientHeight;
		property Render : ISRender read GetRender;
		property ElapsedTime : TSTimerInt read GetElapsedTime;
		property CursorCentered : TSBoolean read GetCursorCentered write SetCursorCentered;
		end;

	PISContext = ^ ISContext;
	ISContext = interface(ISCustomContext)
		['{b4b36fe5-b99e-4cb5-9745-ec1218816a26}']
		function  GetScreen() : TSScreenCustomComponent;
		procedure SetInterfaceLink(const VLink : PISContext);
		function  GetInterfaceLink() : PISContext;
		procedure SetRenderClass(const NewRender : TSNamedClass);
		procedure SetNewContext(const NewContext : TSNamedClass);
		function  GetDefaultWindowColor():TSColor3f;
		procedure BeginIncessantlyPainting();
		procedure EndIncessantlyPainting();
		procedure Minimize();
		procedure Maximize();
		function GetAudioRender() : ISAudioRender;

		property AudioRender : ISAudioRender read GetAudioRender;
		property Screen : TSScreenCustomComponent read GetScreen;
		property NewContext : TSNamedClass write SetNewContext;
		property RenderClass : TSNamedClass write SetRenderClass;
		property InterfaceLink : PISContext read GetInterfaceLink write SetInterfaceLink;
		property Fullscreen : TSBoolean read GetFullscreen write InitFullscreen;
		property Active : TSBoolean read GetActive write SetActive;
		property Cursor : TSCursor read GetCursor write SetCursor;
		property Icon : TSBitMap read GetIcon write SetIcon;
		property Left : TSAreaInt read GetLeft write SetLeft;
		property Top : TSAreaInt read GetTop write SetTop;
		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		property Title : TSString read GetTitle write SetTitle;
		property Render : ISRender read GetRender;
		property ElapsedTime : TSTimerInt read GetElapsedTime;
		property CursorCentered : TSBoolean read GetCursorCentered write SetCursorCentered;
		property Device : TSPointer read GetDevice;
		property Window : TSPointer read GetWindow;
		property ClientWidth : TSAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSAreaInt read GetClientHeight write SetClientHeight;
		end;

	ISContextObject = interface(ISInterface)
		['{ee8df1e3-abe8-4378-8d11-7b5903fea502}']
		procedure SetContext(const VContext : ISContext);
		function GetContext() : ISContext;
		function ContextAssigned() : TSBoolean;

		property Context : ISContext read GetContext write SetContext;
		end;

implementation

end.
