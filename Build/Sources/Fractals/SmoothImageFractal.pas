{$INCLUDE Smooth.inc}

unit SmoothImageFractal;

interface

uses 
	 SmoothBase
	,SmoothFractal
	,SmoothImage
	,SmoothCommon
	;
type
	TSImageFractal=class(TSFractal)
			public
		constructor Create();override;
		class function ClassName():string;override;
			protected
		FImage : TSImage;
		FView : TSScreenVertices;
		FDepthHeight : LongWord;
			public
		procedure InitColor(const x,y:LongInt;const RecNumber:LongInt);virtual;
		class function GetColor(const a,b,color:LongInt):byte;inline;
		class function GetColorOne(const a,b,color:LongInt):byte;inline;
		procedure ToTexture();virtual;
		procedure BeginConstruct();override;
		procedure KillImage();
			public
		property Width:LongInt read FDepth write FDepth;
		property Height:LongWord read FDepthHeight write FDepthHeight;
		property View : TSScreenVertices read FView write FView;
		property Image : TSImage read FImage write FImage;
		end;

implementation

procedure TSImageFractal.KillImage();
begin
SKill(FImage);
end;

class function TSImageFractal.ClassName:string;
begin
Result := 'Smooth image fractal';
end;

// $RANGECHECK
{$IFOPT R+}
	{$DEFINE RANGECHECKS_OFFED}
	{$R-}
	{$ENDIF}

class function TSImageFractal.GetColorOne(const a,b,color:LongInt):byte;inline;
var
	OutPut : TSMaxEnum;
begin
if Color>=b then
	Result:=255
else
	if Color<=a then
		Result:=0
	else
		begin
		if color-a = 0 then
			Result := 0
		else
			begin
			OutPut := Trunc(((b-a)/(color-a))*255);
			if OutPut > 255 then
				Result := OutPut mod 256
			else
				Result := OutPut;
			end;
		end;
end;

class function TSImageFractal.GetColor(const a, b, Color : TSLongInt) : TSByte;inline;
var
	Middle, OutPut : TSWord;
begin
Result:=0;
if (color>=a) and (color<=b) then
	begin
	Middle := round((a+b)/2);
	if color < Middle then
		OutPut := round((color - a) / (Middle - a) * 255)
	else
		OutPut := round((b - color) / (b - Middle) * 255);
	if OutPut > 255 then
		Result := OutPut mod 256
	else
		Result := OutPut;
	end;
end;

{$IFDEF RANGECHECKS_OFFED}
	{$R+}
	{$UNDEFINE RANGECHECKS_OFFED}
	{$ENDIF}

constructor TSImageFractal.Create();
begin
inherited;
FDepthHeight:=0;
FImage:=nil;
end;

procedure TSImageFractal.BeginConstruct();
begin
inherited;
if (FImage = nil) then FImage := TSImage.Create() else FImage.FreeAll();
FImage.Context := Context;
FImage.BitMap.Clear();
FImage.BitMap.Width:=FDepth;
FImage.BitMap.Height:=FDepth*Byte(FDepthHeight=0)+FDepthHeight;
FImage.BitMap.Channels:=3;
FImage.BitMap.ChannelSize:=8;
FImage.BitMap.ReAllocateMemory();
end;

procedure TSImageFractal.ToTexture;
begin
FImage.LoadTexture();
ThreadsBoolean(False);
end;

procedure TSImageFractal.InitColor(const x,y:LongInt;const RecNumber:LongInt);
begin
FImage.BitMap.Data[((FDepth-Y)*FDepth+X)*3]:=trunc((RecNumber/15)*255);
end;

end.
