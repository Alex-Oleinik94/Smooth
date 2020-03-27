{$INCLUDE Smooth.inc}

unit SmoothTextVertexObject;

interface

uses
	 SmoothBase
	,SmoothFont
	,SmoothContextClasses
	,SmoothCommonStructs
	,SmoothRenderInterface
	,SmoothImage
	;

type
	TSTextVertexObjectSymbol = object
			public
		Vectors : packed array [0..3] of TSVector3f;
		TextVectors : packed array [0..3] of TSVector2f;
		Color : TSVector4uint8;
		end;
	
	TSTextVertexObject = object
			protected
		FVertexes : PSByte; (* Array of (Vertex, [Color,] TexVertex) *)
		FVertexesCount : TSMaxEnum;
		FSizeOfOneVertex : TSMaxEnum;
		FUseColors : TSBoolean;
		FMaxTextWidth : TSMaxEnum;
		FTextWidth : TSMaxEnum;
		FTextHeight : TSMaxEnum;
			protected
		procedure SetText(const Text : TSString; constref Render : ISRender; const Font : TSFont); overload;
		procedure SetText(const Text : TSString; constref Render : ISRender; const Font : TSFont; Color : TSVector4uint8); overload;
		procedure SetSymbol(const SymbolNumber : TSMaxEnum; const Symbol : TSTextVertexObjectSymbol);
		procedure SetSymbolPoligone(var Symbol : TSTextVertexObjectSymbol; const SymbolNumber : TSMaxEnum; const SymbolParam : TSSymbolParam; const PaintWithXShift : TSBoolean; const Font : TSFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
			public
		constructor Create();
		destructor Destroy();
		procedure Paint(constref Render : ISRender; const Font : TSFont; const Vector0, Vector1 : TSVector2f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True);
			public
		property UseColors : TSBoolean read FUseColors write FUseColors;
			public
		class function Create(const Text : TSString; constref Render : ISRender; const Font : TSFont) : TSTextVertexObject;
		class procedure Paint(const Text : TSString; constref Render : ISRender; const Font : TSFont; const Vector0, Vector1 : TSVector2f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True); overload;
		class procedure Paint(const Text : TSString; constref Render : ISRender; const Font : TSFont; const Color : TSVector4uint8; const Vector0, Vector1 : TSVector2f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True); overload;
		end;

implementation

uses
	 SmoothRenderBase
	,SmoothCommon
	,SmoothBaseUtils
	;

class procedure TSTextVertexObject.Paint(const Text : TSString; constref Render : ISRender; const Font : TSFont; const Color : TSVector4uint8; const Vector0, Vector1 : TSVector2f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True); overload;
var
	TextObject : TSTextVertexObject;
begin
TextObject.Create();
TextObject.UseColors := True;
TextObject.SetText(Text, Render, Font, Color);
TextObject.Paint(Render, Font, Vector0, Vector1, WidthCentered, HeightCentered);
TextObject.Destroy();
end;

class procedure TSTextVertexObject.Paint(const Text : TSString; constref Render : ISRender; const Font : TSFont; const Vector0, Vector1 : TSVector2f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True); overload;
var
	TextObject : TSTextVertexObject;
begin
TextObject := TSTextVertexObject.Create(Text, Render, Font);
TextObject.Paint(Render, Font, Vector0, Vector1, WidthCentered, HeightCentered);
TextObject.Destroy();
end;

constructor TSTextVertexObject.Create();
begin
FVertexes := nil;
FSizeOfOneVertex := 0;
FUseColors := False;
FTextWidth := 0;
FVertexesCount := 0;
FMaxTextWidth := 0;
FTextHeight := 0;
end;

class function TSTextVertexObject.Create(const Text : TSString; constref Render : ISRender; const Font : TSFont) : TSTextVertexObject;
begin
Result.Create();
Result.SetText(Text, Render, Font);
end;

procedure TSTextVertexObject.Paint(constref Render : ISRender; const Font : TSFont; const Vector0, Vector1 : TSVector2f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True);
var
	WidthShift, HeightShift : TSFloat32;
begin
if (FVertexes <> nil) then
	begin
	Render.PushMatrix();
	if WidthCentered then
		WidthShift := (Abs(Vector1.x - Vector0.x) - FMaxTextWidth) * 0.5
	else
		WidthShift := 0;
	if HeightCentered then
		HeightShift := (Abs(Vector1.y - Vector0.y) - (FTextHeight + Font.FontHeight)) * 0.5
	else
		HeightShift := 0;
	Render.Translatef(Trunc(Vector0.x + WidthShift), Trunc(Vector0.y + HeightShift), 0);
	Font.BindTexture();
	Render.EnableClientState(SR_VERTEX_ARRAY);
	Render.EnableClientState(SR_TEXTURE_COORD_ARRAY);
	if FUseColors then
		Render.EnableClientState(SR_COLOR_ARRAY);
	Render.VertexPointer(3, SR_FLOAT, FSizeOfOneVertex, FVertexes);
	if FUseColors then
		Render.ColorPointer(4, SR_UNSIGNED_BYTE, FSizeOfOneVertex, Pointer(TSMaxEnum(FVertexes) + SizeOf(TSVector3f)));
	Render.TexCoordPointer(2, SR_FLOAT, FSizeOfOneVertex, Pointer(TSMaxEnum(FVertexes) + SizeOf(TSVector3f) + Iff(FUseColors, SizeOf(TSVector4uint8))));
	Render.DrawArrays(SR_TRIANGLES, 0, FVertexesCount);
	Render.DisableClientState(SR_VERTEX_ARRAY);
	Render.DisableClientState(SR_TEXTURE_COORD_ARRAY);
	if FUseColors then
		Render.DisableClientState(SR_COLOR_ARRAY);
	Font.DisableTexture();
	Render.PopMatrix();
	end;
end;

procedure TSTextVertexObject.SetSymbolPoligone(var Symbol : TSTextVertexObjectSymbol; const SymbolNumber : TSMaxEnum; const SymbolParam : TSSymbolParam; const PaintWithXShift : TSBoolean; const Font : TSFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	SymbolParamX0, SymbolParamX1, SymbolParamY0, SymbolParamY1, SymbolX0, SymbolX1, SymbolY0, SymbolY1, X0, X1, Y0, Y1 : TSFloat32;
begin
X0 := FTextWidth;
X1 := X0 + SymbolParam.Width;
Y0 := FTextHeight;
Y1 := Y0 + Font.FontHeight;

Symbol.Vectors[0].Import(X0, Y0);
Symbol.Vectors[1].Import(X1, Y0);
Symbol.Vectors[2].Import(X1, Y1);
Symbol.Vectors[3].Import(X0, Y1);

SymbolParamX0 := SymbolParam.x;
if PaintWithXShift then
	SymbolParamX0 += 0.5;
SymbolParamX1 := SymbolParamX0 + SymbolParam.Width;
SymbolParamY0 := SymbolParam.y;
SymbolParamY1 := SymbolParamY0 + Font.FontHeight;
SymbolX0 := SymbolParamX0 / Font.Width;
SymbolX1 := SymbolParamX1 / Font.Width;
SymbolY0 := 1 - (SymbolParamY0 / Font.Height);
SymbolY1 := 1 - (SymbolParamY1 / Font.Height);

Symbol.TextVectors[0].Import(SymbolX0, SymbolY0);
Symbol.TextVectors[1].Import(SymbolX1, SymbolY0);
Symbol.TextVectors[2].Import(SymbolX1, SymbolY1);
Symbol.TextVectors[3].Import(SymbolX0, SymbolY1);
end;

procedure TSTextVertexObject.SetText(const Text : TSString; constref Render : ISRender; const Font : TSFont); overload;
var
	Color : TSVector4uint8;
begin
Color.Import(255, 255, 255, 255);
SetText(Text, Render, Font, Color);
end;

procedure TSTextVertexObject.SetText(const Text : TSString; constref Render : ISRender; const Font : TSFont; Color : TSVector4uint8); overload;

procedure SetSymbolData(const SymbolNumber : TSMaxEnum; const SymbolParam : TSSymbolParam; const PaintWithXShift : TSBoolean);  {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	Symbol : TSTextVertexObjectSymbol;
begin
SetSymbolPoligone(Symbol, SymbolNumber, SymbolParam, PaintWithXShift, Font);
if FUseColors then
	Symbol.Color := Color;
SetSymbol(SymbolNumber, Symbol);
FTextWidth += SymbolParam.Width;
if (FTextWidth > FMaxTextWidth) then
	FMaxTextWidth := FTextWidth;
end;

var
	i : TSMaxEnum;
	RenderIsDirectX : TSBoolean;
	Eolns13 : TSMaxEnum = 0;
	Eolns10 : TSMaxEnum = 0;
	Eolns : TSMaxEnum = 0;
begin
if (Font = nil) or (Render = nil) or (Text = '') then
	Exit;
RenderIsDirectX := Render.RenderType in [SRenderDirectX9, SRenderDirectX8];
if RenderIsDirectX then
	Color.ConvertType();
FSizeOfOneVertex := SizeOf(TSVector3f) + SizeOf(TSVector2f);
if FUseColors then
	FSizeOfOneVertex += SizeOf(TSVector4uint8);
FVertexesCount := Length(Text) * 6;
if (FVertexes <> nil) then
	begin
	FreeMem(FVertexes);
	FVertexes := nil;
	end;
GetMem(FVertexes, FSizeOfOneVertex * FVertexesCount);
FTextWidth := 0;
FTextHeight := 0;
FMaxTextWidth := 0;
for i := 1 to Length(Text) do
	if (Text[i] = #10) or (Text[i] = #13) then
		begin
		Eolns := Max(Eolns13, Eolns10);
		if (Text[i] = #10) then
			Eolns10 += 1
		else if (Text[i] = #13) then
			Eolns13 += 1;
		if (Eolns < Max(Eolns13, Eolns10)) then
			begin
			FTextHeight += Font.FontHeight + 1;
			FTextWidth := 0;
			end;
		end
	else
		begin
		Eolns10 := 0;
		Eolns13 := 0;
		SetSymbolData(i, Font.SymbolParams[Text[i]], RenderIsDirectX);
		end;
end;

procedure TSTextVertexObject.SetSymbol(const SymbolNumber : TSMaxEnum; const Symbol : TSTextVertexObjectSymbol);
var
	SymbolIndex : TSMaxEnum;
	VertexPointer : TSMaxEnum;
	SymbolShift : TSMaxEnum;
	SymbolPointer : TSMaxEnum;
begin
SymbolIndex := (SymbolNumber - 1) * 6;
SymbolShift := FSizeOfOneVertex * SymbolIndex;
SymbolPointer := TSMaxEnum(FVertexes) + SymbolShift;
VertexPointer := SymbolPointer;
PSVector3f(VertexPointer)^ := Symbol.Vectors[0];
VertexPointer += FSizeOfOneVertex;
PSVector3f(VertexPointer)^ := Symbol.Vectors[1];
VertexPointer += FSizeOfOneVertex;
PSVector3f(VertexPointer)^ := Symbol.Vectors[2];
VertexPointer += FSizeOfOneVertex;
PSVector3f(VertexPointer)^ := Symbol.Vectors[0];
VertexPointer += FSizeOfOneVertex;
PSVector3f(VertexPointer)^ := Symbol.Vectors[2];
VertexPointer += FSizeOfOneVertex;
PSVector3f(VertexPointer)^ := Symbol.Vectors[3];
VertexPointer := SymbolPointer + SizeOf(TSVector3f);
if FUseColors then
	VertexPointer += SizeOf(TSVector4uint8);
PSVector2f(VertexPointer)^ := Symbol.TextVectors[0];
VertexPointer += FSizeOfOneVertex;
PSVector2f(VertexPointer)^ := Symbol.TextVectors[1];
VertexPointer += FSizeOfOneVertex;
PSVector2f(VertexPointer)^ := Symbol.TextVectors[2];
VertexPointer += FSizeOfOneVertex;
PSVector2f(VertexPointer)^ := Symbol.TextVectors[0];
VertexPointer += FSizeOfOneVertex;
PSVector2f(VertexPointer)^ := Symbol.TextVectors[2];
VertexPointer += FSizeOfOneVertex;
PSVector2f(VertexPointer)^ := Symbol.TextVectors[3];
if FUseColors then
	begin
	VertexPointer := SymbolPointer + SizeOf(TSVector3f);
	PSVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSVector4uint8(VertexPointer)^ := Symbol.Color;
	end;
end;

destructor TSTextVertexObject.Destroy();
begin
if (FVertexes <> nil) then
	begin
	FreeMem(FVertexes);
	FVertexes := nil;
	end;
FUseColors := False;
FVertexesCount := 0;
FSizeOfOneVertex := 0;
FMaxTextWidth := 0;
FTextWidth := 0;
FTextHeight := 0;
end;

end.
