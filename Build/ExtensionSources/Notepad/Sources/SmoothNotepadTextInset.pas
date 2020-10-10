{$INCLUDE Smooth.inc}

unit SmoothNotepadTextInset;

interface

uses 
	 Crt
	,SysUtils
	,Classes
	
	,SmoothBase
	,SmoothContext
	,SmoothScreen
	,SmoothFont
	,SmoothCommonStructs
	,SmoothRender
	,SmoothRenderBase
	,SmoothContextClasses
	,SmoothMakefileReader
	,SmoothResourceManager
	,SmoothNotepad
	,SmoothScreenBase
	,SmoothCursor
	;

type
	TSNTextInsetFileString = object
		FString : TSString;
		FColors : TSVertex4fList;
		end;
	
	TSNTextInsetFileStrings = type packed array of TSNTextInsetFileString;
	
	TSNTextInset = class(TSNInset)
			public
		constructor Create();
		destructor Destroy();override;
			private
		FFileName : TSString;
		FFile : TSNTextInsetFileStrings;
		FScrolTimer : TSFloat;
		
		FCursorOverText : TSBoolean;
		FCursorOverTextPrev : TSBoolean;
		
		FTextCursor : record
			FLine : TSLongWord;
			FColumn : TSLongWord;
			FTimer : TSFloat;
			end;
		
		FSystemWords : TSString;
		FSystemSeparators : TSString;
			private
		function GetTextColor(const VString : TSString) : TSVertex4fList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure UpdateLineColor(const Index : TSLongWord);
		procedure RealizeSystemSimbols();
		procedure SetFile(const VFileName : TSString);
		procedure LoadFile();
		function CountLines() : TSLongWord;
		procedure MoveVertical(const Param : TSFloat);
		procedure StandardizateView();
			public
		procedure GoToPosition(const Line, Column : TSLongWord);
		property FileName : TSString write SetFile;
			public
		procedure Paint();override;
		procedure UpDate();override;
		procedure Resize();override;
		end;

implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	,SmoothEncodingUtils
	,SmoothFileUtils
	,SmoothArithmeticUtils
	,SmoothCommon
	,SmoothContextUtils
	
	,StrMan
	;

function TSNTextInset.GetTextColor(const VString : TSString) : TSVertex4fList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	WordList : packed array of TSString = nil;
	WordCountSimbols : packed array of TSByte = nil;
	Index : TSLongWord;

//{$DEFINE TI_COLOR_DEBUG}

procedure FunctionResult (const ResultIndex : TSLongWord; const Color : TSColor4f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[ResultIndex] := Color;
end;

procedure SimbolProv(const LC, UC: TSChar);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ProvS(const S : TSString; var SL : TSByte) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := True;
Result := (Length(S) > SL);
if Result then
	Result := ((S[SL + 1] = LC) or (S[SL + 1] = UC));
if Result then
	SL += 1
else
	SL := 0;
end;

var
	iiii : TSLongWord;
begin
for iiii := 0 to High(WordCountSimbols) do
	ProvS(WordList[iiii],WordCountSimbols[iiii]);
end;

procedure FinalProv();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ProvF(const S : TSString; var SL : TSByte) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	iii : TSLongWord;
begin
Result := SL = Length(S);
if Result then
	for iii := 0 to SL - 1 do
		FunctionResult(Index + iii - SL, SVertex4fImport(0,0,1,1));
end;

var
	ii : TSLongWord;
begin
for ii := 0 to High(WordCountSimbols) do
	if ProvF(WordList[ii],WordCountSimbols[ii]) then
		break;
fillchar(WordCountSimbols[0], Length(WordCountSimbols), 0);
end;

function GetFreeList() : TSVertex4fList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
	Res : TSVertex4fList = nil;
begin
i := Length(VString);
Res := nil;
SetLength(Res, i);
{$IFDEF TI_COLOR_DEBUG}WriteLn('Set Length  Result"',Index,'"');{$ENDIF}
if Length(Res) > 0 then
	begin
	for i := 0 to High(Res) do
		begin
		Res[i].Import(1,1,1,1);
		end;
	end;
Result := Res;
end;

begin
(*========*)Result := nil; Exit;(*========*)
Index := Length(VString);
{$IFDEF TI_COLOR_DEBUG}WriteLn('Begin "',VString,'", Length = "',Index,'"');{$ENDIF}
Result := GetFreeList();
{$IFDEF TI_COLOR_DEBUG}WriteLn('Length(Result)="',Length(Result),'"');{$ENDIF}
SetLength(WordList, StringWordCount(FSystemWords,' '));
SetLength(WordCountSimbols, Length(WordList));
fillchar(WordCountSimbols[0], Length(WordCountSimbols), 0);
if Length(WordList) > 0 then
	for Index := 0 to High(WordList) do
		WordList [Index] := StringWordGet(FSystemWords,' ',Index + 1);
{$IFDEF TI_COLOR_DEBUG}WriteLn('Length(WordList)="',Length(WordList),'"');{$ENDIF}
Index := 1;
while Index <= Length(VString) do
	begin
	{$IFDEF TI_COLOR_DEBUG}WriteLn(Index);{$ENDIF}
	if VString[Index] in FSystemSeparators then
		begin
		FinalProv();
		end
	else
		begin
		SimbolProv(StringCase (VString[Index], @LowerCase)[1], StringCase (VString[Index], @UpperCase)[1]);
		end;
	Index += 1;
	end;
FinalProv();
SetLength(WordList, 0);
SetLength(WordCountSimbols, 0);
{$IFDEF TI_COLOR_DEBUG}WriteLn('End "',VString,'"');{$ENDIF}
end;

procedure TSNTextInset.UpdateLineColor(const Index : TSLongWord);

procedure STC(var Struct : TSNTextInsetFileString);
begin
if Struct.FColors <> nil then
	SetLength(Struct.FColors, 0);
Struct.FColors := nil;
{$IFDEF TI_COLOR_DEBUG}WriteLn('BTC');{$ENDIF}
Struct.FColors := GetTextColor(Struct.FString);
{$IFDEF TI_COLOR_DEBUG}WriteLn('ETC ',Length(Struct.FColors));{$ENDIF}
end;

begin
STC(FFile[Index]);
end;

procedure TSNTextInset.RealizeSystemSimbols();
var
	Extension : TSString;
begin
Extension := SFileExtension(FFileName, True);
if (Extension = 'PAS') or (Extension = 'PP') or (Extension = 'INC') then
	begin
	FSystemWords := 'result exit absolute abstract add and true false array as asm assembler constref automated begin boolean break byte case cdecl char class const constructor contains default deprecated destructor dispid dispinterface div do downto dynamic else end except export exports external far file final finalization finally for forward function goto if implementation implements in index inherited initialization inline integer interface is label library message mod name near nil nodefault not object of on or out overload override package packed pascal platform private procedure program property protected public published raise read readonly real record register reintroduce remove repeat requires resourcestring safecall sealed set shl shr static stdcall stored strict string then threadvar to try type unit unsafe until uses var varargs virtual while with word write writeonly xor';
	FSystemSeparators := ' ();:,.=<>+-[]	';
	end
else
	begin
	FSystemWords := '';
	FSystemSeparators := '';
	end;
end;

procedure TSNTextInset.Resize();
begin
StandardizateView();
inherited;
end;

procedure TSNTextInset.MoveVertical(const Param : TSFloat);
begin
FBegin += Param;
FEnd += Param;
StandardizateView();
FScrolTimer := 1;
end;

procedure TSNTextInset.UpDate();

var
	Line : TSLongWord;
	CursorPos : TSPoint2int32;

function IsCurOnText():TSBoolean;
begin
Result := False;
if not CursorOver then
	Exit;
CursorPos := Context.CursorPosition(SNowCursorPosition) - SVertex2int32Import(FRealPosition.x, FRealPosition.y);
CursorPos.x -= Skin.Font.StringLength(SStr(CountLines()));
Line := Trunc(FBegin + Abs(FEnd - FBegin) * ((CursorPos.y) / Height));
if Line < CountLines() then
	Result := (Skin.Font.StringLength(FFile[Line].FString) + 5 >= CursorPos.x) and
			  (5 <= CursorPos.x);
end;

procedure PutCursor();
begin
GoToPosition(Line, Skin.Font.CursorPlace(FFile[Line].FString, CursorPos.x - 5));
end;

procedure ProcessCursor();
begin
FCursorOverText := CursorOver and IsCurOnText();
if FCursorOverText then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SC_IBEAM)) then
		Context.Cursor := TSCursor.Create(SC_IBEAM);
if FCursorOverTextPrev and (not FCursorOverText) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SC_IBEAM)) then
	Context.Cursor := TSCursor.Create(SC_NORMAL);
FCursorOverTextPrev := FCursorOverText;
if FCursorOverText and Context.CursorKeysPressed(SLeftCursorButton) then
	PutCursor();
end;

procedure ProcessTyping();

function WhiteSignature(const S : TSString) : TSString;
var
	C : TSChar;
begin
Result := '';
for C in S do
	if C in [' ','	'] then
		Result += C
	else
		break;
end;

var
	i, ii : TSLongWord;
begin
if Context.KeyPressed and (Context.KeyPressedType = SDownKey) then
	begin
	case Context.KeyPressedChar of
	#39://ToRight (Arrow)
		begin
		if FTextCursor.FColumn > Length(FFile[FTextCursor.FLine].FString) then
			FTextCursor.FColumn := Length(FFile[FTextCursor.FLine].FString);
		if FTextCursor.FColumn < Length(FFile[FTextCursor.FLine].FString) then
			FTextCursor.FColumn += 1
		else if CountLines() - 1 > FTextCursor.FLine then
			GoToPosition(FTextCursor.FLine + 1, 0);
		end;
	#37://ToLeft (Arrow)
		begin
		if FTextCursor.FColumn > Length(FFile[FTextCursor.FLine].FString) then
			FTextCursor.FColumn := Length(FFile[FTextCursor.FLine].FString);
		if FTextCursor.FColumn > 0 then
			FTextCursor.FColumn -= 1
		else if FTextCursor.FLine > 0 then
			GoToPosition(FTextCursor.FLine - 1, Length(FFile[FTextCursor.FLine - 1].FString));
		end;
	#13://Enter
		begin
		if FTextCursor.FColumn > Length(FFile[FTextCursor.FLine].FString) then
			FTextCursor.FColumn := Length(FFile[FTextCursor.FLine].FString);
		SetLength(FFile, CountLines() + 1);
		for i := High(FFile) - 2 downto FTextCursor.FLine do
			FFile[i + 1] := FFile[i];
		FFile[FTextCursor.FLine + 1].FColors := nil;
		if FFile[FTextCursor.FLine].FColors <> nil then
			begin
			SetLength(FFile[FTextCursor.FLine].FColors, 0);
			FFile[FTextCursor.FLine].FColors := nil;
			end;
		FFile[FTextCursor.FLine + 1].FString := 
			WhiteSignature(FFile[FTextCursor.FLine].FString) +
			SStringGetPart(FFile[FTextCursor.FLine].FString, FTextCursor.FColumn + 1, Length(FFile[FTextCursor.FLine].FString));
		FFile[FTextCursor.FLine].FString := SStringGetPart(FFile[FTextCursor.FLine].FString, 1, FTextCursor.FColumn);
		GoToPosition(FTextCursor.FLine + 1, Length(WhiteSignature(FFile[FTextCursor.FLine].FString)));
		UpdateLineColor(FTextCursor.FLine);
		UpdateLineColor(FTextCursor.FLine - 1);
		end;
	#46: //Delete
		begin
		if FTextCursor.FColumn > Length(FFile[FTextCursor.FLine].FString) then
			FTextCursor.FColumn := Length(FFile[FTextCursor.FLine].FString);
		if FTextCursor.FColumn < Length(FFile[FTextCursor.FLine].FString) then
			begin
			FFile[FTextCursor.FLine].FString := 
				SStringGetPart(FFile[FTextCursor.FLine].FString, 1, FTextCursor.FColumn) +
				SStringGetPart(FFile[FTextCursor.FLine].FString, FTextCursor.FColumn + 2, Length(FFile[FTextCursor.FLine].FString));
			end;
		UpdateLineColor(FTextCursor.FLine);
		end;
	#8: //BackSpase
		begin
		if FTextCursor.FColumn > Length(FFile[FTextCursor.FLine].FString) then
			FTextCursor.FColumn := Length(FFile[FTextCursor.FLine].FString);
		if FTextCursor.FColumn = 1 then
			begin
			FTextCursor.FColumn := 0;
			FFile[FTextCursor.FLine].FString := SStringGetPart(FFile[FTextCursor.FLine].FString, 2, Length(FFile[FTextCursor.FLine].FString));
			end
		else if FTextCursor.FColumn <> 0 then
			begin
			FTextCursor.FColumn -= 1;
			FFile[FTextCursor.FLine].FString := 
				SStringGetPart(FFile[FTextCursor.FLine].FString, 1, FTextCursor.FColumn) +
				SStringGetPart(FFile[FTextCursor.FLine].FString, FTextCursor.FColumn + 2, Length(FFile[FTextCursor.FLine].FString));
			end
		else if FTextCursor.FLine <> 0 then
			begin
			ii := Length(FFile[FTextCursor.FLine - 1].FString);
			FFile[FTextCursor.FLine - 1].FString += FFile[FTextCursor.FLine].FString;
			if FFile[FTextCursor.FLine].FColors <> nil then
				SetLength(FFile[FTextCursor.FLine].FColors, 0);
			for i := FTextCursor.FLine to High(FFile) - 1 do
				FFile[i] := FFile[i + 1];
			SetLength(FFile, Length(FFile) - 1);
			GoToPosition(FTextCursor.FLine - 1, ii);
			end;
		UpdateLineColor(FTextCursor.FLine);
		end;
	#38: //UpKey(Arrow)
		if FTextCursor.FLine > 0 then
			GoToPosition(FTextCursor.FLine - 1, FTextCursor.FColumn);
	#40: //DownKey(Arrow)
		if FTextCursor.FLine < CountLines() - 1 then
			GoToPosition(FTextCursor.FLine + 1, FTextCursor.FColumn);
	Char(S_ALT_KEY),//Alt
	#17,//Ctrl
	#112..#120,///F1..F9
	#123,//F12
	#144,//NumLock
	#45,//Insert
	#27,//Escape
	#19,//Pause (or/and) Break
	#16,//Shift
	#9,//Tab
	#20,//Caps Lock
	#34,#33,//PageDown,PageUp
	#93,//Win Property  (Right Menu Key)
	#91,//Win Menu (Left Menu Key)
	#255,//Screen яркость(F11,F12 on my netbook)
	#233//Dinamics Volume (F7,F8,F9 on my netbook)
		:;// Do NoThink
	#35://  End
		begin
		FTextCursor.FColumn := Length(FFile[FTextCursor.FLine].FString);
		end;
	#36:// Home 
		begin
		FTextCursor.FColumn := 0;
		end;
	else//Simbol
		begin
		if FTextCursor.FColumn > Length(FFile[FTextCursor.FLine].FString) then
			FTextCursor.FColumn := Length(FFile[FTextCursor.FLine].FString);
		if FFile[FTextCursor.FLine].FString = '' then
			begin
			FFile[FTextCursor.FLine].FString :=
				SWhatIsTheSimbol(longint(Context.KeyPressedChar),
				Context.KeysPressed(16) , Context.KeysPressed(20));
			FTextCursor.FColumn := 1;
			end
		else
			begin
			FTextCursor.FColumn += 1;
			FFile[FTextCursor.FLine].FString :=
					SStringGetPart(FFile[FTextCursor.FLine].FString, 1, FTextCursor.FColumn - 1) +
					SWhatIsTheSimbol(longint(Context.KeyPressedChar),
						Context.KeysPressed(16) , Context.KeysPressed(20))+
					SStringGetPart(FFile[FTextCursor.FLine].FString, FTextCursor.FColumn, Length(FFile[FTextCursor.FLine].FString));
			end;
		UpdateLineColor(FTextCursor.FLine);
		end;
	end;
	end;
end;

begin
inherited;
if Visible and CursorOver then
	begin
	if (Context.CursorWheel() <> SNullCursorWheel)then
		begin
		if Context.CursorWheel() = SUpCursorWheel then
			begin
			MoveVertical(-3);
			end
		else
			begin
			MoveVertical( 3);
			end;
		end;
	end;
if FOwner <> nil then
	Visible := FOwner.ActiveInset() = Self;
if Visible then
	begin
	UpdateTimer(False, FScrolTimer, 1, 3);
	if CursorOverComponent or FCursorOverText or FCursorOverTextPrev then
		ProcessCursor();
	ProcessTyping();
	end;
end;

procedure TSNTextInset.StandardizateView();
var
	Difference, DifferenceOld, Middle : TSFloat;
begin
DifferenceOld := Abs(FEnd - FBegin);
Difference := Height / Skin.Font.FontHeight;
if Abs(Difference - DifferenceOld) > SZero then
	begin
	Middle := (FEnd + FBegin) / 2;
	FBegin := Middle - Difference / 2;
	FEnd := Middle + Difference / 2;
	end;
if FEnd > CountLines() then
	begin
	FEnd := CountLines();
	FBegin := FEnd - Difference;
	end;
if FBegin < 0 then
	begin
	FBegin := 0;
	FEnd := Difference;
	end;
end;

procedure TSNTextInset.GoToPosition(const Line, Column : TSLongWord);
var
	Difference : TSFloat;
begin
FTextCursor.FLine := Line;
FTextCursor.FColumn := Column;
FTextCursor.FTimer := 1;
if FTextCursor.FLine < 1 + FBegin then
	begin
	Difference := FBegin - FTextCursor.FLine + 1;
	FBegin -= Difference;
	FEnd -= Difference;
	end
else if FTextCursor.FLine + 2 > FEnd then
	begin
	Difference := FTextCursor.FLine - FEnd + 2;
	FBegin += Difference;
	FEnd += Difference;
	end;
StandardizateView();
end;

procedure TSNTextInset.Paint();

procedure DrawTextAndNumLines();
var
	i, ii, iii : TSLongWord;
	Vertex : TSVertex3f;
	MaxLinesShift : TSLongWord;
	Alpha, Shift : TSFloat;
begin
MaxLinesShift := Skin.Font.StringLength(SStr(CountLines())) + 5;
ii := Trunc(FBegin);
Vertex := SPoint2int32ToVertex3f(GetVertex([SS_LEFT,SS_TOP],S_VERTEX_FOR_MainComponent));
Shift := Abs(FBegin - ii);
Vertex.y -= Shift * Skin.Font.FontHeight;
for i := ii to Trunc(FEnd) + 1 do
	begin
	if i >= CountLines() then
		break;
	
	if i = ii  then
		Alpha := (1 - Shift) ** 2
	else if i - Shift + 1 > FEnd then
		Alpha := Abs(FEnd - i + Shift - 1) ** 2
	else
		Alpha := 1;
	
	Render.Color4f(0.9,0.9,0.9,Alpha);
	Skin.Font.DrawFontFromTwoVertex2f(
		SStr(i+1),
		SVertex2fImport(
			Vertex.x,
			Vertex.y + (i - ii) * Skin.Font.FontHeight),
		SVertex2fImport(
			Vertex.x + MaxLinesShift,
			Vertex.y + (i - ii + 1) * Skin.Font.FontHeight),
		False);
	if FFile[i].FColors <> nil then
		begin
		Skin.Font.DrawFontFromTwoVertex2fAndColorList(
			FFile[i].FString,
			FFile[i].FColors,
			SVertex2fImport(
				Vertex.x + MaxLinesShift,
				Vertex.y + (i - ii) * Skin.Font.FontHeight),
			SVertex2fImport(
				Vertex.x + Width,
				Vertex.y + (i - ii + 1) * Skin.Font.FontHeight),
			False);
		end
	else
		begin
		Render.Color4f(1,1,1,Alpha);
		Skin.Font.DrawFontFromTwoVertex2f(
			FFile[i].FString,
			SVertex2fImport(
				Vertex.x + MaxLinesShift,
				Vertex.y + (i - ii) * Skin.Font.FontHeight),
			SVertex2fImport(
				Vertex.x + Width,
				Vertex.y + (i - ii + 1) * Skin.Font.FontHeight),
			False);
		UpdateLineColor(i);
		end;
	if i = FTextCursor.FLine then
		begin
		iii := Length(FFile[i].FString);
		if FTextCursor.FColumn < iii then
			iii := FTextCursor.FColumn;
		Render.Color4f(0,1,0,1);
		Skin.Font.DrawCursorFromTwoVertex2f(
			FFile[i].FString,
			iii,
			SVertex2fImport(
				Vertex.x + MaxLinesShift,
				Vertex.y + (i - ii) * Skin.Font.FontHeight),
			SVertex2fImport(
				Vertex.x + Width,
				Vertex.y + (i - ii + 1) * Skin.Font.FontHeight),
			False,
			True,
			2);
		end;
	end;
end;

procedure DrawScrollBar();
const
	ScrollBarWidth = 20;
var
	VertexTop, VertexBottom : TSVertex3f;
	VertexTopLeft, VertexBottomLeft : TSVertex3f;
	AreaAll : TSFloat;
begin
VertexTop := SPoint2int32ToVertex3f(GetVertex([SS_RIGHT,SS_TOP],S_VERTEX_FOR_MainComponent));
VertexBottom := SPoint2int32ToVertex3f(GetVertex([SS_RIGHT,SS_BOTTOM],S_VERTEX_FOR_MainComponent));
VertexBottomLeft := VertexBottom; VertexBottomLeft.x -= ScrollBarWidth * FScrolTimer;
VertexTopLeft := VertexTop; VertexTopLeft.x -= ScrollBarWidth * FScrolTimer;
AreaAll := CountLines();
Render.BeginScene(SR_QUADS);

Render.Color4f(0.3,0.3,0.3,FScrolTimer);
Render.Vertex(VertexTop);
Render.Vertex(VertexBottom);
Render.Vertex(VertexBottomLeft);
Render.Vertex(VertexTopLeft);

Render.Color4f(0.1,0.9,0.1,FScrolTimer);
Render.Vertex2f(
	VertexTop.x,
	VertexTop.y + FBegin / AreaAll * Height);
Render.Vertex2f(
	VertexTop.x,
	VertexTop.y + FEnd / AreaAll * Height);
Render.Vertex2f(
	VertexTopLeft.x,
	VertexTop.y + FEnd / AreaAll * Height);
Render.Vertex2f(
	VertexTopLeft.x,
	VertexTop.y + FBegin / AreaAll * Height);
Render.EndScene();
end;

begin
if FOwner.ActiveInset() = Self then
	begin
	DrawTextAndNumLines();
	DrawScrollBar();
	end;
inherited;
end;

function TSNTextInset.CountLines() : TSLongWord;
begin
if FFile = nil then
	Result := 0
else
	Result := Length(FFile);
end;

constructor TSNTextInset.Create();
begin
inherited;
FFileName := '';
FFile := nil;
FScrolTimer := 1;
FSystemSeparators := '';
FSystemWords := '';
end;

destructor TSNTextInset.Destroy();
begin
SetLength(FFile, 0);
inherited;
end;

procedure TSNTextInset.SetFile(const VFileName : TSString);
begin
FFileName := VFileName;
RealizeSystemSimbols();
LoadFile();
end;

procedure TSNTextInset.LoadFile();
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(Stream, FFileName);
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	SetLength(FFile, CountLines() + 1);
	FFile[High(FFile)].FString := SConvertString(SReadLnStringFromStream(Stream), SEncodingWindows1251);
	FFile[High(FFile)].FColors := nil;
	end;
Stream.Destroy();
end;

end.
