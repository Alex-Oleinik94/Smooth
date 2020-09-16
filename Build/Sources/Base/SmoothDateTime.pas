{$INCLUDE Smooth.inc}

unit SmoothDateTime;

interface

uses
	 Dos
	 
	,SmoothBase
	;
type
	// 1 sec = 1 000 millisec
	// 1 sec = 1 000 000 microsec
	// 1 sec = 1 000 000 000 nanosec
	TSTimeNumber = TSInt64; // разрешены отрицательные значение чтобы функционировал "вычет дат"
	TSTimeMiniNumber = TSInt8;
	TSTime = object
			public
		function Create(const ValueSeconds, ValueMicroseconds : TSTimeNumber) : TSTime; overload; static;
		constructor Create(const ValueSeconds, ValueMicroseconds : TSTimeNumber); overload;
			public
		FSeconds : TSTimeNumber;
		FMicroseconds : TSTimeNumber;
			public
		function Hours() : TSTimeMiniNumber;
		function Minutes() : TSTimeMiniNumber;
		function Seconds() : TSTimeMiniNumber;
		end;
	TSTimeVal = TSTime;
type
	TSInt32List8 = array[0..7] of TSInt32;
	PSInt32List8 = ^ TSInt32List8;
	TSDateTime = object
			public
		Years, Month, Day, Week : TSInt32;
		Hours, Minutes, Seconds, Sec100 : TSInt32;
			public
		procedure Get();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastSecondsFrom(const DT : TSDateTime) : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastSeconds() : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Import(a1, a2, a3, a4, a5, a6, a7, a8 : TSInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ImportFromSeconds(Sec : TSInt64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastMilliSeconds() : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastMilliSecondsFrom(const DT : TSDateTime) : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function IsNull() : TSBoolean;
		end;

//Вычитает одну дату их другой;
// функция GetPastSeconds (GetPastMilliSeconds) возвращающет прошедшые (милли-)секунды;
// результат: разница между датами в (милли-)секундах.
operator - (const a, b : TSDateTime) : TSDateTime; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SSecondsToStringTime(VSeconds : TSInt64; const Encoding : TSString = 'RUS1251') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SMilliSecondsToStringTime(VSeconds : TSInt64; const Encoding : TSString = 'RUS1251') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function STextTimeBetweenDates(const D1, D2 : TSDateTime; const Encoding : TSString = 'RUS1251') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SNow() : TSDateTime;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SDateTimeString(const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SDateTimeString(const DateTime : TSDateTime; const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SDateTimeCorrectionString(const Time : TSTime; const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
function SDateTimeCorrectionString(const Date : TSDateTime; const Time : TSTime; const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	,SmoothBaseUtils
	
	,StrMan
	;

function TSTime.Hours() : TSTimeMiniNumber;
begin
Result := Seconds div 60 * 60;
end;

function TSTime.Minutes() : TSTimeMiniNumber;
begin
Result := Seconds div 60 mod 60;
end;

function TSTime.Seconds() : TSTimeMiniNumber;
begin
Result := Seconds mod 60;
end;

constructor TSTime.Create(const ValueSeconds, ValueMicroseconds : TSTimeNumber); overload;
begin
FSeconds := ValueSeconds;
FMicroseconds := ValueMicroseconds;
end;

function TSTime.Create(const ValueSeconds, ValueMicroseconds : TSTimeNumber) : TSTime; overload; static;
begin
Result.Create(ValueSeconds, ValueMicroseconds);
end;

function SDateTimeCorrectionString(const Date : TSDateTime; const Time : TSTime; const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
with Date do
	begin
	Result := '[';
	Result += StringJustifyRight(SStr(Years), 4, '0') + '.';
	Result += StringJustifyRight(SStr(Month), 2, '0') + '.';
	Result += StringJustifyRight(SStr(Day),   2, '0');
	if AddWeek then
		begin
		Result += Iff(ForFileSystem, ',', '/');
		Result += SStr(Week);
		end;
	Result += '][';
	Result += StringJustifyRight(SStr(Hours),   2, '0') + Iff(ForFileSystem, '.', ':');
	end;
with Time do
	begin
	Result += StringJustifyRight(SStr(Minutes), 2, '0') + Iff(ForFileSystem, '.', ':'); 
	Result += StringJustifyRight(SStr(Seconds), 2, '0');
	if AddMilliSeconds then
		begin
		Result += Iff(ForFileSystem, ',', '/'); 
		Result += StringJustifyRight(SStr(FMicroseconds),  6, '0');
		end;
	Result += ']';
	end;
end;

function SDateTimeCorrectionString(const Time : TSTime; const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := SDateTimeCorrectionString(SNow(), Time, ForFileSystem, AddWeek, AddMilliSeconds);
end;

function SDateTimeString(const DateTime : TSDateTime; const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
with DateTime do
	begin
	Result := '[';
	Result += StringJustifyRight(SStr(Years), 4, '0') + '.';
	Result += StringJustifyRight(SStr(Month), 2, '0') + '.';
	Result += StringJustifyRight(SStr(Day),   2, '0');
	if AddWeek then
		begin
		Result += Iff(ForFileSystem, ',', '/');
		Result += SStr(Week);
		end;
	Result += '][';
	Result += StringJustifyRight(SStr(Hours),   2, '0') + Iff(ForFileSystem, '.', ':');
	Result += StringJustifyRight(SStr(Minutes), 2, '0') + Iff(ForFileSystem, '.', ':'); 
	Result += StringJustifyRight(SStr(Seconds), 2, '0');
	if AddMilliSeconds then
		begin
		Result += Iff(ForFileSystem, ',', '/'); 
		Result += StringJustifyRight(SStr(Sec100),  2, '0');
		end;
	Result += ']';
	end;
end;

function SDateTimeString(const ForFileSystem : TSBoolean = False; const AddWeek : TSBoolean = True; const AddMilliSeconds : TSBoolean = True) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := SDateTimeString(SNow(), ForFileSystem, AddWeek, AddMilliSeconds);
end;

function SNow() : TSDateTime;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Get();
end;

function STextTimeBetweenDates(const D1, D2 : TSDateTime; const Encoding : TSString = 'RUS1251') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := StringTrimAll(SMilliSecondsToStringTime((D2 - D1).GetPastMilliSeconds(), Encoding), ' 	');
end;

function SMilliSecondsToStringTime(VSeconds : TSInt64; const Encoding : TSString = 'RUS1251') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
if VSeconds div 100 <> 0 then
	Result += SSecondsToStringTime(VSeconds div 100, Encoding);
if (VSeconds mod 100 <> 0) or (Result = '') then
	begin
	Result += SStr(VSeconds mod 100);
	if Encoding = 'RUS1251' then
		Result += ' мсек '
	else
		Result += ' msec ';
	end;
Result := StringTrimAll(Result, ' 	');
end;

function SSecondsToStringTime(VSeconds : TSInt64; const Encoding : TSString = 'RUS1251') : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Seconds:Int64 = 0;
	Minutes:Int64 = 0;
	Hours:Int64 = 0;
	Days:Int64 = 0;
	Monthes:Int64 = 0;
	Years:Int64 = 0;

	QWr:Word = 0;
begin
Result:='';

Seconds:=VSeconds mod 60;
VSeconds:=VSeconds div 60;

Minutes:=VSeconds mod 60;
VSeconds:=VSeconds div 60;

Hours:=VSeconds mod 24;
VSeconds:=VSeconds div 24;

Days:=VSeconds mod 30;
VSeconds:=VSeconds div 30;

Monthes:=VSeconds mod 12;
VSeconds:=VSeconds div 12;

Years:=VSeconds;
if (Years<>0) and (QWr<=2) then
	begin
	Result+=SStr(Years);
	if Encoding = 'RUS1251' then
		Result += ' г '
	else
		Result += ' y ';
	QWr+=1;
	end;
if (Monthes<>0)  and (QWr<=2)then
	begin
	Result+=SStr(Monthes);
	if Encoding = 'RUS1251' then
		Result += ' мес '
	else
		Result += ' mon ';
	QWr+=1;
	end;
if (Days<>0)  and (QWr<=2)then
	begin
	Result+=SStr(Days);
	if Encoding = 'RUS1251' then
		Result += ' дн '
	else
		Result += ' d ';
	QWr+=1;
	end;
if (Hours<>0)  and (QWr<=2)then
	begin
	Result+=SStr(Hours);
	if Encoding = 'RUS1251' then
		Result += ' ч '
	else
		Result += ' h ';
	QWr+=1;
	end;
if (Minutes<>0)  and (QWr<=2)then
	begin
	Result+=SStr(Minutes);
	if Encoding = 'RUS1251' then
		Result += ' мин '
	else
		Result += ' min ';
	QWr+=1;
	end;
if ((Result='') or (Seconds<>0)) and (QWr<=2) then
	begin
	Result+=SStr(Seconds);
	if Encoding = 'RUS1251' then
		Result += ' сек '
	else
		Result += ' s ';
	QWr+=1;
	end;
end;

function TSDateTime.IsNull() : TSBoolean;
var
	Size : TSMaxEnum;
	Memory : PSByte;
	Index : TSMaxEnum;
begin
Result := True;
Size := SizeOf(TSDateTime);
Memory := @Self;
for Index := 0 to Size - 1 do
	if Memory[Index] <> 0 then
		begin
		Result := False;
		break;
		end;
end;

procedure TSDateTime.ImportFromSeconds(Sec : TSInt64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Sec100:=0;
Seconds:=Sec mod 60;
Sec:=Sec div 60;
Minutes:= Sec mod 60;
Sec:=Sec div 60;
Hours:=Sec mod 24;
Sec:=Sec div 24;
Day:=Sec mod 30;
Month:=(Sec div 30) mod 12;
Years:=Sec mod 365;
end;

procedure TSDateTime.Import(a1,a2, a3, a4, a5, a6, a7, a8 : TSInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
TSInt32List8(Self)[0] := a1;
TSInt32List8(Self)[1] := a2;
TSInt32List8(Self)[2] := a3;
TSInt32List8(Self)[3] := a4;
TSInt32List8(Self)[4] := a5;
TSInt32List8(Self)[5] := a6;
TSInt32List8(Self)[6] := a7;
TSInt32List8(Self)[7] := a8;
end;

procedure TSDateTime.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
WriteLn(Years,' ',Month,' ',Day,' ',Week,' ',Hours,' ',Minutes,' ',Seconds,' ',Sec100);
end;

operator - (const a, b : TSDateTime) : TSDateTime;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i:TSByte;
begin
for i:=0 to 7 do
	TSInt32List8(Result)[i] := TSInt32List8(a)[i] - TSInt32List8(b)[i];
end;

function TSDateTime.GetPastSeconds() : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Seconds;
Result += Minutes * 60;
Result += Hours   * 60 * 60;
Result += Day     * 60 * 60 * 24;
Result += Month   * 60 * 60 * 24 * 30;
Result += Years   * 60 * 60 * 24 * 365;
end;

function TSDateTime.GetPastSecondsFrom(const DT : TSDateTime) : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Self - DT).GetPastSeconds();
end;

procedure TSDateTime.Get();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	NYears, NMonth, NDay, NWeek : TSUInt16;
	NHours, NMinutes, NSeconds, NSec100 : TSUInt16;
begin
GetDate(NYears, NMonth, NDay, NWeek);
GetTime(NHours, NMinutes, NSeconds, NSec100);
Years   := NYears;
Month   := NMonth;
Day     := NDay;
Week    := NWeek;
Hours   := NHours;
Minutes := NMinutes;
Seconds := NSeconds;
Sec100  := NSec100;
end;

procedure TSDateTime.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Years   := 0;
Month   := 0;
Hours   := 0;
Day     := 0;
Week    := 0;
Minutes := 0;
Seconds := 0;
Sec100  := 0;
end;

function TSDateTime.GetPastMilliSeconds() : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := GetPastSeconds() * 100 + Sec100;
end;

function TSDateTime.GetPastMilliSecondsFrom(const DT : TSDateTime) : TSInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Self - DT).GetPastMilliSeconds();
end;


end.
