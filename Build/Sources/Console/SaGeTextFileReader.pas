{$INCLUDE SaGe.inc}

unit SaGeTextFileReader;

interface

uses
	 Classes
	
	,SaGeBase
	,SaGeClasses
	;

type
	TSGTextFileReader = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FFileName : TSGString;
		FFile : TStream;
			protected
		function OpenAsMemoryStream() : TMemoryStream;
		function OpenAsFileStream() : TFileStream;
			public
		procedure Open(const TextFileName : TSGString); virtual; overload;
		procedure Open(); virtual; overload;
		function EndOfFile() : TSGBoolean;
		function EndOfLine() : TSGBoolean;
		function ReadString() : TSGString;
		function ReadChar() : TSGChar;
			public
		property FileName : TSGString read FFileName;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeResourceManager
	;

constructor TSGTextFileReader.Create();
begin
inherited;
FFile := nil;
FFileName := '';
end;

destructor TSGTextFileReader.Destroy();
begin
SGKill(FFile);
inherited;
end;

function TSGTextFileReader.EndOfFile() : TSGBoolean;
begin
Result := True;
if FFile <> nil then
	Result := FFile.Position = FFile.Size;
end;

function TSGTextFileReader.EndOfLine() : TSGBoolean;

function CheckReadedChar() : TSGBoolean;
var
	C : TSGChar;
begin
C := ReadChar();
FFile.Position := FFile.Position - 1;
Result := C in [#10,#13,#0];
end;

begin
if FFile.Position = FFile.Size then
	Result := True
else
	Result := CheckReadedChar();
end;

function TSGTextFileReader.ReadString() : TSGString;
begin
Result := SGReadLnStringFromStream(FFile);
end;

function TSGTextFileReader.ReadChar() : TSGChar;
begin
FFile.ReadBuffer(Result, 1);
end;

procedure TSGTextFileReader.Open(); overload;
begin
SGKill(FFile);
FFile := OpenAsMemoryStream();
//FFile := OpenAsFileStream();
end;

procedure TSGTextFileReader.Open(const TextFileName : TSGString); overload;
begin
FFileName := TextFileName;
Open();
end;

function TSGTextFileReader.OpenAsMemoryStream() : TMemoryStream;
begin
Result := TMemoryStream.Create();
Result.LoadFromFile(FFileName);
Result.Position := 0;
end;

function TSGTextFileReader.OpenAsFileStream() : TFileStream;
begin
Result := TFileStream.Create(FFileName, fmOpenRead);
end;

end.
