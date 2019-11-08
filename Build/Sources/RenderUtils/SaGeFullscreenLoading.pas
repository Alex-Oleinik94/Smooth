{$INCLUDE SaGe.inc}

unit SaGeFullscreenLoading;

interface

uses
	 SaGeBase
	,SaGeRenderBase
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeCommonStructs
	,SaGeFont
	;

type
	TSGLType = (SGBeforeLoading, SGInLoading, SGAfterLoading);
	//����� ��������.
	TSGLoading = class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		procedure Paint(); override;
		procedure DeleteRenderResources(); override;
		procedure LoadRenderResources(); override;
		class function Supported(const _Context : ISGContext) : TSGBoolean; override;
			private
		FProjectionAngle      : TSGSingle;     //���� �������� ������
		FProjectionAngleShift : TSGSingle;     //�������� ��������� ���� �������� ������
		FAngle                : TSGSingle;     //��������� ���� ��������
		FAngleShift           : TSGSingle;     //�������� ��������
		FProgress             : TSGSingle;     //[0..1]
		FCountLines           : TSGLongWord;   //���������� ���������� ���������
		FFont                 : TSGFont;       //����� ��� ������� ���������
		FArrayOfLines:packed array of          //������ ��������
			packed record
			FLengths:packed array of TSGSingle;//����� �������� �������� ������
			FSpeed  :TSGSingle;                //�������� �������� � �������� ������
			FWidth  :TSGSingle;                //������ ������� � ��������
		    end;
		FProgressIsSet        : Boolean;       //���� ������������ �� ������������ �� ���� ��������, ��
		                                       //����������� �����, ��� ������ ������������ ������ ���� ���������,
		                                       //���� ���������, �� ������������ �������� ������������
		FMaxRadius            : TSGSingle;     //������������ ������ (������������ ������ �������)
		FAlpha                : TSGSingle;     //��� ��� ������ � ����� ��������. ����� ������ �������.
		FType                 : TSGLType;      //��� ������ �������� � ������ ������ �������.
		procedure CallAction();                //��� �������������� �������, �� ������� � ������
		procedure SetProgress(const NewProgress:TSGSingle);
			public
		property Progress : TSGSingle read FProgress write SetProgress;
		property Alpha : TSGFloat32 read FAlpha;
		end;

procedure SGKill(var Loading : TSGLoading); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeMathUtils
	;

procedure SGKill(var Loading : TSGLoading); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Loading <> nil then
	begin
	Loading.Destroy();
	Loading := nil;
	end;
end;

procedure TSGLoading.SetProgress(const NewProgress:TSGSingle);
begin
if not FProgressIsSet then
	FProgressIsSet:=True;
FProgress:=NewProgress;
end;

procedure TSGLoading.CallAction();
var
	i, iii : TSGWord;
	iiii   : TSGSingle;
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


constructor TSGLoading.Create(const VContext : ISGContext);
var
	i :    TSGLongWord;
begin
inherited Create(VContext);
FProgress:=0;
FCountLines:=14;
if FCountLines mod 2 = 1 then
	FCountLines+=1;
FAngle:=Random(360);
FProjectionAngle:=600;
FProjectionAngleShift:=SGRandomOne()*0.01; //��� � ��������, ������� ��� ����
FAngleShift:=SGRandomOne()*0.7;            //� ��� � ��������
FMaxRadius:=280;
SetLength(FArrayOfLines,FCountLines);
for i:=0 to FCountLines-1 do
	begin
	FArrayOfLines[i].FLengths:=nil;
	FArrayOfLines[i].FSpeed:=(Random(400)+100)/200;
	FArrayOfLines[i].FWidth:=360/FCountLines;
	end;
FFont:=TSGFont.Create(SGFontDirectory + DirectorySeparator + 'Times New Roman.sgf');
FFont.SetContext(Context);
FFont.Loading();
FProgressIsSet:=False;
FAlpha:=0;
FType:=SGBeforeLoading;
end;


destructor TSGLoading.Destroy();
var
	i : TSGWord;
begin
if FArrayOfLines<>nil then
	begin
	for i:=0 to High(FArrayOfLines) do
		if FArrayOfLines[i].FLengths<>nil then
			SetLength(FArrayOfLines[i].FLengths,0);
	SetLength(FArrayOfLines,0);
	end;
if FFont <> nil then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
inherited Destroy();
end;

procedure TSGLoading.Paint();
var
	FColor : TSGColor4f;

procedure MiniDraw(VProjectionAngle, VRadius : TSGSingle);
var
	i,ii : TSGWord;
	iii  : TSGSingle;

function DrawFirst():TSGBoolean;
begin
Result:=FArrayOfLines[i].FLengths[0]>6;
end;

// For quik job
var
	VVCosAngle, VVSinAngle, VVCosAngle2, VVSinAngle2 : TSGSingle;

begin
VVSinAngle:=sin(VProjectionAngle);
VVSinAngle2:=sin(Pi*FProjectionAngle);
VVCosAngle:=cos(VProjectionAngle);
VVCosAngle2:=cos(Pi*FProjectionAngle);

Render.Color(FColor);
Render.InitOrtho2d(
	-Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	 Render.Height/2+(VVCosAngle+VVCosAngle2)*VRadius,
	 Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	-Render.Height/2+(VVCosAngle+VVCosAngle2)*VRadius);
FFont.DrawFontFromTwoVertex2f(SGStrReal(100*FProgress,0)+'%',
	SGVertex2fImport(-35,-FFont.FontHeight/2),
	SGVertex2fImport(35,FFont.FontHeight/2));

Render.InitOrtho2d(
	-Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	-Render.Height/2-(VVCosAngle+VVCosAngle2)*VRadius,
	Render.Width/2-(VVSinAngle+VVSinAngle2)*VRadius,
	Render.Height/2-(VVCosAngle+VVCosAngle2)*VRadius);
Render.Rotatef(FAngle*FAlpha,0,0,1);
for i:=0 to FCountLines-1 do
	begin
	iii:=50+Byte(not DrawFirst())*FArrayOfLines[i].FLengths[0];
	for ii:=Byte(not DrawFirst()) to High(FArrayOfLines[i].FLengths) do
		begin
		VVCosAngle:=cos(FArrayOfLines[i].FWidth/180*pi);
		VVSinAngle:=sin(FArrayOfLines[i].FWidth/180*pi);
		
		Render.BeginScene(SGR_LINE_LOOP);
		Render.Color(FColor.WithAlpha(FAlpha).WithAlpha(1-(iii+FArrayOfLines[i].FLengths[ii]-6)/FMaxRadius+50/FMaxRadius));
		Render.Vertex2f(iii+FArrayOfLines[i].FLengths[ii]-6,6);
		Render.Vertex2f((iii+FArrayOfLines[i].FLengths[ii]-6)*VVCosAngle,
			(iii+FArrayOfLines[i].FLengths[ii]-6)*VVSinAngle);
		Render.Color(FColor.WithAlpha(FAlpha).WithAlpha(1-iii/FMaxRadius+50/FMaxRadius));
		Render.Vertex2f(iii*VVCosAngle,iii*VVSinAngle);
		Render.Vertex2f(iii,6);
		Render.EndScene();
		
		iii+=FArrayOfLines[i].FLengths[ii];
		end;
	Render.Rotatef(FArrayOfLines[i].FWidth,0,0,1);
	end;
end;

const
	RadiusCentre      = 200;
	QuantityMiniDraws = 3;

var
	i : TSGWord;
	r : TSGSingle;
	depthEnabled : TSGBool = False;
begin
CallAction();
FCOlor := (SGVertex4fImport(1,0,0,1) * (1-FProgress) + SGVertex4fImport(0,1,0,1) * FProgress);
TSGVertex3f(FCOlor) := FCOlor.Normalized();
FColor.AddAlpha(FAlpha);
Render.LineWidth(1);

depthEnabled := Render.IsEnabled(SGR_DEPTH_TEST);
if depthEnabled then
	Render.Disable(SGR_DEPTH_TEST);

r := FProjectionAngle;
for i := 1 to QuantityMiniDraws do
	begin
	r += 2 * pi / QuantityMiniDraws;
	MiniDraw(r, RadiusCentre * (1 - FProgress));
	end;

if depthEnabled then
	Render.Enable(SGR_DEPTH_TEST);

FAngle+=FAngleShift*Context.ElapsedTime;
FProjectionAngle+=FProjectionAngleShift*Context.ElapsedTime;
case FType of
SGBeforeLoading:
	begin
	if FAlpha<1 then
		begin
		FAlpha+=0.007*Context.ElapsedTime;
		if FAlpha>1 then
			begin
			FAlpha:=1.00001;
			FType:=SGInLoading;
			end;
		end;
	end;
SGInLoading:
	begin
	if FProgress >= 1 then
		begin
		FType:=SGAfterLoading;
		FProjectionAngle:=600;
		end;
	end;
SGAfterLoading:
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
	if FType = SGInLoading then
		FProgress+=0.0003*(Random(5)+1)*Context.ElapsedTime; 
	if (FType = SGAfterLoading) and (FAlpha<0) then
		begin
		FProgress:=0;
		FType:=SGBeforeLoading;
		FProjectionAngleShift:=SGRandomOne()*0.01;
		FAngleShift:=SGRandomOne()*0.7;
		FProjectionAngle:=600;
		end;
	end;
end;

class function TSGLoading.ClassName():string;
begin
Result := '������ ��������';
end;

procedure TSGLoading.DeleteRenderResources();
begin
FFont.DeleteRenderResources();
inherited;
end;

procedure TSGLoading.LoadRenderResources();
begin
FFont.LoadRenderResources();
inherited;
end;

class function TSGLoading.Supported(const _Context : ISGContext) : TSGBoolean;
begin
Result := True;
end;

end.