{$INCLUDE Includes\SaGe.inc}

unit SaGeImagesBase;

interface

uses 
	crt
	,SaGeBase
	,SaGeBased
	,SaGeRenderConstants
	,SaGeResourseManager
	;

const 
	SGI_NONE =              $00000000;
	SGI_LOADING =           $00000001;
	SGI_LOAD = SGI_LOADING;
	SGI_SAVE =              $00000002;
	SGI_SAVEING = SGI_SAVE;
	SGI_BMP =               $00000003;
	SGI_SAVEING_COMPLITE =  $00000004;
	SGI_SAVE_COMPLITE =  SGI_SAVEING_COMPLITE;
	{$IFDEF WITHLIBPNG}
		SGI_PNG =               $00000005;
		{$ENDIF}
	SGI_JPG =               $00000006;
	SGI_JPEG = SGI_JPG;
	SGI_TGA =               $00000007;
	SGI_SGIA =              $00000008;
	SGI_DEFAULT =           $00000009;
type
	PSGPixel3b=^TSGPixel3b;
	PSGPixel = PSGPixel3b;
	TSGPixel3b=object
		r,g,b:Byte;
		procedure Import(const r1:Byte = 0;const g1:Byte = 0;const b1:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteLn;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	TSGColor3b=TSGPixel3b;
	TSGPixel=TSGPixel3b;
	SGPixel3b = TSGPixel3b;
	SGPixel = SGPixel3b;
	
	PSGPixel4b=^TSGPixel4b;
	TSGPixel4b=object(TSGPixel3b)
		a:Byte;
		procedure WriteLn();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure RGBToAlpha();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGPixelInfo=object
		FArray:packed array of 
			packed record 
				FProcent:real;
				FIdentifity:LongWord;
				end;
		procedure Get(const Old,New,Position:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGBitMap=class(TSGResourse)
			public
		FBitMap:PByte;
		
		FWidth:Cardinal;
		FHeight:Cardinal;
		
		FChannels:Cardinal;
		FSizeChannel:Cardinal;
		
		FFormatType:Cardinal;
		FDataType:Cardinal;
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure Clear;
		procedure CreateTypes(const Alpha:Cardinal = SG_UNKNOWN;const Grayscale:Cardinal = SG_UNKNOWN);
		procedure WriteInfo(const PredStr : TSGString = '');
		procedure SetWidth(const NewWidth:LongInt);
		procedure SetHeight(const NewHeight:LongInt);
		procedure SetBounds(const NewWidth,NewHeight:LongWord);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetBounds(const NewBound:LongWord);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function PixelsRGBA(const x,y:LongWord):PSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Width : Cardinal read FWidth write FWidth;
		property Height : Cardinal read FHeight write FHeight;
		property Channels : Cardinal read FChannels write FChannels;
		property BitDepth : Cardinal read FSizeChannel write FSizeChannel;
		property PixelFormat : Cardinal read FFormatType write FFormatType;
		property PixelType : Cardinal read FDataType write FDataType;
		property BitMap : PByte read FBitMap write FBitMap;
		end;

operator = (const a,b:TSGPixel3b):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const a:TSGPixel3b; const b:Real):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a,b:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator not (const a:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGGetExpansionFromImageFormat(const Fromat:TSGExByte):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

procedure TSGPixel4b.RGBToAlpha();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	max : byte;
	s : single;
begin
if (r >= b) and (r >= g) then
	max := r
else if (b >= r) and (b >= g) then
	max := b
else
	max := g;
if max = 0 then
	a := 0
else
	begin
	s := 255/max;
	r := trunc(s * r);
	g := trunc(s * g);
	b := trunc(s * b);
	a := max;
	end;
end;

procedure TSGPixel4b.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
System.Write(r,' ',g,' ',b,' ',a);
end;

procedure TSGPixel4b.WriteLn();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write();
System.WriteLn();
end;

function TSGBitMap.PixelsRGBA(const x,y:LongWord):PSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := @PSGPixel4b(FBitMap)[y* FWidth + x];
end;

function SGGetExpansionFromImageFormat(const Fromat:TSGExByte):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Fromat of
SGI_TGA:Result:='tga';
SGI_BMP:Result:='bmp';
SGI_JPG:Result:='jpg';
SGI_SGIA:Result:='sgia';
{$IFDEF WITHLIBPNG}
	SGI_PNG:Result:='png';
	{$ENDIF}
else
	Result:='';
end;
end;

procedure TSGPixel3b.Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
System.Write(r,' ',g,' ',b);
end;
procedure TSGPixel3b.WriteLn;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Write;
System.WriteLn;
end;

operator not (const a:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(255-a.r,255-a.g,255-a.b);
end;

operator + (const a,b:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	SGTruncUp((a.r+b.r)/2),
	SGTruncUp((a.g+b.g)/2),
	SGTruncUp((a.b+b.b)/2));
end;

procedure TSGPixel3b.Import(const r1:Byte = 0;const g1:Byte = 0;const b1:Byte = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
r:=r1;
g:=g1;
b:=b1;
end;

operator * (const a:TSGPixel3b; const b:Real):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(SGTruncUp(a.r*b),SGTruncUp(a.g*b),SGTruncUp(a.b*b));
end;

operator = (const a,b:TSGPixel3b):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin 
Result:=(a.r=b.r) and (a.g=b.g) and (a.b=b.b);
end;

procedure TSGPixelInfo.Clear;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(FArray,0);
FArray:=nil;
end;

procedure TSGPixelInfo.Get(const Old,New,Position:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
// Old - Old Width; 
// New - New Width;
// Position - i
var
	a,b:LongWord;
	c,// c - 1st position
	d,// d - 2nd position
	e
		:single;
	i:Word;
begin
SetLength(FArray,0);
a:=Position;
b:=a+1;
c:=(a/New)*Old;
d:=(b/New)*Old;
while abs(d-c)>0.001 do
	begin
	SetLength(FArray,Length(FArray)+1);
	FArray[High(FArray)].FProcent:=0;
	FArray[High(FArray)].FIdentifity:=0;
	
	if Trunc(c)=Trunc(d) then
		begin
		FArray[High(FArray)].FProcent:=Abs(d-c);
		FArray[High(FArray)].FIdentifity:=Trunc(c);
		c:=d;
		end
	else
		begin
		e:=Trunc(c)+1;
		FArray[High(FArray)].FProcent:=Abs(e-c);
		FArray[High(FArray)].FIdentifity:=Trunc(c);
		c:=e;
		end;
	end;
e:=0;
i:=0;
while i<=High(FArray) do
	begin
	e+=FArray[i].FProcent;
	Inc(i);
	end;
i:=0;
while i<=High(FArray) do
	begin
	FArray[i].FProcent:=FArray[i].FProcent/e;
	Inc(i);
	end;
end;

procedure TSGBitMap.SetBounds(const NewBound:LongWord);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetBounds(NewBound,NewBound);
end;

procedure TSGBitMap.SetBounds(const NewWidth,NewHeight:LongWord);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetHeight(NewHeight);
SetWidth(NewWidth);
end;

procedure TSGBitMap.SetHeight(const NewHeight:LongInt);
var
	NewBitMap:PByte = nil;
	I,II,III,IIII:LongWord;
	Info:TSGPixelInfo = (FArray:nil);
	a:single;
begin
SGLog.Sourse('TSGBitMap : Beginning to set new Height "'+SGStr(FHeight)+'" -> "'+SGStr(NewHeight)+'" (Width = '+SGStr(FWidth)+').');
if NewHeight=FHeight then
	begin
	SGLog.Sourse('TSGBitMap : Setting new Height not need.');
	Exit;
	end;

case FChannels*FSizeChannel of
24,32:
	begin
	GetMem(NewBitMap,FChannels*Width*NewHeight);
	for i:=0 to NewHeight-1 do
		begin
		Info.Get(Height,NewHeight,i);
		
		{for ii:=0 to High(Info.FArray) do
			begin
			SGLog.Sourse(SGStr(ii)+' '+SGStrReal(Info.FArray[ii].FProcent,3)+' '+SGStr(Info.FArray[ii].FIdentifity));
			end;}
		for ii:=0 to Width-1 do
			begin
			for iiii:=0 to FChannels-1 do
				begin
				a:=0;
				for iii:=0 to High(Info.FArray) do
					a+=FBitMap[
						(ii+Info.FArray[iii].FIdentifity*Width)
						*FChannels+iiii]
						*Info.FArray[iii].FProcent;
				NewBitMap[(i*Width+ii)*FChannels+iiii]:=Round(a);
				end;
			end;
		end;
	FreeMem(FBitMap);
	FBitMap:=NewBitMap;
	FHeight:=NewHeight;
	Info.Clear;
	end;
end;
end;

procedure TSGBitMap.SetWidth(const NewWidth:LongInt);
var
	NewBitMap:PByte = nil;
	I,II,III,IIII:LongWord;
	Info:TSGPixelInfo = (FArray:nil);
	a:single;
begin
SGLog.Sourse('TSGBitMap : Beginning to set new Width "'+SGStr(FWidth)+'" -> "'+SGStr(NewWidth)+'" (Height = '+SGStr(FHeight)+').');
if NewWidth=FWidth then
	begin
	SGLog.Sourse('TSGBitMap : Setting new Width not need.');
	Exit;
	end;

case FChannels*FSizeChannel of
24,32:
	begin
	GetMem(NewBitMap,FChannels*NewWidth*Height);
	for i:=0 to NewWidth-1 do
		begin
		Info.Get(Width,NewWidth,i);
		for ii:=0 to Height-1 do
			begin
			for iiii:=0 to FChannels-1 do
				begin
				a:=0;
				for iii:=0 to High(Info.FArray) do
					a+=FBitMap[(Info.FArray[iii].FIdentifity+ii*Width)*FChannels+iiii]*Info.FArray[iii].FProcent;
				NewBitMap[(i+ii*NewWidth)*FChannels+iiii]:=Round(a);
				end;
			end;
		end;
	FreeMem(FBitMap);
	FBitMap:=NewBitMap;
	FWidth:=NewWidth;
	Info.Clear;
	end;
end;
end;

procedure TSGBitMap.WriteInfo(const PredStr : TSGString = '');
begin
WriteLn('TSGBitMap__WriteInfo()');
WriteLn(PredStr,' Width    = ',FWidth);
WriteLn(PredStr,' Height   = ',FHeight);
WriteLn(PredStr,' Channels = ',FChannels);
WriteLn(PredStr,' BitDepth = ',FSizeChannel);
TextColor(15);
WriteLn(PredStr,' Size     = ',SGGetSizeString(FWidth*FHeight*FChannels*FSizeChannel div 8,'EN'));
TextColor(7);
end;

procedure TSGBitMap.CreateTypes(const Alpha:Cardinal = SG_UNKNOWN;const Grayscale:Cardinal = SG_UNKNOWN);
begin
FFormatType:=0;
FDataType:=0;
case FChannels of 
1:
	begin 
	if Grayscale=SG_TRUE then 
		FFormatType:=SGR_LUMINANCE
	else
		if Alpha=SG_TRUE then
			FFormatType:=SGR_ALPHA
		else
			if (Alpha=SG_FALSE) and (Grayscale=SG_FALSE) then
				FFormatType:=SGR_INTENSITY
			else
				FFormatType:=SGR_RED;
	end;
2:
	begin
	//if (Grayscale=SG_TRUE) and (Alpha=SG_TRUE) then
		FFormatType:=SGR_LUMINANCE_ALPHA;
		
	end;
3:
	begin
	FFormatType:=SGR_RGB;
	end;
4:
	begin
	FFormatType:=SGR_RGBA;
	end;
else
	FFormatType:=0;
end;
case FSizeChannel of
8:
	FDataType:=SGR_UNSIGNED_BYTE;
else
	FDataType:=SGR_BITMAP;
end;
end;

procedure TSGBitMap.Clear;
begin
if FBitMap<>nil then
	begin
	FreeMem(FBitMap);
	FBitMap:=nil;
	end;
FWidth:=0;
FHeight:=0;
FSizeChannel:=0;
FFormatType:=0;
FDataType:=0;
end;

constructor TSGBitMap.Create();
begin
inherited;
FBitMap:=nil;
Clear;
end;

destructor TSGBitMap.Destroy();
begin
Clear;
inherited;
end;

end.
