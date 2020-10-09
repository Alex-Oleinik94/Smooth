{$INCLUDE Smooth.inc}

unit SmoothFont;

interface

uses
	 SmoothBase
	,SmoothImage
	,SmoothBitMapBase
	,SmoothCommonStructs
	,SmoothContextInterface
	;

type
	TSFont = class;
	TSFontInt = TSUInt32;
	TSSymbolParamType = TSUInt16;
	
	TStringParams=packed array of packed array [0..1] of TSString;
	
	TSSymbolParam = object
		X, Y, Width : TSSymbolParamType;
		end;
	
	TSSymbolParams = packed array[#0..#255] of TSSymbolParam;
	
	TSFont = class(TSImage)
			public
		constructor Create(const VFileName : TSString = '');
		class function ClassName() : TSString; override;
		destructor Destroy();override;
			protected
		FSymbolParams : TSSymbolParams;
		FFontParams : TStringParams;
		FTextureParams : TStringParams;
		FFontLoaded  : TSBoolean;
		FFontHeight : TSUInt8;
		function LoadFont(const _FontFileName : TSString) : TSBoolean;
		class function GetLongInt(var Params:TStringParams;const Param:TSString):TSInt32;
		function GetSymbolWidth(const Index:char):LongInt;inline;
		function LoadSF():TSBoolean;
			public
		function GetSymbolInfo(const VSymbol : TSChar):TSPoint2int32;inline;
		function Load():TSBoolean;override;
		function StringLength(const S:PChar ):LongWord;overload;
		function StringLength(const S:TSString ):LongWord;overload;
		function CursorPlace(const S : TSString; const Position : TSLongWord):TSUInt32;
		function Loaded() : TSBoolean; override;
			public
		property FontLoaded : TSBoolean read FFontLoaded;
		property FontHeight : TSByte read FFontHeight;
		property SymbolWidth[Index:char]:LongInt read GetSymbolWidth;
		property FontParams:TStringParams read FFontParams;
		property TextureParams:TStringParams read FTextureParams;
		property SymbolParams:TSSymbolParams read FSymbolParams;
			public
		procedure DrawFontFromTwoVertex2f(const S:PChar;const V1,V2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSByte = 2);overload;
		procedure DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSByte = 2);overload;
		procedure AddWaterString(const VString:String;const VImage:TSImage;const VType:LongWord = 0);
		procedure DrawFontFromTwoVertex2fAndColorList(const S : TSString; const VColorList : TSVertex4fList;const V1,V2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
		end;

procedure STranslateFont(const FontInWay, FontOutWay : TSString;const RunInConsole : TSBoolean = True);
procedure SKill(var Font : TSFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SCreateFontFromFile(const _Context : ISContext; const _FileName : TSString; const _LoadTexture : TSBoolean = False) : TSFont;

implementation

uses
	 Classes
	
	,SmoothMathUtils
	,SmoothResourceManager
	,SmoothStringUtils
	,SmoothStreamUtils
	,SmoothBitMap
	,SmoothLog
	,SmoothFileUtils
	,SmoothRenderBase
	;

function SCreateFontFromFile(const _Context : ISContext; const _FileName : TSString; const _LoadTexture : TSBoolean = False) : TSFont;
begin
Result := TSFont.Create(_FileName);
Result.Context := _Context;
Result.Load();
if (_LoadTexture) then
	Result.LoadTexture();
end;

procedure SKill(var Font : TSFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Font <> nil then
	begin
	Font.Destroy();
	Font := nil;
	end;
end;

function TSFont.LoadSF():TSBoolean;
var
	Stream         : TMemoryStream = nil;
	Quantity       : TSFontInt;
	ColorBits      : TSByte;
	QuantityColors : TSWord;
	ArColors       : packed array of TSByte = nil;
	ColorBitMap    : PByte = nil;
	Mask           : TSByte = 0;
function GetColor(const Index : TSMaxEnum):TSByte;
var
	m : TSByte;
	d : TSMaxEnum;
begin
Result:=0;
m:=Index*ColorBits mod 8;
d:=Index*ColorBits div 8;
Result := Mask and (ColorBitMap[d] shr m);
if m+ColorBits>8 then
	Result:= Result or ((ColorBitMap[d+1] shl (8-m)) and Mask);
//SLog.Source(['Index=',Index,', Result=',Result]);
end;

procedure CalcucateBitMap();
var
	i      : TSMaxEnum;
begin
FBitMap.ReAllocateMemory();
Mask := 0;
for i:=0 to ColorBits-1 do
	Mask += 2**i;
for i:=0 to Width*Height-1 do
	begin
	FBitMap.Data[i*FBitMap.Channels+0]:=255;
	FBitMap.Data[i*FBitMap.Channels+1]:=255;
	FBitMap.Data[i*FBitMap.Channels+2]:=255;
	FBitMap.Data[i*FBitMap.Channels+3]:=ArColors[GetColor(i)];
	end;
end;

function CheckHeader():TSBoolean;
var
	C1,C2:Char;
begin
Stream.ReadBuffer(C1,1);
Stream.ReadBuffer(C2,1);
Result:=(C1+C2)='SF';
end;

var
	i:TSMaxEnum;
begin
Result:=False;
Stream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(Stream, FFileName);
Stream.Position:=0;
if Stream.Size=0 then
	begin
	Stream.Destroy();
	Exit;
	end;
if not CheckHeader() then
	begin
	Stream.Destroy();
	Exit;
	end;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FTextureParams,Quantity);
for i:=0 to Quantity-1 do
	begin
	FTextureParams[i][0]:=SReadStringFromStream(Stream);
	FTextureParams[i][1]:=SReadStringFromStream(Stream);
	end;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FFontParams,Quantity);
for i:=0 to Quantity-1 do
	begin
	FFontParams[i][0]:=SReadStringFromStream(Stream);
	FFontParams[i][1]:=SReadStringFromStream(Stream);
	end;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
ColorBits:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
QuantityColors:=Quantity;
SetLength(ArColors,QuantityColors);
Stream.ReadBuffer(ArColors[0],QuantityColors);
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FFontHeight:=Quantity;
SKill(FBitMap);
FBitMap :=TSBitMap.Create();
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FBitMap.Width:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FBitMap.Height:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FBitMap.Channels:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FBitMap.ChannelSize:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
//FBitMap.PixelFormat:=Quantity; // deprecated
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
//FBitMap.PixelType:=Quantity; // deprecated
Stream.ReadBuffer(FSymbolParams,SizeOf(FSymbolParams));
GetMem(ColorBitMap,ColorBits*Width*Height div 8);
Stream.ReadBuffer(ColorBitMap^,ColorBits*Width*Height div 8);
SKill(Stream);
CalcucateBitMap();
SKill(ColorBitMap);
SetLength(ArColors,0);
Result:=True;
FLoadedIntoRAM := True;
FFontLoaded := True;
end;

function TSFont.GetSymbolInfo(const VSymbol:Char):TSPoint2int32;inline;
begin
Result.Import(FSymbolParams[VSymbol].x,FSymbolParams[VSymbol].y);
end;

function TSFont.GetSymbolWidth(const Index:char):LongInt;inline;
begin
Result:=FSymbolParams[Index].Width;
end;

procedure TSFont.DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	P:PChar;
begin
if Length(S) > 0 then
	begin
	P:=SStringToPChar(S);
	DrawFontFromTwoVertex2f(P,Vertex1,Vertex2,AutoXShift,AutoYShift);
	FreeMem(P,SPCharLength(P)+1);
	end;
end;

procedure TSFont.DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSByte = 2);overload;
var
	P:PChar;
begin
P:=SStringToPChar(S);
DrawCursorFromTwoVertex2f(P,CursorPosition,Vertex1,Vertex2,AutoXShift,AutoYShift,CursorWidth);
FreeMem(P,SPCharLength(P)+1);
end;

function TSFont.Loaded() : TSBoolean;
begin
Result:= (inherited Loaded()) and FontLoaded;
end;

class function TSFont.GetLongInt(var Params:TStringParams;const Param:string):LongInt;
var
	i:LongInt;
begin
Result:=0;
for i:=Low(Params) to High(Params) do
	begin
	if Params[i][0]=Param then
		begin
		Val(Params[i][1],Result);
		Break;
		end;
	end;
end;

function TSFont.LoadFont(const _FontFileName : TSString) : TSBoolean;
var
	f:TextFile;
	Identificator:string = '';
	C:Char = ' ';
	C2:char = ' ';

procedure LoadParams(var Params:TStringParams);
begin
while not eoln(f) do
	begin
	SetLength(Params,Length(Params)+1);
	Params[High(Params)][0]:='';
	Params[High(Params)][1]:='';
	C:=' ';
	while C<>'=' do
		begin
		Read(f,C);
		if C<>'=' then
			begin
			Params[High(Params)][0]+=C;
			end;
		end;
	ReadLn(f,Params[High(Params)][1]);
	end;
end;

function GetString(const S:String;const P1,P2:LongInt):String;
var
	i:LongInt;
begin
Result:='';
for i:=P1 to P2 do
	Result+=S[i];
end;

procedure LoadSymbol(S:String;var Obj:TSSymbolParam);
var
	LastPosition:LongInt = 1;
	Position:LongInt = 1;
	I:LongInt = 0;
begin
while (S[Position]<>',')and(Position<=Length(s)) do
	Position+=1;
Position-=1;
Val(GetString(S,LastPosition,Position),I);
Position:=Position+2;
LastPosition:=Position;
Obj.X:=i;

while (S[Position]<>',')and(Position<=Length(s)) do
	Position+=1;
Position-=1;
Val(GetString(S,LastPosition,Position),I);
Position:=Position+2;
LastPosition:=Position;
Obj.Y:=i;

while (S[Position]<>',')and(Position<Length(s)) do
	Position+=1;
Val(GetString(S,LastPosition,Position),I);
Obj.Width:=i;
end;

begin
Result := False;
Assign(f, _FontFileName);
Reset(f);
while not eof(f) do
	begin
	Read(f,C);
	Identificator:='';
	repeat
	if (c<>' ') and (c<>';') then
		begin
		Identificator+=UpCase(c);
		end;
	Read(f,C);
	until (c='(') or (c=':');
	ReadLn(f);
	if (Identificator='FONTPARAMS') then
		LoadParams(FFontParams);
	if (Identificator='TEXTUREPARAMS') then
		LoadParams(FTextureParams);
	if Identificator='SIMBOLPARAMS' then
		begin
		while not eoln(f) do
			begin
			Identificator:='';
			Read(f,C2);
			Read(f,C);
			ReadLn(f,Identificator);
			LoadSymbol(Identificator,FSymbolParams[C2]);
			end;
		Identificator:='';
		end;
	ReadLn(f);
	end;
Close(f);
FFontHeight := GetLongInt(FFontParams, 'Height');
FFontLoaded := True;
Result := True;
end;

function TSFont.Load():TSBoolean;
var
	FontTxt : TSString;
	Index, Index2 : TSMaxEnum;
begin
Result := False;
if SFileExtension(FFileName, True) = 'SF' then
	Result := LoadSF()
else if inherited Load() then
	begin
	FontTxt := SFileNameWithoutExtension(FFileName) + '.txt';
	if SFileExists(FontTxt) then
		Result := LoadFont(FontTxt);
	end;
end;

class function TSFont.ClassName() : TSString;
begin
Result := 'TSFont';
end;

constructor TSFont.Create(const VFileName : TSString = '');
begin
inherited Create(VFileName);
FFontLoaded    := False;
FFontParams    := nil;
FTextureParams := nil;
end;

destructor TSFont.Destroy;
begin
inherited;
end;

procedure TSFont.DrawFontFromTwoVertex2fAndColorList(const S : TSString; const VColorList : TSVertex4fList;const V1,V2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
var
	i:LongInt;
	StringWidth : LongInt = 0;
	Otstup:TSVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
	ThisSymbolWidth:LongWord = 0;
	DirectXShift : TSVertex2f;
	RealStringWidth, RealStringHeight : TSSingle;
	Vertex1, Vertex2 : TSVertex2f;
begin
Vertex1 := V1;
Vertex2 := V2;
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then
	begin
	if Context.Fullscreen then
		DirectXShift.Import(0.5, 0.5)
	else
		DirectXShift.Import(0.4, 0.3);
	end
else
	begin
	DirectXShift.Import(0, 0);
	end;
BindTexture();
StringWidth := StringLength(S);
RealStringWidth := Abs(Vertex2.x - Vertex1.x);
RealStringHeight := Abs(Vertex2.y - Vertex1.y);
if AutoXShift then
	begin
	Otstup.x:=(RealStringWidth - StringWidth)/2;
	if Otstup.x < 0 then
		Otstup.x := 0;
	end;
if AutoYShift then
	begin
	Otstup.y:=(RealStringHeight - FFontHeight)/2;
	end;
Otstup := Otstup.Round();
Vertex1 := Vertex1.Round();
Vertex2 := Vertex2.Round();
Render.BeginScene(SR_QUADS);
i := 1;
while (i <= Length(S)) and (not ToExit) do
	begin
	Render.Color(VColorList[i-1]);
	if s[i] <> '	' then
		begin
		ThisSymbolWidth := FSymbolParams[s[i]].Width;
		if Otstup.x + FSymbolParams[s[i]].Width > RealStringWidth then
			begin
			ToExit := True;
			ThisSymbolWidth := Trunc(RealStringWidth - Otstup.x);
			end;

		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x,
			Otstup.y + Vertex1.y);
		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x + ThisSymbolWidth)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x + ThisSymbolWidth,
			Otstup.y + Vertex1.y);
		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x + ThisSymbolWidth)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y + FFontHeight)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x + ThisSymbolWidth,
			Otstup.y + Vertex1.y + FFontHeight);
		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y + FFontHeight)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x,
			Otstup.y + Vertex1.y + FFontHeight);

		Otstup.x += FSymbolParams[s[i]].Width;
		end
	else
		Otstup.x += FSymbolParams[' '].Width * 4;
	i+=1;
	end;
Render.EndScene();
DisableTexture();
end;

procedure TSFont.DrawFontFromTwoVertex2f(const S:PChar;const V1,V2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	i:LongInt = 0;
	StringWidth : LongInt = 0;
	Otstup:TSVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
	ThisSymbolWidth:LongWord = 0;
	DirectXShift : TSVertex2f;
	RealStringWidth, RealStringHeight : TSSingle;
	Vertex1, Vertex2 : TSVertex2f;
begin
if (not RenderAssigned()) then
	exit;
Vertex1 := V1;
Vertex2 := V2;
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then
	begin
	if Context.Fullscreen then
		DirectXShift.Import(0.5, 0.5)
	else
		DirectXShift.Import(0.4, 0.3);
	end
else
	begin
	DirectXShift.Import(0, 0);
	end;
BindTexture();
StringWidth := StringLength(S);
RealStringWidth := Abs(Vertex2.x - Vertex1.x);
RealStringHeight := Abs(Vertex2.y - Vertex1.y);
if AutoXShift then
	begin
	Otstup.x:=(RealStringWidth - StringWidth)/2;
	if Otstup.x < 0 then
		Otstup.x := 0;
	end;
if AutoYShift then
	begin
	Otstup.y:=(RealStringHeight - FFontHeight)/2;
	end;
Otstup := Otstup.Round();
Vertex1 := Vertex1.Round();
Vertex2 := Vertex2.Round();
Render.BeginScene(SR_QUADS);
while (s[i]<>#0) and (not ToExit) do
	begin
	if s[i] <> '	' then
		begin
		ThisSymbolWidth := FSymbolParams[s[i]].Width;
		if Otstup.x + FSymbolParams[s[i]].Width > RealStringWidth then
			begin
			ToExit := True;
			ThisSymbolWidth := Trunc(RealStringWidth - Otstup.x);
			end;

		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x,
			Otstup.y + Vertex1.y);
		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x + ThisSymbolWidth)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x + ThisSymbolWidth,
			Otstup.y + Vertex1.y);
		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x + ThisSymbolWidth)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y + FFontHeight)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x + ThisSymbolWidth,
			Otstup.y + Vertex1.y + FFontHeight);
		Render.TexCoord2f(
				 (Self.FSymbolParams[s[i]].x + DirectXShift.x)/Self.Width,
			1 - ((Self.FSymbolParams[s[i]].y + DirectXShift.y + FFontHeight)/Self.Height));
		Render.Vertex2f(
			Otstup.x + Vertex1.x,
			Otstup.y + Vertex1.y + FFontHeight);

		Otstup.x += FSymbolParams[s[i]].Width;
		end
	else
		Otstup.x += FSymbolParams[' '].Width * 4;
	i+=1;
	end;
Render.EndScene();
DisableTexture();
end;

function TSFont.StringLength(const S : PChar) : TSLongWord;overload;
var
	i : TSLongWord;
begin
if S = nil then
	begin
	Result:=0;
	Exit;
	end;
Result:=0;
i:=0;
while s[i]<>#0 do
	begin
	if s[i] = '	' then
		Result += FSymbolParams[' '].Width * 4
	else
		Result+=FSymbolParams[s[i]].Width;
	i+=1;
	end;
end;

function TSFont.CursorPlace(const S : TSString; const Position : TSLongWord):TSLongWord;
var
	y, oldy, i : TSLongWord;
	Placed : TSBoolean = False;
begin
Result := 0;
y := 0;
oldy := 0;
for i:= 1 to Length(S) do
	begin
	if s[i] = '	' then
		y += FSymbolParams[' '].Width * 4
	else
		y += FSymbolParams[s[i]].Width;
	if (Position >= oldy) and (Position <= y) then
		begin
		Placed := True;
		if (Position - oldy) < (y - Position) then
			Result := i - 1
		else
			Result := i;
		break;
		end;
	oldy := y;
	end;
if not Placed then
	Result := Length(S);
end;

function TSFont.StringLength(const S : TSString) : TSLongWord;overload;
var
	i : TSLongWord;
begin
Result:=0;
for i:=1 to Length(S) do
	begin
	if s[i] = '	' then
		Result += FSymbolParams[' '].Width * 4
	else
		Result += FSymbolParams[s[i]].Width;
	end;
end;

procedure TSFont.AddWaterString(const VString:String;const VImage:TSImage;const VType:LongWord = 0);
var
	PBits:PSPixel3b;
	StrL:TSUInt32;
	PW,PH:TSUInt32;
	i:TSUInt32;
	PFontBits:PSPixel4b;
	iw,ih:TSUInt32;
	SI:TSPoint2int32;

procedure Invert(const a,b:TSMaxEnum);inline;
begin
PBits[a].r:=trunc(PBits[a].r*(255-PFontBits[b].a)/255+(255-PBits[a].r)*(PFontBits[b].a)/255);
PBits[a].g:=trunc(PBits[a].g*(255-PFontBits[b].a)/255+(255-PBits[a].g)*(PFontBits[b].a)/255);
PBits[a].b:=trunc(PBits[a].b*(255-PFontBits[b].a)/255+(255-PBits[a].b)*(PFontBits[b].a)/255);
end;

var
	SumR,SumG,SumB,Sum:TSMaxEnum;

procedure AddSum(const a,b:TSMaxEnum);inline;
begin
PBits[a].r:=trunc(PBits[a].r*(255-PFontBits[b].a)/255+(SumR)*(PFontBits[b].a)/255);
PBits[a].g:=trunc(PBits[a].g*(255-PFontBits[b].a)/255+(SumG)*(PFontBits[b].a)/255);
PBits[a].b:=trunc(PBits[a].b*(255-PFontBits[b].a)/255+(SumB)*(PFontBits[b].a)/255);
end;

var
	TempR:TSFloat64;
begin
if (Self=nil) or (not(FontLoaded)) then
	begin
	SLog.Source('TSFont__AddWaterString: Error: Font not loaded!');
	Exit;
	end
else if (not VImage.BitMapHasData()) or (not BitMapHasData()) or (VImage.BitMap.Channels<>3) or (FBitMap.Channels<>4) then
	begin
	SLog.Source('TSFont__AddWaterString: Error: Invalid parametrs!');
	Exit;
	end;
PBits:=PSPixel3b(VImage.BitMap.Data);
StrL:=StringLength(VString);
if (StrL>VImage.Width) or (FontHeight>VImage.Height) then
	begin
	SLog.Source('TSFont__AddWaterString : Error : for this image ('+SStr(VImage.Width)+','+SStr(VImage.Height)+') water string "'+VString+'" is not portable!');
	Exit;
	end;
PW:=VImage.Width-StrL-5;
PH:=VImage.Height-FontHeight-4;
PFontBits:=PSPixel4b(FBitMap.Data);
if VType=0 then
	begin
	SumB:=0;
	SumR:=0;
	Sum:=0;
	SumG:=0;
	for i:=1 to Length(VString) do
		begin
		SI:=GetSymbolInfo(VString[i]);
		for iw:=0 to SymbolWidth[VString[i]]-1 do
			begin
			for ih:=1 to FontHeight do
				begin
				Sum+=1;
				SumR+=PBits[VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width].r;
				SumG+=PBits[VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width].g;
				SumB+=PBits[VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width].b;
				end;
			end;
		PW+=SymbolWidth[VString[i]];
		end;
	SumR:=Trunc(SumR/Sum);
	SumG:=Trunc(SumG/Sum);
	SumB:=Trunc(SumB/Sum);
	SumR:=255-SumR;
	SumG:=255-SumG;
	SumB:=255-SumB;
	TempR:=sqrt(sqr(SumB)+sqr(SumG)+sqr(SumB));
	SumR:=round(255*SumR/TempR);
	SumG:=round(255*SumG/TempR);
	SumB:=round(255*SumB/TempR);
	PW:=VImage.Width-StrL-5;
	end;

for i:=1 to Length(VString) do
	begin
	SI:=GetSymbolInfo(VString[i]);
	for iw:=0 to SymbolWidth[VString[i]]-1 do
		for ih:=1 to FontHeight do
			begin
			case VType of
			0:
				begin
				AddSum(
					VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width,
					Width*Height+(SI.x+iw)-(SI.y+ih)*Width);
				end;
			else
				Invert(
					VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width,
					Width*Height+(SI.x+iw)-(SI.y+ih)*Width);
			end;
			end;
	PW+=SymbolWidth[VString[i]];
	end;
end;


procedure TSFont.DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:TSVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSByte = 2);overload;
var
	i:LongInt = 0;
	StringWidth:LongInt = 0;
	Otstup:TSVertex2f = (x:0;y:0);
begin
if AutoXShift then
	begin
	Otstup.x:=(Abs(Vertex2.x-Vertex1.x)-StringWidth)/2;
	if Otstup.x<0 then
		Otstup.x:=0;
	end;
if AutoYShift then
	begin
	Otstup.y:=(Abs(Vertex2.y-Vertex1.y)-FFontHeight)/2;
	end;

while (s[i]<>#0) and (CursorPosition > i) do
	begin
	if s[i] = '	' then
		Otstup.x := FSymbolParams[' '].Width * 4
	else
		Otstup.x += FSymbolParams[s[i]].Width;
	i+=1;
	end;
if Abs(Vertex1.x-Vertex2.x)>Otstup.x then
	begin
	if CursorWidth = 1 then
		begin
		Render.BeginScene(SR_LINES);
		Render.Vertex(Vertex1 + Otstup);
		Render.Vertex2f(Otstup.x+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
		Render.EndScene();
		end
	else
		begin
		Render.BeginScene(SR_QUADS);
		Render.Vertex2f(Otstup.x+Vertex1.x-CursorWidth/2,Otstup.y+Vertex1.y);
		Render.Vertex2f(Otstup.x+Vertex1.x+CursorWidth/2,Otstup.y+Vertex1.y);
		Render.Vertex2f(Otstup.x+Vertex1.x+CursorWidth/2,Otstup.y+FFontHeight+Vertex1.y);
		Render.Vertex2f(Otstup.x+Vertex1.x-CursorWidth/2,Otstup.y+FFontHeight+Vertex1.y);
		Render.EndScene();
		end;
	end;
end;

(*=== STranslateFont ===*)

procedure STranslateFont(const FontInWay, FontOutWay : TSString; const RunInConsole:TSBoolean = True);
var
	Font : TSFont = nil;
	BitMap : TSBitMapData = nil;
	Colors : array [0..255] of TSMaxEnum;
	ObrColors : array [0..255] of TSUInt8;
	TudaColors : array of TSUInt8 = nil;
	QuantityColors : TSUInt8 = 0;
	ColorBits : TSUInt8 = 0;
	ColorBitMap : TSBitMapData = nil;
var
	i,q : TSMaxEnum;
procedure WriteFileToStream();
var
	OutStream : TFileStream = nil;
	Header:packed record
		s,g,f:Char;
		end = (s:'S';g:'G';f:'F');
	Quantity:TSFontInt;
	SP:TSSymbolParams;
	i:TSLongWord;
begin
OutStream := TFileStream.Create(FontOutWay,fmCreate);
if OutStream = nil then
	begin
	SLog.Source(['STranslateFont : Can''t open file "',FontOutWay,'"']);
	Exit;
	end;
OutStream.WriteBuffer(Header,SizeOf(Header));
Quantity:=Length(Font.TextureParams);
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to High(Font.TextureParams) do
	begin
	SWriteStringToStream(Font.TextureParams[i][0],OutStream);
	SWriteStringToStream(Font.TextureParams[i][1],OutStream);
	end;
Quantity:=Length(Font.FontParams);
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to High(Font.FontParams) do
	begin
	SWriteStringToStream(Font.FontParams[i][0],OutStream);
	SWriteStringToStream(Font.FontParams[i][1],OutStream);
	end;
{if RunInConsole then
	begin
	SLog.Source(['STranslateFont : Writing info (ColorBits=',ColorBits,',QuantityColors=',QuantityColors,')']);
	SLog.Source(['STranslateFont : TudaColors=['],False);
	for i:=0 to High(TudaColors) do
		SLog.Source([TudaColors[i]],False);
	SLog.Source('].');
	end;}
Quantity:=ColorBits;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=QuantityColors;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
OutStream.WriteBuffer(TudaColors[0],QuantityColors);
Quantity:=Font.FontHeight;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=Font.Width;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=Font.Height;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=Font.BitMap.Channels;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=Font.BitMap.ChannelSize;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=0; // Font.BitMap.PixelFormat; // deprecated
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=0; // Font.BitMap.PixelType; // deprecated
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
SP:=Font.SymbolParams;
OutStream.WriteBuffer(SP,SizeOf(SP));
OutStream.WriteBuffer(ColorBitMap^,ColorBits*Font.Width*Font.Height div 8);
OutStream.Destroy();
end;

procedure SetColor(const Index : TSMaxEnum;const Number:TSUInt8);
var
	m: TSUInt8;
	d: TSMaxEnum;
begin
m:=(Index*ColorBits) mod 8;
d:=(Index*ColorBits) div 8;
ColorBitMap[d] := 255 and (ColorBitMap[d] or (Number shl m));
if m+ColorBits>8 then
	begin
	ColorBitMap[d+1] := 255 and (ColorBitMap[d+1] or (Number shr (8-m)));
	end;
end;

begin
Fillchar(Colors,SizeOf(Colors),0);
if RunInConsole then
	SLog.Source(['STranslateFont : Translete "',FontInWay,'" to "',FontOutWay,'".']);
Font := TSFont.Create(FontInWay);
if Font.Load() then
	if RunInConsole then
		SLog.Source(['STranslateFont : Font loaded!'])
	else
else
	begin
	if RunInConsole then
		SLog.Source(['STranslateFont : While loading font exeption error!']);
	Exit;
	end;
if (Font.BitMap.Channels <> 4) then
	begin
	if RunInConsole then
		SLog.Source(['STranslateFont : (Font.Channels!=4), exiting!']);
	Exit;
	end;
BitMap := Font.BitMap.Data;
q:=0;
Fillchar(Colors,SizeOf(Colors),0);
for i:=0 to Font.Width*Font.Height*Font.BitMap.Channels-1 do
	begin
	Colors[BitMap[i]]+=1;
	case BitMap[i] of
	0,255:;
	else
		q+=1;
	end;
	end;
if RunInConsole then
	begin
	SLog.Source(['STranslateFont : Font : Total [1..254] variables quantyti : "',q,'" of "'+SStr(Font.Width*Font.Height*Font.BitMap.Channels)+'" ('+SStrReal(q/(Font.Width*Font.Height*Font.BitMap.Channels)*100,2)+' per cent)!']);
	for i:=0 to 255 do
		if Colors[i]<>0 then
			begin
			SLog.Source(['STranslateFont : Colors[',i,']="',Colors[i],'".']);
			end;
	end;
q:=0;
for i:=0 to Font.Width*Font.Height-1 do
	begin
	if (BitMap[i*Font.BitMap.Channels+0]<>255) then q+=1;
	if (BitMap[i*Font.BitMap.Channels+1]<>255) then q+=1;
	if (BitMap[i*Font.BitMap.Channels+2]<>255) then q+=1;
	end;
if RunInConsole then
	begin
	SLog.Source(['STranslateFont : Font : RGB [0..254] variables quantyti : "',q,'" of "'+SStr(Font.Width*Font.Height*3)+'" ('+SStrReal(q/(Font.Width*Font.Height*3)*100,2)+' per cent)!']);
	end;
if q<>0 then
	Exit;
Fillchar(Colors,SizeOf(Colors),0);
Fillchar(ObrColors,SizeOf(ObrColors),0);
for i:=0 to Font.Width*Font.Height-1 do
	begin
	Colors[BitMap[i*Font.BitMap.Channels+3]]+=1;
	end;
SetLength(TudaColors,0);
for i:=0 to 255 do
	if Colors[i]<>0 then
		begin
		ObrColors[i]:=QuantityColors;
		SetLength(TudaColors,Length(TudaColors)+1);
		TudaColors[High(TudaColors)]:=i;
		QuantityColors+=1;
		end;
if RunInConsole then
	begin
	SLog.Source(['STranslateFont : Font : Quantity colors = "',QuantityColors,'"!']);
	for i:=0 to 255 do
		if Colors[i]<>0 then
			begin
			SLog.Source(['STranslateFont : Colors[',i,']="',Colors[i],'" ('+SStrReal(Colors[i]/(Font.Width*Font.Height)*100,2)+' per cent).']);
			end;
	end;
ColorBits:=0;
while QuantityColors>2**ColorBits do
	ColorBits+=1;
if RunInConsole then
	begin
	SLog.Source(['STranslateFont : Color bits = "',ColorBits,'"']);
	end;
GetMem(ColorBitMap,ColorBits*Font.Width*Font.Height div 8);
Fillchar(ColorBitMap^,ColorBits*Font.Width*Font.Height div 8,0);
if RunInConsole then
	begin
	SLog.Source(['STranslateFont : Sizeof color bit map = "',ColorBits*Font.Width*Font.Height div 8,'" (',ColorBits*Font.Width*Font.Height mod 8,')']);
	end;
for i:=0 to Font.Width*Font.Height-1 do
	begin
	SetColor(i,ObrColors[BitMap[i*Font.BitMap.Channels+3]]);
	end;
WriteFileToStream();
SKill(ColorBitMap);
SKill(Font);
if TudaColors<>nil then
	SetLength(TudaColors,0);
end;

end.
