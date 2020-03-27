{$INCLUDE Smooth.inc}

unit SmoothAllExamples;

interface

uses
	 SmoothBase
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothPaintableObjectContainer
	,SmoothGraphicViewer
	,SmoothExtensionManager
	
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
	TSAllExamples = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext); override;
		destructor Destroy(); override;
		class function ClassName() : TSString;override;
			private
		FPaintableObjectContainer : TSPaintableObjectContainer;
			public
		procedure Paint();override;
		end;

implementation

uses
	 SmoothRenderBase
	;

constructor TSAllExamples.Create(const VContext : ISContext);
begin
inherited;
FPaintableObjectContainer := TSPaintableObjectContainer.Create(Context);
FPaintableObjectContainer.Add(TSExample1);
FPaintableObjectContainer.Add(TSExample2);
FPaintableObjectContainer.Add(TSExample2_2);
FPaintableObjectContainer.Add(TSExample3);
FPaintableObjectContainer.Add(TSExample4_1);
FPaintableObjectContainer.Add(TSExample4_2);
FPaintableObjectContainer.Add(TSExample4_3);
//FPaintableObjectContainer.Add(TSExample5); //deprecated
//FPaintableObjectContainer.Add(TSExample5_2); //deprecated
FPaintableObjectContainer.Add(TSExample5_4);
FPaintableObjectContainer.Add(TSExample6);
FPaintableObjectContainer.Add(TSExample6_2);
FPaintableObjectContainer.Add(TSApprFunction); // Ex 7
FPaintableObjectContainer.Add(TSExample13);
FPaintableObjectContainer.Add(TSExample14);
FPaintableObjectContainer.Add(TSExample15);
FPaintableObjectContainer.Add(TSExample16);
FPaintableObjectContainer.Add(TSKraftExamples);
FPaintableObjectContainer.Initialize();
FPaintableObjectContainer.ComboBox.SetBounds(FPaintableObjectContainer.ComboBox.Left, 28, FPaintableObjectContainer.ComboBox.Width, FPaintableObjectContainer.ComboBox.Height);
end;

destructor TSAllExamples.Destroy();
begin
FPaintableObjectContainer.Destroy();
FPaintableObjectContainer := nil;
inherited;
end;

class function TSAllExamples.ClassName():string;
begin
Result := 'Примеры';
end;

procedure TSAllExamples.Paint();
begin
if (FPaintableObjectContainer <> nil) then
	FPaintableObjectContainer.Paint();
end;

initialization
begin
SRegisterDrawClass(TSAllExamples, False);
end;

end.
