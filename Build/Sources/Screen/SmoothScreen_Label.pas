{$INCLUDE Smooth.inc}

unit SmoothScreen_Label;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreen
	,SmoothCommonStructs
	,SmoothScreenComponent
	,SmoothScreenComponentInterfaces
	;

type
	TSLabel = class(TSComponent, ISLabel)
			protected
		FTextColorSeted : TSBoolean;
		FTextColor      : TSColor4f;
		FTextPosition   : TSBoolean;
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		procedure Paint(); override;
			protected
		function  GetTextPosition() : TSBoolean; virtual;
		procedure SetTextPosition(const VTextPosition : TSBoolean); virtual;
		function  GetTextColor() : TSColor4f; virtual;
		procedure SetTextColor(const VTextColor : TSColor4f); virtual;
		function  GetTextColorSeted() : TSBoolean; virtual;
		procedure SetTextColorSeted(const VTextColorSeted : TSBoolean); virtual;
			public
		property TextPosition   : TSBoolean read GetTextPosition   write SetTextPosition;
		property TextColor      : TSColor4f read GetTextColor      write SetTextColor;
		property TextColorSeted : TSBoolean read GetTextColorSeted write SetTextColorSeted;
		end;

implementation

uses
	 SmoothArithmeticUtils
	;

class function TSLabel.ClassName() : TSString; 
begin
Result := 'TSLabel';
end;

function  TSLabel.GetTextColor() : TSColor4f;
begin
Result := FTextColor;
end;

procedure TSLabel.SetTextColor(const VTextColor : TSColor4f);
begin
FTextColor      := VTextColor;
FTextColorSeted := True;
end;

function  TSLabel.GetTextColorSeted() : TSBoolean;
begin
Result := FTextColorSeted;
end;

procedure TSLabel.SetTextColorSeted(const VTextColorSeted : TSBoolean);
begin
FTextColorSeted := VTextColorSeted;
end;

destructor TSLabel.Destroy();
begin
inherited;
end;

constructor TSLabel.Create();
begin
inherited;
FTextColor.Import(1, 1, 1, 1);
FTextPosition   := True;
FTextColorSeted := False;
end;

function TSLabel.GetTextPosition() : TSBoolean;
begin
Result := FTextPosition;
end;

procedure TSLabel.SetTextPosition(const VTextPosition :TSBoolean);
begin
FTextPosition := VTextPosition;
end;

procedure TSLabel.Paint();
begin
if FVisibleTimer > SZero then
	FSkin.PaintLabel(Self);
inherited;
end;

end.
