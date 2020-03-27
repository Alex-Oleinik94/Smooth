{$INCLUDE Smooth.inc}

unit SmoothScreenSkinInterface;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothScreenBase
	,SmoothScreenComponentInterfaces
	;
type
	ISScreenSkin = interface(ISInterface)
		['{f55a3794-246d-4bac-b8f8-47a971209b1f}']
		procedure PaintButton(constref Button : ISButton);
		procedure PaintPanel(constref Panel : ISPanel);
		procedure PaintComboBox(constref ComboBox : ISComboBox);
		procedure PaintLabel(constref VLabel : ISLabel);
		procedure PaintEdit(constref Edit : ISEdit);
		procedure PaintProgressBar(constref ProgressBar : ISProgressBar);
		procedure PaintForm(constref Form : ISForm);
		end;

implementation

end.
