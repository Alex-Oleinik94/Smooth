{$I Includes\SaGe.inc}
unit SaGeLoading;
interface
uses
	SaGeBase
	,SaGeRender
	,SaGeContext
	,SaGeCommon
	,SaGeUtils
	;
type
	TSGLoading=class(TSGDrawClass)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
		procedure Draw();override;
			private
		FAngle:Single;                      //Начальный угол поворота
		FAngleShift:Single;                 //Срорость кручения
		FProgress:Single;                   //[0..1]
		FCountLines:LongWord;               //Количество разделений экранчика
		FFont:TSGFont;                      //Шрифт для надписи процентов
		FNapAngleShift:Boolean;             //В какую сторону крутиться
		FArrayOfLines:packed array of       //Массив дорожкок
			packed record
			FLengths:packed array of Word;  //Длины кусочков дорожкок экрана
			FSpeed:Word;                    //Скорость убывания в середину экрана
			FWidth:Single;                  //Ширина дорожки в градусах
			end;
		procedure CallAction();             //Тут обрабатываются дорожки, их кусочки и ширины
			public
		property Progress:Single read FProgress write FProgress;
		end;

implementation

procedure TSGLoading.CallAction();
var
	i,ii,iii:Word;
	iiii:Single;
begin
for i:=0 to FCountLines-1 do
	begin
	if FArrayOfLines[i].FLengths<>nil then
		begin
		ii:=FArrayOfLines[i].FSpeed*Context.ElapsedTime;
		while ii<>0 do
			begin
			if FArrayOfLines[i].FLengths[0]>ii then
				begin
				FArrayOfLines[i].FLengths[0]-=ii;
				ii:=0;
				end
			else
				begin
				ii-=FArrayOfLines[i].FLengths[0];
				for iii:=0 to High(FArrayOfLines[i].FLengths)-1 do
					FArrayOfLines[i].FLengths[iii]:=FArrayOfLines[i].FLengths[iii+1];
				SetLength(FArrayOfLines[i].FLengths,Length(FArrayOfLines[i].FLengths)-1);
				end;
			end;
		end;
	ii:=0;
	if FArrayOfLines[i].FLengths<>nil then
	for iii:=0 to High(FArrayOfLines[i].FLengths) do
		ii+=FArrayOfLines[i].FLengths[iii];
	while ii<1000 do
		begin
		if FArrayOfLines[i].FLengths<>nil then
			SetLength(FArrayOfLines[i].FLengths,Length(FArrayOfLines[i].FLengths)+1)
		else
			SetLength(FArrayOfLines[i].FLengths,1);
		FArrayOfLines[i].FLengths[High(FArrayOfLines[i].FLengths)]:=Random(100)+6;
		ii+=FArrayOfLines[i].FLengths[High(FArrayOfLines[i].FLengths)];
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


constructor TSGLoading.Create(const VContext:PSGContext);
var
	i:LongWord;
begin
inherited Create(VContext);
FProgress:=0;
FCountLines:=15;
if FCountLines mod 2 = 1 then
	FCountLines+=1;
FAngle:=Random(360);
FAngleShift:=0.4;
SetLength(FArrayOfLines,FCountLines);
for i:=0 to FCountLines-1 do
	begin
	FArrayOfLines[i].FLengths:=nil;
	FArrayOfLines[i].FSpeed:=Random(2)+1;
	FArrayOfLines[i].FWidth:=360/FCountLines;
	end;
FFont:=TSGFont.Create(SGFontDirectory+Slash+'Times New Roman.bmp');
FFont.SetContext(FContext);
FFont.Loading();
FNapAngleShift:=Boolean(Random(2));
end;


destructor TSGLoading.Destroy();
var
	i,ii:Word;
begin
if FArrayOfLines<>nil then
	begin
	for i:=0 to High(FArrayOfLines) do
		if FArrayOfLines[i].FLengths<>nil then
			SetLength(FArrayOfLines[i].FLengths,0);
	SetLength(FArrayOfLines,0);
	end;
inherited Destroy();
end;

procedure TSGLoading.Draw();
var
	i,ii,iii:Word;
function DrawFirst():Boolean;
begin
Result:=FArrayOfLines[i].FLengths[0]>6;
end;
var
	FCOlor:TSGColor4f;
begin
CallAction();

FCOlor:=(SGColorImport(1,0,0)*(1-FProgress)+SGColorImport(0,1,0)*FProgress);
FCOlor.Normalize();
FColor.Color(Render);

Render.InitOrtho2d(-Context.Width/2,Context.Height/2,Context.Width/2,-Context.Height/2);
FFont.DrawFontFromTwoVertex2f(SGStrReal(100*FProgress,1)+'%',
	SGVertex2fImport(-35,-FFont.FontHeight/2),
	SGVertex2fImport(35,FFont.FontHeight/2));

Render.InitOrtho2d(-Context.Width/2,-Context.Height/2,Context.Width/2,Context.Height/2);
Render.Rotatef(FAngle,0,0,1);
for i:=0 to FCountLines-1 do
	begin
	iii:=50+Byte(not DrawFirst())*FArrayOfLines[i].FLengths[0];
	for ii:=Byte(not DrawFirst()) to High(FArrayOfLines[i].FLengths) do
		begin
		Render.BeginScene(SGR_LINE_LOOP);
		Render.Vertex2f(iii,6);
		Render.Vertex2f(iii+FArrayOfLines[i].FLengths[ii]-6,6);
		Render.Vertex2f((iii+FArrayOfLines[i].FLengths[ii]-6)*cos(FArrayOfLines[i].FWidth/180*pi),
			(iii+FArrayOfLines[i].FLengths[ii]-6)*sin(FArrayOfLines[i].FWidth/180*pi));
		Render.Vertex2f(iii*cos(FArrayOfLines[i].FWidth/180*pi),iii*sin(FArrayOfLines[i].FWidth/180*pi));
		iii+=FArrayOfLines[i].FLengths[ii];
		Render.EndScene();
		end;
	Render.Rotatef(FArrayOfLines[i].FWidth,0,0,1);
	end;
if FNapAngleShift then
	FAngle+=FAngleShift*Context.ElapsedTime
else
	FAngle-=FAngleShift*Context.ElapsedTime;
(*FAKE, NEED TO ERASE*)FProgress+=0.001; if FProgress>1 then FProgress:=0;
end;

class function TSGLoading.ClassName():string;
begin
Result:='Загрузка...';
end;

end.
