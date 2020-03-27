{$INCLUDE Smooth.inc}

unit SmoothFractalForm;

interface

uses 
	 SmoothBase
	,SmoothFractals
	,SmoothScreen
	,SmoothContextInterface
	,SmoothScreenClasses
	;

type
	TS3DFractalForm = class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		procedure Calculate();override;
		procedure CalculateFromThread(); virtual;
			protected
		procedure FinalizeCalculateFromThread(const ObjectId : TSUInt32); virtual;
		function RecQuantity(const RecDepth : TSMaxEnum) : TSMaxEnum; virtual; abstract;
			protected
		FLD, FLDC : TSScreenLabel;
		FBPD, FBMD : TSScreenButton;
			protected
		FIs2D : TSBoolean;
		FPrimetiveType : TSUInt32;
		FPrimetiveParam : TSUInt32;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothRenderBase
	,SmoothVertexObject
	,SmoothScreenBase
	;

procedure TS3DFractalForm.Calculate();
var
	Quantity : TSUInt64;
begin
inherited;
Clear3dObject();
Quantity := RecQuantity(FDepth);
if FIs2D then
	if (Render.RenderType in [SRenderDirectX9, SRenderDirectX8]) then 
		Calculate3dObjects(Quantity, FPrimetiveType, S3dObjectVertexType3f, FPrimetiveParam)
	else
		Calculate3dObjects(Quantity, FPrimetiveType, S3dObjectVertexType2f, FPrimetiveParam)
else
	Calculate3dObjects(Quantity, FPrimetiveType, S3dObjectVertexType3f, FPrimetiveParam);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished := False;
	FThreadsData[0].FData     := nil;
	CalculateFromThread();
	end
else
	begin
	CalculateFromThread();
	if FEnableVBO and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO();
	end;
end;

procedure TS3DFractalForm.CalculateFromThread();
begin

end;

procedure TS3DFractalForm.FinalizeCalculateFromThread(const ObjectId : TSUInt32);
begin
if FThreadsEnable then
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
end;

procedure mmmFButtonDepthPlusOnChangeKT(Button:TSScreenButton);
begin
with TS3DFractalForm(Button.FUserPointer1) do
	begin
	FDepth += 1;
	Calculate();
	FLD.Caption := SStr(Depth);
	FBMD.Active := True;
	end;
end;

procedure mmmFButtonDepthMinusOnChangeKT(Button:TSScreenButton);
begin
with TS3DFractalForm(Button.FUserPointer1) do
	begin
	if Depth > 0 then
		begin
		FDepth -= 1;
		Calculate();
		FLD.Caption := SStr(Depth);
		if Depth = 0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TS3DFractalForm.Create(const VContext : ISContext);
begin
inherited;
FEnableColors  := False;
FEnableNormals := False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
FLightingEnable := False;

FIs2D := False;
FPrimetiveType := SR_LINES;
FPrimetiveParam := 0;

FLD  := nil;
FLDC := nil;
FBMD := nil;
FBPD := nil;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]);
Screen.LastChild.BoundsMakeReal();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]);
Screen.LastChild.BoundsMakeReal();

FLDC := SCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@mmmFButtonDepthPlusOnChangeKT);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@mmmFButtonDepthMinusOnChangeKT);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD.Caption:=SStringToPChar(SStr(Depth));
end;

destructor TS3DFractalForm.Destroy();
begin
FBMD.Destroy();
FLD.Destroy();
FLDC.Destroy();
FBPD.Destroy();
inherited Destroy();
end;

class function TS3DFractalForm.ClassName():TSString;
begin
Result := 'TS3DFractalForm';
end;

end.
