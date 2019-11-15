{$INCLUDE SaGe.inc}

unit SaGeFont;

interface

uses
	 SaGeBase
	,SaGeImage
	,SaGeBitMapBase
	,SaGeCommonStructs
	,SaGeContextInterface
	;

type
	TSGFont = class;
	TSGFontInt = TSGUInt32;
	TSGSymbolParamType = TSGUInt16;
	
	TStringParams=packed array of packed array [0..1] of TSGString;
	
	TSGSymbolParam = object
		X, Y, Width : TSGSymbolParamType;
		end;
	
	TSGSymbolParams = packed array[#0..#255] of TSGSymbolParam;
	
	TSGFont = class(TSGImage)
			public
		constructor Create(const VFileName : TSGString = '');
		class function ClassName() : TSGString; override;
		destructor Destroy();override;
			protected
		FSymbolParams : TSGSymbolParams;
		FFontParams : TStringParams;
		FTextureParams : TStringParams;
		FFontLoaded  : TSGBoolean;
		FFontHeight : TSGUInt8;
		procedure LoadFont(const FontWay : TSGString);
		class function GetLongInt(var Params:TStringParams;const Param:TSGString):TSGInt32;
		function GetSymbolWidth(const Index:char):LongInt;inline;
		function LoadSGF():TSGBoolean;
			public
		function GetSymbolInfo(const VSymbol : TSGChar):TSGPoint2int32;inline;
		function Load():TSGBoolean;override;
		function StringLength(const S:PChar ):LongWord;overload;
		function StringLength(const S:TSGString ):LongWord;overload;
		function CursorPlace(const S : TSGString; const Position : TSGLongWord):TSGUInt32;
		function Loaded() : TSGBoolean; override;
			public
		property FontLoaded : TSGBoolean read FFontLoaded;
		property FontHeight : TSGByte read FFontHeight;
		property SymbolWidth[Index:char]:LongInt read GetSymbolWidth;
		property FontParams:TStringParams read FFontParams;
		property TextureParams:TStringParams read FTextureParams;
		property SymbolParams:TSGSymbolParams read FSymbolParams;
			public
		procedure DrawFontFromTwoVertex2f(const S:PChar;const V1,V2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSGByte = 2);overload;
		procedure DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSGByte = 2);overload;
		procedure AddWaterString(const VString:String;const VImage:TSGImage;const VType:LongWord = 0);
		procedure DrawFontFromTwoVertex2fAndColorList(const S : TSGString; const VColorList : TSGVertex4fList;const V1,V2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
		end;

procedure SGTranslateFont(const FontInWay, FontOutWay : TSGString;const RunInConsole : TSGBoolean = True);
procedure SGKill(var Font : TSGFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SGCreateFontFromFile(const _Context : ISGContext; const _FileName : TSGString; const _LoadTexture : TSGBoolean = False) : TSGFont;

implementation

uses
	 Classes
	
	,SaGeMathUtils
	,SaGeResourceManager
	,SaGeStringUtils
	,SaGeStreamUtils
	,SaGeBitMap
	,SaGeLog
	,SaGeFileUtils
	,SaGeRenderBase
	;

function SGCreateFontFromFile(const _Context : ISGContext; const _FileName : TSGString; const _LoadTexture : TSGBoolean = False) : TSGFont;
begin
Result := TSGFont.Create(_FileName);
Result.Context := _Context;
Result.Load();
if (_LoadTexture) then
	Result.ToTexture();
end;

procedure SGKill(var Font : TSGFont); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Font <> nil then
	begin
	Font.Destroy();
	Font := nil;
	end;
end;

function TSGFont.LoadSGF():TSGBoolean;
var
	Stream         : TMemoryStream = nil;
	Quantity       : TSGFontInt;
	ColorBits      : TSGByte;
	QuantityColors : TSGWord;
	ArColors       : packed array of TSGByte = nil;
	ColorBitMap    : PByte = nil;
	Mask           : TSGByte = 0;
function GetColor(const Index : TSGMaxEnum):TSGByte;
var
	m : TSGByte;
	d : TSGMaxEnum;
begin
Result:=0;
m:=Index*ColorBits mod 8;
d:=Index*ColorBits div 8;
Result := Mask and (ColorBitMap[d] shr m);
if m+ColorBits>8 then
	Result:= Result or ((ColorBitMap[d+1] shl (8-m)) and Mask);
//SGLog.Source(['Index=',Index,', Result=',Result]);
end;

procedure CalcucateBitMap();
var
	i      : TSGMaxEnum;
	BitMap : PByte;
begin
GetMem(BitMap,Width*Height*Channels);
FImage.BitMap := BitMap;
Mask := 0;
for i:=0 to ColorBits-1 do
	Mask += 2**i;
for i:=0 to Width*Height-1 do
	begin
	BitMap[i*Channels+0]:=255;
	BitMap[i*Channels+1]:=255;
	BitMap[i*Channels+2]:=255;
	BitMap[i*Channels+3]:=ArColors[GetColor(i)];
	end;
end;

function ValidateHeader():TSGBoolean;
var
	C1,C2,C3:Char;
begin
Stream.ReadBuffer(C1,1);
Stream.ReadBuffer(C2,1);
Stream.ReadBuffer(C3,1);
Result:=(C1+C2+C3)='SGF';
end;

var
	i:TSGMaxEnum;
begin
Result:=False;
Stream := TMemoryStream.Create();
SGResourceFiles.LoadMemoryStreamFromFile(Stream, FFileName);
Stream.Position:=0;
if Stream.Size=0 then
	begin
	Stream.Destroy();
	Exit;
	end;
if not ValidateHeader() then
	begin
	Stream.Destroy();
	Exit;
	end;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FTextureParams,Quantity);
for i:=0 to Quantity-1 do
	begin
	FTextureParams[i][0]:=SGReadStringFromStream(Stream);
	FTextureParams[i][1]:=SGReadStringFromStream(Stream);
	end;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
SetLength(FFontParams,Quantity);
for i:=0 to Quantity-1 do
	begin
	FFontParams[i][0]:=SGReadStringFromStream(Stream);
	FFontParams[i][1]:=SGReadStringFromStream(Stream);
	end;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
ColorBits:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
QuantityColors:=Quantity;
SetLength(ArColors,QuantityColors);
Stream.ReadBuffer(ArColors[0],QuantityColors);
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FFontHeight:=Quantity;
if FImage<>nil then
	FImage.Destroy();
FImage:=TSGBitMap.Create();
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FImage.Width:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FImage.Height:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FImage.Channels:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FImage.BitDepth:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FImage.PixelFormat:=Quantity;
Stream.ReadBuffer(Quantity,SizeOf(Quantity));
FImage.PixelType:=Quantity;
Stream.ReadBuffer(FSymbolParams,SizeOf(FSymbolParams));
GetMem(ColorBitMap,ColorBits*Width*Height div 8);
Stream.ReadBuffer(ColorBitMap^,ColorBits*Width*Height div 8);
Stream.Destroy();
Stream:=nil;
CalcucateBitMap();
FreeMem(ColorBitMap,ColorBits*Width*Height div 8);
SetLength(ArColors,0);
Result:=True;
FLoadedIntoRAM := True;
FFontLoaded := True;
end;

function TSGFont.GetSymbolInfo(const VSymbol:Char):TSGPoint2int32;inline;
begin
Result.Import(FSymbolParams[VSymbol].x,FSymbolParams[VSymbol].y);
end;

function TSGFont.GetSymbolWidth(const Index:char):LongInt;inline;
begin
Result:=FSymbolParams[Index].Width;
end;

procedure TSGFont.DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	P:PChar;
begin
if Length(S) > 0 then
	begin
	P:=SGStringToPChar(S);
	DrawFontFromTwoVertex2f(P,Vertex1,Vertex2,AutoXShift,AutoYShift);
	FreeMem(P,SGPCharLength(P)+1);
	end;
end;

procedure TSGFont.DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSGByte = 2);overload;
var
	P:PChar;
begin
P:=SGStringToPChar(S);
DrawCursorFromTwoVertex2f(P,CursorPosition,Vertex1,Vertex2,AutoXShift,AutoYShift,CursorWidth);
FreeMem(P,SGPCharLength(P)+1);
end;

function TSGFont.Loaded() : TSGBoolean;
begin
Result:= (inherited Loaded()) and FontLoaded;
end;

class function TSGFont.GetLongInt(var Params:TStringParams;const Param:string):LongInt;
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

procedure TSGFont.LoadFont(const FontWay:string);
var
	Fail:TextFile;
	Identificator:string = '';
	C:Char = ' ';
	C2:char = ' ';

procedure LoadParams(var Params:TStringParams);
begin
while not eoln(Fail) do
	begin
	SetLength(Params,Length(Params)+1);
	Params[High(Params)][0]:='';
	Params[High(Params)][1]:='';
	C:=' ';
	while C<>'=' do
		begin
		Read(Fail,C);
		if C<>'=' then
			begin
			Params[High(Params)][0]+=C;
			end;
		end;
	ReadLn(Fail,Params[High(Params)][1]);
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

procedure LoadSymbol(S:String;var Obj:TSGSymbolParam);
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
Assign(Fail,FontWay);
Reset(Fail);
while not eof(Fail) do
	begin
	Read(Fail,C);
	Identificator:='';
	repeat
	if (c<>' ') and (c<>';') then
		begin
		Identificator+=UpCase(c);
		end;
	Read(Fail,C);
	until (c='(') or (c=':');
	ReadLn(Fail);
	if (Identificator='FONTPARAMS') then
		LoadParams(FFontParams);
	if (Identificator='TEXTUREPARAMS') then
		LoadParams(FTextureParams);
	if Identificator='SIMBOLPARAMS' then
		begin
		while not eoln(Fail) do
			begin
			Identificator:='';
			Read(Fail,C2);
			Read(Fail,C);
			ReadLn(Fail,Identificator);
			LoadSymbol(Identificator,FSymbolParams[C2]);
			end;
		Identificator:='';
		end;
	ReadLn(Fail);
	end;
Close(Fail);
FFontHeight := GetLongInt(FFontParams, 'Height');
FFontLoaded := True;
end;

function TSGFont.Load():TSGBoolean;
var
	FontWay:string = '';
	i:LongInt = 0;
	ii:LongInt = 0;
begin
if SGFileExpansion(FFileName)='SGF' then
	begin
	Result := LoadSGF();
	Exit;
	end;
Result:=inherited Load();
if not Result then
	Exit;
i:=Length(FFileName);
while (FFileName[i]<>'.')and(FFileName[i]<>'/')and(i>0)do
	i-=1;
if (i>0)and (FFileName[i]='.') then
	begin
	for ii:=1 to i do
		FontWay+=FFileName[ii];
	FontWay+='txt';
	if SGFileExists(FontWay) then
		begin
		LoadFont(FontWay);
		end;
	end;
end;

class function TSGFont.ClassName() : TSGString;
begin
Result := 'TSGFont';
end;

constructor TSGFont.Create(const VFileName : TSGString = '');
begin
inherited Create(VFileName);
FFontLoaded    := False;
FFontParams    := nil;
FTextureParams := nil;
end;

destructor TSGFont.Destroy;
begin
inherited;
end;

procedure TSGFont.DrawFontFromTwoVertex2fAndColorList(const S : TSGString; const VColorList : TSGVertex4fList;const V1,V2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
var
	i:LongInt;
	StringWidth : LongInt = 0;
	Otstup:TSGVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
	ThisSymbolWidth:LongWord = 0;
	DirectXShift : TSGVertex2f;
	RealStringWidth, RealStringHeight : TSGSingle;
	Vertex1, Vertex2 : TSGVertex2f;
begin
Vertex1 := V1;
Vertex2 := V2;
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then
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
Render.BeginScene(SGR_QUADS);
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

procedure TSGFont.DrawFontFromTwoVertex2f(const S:PChar;const V1,V2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	i:LongInt = 0;
	StringWidth : LongInt = 0;
	Otstup:TSGVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
	ThisSymbolWidth:LongWord = 0;
	DirectXShift : TSGVertex2f;
	RealStringWidth, RealStringHeight : TSGSingle;
	Vertex1, Vertex2 : TSGVertex2f;
begin
if (not RenderAssigned()) then
	exit;
Vertex1 := V1;
Vertex2 := V2;
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then
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
Render.BeginScene(SGR_QUADS);
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

function TSGFont.StringLength(const S : PChar) : TSGLongWord;overload;
var
	i : TSGLongWord;
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

function TSGFont.CursorPlace(const S : TSGString; const Position : TSGLongWord):TSGLongWord;
var
	y, oldy, i : TSGLongWord;
	Placed : TSGBoolean = False;
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

function TSGFont.StringLength(const S : TSGString) : TSGLongWord;overload;
var
	i : TSGLongWord;
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

procedure TSGFont.AddWaterString(const VString:String;const VImage:TSGImage;const VType:LongWord = 0);
var
	PBits:PSGPixel3b;
	StrL:LongWord;
	PW,PH:LongWord;
	i:LongWord;
	PFontBits:PSGPixel4b;
	iw,ih:LongWord;
	SI:TSGPoint2int32;

procedure Invert(const a,b:TSGMaxEnum);inline;
begin
PBits[a].r:=trunc(PBits[a].r*(255-PFontBits[b].a)/255+(255-PBits[a].r)*(PFontBits[b].a)/255);
PBits[a].g:=trunc(PBits[a].g*(255-PFontBits[b].a)/255+(255-PBits[a].g)*(PFontBits[b].a)/255);
PBits[a].b:=trunc(PBits[a].b*(255-PFontBits[b].a)/255+(255-PBits[a].b)*(PFontBits[b].a)/255);
end;

var
	SumR,SumG,SumB,Sum:TSGMaxEnum;

procedure AddSum(const a,b:TSGMaxEnum);inline;
begin
PBits[a].r:=trunc(PBits[a].r*(255-PFontBits[b].a)/255+(SumR)*(PFontBits[b].a)/255);
PBits[a].g:=trunc(PBits[a].g*(255-PFontBits[b].a)/255+(SumG)*(PFontBits[b].a)/255);
PBits[a].b:=trunc(PBits[a].b*(255-PFontBits[b].a)/255+(SumB)*(PFontBits[b].a)/255);
end;

var
	TempR:real;
begin
if (Self=nil) or (not(FontLoaded)) then
	begin
	SGLog.Source('TSGFont__AddWaterString : Error : Font not loaded!');
	Exit;
	end;
if (VImage.Image=nil) or (VImage.Channels<>3) or (Channels<>4) or (Image=nil)or (Image.BitMap=nil) then
	begin
	SGLog.Source('TSGFont__AddWaterString : Error : Invalid arametrs!');
	Exit;
	end;
PBits:=PSGPixel3b(VImage.Image.BitMap);
StrL:=StringLength(VString);
if (StrL>VImage.Width) or (FontHeight>VImage.Height) then
	begin
	SGLog.Source('TSGFont__AddWaterString : Error : for this image ('+SGStr(VImage.Width)+','+SGStr(VImage.Height)+') water string "'+VString+'" is not portable!');
	Exit;
	end;
PW:=VImage.Width-StrL-5;
PH:=VImage.Height-FontHeight-4;
PFontBits:=PSGPixel4b(FImage.BitMap);
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


procedure TSGFont.DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:TSGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True;const CursorWidth : TSGByte = 2);overload;
var
	i:LongInt = 0;
	StringWidth:LongInt = 0;
	Otstup:TSGVertex2f = (x:0;y:0);
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
		Render.BeginScene(SGR_LINES);
		Render.Vertex(Vertex1 + Otstup);
		Render.Vertex2f(Otstup.x+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
		Render.EndScene();
		end
	else
		begin
		Render.BeginScene(SGR_QUADS);
		Render.Vertex2f(Otstup.x+Vertex1.x-CursorWidth/2,Otstup.y+Vertex1.y);
		Render.Vertex2f(Otstup.x+Vertex1.x+CursorWidth/2,Otstup.y+Vertex1.y);
		Render.Vertex2f(Otstup.x+Vertex1.x+CursorWidth/2,Otstup.y+FFontHeight+Vertex1.y);
		Render.Vertex2f(Otstup.x+Vertex1.x-CursorWidth/2,Otstup.y+FFontHeight+Vertex1.y);
		Render.EndScene();
		end;
	end;
end;

(*=== SGTranslateFont ===*)

procedure SGTranslateFont(const FontInWay,FontOutWay : TSGString;const RunInConsole:TSGBoolean = True);
var
	Font:TSGFont = nil;
	BitMap:PByte = nil;
	Colors : array [0..255] of TSGMaxEnum;
	ObrColors : array [0..255] of Byte;
	TudaColors : array of byte = nil;
	QuantityColors : Byte = 0;
	ColorBits : Byte = 0;
	ColorBitMap : PByte = nil;
var
	i,q : TSGMaxEnum;
procedure WriteFileToStream();
var
	OutStream : TFileStream = nil;
	Header:packed record
		s,g,f:Char;
		end = (s:'S';g:'G';f:'F');
	Quantity:TSGFontInt;
	SP:TSGSymbolParams;
	i:TSGLongWord;
begin
OutStream := TFileStream.Create(FontOutWay,fmCreate);
if OutStream = nil then
	begin
	SGLog.Source(['SGTranslateFont : Can''t open file "',FontOutWay,'"']);
	Exit;
	end;
OutStream.WriteBuffer(Header,SizeOf(Header));
Quantity:=Length(Font.TextureParams);
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to High(Font.TextureParams) do
	begin
	SGWriteStringToStream(Font.TextureParams[i][0],OutStream);
	SGWriteStringToStream(Font.TextureParams[i][1],OutStream);
	end;
Quantity:=Length(Font.FontParams);
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
for i:=0 to High(Font.FontParams) do
	begin
	SGWriteStringToStream(Font.FontParams[i][0],OutStream);
	SGWriteStringToStream(Font.FontParams[i][1],OutStream);
	end;
{if RunInConsole then
	begin
	SGLog.Source(['SGTranslateFont : Writing info (ColorBits=',ColorBits,',QuantityColors=',QuantityColors,')']);
	SGLog.Source(['SGTranslateFont : TudaColors=['],False);
	for i:=0 to High(TudaColors) do
		SGLog.Source([TudaColors[i]],False);
	SGLog.Source('].');
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
Quantity:=Font.Channels;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=Font.Image.BitDepth;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=Font.Image.PixelFormat;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
Quantity:=Font.Image.PixelType;
OutStream.WriteBuffer(Quantity,SizeOf(Quantity));
SP:=Font.SymbolParams;
OutStream.WriteBuffer(SP,SizeOf(SP));
OutStream.WriteBuffer(ColorBitMap^,ColorBits*Font.Width*Font.Height div 8);
OutStream.Destroy();
end;

procedure SetColor(const Index : TSGMaxEnum;const Number:Byte);
var
	m:Byte;
	d:TSGMaxEnum;
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
	SGLog.Source(['SGTranslateFont : Translete "',FontInWay,'" to "',FontOutWay,'".']);
Font := TSGFont.Create(FontInWay);
if Font.Load() then
	if RunInConsole then
		SGLog.Source(['SGTranslateFont : Font loaded!'])
	else
else
	begin
	if RunInConsole then
		SGLog.Source(['SGTranslateFont : While loading font exeption error!']);
	Exit;
	end;
if Font.Channels <> 4 then
	begin
	if RunInConsole then
		SGLog.Source(['SGTranslateFont : (Font.Channels!=4), exiting!']);
	Exit;
	end;
BitMap := Font.BitMap;
q:=0;
Fillchar(Colors,SizeOf(Colors),0);
for i:=0 to Font.Width*Font.Height*Font.Channels-1 do
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
	SGLog.Source(['SGTranslateFont : Font : Total [1..254] variables quantyti : "',q,'" of "'+SGStr(Font.Width*Font.Height*Font.Channels)+'" ('+SGStrReal(q/(Font.Width*Font.Height*Font.Channels)*100,2)+' per cent)!']);
	for i:=0 to 255 do
		if Colors[i]<>0 then
			begin
			SGLog.Source(['SGTranslateFont : Colors[',i,']="',Colors[i],'".']);
			end;
	end;
q:=0;
for i:=0 to Font.Width*Font.Height-1 do
	begin
	if (BitMap[i*Font.Channels+0]<>255) then q+=1;
	if (BitMap[i*Font.Channels+1]<>255) then q+=1;
	if (BitMap[i*Font.Channels+2]<>255) then q+=1;
	end;
if RunInConsole then
	begin
	SGLog.Source(['SGTranslateFont : Font : RGB [0..254] variables quantyti : "',q,'" of "'+SGStr(Font.Width*Font.Height*3)+'" ('+SGStrReal(q/(Font.Width*Font.Height*3)*100,2)+' per cent)!']);
	end;
if q<>0 then
	Exit;
Fillchar(Colors,SizeOf(Colors),0);
Fillchar(ObrColors,SizeOf(ObrColors),0);
for i:=0 to Font.Width*Font.Height-1 do
	begin
	Colors[BitMap[i*Font.Channels+3]]+=1;
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
	SGLog.Source(['SGTranslateFont : Font : Quantity colors = "',QuantityColors,'"!']);
	for i:=0 to 255 do
		if Colors[i]<>0 then
			begin
			SGLog.Source(['SGTranslateFont : Colors[',i,']="',Colors[i],'" ('+SGStrReal(Colors[i]/(Font.Width*Font.Height)*100,2)+' per cent).']);
			end;
	end;
ColorBits:=0;
while QuantityColors>2**ColorBits do
	ColorBits+=1;
if RunInConsole then
	begin
	SGLog.Source(['SGTranslateFont : Color bits = "',ColorBits,'"']);
	end;
GetMem(ColorBitMap,ColorBits*Font.Width*Font.Height div 8);
Fillchar(ColorBitMap^,ColorBits*Font.Width*Font.Height div 8,0);
if RunInConsole then
	begin
	SGLog.Source(['SGTranslateFont : Sizeof color bit map = "',ColorBits*Font.Width*Font.Height div 8,'" (',ColorBits*Font.Width*Font.Height mod 8,')']);
	end;
for i:=0 to Font.Width*Font.Height-1 do
	begin
	SetColor(i,ObrColors[BitMap[i*Font.Channels+3]]);
	end;
WriteFileToStream();
FreeMem(ColorBitMap);
if Font<>nil then
	Font.Destroy();
if TudaColors<>nil then
	SetLength(TudaColors,0);
end;

end.
