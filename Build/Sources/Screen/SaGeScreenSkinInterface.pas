{$INCLUDE SaGe.inc}

unit SaGeScreenSkinInterface;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeScreenBase
	;
type
	ISGSkin = interface
		['{f55a3794-246d-4bac-b8f8-47a971209b1f}']
		procedure PaintButton(constref Button : ISGButton);
		procedure PaintPanel(constref Panel : ISGPanel);
		procedure PaintComboBox(constref ComboBox : ISGComboBox);
		procedure PaintLabel(constref VLabel : ISGLabel);
		procedure PaintEdit(constref Edit : ISGEdit);
		procedure PaintProgressBar(constref ProgressBar : ISGProgressBar);
		end;

implementation

end.
