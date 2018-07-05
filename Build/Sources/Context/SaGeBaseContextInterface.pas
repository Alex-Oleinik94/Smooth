{$INCLUDE SaGe.inc}

unit SaGeBaseContextInterface;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	;
type
	TSGAreaInt = TSGInt32;
	ISGRectangle = interface(ISGInterface)
		['{e8662e5e-d8bd-4515-8828-40853a68da8f}']
		function GetWidth() : TSGAreaInt;
		function GetHeight() : TSGAreaInt;
		procedure SetWidth(const VWidth : TSGAreaInt);
		procedure SetHeight(const VHeight : TSGAreaInt);

		property Width  : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		end;

	ISGArea = interface(ISGRectangle)
		['{f1f34026-791d-4476-a5dc-32ecaeec36c8}']
		function GetLeft() : TSGAreaInt;
		function GetTop() : TSGAreaInt;
		procedure SetLeft(const VLeft : TSGAreaInt);
		procedure SetTop(const VTop : TSGAreaInt);

		property Left   : TSGAreaInt read GetLeft write SetLeft;
		property Top    : TSGAreaInt read GetTop write SetTop;
		property Width  : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
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
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		end;
	
	TSGTimerInt = TSGUInt32;
	ISGBaseContext = interface(ISGDeviceArea)
		['{2746e985-11ee-4a85-a840-fe89d1d81f0d}']
		procedure StartComputeTimer();
		procedure UpdateTimer();
		function GetElapsedTime() : TSGTimerInt;
		
		function GetTitle() : TSGString;
		procedure SetTitle(const VTitle : TSGString);
		
		procedure Resize();

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

implementation

end.
