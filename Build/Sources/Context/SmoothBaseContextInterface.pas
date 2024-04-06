{$INCLUDE Smooth.inc}

unit SmoothBaseContextInterface;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	;
type
	TSAreaInt = TSInt32;
	ISRectangle = interface(ISInterface)
		['{e8662e5e-d8bd-4515-8828-40853a68da8f}']
		function GetWidth() : TSAreaInt;
		function GetHeight() : TSAreaInt;
		procedure SetWidth(const VWidth : TSAreaInt);
		procedure SetHeight(const VHeight : TSAreaInt);

		property Width  : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		end;

	ISArea = interface(ISRectangle)
		['{f1f34026-791d-4476-a5dc-32ecaeec36c8}']
		function GetLeft() : TSAreaInt;
		function GetTop() : TSAreaInt;
		procedure SetLeft(const VLeft : TSAreaInt);
		procedure SetTop(const VTop : TSAreaInt);

		property Left   : TSAreaInt read GetLeft write SetLeft;
		property Top    : TSAreaInt read GetTop write SetTop;
		property Width  : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		end;

	ISClientArea = interface(ISArea)
		['{f1abd9e3-5eb3-40ae-9d70-0b28a8d4d68b}']
		function GetClientWidth()  : TSAreaInt;
		function GetClientHeight() : TSAreaInt;
		procedure SetClientWidth (const VClientWidth  : TSAreaInt);
		procedure SetClientHeight(const VClientHeight : TSAreaInt);

		property Left : TSAreaInt read GetLeft write SetLeft;
		property Top : TSAreaInt read GetTop write SetTop;
		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		end;
	
	TSTimerInt = TSUInt32;
	ISBaseContext = interface(ISClientArea)
		['{2746e985-11ee-4a85-a840-fe89d1d81f0d}']
		function GetWindow() : TSPointer;
		function GetDevice() : TSPointer;
		function GetOption(const What : TSString) : TSPointer;
		
		procedure StartComputeTimer();
		procedure UpdateTimer();
		function GetElapsedTime() : TSTimerInt;
		
		function GetTitle() : TSString;
		procedure SetTitle(const VTitle : TSString);
		
		procedure Resize();
		
		function  GetFullscreen() : TSBoolean;
		procedure InitFullscreen(const VFullscreen : TSBoolean);
		
		property Left : TSAreaInt read GetLeft write SetLeft;
		property Top : TSAreaInt read GetTop write SetTop;
		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		property Title : TSString read GetTitle write SetTitle;
		property ElapsedTime : TSTimerInt read GetElapsedTime;
		property Device : TSPointer read GetDevice;
		property Window : TSPointer read GetWindow;
		property ClientWidth : TSAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSAreaInt read GetClientHeight write SetClientHeight;
		property Fullscreen : TSBoolean read GetFullscreen write InitFullscreen;
		end;

implementation

end.
