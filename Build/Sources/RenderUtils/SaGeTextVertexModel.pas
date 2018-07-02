{$INCLUDE SaGe.inc}

unit SaGeTextVertexModel;

interface

uses
	 SaGeBase
	,SaGeFont
	,SaGeVertexObject
	,SaGeCommonClasses
	,SaGeCommonStructs
	;

type
	TSGTextVertexModelSymbol = object
			public
		Vectors : packed array [0..3] of TSGVector3f;
		TextVectors : packed array [0..3] of TSGVector2f;
		Color : TSGVector4f;
		end;
	
	TSGTextVertexModel = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
		procedure Paint();override;
			private
		FMesh : TSG3DObject;
		FText : TSGString;
		FFont : TSGFont;
		FUseColors : TSGBoolean;
			protected
		procedure SetSymbol(const SymbolNumber : TSGMaxEnum; const Symbol : TSGTextVertexModelSymbol);
		procedure SetText(const NewText : TSGString);
			public
		property Text : TSGString read FText write SetText;
		property Font : TSGFont   read FFont write FFont;
		end;

procedure SGKill(var StaticString : TSGTextVertexModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeRenderBase
	,SaGeCommon
	;

procedure SGKill(var StaticString : TSGTextVertexModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (StaticString <> nil) then
	begin
	StaticString.Destroy();
	StaticString := nil;
	end;
end;

procedure TSGTextVertexModel.Paint();
begin
if (FMesh<>nil) and (FFont<>nil) then
	begin
	if (not FUseColors) then
		Render.Color4f(1, 1, 1, 1);
	FFont.BindTexture();
	FMesh.Paint();
	FFont.DisableTexture();
	end;
end;

constructor TSGTextVertexModel.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FMesh := nil;
FText := '';
FFont := nil;
FUseColors := False;
end;

procedure TSGTextVertexModel.SetText(const NewText : TSGString);
var
	WidthShift : TSGMaxEnum;
	DXShift : TSGSingle = 0;

procedure SetSymbolPoligone(const SymbolNumber : TSGMaxEnum; const SymbolParam : TSGSymbolParam); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Symbol : TSGTextVertexModelSymbol;
begin
Symbol.Vectors[0].Import(WidthShift, 0);
Symbol.Vectors[1].Import(WidthShift + SymbolParam.Width, 0);
Symbol.Vectors[2].Import(WidthShift + SymbolParam.Width, FFont.FontHeight);
Symbol.Vectors[3].Import(WidthShift, FFont.FontHeight);
WidthShift += SymbolParam.Width;

Symbol.TextVectors[0].Import(
	(SymbolParam.x + DXShift)/FFont.Width,
	1 - (SymbolParam.y/FFont.Height));
Symbol.TextVectors[1].Import(
	(SymbolParam.x + SymbolParam.Width + DXShift)/FFont.Width,
	1 - (SymbolParam.y/FFont.Height));
Symbol.TextVectors[2].Import(
	(SymbolParam.x + SymbolParam.Width + DXShift)/FFont.Width,
	1 - ((SymbolParam.y + FFont.FontHeight)/FFont.Height));
Symbol.TextVectors[3].Import(
	(SymbolParam.x + DXShift)/FFont.Width,
	1 - ((SymbolParam.y + FFont.FontHeight)/FFont.Height));

SetSymbol(SymbolNumber, Symbol);
end;

var
	i : TSGMaxEnum;
begin
if (FFont = nil) then
	Exit;
SGKill(FMesh);
FText := NewText;
if (FText = '') then
	Exit;
if Render.RenderType in [SGRenderDirectX9, SGRenderDirectX8] then
	DXShift := 0.5;
FMesh := TSG3DObject.Create();
FMesh.SetContext(Context);
FMesh.HasColors := FUseColors;
FMesh.ObjectPoligonesType := SGR_TRIANGLES;
FMesh.ObjectColor := SGColor4fFromUInt32($FFFFFFFF);
FMesh.EnableCullFace := False;
FMesh.HasNormals := False;
FMesh.QuantityFaceArrays := 0;
FMesh.HasTexture := True;
FMesh.Vertexes := 2 * 3 * Length(FText);
WidthShift := 0;
for i := 1 to Length(FText) do
	SetSymbolPoligone(i, FFont.SymbolParams[FText[i]]);
FMesh.LoadToVBO();
end;

procedure TSGTextVertexModel.SetSymbol(const SymbolNumber : TSGMaxEnum; const Symbol : TSGTextVertexModelSymbol);
var
	SymbolIndex : TSGMaxEnum;
begin
SymbolIndex := (SymbolNumber - 1) * 6;
FMesh.ArVertex3f[SymbolIndex + 0]^  := Symbol.Vectors[0];
FMesh.ArVertex3f[SymbolIndex + 1]^  := Symbol.Vectors[1];
FMesh.ArVertex3f[SymbolIndex + 2]^  := Symbol.Vectors[2];
FMesh.ArVertex3f[SymbolIndex + 3]^  := Symbol.Vectors[0];
FMesh.ArVertex3f[SymbolIndex + 4]^  := Symbol.Vectors[2];
FMesh.ArVertex3f[SymbolIndex + 5]^  := Symbol.Vectors[3];
FMesh.ArTexVertex[SymbolIndex + 0]^ := Symbol.TextVectors[0];
FMesh.ArTexVertex[SymbolIndex + 1]^ := Symbol.TextVectors[1];
FMesh.ArTexVertex[SymbolIndex + 2]^ := Symbol.TextVectors[2];
FMesh.ArTexVertex[SymbolIndex + 3]^ := Symbol.TextVectors[0];
FMesh.ArTexVertex[SymbolIndex + 4]^ := Symbol.TextVectors[2];
FMesh.ArTexVertex[SymbolIndex + 5]^ := Symbol.TextVectors[3];
if FUseColors then
	begin
	FMesh.SetColor(SymbolIndex + 0, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 1, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 2, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 3, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 4, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 5, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	end;
end;

destructor TSGTextVertexModel.Destroy();
begin
SGKill(FMesh);
inherited;
end;

class function TSGTextVertexModel.ClassName():TSGString;
begin
Result := 'TSGTextVertexModel';
end;

end.
