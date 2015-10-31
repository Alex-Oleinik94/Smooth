{$INCLUDE Includes\SaGe.inc}

unit SaGeUtils;

interface
uses
	 SaGeBase
	,Classes
	,SaGeBased
	,SaGeCommon
	,SaGeContext
	,SaGeRender
	,SaGeImages
	,SaGeMesh
	,SaGeImagesBase
	,SaGeResourseManager
	,PAPPE
	;
type
	TSGFont=class;
(*====================================================================*)
(*============================TSGCamera===============================*)
(*====================================================================*)
const
	SG_VIEW_WATCH_OBJECT        = $001001;
	SG_VIEW_LOOK_AT_OBJECT      = $001002;
type
	TSGCamera=class(TSGContextObject)
			public
		constructor Create();override;
			public
		FMatrixMode: TSGExByte; // SG_3D, SG_2D, SG_ORTHO_3D
		FViewMode  : TSGExByte; // SG_VIEW_...
			// for SG_VIEW_WATCH_OBJECT
		FRotateX, FRotateY, FTranslateX, FTranslateY, FZum : TSGSingle;
			// for SG_VIEW_LOOK_AT_OBJECT
		FLocation : TSGVertex3f;
		FView   :TSGVertex3f;
		FUp : TSGVertex3f;
		procedure Change();inline;
			public
		procedure InitMatrix();inline;
		procedure Clear();inline;
		procedure CallAction();inline;
			public
		procedure InitViewModeComboBox();virtual;abstract;
		procedure Move(const Param : TSGSingle);
		procedure MoveSidewards(const Param : TSGSingle);
		procedure MoveUp(const Param : TSGSingle);
		procedure Rotate(const x, y, z : TSGSingle);
			public
		property Up        : TSGVertex3f read FUp         write FUp;
		property Location  : TSGVertex3f read FLocation   write FLocation;
		property Position  : TSGVertex3f read FLocation   write FLocation;
		property View      : TSGVertex3f read FView       write FView;
		property MatrixMode: TSGExByte   read FMatrixMode write FMatrixMode;
		property ViewMode  : TSGExByte   read FViewMode   write FViewMode;
		end;

(*====================================================================*)
(*==========================TSGBezierCurve============================*)
(*====================================================================*)
	TSGBezierCurveType=(SG_Bezier_Curve_High,SG_Bezier_Curve_Low);
	TSGBezierCurve=class(TSGDrawClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FStartArray : TArTSGVertex3f;
		FMesh : TSG3DObject;
		FDetalization : LongWord;
		FType:TSGBezierCurveType;
		FLowIndex:LongWord;
		FLowAttitude:Real;
		procedure SetVertex(const Index:TSGMaxEnum;const VVertex:TSGVertex3f);
		function GetVertex(const Index:TSGMaxEnum):TSGVertex3f;
		function GetResultVertex(const Attitude:real;const FArray:PTSGVertex3f;const VLength:TSGMaxEnum):TSGVertex3f;inline;overload;
		function GetLow(const R:Real):TSGVertex3f;inline;
			public
		property LowAttitude:Real read FLowAttitude;
		property LowIndex:LongWord read FLowIndex;
		function GetResultVertex(const Attitude:real):TSGVertex3f;inline;overload;
		procedure Calculate();
		procedure AddVertex(const VVertex:TSGVertex3f);
		property Vertexes[Index : TSGMaxEnum]:TSGVertex3f read GetVertex write SetVertex; 
		property Detalization:LongWord read FDetalization write FDetalization;
		procedure Draw();override;
		function VertexQuantity:TSGMaxEnum;inline;
		end;

(*====================================================================*)
(*=============================TSGFont================================*)
(*====================================================================*)
	TSGFontInt = TSGLongWord;
	TSGSimbolParamType = TSGWord;
	
	TStringParams=packed array of packed array [0..1] of string;
	
	TSGSimbolParam=object
		X,Y,Width:TSGSimbolParamType;
		end;
	
	TSGSimbolParams = packed array[#0..#255] of TSGSimbolParam;
	
	TSGFont=class(TSGImage)
			public
		constructor Create(const FileName:string = '');
		destructor Destroy;override;
			protected
		FSimbolParams:TSGSimbolParams;
		FFontParams:TStringParams;
		FTextureParams:TStringParams;
		FFontReady:TSGBoolean;
		FFontHeight:Byte;
		procedure LoadFont(const FontWay:string);
		class function GetLongInt(var Params:TStringParams;const Param:string):LongInt;
		function GetSimbolWidth(const Index:char):LongInt;inline;
		function LoadSGF():TSGBoolean;
			public
		function GetSimbolInfo(const VSimbol:Char):TSGPoint2f;inline;
		function Loading():TSGBoolean;override;
		function StringLength(const S:PChar ):LongWord;overload;
		function StringLength(const S:string ):LongWord;overload;
		function Ready():Boolean;override;
			public
		property FontReady :Boolean read FFontReady;
		property FontHeight:Byte read FFontHeight;
		property SimbolWidth[Index:char]:LongInt read GetSimbolWidth;
		property FontParams:TStringParams read FFontParams;
		property TextureParams:TStringParams read FTextureParams;
		property SimbolParams:TSGSimbolParams read FSimbolParams;
			public
		procedure DrawFontFromTwoVertex2f(const S:PChar;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure AddWaterString(const VString:String;const VImage:TSGImage;const VType:LongWord = 0);
		end;

		
	{PSGViewportObject = ^ TSGViewportObject;
	TSGViewportObject=class(TSGRenderObject)
			private
		FColor:TSGColor4f;
		x,y,z:Real;
		depth:Single;
		viewport:TViewPortArray;
		mv_matrix,proj_matrix:T16DArray;
		Point:SGPoint;
		function GetVertex:SGVertex;
			public
		procedure GetViewport;
		procedure SetPoint (NewPoint:SGPoint;const WithSmezhenie:boolean = True);
		procedure CanculateVertex;
		procedure CanculateColor;
		property Vertex : SGVertex read GetVertex;
		property Color : SGColor4f read FColor;
		end;
	SGViewportObject = TSGViewportObject;
	PTSGViewportObject = PSGViewportObject;
	
function SGGetVertexFromPointOnScreen(const Point:SGPoint;const WithSmezhenie:boolean = True):SGVertex;}

type
	TSGStaticString=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
		procedure Draw();override;
			private
		FMesh : TSG3DObject;
		FText : TSGString;
		FFont : TSGFont;
			public
		procedure SetText(const NewText : TSGString);
			public
		property Text : TSGString read FText write SetText;
		property Font : TSGFont   read FFont write FFont;
		end;

// Эта процедура переводит шрифт в формат PNG
procedure SGTranslateFont(const FontInWay,FontOutWay : TSGString;const RunInConsole:TSGBoolean = True);

implementation

procedure TSGStaticString.Draw();
begin
if (FMesh<>nil) and (FFont<>nil) then
	begin
	Render.Color4f(1,1,1,1);
	FFont.BindTexture();
	FMesh.Draw();
	FFont.DisableTexture();
	end;
end;

constructor TSGStaticString.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FMesh := nil;
FText := '';
FFont := nil;
end;

procedure TSGStaticString.SetText(const NewText : TSGString);
var
	i, ii : TSGLongWord;
	DXShift : TSGSingle = 0;
begin
if (FFont = nil) then
	Exit;
if FMesh <> nil then
	begin
	FMesh.Destroy();
	FMesh:=nil;
	end;
FText := NewText;
if FText = '' then
	Exit;
if Render.RenderType = SGRenderDirectX then
	DXShift := 0.5;
FMesh := TSG3DObject.Create();
FMesh.SetContext(Context);
FMesh.HasColors := False;
FMesh.ObjectPoligonesType:=SGR_TRIANGLES;
FMesh.ObjectColor:=SGGetColor4fFromLongWord($FFFFFF);
FMesh.EnableCullFace:=False;
FMesh.HasNormals:=False;
FMesh.QuantityFaceArrays := 0;
FMesh.HasTexture := True;
FMesh.Vertexes := 2*3*Length(FText);
ii := 0;
for i:=1 to Length(FText) do
	begin
	FMesh.ArVertex3f[(i-1)*6+0]^.Import(ii,0);
	FMesh.ArVertex3f[(i-1)*6+1]^.Import(ii+FFont.SimbolParams[FText[i]].Width,0);
	FMesh.ArVertex3f[(i-1)*6+2]^.Import(ii+FFont.SimbolParams[FText[i]].Width,FFont.FontHeight);
	FMesh.ArVertex3f[(i-1)*6+3]^:=FMesh.ArVertex3f[(i-1)*6+0]^;
	FMesh.ArVertex3f[(i-1)*6+4]^:=FMesh.ArVertex3f[(i-1)*6+2]^;
	FMesh.ArVertex3f[(i-1)*6+5]^.Import(ii,FFont.FontHeight);
	
	FMesh.ArTexVertex[(i-1)*6+0]^.Import(
		(FFont.SimbolParams[FText[i]].x+DXShift)/FFont.Width,
		1-(FFont.SimbolParams[FText[i]].y/FFont.Height));
	FMesh.ArTexVertex[(i-1)*6+1]^.Import(
		(FFont.SimbolParams[FText[i]].x+FFont.SimbolParams[FText[i]].Width+DXShift)/FFont.Width,
		1-(FFont.SimbolParams[FText[i]].y/FFont.Height));
	FMesh.ArTexVertex[(i-1)*6+2]^.Import(
		(FFont.SimbolParams[FText[i]].x+FFont.SimbolParams[FText[i]].Width+DXShift)/FFont.Width,
		1-((FFont.SimbolParams[FText[i]].y+FFont.FontHeight)/FFont.Height));
	FMesh.ArTexVertex[(i-1)*6+3]^:=FMesh.ArTexVertex[(i-1)*6+0]^;
	FMesh.ArTexVertex[(i-1)*6+4]^:=FMesh.ArTexVertex[(i-1)*6+2]^;
	FMesh.ArTexVertex[(i-1)*6+5]^.Import(
		(FFont.SimbolParams[FText[i]].x+DXShift)/FFont.Width,
		1-((FFont.SimbolParams[FText[i]].y+FFont.FontHeight)/FFont.Height));
	
	ii+=FFont.SimbolParams[FText[i]].Width;
	end;
FMesh.LoadToVBO();
end;

destructor TSGStaticString.Destroy();
begin
inherited;
end;

class function TSGStaticString.ClassName():TSGString;
begin
Result := 'TSGStaticString';
end;

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
	SP:TSGSimbolParams;
	i:TSGLongWord;
begin
OutStream := TFileStream.Create(FontOutWay,fmCreate);
if OutStream = nil then
	begin
	SGLog.Sourse(['SGTranslateFont : Can''t open file "',FontOutWay,'"']);
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
	SGLog.Sourse(['SGTranslateFont : Writing info (ColorBits=',ColorBits,',QuantityColors=',QuantityColors,')']);
	SGLog.Sourse(['SGTranslateFont : TudaColors=['],False);
	for i:=0 to High(TudaColors) do
		SGLog.Sourse([TudaColors[i]],False);
	SGLog.Sourse('].');
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
SP:=Font.SimbolParams;
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
	SGLog.Sourse(['SGTranslateFont : Translete "',FontInWay,'" to "',FontOutWay,'".']);
Font := TSGFont.Create(FontInWay);
if Font.Loading() then
	if RunInConsole then
		SGLog.Sourse(['SGTranslateFont : Font loaded!'])
	else
else
	begin
	if RunInConsole then
		SGLog.Sourse(['SGTranslateFont : While loading font exeption error!']);
	Exit;
	end;
if Font.Channels <> 4 then
	begin
	if RunInConsole then
		SGLog.Sourse(['SGTranslateFont : (Font.Channels!=4), exiting!']);
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
	SGLog.Sourse(['SGTranslateFont : Font : Total [1..254] variables quantyti : "',q,'" of "'+SGStr(Font.Width*Font.Height*Font.Channels)+'" ('+SGStrReal(q/(Font.Width*Font.Height*Font.Channels)*100,2)+' per cent)!']);
	for i:=0 to 255 do 
		if Colors[i]<>0 then
			begin
			SGLog.Sourse(['SGTranslateFont : Colors[',i,']="',Colors[i],'".']);
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
	SGLog.Sourse(['SGTranslateFont : Font : RGB [0..254] variables quantyti : "',q,'" of "'+SGStr(Font.Width*Font.Height*3)+'" ('+SGStrReal(q/(Font.Width*Font.Height*3)*100,2)+' per cent)!']);
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
	SGLog.Sourse(['SGTranslateFont : Font : Quantity colors = "',QuantityColors,'"!']);
	for i:=0 to 255 do 
		if Colors[i]<>0 then
			begin
			SGLog.Sourse(['SGTranslateFont : Colors[',i,']="',Colors[i],'" ('+SGStrReal(Colors[i]/(Font.Width*Font.Height)*100,2)+' per cent).']);
			end;
	end;
ColorBits:=0;
while QuantityColors>2**ColorBits do
	ColorBits+=1;
if RunInConsole then
	begin
	SGLog.Sourse(['SGTranslateFont : Color bits = "',ColorBits,'"']);
	end;
GetMem(ColorBitMap,ColorBits*Font.Width*Font.Height div 8);
Fillchar(ColorBitMap^,ColorBits*Font.Width*Font.Height div 8,0);
if RunInConsole then
	begin
	SGLog.Sourse(['SGTranslateFont : Sizeof color bit map = "',ColorBits*Font.Width*Font.Height div 8,'" (',ColorBits*Font.Width*Font.Height mod 8,')']);
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

(*====================================================================*)
(*==========================TSGBezierCurve============================*)
(*====================================================================*)

function TSGBezierCurve.VertexQuantity:TSGMaxEnum;inline;
begin
if FStartArray=nil then
	Result:=0
else
	Result:=Length(FStartArray);
end;

procedure TSGBezierCurve.Draw();
begin
if FMesh<>nil then
	FMesh.Draw();
end;

function TSGBezierCurve.GetResultVertex(const Attitude:real):TSGVertex3f;inline;overload;
begin
if (FType = SG_Bezier_Curve_High)or (Length(FStartArray)<3) then
	Result:=GetResultVertex(Attitude,@FStartArray[0],Length(FStartArray))
else
	Result:=GetLow(Attitude);
end;

function TSGBezierCurve.GetResultVertex(const Attitude:real;const FArray:PTSGVertex3f;const VLength:TSGMaxEnum):TSGVertex3f;inline;overload;
var
	VArray:TArTSGVertex3f;
	i:TSGMaxEnum;
begin
if VLength=1 then
	Result:=FArray[0]
else if VLength=2 then
	Result:=SGGetVertexInAttitude(FArray[0],FArray[1],Attitude)
else
	begin
	SetLength(VArray,VLength-1);
	for i:=0 to High(VArray) do
		VArray[i]:=SGGetVertexInAttitude(FArray[i],FArray[i+1],Attitude);
	Result:=GetResultVertex(Attitude,@VArray[0],VLength-1);
	SetLength(VArray,0);
	end;
end;

function TSGBezierCurve.GetLow(const R:Real):TSGVertex3f;inline;
var
	StN:Real;
begin
StN:=R*High(FStartArray);
FLowIndex:=trunc(StN);
FLowAttitude:=StN - FLowIndex;
if trunc(StN) = 0 then
	Result:=(
		GetResultVertex(StN,  @FStartArray[trunc(StN)],2)+
		GetResultVertex(StN/2,@FStartArray[trunc(StN)],3)
		)/2
else if trunc(StN) >= High(FStartArray)-1 then
	begin
	Result:=(
		GetResultVertex((StN-High(FStartArray)+2)/2	 		,@FStartArray[High(FStartArray)-2]		,3)+
		GetResultVertex((StN-(High(FStartArray)-1))			,@FStartArray[High(FStartArray)-1]		,2)
		)/2
	end
else
	Result:=(
		GetResultVertex((StN-(Trunc(StN)-1))/2		,@FStartArray[trunc(StN)-1]		,3)+
		GetResultVertex((StN-(Trunc(StN)))/2		,@FStartArray[trunc(StN)]		,3))/2;
end;

procedure TSGBezierCurve.Calculate();
var
	i:TSGMaxEnum;
begin
if FMesh<>nil then
	FMesh.Destroy();
FMesh:=nil;
if (FStartArray=nil) or (Length(FStartArray)=0) then
	Exit;
FMesh:=TSG3DObject.Create();
FMesh.SetContext(Context);
FMesh.ObjectColor:=SGGetColor4fFromLongWord($FFFFFF);
FMesh.EnableCullFace:=False;
FMesh.ObjectPoligonesType:=SGR_LINE_STRIP;
FMesh.VertexType := SGMeshVertexType3f;
FMesh.SetVertexLength(FDetalization);
for i:=0 to FDetalization-1 do
	begin
	FMesh.ArVertex3f[i]^:=GetResultVertex(i/(Detalization-1));
	end;
FMesh.LoadToVBO();
end;

procedure TSGBezierCurve.SetVertex(const Index:TSGMaxEnum;const VVertex:TSGVertex3f);
begin
if FStartArray<>nil then
	FStartArray[Index]:=VVertex;
end;

function TSGBezierCurve.GetVertex(const Index:TSGMaxEnum):TSGVertex3f;
begin
Result:=FStartArray[Index];
end;

procedure TSGBezierCurve.AddVertex(const VVertex:TSGVertex3f);
begin
if FStartArray=nil then
	SetLength(FStartArray,1)
else
	SetLength(FStartArray,Length(FStartArray)+1);
FStartArray[High(FStartArray)]:=VVertex;
end;

constructor TSGBezierCurve.Create();
begin
inherited;
FStartArray:=nil;
FMesh:=nil;
FDetalization:=50;
FType:=SG_Bezier_Curve_Low;
end;

destructor TSGBezierCurve.Destroy();
begin
if FStartArray<>nil then
	SetLength(FStartArray,0);
if FMesh<>nil then
	FMesh.Destroy();
inherited;
end;

(*====================================================================*)
(*============================TSGCamera===============================*)
(*====================================================================*)

constructor TSGCamera.Create();
begin
inherited;
FMatrixMode:=SG_3D;
FViewMode:=SG_VIEW_WATCH_OBJECT;
FLocation.Import();
FView.Import();
FUp.Import(0,0,0);
Clear();
end;

procedure TSGCamera.Change();inline;
begin
case FViewMode of
SG_VIEW_WATCH_OBJECT:
	begin
	if Context.CursorWheel=SGUpCursorWheel then
		begin
		FZum*=0.9;
		end;
	if Context.CursorWheel=SGDownCursorWheel then
		begin
		FZum*=1/0.9;
		end;
	if Context.CursorKeysPressed(SGLeftCursorButton) then
		begin
		FRotateY+=Context.CursorPosition(SGDeferenseCursorPosition).x/3;
		FRotateX+=Context.CursorPosition(SGDeferenseCursorPosition).y/3;
		end;
	if Context.CursorKeysPressed(SGRightCursorButton) then
		begin
		FTranslateY+=    (-Context.CursorPosition(SGDeferenseCursorPosition).y/100)*FZum;
		FTranslateX+=   ( Context.CursorPosition(SGDeferenseCursorPosition).x/100)*FZum;
		end;
	if (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedChar=char(189)) and (Context.KeyPressedType=SGDownKey)) then
		begin
		FZum*=1/0.89;
		end;
	if  (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedByte=187) and (Context.KeyPressedType=SGDownKey))  then
		begin
		FZum*=0.89;
		end;
	end;
end;
end;

procedure TSGCamera.InitMatrix();inline;
var
	Matrix:TSGMatrix4;
begin
case FViewMode of
SG_VIEW_WATCH_OBJECT:
	begin
	Render.InitMatrixMode(FMatrixMode,FZum);
	Render.Translatef(FTranslateX,FTranslateY,-10*FZum);
	Render.Rotatef(FRotateX,1,0,0);
	Render.Rotatef(FRotateY,0,1,0);
	end;
SG_VIEW_LOOK_AT_OBJECT:
	begin
	FUp.Normalize();
	Render.InitMatrixMode(SG_3D);
	//Matrix:=SGGetLookAtMatrix(FLocation,FView,FUp);
	Matrix:=TSGMatrix4(PAPPE.Matrix4x4LookAt(TPhysicsVector3(FLocation),TPhysicsVector3(FView+FLocation),TPhysicsVector3(FUp)));
	Render.MultMatrixf(@Matrix);
	end;
end;
end;

procedure TSGCamera.Move(const Param : TSGSingle);
begin
Position := Position + FView * Param;
end;

procedure TSGCamera.Rotate(const x, y, z : TSGSingle);
var
	Sidewards : TSGVertex3f;
begin
if x<>0 then
	begin
	Sidewards := (View * Up).Normalized();
	View := SGRotatePoint(View, Sidewards, -X).Normalized();
	Up := (Sidewards * View).Normalized();
	end;
if y<>0 then
	View := SGRotatePoint(View, Up, -Y).Normalized();
if z<>0 then
	Up := SGRotatePoint(Up, View, -Z).Normalized();
end;

procedure TSGCamera.MoveUp(const Param : TSGSingle);
begin
Position := Position + Up * Param;
end;

procedure TSGCamera.MoveSidewards(const Param : TSGSingle);
begin
Position := Position + (View * Up).Normalized() * Param;
end;

procedure TSGCamera.CallAction();inline;
begin
Change();
InitMatrix();
end;

procedure TSGCamera.Clear();inline;
begin
FZum:=1;
FRotateX:=0;
FRotateY:=0;
FTranslateX:=0;
FTranslateY:=0;
end;

//======================================================================

{procedure SGViewportObject.CanculateColor;
begin
glReadPixels(
	Point.x,
	Context.Height-Point.y-1,
	1, 
	1, 
	GL_RGBA, 
	GL_FLOAT, 
	@FColor);
end;

procedure SGViewportObject.CanculateVertex; 
begin
glReadPixels(
	Point.x,
	Context.Height-Point.y-1,
	1, 
	1, 
	GL_DEPTH_COMPONENT, 
	GL_FLOAT, 
	@depth);
gluUnProject(
	Point.x,
	Context.Height-Point.y-1,
	depth,
	mv_matrix,
	proj_matrix,
	viewport,
	@x,
	@y,
	@z);
end;}
{function SGViewportObject.GetVertex:SGVertex;
begin
Result.Import(x,y,z);
end;}
{procedure SGViewportObject.SetPoint(NewPoint:SGPoint;const WithSmezhenie:boolean = True);
begin
Point:=NewPoint;
//if WithSmezhenie then
	//Point+=Smezhenie;
end;

procedure SGViewportObject.GetViewport;
begin
glGetIntegerv(GL_VIEWPORT,viewport);
glGetDoublev(GL_MODELVIEW_MATRIX,mv_matrix);
glGetDoublev(GL_PROJECTION_MATRIX,proj_matrix);
end;

function SGGetVertexFromPointOnScreen(const Point:SGPoint;const WithSmezhenie:boolean = True):SGVertex;
var
	ViewportObj:SGViewportObject;
begin
ViewportObj:=TSGViewportObject.Create;
ViewportObj.GetViewport;
ViewportObj.SetPoint(Point,WithSmezhenie);
ViewportObj.CanculateVertex;
Result:=ViewportObj.Vertex;
ViewportObj.Destroy;
end;}

(*====================================================================*)
(*=============================TSGFont================================*)
(*====================================================================*)

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
//SGLog.Sourse(['Index=',Index,', Result=',Result]);
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
SGResourseFiles.LoadMemoryStreamFromFile(Stream,FWay);
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
Stream.ReadBuffer(FSimbolParams,SizeOf(FSimbolParams));
GetMem(ColorBitMap,ColorBits*Width*Height div 8);
Stream.ReadBuffer(ColorBitMap^,ColorBits*Width*Height div 8);
Stream.Destroy();
Stream:=nil;
CalcucateBitMap();
FreeMem(ColorBitMap,ColorBits*Width*Height div 8);
SetLength(ArColors,0);
Result:=True;
FReadyToGoToTexture := True;
FFontReady := True;
end;

function TSGFont.GetSimbolInfo(const VSimbol:Char):TSGPoint2f;inline;
begin
Result.Import(FSimbolParams[VSimbol].x,FSimbolParams[VSimbol].y);
end;

function TSGFont.GetSimbolWidth(const Index:char):LongInt;inline;
begin
Result:=FSimbolParams[Index].Width;
end;

procedure TSGFont.DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	P:PChar;
begin
P:=SGStringToPChar(S);
DrawFontFromTwoVertex2f(P,Vertex1,Vertex2,AutoXShift,AutoYShift);
FreeMem(P,SGPCharLength(P)+1);
end;

procedure TSGFont.DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	P:PChar;
begin
P:=SGStringToPChar(S);
DrawCursorFromTwoVertex2f(P,CursorPosition,Vertex1,Vertex2,AutoXShift,AutoYShift);
FreeMem(P,SGPCharLength(P)+1);
end;

function TSGFont.Ready:Boolean;
begin
Result:= (Inherited Ready) and FontReady;
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

procedure LoadSimbol(S:String;var Obj:TSGSimbolParam);
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
			LoadSimbol(Identificator,FSimbolParams[C2]);
			end;
		Identificator:='';
		end;
	ReadLn(Fail);
	end;
Close(Fail);
FFontHeight:=GetLongInt(FFontParams,'Height');
FFontReady:=True;
end;

function TSGFont.Loading():TSGBoolean;
var
	FontWay:string = '';
	i:LongInt = 0;
	ii:LongInt = 0;
begin
if SGGetFileExpansion(FWay)='SGF' then
	begin
	Result:=LoadSGF();
	Exit;
	end;
Result:=inherited Loading();
if not Result then 
	Exit;
i:=Length(FWay);
while (FWay[i]<>'.')and(FWay[i]<>'/')and(i>0)do
	i-=1;
if (i>0)and (FWay[i]='.') then
	begin
	for ii:=1 to i do
		FontWay+=FWay[ii];
	FontWay+='txt';
	if SGFileExists(FontWay) then
		begin
		LoadFont(FontWay);
		end;
	end;
end;

constructor TSGFont.Create(const FileName:string = '');
begin
inherited Create(FileName);
FFontReady:=False;
FFontParams:=nil;
FTextureParams:=nil;
end;

destructor TSGFont.Destroy;
begin
inherited;
end;

procedure TSGFont.DrawFontFromTwoVertex2f(const S:PChar;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	i:LongInt = 0;
	StringWidth:LongInt = 0;
	Otstup:SGVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
	ThisSimbolWidth:LongWord = 0;
	DXShift : TSGSingle = 0;
begin
if Render.RenderType=SGRenderDirectX then
	DXShift:=0.5;
BindTexture();
StringWidth:=StringLength(S);
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
Otstup.Round;
while (s[i]<>#0) and (not ToExit) do
	begin
	ThisSimbolWidth:=FSimbolParams[s[i]].Width;
	if Otstup.x+FSimbolParams[s[i]].Width>Abs(Vertex2.x-Vertex1.x) then
		begin
		ToExit:=True;
		ThisSimbolWidth:=Trunc(Abs(Vertex2.x-Vertex1.x)-Otstup.x);
		end;
	Render.BeginScene(SGR_QUADS);
	Render.TexCoord2f((Self.FSimbolParams[s[i]].x+DXShift)/Self.Width,1-(Self.FSimbolParams[s[i]].y/Self.Height));
	Render.Vertex2f(Otstup.x+Vertex1.x,Otstup.y+Vertex1.y);
	Render.TexCoord2f(
		(Self.FSimbolParams[s[i]].x+ThisSimbolWidth+DXShift)/Self.Width,
		1-(Self.FSimbolParams[s[i]].y/Self.Height));
	Render.Vertex2f(Otstup.x+ThisSimbolWidth+Vertex1.x,Otstup.y+Vertex1.y);
	Render.TexCoord2f(
		(Self.FSimbolParams[s[i]].x+ThisSimbolWidth+DXShift)/Self.Width,
		1-((Self.FSimbolParams[s[i]].y+FFontHeight)/Self.Height));
	Render.Vertex2f(Otstup.x+ThisSimbolWidth+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
	Render.TexCoord2f((Self.FSimbolParams[s[i]].x+DXShift)/Self.Width,1-((Self.FSimbolParams[s[i]].y+FFontHeight)/Self.Height));
	Render.Vertex2f(Otstup.x+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
	Render.EndScene();
	Otstup.x+=FSimbolParams[s[i]].Width;
	i+=1;
	end;
DisableTexture;
end;

function TSGFont.StringLength(const S:PChar ):LongWord;overload;
var
	i:LongWord;
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
	Result+=FSimbolParams[s[i]].Width;
	i+=1;
	end;
end;

function TSGFont.StringLength(const S:string ):LongWord;overload;
var
	i:LongWord;
begin
Result:=0;
for i:=1 to Length(S) do
	begin
	Result+=FSimbolParams[s[i]].Width;
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
	SI:TSGPoint2f;

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
if (Self=nil) or (not(FontReady)) then
	begin
	SGLog.Sourse('TSGFont__AddWaterString : Error : Font not ready!');
	Exit;
	end;
if (VImage.Image=nil) or (VImage.Channels<>3) or (Channels<>4) or (Image=nil)or (Image.BitMap=nil) then
	begin
	SGLog.Sourse('TSGFont__AddWaterString : Error : Invalid arametrs!');
	Exit;
	end;
PBits:=PSGPixel3b(VImage.Image.BitMap);
StrL:=StringLength(VString);
if (StrL>VImage.Width) or (FontHeight>VImage.Height) then
	begin
	SGLog.Sourse('TSGFont__AddWaterString : Error : for this image ('+SGStr(VImage.Width)+','+SGStr(VImage.Height)+') water string "'+VString+'" is not portable!');
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
		SI:=GetSimbolInfo(VString[i]);
		for iw:=0 to SimbolWidth[VString[i]]-1 do
			begin
			for ih:=1 to FontHeight do
				begin
				Sum+=1;
				SumR+=PBits[VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width].r;
				SumG+=PBits[VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width].g;
				SumB+=PBits[VImage.Width*VImage.Height+(PW+iw)-(PH+ih)*VImage.Width].b;
				end;
			end;
		PW+=SimbolWidth[VString[i]];
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
	SI:=GetSimbolInfo(VString[i]);
	for iw:=0 to SimbolWidth[VString[i]]-1 do
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
	PW+=SimbolWidth[VString[i]];
	end;
end;


procedure TSGFont.DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	i:LongInt = 0;
	StringWidth:LongInt = 0;
	Otstup:SGVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
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

while (s[i]<>#0) and (not ToExit) and (CursorPosition>i) do
	begin
	Otstup.x+=FSimbolParams[s[i]].Width;
	i+=1;
	end;
if Abs(Vertex1.x-Vertex2.x)>Otstup.x then
	begin
	Render.BeginScene(SGR_LINES);
	(Vertex1+Otstup).Vertex(Render);
	Render.Vertex2f(Otstup.x+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
	Render.EndScene();
	end;
end;

end.
