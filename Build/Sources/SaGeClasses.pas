{$INCLUDE SaGe.inc}

unit SaGeClasses;

interface

uses
	Classes
	,SaGeBase
	,SaGeBased
	{$IFDEF WITHLEAKSDETECTOR}
	,SaGeLeaksDetector
	{$ENDIF}
	;

type
	ISGInterface = interface(IInterface)
		['{2542664e-68ea-47d7-8f66-67e3143ca7ae}']
		procedure DestroyFromInterface();
		end;

	TSGObject = class(TObject)
		constructor Create();virtual;
		end;

	TSGInterfacedObject = class(TSGObject, ISGInterface)
			private
		FReferenceCount : TSGLongWord;
			public
		function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} VInterfaceIdentifier : TSGGuid; out VObject) : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
		function _AddRef : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
		function _Release : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};virtual;
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure DestroyFromInterface();virtual;
		end;

	TSGNamed = class(TSGInterfacedObject)
			public
		{$IFDEF WITHLEAKSDETECTOR}
		constructor Create(); override;
		destructor Destroy(); override;
		{$ENDIF}
		class function ClassName() : TSGString; virtual;
		end;

	ISGOptionGetSeter = interface
		['{8c35573c-38fb-43ab-876f-af746af58650}']
		function GetOption(const VName : TSGString) : TSGPointer;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);
		end;

	ISGPaintable = interface(ISGOptionGetSeter)
		['{7996b748-dd9b-41d5-ac28-7e5529023ef1}']
		procedure Paint();
		end;

	TSGAreaInt = TSGInt32;

	ISGRectangle = interface(ISGPaintable)
		['{e8662e5e-d8bd-4515-8828-40853a68da8f}']
		function GetWidth() : TSGAreaInt;
		function GetHeight() : TSGAreaInt;
		procedure SetWidth(const VWidth : TSGAreaInt);
		procedure SetHeight(const VHeight : TSGAreaInt);

		property Width  : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		end;

	ISGTitledResiseableRectangle = interface(ISGRectangle)
		['{425e6c53-7a59-4b26-9ed5-eb94879c9f16}']
		function GetTitle() : TSGString;
		procedure SetTitle(const VTitle : TSGString);

		procedure Resize();

		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		end;


	ISGArea = interface(ISGTitledResiseableRectangle)
		['{f1f34026-791d-4476-a5dc-32ecaeec36c8}']
		function GetLeft() : TSGAreaInt;
		function GetTop() : TSGAreaInt;
		procedure SetLeft(const VLeft : TSGAreaInt);
		procedure SetTop(const VTop : TSGAreaInt);

		property Left   : TSGAreaInt read GetLeft write SetLeft;
		property Top    : TSGAreaInt read GetTop write SetTop;
		property Width  : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title  : TSGString  read GetTitle write SetTitle;
		end;

	ISGDeviceArea = interface(ISGArea)
		['{f1abd9e3-5eb3-40ae-9d70-0b28a8d4d68b}']
		function GetClientWidth()  : TSGAreaInt;
		function GetClientHeight() : TSGAreaInt;
		procedure SetClientWidth (const VClientWidth  : TSGAreaInt);
		procedure SetClientHeight(const VClientHeight : TSGAreaInt);
		function GetWindow() : TSGPointer;
		function GetDevice() : TSGPointer;

		property ClientWidth : TSGAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGAreaInt read GetClientHeight write SetClientHeight;
		property Left : TSGAreaInt read GetLeft write SetLeft;
		property Top : TSGAreaInt read GetTop write SetTop;
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		end;

	TSGTimerInt = TSGUInt32;
	ISGTimerArea = interface(ISGDeviceArea)
		['{2746e985-11ee-4a85-a840-fe89d1d81f0d}']
		procedure StartComputeTimer();
		procedure UpdateTimer();
		function GetElapsedTime() : TSGTimerInt;

		property Left : TSGAreaInt read GetLeft write SetLeft;
		property Top : TSGAreaInt read GetTop write SetTop;
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property ElapsedTime : TSGTimerInt read GetElapsedTime;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		property ClientWidth : TSGAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGAreaInt read GetClientHeight write SetClientHeight;
		end;

	ISGNearlyContext = interface(ISGTimerArea)
		['{5ae93fd6-88a9-495e-9249-9e3e4cf7f9ac}']
		end;

	TSGPaintable = class(TSGNamed, ISGPaintable)
			public
		class function ClassName() : TSGString; override;
		procedure Paint();virtual;
		function GetOption(const VName : TSGString) : TSGPointer;virtual;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);virtual;
		end;

	ISGDeviceDependent = interface(ISGPaintable)
		['{0841a6ed-c09e-4273-965a-c82db11d26ff}']
		function Suppored() : TSGBoolean;
		procedure DeleteDeviceResourses();
		procedure LoadDeviceResourses();
		procedure Resize();
		end;

	TSGExtendedPaintable = class(TSGPaintable, ISGDeviceDependent)
			public
		class function ClassName() : TSGString; override;
		procedure DeleteDeviceResourses();virtual;
		procedure LoadDeviceResourses();virtual;
		function Suppored() : TSGBoolean;virtual;
		procedure Resize();virtual;
		end;

procedure SGDestroyInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} i : IInterface);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	SysUtils;

{$IFDEF WITHLEAKSDETECTOR}
constructor TSGNamed.Create();
begin
inherited;
if LeaksDetector <> nil then
	LeaksDetector.AddReference(ClassName())
else
	SGLog.Sourse(['TSGLeaksDetector : Error : AddReferense(''',ClassName(),''') without specimen of TSGLeaksDetector']);
end;

destructor TSGNamed.Destroy();
begin
if LeaksDetector <> nil then
	LeaksDetector.ReleaseReference(ClassName())
else
	SGLog.Sourse(['TSGLeaksDetector : Error : ReleaseReference(''',ClassName(),''') without specimen of TSGLeaksDetector']);
inherited;
end;
{$ENDIF}

procedure SGDestroyInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} i : IInterface);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
try
while i._Release() > 0 do ;
except
end;
end;

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

constructor TSGInterfacedObject.Create();
begin
inherited;
FReferenceCount := 1;
end;

destructor TSGInterfacedObject.Destroy();
begin
inherited;
end;

procedure TSGInterfacedObject.DestroyFromInterface();
begin
if Self <> nil then
	begin
	WriteLn('Destroying from interface ' + ClassName());
	Self.Destroy();
	end;
end;

function TSGExtendedPaintable.Suppored() : TSGBoolean;
begin
Result := True;
end;

procedure TSGExtendedPaintable.Resize();
begin
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
Result := S_OK;
if not Supports(Self, VInterfaceIdentifier, VObject) then
	if not GetInterface(VInterfaceIdentifier, VObject) then
		{$IFNDEF RELEASE}Result := TSGLongInt(E_NOINTERFACE){$ENDIF};
end;

function TSGInterfacedObject._AddRef : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := InterlockedIncrement(FReferenceCount);
end;

function TSGInterfacedObject._Release : TSGLongInt;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
Result := InterlockedDecrement(FReferenceCount);
if Result = 0 then
	begin
	DestroyFromInterface();
	end;
end;

end.
