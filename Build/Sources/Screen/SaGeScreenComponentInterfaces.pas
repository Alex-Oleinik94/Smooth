{$INCLUDE SaGe.inc}

unit SaGeScreenComponentInterfaces;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeCommonStructs
	,SaGeImage
	;
type
	ISGOverComponent = interface(ISGComponent)
		['{ac52a3a2-e62d-4473-a2b9-1d36f56389a9}']
		function GetCursorOverTimer() : TSGScreenTimer;
		function GetCursorOver() : TSGBool;

		property CursorOver : TSGBoolean read GetCursorOver;
		property CursorOverTimer : TSGScreenTimer read GetCursorOverTimer;
		end;

	ISGClickComponent = interface(ISGOverComponent)
		['{9b21d96d-b820-41cd-b18f-14ed09d5c218}']
		function GetClickTimer() : TSGScreenTimer;
		function GetClick() : TSGBool;

		property Click : TSGBoolean read GetClick;
		property ClickTimer : TSGScreenTimer read GetClickTimer;
		end;

	ISGLabel = interface(ISGComponent)
		['{7f02dd71-b699-453f-aa8d-f41dd7d44bc6}']
		function  GetTextPosition() : TSGBoolean;
		procedure SetTextPosition(const Pos : TSGBoolean);
		function  GetTextColor() : TSGColor4f;
		procedure SetTextColor(const VTextColor : TSGColor4f);
		function  GetTextColorSeted() : TSGBoolean;
		procedure SetTextColorSeted(const VTextColorSeted : TSGBoolean);

		property TextPosition   : TSGBoolean read GetTextPosition   write SetTextPosition;
		property TextColor      : TSGColor4f read GetTextColor      write SetTextColor;
		property TextColorSeted : TSGBoolean read GetTextColorSeted write SetTextColorSeted;
		end;

	ISGButton = interface(ISGClickComponent)
		['{ec439dc0-edd6-42e2-af41-42e9805c2e77}']
		end;

	ISGPanel = interface(ISGComponent)
		['{41f51334-780b-444c-aa61-4c000759516b}']
		function ViewingLines() : TSGBoolean;
		function ViewingQuad()  : TSGBoolean;
		
		property ViewLines : TSGBool read ViewingLines;
		property ViewQuad : TSGBool read ViewingQuad;
		end;

	ISGOpenComponent = interface(ISGClickComponent)
		['{84a57b91-b224-45f1-a25d-938dbec2ad0f}']
		function GetOpen() : TSGBoolean;
		function GetOpenTimer() : TSGScreenTimer;

		property Open : TSGBoolean read GetOpen;
		property OpenTimer : TSGScreenTimer read GetOpenTimer;
		end;

	TSGComboBoxItemIdentifier = TSGInt64;
	PSGComboBoxItem = ^ TSGComboBoxItem;
	TSGComboBoxItem = object
			protected
		FImage      : TSGImage;
		FCaption    : TSGCaption;
		FIdentifier : TSGComboBoxItemIdentifier;
		FActive     : TSGBoolean;
		FSelected   : TSGBoolean;
		FOver       : TSGBoolean;
			public
		procedure Clear();
			public
		property Selected   : TSGBoolean                read FSelected   write FSelected;
		property Over       : TSGBoolean                read FOver       write FOver;
		property Active     : TSGBoolean                read FActive     write FActive;
		property Caption    : TSGCaption                read FCaption    write FCaption;
		property Text       : TSGCaption                read FCaption    write FCaption;
		property Identifier : TSGComboBoxItemIdentifier read FIdentifier write FIdentifier;
		property Image      : TSGImage                  read FImage      write FImage;
		end;

	TSGComboBoxItemList = packed array of TSGComboBoxItem;

	ISGComboBox = interface(ISGOpenComponent)
		['{5859810e-163e-4f5d-9622-7b574ebe07d5}']
		function GetItems() : PSGComboBoxItem;
		function GetItemsCount() : TSGUInt32;
		function GetLinesCount() : TSGUInt32;
		function GetSelectedItem() : PSGComboBoxItem;
		function GetFirstItemIndex() : TSGUInt32;

		property FirstItemIndex : TSGUInt32 read GetFirstItemIndex;
		property LinesCount     : TSGUInt32 read GetLinesCount;
		property ItemsCount     : TSGUInt32 read GetItemsCount;
		property Items          : PSGComboBoxItem read GetItems;
		end;

	TSGEditTextType = TSGByte;
	ISGEdit = interface(ISGOverComponent)
		['{468c7f6f-795a-48a1-b5be-615448c2dcbe}']
		function GetTextType() : TSGEditTextType;
		function GetTextComplite() : TSGBoolean;
		function GetCursorPosition() : TSGInt32;
		function GetTextTypeAssigned() : TSGBoolean;
		function GetCursorTimer() : TSGScreenTimer;
		function GetTextCompliteTimer() : TSGScreenTimer;
		function GetNowEditing() : TSGBool;
		
		property NowEditing        : TSGBool         read GetNowEditing;
		property TextCompliteTimer : TSGScreenTimer  read GetTextCompliteTimer;
		property CursorTimer       : TSGScreenTimer  read GetCursorTimer;
		property TextTypeAssigned  : TSGBoolean      read GetTextTypeAssigned;
		property TextType          : TSGEditTextType read GetTextType;
		property TextComplite      : TSGBoolean      read GetTextComplite;
		property CursorPosition    : TSGInt32        read GetCursorPosition;
		end;

	TSGProgressBarFloat = TSGFloat64;
	PSGProgressBarFloat = ^ TSGProgressBarFloat;
	ISGProgressBar = interface(ISGComponent)
		['{d3781f76-15e1-4537-9886-c6f98787cade}']
		function GetProgress() : TSGProgressBarFloat;
		function GetColor() : TSGScreenSkinFrameColor;
		function GetIsColorStatic() : TSGBool;
		function GetProgressTimer() : TSGProgressBarFloat;
		function GetViewCaption() : TSGBool;
		function GetViewProgress() : TSGBool;

		property ViewProgress  : TSGBool                 read GetViewProgress;
		property ViewCaption   : TSGBool                 read GetViewCaption;
		property ProgressTimer : TSGProgressBarFloat     read GetProgressTimer;
		property Progress      : TSGProgressBarFloat     read GetProgress;
		property Color         : TSGScreenSkinFrameColor read GetColor;
		property IsColorStatic : TSGBool                 read GetIsColorStatic;
		end;

implementation

procedure TSGComboBoxItem.Clear();
begin
if (FImage as TSGImage) <> nil then
	FImage.Destroy();
FImage      := nil;
FCaption    := '';
FIdentifier := 0;
FActive     := False;
FSelected   := False;
FOver       := False;
end;

end.
