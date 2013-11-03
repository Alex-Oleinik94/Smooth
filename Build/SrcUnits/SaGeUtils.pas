{$I Includes\SaGe.inc}

unit SaGeUtils;

interface
uses
	SaGeBase
	,SaGeCommon
	,SaGeContext
	,SaGeRender
	,SaGeImages
	;
type
	SGIdentityObject=object
		Context:PSGContext;
		Render:TSGRender;
		Rotate1:real;
		Rotate2:real;
		Rotate3:real;
		Zum:real;
		Left:real;
		Top:real;
		Changet:Boolean;
		procedure Clear;
		procedure Change(const Mode:LongWord = SG_3D);
		procedure Init(const Tr:TSGVertex3f);overload;
		procedure Init;overload;
		procedure ChangeAndInit(const Mode:LongWord = SG_3D);
		procedure Go(const Mode:LongWord = SG_3D);
		end;
	SGImage = SaGeImages.TSGImage;
	TSGImage = SaGeImages.TSGImage;
	TStringParams=packed array of packed array [0..1] of string;
	TSGGLImage=class(TSGImage)
			public
		procedure DrawImageFromTwoVertex2f(Vertex1,Vertex2:SGVertex2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D;const Rotation:Byte = 0);
		procedure DrawImageFromTwoPoint2f(Vertex1,Vertex2:SGPoint2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D;const Rotation:Byte = 0);
		procedure ImportFromDispley(const Point1,Point2:SGPoint;const NeedAlpha:Boolean = True);
		procedure ImportFromDispley(const NeedAlpha:Boolean = True);
		class function UnProjectShift:TSGPoint2f;
		procedure DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);inline;
		procedure RePlacVertex(var Vertex1,Vertex2:SGVertex2f;const RePlaceY:SGByte = SG_3D);inline;
		end;
	
	TSGSimbolParam=object
		X,Y,Width:LongInt;
		end;
	
	TSGFont=class(TSGGLImage)
			public
		constructor Create(const FileName:string = '');
		destructor Destroy;override;
			protected
		FSimbolParams:packed array[#0..#255] of TSGSimbolParam;
		FFontParams:TStringParams;
		FTextureParams:TStringParams;
		FFontReady:Boolean;
		FFontHeight:LongInt;
		procedure LoadFont(const FontWay:string);
		class function GetLongInt(var Params:TStringParams;const Param:string):LongInt;
			public
		property FontHeight:LongInt read FFontHeight;
		procedure ToTexture;override;
		function StringLength(const S:PChar ):LongWord;overload;
		function StringLength(const S:string ):LongWord;overload;
		property FontReady:Boolean read FFontReady;
		function Ready:Boolean;override;
		end;
	
	TSGGLFont=class(TSGFont)
		procedure DrawFontFromTwoVertex2f(const S:PChar;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
		procedure DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
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

implementation

procedure TSGGLFont.DrawFontFromTwoVertex2f(const S:string;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	P:PChar;
begin
P:=SGStringToPChar(S);
DrawFontFromTwoVertex2f(P,Vertex1,Vertex2,AutoXShift,AutoYShift);
FreeMem(P,SGPCharLength(P)+1);
end;

procedure TSGGLFont.DrawCursorFromTwoVertex2f(const S:String;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	P:PChar;
begin
P:=SGStringToPChar(S);
DrawCursorFromTwoVertex2f(P,CursorPosition,Vertex1,Vertex2,AutoXShift,AutoYShift);
FreeMem(P,SGPCharLength(P)+1);
end;

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

procedure TSGFont.ToTexture;
var
	FontWay:string = '';
	i:LongInt = 0;
	ii:LongInt = 0;
begin
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
inherited ToTexture;
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

procedure TSGGLFont.DrawFontFromTwoVertex2f(const S:PChar;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
var
	i:LongInt = 0;
	StringWidth:LongInt = 0;
	Otstup:SGVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
	SimbolWidth:LongWord = 0;
begin
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
	SimbolWidth:=FSimbolParams[s[i]].Width;
	if Otstup.x+FSimbolParams[s[i]].Width>Abs(Vertex2.x-Vertex1.x) then
		begin
		ToExit:=True;
		SimbolWidth:=Trunc(Abs(Vertex2.x-Vertex1.x)-Otstup.x);
		end;
	Render.BeginScene(SGR_QUADS);
	Render.TexCoord2f(Self.FSimbolParams[s[i]].x/Self.Width,1-(Self.FSimbolParams[s[i]].y/Self.Height));
	Render.Vertex2f(Otstup.x+Vertex1.x,Otstup.y+Vertex1.y);
	Render.TexCoord2f(
		(Self.FSimbolParams[s[i]].x+SimbolWidth)/Self.Width,
		1-(Self.FSimbolParams[s[i]].y/Self.Height));
	Render.Vertex2f(Otstup.x+SimbolWidth+Vertex1.x,Otstup.y+Vertex1.y);
	Render.TexCoord2f(
		(Self.FSimbolParams[s[i]].x+SimbolWidth)/Self.Width,
		1-((Self.FSimbolParams[s[i]].y+FFontHeight)/Self.Height));
	Render.Vertex2f(Otstup.x+SimbolWidth+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
	Render.TexCoord2f(Self.FSimbolParams[s[i]].x/Self.Width,1-((Self.FSimbolParams[s[i]].y+FFontHeight)/Self.Height));
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

procedure TSGGLImage.DrawImageFromTwoPoint2f(Vertex1,Vertex2:SGPoint2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D;const Rotation:Byte = 0);
begin
DrawImageFromTwoVertex2f(SGPoint2fToVertex2f(Vertex1),SGPoint2fToVertex2f(Vertex2),RePlace,RePlaceY,Rotation);
end;

procedure TSGGLImage.DrawImageFromTwoVertex2f(Vertex1,Vertex2:SGVertex2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D;const Rotation:Byte = 0);
procedure DoTexCoord(const NowRotation:Byte);inline;
begin
case (NowRotation mod 4) of
0:Render.TexCoord2f(0,1);
1:Render.TexCoord2f(1,1);
2:Render.TexCoord2f(1,0);
3:Render.TexCoord2f(0,0);
end;
end;
begin
if RePlace then
	begin
	RePlacVertex(Vertex1,Vertex2,rePlaceY);
	end;
BindTexture();
Render.BeginScene(SGR_QUADS);
DoTexCoord(Rotation);
Vertex1.Vertex(Render);
DoTexCoord(Rotation+1);
Render.Vertex2f(Vertex2.x,Vertex1.y);
DoTexCoord(Rotation+2);
Vertex2.Vertex(Render);
DoTexCoord(Rotation+3);
Render.Vertex2f(Vertex1.x,Vertex2.y);
Render.EndScene();
DisableTexture();
end;

procedure TSGGLImage.DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);inline;
begin
if RePlace then
	RePlacVertex(Vertex1,Vertex2,SG_2D);
DrawImageFromTwoVertex2f(
	SGVertex2fImport(
		Vertex1.x+abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex1.y+abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	SGVertex2fImport(
		Vertex2.x-abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex2.y-abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	RePlace,SG_2D);
end;

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

procedure SGViewportObject.CanculateVertex;//{$}
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

procedure TSGGLImage.RePlacVertex(var Vertex1,Vertex2:SGVertex2f;const RePlaceY:SGByte = SG_3D);inline;
begin
if Vertex1.x>Vertex2.x then
	SGQuickRePlaceVertexType(Vertex1.x,Vertex2.x);
case RePlaceY of
SG_2D:
	begin
	if Vertex1.y>Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
else
	begin
	if Vertex1.y<Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
end;
end;

class function TSGGLImage.UnProjectShift:TSGPoint2f;
begin
//Result:=TSGViewportObject.Smezhenie;
	//onu:{$}
	Result.Import();
end;

procedure TSGGLImage.ImportFromDispley(const NeedAlpha:Boolean = True);
begin
ImportFromDispley(
	SGPointImport(1,1),
	SGPointImport(Render.Width,Render.Height),
	NeedAlpha);
end;

procedure TSGGLImage.ImportFromDispley(const Point1,Point2:SGPoint;const NeedAlpha:Boolean = True);
begin
if Self<>nil then
	FreeAll
else
	Self:=TSGGLImage.Create;
if NeedAlpha then
	begin
	GetMem(FImage.FBitMap,(Point2.x-Point1.x+1)*(Point2.y-Point1.y+1)*4);
	Render.ReadPixels(
		Point1.x-1,//+ReadPixelsShift.x,
		Point1.y-1,//+ReadPixelsShift.y,
		Point2.x-Point1.x+1, 
		Point2.y-Point1.y+1, 
		SGR_RGBA, 
		SGR_UNSIGNED_BYTE, 
		FImage.FBitMap);
	Bits:=32;
	end
else
	begin
	GetMem(FImage.FBitMap,(Point2.x-Point1.x+1)*(Point2.y-Point1.y+1)*3);
	Render.ReadPixels(
		Point1.x-1,//+ReadPixelsShift.x,
		Point1.y-1,//+ReadPixelsShift.y,
		Point2.x-Point1.x+1, 
		Point2.y-Point1.y+1, 
		SGR_RGB, 
		SGR_UNSIGNED_BYTE, 
		FImage.FBitMap);
	Bits:=24;
	end;
Height:=Point2.y-Point1.y+1;
Width:=Point2.x-Point1.x+1;
FReadyToGoToTexture:=True;
end;

procedure TSGGLFont.DrawCursorFromTwoVertex2f(const S:PChar;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);overload;
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

{function SGViewportObject.GetVertex:SGVertex;
begin
Result.Import(x,y,z);
end;}

procedure SGIdentityObject.Change(const Mode:LongWord = SG_3D);
var
	LastTop,LastLeft,LastR1,LastR2:real;
begin
Changet:=False;
LastLeft:=Left;
LastTop:=Top;
LastR1:=Rotate1;
LastR2:=Rotate2;
if Context^.CursorWheel=SGUpCursorWheel then
	begin
	Zum*=0.9;
	Changet:=True;
	end;
if Context^.CursorWheel=SGDownCursorWheel then
	begin
	Zum*=1/0.9;
	Changet:=True;
	end;
if Context^.CursorKeysPressed(SGLeftCursorButton) then
	begin
	Rotate2+=Context^.CursorPosition(SGDeferenseCursorPosition).x/3;
	Rotate1+=Context^.CursorPosition(SGDeferenseCursorPosition).y/3;
	end;
if Context^.CursorKeysPressed(SGRightCursorButton) then{$}
	begin
	Top+=    (-Context^.CursorPosition(SGDeferenseCursorPosition).y/100)*Zum;
	Left+=   ( Context^.CursorPosition(SGDeferenseCursorPosition).x/100)*Zum;
	end;
if (Context^.KeyPressed and (Context^.KeysPressed(char(17))) and (Context^.KeyPressedChar=char(189)) and (Context^.KeyPressedType=SGDownKey)) then
	begin
	Zum*=1/0.89;
	Changet:=true;
	end;
if  (Context^.KeyPressed and (Context^.KeysPressed(char(17))) and (Context^.KeyPressedByte=187) and (Context^.KeyPressedType=SGDownKey))  then
	begin
	Zum*=0.89;
	Changet:=true;
	end;
if (not Changet) and (not (SGRealsEqual(LastLeft,Left) and SGRealsEqual(LastR1,Rotate1) and SGRealsEqual(LastTop,Top) and SGRealsEqual(LastR2,Rotate2))) then
	Changet:=True;
end;

procedure SGIdentityObject.Go(const Mode:LongWord = SG_3D);
begin
Change(Mode);
Render.InitMatrixMode(Mode,(Zum)*120);
Init();
end;

procedure SGIdentityObject.Init(const tr :TSGVertex3f);overload;
begin
Render.Translatef(Left,Top,-10*Zum);
Render.Rotatef(Rotate1,1,0,0);
Render.Rotatef(Rotate2,0,1,0);
Tr.Translate(Render);
end;

procedure SGIdentityObject.Init;overload;
begin
Init(SGVertexImport(0,0,0));
end;

procedure SGIdentityObject.Clear;
begin
Rotate1:=0;
Rotate2:=0;
Rotate3:=0;
Top:=0;
Zum:=1;
Left:=0;
end;

procedure SGIdentityObject.ChangeAndInit(const Mode:LongWord = SG_3D);
begin
Change(Mode);
Init();
end;



end.
