{$INCLUDE SaGe.inc}

unit SaGeAllExamples;

interface

uses
	SaGeBase
	,SaGeContext
	,SaGeTotal
	,SaGeRender
	
	,Ex1
	,Ex2_2
	,Ex2
	,Ex3
	,Ex4_1
	,Ex4_2
	,Ex4_3
	,Ex5
	,Ex5_2
	,Ex5_4
	,Ex6
	,Ex6_2
	,Ex7
	,Ex13
	;

type
	TSGAllExamples = class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
			public
		FDrawClasses : TSGDrawClasses;
			public
		procedure Draw();override;
		end;

implementation

constructor TSGAllExamples.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FDrawClasses := TSGDrawClasses.Create(Context);
FDrawClasses.Add(TSGExample13);
FDrawClasses.Add(TSGExample1);
FDrawClasses.Add(TSGExample2);
FDrawClasses.Add(TSGExample2_2);
FDrawClasses.Add(TSGExample3);
FDrawClasses.Add(TSGExample4_1);
FDrawClasses.Add(TSGExample4_2);
FDrawClasses.Add(TSGExample4_3);
FDrawClasses.Add(TSGExample5);
FDrawClasses.Add(TSGExample5_2);
FDrawClasses.Add(TSGExample5_4);
FDrawClasses.Add(TSGExample6);
FDrawClasses.Add(TSGExample6_2);
FDrawClasses.Add(TSGApprFunction{Ex7});
FDrawClasses.Initialize();
FDrawClasses.ComboBox.BoundsToNeedBounds();
FDrawClasses.ComboBox.SetBounds(5,5,SGDrawClassesComboBoxWidth,18);
FDrawClasses.ComboBox.BoundsToNeedBounds();
FDrawClasses.ComboBox.SetBounds(5,28,SGDrawClassesComboBoxWidth,18);
end;

destructor TSGAllExamples.Destroy();
begin
FDrawClasses.Destroy();
FDrawClasses:=nil;
inherited;
end;

class function TSGAllExamples.ClassName():string;
begin
Result := '�������';
end;

procedure TSGAllExamples.Draw();
begin
if FDrawClasses<>nil then
	FDrawClasses.Draw();
end;

end.
