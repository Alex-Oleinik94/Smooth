{$INCLUDE SaGe.inc}

unit SaGeClientMaxWeb;

interface

uses
	Classes
	,SaGeBased
	,SaGeBase
	,SaGeRender
	,SaGeContext
	,SaGeNet
	
	,fpjson
	,jsonparser
	;

type
	TSGClientMaxWeb=class(TSGDrawClass)
			private
		J : TJSONData;
		Schedules : TJSONData;
			public
		constructor Create(const VContext:TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
		end;

implementation

{Constructor Create; virtual;
Procedure Clear;  virtual; Abstract;
Procedure DumpJSON(S : TStream);
// Get enumerator
function GetEnumerator: TBaseJSONEnumerator; virtual;
Function FindPath(Const APath : TJSONStringType) : TJSONdata;
Function GetPath(Const APath : TJSONStringType) : TJSONdata;
Function Clone : TJSONData; virtual; abstract;
Function FormatJSON(Options : TFormatOptions = DefaultFormat; Indentsize : Integer = DefaultIndentSize) : TJSONStringType; 
property Count: Integer read GetCount;
property Items[Index: Integer]: TJSONData read GetItem write SetItem;
property Value: variant read GetValue write SetValue;
Property AsString : TJSONStringType Read GetAsString Write SetAsString;
Property AsFloat : TJSONFloat Read GetAsFloat Write SetAsFloat;
Property AsInteger : Integer Read GetAsInteger Write SetAsInteger;
Property AsInt64 : Int64 Read GetAsInt64 Write SetAsInt64;
Property AsQWord : QWord Read GetAsQWord Write SetAsQword;
Property AsBoolean : Boolean Read GetAsBoolean Write SetAsBoolean;
Property IsNull : Boolean Read GetIsNull;
Property AsJSON : TJSONStringType Read GetAsJSON;}

constructor TSGClientMaxWeb.Create(const VContext:TSGContext);
var
	S : String = '';
	MS : TMemoryStream = nil;
	i : LongWord;
	DT : TSGDataTime;
begin
inherited Create(VContext);
SGLog.Sourse('Begin get HTTP');
MS := SGGetFromHTTP('http://fpm.babichev.net/schedule/32/k/mathmod?api=json');
SGLog.Sourse(['End get HTTP "',LongWord(MS),'"']);
if MS = nil then 
	Exit;
i := 0;
while i<>MS.Size do
	begin
	S+=PChar(MS.Memory)[i];
	i+=1;
	end;
MS.Destroy();
{J := GetJSON(S);
DT.Get();
Schedules := J.FindPath('schedules');}
//WriteLn(J.FindPath('schdule_title').AsString);
end;

procedure TSGClientMaxWeb.Draw();
begin

end;

destructor TSGClientMaxWeb.Destroy();
begin
inherited;
end;

class function TSGClientMaxWeb.ClassName():TSGString;
begin
Result := 'Расписание КубГУ';
end;

end.
