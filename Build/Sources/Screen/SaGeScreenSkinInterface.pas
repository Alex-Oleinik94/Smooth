{$INCLUDE SaGe.inc}

unit SaGeScreenSkinInterface;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeScreenBase
	,SaGeScreenComponentInterfaces
	;
type
	ISGScreenSkin = interface(ISGInterface)
		['{f55a3794-246d-4bac-b8f8-47a971209b1f}']
		procedure PaintButton(constref Button : ISGButton);
		procedure PaintPanel(constref Panel : ISGPanel);
		procedure PaintComboBox(constref ComboBox : ISGComboBox);
		procedure PaintLabel(constref VLabel : ISGLabel);
		procedure PaintEdit(constref Edit : ISGEdit);
		procedure PaintProgressBar(constref ProgressBar : ISGProgressBar);
		procedure PaintForm(constref Form : ISGForm);
		end;

implementation

end.
