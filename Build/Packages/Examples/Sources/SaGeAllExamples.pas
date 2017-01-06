{$INCLUDE SaGe.inc}

unit SaGeAllExamples;

interface

uses
	SaGeBase
	,SaGeCommonClasses
	,SaGeCommonUtils
	,SaGeRenderConstants
	,SaGeGraphicViewer
	,SaGePackages
	
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
	,Ex14
	,Ex15
	,Ex16
	;

type
	TSGAllExamples = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
			private
		FDrawClasses : TSGDrawClasses;
			public
		procedure Paint();override;
		end;

implementation

constructor TSGAllExamples.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FDrawClasses := TSGDrawClasses.Create(Context);
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
FDrawClasses.Add(TSGApprFunction); // Ex 7
FDrawClasses.Add(TSGExample13);
FDrawClasses.Add(TSGExample14);
FDrawClasses.Add(TSGExample15);
FDrawClasses.Add(TSGExample16);
FDrawClasses.Initialize();
FDrawClasses.ComboBox.SetBounds(FDrawClasses.ComboBox.Left, 28, FDrawClasses.ComboBox.Width, FDrawClasses.ComboBox.Height);
end;

destructor TSGAllExamples.Destroy();
begin
FDrawClasses.Destroy();
FDrawClasses := nil;
inherited;
end;

class function TSGAllExamples.ClassName():string;
begin
Result := 'Примеры';
end;

procedure TSGAllExamples.Paint();
begin
if FDrawClasses <> nil then
	FDrawClasses.Paint();
end;

initialization
begin
SGRegisterDrawClass(TSGAllExamples, False);
end;

end.
