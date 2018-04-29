{$INCLUDE SaGe.inc}

unit SaGeDateTime;

interface

uses
	 Dos
	
	,SaGeBase
	;
type
	// Used Int64 (not UInt64) becouse "Ariphmetic overflow"
	TSGInt32List8 = array[0..7] of TSGInt32;
	PSGInt32List8 = ^ TSGInt32List8;
	TSGDateTime = object
			public
		Years, Month, Day, Week : TSGInt32;
		Hours, Minutes, Seconds, Sec100 : TSGInt32;
			public
		procedure Get();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastSecondsFrom(const DT : TSGDateTime) : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastSeconds() : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Import(a1, a2, a3, a4, a5, a6, a7, a8 : TSGInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ImportFromSeconds(Sec : TSGInt64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastMiliSeconds() : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPastMiliSecondsFrom(const DT : TSGDateTime) : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

//Вычитает одну дату их другой. Из результата можно
//Вызвать функцию, возвращающую прошедшые (мили)секунды
//И получить разницу во времени этих дат в (мили)секундах
operator - (const a, b : TSGDateTime) : TSGDateTime;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGSecondsToStringTime(VSeconds : TSGInt64; const Encoding : TSGString = 'RUS1251') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGMiliSecondsToStringTime(VSeconds : TSGInt64; const Encoding : TSGString = 'RUS1251') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTextTimeBetweenDates(const D1, D2 : TSGDateTime; const Encoding : TSGString = 'RUS1251') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGNow() : TSGDateTime;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	
	,StrMan
	;

function SGNow() : TSGDateTime;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Get();
end;

function SGTextTimeBetweenDates(const D1, D2 : TSGDateTime; const Encoding : TSGString = 'RUS1251') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := StringTrimAll(SGMiliSecondsToStringTime((D2 - D1).GetPastMiliSeconds(), Encoding), ' 	');
end;

function SGMiliSecondsToStringTime(VSeconds : TSGInt64; const Encoding : TSGString = 'RUS1251') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
if VSeconds div 100 <> 0 then
	Result += SGSecondsToStringTime(VSeconds div 100, Encoding);
if (VSeconds mod 100 <> 0) or (Result = '') then
	begin
	Result += SGStr(VSeconds mod 100);
	if Encoding = 'RUS1251' then
		Result += ' мсек '
	else
		Result += ' msec ';
	end;
Result := StringTrimAll(Result, ' 	');
end;

function SGSecondsToStringTime(VSeconds : TSGInt64; const Encoding : TSGString = 'RUS1251') : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	Result+=SGStr(Years);
	if Encoding = 'RUS1251' then
		Result += ' г '
	else
		Result += ' y ';
	QWr+=1;
	end;
if (Monthes<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Monthes);
	if Encoding = 'RUS1251' then
		Result += ' мес '
	else
		Result += ' mon ';
	QWr+=1;
	end;
if (Days<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Days);
	if Encoding = 'RUS1251' then
		Result += ' дн '
	else
		Result += ' d ';
	QWr+=1;
	end;
if (Hours<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Hours);
	if Encoding = 'RUS1251' then
		Result += ' ч '
	else
		Result += ' h ';
	QWr+=1;
	end;
if (Minutes<>0)  and (QWr<=2)then
	begin
	Result+=SGStr(Minutes);
	if Encoding = 'RUS1251' then
		Result += ' мин '
	else
		Result += ' min ';
	QWr+=1;
	end;
if ((Result='') or (Seconds<>0)) and (QWr<=2) then
	begin
	Result+=SGStr(Seconds);
	if Encoding = 'RUS1251' then
		Result += ' сек '
	else
		Result += ' s ';
	QWr+=1;
	end;
end;

procedure TSGDateTime.ImportFromSeconds(Sec : TSGInt64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

procedure TSGDateTime.Import(a1,a2, a3, a4, a5, a6, a7, a8 : TSGInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
TSGInt32List8(Self)[0] := a1;
TSGInt32List8(Self)[1] := a2;
TSGInt32List8(Self)[2] := a3;
TSGInt32List8(Self)[3] := a4;
TSGInt32List8(Self)[4] := a5;
TSGInt32List8(Self)[5] := a6;
TSGInt32List8(Self)[6] := a7;
TSGInt32List8(Self)[7] := a8;
end;

procedure TSGDateTime.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
WriteLn(Years,' ',Month,' ',Day,' ',Week,' ',Hours,' ',Minutes,' ',Seconds,' ',Sec100);
end;

operator - (const a, b : TSGDateTime) : TSGDateTime;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i:TSGByte;
begin
for i:=0 to 7 do
	TSGInt32List8(Result)[i] := TSGInt32List8(a)[i] - TSGInt32List8(b)[i];
end;

function TSGDateTime.GetPastSeconds() : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Seconds;
Result += Minutes * 60;
Result += Hours   * 60 * 60;
Result += Day     * 60 * 60 * 24;
Result += Month   * 60 * 60 * 24 * 30;
Result += Years   * 60 * 60 * 24 * 365;
end;

function TSGDateTime.GetPastSecondsFrom(const DT : TSGDateTime) : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Self - DT).GetPastSeconds();
end;

procedure TSGDateTime.Get();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	NYears, NMonth, NDay, NWeek : TSGUInt16;
	NHours, NMinutes, NSeconds, NSec100 : TSGUInt16;
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

procedure TSGDateTime.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function TSGDateTime.GetPastMiliSeconds() : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := GetPastSeconds() * 100 + Sec100;
end;

function TSGDateTime.GetPastMiliSecondsFrom(const DT : TSGDateTime) : TSGInt64;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Self - DT).GetPastMiliSeconds();
end;


end.
