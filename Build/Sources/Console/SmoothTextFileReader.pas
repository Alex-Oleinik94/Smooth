{$INCLUDE Smooth.inc}

unit SmoothTextFileReader;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothClasses
	;

type
	TSTextFileReader = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FFileName : TSString;
		FFile : TStream;
			protected
		function OpenAsMemoryStream() : TMemoryStream;
		function OpenAsFileStream() : TFileStream;
			public
		procedure Open(const TextFileName : TSString); virtual; overload;
		procedure Open(); virtual; overload;
		function EndOfFile() : TSBoolean;
		function EndOfLine() : TSBoolean;
		function ReadString() : TSString;
		function ReadChar() : TSChar;
			public
		property FileName : TSString read FFileName;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothResourceManager
	;

constructor TSTextFileReader.Create();
begin
inherited;
FFile := nil;
FFileName := '';
end;

destructor TSTextFileReader.Destroy();
begin
SKill(FFile);
inherited;
end;

function TSTextFileReader.EndOfFile() : TSBoolean;
begin
Result := True;
if FFile <> nil then
	Result := FFile.Position = FFile.Size;
end;

function TSTextFileReader.EndOfLine() : TSBoolean;

function CheckReadedChar() : TSBoolean;
var
	C : TSChar;
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

function TSTextFileReader.ReadString() : TSString;
begin
Result := SReadLnStringFromStream(FFile);
end;

function TSTextFileReader.ReadChar() : TSChar;
begin
FFile.ReadBuffer(Result, 1);
end;

procedure TSTextFileReader.Open(); overload;
begin
SKill(FFile);
FFile := OpenAsMemoryStream();
//FFile := OpenAsFileStream();
end;

procedure TSTextFileReader.Open(const TextFileName : TSString); overload;
begin
FFileName := TextFileName;
Open();
end;

function TSTextFileReader.OpenAsMemoryStream() : TMemoryStream;
begin
Result := TMemoryStream.Create();
Result.LoadFromFile(FFileName);
Result.Position := 0;
end;

function TSTextFileReader.OpenAsFileStream() : TFileStream;
begin
Result := TFileStream.Create(FFileName, fmOpenRead);
end;

end.
