{$INCLUDE Smooth.inc}

unit SmoothFractalMandelbrot;

interface

uses
	 SmoothBase
	,SmoothFractal
	,SmoothImageFractal
	,SmoothDateTime
	,SmoothComplex
	,SmoothContextInterface
	,SmoothScreenClasses
	,SmoothCommonStructs
	;
type
	PSFractalMandelbrotThreadData = ^ TSFractalMandelbrotThreadData;
	TSFractalMandelbrotThreadData = object(TSCustomFractalThreadData)
			public
		constructor Create(const _FractalThreadData : PSFractalThreadData); overload;
		destructor Destroy;
		function Create(const _FractalThreadData : PSFractalThreadData; const _h1,_h2:LongInt;const Point:Pointer;const Number:LongInt = -1) : PSFractalMandelbrotThreadData; static; overload;
		procedure Import(const _FractalThreadData : PSFractalThreadData; const _h1,_h2:LongInt;const Point:Pointer;const Number:LongInt = -1);
			public
		H1,H2:LongInt;
		
		FWait:Boolean;
		NowPos:LongWord;
		NewPos:LongWord;
		
		FPoint:Pointer;
		FNumber:LongInt;
		VBuffer : array[False..True] of PBoolean;
		
		FBeginData:TSDateTime;//время начала потока
		
		FHePr:LongWord;//Уже сделаный прогресс потока по Height
		end;
	
	TSMandelbrotPixel = record
		r, g, b : TSByte;
		end;
	
	TSFractalMandelbrot = class(TSImageFractal)
			public
		constructor Create(const _Context : ISContext); override;
			protected
		FZNumber      : TSComplexNumber;
		FZDegree      : LongInt;
		FZMandelbrot  : Boolean;
		FZQuantityRecursion : LongInt;
		FColorScheme  : TSUInt8;
		
		FAttitudeForThemeEnable : Boolean;
		FTheme1,FTheme2         : TSByte;
		FAttitudeForTheme      : Real;
		
		FSmosh : Byte;
		procedure InitColor(const x,y:LongInt;const RecNumber:LongInt);override;
		function Rec(Number:TSComplexNumber):Word;inline;
		function MandelbrotRec(const Number:TSComplexNumber;const dx,dy:single):Word;inline;
			public
		function GetPixelColor(const VColorSceme:TSByte;const RecNumber:Word):TSMandelbrotPixel;inline;
		procedure ImageDepict(_ThreadData:PSFractalMandelbrotThreadData); overload;
		procedure ImageDepict(); overload;
		procedure Construct();override;
		procedure Paint();override;
		procedure AfterConstruct();override;
		procedure BeginConstruct();override;
		procedure BeginThread(const Number:LongInt;const Real:Pointer);
			public
		property ZNumber:TSComplexNumber read FZNumber write FZNumber;
		property ZDegree:LongInt read FZDegree write FZDegree;
		property ZMandelbrot:TSBoolean read FZMandelbrot write FZMandelbrot;
		property ZQuantityRecursion:LongInt read FZQuantityRecursion write FZQuantityRecursion;
		property ColorScheme : TSUInt8 read FColorScheme write FColorScheme;
		property AttitudeForThemeEnable : TSBoolean read FAttitudeForThemeEnable write FAttitudeForThemeEnable;
		property AttitudeForTheme : Real read FAttitudeForTheme write FAttitudeForTheme;
		property Theme1 : TSByte read FTheme1 write FTheme1;
		property Theme2 : TSByte read FTheme2 write FTheme2;
		end;

procedure TSFractalMandelbrotThreadProcedure(_ThreadData:PSFractalThreadData);

implementation

uses
	 SmoothRenderBase
	,SmoothThreads
	,SysUtils
	;

procedure TSFractalMandelbrotThreadProcedure(_ThreadData:PSFractalThreadData);
begin
(_ThreadData^.Fractal as TSFractalMandelbrot).ImageDepict(PSFractalMandelbrotThreadData(_ThreadData^.Data));
_ThreadData^.Finished := True;
end;

destructor TSFractalMandelbrotThreadData.Destroy;
begin
FreeMem(VBuffer[True]);
FreeMem(VBuffer[not True]);
inherited;
end;

procedure TSFractalMandelbrot.BeginThread(const Number:LongInt;const Real:Pointer);
var
	FractalMandelbrotThreadData : PSFractalMandelbrotThreadData;
	FractalThreadData : PSFractalThreadData;
begin
FractalMandelbrotThreadData := GetMem(SizeOf(TSFractalMandelbrotThreadData));
FractalThreadData := @FThreadsData[Number];
FractalMandelbrotThreadData := TSFractalMandelbrotThreadData.Create(FractalThreadData,
	Trunc( (Number)*(Height div Length(FThreadsData))),
	Trunc( (Number+1)*(Height div Length(FThreadsData)))-1,
	Real,Number);
FractalThreadData^.Data := FractalMandelbrotThreadData;

FractalMandelbrotThreadData^.NewPos:=0;
FractalMandelbrotThreadData^.NowPos:=0;
FractalMandelbrotThreadData^.FWait:=False;
FractalMandelbrotThreadData^.FBeginData.Get;

FractalThreadData^.Thread:=
	TSThread.Create(
		TSPointerProcedure(@TSFractalMandelbrotThreadProcedure),
		FractalThreadData);
end;

procedure TSFractalMandelbrot.AfterConstruct;
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	if FThreadsData[i].Finished then
		begin
		FThreadsData[i].FreeMemData();
		FThreadsData[i].KillThread();
		end;
inherited;
end;

procedure TSFractalMandelbrot.BeginConstruct;
begin
inherited;
end;

procedure TSFractalMandelbrotThreadData.Import(const _FractalThreadData : PSFractalThreadData; const _h1,_h2:LongInt;const Point:Pointer;const Number:LongInt = -1);
begin
FractalThreadData := _FractalThreadData;
h1:=_h1;
h2:=_h2;
FPoint:=Point;
FNumber:=Number;
end;

function TSFractalMandelbrotThreadData.Create(const _FractalThreadData : PSFractalThreadData; const _h1,_h2:LongInt;const Point:Pointer;const Number:LongInt = -1) : PSFractalMandelbrotThreadData; overload;
begin
Result := GetMem(SizeOf(TSFractalMandelbrotThreadData));
Result^.Create(_FractalThreadData);
Result^.Import(_FractalThreadData, _h1, _h2, Point, Number)
end;

constructor TSFractalMandelbrotThreadData.Create(const _FractalThreadData : PSFractalThreadData); overload;
begin
h1:=0;
h2:=0;
FPoint:=nil;
FNumber:=-1;
VBuffer[True] := GetMem(trunc(_FractalThreadData^.Fractal.Depth/2)+1);
VBuffer[False] := GetMem(trunc(_FractalThreadData^.Fractal.Depth/2)+1);
FHePr:=0;
end;

procedure TSFractalMandelbrot.Paint();
begin
inherited;
if FImage.Loaded then
	FImage.DrawImageFromTwoPoint2int32(
		TSVector2Int32.Create(1,1),
		TSVector2Int32.Create(Render.Width,Render.Height),
		False,S_3D);
end;


constructor TSFractalMandelbrot.Create(const _Context : ISContext);
begin
inherited;
FTheme1:=0;
FTheme2:=0;
FAttitudeForTheme:=0;
FAttitudeForThemeEnable:=False;
FImage:=nil;
FZNumber.Import(0,0.65);
FView.Import(-1.5,-1.5*(Render.Height/Render.Width),1.5,1.5*(Render.Height/Render.Width));
FZMandelbrot:=False;
FZDegree:=2;
FZQuantityRecursion:=256;
FColorScheme:=0;
FSmosh:=1;
end;

function TSFractalMandelbrot.GetPixelColor(const VColorSceme:TSByte;const RecNumber:Word):TSMandelbrotPixel;inline;
var
	Color : TSLongWord;

function YellowPil():TSMandelbrotPixel;
begin
	Result.r := trunc(abs(cos(Color) * Color)) mod 255;
	Result.g := GetColor(Color Div 2,Color * Color,trunc(abs((cos(Color) * cos(Color)) * Result.r))mod 500);
	if Color <> 0 then
		Result.b := GetColor(
			Result.g, 
			Result.r, 
			(sqr(Result.r)
		) mod Color)
	else
		Result.b := GetColor(
			Result.g, 
			Result.r, 
			(sqr(Result.r)
		) mod 255);
end;

procedure SwapByte(var a,b:byte);inline;
var 
	c:byte;
begin
c:=a;
a:=b;
b:=c;
end;

begin
Color := Round((RecNumber/20)*255);
case VColorSceme of
1:
	begin
	if RecNumber=FZQuantityRecursion then
		begin
		Result.r:=200;
		Result.g:=0;
		Result.b:=255;
		end
	else
		begin
		Result.r:=GetColor(0,383,Color mod 383) div 2;
		Result.g:=GetColor(128,896,Color  mod 896);
		Result.b:=GetColor(0,383,Color  mod 383);
		end;
	end;
2:
	begin
	Result.r:=GetColorOne(FZQuantityRecursion div 4,FZQuantityRecursion,Color);
	Result.g:=GetColorOne(0,FZQuantityRecursion,Color);
	Result.b:=GetColorOne(FZQuantityRecursion div 2,FZQuantityRecursion,Color);
	end;
3:
	begin
	Color:=Trunc(RecNumber/FZQuantityRecursion*255);
	Result.r:=Color;
	Result.g:=Color;
	Result.b:=Color; 
	end;

4:
	begin
		Result.r := Color mod 256;
		Result.g := (SizeOf(FImage.BitMap.Data) * Color) div 255;
		Result.b := 0;	// nil
	end;

5:
	begin
		Result:=YellowPil();
	end;

6:
	begin
		Result.r:= trunc(abs(sin(Color) * Color));
		Result.g := GetColor(
			128, 
			383, 
			(trunc(abs(cos(Color) * Result.r)) mod 383)
		);
		if (Result.g < Result.r) then
			Result.b := 
				(sqr(Result.r)) DIV 255
		else
			Result.b := 
				(sqr(Result.g)) DIV 255;
	end;
7:
	begin
	Result.b:=GetColor(0,383,Color mod 383) div 2;
	Result.r:=GetColor(128,896,Color mod 896);
	Result.g:=GetColor(0,383,Color mod 383);
	end;
8:
	begin
	Result.g:=GetColor(0,383,Color mod 383) div 2;
	Result.r:=GetColor(128,896,Color mod 896);
	Result.b:=GetColor(0,383,Color mod 383);
	end;
9:
	begin
	Result.g:=GetColor(0,383,Color mod 383) div 2;
	Result.b:=GetColor(128,896,Color mod 896);
	Result.r:=GetColor(0,383,Color mod 383);
	end;
10:
	begin
	Result.r:=GetColor(0,383,Color mod 383) div 2;
	Result.b:=GetColor(128,896,Color mod 896);
	Result.g:=GetColor(0,383,Color mod 383);
	end;
11:
	begin
	Result.b:=GetColor(0,383,Color mod 383) div 2;
	Result.g:=GetColor(128,896,Color mod 896);
	Result.r:=GetColor(0,383,Color mod 383);
	end;
12:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.b);
	end;
13:
	begin
		Result:=YellowPil();
		SwapByte(Result.g,Result.b);
	end;
14:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.b);
		SwapByte(Result.g,Result.r);
	end;
15:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.b);
		SwapByte(Result.g,Result.b);
	end;
16:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.g);
	end;
else
	begin
	if RecNumber=FZQuantityRecursion then
		begin
		Result.r:=255;
		Result.g:=127;
		Result.b:=0;
		end
	else
		begin
		Result.r:=GetColor(200,400,Color mod 400);
		Result.g:=GetColor(0,200,Color mod 200);
		Result.b:=GetColor(100,300,Color mod 300);
		end;
	end;
end;
end;

procedure TSFractalMandelbrot.InitColor(const x,y:LongInt;const RecNumber:LongInt);
var
	MandelbrotPixel1,MandelbrotPixel2:TSMandelbrotPixel;
begin
if FAttitudeForThemeEnable then
	begin
	MandelbrotPixel1:=GetPixelColor(FTheme1,RecNumber);
	MandelbrotPixel2:=GetPixelColor(FTheme2,RecNumber);
	MandelbrotPixel1.r:=Round(MandelbrotPixel1.r*(1-FAttitudeForTheme)+FAttitudeForTheme*MandelbrotPixel2.r);
	MandelbrotPixel1.g:=Round(MandelbrotPixel1.g*(1-FAttitudeForTheme)+FAttitudeForTheme*MandelbrotPixel2.g);
	MandelbrotPixel1.b:=Round(MandelbrotPixel1.b*(1-FAttitudeForTheme)+FAttitudeForTheme*MandelbrotPixel2.b);
	end
else
	begin
	MandelbrotPixel1:=GetPixelColor(FColorScheme,RecNumber);
	end;
FImage.BitMap.Data[(Y*Width+X)*3+0]:=MandelbrotPixel1.r;
FImage.BitMap.Data[(Y*Width+X)*3+1]:=MandelbrotPixel1.g;
FImage.BitMap.Data[(Y*Width+X)*3+2]:=MandelbrotPixel1.b;
end;

function TSFractalMandelbrot.MandelbrotRec(const Number:TSComplexNumber;const dx,dy:single):Word;inline;
var
	i,ii:Byte;
begin
Result:=0;
for i:=0 to FSmosh-1 do
	for ii:=0 to FSmosh-1 do
		Result+=Rec(TSComplexNumber.Create(Number.x+i*dx/FSmosh,Number.y+ii*dy/FSmosh));
Result:=Round(Result/sqr(FSmosh));
if Result>FZQuantityRecursion then
	Result:=FZQuantityRecursion;
end;

procedure TSFractalMandelbrot.ImageDepict(_ThreadData:PSFractalMandelbrotThreadData);
var
	i,ii:Word;
	rY,rX,dX,dY:System.Real;//По идее это Wight и Height
	
	VReady:Boolean = False;
	VBufferNow:Boolean = False;
	
	VKolRec:LongInt;
	IsComponent:Boolean = False;
begin
if _ThreadData^.FPoint<>nil then
	IsComponent:=TSScreenComponent(_ThreadData^.FPoint) is TSScreenProgressBar;
rY:=abs(FView.y1-FView.y2);
rX:=abs(FView.x1-FView.x2);
dX:=rX/Width;
dY:=rY/Height;
//i:=_ThreadData^.h1;
//От h1 горизонтальной линии пикселей до h2 делаем
for i:=_ThreadData^.h1 to _ThreadData^.h2 do
//while i<=_ThreadData^.h2 do
//repeat
	begin
	_ThreadData^.NowPos:=i;
	ii:=Byte(VBufferNow);
	while (ii<Width) do
		begin
		VKolRec:=MandelbrotRec(TSComplexNumber.Create(FView.x1+dX*ii,FView.y1+dY*i),dx,dy);//(ii/FDepth)*r?
		InitColor(ii,i,VKolRec);
		_ThreadData^.VBuffer[VBufferNow][ii div 2]:=VKolRec=FZQuantityRecursion;
		if (VReady) then
			begin
			if (_ThreadData^.VBuffer[VBufferNow][ii div 2]) and (_ThreadData^.VBuffer[not VBufferNow][ii div 2]) and 
				(((not VBufferNow) and (ii<>0) and (_ThreadData^.VBuffer[not VBufferNow][(ii-1) div 2])) 
				or 
				((VBufferNow) and (ii<>Width-1) and (_ThreadData^.VBuffer[not VBufferNow][(ii+1) div 2]))) then
					InitColor(ii,i-1,FZQuantityRecursion)
			else
				InitColor(ii,i-1,
					MandelbrotRec(TSComplexNumber.Create(FView.x1+dX*ii,FView.y1+dY*(i-1)),dx,dy));
			end;
		ii+=2;
		end;
	
	VBufferNow:= not VBufferNow;
	if not VReady then
		VReady:=True;
	
	if PSDouble(_ThreadData^.FPoint)<>nil then
		if IsComponent then
			TSScreenProgressBar(_ThreadData^.FPoint).Progress:=(i-_ThreadData^.h1)/(_ThreadData^.h2-_ThreadData^.h1)
		else
			PSDouble(_ThreadData^.FPoint)^:=(i-_ThreadData^.h1)/(_ThreadData^.h2-_ThreadData^.h1);
	
	while _ThreadData^.FWait do
		begin
		if _ThreadData^.NewPos<>0 then
			begin
			_ThreadData^.h2:=_ThreadData^.NewPos-1;
			_ThreadData^.FWait:=False;
			_ThreadData^.NewPos:=0;
			end;
		Sleep(5);
		end;
	if i+1>_ThreadData^.h2 then
		Break;
	//Inc(i);
	end;
//until hh2<i;
ii:=Byte(VBufferNow);
while ii<Width do
	begin
	VKolRec:=Rec(TSComplexNumber.Create(FView.x1+dX*ii,FView.y1+dY*i));
	InitColor(ii,i,VKolRec);
	ii+=2;
	end;
end;

function TSFractalMandelbrot.Rec(Number:TSComplexNumber):Word;inline;
var 
	Depth2:Word = 0;
	Number2:TSComplexNumber;
begin
Number2:=Number;
While (Depth2<FZQuantityRecursion) and(sqrt(sqr(Number.x)+sqr(Number.y))<2) do
	begin
	Depth2+=1;
	Number:=Number**FZDegree;
	if FZMandelbrot then
		Number+=Number2
	else
		Number+=FZNumber;
	end;
Result:=Depth2;
end;

procedure TSFractalMandelbrot.ImageDepict();
var
	FractalMandelbrotThreadData : TSFractalMandelbrotThreadData;
begin
FractalMandelbrotThreadData.Create(nil, 0,Depth-1,nil,-1);
ImageDepict(@FractalMandelbrotThreadData);
end;

procedure TSFractalMandelbrot.Construct;
begin
inherited;
BeginConstruct();
ImageDepict();
ToTexture();
end;

end.
