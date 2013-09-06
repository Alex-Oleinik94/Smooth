//*| -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//*| MULTIMEDIA TIMER - game engine 1.4
//*| ---------------------------------------------------------------------------
//*| by Georgy Moshkin
//*|
//*| email : tmtlib@narod.ru
//*| WWW   : http://www.tmtlib.narod.ru/
//*|
//*| License: Public Domain
//*| =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
unit _mmtime;

interface

uses MMSystem;

var  tc: TTimeCaps;
     TGT:integer;
     prevTGT: integer;
     FixIt:integer;

     ElapsedTime: word;
     OldElapsedTime: word;



procedure mmtimeAlloc;
procedure mmtimeFree;
function mmtimeElapsed:integer;

implementation

procedure mmtimeAlloc;
begin
  // Retrieve timer caps, which contain resolution range
  timeGetDevCaps(@tc, SizeOf(tc));
  // Set resolution with this call
  timeBeginPeriod(tc.wPeriodMin);

  prevTGT:=timeGetTime;
end;

procedure mmtimeFree;
begin
  // Don't retrieve the caps again to be absolutely sure we restore the same value that we set
  // Restore old resolution
  timeEndPeriod(tc.wPeriodMin);
end;


function mmtimeElapsed:integer;
//var f:text;
begin
prevTGT:=TGT;
TGT:=timeGetTime;
if (TGT<>0) and (prevTGT<>0) and (TGT>prevTGT) then
mmtimeElapsed:=TGT-prevTGT
else
mmtimeElapsed:=FixIt;
FixIt:=TGT-prevTGT;


end;

end.