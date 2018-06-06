{$INCLUDE SaGe.inc}

unit SaGeCommonClasses;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeCommonStructs
	,SaGeRenderInterface
	,SaGeAudioRenderInterface
	,SaGeCursor
	,SaGeBitMap
	,SaGeContextUtils
	;
type
	ISGRenderedTimerArea = interface(ISGNearlyContext)
		['{ed55d22e-7069-46b1-ad39-fb9fcbe63bcb}']
		function GetRender() : ISGRender;

		property Left : TSGAreaInt read GetLeft write SetLeft;
		property Top : TSGAreaInt read GetTop write SetTop;
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGTimerInt read GetElapsedTime;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		property ClientWidth : TSGAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGAreaInt read GetClientHeight write SetClientHeight;
		end;

	ISGContextHandler = interface(ISGRenderedTimerArea)
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
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGTimerInt read GetElapsedTime;
		end;

	ISGCustomContext = interface(ISGContextHandler)
		['{b55c5aea-0250-4e89-8889-8f5eae820eb0}']
		procedure Initialize();
		procedure Run();
		procedure Messages();
		procedure SwapBuffers();
		procedure Close();
		procedure ShowCursor(const VShowing : TSGBoolean);
		procedure ReinitializeRender();

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
		function  GetScreen() : TSGPointer;
		procedure SetSelfLink(const VLink : PISGContext);
		function  GetSelfLink() : PISGContext;
		procedure SetRenderClass(const NewRender : TSGPointer);
		procedure SetNewContext(const NewContext : TSGPointer);
		function  GetDefaultWindowColor():TSGColor3f;
		procedure BeginIncessantlyPainting();
		procedure EndIncessantlyPainting();
		procedure Minimize();
		procedure Maximize();
		function GetAudioRender() : ISGAudioRender;

		property AudioRender : ISGAudioRender read GetAudioRender;
		property Screen : TSGPointer read GetScreen;
		property NewContext : TSGPointer write SetNewContext;
		property RenderClass : TSGPointer write SetRenderClass;
		property SelfLink : PISGContext read GetSelfLink write SetSelfLink;
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

	ISGContextabled = interface(ISGRendered)
		['{ee8df1e3-abe8-4378-8d11-7b5903fea502}']
		procedure SetContext(const VContext : ISGContext);
		function GetContext() : ISGContext;
		function ContextAssigned() : TSGBoolean;

		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		end;

	TSGContextabled = class(TSGNamed, ISGContextabled)
			public
		constructor Create();override;deprecated;
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);virtual;
			protected
		FContext : PISGContext;
			public
		procedure SetContext(const VContext : ISGContext);virtual;
		function GetContext() : ISGContext;virtual;
		function GetRender() : ISGRender;virtual;
		function GetAudioRender() : ISGAudioRender;virtual;

		function ContextAssigned() : TSGBoolean;virtual;
		function RenderAssigned() : TSGBoolean;virtual;
		function AudioRenderAssigned() : TSGBool; virtual;

		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		property AudioRender : ISGAudioRender read GetAudioRender;
		end;

	TSGDrawableClass = class of TSGDrawable;
	TSGDrawable = class(TSGExtendedPaintable, ISGContextabled)
			public
		constructor Create();override;deprecated;
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);virtual;
		class function ClassName() : TSGString; override;
			protected
		FContext : PISGContext;
			public
		procedure SetContext(const VContext : ISGContext);virtual;
		function GetContext() : ISGContext;virtual;
		function GetRender() : ISGRender;virtual;
		function GetAudioRender() : ISGAudioRender;virtual;

		function ContextAssigned() : TSGBoolean;virtual;
		function RenderAssigned() : TSGBoolean;virtual;
		function AudioRenderAssigned() : TSGBool; virtual;

		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		property AudioRender : ISGAudioRender read GetAudioRender;
		end;

implementation

function TSGDrawable.AudioRenderAssigned() : TSGBool;
begin
Result := False;
if ContextAssigned() then
	Result := Context.AudioRender <> nil;
end;

function TSGDrawable.GetAudioRender() : ISGAudioRender;
begin
Result := Context.AudioRender;
end;

function TSGContextabled.AudioRenderAssigned() : TSGBool;
begin
Result := False;
if ContextAssigned() then
	Result := Context.AudioRender <> nil;
end;

function TSGContextabled.GetAudioRender() : ISGAudioRender;
begin
Result := Context.AudioRender;
end;

class function TSGDrawable.ClassName() : TSGString;
begin
Result := 'TSGDrawable';
end;

constructor TSGContextabled.Create();
begin
inherited;
FContext := nil;
end;

destructor TSGContextabled.Destroy();
begin
inherited;
end;

constructor TSGContextabled.Create(const VContext : ISGContext);
begin
Create();
SetContext(VContext);
end;

procedure TSGContextabled.SetContext(const VContext : ISGContext);
begin
if VContext <> nil then
	FContext := VContext.SelfLink
else
	FContext := nil;
end;

function TSGContextabled.GetContext() : ISGContext;
begin
Result := FContext^;
end;

function TSGContextabled.GetRender() : ISGRender;
begin
Result := FContext^.Render;
end;

function TSGContextabled.ContextAssigned() : TSGBoolean;
begin
Result := False;
if (FContext <> nil) then
	if (FContext^ <> nil) then
		Result := True;
end;

function TSGContextabled.RenderAssigned() : TSGBoolean;
begin
Result := False;
if ContextAssigned() then
	if FContext^.Render <> nil then
		Result := True;
end;

function TSGDrawable.RenderAssigned() : TSGBoolean;
begin
if ContextAssigned() then
	if FContext^.Render <> nil then
		Result := True;
end;

constructor TSGDrawable.Create(const VContext:ISGContext);
begin
Create();
SetContext(VContext);
end;

function TSGDrawable.GetRender():ISGRender;
begin
Result := FContext^.Render;
end;

procedure TSGDrawable.SetContext(const VContext : ISGContext);
begin
if VContext <> nil then
	FContext := VContext.SelfLink
else
	FContext := nil;
end;

function TSGDrawable.ContextAssigned() : TSGBoolean;
begin
Result := False;
if (FContext <> nil) then
	if (FContext^ <> nil) then
		Result := True;
end;

function TSGDrawable.GetContext() : ISGContext;
begin
Result := FContext^;
end;

constructor TSGDrawable.Create();
begin
inherited;
FContext := nil;
end;

destructor TSGDrawable.Destroy();
begin
inherited;
end;

end.
