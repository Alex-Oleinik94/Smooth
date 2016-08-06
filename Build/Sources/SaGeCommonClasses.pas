{$INCLUDE SaGe.inc}

unit SaGeCommonClasses;

interface
uses
	SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeRender
	,SaGeImagesBase
	;

type
	TSGCursorHandle = type TSGLongWord;

const
	SGC_NULL = 0;
	SGC_APPSTARTING = 32650;
	SGC_NORMAL = 32512;
	SGC_CROSS = 32515;
	SGC_HAND = 32649;
	SGC_HELP = 32651;
	SGC_IBEAM = 32513;
	SGC_NO = 32648;
	SGC_SIZEALL = 32646;
	SGC_SIZENESW = 32643;
	SGC_SIZENS = 32645;
	SGC_SIZENWSE = 32642;
	SGC_SIZEWE = 32644;
	SGC_UP = 32516;
	SGC_WAIT = 32514;
	SGC_GLASSY = 20000;

type
	TSGCursorButtons = (SGNullCursorButton, SGMiddleCursorButton, SGLeftCursorButton, SGRightCursorButton);
	TSGCursorButtonType = (SGNullKey, SGDownKey, SGUpKey);
	TSGCursorWheel = (SGNullCursorWheel,SGUpCursorWheel,SGDownCursorWheel);
	TSGCursorPosition = (SGDeferenseCursorPosition,SGNowCursorPosition,SGLastCursorPosition);
	TSGHotPixelType = TSGLongInt;
	
	TSGCursor = class(TSGBitMap)
			public
		constructor Create(const VStandartCursor : TSGCursorHandle = SGC_NULL);virtual;
		function LoadFrom(const VFileName : TSGString; const HotX : TSGFloat = 0; const HotY : TSGFloat = 0):TSGCursor;virtual;
		class function Copy(const VCursor : TSGCursor):TSGCursor;
		procedure CopyFrom(const VCursor : TSGCursor);
			private
		FHotPixel : TSGPoint2int32;
		FStandartCursor : TSGCursorHandle;
			public
		property HotPixelX : TSGHotPixelType read FHotPixel.x write FHotPixel.x;
		property HotPixelY : TSGHotPixelType read FHotPixel.y write FHotPixel.y;
		property StandartHandle : TSGCursorHandle read FStandartCursor;
		end;
	
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
		function CursorKeyPressed():TSGCursorButtons;
		function CursorKeyPressedType():TSGCursorButtonType;
		function CursorKeysPressed(const Index : TSGCursorButtons ):TSGBoolean;
		function CursorWheel():TSGCursorWheel;
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2int32;
		procedure ClearKeys();
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);
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
		procedure SetSelfLink(const VLink : PISGContext);
		function  GetSelfLink() : PISGContext;
		procedure SetRenderClass(const NewRender : TSGPointer);
		procedure SetNewContext(const NewContext : TSGPointer);
		function  GetDefaultWindowColor():TSGColor3f;
		procedure BeginIncessantlyPainting();
		procedure EndIncessantlyPainting();
		procedure Minimize();
		procedure Maximize();
		
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
			private
		FContext : PISGContext;
			public
		procedure SetContext(const VContext : ISGContext);virtual;
		function GetContext() : ISGContext;virtual;
		function GetRender() : ISGRender;virtual;
		
		function ContextAssigned() : TSGBoolean;virtual;
		function RenderAssigned() : TSGBoolean;virtual;
		
		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		end;
	
	TSGDrawableClass = class of TSGDrawable;
	TSGDrawable = class(TSGExtendedPaintable, ISGContextabled)
			public
		constructor Create();override;deprecated;
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);virtual;
		class function ClassName() : TSGString; override;
			private
		FContext : PISGContext;
			public
		procedure SetContext(const VContext : ISGContext);virtual;
		function GetContext() : ISGContext;virtual;
		function GetRender() : ISGRender;virtual;
		
		function ContextAssigned() : TSGBoolean;virtual;
		function RenderAssigned() : TSGBoolean;virtual;
		
		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		end;

implementation

uses
	SaGeImages;

class function TSGDrawable.ClassName() : TSGString;
begin
Result := 'TSGDrawable';
end;

procedure TSGCursor.CopyFrom(const VCursor : TSGCursor);
begin
(Self as TSGBitMap).CopyFrom(VCursor as TSGBitMap);
FHotPixel       := VCursor.FHotPixel;
FStandartCursor := VCursor.FStandartCursor;
end;

class function TSGCursor.Copy(const VCursor : TSGCursor):TSGCursor;
begin
Result := TSGCursor.Create();
Result.CopyFrom(VCursor);
end;

function TSGCursor.LoadFrom(const VFileName : TSGString; const HotX : TSGFloat = 0; const HotY : TSGFloat = 0):TSGCursor;
var
	Image : TSGImage;
begin
Image := TSGImage.Create(VFileName);
Image.Loading();

(Self as TSGBitMap).CopyFrom(Image.Image);
HotPixelX := Trunc(HotX * Width );
HotPixelY := Trunc(HotY * Height);

Image.Destroy();
Image := nil;

Result := Self;
end;

constructor TSGCursor.Create(const VStandartCursor : TSGCursorHandle = SGC_NULL);
begin
inherited Create();
FHotPixel.Import(0, 0);
FStandartCursor := VStandartCursor;
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
if (FContext <> nil) then
	if (FContext^ <> nil) then
		if FContext^.Render <> nil then
			Result := True;
end;

function TSGDrawable.RenderAssigned() : TSGBoolean;
begin
if (FContext <> nil) then
	if (FContext^ <> nil) then
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
Result:=FContext^.Render;
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
