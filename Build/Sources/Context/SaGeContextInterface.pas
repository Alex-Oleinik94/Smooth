{$INCLUDE SaGe.inc}

unit SaGeContextInterface;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeBaseContextInterface
	,SaGeBitMap
	,SaGeCursor
	,SaGeCommonStructs
	,SaGeAudioRenderInterface
	,SaGeRenderInterface
	,SaGeContextUtils
	,SaGeScreenCustomComponent
	;
type
	ISGContextHandler = interface(ISGBaseContext)
		['{a886fa59-2fe5-4ac7-a2ae-829df4b8a911}']
		function KeysPressed(const  Index : TSGInteger ) : TSGBoolean;overload;
		function KeysPressed(const  Index : TSGChar ) : TSGBoolean;overload;
		function KeyPressed():TSGBoolean;
		function KeyPressedType():TSGCursorButtonType;
		function KeyPressedChar():TSGChar;
		function KeyPressedByte():TSGLongWord;
		function CursorKeyPressed():TSGCursorButton;
		function CursorKeyPressedType():TSGCursorButtonType;
		function CursorKeysPressed(const Index : TSGCursorButton):TSGBoolean;
		function CursorWheel():TSGCursorWheel;
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2int32;
		procedure ClearKeys();
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);
		procedure SetCursorKey(ButtonType : TSGCursorButtonType; Key : TSGCursorButton);
		procedure SetCursorWheel(const VCursorWheel : TSGCursorWheel);
		
		property Left : TSGAreaInt read GetLeft write SetLeft;
		property Top : TSGAreaInt read GetTop write SetTop;
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		property ClientWidth : TSGAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGAreaInt read GetClientHeight write SetClientHeight;
		property ElapsedTime : TSGTimerInt read GetElapsedTime;
		end;

	ISGCustomContext = interface(ISGContextHandler)
		['{b55c5aea-0250-4e89-8889-8f5eae820eb0}']
		procedure Initialize(const _WindowPlacement : TSGContextWindowPlacement = SGPlacementNormal);
		procedure Run();
		procedure Messages();
		procedure SwapBuffers();
		procedure Close();
		procedure ShowCursor(const VShowing : TSGBoolean);
		procedure ReinitializeRender();
		function GetRender() : ISGRender;
		
		function  GetFullscreen() : TSGBoolean;
		procedure InitFullscreen(const VFullscreen : TSGBoolean);

		procedure SetActive(const VActive : TSGBoolean);
		function  GetActive():TSGBoolean;
		procedure SetVisible(const _Visible : TSGBoolean);
		function  GetVisible() : TSGBoolean;
		procedure SetForeground();
		
		procedure SetCursorCentered(const VCentered : TSGBoolean);
		function GetCursorCentered() : TSGBoolean;

		function GetCursorPosition():TSGPoint2int32;
		procedure SetCursorPosition(const VPosition : TSGPoint2int32);
		function GetWindowArea():TSGPoint2int32;
		function GetScreenArea():TSGPoint2int32;
		function GetClientArea():TSGPoint2int32;
		function ShiftClientArea() : TSGPoint2int32;
		function GetClientAreaShift() : TSGPoint2int32;

		function FileOpenDialog(const VTittle: TSGString; const VFilter : TSGString) : TSGString;
		function FileSaveDialog(const VTittle: TSGString; const VFilter : TSGString;const Extension : TSGString) : TSGString;

		function GetCursor():TSGCursor;
		procedure SetCursor(const VCursor : TSGCursor);
		function GetIcon():TSGBitMap;
		procedure SetIcon(const VIcon : TSGBitMap);

		property Fullscreen : TSGBoolean read GetFullscreen write InitFullscreen;
		property Active : TSGBoolean read GetActive write SetActive;
		property Cursor : TSGCursor read GetCursor write SetCursor;
		property Icon : TSGBitMap read GetIcon write SetIcon;
		property Left : TSGAreaInt read GetLeft write SetLeft;
		property Top : TSGAreaInt read GetTop write SetTop;
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		property ClientWidth : TSGAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGAreaInt read GetClientHeight write SetClientHeight;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGTimerInt read GetElapsedTime;
		property CursorCentered : TSGBoolean read GetCursorCentered write SetCursorCentered;
		end;

	PISGContext = ^ ISGContext;
	ISGContext = interface(ISGCustomContext)
		['{b4b36fe5-b99e-4cb5-9745-ec1218816a26}']
		function  GetScreen() : TSGScreenCustomComponent;
		procedure SetInterfaceLink(const VLink : PISGContext);
		function  GetInterfaceLink() : PISGContext;
		procedure SetRenderClass(const NewRender : TSGNamedClass);
		procedure SetNewContext(const NewContext : TSGNamedClass);
		function  GetDefaultWindowColor():TSGColor3f;
		procedure BeginIncessantlyPainting();
		procedure EndIncessantlyPainting();
		procedure Minimize();
		procedure Maximize();
		function GetAudioRender() : ISGAudioRender;

		property AudioRender : ISGAudioRender read GetAudioRender;
		property Screen : TSGScreenCustomComponent read GetScreen;
		property NewContext : TSGNamedClass write SetNewContext;
		property RenderClass : TSGNamedClass write SetRenderClass;
		property InterfaceLink : PISGContext read GetInterfaceLink write SetInterfaceLink;
		property Fullscreen : TSGBoolean read GetFullscreen write InitFullscreen;
		property Active : TSGBoolean read GetActive write SetActive;
		property Cursor : TSGCursor read GetCursor write SetCursor;
		property Icon : TSGBitMap read GetIcon write SetIcon;
		property Left : TSGAreaInt read GetLeft write SetLeft;
		property Top : TSGAreaInt read GetTop write SetTop;
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGTimerInt read GetElapsedTime;
		property CursorCentered : TSGBoolean read GetCursorCentered write SetCursorCentered;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		property ClientWidth : TSGAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGAreaInt read GetClientHeight write SetClientHeight;
		end;

	ISGContextObject = interface(ISGInterface)
		['{ee8df1e3-abe8-4378-8d11-7b5903fea502}']
		procedure SetContext(const VContext : ISGContext);
		function GetContext() : ISGContext;
		function ContextAssigned() : TSGBoolean;

		property Context : ISGContext read GetContext write SetContext;
		end;

implementation

end.
