{$INCLUDE Smooth.inc}

unit SmoothFullscreenLoading;

interface

uses
	 SmoothBase
	,SmoothRenderBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothCommonStructs
	,SmoothFont
	,SmoothScreenClasses
	;

type
	TSLType = (SBeforeLoading, SInLoading, SAfterLoading);
	//Класс загрузки.
	TSLoading = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		procedure Paint(); override;
		procedure DeleteRenderResources(); override;
		procedure LoadRenderResources(); override;
		class function Supported(const _Context : ISContext) : TSBoolean; override;
			private
		FProjectionAngle      : TSFloat32;     //Угол поворота центра
		FProjectionAngleShift : TSFloat32;     //Скорость узманения угла поворота центра
		FAngle                : TSFloat32;     //Начальный угол поворота
		FAngleShift           : TSFloat32;     //Срорость кручения
		FProgress             : TSFloat32;     //[0..1]
		FCountLines           : TSLongWord;   //Количество разделений экранчика
		FFont                 : TSFont;       //Шрифт для надписи процентов
		FArrayOfLines:packed array of          //Массив дорожкок
			packed record
			FLengths:packed array of TSFloat32;//Длины кусочков дорожкок экрана
			FSpeed  :TSFloat32;                //Скорость убывания в середину экрана
			FWidth  :TSFloat32;                //Ширина дорожки в градусах
		    end;
		FProgressIsSet        : Boolean;       //Если "пользователь" не устанавливал не разу прогресс, то
		                                       //Запускатеся режим, где просто показывается работа этой программы,
		                                       //Если установил, то отображается прогресс "пользователя"
		FMaxRadius            : TSFloat32;     //Максимальный радиус (максимальная длинна дорожек)
		FAlpha                : TSFloat32;     //Это для начала и конца загрузки. Чтобы "плавно уходило".
		FType                 : TSLType;      //Тип работы загрузки в данный момент времени.
		FRadiusCentre         : TSMaxEnum;
		FQuantityParts        : TSMaxEnum;
		FPartsSigns           : packed array of TSFloat32;
		FHintLabel            : TSScreenLabel;
		procedure CallAction();                //Здесь обрабатываются дорожки, их кусочки и ширины
		procedure SetProgress(const NewProgress:TSFloat32);
		procedure MiniDrawsSignsUpDate();
		procedure PaintPart(const VProjectionAngle, VRadius : TSFloat32; const Color : TSColor4f; const Sign : TSFloat32);
			public
		property Progress : TSFloat32 read FProgress write SetProgress;
		property Alpha : TSFloat32 read FAlpha;
		end;

procedure SKill(var Loading : TSLoading); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothMathUtils
	,SmoothScreenBase
	;

procedure SKill(var Loading : TSLoading); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Loading <> nil then
	begin
	Loading.Destroy();
	Loading := nil;
	end;
end;

procedure TSLoading.SetProgress(const NewProgress:TSFloat32);
begin
if not FProgressIsSet then
	FProgressIsSet:=True;
FProgress:=NewProgress;
end;

procedure TSLoading.CallAction();
var
	i, iii : TSUInt16;
	iiii   : TSFloat32;
begin
for i:=0 to FCountLines-1 do
	begin
	if FArrayOfLines[i].FLengths<>nil then
		begin
		iiii:=FArrayOfLines[i].FSpeed*Context.ElapsedTime;
		while iiii<>0 do
			begin
			if FArrayOfLines[i].FLengths[0]>iiii then
				begin
				FArrayOfLines[i].FLengths[0]-=iiii;
				iiii:=0;
				end
			else
				begin
				iiii-=FArrayOfLines[i].FLengths[0];
				for iii:=0 to High(FArrayOfLines[i].FLengths)-1 do
					FArrayOfLines[i].FLengths[iii]:=FArrayOfLines[i].FLengths[iii+1];
				SetLength(FArrayOfLines[i].FLengths,Length(FArrayOfLines[i].FLengths)-1);
				end;
			end;
		end;
	iiii:=0;
	if FArrayOfLines[i].FLengths<>nil then
	for iii:=0 to High(FArrayOfLines[i].FLengths) do
		iiii+=FArrayOfLines[i].FLengths[iii];
	while iiii<FMaxRadius do
		begin
		if FArrayOfLines[i].FLengths<>nil then
			SetLength(FArrayOfLines[i].FLengths,Length(FArrayOfLines[i].FLengths)+1)
		else
			SetLength(FArrayOfLines[i].FLengths,1);
		FArrayOfLines[i].FLengths[High(FArrayOfLines[i].FLengths)]:=Random(100)+6;
		iiii+=FArrayOfLines[i].FLengths[High(FArrayOfLines[i].FLengths)];
		end;
	if i mod 2 = 0 then
		begin
		iiii:=(Random(100)-49)/200;
		if not(((FArrayOfLines[i].FWidth+iiii)>2*300/FCountLines) or ((FArrayOfLines[i+1].FWidth-iiii)>2*300/FCountLines)) then
			begin
			FArrayOfLines[i].FWidth+=iiii;
			FArrayOfLines[i+1].FWidth-=iiii;
			end;
		end;
	end;
end;

procedure TSLoading.MiniDrawsSignsUpDate();
var
	Index : TSMaxEnum;
begin
SetLength(FPartsSigns, FQuantityParts);
for Index := 0 to FQuantityParts - 1 do
	FPartsSigns[Index] := SRandomOne();
end;

constructor TSLoading.Create(const VContext : ISContext);
var
	Index : TSMaxEnum;
begin
inherited Create(VContext);
FRadiusCentre := 200;
FQuantityParts := 5;
MiniDrawsSignsUpDate();
FProgress:=0;
FCountLines:=14;
if FCountLines mod 2 = 1 then
	FCountLines+=1;
FAngle:=Random(360);
FProjectionAngle:=600;
FProjectionAngleShift := SRandomOne() * 0.01; //Здесь в радианах, поэтому так мало
FAngleShift := SRandomOne() * 0.7;            //А здесь в градусах
FMaxRadius:=280;
SetLength(FArrayOfLines,FCountLines);
for Index := 0 to FCountLines - 1 do
	begin
	FArrayOfLines[Index].FLengths := nil;
	FArrayOfLines[Index].FSpeed := (Random(400) + 100) / 200;
	FArrayOfLines[Index].FWidth := 360 / FCountLines;
	end;
FFont := SCreateFontFromFile(Context, SFontDirectory + DirectorySeparator + 'Times New Roman.Sf');
FProgressIsSet:=False;
FAlpha:=0;
FType:=SBeforeLoading;
FHintLabel := SCreateLabel(Screen, 'progress', 
	Render.Width - 90 - 10, Render.Height - FFont.FontHeight + 2 - 10, 90, FFont.FontHeight + 2,
	FFont, [SAnchRight, SAnchBottom], True, True);
FHintLabel.TextPosition := False;
end;

destructor TSLoading.Destroy();
var
	i : TSUInt16;
begin
if FArrayOfLines<>nil then
	begin
	for i:=0 to High(FArrayOfLines) do
		if FArrayOfLines[i].FLengths<>nil then
			SetLength(FArrayOfLines[i].FLengths,0);
	SetLength(FArrayOfLines,0);
	end;
SetLength(FPartsSigns, 0);
SKill(FFont);
SKill(FHintLabel);
inherited;
end;

procedure TSLoading.PaintPart(const VProjectionAngle, VRadius : TSFloat32; const Color : TSColor4f; const Sign : TSFloat32);
var
	i, ii : TSUInt16;
	iii   : TSFloat32;

function DrawFirst():TSBoolean;
begin
Result:=FArrayOfLines[i].FLengths[0]>6;
end;

var
	VVCosAngle, VVSinAngle, VVCosAngle2, VVSinAngle2 : TSFloat32; // for quik job
begin
VVSinAngle:=sin(VProjectionAngle);
VVSinAngle2:=sin(Pi*FProjectionAngle);
VVCosAngle:=cos(VProjectionAngle);
VVCosAngle2:=cos(Pi*FProjectionAngle);

Render.Color(Color);
Render.InitOrtho2d(
	-Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	 Render.Height/2+(VVCosAngle+VVCosAngle2)*VRadius,
	 Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	-Render.Height/2+(VVCosAngle+VVCosAngle2)*VRadius);
FFont.DrawFontFromTwoVertex2f(SStrReal(100*FProgress,0)+'%',
	SVertex2fImport(-35,-FFont.FontHeight/2),
	SVertex2fImport(35,FFont.FontHeight/2));

Render.InitOrtho2d(
	-Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	-Render.Height/2-(VVCosAngle+VVCosAngle2)*VRadius,
	Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	Render.Height/2-(VVCosAngle+VVCosAngle2)*VRadius);
Render.Rotatef(FAngle*FAlpha*Sign,0,0,1);
for i:=0 to FCountLines-1 do
	begin
	iii:=50+Byte(not DrawFirst())*FArrayOfLines[i].FLengths[0];
	VVCosAngle:=cos(FArrayOfLines[i].FWidth/180*pi);
	VVSinAngle:=sin(FArrayOfLines[i].FWidth/180*pi);
	for ii:=Byte(not DrawFirst()) to High(FArrayOfLines[i].FLengths) do
		begin
		Render.BeginScene(SR_LINE_LOOP);
		Render.Color(Color.WithAlpha(FAlpha).WithAlpha(1-(iii+FArrayOfLines[i].FLengths[ii]-6)/FMaxRadius+50/FMaxRadius));
		Render.Vertex2f(iii+FArrayOfLines[i].FLengths[ii]-6,6);
		Render.Vertex2f((iii+FArrayOfLines[i].FLengths[ii]-6)*VVCosAngle,
			(iii+FArrayOfLines[i].FLengths[ii]-6)*VVSinAngle);
		Render.Color(Color.WithAlpha(FAlpha).WithAlpha(1-iii/FMaxRadius+50/FMaxRadius));
		Render.Vertex2f(iii*VVCosAngle,iii*VVSinAngle);
		Render.Vertex2f(iii,6);
		Render.EndScene();
		
		iii+=FArrayOfLines[i].FLengths[ii];
		end;
	Render.Rotatef(FArrayOfLines[i].FWidth,0,0,1);
	end;
end;

procedure TSLoading.Paint();
var
	Color : TSColor4f;
	i : TSUInt16;
	r : TSFloat32;
	depthEnabled : TSBool = False;
begin
CallAction();
Color := SVertex4fImport(1,0,0,1) * (1-FProgress) + SVertex4fImport(0,1,0,1) * FProgress;
TSVertex3f(Color) := Color.Normalized();
Color.AddAlpha(FAlpha);
Render.LineWidth(1);

depthEnabled := Render.IsEnabled(SR_DEPTH_TEST);
if depthEnabled then
	Render.Disable(SR_DEPTH_TEST);

r := FProjectionAngle;
for i := 1 to FQuantityParts do
	begin
	r += 2 * pi / FQuantityParts;
	PaintPart(r * FPartsSigns[i - 1], FRadiusCentre * (1 - FProgress) * FPartsSigns[i - 1], Color, FPartsSigns[i - 1]); // don't now what is it ...
	end;

if depthEnabled then
	Render.Enable(SR_DEPTH_TEST);

FAngle+=FAngleShift*Context.ElapsedTime;
FProjectionAngle+=FProjectionAngleShift*Context.ElapsedTime;
case FType of
SBeforeLoading:
	begin
	if FAlpha<1 then
		begin
		FAlpha+=0.007*Context.ElapsedTime;
		if FAlpha>1 then
			begin
			FAlpha:=1.00001;
			FType:=SInLoading;
			end;
		end;
	FHintLabel.Visible := True;
	FHintLabel.Caption := SStrReal(FProgress * 100, 2) + '%';
	end;
SInLoading:
	begin
	if FProgress >= 1 then
		begin
		FType:=SAfterLoading;
		FProjectionAngle:=600;
		MiniDrawsSignsUpDate();
		FHintLabel.Caption := '100%';
		FHintLabel.Visible := False;
		end
	else
		FHintLabel.Caption := SStrReal(FProgress * 100, 2) + '%';
	end;
SAfterLoading:
	begin
	if FAlpha>0 then
		begin
		FAlpha-=0.007*Context.ElapsedTime;
		if FAlpha<0 then
			FAlpha:=-0.00001;
		end;
	end;
end;

if not FProgressIsSet then
	begin
	if FType = SInLoading then
		FProgress+=0.0003*(Random(5)+1)*Context.ElapsedTime; 
	if (FType = SAfterLoading) and (FAlpha<0) then
		begin
		FProgress:=0;
		FType:=SBeforeLoading;
		FProjectionAngleShift:=SRandomOne()*0.01;
		FAngleShift:=SRandomOne()*0.7;
		FProjectionAngle:=600;
		end;
	end;
end;

class function TSLoading.ClassName():string;
begin
Result := 'Модель загрузки';
end;

procedure TSLoading.DeleteRenderResources();
begin
FFont.DeleteRenderResources();
inherited;
end;

procedure TSLoading.LoadRenderResources();
begin
FFont.LoadRenderResources();
inherited;
end;

class function TSLoading.Supported(const _Context : ISContext) : TSBoolean;
begin
Result := True;
end;

end.
