{$INCLUDE SaGe.inc}

unit SaGeTextVertexObject;

interface

uses
	 SaGeBase
	,SaGeFont
	,SaGeCommonClasses
	,SaGeCommonStructs
	,SaGeRenderInterface
	,SaGeImage
	;

type
	TSGTextVertexObjectSymbol = object
			public
		Vectors : packed array [0..3] of TSGVector3f;
		TextVectors : packed array [0..3] of TSGVector2f;
		Color : TSGVector4uint8;
		end;
	
	TSGTextVertexObject = object
			protected
		FVertexes : PSGByte; (* Array of (Vertex, [Color,] TexVertex) *)
		FVertexesCount : TSGMaxEnum;
		FSizeOfOneVertex : TSGMaxEnum;
		FUseColors : TSGBoolean;
		FTextWidth : TSGFloat32;
			protected
		procedure SetText(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont); overload;
		procedure SetText(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont; const Color : TSGVector4uint8); overload;
		procedure SetSymbol(const SymbolNumber : TSGMaxEnum; const Symbol : TSGTextVertexObjectSymbol);
		procedure SetSymbolPoligone(var Symbol : TSGTextVertexObjectSymbol; const SymbolNumber : TSGMaxEnum; const SymbolParam : TSGSymbolParam; const PaintWithXShift : TSGBoolean; const Font : TSGFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
			public
		constructor Create();
		destructor Destroy();
		procedure Paint(constref Render : ISGRender; const Font : TSGFont; const Vector0, Vector1 : TSGVector2f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True);
			public
		property UseColors : TSGBoolean read FUseColors write FUseColors;
			public
		class function Create(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont) : TSGTextVertexObject;
		class procedure Paint(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont; const Vector0, Vector1 : TSGVector2f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True); overload;
		class procedure Paint(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont; const Color : TSGVector4uint8; const Vector0, Vector1 : TSGVector2f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True); overload;
		end;

implementation

uses
	 SaGeRenderBase
	,SaGeCommon
	,SaGeBaseUtils
	;

class procedure TSGTextVertexObject.Paint(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont; const Color : TSGVector4uint8; const Vector0, Vector1 : TSGVector2f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True); overload;
var
	TextObject : TSGTextVertexObject;
begin
TextObject.Create();
TextObject.UseColors := True;
TextObject.SetText(Text, Render, Font, Color);
TextObject.Paint(Render, Font, Vector0, Vector1, WidthCentered, HeightCentered);
TextObject.Destroy();
end;

class procedure TSGTextVertexObject.Paint(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont; const Vector0, Vector1 : TSGVector2f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True); overload;
var
	TextObject : TSGTextVertexObject;
begin
TextObject := TSGTextVertexObject.Create(Text, Render, Font);
TextObject.Paint(Render, Font, Vector0, Vector1, WidthCentered, HeightCentered);
TextObject.Destroy();
end;

constructor TSGTextVertexObject.Create();
begin
FVertexes := nil;
FSizeOfOneVertex := 0;
FUseColors := False;
FTextWidth := 0;
FVertexesCount := 0;
end;

class function TSGTextVertexObject.Create(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont) : TSGTextVertexObject;
begin
Result.Create();
Result.SetText(Text, Render, Font);
end;

procedure TSGTextVertexObject.Paint(constref Render : ISGRender; const Font : TSGFont; const Vector0, Vector1 : TSGVector2f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True);
var
	WidthShift, HeightShift : TSGFloat32;
begin
if (FVertexes <> nil) then
	begin
	Render.PushMatrix();
	if WidthCentered then
		WidthShift := (Abs(Vector1.x - Vector0.x) - FTextWidth) * 0.5
	else
		WidthShift := 0;
	if HeightCentered then
		HeightShift := (Abs(Vector1.y - Vector0.y) - Font.FontHeight) * 0.5
	else
		HeightShift := 0;
	Render.Translatef(Vector0.x + WidthShift, Vector0.y + HeightShift, 0);
	Font.BindTexture();
	Render.EnableClientState(SGR_VERTEX_ARRAY);
	Render.EnableClientState(SGR_TEXTURE_COORD_ARRAY);
	if FUseColors then
		Render.EnableClientState(SGR_COLOR_ARRAY);
	Render.VertexPointer(3, SGR_FLOAT, FSizeOfOneVertex, FVertexes);
	if FUseColors then
		Render.ColorPointer(4, SGR_UNSIGNED_BYTE, FSizeOfOneVertex, Pointer(TSGMaxEnum(FVertexes) + SizeOf(TSGVector3f)));
	Render.TexCoordPointer(2, SGR_FLOAT, FSizeOfOneVertex, Pointer(TSGMaxEnum(FVertexes) + SizeOf(TSGVector3f) + Iff(FUseColors, SizeOf(TSGVector4uint8))));
	Render.DrawArrays(SGR_TRIANGLES, 0, FVertexesCount);
	Render.DisableClientState(SGR_VERTEX_ARRAY);
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
	if FUseColors then
		Render.DisableClientState(SGR_COLOR_ARRAY);
	Font.DisableTexture();
	Render.PopMatrix();
	end;
end;

procedure TSGTextVertexObject.SetSymbolPoligone(var Symbol : TSGTextVertexObjectSymbol; const SymbolNumber : TSGMaxEnum; const SymbolParam : TSGSymbolParam; const PaintWithXShift : TSGBoolean; const Font : TSGFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	SymbolParamX0, SymbolParamX1, SymbolParamY0, SymbolParamY1, SymbolX0, SymbolX1, SymbolY0, SymbolY1, X0, X1, Y0, Y1 : TSGFloat32;
begin
X0 := FTextWidth;
X1 := X0 + SymbolParam.Width;
Y0 := 0;
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

procedure TSGTextVertexObject.SetText(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont); overload;
var
	Color : TSGVector4uint8;
begin
Color.Import(255, 255, 255, 255);
SetText(Text, Render, Font, Color);
end;

procedure TSGTextVertexObject.SetText(const Text : TSGString; constref Render : ISGRender; const Font : TSGFont; const Color : TSGVector4uint8); overload;

procedure SetSymbolData(const SymbolNumber : TSGMaxEnum; const SymbolParam : TSGSymbolParam; const PaintWithXShift : TSGBoolean);  {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
var
	Symbol : TSGTextVertexObjectSymbol;
begin
SetSymbolPoligone(Symbol, SymbolNumber, SymbolParam, PaintWithXShift, Font);
if FUseColors then
	Symbol.Color := Color;
SetSymbol(SymbolNumber, Symbol);
FTextWidth += SymbolParam.Width;
end;

var
	i : TSGMaxEnum;
	RenderIsDirectX : TSGBoolean;
begin
if (Font = nil) or (Render = nil) or (Text = '') then
	Exit;
RenderIsDirectX := Render.RenderType in [SGRenderDirectX9, SGRenderDirectX8];
FSizeOfOneVertex := SizeOf(TSGVector3f) + SizeOf(TSGVector2f);
if FUseColors then
	FSizeOfOneVertex += SizeOf(TSGVector4uint8);
FVertexesCount := Length(Text) * 6;
if (FVertexes <> nil) then
	begin
	FreeMem(FVertexes);
	FVertexes := nil;
	end;
GetMem(FVertexes, FSizeOfOneVertex * FVertexesCount);
FTextWidth := 0;
for i := 1 to Length(Text) do
	SetSymbolData(i, Font.SymbolParams[Text[i]], RenderIsDirectX);
end;

procedure TSGTextVertexObject.SetSymbol(const SymbolNumber : TSGMaxEnum; const Symbol : TSGTextVertexObjectSymbol);
var
	SymbolIndex : TSGMaxEnum;
	VertexPointer : TSGMaxEnum;
	SymbolShift : TSGMaxEnum;
	SymbolPointer : TSGMaxEnum;
begin
SymbolIndex := (SymbolNumber - 1) * 6;
SymbolShift := FSizeOfOneVertex * SymbolIndex;
SymbolPointer := TSGMaxEnum(FVertexes) + SymbolShift;
VertexPointer := SymbolPointer;
PSGVector3f(VertexPointer)^ := Symbol.Vectors[0];
VertexPointer += FSizeOfOneVertex;
PSGVector3f(VertexPointer)^ := Symbol.Vectors[1];
VertexPointer += FSizeOfOneVertex;
PSGVector3f(VertexPointer)^ := Symbol.Vectors[2];
VertexPointer += FSizeOfOneVertex;
PSGVector3f(VertexPointer)^ := Symbol.Vectors[0];
VertexPointer += FSizeOfOneVertex;
PSGVector3f(VertexPointer)^ := Symbol.Vectors[2];
VertexPointer += FSizeOfOneVertex;
PSGVector3f(VertexPointer)^ := Symbol.Vectors[3];
VertexPointer := SymbolPointer + SizeOf(TSGVector3f);
if FUseColors then
	VertexPointer += SizeOf(TSGVector4uint8);
PSGVector2f(VertexPointer)^ := Symbol.TextVectors[0];
VertexPointer += FSizeOfOneVertex;
PSGVector2f(VertexPointer)^ := Symbol.TextVectors[1];
VertexPointer += FSizeOfOneVertex;
PSGVector2f(VertexPointer)^ := Symbol.TextVectors[2];
VertexPointer += FSizeOfOneVertex;
PSGVector2f(VertexPointer)^ := Symbol.TextVectors[0];
VertexPointer += FSizeOfOneVertex;
PSGVector2f(VertexPointer)^ := Symbol.TextVectors[2];
VertexPointer += FSizeOfOneVertex;
PSGVector2f(VertexPointer)^ := Symbol.TextVectors[3];
if FUseColors then
	begin
	VertexPointer := SymbolPointer + SizeOf(TSGVector3f);
	PSGVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSGVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSGVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSGVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSGVector4uint8(VertexPointer)^ := Symbol.Color;
	VertexPointer += FSizeOfOneVertex;
	PSGVector4uint8(VertexPointer)^ := Symbol.Color;
	end;
end;

destructor TSGTextVertexObject.Destroy();
begin
if (FVertexes <> nil) then
	begin
	FreeMem(FVertexes);
	FVertexes := nil;
	end;
FUseColors := False;
FVertexesCount := 0;
FSizeOfOneVertex := 0;
end;

end.
