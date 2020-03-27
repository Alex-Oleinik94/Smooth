{$INCLUDE Smooth.inc}

unit SmoothlNetURIParser;

interface

uses
	 SmoothBase
	;

function SCheckURL(const URL : TSString; const Protocol : TSString = ''; const Port : TSUInt16 = 0) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGetURLProtocol(const URL : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SSetURLProtocol(const URL, Protocol : TSString) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SDecomposeURL(const URL : TSString; out Host, URI : TSString; out Port : TSUInt16) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	
	,StrMan
	,lHTTPUtil
	;

function SDecomposeURL(const URL : TSString; out Host, URI : TSString; out Port : TSUInt16) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function StringIsNumber(const Str : TSString) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSUInt32;
begin
Result := Str <> '';
if Result then
	for i := 1 to Length(Str) do
		if not (Str[i] in '0123456789') then
			begin
			Result := False;
			break;
			end;
end;

begin
Result := False;
if StringMatching(SUpCaseString(URL), 'LOCALHOST*') then
	begin
	Host := 'localhost';
	Port := 0;
	URI := '';
	if (StringWordCount(URL, ':') = 2) then
		if StringIsNumber(StringWordGet(URL, ':', 2)) then
			Port := SVal(StringWordGet(URL, ':', 2))
		else
			SHint('SDecomposeURL: Error while pasring port!');
	end
else if StringMatching(URL, '*?.*?.*?.*?:*?') then
	begin
	Port := 0;
	URI := '';
	Host := StringWordGet(URL, ':', 1);
	if StringIsNumber(StringWordGet(URL, ':', 2)) then
		Port := SVal(StringWordGet(URL, ':', 2))
	else
		SHint('SDecomposeURL: Error while pasring port!');
	end
else if StringMatching(URL, '*?.*?.*?.*?') then
	begin
	Port := 0;
	Host := URL;
	URI := '';
	end
else
	begin
	Result := DecomposeURL(URL, Host, URI, Port);
	end;
end;

function SSetURLProtocol(const URL, Protocol : TSString) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := URL;
if StringWordCount(URL, ':') = 2 then
	Result := Protocol + ':' + StringWordGet(URL, ':', 2)
else if StringWordCount(URL, ':') = 1 then
	Result := Protocol + '://' + URL
else
	Result := URL;
end;

function SGetURLProtocol(const URL : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, Pos2 : TSUInt32;
begin
if StringWordCount(URL, ':') = 2 then
	Result := StringWordGet(URL, ':', 1)
else
	Result := '';
end;

function SCheckURL(const URL : TSString; const Protocol : TSString = ''; const Port : TSUInt16 = 0) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	VPort : TSUInt16;
	Host, URI : TSString;
	URLProtocol : TSString;
begin
Result := URL;
URLProtocol := SGetURLProtocol(Result);
if (URLProtocol = '') and (Protocol <> '') then
	begin
	URLProtocol := Protocol;
	Result := SSetURLProtocol(Result, URLProtocol);
	end;
DecomposeURL(Result, Host, URI, VPort);
if Port <> 0 then
	VPort := Port;
if URI = '' then
	URI := '/';
Result := URLProtocol + '://' + Host + URI;
if Port <> 0 then
	Result += ':' + SStr(Port);
SLog.Source(Result);
end;

end.
