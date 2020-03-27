{$INCLUDE Smooth.inc}

unit SmoothScreenComponentInterfaces;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothCommonStructs
	,SmoothImage
	;
type
	ISCursorOverComponent = interface(ISComponent)
		['{ac52a3a2-e62d-4473-a2b9-1d36f56389a9}']
		function GetCursorOverTimer() : TSScreenTimer;
		function GetCursorOver() : TSBool;

		property CursorOver : TSBoolean read GetCursorOver;
		property CursorOverTimer : TSScreenTimer read GetCursorOverTimer;
		end;

	ISMouseClickComponent = interface(ISCursorOverComponent)
		['{9b21d96d-b820-41cd-b18f-14ed09d5c218}']
		function GetMouseClickTimer() : TSScreenTimer;
		function GetMouseClick() : TSBool;

		property MouseClick : TSBoolean read GetMouseClick;
		property MouseClickTimer : TSScreenTimer read GetMouseClickTimer;
		end;

	ISLabel = interface(ISComponent)
		['{7f02dd71-b699-453f-aa8d-f41dd7d44bc6}']
		function  GetTextPosition() : TSBoolean;
		procedure SetTextPosition(const Pos : TSBoolean);
		function  GetTextColor() : TSColor4f;
		procedure SetTextColor(const VTextColor : TSColor4f);
		function  GetTextColorSeted() : TSBoolean;
		procedure SetTextColorSeted(const VTextColorSeted : TSBoolean);

		property TextPosition   : TSBoolean read GetTextPosition   write SetTextPosition;
		property TextColor      : TSColor4f read GetTextColor      write SetTextColor;
		property TextColorSeted : TSBoolean read GetTextColorSeted write SetTextColorSeted;
		end;

	ISButton = interface(ISMouseClickComponent)
		['{ec439dc0-edd6-42e2-af41-42e9805c2e77}']
		end;

	ISPanel = interface(ISComponent)
		['{41f51334-780b-444c-aa61-4c000759516b}']
		function ViewingLines() : TSBoolean;
		function ViewingQuad()  : TSBoolean;
		
		property ViewLines : TSBool read ViewingLines;
		property ViewQuad : TSBool read ViewingQuad;
		end;

	ISOpenComponent = interface(ISMouseClickComponent)
		['{84a57b91-b224-45f1-a25d-938dbec2ad0f}']
		function GetOpen() : TSBoolean;
		function GetOpenTimer() : TSScreenTimer;

		property Open : TSBoolean read GetOpen;
		property OpenTimer : TSScreenTimer read GetOpenTimer;
		end;

	TSComboBoxItemIdentifier = TSInt64;
	PSComboBoxItem = ^ TSComboBoxItem;
	TSComboBoxItem = object
			protected
		FImage      : TSImage;
		FCaption    : TSCaption;
		FIdentifier : TSComboBoxItemIdentifier;
		FActive     : TSBoolean;
		FSelected   : TSBoolean;
		FOver       : TSBoolean;
			public
		procedure Clear();
			public
		property Selected   : TSBoolean                read FSelected   write FSelected;
		property Over       : TSBoolean                read FOver       write FOver;
		property Active     : TSBoolean                read FActive     write FActive;
		property Caption    : TSCaption                read FCaption    write FCaption;
		property Text       : TSCaption                read FCaption    write FCaption;
		property Identifier : TSComboBoxItemIdentifier read FIdentifier write FIdentifier;
		property Image      : TSImage                  read FImage      write FImage;
		end;

	TSComboBoxItemList = packed array of TSComboBoxItem;

	ISComboBox = interface(ISOpenComponent)
		['{5859810e-163e-4f5d-9622-7b574ebe07d5}']
		function GetItems() : PSComboBoxItem;
		function GetItemsCount() : TSUInt32;
		function GetLinesCount() : TSUInt32;
		function GetSelectedItem() : PSComboBoxItem;
		function GetFirstItemIndex() : TSUInt32;

		property FirstItemIndex : TSUInt32 read GetFirstItemIndex;
		property LinesCount     : TSUInt32 read GetLinesCount;
		property ItemsCount     : TSUInt32 read GetItemsCount;
		property Items          : PSComboBoxItem read GetItems;
		end;

	TSEditTextType = TSByte;
	ISEdit = interface(ISCursorOverComponent)
		['{468c7f6f-795a-48a1-b5be-615448c2dcbe}']
		function GetTextType() : TSEditTextType;
		function GetTextComplite() : TSBoolean;
		function GetCursorPosition() : TSInt32;
		function GetTextTypeAssigned() : TSBoolean;
		function GetCursorTimer() : TSScreenTimer;
		function GetTextCompliteTimer() : TSScreenTimer;
		function GetNowEditing() : TSBool;
		
		property NowEditing        : TSBool         read GetNowEditing;
		property TextCompliteTimer : TSScreenTimer  read GetTextCompliteTimer;
		property CursorTimer       : TSScreenTimer  read GetCursorTimer;
		property TextTypeAssigned  : TSBoolean      read GetTextTypeAssigned;
		property TextType          : TSEditTextType read GetTextType;
		property TextComplite      : TSBoolean      read GetTextComplite;
		property CursorPosition    : TSInt32        read GetCursorPosition;
		end;

	TSProgressBarFloat = TSFloat64;
	PSProgressBarFloat = ^ TSProgressBarFloat;
	ISProgressBar = interface(ISComponent)
		['{d3781f76-15e1-4537-9886-c6f98787cade}']
		function GetProgress() : TSProgressBarFloat;
		function GetColor() : TSScreenSkinFrameColor;
		function GetIsColorStatic() : TSBool;
		function GetProgressTimer() : TSProgressBarFloat;
		function GetViewCaption() : TSBool;
		function GetViewProgress() : TSBool;

		property ViewProgress  : TSBool                 read GetViewProgress;
		property ViewCaption   : TSBool                 read GetViewCaption;
		property ProgressTimer : TSProgressBarFloat     read GetProgressTimer;
		property Progress      : TSProgressBarFloat     read GetProgress;
		property Color         : TSScreenSkinFrameColor read GetColor;
		property IsColorStatic : TSBool                 read GetIsColorStatic;
		end;
	
	ISForm = interface(ISComponent)
		['{214e57d5-4aea-4410-a7e6-c5d2bcaf170d}']
		end;

implementation

procedure TSComboBoxItem.Clear();
begin
if (FImage as TSImage) <> nil then
	FImage.Destroy();
FImage      := nil;
FCaption    := '';
FIdentifier := 0;
FActive     := False;
FSelected   := False;
FOver       := False;
end;

end.
