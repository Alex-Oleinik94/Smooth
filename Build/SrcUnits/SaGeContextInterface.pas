{$INCLUDE Includes\SaGe.inc}

unit SaGeContextInterface;

interface
uses
	SaGeBased
	,SaGeBaseClasses
	,SaGeCommon
	,SaGeRender
	;

type
	TSGCursorButtons = (SGNoCursorButton, SGMiddleCursorButton, SGLeftCursorButton, SGRightCursorButton);
	TSGCursorButtonType = (SGDownKey, SGUpKey);
	TSGCursorWheel = (SGNoCursorWheel,SGUpCursorWheel,SGDownCursorWheel);
	TSGCursorPosition = (SGDeferenseCursorPosition,SGNowCursorPosition,SGLastCursorPosition);
	
	ISGRenderedTimerArea = interface(ISGTimerArea)
		function GetRender() : ISGRender;
		
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGLongWord read GetElapsedTime;
		end;
	
	ISGCursorHandler = interface(ISGRenderedTimerArea)
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
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;
		procedure ClearKeys();
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);
		
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGLongWord read GetElapsedTime;
		end;
	
	ISGCustomContext = interface(ISGCursorHandler)
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
		
		function GetCursorPosition():TSGPoint2f;
		procedure SetCursorPosition(const VPosition : TSGPoint2f);
		function GetWindowArea():TSGPoint2f;
		function GetScreenArea():TSGPoint2f;
		function GetClientArea():TSGPoint2f;
		function ShiftClientArea() : TSGPoint2f;
		function GetClientAreaShift() : TSGPoint2f;
		
		function FileOpenDialog(const VTittle: TSGString; const VFilter : TSGString) : TSGString;
		function FileSaveDialog(const VTittle: TSGString; const VFilter : TSGString;const Extension : TSGString) : TSGString;
		
		function GetCursorIcon():TSGPointer;
		procedure SetCursorIcon(const VIcon : TSGPointer);
		function GetIcon():TSGPointer;
		procedure SetIcon(const VIcon : TSGPointer);
		
		property Fullscreen : TSGBoolean read GetFullscreen write InitFullscreen;
		property Active : TSGBoolean read GetActive write SetActive;
		property CursorIcon : TSGPointer read GetCursorIcon write SetCursorIcon;
		property Icon : TSGPointer read GetIcon write SetIcon;
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGLongWord read GetElapsedTime;
		property CursorCentered : TSGBoolean read GetCursorCentered write SetCursorCentered;
		end;
	
	PISGContext = ^ ISGContext;
	ISGContext = interface(ISGCustomContext)
		procedure SetSelfLink(const VLink : PISGContext);
		function GetSelfLink() : PISGContext;
		
		property SelfLink : PISGContext read GetSelfLink write SetSelfLink;
		property Fullscreen : TSGBoolean read GetFullscreen write InitFullscreen;
		property Active : TSGBoolean read GetActive write SetActive;
		property CursorIcon : TSGPointer read GetCursorIcon write SetCursorIcon;
		property Icon : TSGPointer read GetIcon write SetIcon;
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property CursorCentered : TSGBoolean read GetCursorCentered write SetCursorCentered;
		end;
	
	ISGContextabled = interface(ISGRendered)
		procedure SetContext(const VContext : ISGContext);
		function GetContext() : ISGContext;
		function ContextAssigned() : TSGBoolean;
		
		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		end;
	
	TSGDrawable = class(TSGExtendedPaintable, ISGContextabled)
			public
		constructor Create();override;deprecated;
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);virtual;overload;
			public
		FContext : PISGContext;
			public
		procedure SetContext(const VContext : ISGContext);virtual;
		function GetContext() : ISGContext;virtual;
		function GetRender() : ISGRender;virtual;
		function ContextAssigned() : TSGBoolean;virtual;
		
		property Context : ISGContext read GetContext write SetContext;
		property Render  : ISGRender  read GetRender;
		end;

implementation

constructor TSGDrawable.Create(const VContext:ISGContext);overload;
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
