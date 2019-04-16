{$INCLUDE SaGe.inc}

unit SaGeAllExamples;

interface

uses
	 SaGeBase
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGePaintableObjectContainer
	,SaGeGraphicViewer
	,SaGeExtensionManager
	
	// Visual examples
	,Ex1
	,Ex2_2
	,Ex2
	,Ex3
	,Ex4_1
	,Ex4_2
	,Ex4_3
	,Ex5 //deprecated
	,Ex5_2 //deprecated
	,Ex5_4
	,Ex6
	,Ex6_2
	,Ex7
	,Ex13
	,Ex14
	,Ex15
	,Ex16
	,ExKraft
	
	// Console examples
	{$IFNDEF MOBILE}
		,Ex8
		,Ex9
		,Ex10
		,Ex11
		,Ex12
		{$ENDIF}
	;

type
	TSGAllExamples = class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString;override;
			private
		FPaintableObjectContainer : TSGPaintableObjectContainer;
			public
		procedure Paint();override;
		end;

implementation

uses
	 SaGeRenderBase
	;

constructor TSGAllExamples.Create(const VContext : ISGContext);
begin
inherited;
FPaintableObjectContainer := TSGPaintableObjectContainer.Create(Context);
FPaintableObjectContainer.Add(TSGExample1);
FPaintableObjectContainer.Add(TSGExample2);
FPaintableObjectContainer.Add(TSGExample2_2);
FPaintableObjectContainer.Add(TSGExample3);
FPaintableObjectContainer.Add(TSGExample4_1);
FPaintableObjectContainer.Add(TSGExample4_2);
FPaintableObjectContainer.Add(TSGExample4_3);
//FPaintableObjectContainer.Add(TSGExample5); //deprecated
//FPaintableObjectContainer.Add(TSGExample5_2); //deprecated
FPaintableObjectContainer.Add(TSGExample5_4);
FPaintableObjectContainer.Add(TSGExample6);
FPaintableObjectContainer.Add(TSGExample6_2);
FPaintableObjectContainer.Add(TSGApprFunction); // Ex 7
FPaintableObjectContainer.Add(TSGExample13);
FPaintableObjectContainer.Add(TSGExample14);
FPaintableObjectContainer.Add(TSGExample15);
FPaintableObjectContainer.Add(TSGExample16);
FPaintableObjectContainer.Add(TSGKraftExamples);
FPaintableObjectContainer.Initialize();
FPaintableObjectContainer.ComboBox.SetBounds(FPaintableObjectContainer.ComboBox.Left, 28, FPaintableObjectContainer.ComboBox.Width, FPaintableObjectContainer.ComboBox.Height);
end;

destructor TSGAllExamples.Destroy();
begin
FPaintableObjectContainer.Destroy();
FPaintableObjectContainer := nil;
inherited;
end;

class function TSGAllExamples.ClassName():string;
begin
Result := 'Примеры';
end;

procedure TSGAllExamples.Paint();
begin
if (FPaintableObjectContainer <> nil) then
	FPaintableObjectContainer.Paint();
end;

initialization
begin
SGRegisterDrawClass(TSGAllExamples, False);
end;

end.
