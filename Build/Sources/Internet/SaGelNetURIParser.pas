{$INCLUDE SaGe.inc}

unit SaGelNetURIParser;

interface

uses
	 SaGeBase
	;

function SGCheckURL(const URL : TSGString; const Protocol : TSGString = ''; const Port : TSGUInt16 = 0) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetURLProtocol(const URL : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGSetURLProtocol(const URL, Protocol : TSGString) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDecomposeURL(const URL : TSGString; out Host, URI : TSGString; out Port : TSGUInt16) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	,SaGeLog
	
	,StrMan
	,lHTTPUtil
	;

function SGDecomposeURL(const URL : TSGString; out Host, URI : TSGString; out Port : TSGUInt16) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function StringIsNumber(const Str : TSGString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
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
if StringMatching(SGUpCaseString(URL), 'LOCALHOST*') then
	begin
	Host := 'localhost';
	Port := 0;
	URI := '';
	if (StringWordCount(URL, ':') = 2) then
		if StringIsNumber(StringWordGet(URL, ':', 2)) then
			Port := SGVal(StringWordGet(URL, ':', 2))
		else
			SGHint('SGDecomposeURL: Error while pasring port!');
	end
else if StringMatching(URL, '*?.*?.*?.*?:*?') then
	begin
	Port := 0;
	URI := '';
	Host := StringWordGet(URL, ':', 1);
	if StringIsNumber(StringWordGet(URL, ':', 2)) then
		Port := SGVal(StringWordGet(URL, ':', 2))
	else
		SGHint('SGDecomposeURL: Error while pasring port!');
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

function SGSetURLProtocol(const URL, Protocol : TSGString) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := URL;
if StringWordCount(URL, ':') = 2 then
	Result := Protocol + ':' + StringWordGet(URL, ':', 2)
else if StringWordCount(URL, ':') = 1 then
	Result := Protocol + '://' + URL
else
	Result := URL;
end;

function SGGetURLProtocol(const URL : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, Pos2 : TSGUInt32;
begin
if StringWordCount(URL, ':') = 2 then
	Result := StringWordGet(URL, ':', 1)
else
	Result := '';
end;

function SGCheckURL(const URL : TSGString; const Protocol : TSGString = ''; const Port : TSGUInt16 = 0) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	VPort : TSGUInt16;
	Host, URI : TSGString;
	URLProtocol : TSGString;
begin
Result := URL;
URLProtocol := SGGetURLProtocol(Result);
if (URLProtocol = '') and (Protocol <> '') then
	begin
	URLProtocol := Protocol;
	Result := SGSetURLProtocol(Result, URLProtocol);
	end;
DecomposeURL(Result, Host, URI, VPort);
if Port <> 0 then
	VPort := Port;
if URI = '' then
	URI := '/';
Result := URLProtocol + '://' + Host + URI;
if Port <> 0 then
	Result += ':' + SGStr(Port);
SGLog.Source(Result);
end;

end.
