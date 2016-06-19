{$INCLUDE Includes\SaGe.inc}

unit SaGeBaseClasses;

interface 

uses
	Classes
	,SaGeBased;
	
type
	ISGInterface = interface(IInterface)
		procedure DestroyFromInterface();
		end;
	
	TSGObject = class(TObject)
		constructor Create();virtual;
		end;
	
	TSGInterfacedObject = class(TSGObject, ISGInterface)
		function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} VInterfaceIdentifier : TSGGuid; out VObject) : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
		function _AddRef : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
		function _Release : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
		
		destructor Destroy(); override;
		procedure DestroyFromInterface();
		end;
	
	TSGNamed = class(TSGInterfacedObject)
			public
		class function ClassName() : TSGString; virtual;
		end;
	
	ISGOptionGetSeter = interface
		function GetOption(const VName : TSGString) : TSGPointer;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);
		end;
	
	ISGPaintable = interface(ISGOptionGetSeter)
		procedure Paint();
		end;
	
	ISGRectangle = interface(ISGPaintable)
		function GetWidth() : TSGLongWord;
		function GetHeight() : TSGLongWord;
		procedure SetWidth(const VWidth : TSGLongWord);
		procedure SetHeight(const VHeight : TSGLongWord);
		
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		end;
	
	ISGTitledResiseableRectangle = interface(ISGRectangle)
		function GetTitle() : TSGString;
		procedure SetTitle(const VTitle : TSGString);
		
		procedure Resize();
		
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		end;
	
	ISGArea = interface(ISGTitledResiseableRectangle)
		function GetLeft() : TSGLongWord;
		function GetTop() : TSGLongWord;
		procedure SetLeft(const VLeft : TSGLongWord);
		procedure SetTop(const VTop : TSGLongWord);
		
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		end;
	
	ISGAreaWithClient = interface(ISGArea)
		function GetClientWidth() : TSGLongWord;
		function GetClientHeight() : TSGLongWord;
		procedure SetClientWidth(const VClientWidth : TSGLongWord);
		procedure SetClientHeight(const VClientHeight : TSGLongWord);
		
		property ClientWidth : TSGLongWord read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGLongWord read GetClientHeight write SetClientHeight;
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		end;
	
	ISGTimerArea = interface(ISGAreaWithClient)
		procedure StartComputeTimer();
		procedure UpdateTimer();
		function GetElapsedTime() : TSGLongWord;
		
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property ElapsedTime : TSGLongWord read GetElapsedTime;
		end;
	
	ISGNearlyContext = ISGTimerArea;
	
	TSGPaintable = class(TSGNamed, ISGPaintable)
			public
		class function ClassName() : TSGString; override;
		procedure Paint();
		function GetOption(const VName : TSGString) : TSGPointer;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);
		end;
	
	ISGDeviceDependent = interface
		procedure DeleteDeviceResourses();
		procedure LoadDeviceResourses();
		end;
	
	TSGExtendedPaintable = class(TSGPaintable, ISGDeviceDependent)
			public
		class function ClassName() : TSGString; override;
		procedure DeleteDeviceResourses();
		procedure LoadDeviceResourses();
		end;

implementation

function TSGPaintable.GetOption(const VName : TSGString) : TSGPointer;
begin
Result := nil;
end;

procedure TSGPaintable.SetOption(const VName : TSGString; const VValue : TSGPointer);
begin
end;

constructor TSGObject.Create();
begin
end;

destructor TSGInterfacedObject.Destroy();
begin
inherited;
end;

procedure TSGInterfacedObject.DestroyFromInterface();
begin
if Self <> nil then
	Self.Destroy();
end;

procedure TSGExtendedPaintable.DeleteDeviceResourses();
begin
end;

procedure TSGExtendedPaintable.LoadDeviceResourses();
begin
end;

procedure TSGPaintable.Paint();
begin
end;

class function TSGPaintable.ClassName() : TSGString;
begin
Result := 'TSGPaintable';
end;

class function TSGNamed.ClassName() : TSGString;
begin
Result := 'TSGNamed';
end;

class function TSGExtendedPaintable.ClassName() : TSGString;
begin
Result := 'TSGExtendedPaintable';
end;

function TSGInterfacedObject.QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} VInterfaceIdentifier : TSGGuid; out VObject) : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
if GetInterface(VInterfaceIdentifier, VObject) then
	Result := S_OK
else
	Result := TSGLongInt(E_NOINTERFACE); 
end;

function TSGInterfacedObject._AddRef : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := 1;
end;

function TSGInterfacedObject._Release : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := 1;
end;

end.
